--!strict
-- Puts a look on your own character, on this client only. A model is built from a
-- HumanoidDescription and its body parts, clothing, accessories and animations are copied onto
-- your character; a copy of your own look is kept and put back when the look is released.
-- Other players' characters are never touched: their look is read from their description.

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")

local Env = require("../../platform/Env")
local Rules = require("./Rules")

local OWNED = "TZAR_Look"
local VERIFY_EVERY = 0.5

local R15_PARTS = {
    "Head",
    "UpperTorso",
    "LowerTorso",
    "LeftUpperArm",
    "LeftLowerArm",
    "LeftHand",
    "RightUpperArm",
    "RightLowerArm",
    "RightHand",
    "LeftUpperLeg",
    "LeftLowerLeg",
    "LeftFoot",
    "RightUpperLeg",
    "RightLowerLeg",
    "RightFoot",
}
local R6_PARTS = { "Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }
local PART_VISUALS: { [string]: boolean } =
    { SpecialMesh = true, FaceControls = true, WrapTarget = true, SurfaceAppearance = true }

type Expect = { meshId: string?, size: Vector3, initial: Vector3? }

type Current = {
    owner: string,
    desc: HumanoidDescription,
    label: string,
    model: Model?,
    clips: { [string]: number },
    rig: Enum.HumanoidRigType?,
    char: Model?,
    expect: { [BasePart]: Expect },
}

export type Look = {
    -- Marks `owner` as the one wearing a look, before it is built (a switch never flashes back).
    claim: (owner: string) -> (),
    -- Builds and puts on the look; yields. Errors go to the caller.
    apply: (owner: string, desc: HumanoidDescription, label: string) -> { string },
    -- Gives your own look back, unless another owner took over meanwhile.
    release: (owner: string) -> (),
    owner: () -> string?,
    current: () -> (HumanoidDescription?, string?),
    -- A detached copy of what you look like now (worn look or your own), for a preview.
    preview: () -> Model?,
    setRules: (on: boolean) -> (),
    destroy: () -> (),
}

local lp = Players.LocalPlayer

local function own<T>(inst: T): T
    (inst :: any):SetAttribute(OWNED, true)
    return inst
end

local function isOwned(inst: Instance): boolean
    return inst:GetAttribute(OWNED) == true
end

local function isPartVisual(x: Instance): boolean
    return PART_VISUALS[x.ClassName] == true or (x:IsA("Decal") and x.Name == "face")
end

local function isAvatarAccessory(x: Instance): boolean
    if not x:IsA("Accoutrement") then
        return false
    end
    local h = x:FindFirstChild("Handle")
    return h ~= nil and h:IsA("BasePart")
end

local function isAppearanceItem(x: Instance): boolean
    return x:IsA("Clothing")
        or x:IsA("ShirtGraphic")
        or x:IsA("BodyColors")
        or x:IsA("CharacterMesh")
end

local function accessories(model: Instance): { Instance }
    local out = {}
    for _, d in model:GetDescendants() do
        if
            isAvatarAccessory(d)
            and not d:FindFirstAncestorWhichIsA("Tool")
            and not d:FindFirstAncestorWhichIsA("Accoutrement")
        then
            table.insert(out, d)
        end
    end
    return out
end

local function partNames(hum: Humanoid): { string }
    return if hum.RigType == Enum.HumanoidRigType.R15 then R15_PARTS else R6_PARTS
end

-- A copy of your own character to restore from (scripts and tools left out).
local function snapshot(char: Model): Model
    for _, d in char:GetDescendants() do
        if not d.Archivable then
            pcall(function()
                d.Archivable = true
            end)
        end
    end
    local prev = char.Archivable
    char.Archivable = true
    local c = char:Clone()
    char.Archivable = prev
    for _, d in c:GetDescendants() do
        if d.ClassName == "Script" or d:IsA("Tool") then
            d:Destroy()
        end
    end
    return c
end

local function syncPart(src: BasePart, dst: BasePart)
    if dst:IsA("MeshPart") and src:IsA("MeshPart") then
        if dst.MeshId ~= src.MeshId then
            pcall(function()
                dst.MeshId = src.MeshId
            end)
        end
        if dst.TextureID ~= src.TextureID then
            pcall(function()
                dst.TextureID = src.TextureID
            end)
        end
        local initial = Env.getHidden(src, "InitialSize")
        if initial then
            Env.setHidden(dst, "InitialSize", initial)
        end
    end
    dst.Size = src.Size
    dst.Color = src.Color
    for _, c in dst:GetChildren() do
        if isPartVisual(c) then
            c:Destroy()
        end
    end
    for _, c in src:GetChildren() do
        if isPartVisual(c) then
            own(c:Clone()).Parent = dst
        elseif c:IsA("Attachment") then
            local a = dst:FindFirstChild(c.Name)
            if a and a:IsA("Attachment") then
                a.CFrame = c.CFrame
            else
                own(c:Clone()).Parent = dst
            end
        elseif
            c:IsA("ValueBase") and (c.Name == "OriginalSize" or c.Name == "AvatarPartScaleType")
        then
            local v = dst:FindFirstChild(c.Name)
            if v and v.ClassName == c.ClassName then
                (v :: any).Value = (c :: any).Value
            end
        end
    end
end

local function sourceMotor(src: Model, m: Motor6D): Motor6D?
    local p1 = m.Part1
    for _, d in src:GetDescendants() do
        if d:IsA("Motor6D") and d.Name == m.Name then
            local dp1 = d.Part1
            if dp1 and p1 and dp1.Name == p1.Name then
                return d
            end
        end
    end
    return nil
end

-- Joints follow the new parts' rig attachments, or the source model's joints.
local function syncJoints(src: Model, char: Model)
    for _, m in char:GetDescendants() do
        if m:IsA("Motor6D") then
            local p0, p1 = m.Part0, m.Part1
            if p0 and p1 and p0.Parent == char and p1.Parent == char then
                local done = false
                for _, a1 in p1:GetChildren() do
                    if a1:IsA("Attachment") and string.match(a1.Name, "RigAttachment$") then
                        local a0 = p0:FindFirstChild(a1.Name)
                        if a0 and a0:IsA("Attachment") then
                            m.C0 = a0.CFrame
                            m.C1 = a1.CFrame
                            done = true
                            break
                        end
                    end
                end
                if not done then
                    local sm = sourceMotor(src, m)
                    if sm then
                        m.C0 = sm.C0
                        m.C1 = sm.C1
                    end
                end
            end
        end
    end
end

local function bodyAttachment(char: Model, name: string): Attachment?
    for _, p in char:GetChildren() do
        if p:IsA("BasePart") then
            local a = p:FindFirstChild(name)
            if a and a:IsA("Attachment") then
                return a
            end
        end
    end
    return nil
end

local function attachAccessory(acc: Instance, char: Model)
    local h = acc:FindFirstChild("Handle")
    if not h or not h:IsA("BasePart") then
        return
    end
    for _, j in h:GetChildren() do
        if j:IsA("JointInstance") or j:IsA("WeldConstraint") then
            j:Destroy()
        end
    end
    h.Anchored = false
    h.CanCollide = false
    h.Massless = true
    pcall(function()
        h.CanTouch = false
        h.CanQuery = false
    end)
    local w = Instance.new("Weld")
    w.Name = "AccessoryWeld"
    w.Part0 = h
    for _, att in h:GetChildren() do
        if att:IsA("Attachment") then
            local target = bodyAttachment(char, att.Name)
            if target then
                w.C0 = att.CFrame
                w.C1 = target.CFrame
                w.Part1 = target.Parent :: BasePart
                break
            end
        end
    end
    if not w.Part1 then
        local head = char:FindFirstChild("Head")
        if not (head and head:IsA("BasePart")) then
            w:Destroy()
            return
        end
        w.C0 = (acc :: any).AttachmentPoint
        w.C1 = CFrame.new(0, head.Size.Y / 2, 0)
        w.Part1 = head
    end
    w.Parent = h
end

local function animIds(sv: Instance): string
    local t = {}
    for _, a in sv:GetChildren() do
        if a:IsA("Animation") then
            table.insert(t, a.AnimationId)
        end
    end
    return table.concat(t, ";")
end

-- Animation packs live in the Animate script's StringValues; Animate restarts to pick them up.
local function copyAnimate(src: Model, char: Model, clips: { [string]: number })
    local sA, dA = src:FindFirstChild("Animate"), char:FindFirstChild("Animate")
    if not (sA and dA) then
        return
    end
    local changed = false
    for _, sv in sA:GetChildren() do
        local dv = dA:FindFirstChild(sv.Name)
        if
            sv:IsA("StringValue")
            and dv
            and dv:IsA("StringValue")
            and animIds(sv) ~= animIds(dv)
        then
            for _, c in dv:GetChildren() do
                c:Destroy()
            end
            for _, c in sv:GetChildren() do
                c:Clone().Parent = dv
            end
            changed = true
        end
    end
    for slot, id in clips do
        local dv = dA:FindFirstChild(slot)
        local a = dv and dv:FindFirstChildOfClass("Animation")
        local want = "rbxassetid://" .. id
        if a and a.AnimationId ~= want then
            a.AnimationId = want
            changed = true
        end
    end
    if changed and dA:IsA("LocalScript") then
        local hum = char:FindFirstChildOfClass("Humanoid")
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if animator then
            for _, t in animator:GetPlayingAnimationTracks() do
                t:Stop(0)
            end
        end
        dA.Enabled = false
        task.wait()
        dA.Enabled = true
    end
end

-- Copies `src`'s look onto `char`; returns what to watch for (the game changing it back).
local function transplant(
    src: Model,
    char: Model,
    clips: { [string]: number }?
): { [BasePart]: Expect }
    local expect: { [BasePart]: Expect } = {}
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then
        return expect
    end
    local isR15 = hum.RigType == Enum.HumanoidRigType.R15
    for _, n in partNames(hum) do
        local s, d = src:FindFirstChild(n), char:FindFirstChild(n)
        if s and d and s:IsA("BasePart") and d:IsA("BasePart") then
            syncPart(s, d)
            expect[d] = {
                meshId = if d:IsA("MeshPart") then d.MeshId else nil,
                size = d.Size,
                initial = if d:IsA("MeshPart") then Env.getHidden(d, "InitialSize") else nil,
            }
        end
    end
    local sRoot, dRoot =
        src:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("HumanoidRootPart")
    if sRoot and dRoot and sRoot:IsA("BasePart") and dRoot:IsA("BasePart") then
        for _, a in sRoot:GetChildren() do
            local d = if a:IsA("Attachment") then dRoot:FindFirstChild(a.Name) else nil
            if d and d:IsA("Attachment") then
                d.CFrame = (a :: Attachment).CFrame
            end
        end
    end
    syncJoints(src, char)

    local srcHum = src:FindFirstChildOfClass("Humanoid")
    if isR15 and srcHum and sRoot and dRoot and sRoot:IsA("BasePart") and dRoot:IsA("BasePart") then
        hum.HipHeight = srcHum.HipHeight + (sRoot.Size.Y - dRoot.Size.Y) / 2
    end

    for _, c in char:GetChildren() do
        if isAppearanceItem(c) then
            c:Destroy()
        end
    end
    for _, acc in accessories(char) do
        acc:Destroy()
    end
    for _, c in src:GetChildren() do
        if isAppearanceItem(c) then
            own(c:Clone()).Parent = char
        end
    end
    for _, c in accessories(src) do
        local acc = own(c:Clone())
        attachAccessory(acc, char)
        acc.Parent = char
    end
    if isR15 then
        copyAnimate(src, char, clips or {})
    end
    return expect
end

local Look = {}

function Look.new(log: (msg: string) -> ()): Look
    local originals: { [Model]: Model } = setmetatable({}, { __mode = "k" }) :: any
    -- Characters that spawned while this runs: false until their appearance has loaded. Right
    -- after a respawn HasAppearanceLoaded still answers for the old character, so a copy of your
    -- own look taken then would have no clothes or accessories to give back.
    local fresh: { [Model]: boolean } = setmetatable({}, { __mode = "k" }) :: any
    local conns = {
        lp.CharacterAdded:Connect(function(c: Model)
            fresh[c] = false
        end),
        lp.CharacterAppearanceLoaded:Connect(function(c: Model)
            fresh[c] = true
        end),
    }
    local function waitAppearance(char: Model)
        local t0 = os.clock()
        if fresh[char] == nil then
            while not lp:HasAppearanceLoaded() and os.clock() - t0 < 6 and lp.Character == char do
                task.wait(0.1)
            end
            return
        end
        while fresh[char] == false and os.clock() - t0 < 8 and lp.Character == char do
            task.wait(0.1)
        end
        -- Layered clothing and accessories settle a moment after the event.
        task.wait(0.3)
    end
    local cur: Current? = nil
    local claimed: string? = nil
    local busy = false
    local rules = false
    local alive = true

    local function build(
        desc: HumanoidDescription,
        rig: Enum.HumanoidRigType
    ): (Model, { [string]: number }, { string })
        local copy = desc:Clone()
        local notes: { string } = {}
        local post: Rules.Post = { clips = {}, scale = false }
        if rules then
            post = Rules.apply(copy, notes)
        end
        local ok, built = Rules.call(Players, "CreateHumanoidModelFromDescription", copy, rig)
        copy:Destroy()
        if not ok or typeof(built) ~= "Instance" then
            error(tostring(built), 0)
        end
        local model = built :: Model
        if rules then
            Rules.limit(model, post, notes)
        end
        pcall(ContentProvider.PreloadAsync, ContentProvider, { model })
        return model, post.clips, notes
    end

    -- Puts the current look on the current character, building the model again when needed.
    local function put(c: Current): { string }
        local char = lp.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not (char and hum) then
            return {}
        end
        if not originals[char] then
            originals[char] = snapshot(char)
        end
        local notes: { string } = {}
        if not c.model or c.rig ~= hum.RigType then
            if c.model then
                c.model:Destroy()
            end
            local model, clips, n = build(c.desc, hum.RigType)
            c.model, c.clips, c.rig, notes = model, clips, hum.RigType, n
        end
        c.expect = transplant(c.model :: Model, char, c.clips)
        c.char = char
        return notes
    end

    local function restore()
        local c = cur
        if not c then
            return
        end
        cur = nil
        if c.model then
            c.model:Destroy()
        end
        local char = lp.Character
        local orig = char and originals[char]
        if char and orig then
            transplant(orig, char, nil)
        end
    end

    -- The game may put its own look back (respawn scripts, morphs): put ours on again.
    local function changed(c: Current): boolean
        local char = lp.Character
        if not char or c.char ~= char then
            return false
        end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then
            return false
        end
        for _, n in partNames(hum) do
            local p = char:FindFirstChild(n)
            if p and p:IsA("BasePart") then
                local e = c.expect[p]
                if not e then
                    return true
                end
                if e.meshId and p:IsA("MeshPart") and p.MeshId ~= e.meshId then
                    return true
                end
                if (p.Size - e.size).Magnitude > 1e-3 then
                    return true
                end
                local initial = e.initial and Env.getHidden(p, "InitialSize")
                if initial and e.initial and (initial - e.initial).Magnitude > 1e-3 then
                    return true
                end
                for _, x in p:GetChildren() do
                    if isPartVisual(x) and not isOwned(x) then
                        return true
                    end
                end
            end
        end
        for _, x in char:GetChildren() do
            if isAppearanceItem(x) and not isOwned(x) then
                return true
            end
        end
        for _, acc in accessories(char) do
            if not isOwned(acc) then
                return true
            end
        end
        return false
    end

    task.spawn(function()
        while alive do
            task.wait(VERIFY_EVERY)
            local c = cur
            if alive and c and not busy and claimed == c.owner then
                local ok, yes = pcall(changed, c)
                if ok and yes then
                    busy = true
                    local okPut, err = pcall(put, c)
                    busy = false
                    if not okPut then
                        log("look: " .. tostring(err))
                    end
                end
            end
        end
    end)

    local self: Look
    self = {
        claim = function(owner: string)
            claimed = owner
        end,
        apply = function(owner: string, desc: HumanoidDescription, label: string): { string }
            claimed = owner
            local char = lp.Character
            if char then
                waitAppearance(char)
            end
            local old = cur
            local c: Current = {
                owner = owner,
                desc = desc,
                label = label,
                clips = {},
                expect = {},
            }
            busy = true
            local ok, notes = pcall(put, c)
            busy = false
            if not ok then
                if c.model then
                    c.model:Destroy()
                end
                error(notes, 0)
            end
            if claimed ~= owner then
                -- Someone else took over while this one was loading.
                if c.model then
                    c.model:Destroy()
                end
                return {}
            end
            if old and old.model and old.model ~= c.model then
                old.model:Destroy()
            end
            cur = c
            return notes
        end,
        release = function(owner: string)
            if claimed ~= owner then
                return
            end
            claimed = nil
            -- Re-enabling (new arguments, respawn) claims again within the same frame: no flash.
            task.defer(function()
                if claimed == nil then
                    restore()
                end
            end)
        end,
        owner = function(): string?
            local c = cur
            return if c then c.owner else nil
        end,
        current = function(): (HumanoidDescription?, string?)
            local c = cur
            if c then
                return c.desc, c.label
            end
            return nil, nil
        end,
        preview = function(): Model?
            local c = cur
            local src: Model? = if c and c.model then c.model else lp.Character
            if not src then
                return nil
            end
            local ok, copy = pcall(snapshot, src)
            if not ok then
                return nil
            end
            for _, d in copy:GetDescendants() do
                if d:IsA("LuaSourceContainer") or d:IsA("Sound") or d:IsA("ForceField") then
                    d:Destroy()
                elseif d:IsA("BasePart") then
                    d.Anchored = true
                end
            end
            return copy
        end,
        setRules = function(on: boolean)
            if rules == on then
                return
            end
            rules = on
            local c = cur
            if c and not busy then
                if c.model then
                    c.model:Destroy()
                    c.model = nil
                end
                busy = true
                local ok, err = pcall(put, c)
                busy = false
                if not ok then
                    log("look: " .. tostring(err))
                end
            end
        end,
        destroy = function()
            alive = false
            for _, c in conns do
                c:Disconnect()
            end
            claimed = nil
            restore()
            for _, m in originals do
                m:Destroy()
            end
            table.clear(originals)
        end,
    }
    return self
end

return Look
