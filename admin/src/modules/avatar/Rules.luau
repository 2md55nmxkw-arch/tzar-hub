--!strict
-- The game's own avatar rules: AvatarSettings (body, accessories, clothing, animations) and the
-- older game-start-info limits. Applied to a copy of the description before the model is built,
-- so a look worn here fits what this game allows. Read once per session.

local MarketplaceService = game:GetService("MarketplaceService")
local StarterPlayer = game:GetService("StarterPlayer")

local Env = require("../../platform/Env")

export type Post = {
    -- Animate slot name -> animation id the game forces.
    clips: { [string]: number },
    accLimit: Vector3?,
    clothLimit: Vector3?,
    -- true: oversized accessories are scaled down; false: removed.
    scale: boolean,
}

type Data = {
    legacy: any,
    body: Instance?,
    acc: Instance?,
    cloth: Instance?,
    anim: Instance?,
}

local Rules = {}

local ASSET_FIELD: { [number]: string } = {
    [2] = "GraphicTShirt",
    [11] = "Shirt",
    [12] = "Pants",
    [17] = "Head",
    [18] = "Face",
    [27] = "Torso",
    [28] = "RightArm",
    [29] = "LeftArm",
    [30] = "LeftLeg",
    [31] = "RightLeg",
    [78] = "MoodAnimation",
    [79] = "Head",
}
Rules.ASSET_FIELD = ASSET_FIELD

local ANIM_FIELDS = {
    "ClimbAnimation",
    "FallAnimation",
    "IdleAnimation",
    "JumpAnimation",
    "MoodAnimation",
    "RunAnimation",
    "SwimAnimation",
    "WalkAnimation",
}
local BODY_FIELDS = { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }

local cache: Data? = nil

-- obj:NameAsync(...), or obj:Name(...) on clients from before the Async rename. Never throws.
function Rules.call(obj: any, name: string, ...: any): (boolean, any)
    local args = table.pack(...)
    local hasAsync, async = pcall(function(): any
        return obj[name .. "Async"]
    end)
    local fn: any = if hasAsync and async then async else nil
    if not fn then
        local hasOld, old = pcall(function(): any
            return obj[name]
        end)
        fn = if hasOld then old else nil
    end
    if not fn then
        return false, "no " .. name
    end
    return pcall(function(): any
        return fn(obj, table.unpack(args, 1, args.n))
    end)
end

-- Catalog info for an asset, or nil.
function Rules.productInfo(id: number): any
    local ok, info = Rules.call(MarketplaceService, "GetProductInfo", id)
    return if ok and type(info) == "table" then info else nil
end

local function httpJson(url: string): any
    local res = Env.http(url)
    if not res or not res.ok then
        return nil
    end
    return Env.json(res.body)
end

local function prop(inst: Instance?, name: string): any
    if not inst then
        return nil
    end
    local ok, v = pcall(function()
        return (inst :: any)[name]
    end)
    return if ok then v else nil
end

-- Enum items compared by name: older clients do not have every AvatarSettings enum.
local function is(v: any, name: string): boolean
    return typeof(v) == "EnumItem" and (v :: EnumItem).Name == name
end

-- AvatarSettings asset ids: 0, or -1 on newer clients, mean "no override".
local function num(v: any): number
    local n = tonumber(v)
    return if n and n > 0 then n else 0
end

local function load(): Data
    local c = cache
    if c then
        return c
    end
    local d: Data = {
        legacy = httpJson(
            "https://avatar.roblox.com/v1/game-start-info?universeId=" .. tostring(game.GameId)
        ),
    }
    local ok, settings = pcall(function(): any
        return (game :: any):GetService("AvatarSettings")
    end)
    local root: Instance? = if ok and settings
        then settings:FindFirstChildOfClass("AvatarRules")
        else nil
    if root then
        d.body = root:FindFirstChildOfClass("AvatarBodyRules")
        d.acc = root:FindFirstChildOfClass("AvatarAccessoryRules")
        d.cloth = root:FindFirstChildOfClass("AvatarClothingRules")
        d.anim = root:FindFirstChildOfClass("AvatarAnimationRules")
    end
    cache = d
    return d
