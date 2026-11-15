--!strict
-- Emotes: an emote asset id is turned into its animation id (assetdelivery, gunzipped here, with
-- game:GetObjects as the fallback), cached on disk, and played on your own character through its
-- Animate script or its Animator. Animations on your own character replicate, so others see it.

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Env = require("../../platform/Env")
local Rules = require("./Rules")

local CACHE = "TZAR/admin/emote_anims.json"
local OLD_CACHE = "AvatarChanger/emote_anims.json"
local EMOTE_ASSET_TYPE = 61
local SLOTS = 8

export type WheelEmote = { id: number, name: string, fromOutfit: boolean }

local Emotes = {}

-- Inflate (RFC 1951) inside a gzip member (RFC 1952). Only used for small emote assets.
local LBASE = {
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    13,
    15,
    17,
    19,
    23,
    27,
    31,
    35,
    43,
    51,
    59,
    67,
    83,
    99,
    115,
    131,
    163,
    195,
    227,
    258,
}
local LEXT =
    { 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0 }
local DBASE = {
    1,
    2,
    3,
    4,
    5,
    7,
    9,
    13,
    17,
    25,
    33,
    49,
    65,
    97,
    129,
    193,
    257,
    385,
    513,
    769,
    1025,
    1537,
    2049,
    3073,
    4097,
    6145,
    8193,
    12289,
    16385,
    24577,
}
local DEXT = {
    0,
    0,
    0,
    0,
    1,
    1,
    2,
    2,
    3,
    3,
    4,
    4,
    5,
    5,
    6,
    6,
    7,
    7,
    8,
    8,
    9,
    9,
    10,
    10,
    11,
    11,
    12,
    12,
    13,
    13,
}
local ORDER = { 16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15 }

type Huff = { count: { [number]: number }, symbol: { [number]: number } }

local function huff(lengths: { [number]: number }, n: number, from: number): Huff
    local count: { [number]: number } = {}
    local offs: { [number]: number } = {}
    local sym: { [number]: number } = {}
    for i = 0, 15 do
        count[i] = 0
    end
    for i = 0, n - 1 do
        local l = lengths[from + i] or 0
        count[l] += 1
    end
    count[0] = 0
    offs[1] = 0
    for i = 1, 14 do
        offs[i + 1] = offs[i] + count[i]
    end
    for i = 0, n - 1 do
        local l = lengths[from + i] or 0
        if l ~= 0 then
            sym[offs[l]] = i
            offs[l] += 1
        end
    end
    return { count = count, symbol = sym }
end

