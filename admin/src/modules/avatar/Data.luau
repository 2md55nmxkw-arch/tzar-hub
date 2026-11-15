--!strict
-- Saved outfits and the emote list in TZAR/admin/avatar.json. The first run imports what the old
-- Avatar Changer saved (AvatarChanger/outfits.json and the emote list in its config.json); those
-- files are only read, never changed.

local HttpService = game:GetService("HttpService")

local Env = require("../../platform/Env")

export type Outfit = { id: string, name: string, data: any }
export type Emote = { id: number, name: string }
export type Data = {
    version: number,
    outfits: { Outfit },
    emotes: { Emote },
    -- The worn look's own equipped emotes come first on the wheel.
    outfitEmotes: boolean,
    imported: boolean,
}

local PATH = "TZAR/admin/avatar.json"
local OLD_OUTFITS = "AvatarChanger/outfits.json"
local OLD_CONFIG = "AvatarChanger/config.json"
local VERSION = 1

local DESC_NUMBERS = {
    "Head",
    "Torso",
    "LeftArm",
    "RightArm",
    "LeftLeg",
    "RightLeg",
    "Face",
    "Shirt",
    "Pants",
    "GraphicTShirt",
    "BodyTypeScale",
    "DepthScale",
    "HeadScale",
    "HeightScale",
    "ProportionScale",
    "WidthScale",
    "ClimbAnimation",
    "FallAnimation",
    "IdleAnimation",
    "JumpAnimation",
    "MoodAnimation",
    "RunAnimation",
    "SwimAnimation",
    "WalkAnimation",
}
local DESC_COLORS =
    { "HeadColor", "TorsoColor", "LeftArmColor", "RightArmColor", "LeftLegColor", "RightLegColor" }

local Data = {}

local function readJson(path: string): any
    local body = Env.readFile(path)
    return if body then Env.json(body) else nil
end

-- Old emote entries: { id, name } in emoteList, or the even older { "1".."8" = { id, name } }.
local function oldEmotes(config: any): { Emote }
    local out: { Emote } = {}
    if type(config) ~= "table" then
        return out
    end
    local function add(e: any)
        if type(e) == "table" and tonumber(e.id) then
            table.insert(out, { id = tonumber(e.id) :: number, name = tostring(e.name or e.id) })
        end
    end
    if type(config.emoteList) == "table" then
        for _, e in config.emoteList do
            add(e)
        end
    elseif type(config.emoteSlots) == "table" then
        for i = 1, 8 do
            add(config.emoteSlots[tostring(i)])
        end
    end
    return out
end

function Data.load(): (Data, number)
    local raw = readJson(PATH)
    local d: Data = {
        version = VERSION,
        outfits = {},
        emotes = {},
        outfitEmotes = true,
        imported = false,
    }
    if type(raw) == "table" then
        d.outfits = if type(raw.outfits) == "table" then raw.outfits else {}
        d.emotes = if type(raw.emotes) == "table" then raw.emotes else {}
        d.outfitEmotes = raw.outfitEmotes ~= false
        d.imported = raw.imported == true
    end
    local imported = 0
    if not d.imported then
        local old = readJson(OLD_OUTFITS)
        if type(old) == "table" and type(old.list) == "table" then
            for _, o in old.list do
                if type(o) == "table" and type(o.data) == "table" then
                    table.insert(d.outfits, {
                        id = tostring(o.id or HttpService:GenerateGUID(false)),
                        name = tostring(o.name or "Outfit"),
                        data = o.data,
                    })
                    imported += 1
                end
            end
        end
        local config = readJson(OLD_CONFIG)
        for _, e in oldEmotes(config) do
            table.insert(d.emotes, e)
            imported += 1
        end
        if type(config) == "table" and config.useOutfitEmotes == false then
            d.outfitEmotes = false
        end
        d.imported = true
        Data.save(d)
    end
    return d, imported
end

function Data.save(d: Data)
    local ok, body = pcall(HttpService.JSONEncode, HttpService, d)
    if ok then
        Env.writeFile(PATH, body)
    end
end

function Data.find(d: Data, name: string): Outfit?
    local lower = string.lower(name)
    for _, o in d.outfits do
        if string.lower(o.name) == lower or o.id == name then
            return o
        end
    end
    return nil