end

-- Replaces every accessory of one type with the given asset.
local function setAccessory(
    desc: HumanoidDescription,
    typeName: string,
    assetId: number,
    layered: boolean
)
    pcall(function()
        local accType = (Enum.AccessoryType :: any)[typeName]
        local out = {}
        for _, a in desc:GetAccessories(true) do
            if a.AccessoryType ~= accType then
                table.insert(out, a)
            end
        end
        table.insert(out, {
            AssetId = assetId,
            AccessoryType = accType,
            IsLayered = layered,
            Order = if layered then #out + 1 else nil,
        })
        desc:SetAccessories(out, true)
    end)
end

local function clampField(
    desc: HumanoidDescription,
    field: string,
    lo: any,
    hi: any,
    notes: { string }
)
    local a, b = tonumber(lo), tonumber(hi)
    if not a or not b or (a == 0 and b == 0) then
        return
    end
    local d = desc :: any
    local v = d[field]
    local c = math.clamp(v, math.min(a, b), math.max(a, b))
    if math.abs(c - v) > 1e-4 then
        d[field] = c
        table.insert(notes, string.format("%s %.2f→%.2f", field, v, c))
    end
end

local function clampRange(desc: HumanoidDescription, field: string, range: any, notes: { string })
    if typeof(range) == "NumberRange" then
        clampField(desc, field, range.Min, range.Max, notes)
    end
end

local function applyBundle(
    desc: HumanoidDescription,
    bundleId: number,
    keepHead: boolean,
    notes: { string }
)
    local data = httpJson("https://catalog.roblox.com/v1/bundles/" .. bundleId .. "/details")
    if type(data) ~= "table" or type(data.items) ~= "table" then
        return
    end
    for _, it in data.items do
        if it.type == "Asset" then
            local info = Rules.productInfo(it.id)
            local field = info and ASSET_FIELD[info.AssetTypeId]
            if field and not (keepHead and field == "Head") then
                (desc :: any)[field] = it.id
            end
        end
    end
    table.insert(notes, "bundle " .. bundleId)
end

