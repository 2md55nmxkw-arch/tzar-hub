--!strict
-- Owns everything a feature creates and undoes it in reverse order, so restores run after the
-- connections that would fight them are gone.

type Task = () -> ()

export type Janitor = {
    Add: <T>(self: Janitor, item: T) -> T,
    Defer: (self: Janitor, fn: () -> ()) -> (),
    Connect: (self: Janitor, signal: RBXScriptSignal, fn: (...any) -> ()) -> RBXScriptConnection,
    Set: (self: Janitor, target: Instance, prop: string, value: any) -> (),
    Cleanup: (self: Janitor) -> (),
    Count: (self: Janitor) -> number,
}

type State = {
    _tasks: { Task },
    _onError: (string) -> (),
}

local Janitor = {}
Janitor.__index = Janitor

local function asTask(value: unknown): Task
    local item = value :: any
    local t = typeof(item)
    if t == "RBXScriptConnection" then
        return function()
            item:Disconnect()
        end
    elseif t == "Instance" then
        return function()
            item:Destroy()
        end
    elseif t == "function" then
        return item
    elseif t == "thread" then
        return function()
            if coroutine.status(item) ~= "dead" then
                pcall(task.cancel, item)
            end
        end
    elseif t == "table" then
        local obj: any = value
        if type(obj.Destroy) == "function" then
            return function()
                (value :: any):Destroy()
            end
        elseif type(obj.Disconnect) == "function" then
            return function()
                (value :: any):Disconnect()
            end
        elseif type(obj.Cleanup) == "function" then
            -- A nested Janitor.
            return function()
                (value :: any):Cleanup()
            end
        end
    end
    error("Janitor: cannot own a " .. t)
end

function Janitor.new(onError: ((string) -> ())?): Janitor
    local self: State = {
        _tasks = {},
        _onError = onError or function(msg: string)
            warn("[TZAR] cleanup: " .. msg)
        end,
    }
    return (setmetatable(self, Janitor) :: any) :: Janitor
end

function Janitor.Add<T>(self: State, item: T): T
    table.insert(self._tasks, asTask(item))
    return item
end

function Janitor.Defer(self: State, fn: () -> ())
    table.insert(self._tasks, fn)
end

-- Callbacks are protected: a failing handler logs and keeps the connection alive.
function Janitor.Connect(
    self: State,
    signal: RBXScriptSignal,
    fn: (...any) -> ()
): RBXScriptConnection
    local onError = self._onError
    local conn = signal:Connect(function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            onError(tostring(err))
        end
    end)
    table.insert(self._tasks, function()
        conn:Disconnect()
    end)
    return conn
end

-- Sets a property and restores the value it had before.
function Janitor.Set(self: State, target: Instance, prop: string, value: any)
    local old = (target :: any)[prop];
    (target :: any)[prop] = value
    table.insert(self._tasks, function()
        if target.Parent ~= nil or target == workspace.CurrentCamera then
            (target :: any)[prop] = old
        end
    end)
end

function Janitor.Cleanup(self: State)
    local tasks = self._tasks
    self._tasks = {}
    for i = #tasks, 1, -1 do
        local ok, err = pcall(tasks[i])
        if not ok then
            self._onError(tostring(err))
        end
    end
end

function Janitor.Count(self: State): number
    return #self._tasks
end

return Janitor
