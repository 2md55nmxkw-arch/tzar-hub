--!strict
-- TZAR icons, fonts and the Teto mascot. Looked up in the shared cache (TZAR/assets), then in the
-- Avatar Changer folders; anything missing is downloaded once from the site in the background.

local Env = require("../platform/Env")

local Assets = {}

local BASE = "https://hub.2md.space/tzar-assets/"
local CACHE = "TZAR/assets/"
local LEGACY_IMAGES = "AvatarChanger/assets/"
local LEGACY_FONTS = "AvatarChanger/fonts/"

Assets.IMAGES = table.freeze({
    "logo",
    "settings",
    "minus",
    "x",
    "search",
    "arrow-right",
    "refresh",
    "teto",
    "zap",
    "ghost",
    "gauge",
    "arrow-up",
    "clock",
    "user",
    "eye",
    "sun",
    "box",
    "list",
    "key",
    "star",
    "check",
    "chevron-down",
    "keyboard",
    "map-pin",
    "log-out",
    "sparkles",
    "plus",
    "arrow-left",
    "message",
    "command",
    "globe",
    "menu",
    "info",
})
Assets.FONTS = table.freeze({
    "Inter-Regular.ttf",
    "Inter-Medium.ttf",
    "Inter-SemiBold.ttf",
    "Inter-ExtraBold.ttf",
    "JetBrainsMono-Regular.ttf",
})

local ids: { [string]: string } = {}

-- Path of a local copy of `file`, or nil.
function Assets.path(file: string): string?
    if Env.exists(CACHE .. file) then
        return CACHE .. file
    end
    local legacy = (if string.sub(file, -4) == ".ttf" then LEGACY_FONTS else LEGACY_IMAGES) .. file
    if Env.exists(legacy) then
        return legacy
    end
    return nil
end

-- rbxasset id for an image by name (without .png), or nil when we have no copy yet.
function Assets.image(name: string): string?
    local cached = ids[name]
    if cached then
        return cached
    end
    local path = Assets.path(name .. ".png")
    local id = path and Env.customAsset(path)
    if id then
        ids[name] = id
    end
    return id
end

function Assets.missing(): { string }
    local out = {}
    for _, name in Assets.IMAGES do
        if not Assets.path(name .. ".png") then
            table.insert(out, name .. ".png")
        end
    end
    for _, file in Assets.FONTS do
        if not Assets.path(file) then
            table.insert(out, file)
        end
    end
    return out
end

-- Downloads files in the background; `done` gets how many arrived.
function Assets.download(files: { string }, done: (number) -> ())
    if #files == 0 or not Env.has("writefile") then
        return
    end
    task.spawn(function()
        local got = 0
        for _, file in files do
            local res = Env.http(BASE .. file)
            if res and res.ok and #res.body > 0 and string.sub(res.body, 1, 1) ~= "<" then
                if Env.writeFile(CACHE .. file, res.body) then
                    got += 1
                end
            end
        end
        done(got)
    end)
end

return Assets