end

-- "Name", or "Name (2)" when that is taken.
function Data.unique(d: Data, base: string): string
    if not Data.find(d, base) then
        return base
    end
    local n = 2
    while Data.find(d, string.format("%s (%d)", base, n)) do
        n += 1
    end
    return string.format("%s (%d)", base, n)
end

local function numStr(n: number): string
    if n == math.floor(n) then
        return string.format("%d", n)
    end
    return string.format("%.17g", n)
end

local function v3(v: Vector3?): { number }?
    return if v then { v.X, v.Y, v.Z } else nil
end

-- Same shape the Avatar Changer wrote, so old outfits and exported scripts keep working.
function Data.serialize(desc: HumanoidDescription): any
    local dd = desc :: any
    local t = { numbers = {}, colors = {}, accessories = {} } :: any
    for _, f in DESC_NUMBERS do
        t.numbers[f] = numStr(dd[f])
    end
    for _, f in DESC_COLORS do
        t.colors[f] = (dd[f] :: Color3):ToHex()
    end
    for _, a in desc:GetAccessories(true) do
        local acc = a :: any
        table.insert(t.accessories, {
            AssetId = numStr(acc.AssetId),
            AccessoryType = acc.AccessoryType.Name,
            IsLayered = acc.IsLayered,
            Order = acc.Order,
            Puffiness = acc.Puffiness,
            Position = v3(acc.Position),
            Rotation = v3(acc.Rotation),
            Scale = v3(acc.Scale),
        })
    end
    local okE, emotes = pcall(function(): any
        return desc:GetEmotes()
    end)
    local okQ, equipped = pcall(function(): any
        return desc:GetEquippedEmotes()
    end)
    if okE and okQ and type(equipped) == "table" and #equipped > 0 then
        t.emotes, t.equippedEmotes = {}, equipped
        for name, ids in emotes do
            t.emotes[name] = {}
            for _, id in ids do
                table.insert(t.emotes[name], numStr(id))
            end
        end
    end
    return t
end

local function vec(t: any): Vector3?
    if type(t) == "table" and #t == 3 then
        return Vector3.new(tonumber(t[1]) or 0, tonumber(t[2]) or 0, tonumber(t[3]) or 0)
    end
    return nil
end

function Data.deserialize(t: any): HumanoidDescription
    local desc = Instance.new("HumanoidDescription")
    local dd = desc :: any
    for f, v in (if type(t.numbers) == "table" then t.numbers else {}) :: { [string]: any } do
        pcall(function()
            dd[f] = tonumber(v) or 0
        end)
    end
    for f, hex in (if type(t.colors) == "table" then t.colors else {}) :: { [string]: any } do
        pcall(function()
            dd[f] = Color3.fromHex(hex)
        end)
    end
    local list: { any } = {}
    for _, a in (if type(t.accessories) == "table" then t.accessories else {}) :: { any } do
        local okT, accType = pcall(function(): any
            return (Enum.AccessoryType :: any)[a.AccessoryType]
        end)
        table.insert(list, {
            AssetId = tonumber(a.AssetId) or 0,
            AccessoryType = if okT and accType then accType else Enum.AccessoryType.Unknown,
            IsLayered = a.IsLayered == true,
            Order = a.Order,
            Puffiness = a.Puffiness,
            Position = vec(a.Position),
            Rotation = vec(a.Rotation),
            Scale = vec(a.Scale),
        })
    end
    if not pcall(desc.SetAccessories, desc, list, true) then
        for _, item in list do
            item.Position, item.Rotation, item.Scale = nil, nil, nil
        end
        pcall(desc.SetAccessories, desc, list, true)
    end
    if type(t.emotes) == "table" and type(t.equippedEmotes) == "table" then
        local emotes: { [string]: { any } } = {}
        for name, ids in t.emotes :: { [string]: any } do
            emotes[name] = {}
            for _, id in ids do
                table.insert(emotes[name], tonumber(id))
            end
        end
        pcall(desc.SetEmotes, desc, emotes)
        pcall(desc.SetEquippedEmotes, desc, t.equippedEmotes)
    end
    return desc
end

return Data
