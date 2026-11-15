--!strict
-- Keyboard: the show/hide key, the command bar key and user binds (key -> command line).
-- A hold bind runs on press and is undone on release. Keys pressed while typing in any TextBox,
-- or eaten by the game's own UI, are ignored.

local UserInputService = game:GetService("UserInputService")

local Janitor = require("./Janitor")
local Store = require("./Store")

export type Handlers = {
    toggleAll: () -> (),
    openBar: () -> (),
    run: (line: string) -> (),
}

export type Binds = {
    -- While set, the next key press goes here instead (used by "press a key" fields).
    Capture: (self: Binds, fn: ((Enum.KeyCode) -> ())?) -> (),
    Destroy: (self: Binds) -> (),
}

local Binds = {}
Binds.__index = Binds

function Binds.new(store: Store.Store, handlers: Handlers): Binds
    local jan = Janitor.new()
    local self = { _jan = jan, _capture = nil :: ((Enum.KeyCode) -> ())? }
    jan:Connect(UserInputService.InputBegan, function(input: InputObject, processed: boolean)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        local key = input.KeyCode
        local capture = self._capture
        if capture then
            self._capture = nil
            capture(key)
            return
        end
        if UserInputService:GetFocusedTextBox() then
            return
        end
        local data = store.data
        if key.Name == data.toggleKey then
            handlers.toggleAll()
            return
        end
        if processed then
            return
        end
        if key.Name == data.paletteKey then
            -- Defer so the ";" itself is not typed into the box we focus.
            task.defer(handlers.openBar)
            return
        end
        local line = data.binds[key.Name]
        if line then
            handlers.run(line)
        end
    end)
    jan:Connect(UserInputService.InputEnded, function(input: InputObject)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end
        local name = input.KeyCode.Name
        local line = store.data.binds[name]
        if line and store.data.holdBinds[name] then
            local word = string.match(line, "^%S+")
            if word then
                handlers.run("un" .. word)
            end
        end
    end)
    return (setmetatable(self, Binds) :: any) :: Binds
end

function Binds.Capture(self: any, fn: ((Enum.KeyCode) -> ())?)
    self._capture = fn
end

function Binds.Destroy(self: any)
    self._capture = nil
    self._jan:Cleanup()
end

return Binds
