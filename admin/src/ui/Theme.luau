--!strict
-- Tokens shared with the Avatar Changer window, plus fonts: Inter / JetBrains Mono when the
-- Avatar Changer font files are on disk, BuilderSans / RobotoMono otherwise.

local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")

local Assets = require("./Assets")
local Env = require("../platform/Env")

local Theme = {}

Theme.C = table.freeze({
    base = Color3.fromHex("080808"),
    surface = Color3.fromHex("121212"),
    card = Color3.fromHex("161616"),
    raised = Color3.fromHex("1a1a1a"),
    control = Color3.fromHex("232323"),
    hover = Color3.fromHex("2c2c2c"),
    -- Every row (and the slider track) sits on this.
    track = Color3.fromHex("171717"),
    trackHover = Color3.fromHex("1c1c1c"),
    text1 = Color3.fromHex("ededed"),
    text2 = Color3.fromHex("9a9a98"),
    text3 = Color3.fromHex("5f5f5d"),
    accent = Color3.fromHex("e53945"),
    ok = Color3.fromHex("3ecf8e"),
    info = Color3.fromHex("5b9cf6"),
    white = Color3.new(1, 1, 1),
    black = Color3.new(0, 0, 0),
})

-- White strokes at these transparencies read as hairlines on the dark surface.
Theme.LINE = table.freeze({ default = 0.9, subtle = 0.94, strong = 0.84 })

Theme.SIZE = table.freeze({
    -- Command bar
    bar = 600,
    barTouch = 560,
    barTop = 92,
    results = 312,
    -- Rows, controls and corners
    row = 40,
    rowTouch = 44,
    radius = 8,
    card = 12,
    window = 16,
    -- Floating panels
    panel = 280,
    panelTouch = 492,
})

Theme.touch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local OUT_DIR = "TZAR/admin/fonts/"

local function family(name: string, faces: { { any } }): string?
    local t = { name = name, faces = {} :: { any } }
    for _, f in faces do
        local path = Assets.path(f[3])
        local id = path and Env.customAsset(path)
        if not id then
            return nil
        end
        table.insert(t.faces, { name = f[1], weight = f[2], style = "normal", assetId = id })
    end
    local path = OUT_DIR .. name .. ".json"
    if not Env.writeFile(path, HttpService:JSONEncode(t)) then
        return nil
    end
    return Env.customAsset(path)
end

local function pick(fam: string?, fallback: string, weight: Enum.FontWeight): Font
    return if fam then Font.new(fam, weight) else Font.fromName(fallback, weight)
end

-- Filled in place so modules holding Theme.F see new fonts after a background download.
Theme.F = {} :: {
    regular: Font,
    medium: Font,
    semibold: Font,
    bold: Font,
    mono: Font,
}

function Theme.loadFonts()
    local inter = family("Inter", {
        { "Regular", 400, "Inter-Regular.ttf" },
        { "Medium", 500, "Inter-Medium.ttf" },
        { "SemiBold", 600, "Inter-SemiBold.ttf" },
        { "ExtraBold", 800, "Inter-ExtraBold.ttf" },
    })
    local mono = family("JetBrainsMono", { { "Regular", 400, "JetBrainsMono-Regular.ttf" } })
    local F = Theme.F
    F.regular = pick(inter, "BuilderSans", Enum.FontWeight.Regular)
    F.medium = pick(inter, "BuilderSans", Enum.FontWeight.Medium)
    F.semibold = pick(inter, "BuilderSans", Enum.FontWeight.SemiBold)
    F.bold = pick(inter, "BuilderSans", Enum.FontWeight.ExtraBold)
    F.mono = pick(mono, "RobotoMono", Enum.FontWeight.Regular)
end
Theme.loadFonts()
Theme.SHADOW = table.freeze({
    window = {
        Color = Color3.new(0, 0, 0),
        Transparency = 0.4,
        Offset = UDim2.fromOffset(0, 24),
        BlurRadius = UDim.new(0, 64),
        Spread = UDim2.fromOffset(-8, -8),
    },
    pop = {
        Color = Color3.new(0, 0, 0),
        Transparency = 0.45,
        Offset = UDim2.fromOffset(0, 8),
        BlurRadius = UDim.new(0, 24),
    },
})

return Theme
