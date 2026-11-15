--!strict
-- One connection per frame phase for the whole hub: Stepped (before physics), Heartbeat (after)
-- and RenderStepped (after the camera). Tickers sit in plain arrays and the per-frame loop
-- allocates nothing; a ticker that throws is dropped and reported.

local RunService = game:GetService("RunService")

export type Ticker = (dt: number) -> ()
export type Phase = "stepped" | "heartbeat" | "render"

export type Scheduler = {
    Add: (self: Scheduler, phase: Phase, fn: Ticker, onError: ((string) -> ())?) -> () -> (),
    Count: (self: Scheduler) -> number,
    Destroy: (self: Scheduler) -> (),
}

type Entry = { fn: Ticker, onError: ((string) -> ())? }

local Scheduler = {}
Scheduler.__index = Scheduler

local BIND_NAME = "TZAR_Admin_Render"

local function step(list: { Entry }, dt: number)
    for i = #list, 1, -1 do
        local e = list[i]
        local ok, err = pcall(e.fn, dt)
        if not ok then
            table.remove(list, i)
            if e.onError then
                task.spawn(e.onError, tostring(err))
            end
        end
    end
end

function Scheduler.new(): Scheduler
    local self = {
        _stepped = {} :: { Entry },
        _heartbeat = {} :: { Entry },
        _render = {} :: { Entry },
        _conns = {} :: { RBXScriptConnection },
        _bound = false,
    }
    table.insert(
        self._conns,
        RunService.PreSimulation:Connect(function(dt: number)
            if #self._stepped > 0 then
                step(self._stepped, dt)
            end
        end)
    )
    table.insert(
        self._conns,
        RunService.Heartbeat:Connect(function(dt: number)
            if #self._heartbeat > 0 then
                step(self._heartbeat, dt)
            end
        end)
    )
    -- Camera priority + 1 so camera tickers win over the default camera script.
    RunService:BindToRenderStep(
        BIND_NAME,
        Enum.RenderPriority.Camera.Value + 1,
        function(dt: number)
            if #self._render > 0 then
                step(self._render, dt)
            end
        end
    )
    self._bound = true
    return (setmetatable(self, Scheduler) :: any) :: Scheduler
end

function Scheduler.Add(self: any, phase: Phase, fn: Ticker, onError: ((string) -> ())?): () -> ()
    local list: { Entry } = if phase == "render"
        then self._render
        elseif phase == "stepped" then self._stepped
        else self._heartbeat
    local entry: Entry = { fn = fn, onError = onError }
    table.insert(list, entry)
    return function()
        local i = table.find(list, entry)
        if i then
            table.remove(list, i)
        end
    end
end

function Scheduler.Count(self: any): number
    return #self._stepped + #self._heartbeat + #self._render
end

function Scheduler.Destroy(self: any)
    table.clear(self._stepped)
    table.clear(self._heartbeat)
    table.clear(self._render)
    for _, c in self._conns do
        c:Disconnect()
    end
    table.clear(self._conns)
    if self._bound then
        RunService:UnbindFromRenderStep(BIND_NAME)
        self._bound = false
    end
end

return Scheduler
