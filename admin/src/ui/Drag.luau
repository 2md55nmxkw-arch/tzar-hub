--!strict
-- Drag a frame by a handle with mouse or touch. A press that moves less than SLOP is a tap, so
-- the same handle can also be a button. Positions stay on screen and are reported on release.

local UserInputService = game:GetService("UserInputService")

local Janitor = require("../core/Janitor")

local SLOP = 6
local MARGIN = 6

export type Drag = {
    -- True between a drag that moved and the next press: lets Activated ignore the drop.
    moved: () -> boolean,
    clamp: () -> (),
}

local Drag = {}

local function viewport(): Vector2
    local cam = workspace.CurrentCamera
    return if cam then cam.ViewportSize else Vector2.new(1280, 720)
end
Drag.viewport = viewport

function Drag.place(target: GuiObject, x: number, y: number)
    local vp = viewport()
    local w, h = target.AbsoluteSize.X, target.AbsoluteSize.Y
    target.Position = UDim2.fromOffset(
        math.clamp(x, MARGIN, math.max(MARGIN, vp.X - w - MARGIN)),
        math.clamp(y, MARGIN, math.max(MARGIN, vp.Y - h - MARGIN))
    )
end

function Drag.attach(
    handle: GuiObject,
    target: GuiObject,
    jan: Janitor.Janitor,
    onEnd: (x: number, y: number) -> ()
): Drag
    local start: Vector3? = nil
    local origin = Vector2.zero
    local moved = false
    jan:Connect(handle.InputBegan, function(io: InputObject)
        local t = io.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            start = io.Position
            -- Target positions are offsets from the top-left of the screen GUI.
            origin = Vector2.new(target.Position.X.Offset, target.Position.Y.Offset)
            moved = false
        end
    end)
    jan:Connect(UserInputService.InputChanged, function(io: InputObject)
        local s = start
        if not s then
            return
        end
        local t = io.UserInputType
        if t ~= Enum.UserInputType.MouseMovement and t ~= Enum.UserInputType.Touch then
            return
        end
        local d = io.Position - s
        if moved or math.abs(d.X) + math.abs(d.Y) > SLOP then
            moved = true
            Drag.place(target, origin.X + d.X, origin.Y + d.Y)
        end
    end)
    jan:Connect(UserInputService.InputEnded, function(io: InputObject)
        local t = io.UserInputType
        if start and (t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch) then
            start = nil
            if moved then
                onEnd(target.Position.X.Offset, target.Position.Y.Offset)
                -- Keep `moved` true until the Activated that follows this release has run.
                task.defer(function()
                    moved = false
                end)
            end
        end
    end)
    return {
        moved = function()
            return moved
        end,
        clamp = function()
            Drag.place(target, target.Position.X.Offset, target.Position.Y.Offset)
        end,
    }
end

return Drag
