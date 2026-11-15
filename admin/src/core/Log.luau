--!strict
-- Ring buffer of recent log lines. The log window reads it; errors also go to the dev console.

local Signal = require("./Signal")

export type Level = "debug" | "info" | "warn" | "error"
export type Entry = { time: number, level: Level, text: string }

export type Log = {
    Added: Signal.Signal<Entry>,
    Write: (self: Log, level: Level, text: string) -> (),
    Info: (self: Log, text: string) -> (),
    Warn: (self: Log, text: string) -> (),
    Error: (self: Log, text: string) -> (),
    Entries: (self: Log) -> { Entry },
    Destroy: (self: Log) -> (),
}

local CAPACITY = 300

local Log = {}
Log.__index = Log

function Log.new(): Log
    local self = {
        Added = Signal.new(),
        _buf = table.create(CAPACITY) :: { Entry },
        _head = 0,
        _size = 0,
    }
    return (setmetatable(self, Log) :: any) :: Log
end

function Log.Write(self: any, level: Level, text: string)
    local e: Entry = { time = os.time(), level = level, text = text }
    self._head = self._head % CAPACITY + 1
    self._buf[self._head] = e
    self._size = math.min(self._size + 1, CAPACITY)
    if level == "error" then
        warn("[TZAR] " .. text)
    end
    self.Added:Fire(e)
end

function Log.Info(self: any, text: string)
    self:Write("info", text)
end

function Log.Warn(self: any, text: string)
    self:Write("warn", text)
end

function Log.Error(self: any, text: string)
    self:Write("error", text)
end

-- Oldest first.
function Log.Entries(self: any): { Entry }
    local out = {} :: { Entry }
    local start = (self._head - self._size) % CAPACITY
    for i = 1, self._size do
        out[i] = self._buf[(start + i - 1) % CAPACITY + 1]
    end
    return out
end

function Log.Destroy(self: any)
    self.Added:DisconnectAll()
end

return Log