-- Changes `desc` in place; returns what has to happen after the model is built.
function Rules.apply(desc: HumanoidDescription, notes: { string }): Post
    local r = load()
    local d = desc :: any
    local post: Post = { clips = {}, scale = false }

    if StarterPlayer.LoadCharacterAppearance == false then
        table.insert(notes, "game hides avatars")
    end

    local legacy = r.legacy
    if type(legacy) == "table" then
        local mn = legacy.universeAvatarMinScales or {}
        local mx = legacy.universeAvatarMaxScales or {}
        local map: { [string]: string } = {
            height = "HeightScale",
            width = "WidthScale",
            head = "HeadScale",
            depth = "DepthScale",
            proportion = "ProportionScale",
            bodyType = "BodyTypeScale",
        }
        for key, field in map do
            clampField(desc, field, mn[key], mx[key], notes)
        end
        for _, o in legacy.universeAvatarAssetOverrides or {} do
            local field = ASSET_FIELD[o.assetTypeID]
            if field and not o.isPlayerChoice and num(o.assetID) ~= 0 then
                d[field] = o.assetID
                table.insert(notes, field .. "=" .. tostring(o.assetID))
            end
        end
        if tostring(legacy.allowCustomAnimations) == "False" then
            for _, f in ANIM_FIELDS do
                d[f] = 0
            end
            table.insert(notes, "standard animations")
        end
    end

    local b = r.body
    if b then
        local mode = prop(b, "AppearanceMode")
        if is(mode, "CustomParts") then
            for _, part in { "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg", "Face" } do
                local id = num(prop(b, "Custom" .. part .. "Id"))
                if prop(b, "Custom" .. part .. "Enabled") and id ~= 0 then
                    d[part] = id
                    table.insert(notes, part .. "=" .. id)
                end
            end
            if prop(b, "CustomMoodEnabled") and num(prop(b, "CustomMoodId")) ~= 0 then
                d.MoodAnimation = num(prop(b, "CustomMoodId"))
            end
            if prop(b, "CustomEyebrowEnabled") and num(prop(b, "CustomEyebrowId")) ~= 0 then
                setAccessory(desc, "Eyebrow", num(prop(b, "CustomEyebrowId")), false)
            end
            if prop(b, "CustomEyelashEnabled") and num(prop(b, "CustomEyelashId")) ~= 0 then
                setAccessory(desc, "Eyelash", num(prop(b, "CustomEyelashId")), false)
            end
        elseif is(mode, "CustomBody") then
            local bundle = num(prop(b, "CustomBodyBundleId"))
            if is(prop(b, "CustomBodyType"), "BundleId") and bundle ~= 0 then
                applyBundle(desc, bundle, prop(b, "KeepPlayerHead") == true, notes)
            end
        end
        for _, part in BODY_FIELDS do
            local v = num(prop(b, part .. "Override"))
            if v ~= 0 then
                d[part] = v
                table.insert(notes, part .. "=" .. v)
            end
        end
        if is(prop(b, "ScaleMode"), "CustomScale") then
            clampRange(desc, "HeightScale", prop(b, "CustomHeightScale"), notes)
            clampRange(desc, "WidthScale", prop(b, "CustomWidthScale"), notes)
            clampRange(desc, "HeadScale", prop(b, "CustomHeadScale"), notes)
            clampRange(desc, "BodyTypeScale", prop(b, "CustomBodyTypeScale"), notes)
            clampRange(desc, "ProportionScale", prop(b, "CustomProportionsScale"), notes)
        end
        if is(prop(b, "BuildMode"), "CustomBuild") then
            clampRange(desc, "HeightScale", prop(b, "CustomBuildHeight"), notes)
            clampRange(desc, "WidthScale", prop(b, "CustomBuildWidth"), notes)
            clampRange(desc, "HeadScale", prop(b, "CustomBuildHead"), notes)
            clampRange(desc, "BodyTypeScale", prop(b, "CustomBuildBodyType"), notes)
            clampRange(desc, "ProportionScale", prop(b, "CustomBuildProportions"), notes)
        end
    end

    local a = r.acc
    if a then
        local custom = is(prop(a, "CustomAccessoryMode"), "CustomAccessories")
        local slots: { [string]: string } = {
            Back = "Back",
            Face = "Face",
            Front = "Front",
            Hair = "Hair",
            Head = "Hat",
            Neck = "Neck",
            Shoulder = "Shoulder",
            Waist = "Waist",
        }
        for slot, accType in slots do
            local id = 0
            if custom and prop(a, "Custom" .. slot .. "AccessoryEnabled") then
                id = num(prop(a, "Custom" .. slot .. "AccessoryId"))
            end
            if id == 0 then
                id = num(prop(a, slot .. "AccessoryOverride"))
            end
            if id ~= 0 then
                setAccessory(desc, accType, id, false)
                table.insert(notes, accType .. "=" .. id)
            end
        end
        local method = prop(a, "LimitMethod")
        if
            is(prop(a, "AccessoryMode"), "CustomLimit")
            and (is(method, "Scale") or is(method, "Remove"))
        then
            local bounds = prop(a, "LimitBounds")
            post.accLimit = if typeof(bounds) == "Vector3" then bounds else nil
            post.scale = is(method, "Scale")
        end
    end

    local c = r.cloth
    if c then
        local custom = is(prop(c, "CustomClothingMode"), "CustomClothing")
        local function pick(key: string): number
            local id = 0
            if custom and prop(c, "Custom" .. key .. "AccessoryEnabled") then
                id = num(prop(c, "Custom" .. key .. "AccessoryId"))
            end
            if id == 0 then
                id = num(prop(c, key .. "AccessoryOverride"))
            end
            return id
        end
        local classic: { [string]: string } =
            { ClassicShirts = "Shirt", ClassicPants = "Pants", ClassicTShirts = "GraphicTShirt" }
        for key, field in classic do
            local id = pick(key)
            if id ~= 0 then
                d[field] = id
                table.insert(notes, field .. "=" .. id)
            end
        end
        local layered: { [string]: string } = {
            Jacket = "Jacket",
            Shirt = "Shirt",
            Sweater = "Sweater",
            TShirt = "TShirt",
            Pants = "Pants",
            Shorts = "Shorts",
            DressSkirt = "DressSkirt",
            LeftShoes = "LeftShoe",
            RightShoes = "RightShoe",
        }
        for key, accType in layered do
            local id = pick(key)
            if id ~= 0 then
                setAccessory(desc, accType, id, true)
                table.insert(notes, accType .. "=" .. id)
            end
        end
        if is(prop(c, "ClothingMode"), "CustomLimit") then
            local bounds = prop(c, "LimitBounds")
            post.clothLimit = if typeof(bounds) == "Vector3" then bounds else nil
        end
    end

    local an = r.anim
    if an then
        local packs = prop(an, "AnimationPacksMode")
        if typeof(packs) == "EnumItem" and not is(packs, "PlayerChoice") then
            for _, f in ANIM_FIELDS do
                d[f] = 0
            end
            table.insert(notes, "standard animations")
        end
        local customClips = is(prop(an, "AnimationClipsMode"), "CustomClips")
        local clipSlots: { [string]: string } = {
            Climb = "climb",
            Fall = "fall",
            Idle = "idle",
            Jump = "jump",
            Run = "run",
            Swim = "swim",
            SwimIdle = "swimidle",
            Walk = "walk",
        }
        for key, slot in clipSlots do
            local id = 0
            if customClips and prop(an, "Custom" .. key .. "AnimationEnabled") then
                id = num(prop(an, "Custom" .. key .. "AnimationId"))
            end
            if id == 0 then
                id = num(prop(an, key .. "AnimationOverride"))
            end
            if id ~= 0 then
                post.clips[slot] = id
            end
        end
        local mood = num(prop(an, "MoodAnimationOverride"))
        if mood ~= 0 then
            d.MoodAnimation = mood
        end
    end

    return post