function Emotes.gunzip(data: string): string
    local flg = string.byte(data, 4) or 0
    local pos = 11
    if bit32.band(flg, 4) ~= 0 then
        pos += 2 + (string.byte(data, pos) or 0) + (string.byte(data, pos + 1) or 0) * 256
    end
    if bit32.band(flg, 8) ~= 0 then
        pos = (string.find(data, "\0", pos, true) or #data) + 1
    end
    if bit32.band(flg, 16) ~= 0 then
        pos = (string.find(data, "\0", pos, true) or #data) + 1
    end
    if bit32.band(flg, 2) ~= 0 then
        pos += 2
    end
    local buf, cnt = 0, 0
    local out: { number } = {}
    local function bits(n: number): number
        while cnt < n do
            buf += bit32.lshift(string.byte(data, pos) or 0, cnt)
            pos += 1
            cnt += 8
        end
        local v = bit32.band(buf, bit32.lshift(1, n) - 1)
        buf = bit32.rshift(buf, n)
        cnt -= n
        return v
    end
    local function decode(h: Huff): number
        local code, first, index = 0, 0, 0
        for len = 1, 15 do
            code += bits(1)
            local c = h.count[len]
            if code - c < first then
                return h.symbol[index + (code - first)]
            end
            index += c
            first = (first + c) * 2
            code *= 2
        end
        error("bad huffman code")
    end
    repeat
        local final, typ = bits(1), bits(2)
        if typ == 0 then
            buf, cnt = 0, 0
            local len = (string.byte(data, pos) or 0) + (string.byte(data, pos + 1) or 0) * 256
            pos += 4
            for i = 0, len - 1 do
                out[#out + 1] = string.byte(data, pos + i) or 0
            end
            pos += len
        else
            local lens: { [number]: number } = {}
            local nlen, ndist = 288, 30
            if typ == 1 then
                for i = 0, 143 do
                    lens[i] = 8
                end
                for i = 144, 255 do
                    lens[i] = 9
                end
                for i = 256, 279 do
                    lens[i] = 7
                end
                for i = 280, 287 do
                    lens[i] = 8
                end
                for i = 0, 29 do
                    lens[288 + i] = 5
                end
            else
                nlen, ndist = bits(5) + 257, bits(5) + 1
                local ncode = bits(4) + 4
                local cl: { [number]: number } = {}
                for i = 1, ncode do
                    cl[ORDER[i]] = bits(3)
                end
                local clh = huff(cl, 19, 0)
                local raw: { [number]: number } = {}
                local i = 0
                while i < nlen + ndist do
                    local s = decode(clh)
                    if s < 16 then
                        raw[i] = s
                        i += 1
                    else
                        local rep, val = 0, 0
                        if s == 16 then
                            val = raw[i - 1]
                            rep = 3 + bits(2)
                        elseif s == 17 then
                            rep = 3 + bits(3)
                        else
                            rep = 11 + bits(7)
                        end
                        for _ = 1, rep do
                            raw[i] = val
                            i += 1
                        end
                    end
                end
                for k = 0, nlen - 1 do
                    lens[k] = raw[k]
                end
                for k = 0, ndist - 1 do
                    lens[288 + k] = raw[nlen + k]
                end
            end
            local lh, dh = huff(lens, nlen, 0), huff(lens, ndist, 288)
            while true do
                local s = decode(lh)
                if s < 256 then
                    out[#out + 1] = s
                elseif s == 256 then
                    break
                else
                    s -= 257
                    local len = LBASE[s + 1] + bits(LEXT[s + 1])
                    local ds = decode(dh)
                    local dist = DBASE[ds + 1] + bits(DEXT[ds + 1])
                    local start = #out - dist
                    for k = 1, len do
                        out[#out + 1] = out[start + k]
                    end
                end
            end
        end
    until final == 1
    local parts: { string } = {}
    for i = 1, #out, 4096 do
        parts[#parts + 1] = string.char(table.unpack(out, i, math.min(i + 4095, #out)))
    end
    return table.concat(parts)
end

-- Emote asset id (string key) -> animation id. Shared with the old Avatar Changer cache.
local animIds: { [string]: string }? = nil
local animations: { [number]: Animation } = {}

local function cache(): { [string]: string }
    local c = animIds
    if c then
        return c
    end
    local loaded: { [string]: string } = {}
    for _, path in { OLD_CACHE, CACHE } do
        local body = Env.readFile(path)
        local t = body and Env.json(body)
        if type(t) == "table" then
            for k, v in t do
                loaded[tostring(k)] = tostring(v)
            end
        end
    end
    animIds = loaded
    return loaded
end

local function resolve(id: number): string?
    local key = tostring(id)
    local c = cache()
    if c[key] then
        return c[key]
    end
    local animId: string? = nil
    local res = Env.http("https://assetdelivery.roblox.com/v1/asset/?id=" .. key)
    if res and res.ok and res.body ~= "" then
        local body = res.body
        if string.sub(body, 1, 2) == "\31\139" then
            local ok, raw = pcall(Emotes.gunzip, body)
            body = if ok then raw else ""
        end
        animId = string.match(body, "rbxassetid://(%d+)")
            or string.match(body, "[Aa]sset/%?[Ii][Dd]=(%d+)")
    end
    if not animId then
        local ok, objs = pcall(function(): any
            return (game :: any):GetObjects("rbxassetid://" .. key)
        end)
        local a = if ok and type(objs) == "table" then objs[1] else nil
        if typeof(a) == "Instance" and a:IsA("Animation") then
            animId = string.match(a.AnimationId, "(%d+)$")
        end
    end
    if animId then
        c[key] = animId
        local ok, body = pcall(HttpService.JSONEncode, HttpService, c)
        if ok then
            Env.writeFile(CACHE, body)
        end
    end
    return animId
end

function Emotes.animation(id: number): Animation?
    local a = animations[id]
    if a then
        return a
    end
    local animId = resolve(id)
    if not animId then
        return nil
    end
    local anim = Instance.new("Animation")
    -- The track takes this name, so the emote can be told apart from walk and idle tracks.
    anim.Name = "TZAR_Emote_" .. id
    anim.AnimationId = "rbxassetid://" .. animId
    animations[id] = anim
    return anim
end

-- Emote name from the catalog, or nil when the id is not an emote.
function Emotes.lookup(id: number): (string?, boolean)
    local info = Rules.productInfo(id)
    if not info then
        return nil, false
    end
    if info.AssetTypeId ~= EMOTE_ASSET_TYPE then
        return tostring(info.Name), false
    end
    return tostring(info.Name), true
end

-- Plays on your own R15 character; stops when you start running. false + reason key otherwise.
function Emotes.play(id: number): (boolean, string?)
    local char = Players.LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (char and hum) then
        return false, "av.no_character"
    end
    if hum.RigType ~= Enum.HumanoidRigType.R15 then
        return false, "av.r15_only"
    end
    local anim = Emotes.animation(id)
    if not anim then
        return false, "av.emote_failed"
    end
    local animate = char:FindFirstChild("Animate")
    local pe = animate and animate:FindFirstChild("PlayEmote")
    if pe and pe:IsA("BindableFunction") then
        local ok, res = pcall(pe.Invoke, pe, anim)
        if ok and res ~= false then
            return true, nil
        end
    end
    local animator = hum:FindFirstChildOfClass("Animator")
    if not animator then
        return false, "av.emote_failed"
    end
    local track = animator:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    local conn: RBXScriptConnection
    conn = hum.Running:Connect(function(speed: number)
        if speed > 0.5 then
            track:Stop(0.2)
            conn:Disconnect()
        end
    end)
    track.Stopped:Once(function()
        if conn.Connected then
            conn:Disconnect()
        end
    end)
    return true, nil
end

-- The worn look's equipped emotes (slot order), then your own list.
function Emotes.wheel(
    desc: HumanoidDescription?,
    list: { { id: number, name: string } },
    outfitFirst: boolean
): { WheelEmote }
    local out: { WheelEmote } = {}
    local seen: { [number]: boolean } = {}
    local function add(id: number?, name: string?, fromOutfit: boolean)
        if id and name and not seen[id] then
            seen[id] = true
            table.insert(out, { id = id, name = name, fromOutfit = fromOutfit })
        end
    end
    if outfitFirst then
        local d = desc
        if not d then
            local hum = Players.LocalPlayer.Character
                and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            local ok, applied = pcall(function(): any
                return (hum :: Humanoid):GetAppliedDescription()
            end)
            d = if ok then applied else nil
        end
        if d then
            local okE, emotes = pcall(function(): any
                return (d :: HumanoidDescription):GetEmotes()
            end)
            local okQ, equipped = pcall(function(): any
                return (d :: HumanoidDescription):GetEquippedEmotes()
            end)
            if okE and okQ and type(equipped) == "table" then
                local slots: { [number]: { id: number, name: string } } = {}
                for _, it in equipped do
                    local ids = emotes[it.Name]
                    if ids and ids[1] and it.Slot >= 1 and it.Slot <= SLOTS then
                        slots[it.Slot] = { id = ids[1], name = it.Name }
                    end
                end
                for i = 1, SLOTS do
                    local s = slots[i]
                    if s then
                        add(s.id, s.name, true)
                    end
                end
            end
        end
    end
    for _, e in list do
        add(tonumber(e.id), e.name, false)
    end
    return out
end

return Emotes
