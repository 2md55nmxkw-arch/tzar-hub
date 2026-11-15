--!strict
-- Typed signal. Listeners live in an array; Fire walks it without allocating.

export type Connection = {
    Connected: boolean,
    Disconnect: (self: Connection) -> (),
}

export type Signal<T...> = {
    Connect: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
    Fire: (self: Signal<T...>, T...) -> (),
    DisconnectAll: (self: Signal<T...>) -> (),
}

type Listener = { fn: (...any) -> (), conn: Connection }

local Signal = {}
Signal.__index = Signal

local Conn = {}
Conn.__index = Conn

function Conn.Disconnect(self: any)
    if not self.Connected then
        return
    end
    self.Connected = false
    local list = self._signal._listeners
    for i = #list, 1, -1 do
        if list[i].conn == self then
            table.remove(list, i)
            break
        end
    end
end

function Signal.new<T...>(onError: ((string) -> ())?): Signal<T...>
    local self = { _listeners = {} :: { Listener }, _onError = onError }
    return (setmetatable(self, Signal) :: any) :: Signal<T...>
end

function Signal.Connect(self: any, fn: (...any) -> ()): Connection
    local conn = (setmetatable({ Connected = true, _signal = self }, Conn) :: any) :: Connection
    table.insert(self._listeners, { fn = fn, conn = conn })
    return conn
end

function Signal.Fire(self: any, ...: any)
    local list: { Listener } = self._listeners
    local onError: ((string) -> ())? = self._onError
    -- Backwards so a listener may disconnect itself mid-fire.
    for i = #list, 1, -1 do
        local l = list[i]
        if l then
            local ok, err = pcall(l.fn, ...)
            if not ok and onError then
                onError(tostring(err))
            end
        end
    end
end

function Signal.DisconnectAll(self: any)
    for _, l in self._listeners do
        l.conn.Connected = false
    end
    table.clear(self._listeners)
end

return Signal