end

local function scaleAccessory(h: BasePart, f: number)
    h.Size *= f
    local m = h:FindFirstChildOfClass("SpecialMesh")
    if m then
        m.Scale *= f
    end
    for _, x in h:GetChildren() do
        if x:IsA("Attachment") then
            x.Position *= f
        end
    end
end

-- Shrinks or removes accessories bigger than the game allows.
function Rules.limit(model: Model, post: Post, notes: { string })
    for _, acc in model:GetChildren() do
        local h = if acc:IsA("Accoutrement") then acc:FindFirstChild("Handle") else nil
        if h and h:IsA("BasePart") then
            local layered = h:FindFirstChildOfClass("WrapLayer") ~= nil
            local bounds = if layered then post.clothLimit else post.accLimit
            if bounds and bounds.Magnitude > 0 then
                local f = 1
                for _, ax in { "X", "Y", "Z" } do
                    local lim = (bounds :: any)[ax] :: number
                    local size = (h.Size :: any)[ax] :: number
                    if lim > 0 and size > lim then
                        f = math.min(f, lim / size)
                    end
                end
                if f < 1 then
                    if not layered and post.scale then
                        scaleAccessory(h, f)
                        table.insert(notes, string.format("%s ×%.2f", acc.Name, f))
                    else
                        table.insert(notes, acc.Name .. " removed")
                        acc:Destroy()
                    end
                end
            end
        end
    end
end

return Rules
