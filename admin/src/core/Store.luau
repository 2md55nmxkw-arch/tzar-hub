--!strict
-- Settings in TZAR/admin/settings.json. Every file carries a schema number; older files pass
-- through MIGRATIONS in order, and a file from a newer build is kept aside as .bak.

local HttpService = game:GetService("HttpService")

local Env = require("../platform/Env")
local Signal = require("./Signal")

export type Point = { x: number, y: number }

export type Settings = {
    schema: number,
    lang: string?,
    -- Hides and shows everything TZAR draws (dock, panels, launcher).
    toggleKey: string,
    -- Opens the command bar.
    paletteKey: string,
    disabled: { string },
    binds: { [string]: string },
    -- Keys whose bind runs on press and is undone on release (toggles only).
    holdBinds: { [string]: boolean },
    history: { string },
    chatCommands: boolean,
    sound: boolean,
    -- Commands on the dock, plus "preset:<module>:<id>" entries.
    pins: { string },
    dock: Point?,
    panels: { [string]: Point },
    -- Per game module: presets the user saved.
    modules: { [string]: { presets: { { id: string, name: string, values: { [string]: any } } } } },
    -- TZAR's emote wheel on "." in place of the Roblox one.
    emoteWheel: boolean,
}

export type Store = {
    data: Settings,
    Changed: Signal.Signal<string>,
    Save: (self: Store, key: string?) -> (),
    Flush: (self: Store) -> (),
    Destroy: (self: Store) -> (),
}

local PATH = "TZAR/admin/settings.json"
local SCHEMA = 4
local PINS_DEFAULT = table.freeze({ "fly", "speed", "noclip" })
local SAVE_DELAY = 1
local HISTORY_MAX = 50

local function defaults(): Settings
    return {
        schema = SCHEMA,
        lang = nil,
        toggleKey = "RightShift",
        paletteKey = "Semicolon",
        disabled = {},
        binds = {},
        holdBinds = {},
        history = {},
        chatCommands = false,
        sound = true,
        pins = table.clone(PINS_DEFAULT) :: { string },
        dock = nil,
        panels = {},
        modules = {},
        emoteWheel = false,
    }
end

-- MIGRATIONS[n] turns a schema-n table into schema n+1.
local MIGRATIONS: { [number]: (any) -> any } = {
    -- 1 -> 2: the window and its floating button gave way to the command bar, dock and panels.
    [1] = function(raw: any): any
        raw.window = nil
        raw.fab = nil
        raw.tab = nil
        raw.pins = raw.pins or table.clone(PINS_DEFAULT)
        raw.panels = raw.panels or {}
        raw.holdBinds = raw.holdBinds or {}
        return raw
    end,
    -- 2 -> 3: game modules keep their saved presets.
    [2] = function(raw: any): any
        raw.modules = raw.modules or {}
        return raw
    end,
    -- 3 -> 4: the avatar module's own emote wheel, off until switched on.
    [3] = function(raw: any): any
        raw.emoteWheel = raw.emoteWheel == true
        return raw
    end,
}

local function migrate(raw: any): Settings?
    if type(raw) ~= "table" then
        return nil
    end
    local v = tonumber(raw.schema) or 0
    if v > SCHEMA then
        return nil
    end
    while v < SCHEMA do
        local step = MIGRATIONS[v]
        if step then
            raw = step(raw)
        end
        v += 1
        raw.schema = v
    end
    -- Fill anything missing and drop wrong types so a hand-edited file cannot break the hub.
    local out = defaults()
    for k, def in out :: any do
        local got = raw[k]
        if got ~= nil and (def == nil or type(got) == type(def)) then
            (out :: any)[k] = got
        end
    end
    for _, k in { "lang", "dock" } do
        if raw[k] ~= nil then
            (out :: any)[k] = raw[k]
        end
    end
    if #out.history > HISTORY_MAX then
        out.history = table.move(out.history, #out.history - HISTORY_MAX + 1, #out.history, 1, {})
    end
    return out
end

local Store = {}
Store.__index = Store

function Store.new(): Store
    local data = defaults()
    local body = Env.readFile(PATH)
    if body then
        local raw = Env.json(body)
        local ok = migrate(raw)
        if ok then
            data = ok
        else
            Env.writeFile(PATH .. ".bak", body)
        end
    end
    local self = {
        data = data,
        Changed = Signal.new(),
        _pending = nil :: thread?,
    }
    return (setmetatable(self, Store) :: any) :: Store
end

function Store.Flush(self: any)
    if self._pending then
        pcall(task.cancel, self._pending)
        self._pending = nil
    end
    local ok, body = pcall(HttpService.JSONEncode, HttpService, self.data)
    if ok then
        Env.writeFile(PATH, body)
    end
end

-- Writes at most once per SAVE_DELAY seconds.
function Store.Save(self: any, key: string?)
    if key then
        self.Changed:Fire(key)
    end
    if self._pending then
        return
    end
    self._pending = task.delay(SAVE_DELAY, function()
        self._pending = nil
        self:Flush()
    end)
end

function Store.Destroy(self: any)
    if self._pending then
        self:Flush()
    end
    self.Changed:DisconnectAll()
end

Store.PATH = PATH
Store.HISTORY_MAX = HISTORY_MAX
Store._migrate = migrate

return Store
