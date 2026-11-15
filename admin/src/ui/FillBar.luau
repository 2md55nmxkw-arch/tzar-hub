--!strict
-- A value command as one bar: dark track, solid red fill clipped by the 8px corners, a straight
-- edge with a light line where the fill stops, the name on the left and the number on the right.
-- Drag sideways anywhere on it, or click/tap a spot to jump there; a vertical swipe still
-- scrolls the list around it. A notch at the bottom marks the game's default.

local UserInputService = game:GetService("UserInputService")

local Create = require("./Create")
local Janitor = require("../core/Janitor")
local Theme = require("./Theme")

local C, F, S = Theme.C, Theme.F, Theme.SIZE
local new, corner, tween = Create.new, Create.corner, Create.tween

export type Options = {
    height: number,
    min: number,
    max: number,
    step: number,
    default: number?,
    scroll: ScrollingFrame?,
    jan: Janitor.Janitor,
    title: () -> string,
    format: (v: number) -> string,
    value: () -> number,
    active: () -> boolean,
    enabled: () -> boolean,
    commit: (v: number) -> (),
}

export type FillBar = {
    frame: TextButton,
    refresh: () -> (),
    dragging: () -> boolean,
}

local SLOP = 6

-- Set by the user: full accent. Still the game's own value: the same red, held back.
local FILL_ON, LINE_ON = C.accent, Color3.fromHex("ff8a93")
local FILL_OFF, LINE_OFF = Color3.fromHex("3b1a1d"), Color3.fromHex("70343a")

local FillBar = {}

function FillBar.new(parent: Instance, o: Options): FillBar
    local frame = new("TextButton", {
        Name = "FillBar",
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, o.height),
        Parent = parent,
    })
    -- CanvasGroup so the rounded corners clip the fill; the text lives outside it to stay sharp.
    local track = new("CanvasGroup", {
        Name = "Track",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = C.track,
        BorderSizePixel = 0,
        Parent = frame,
    }, { corner(S.radius) })
    local fill = new("Frame", {
        Name = "Bar",
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = FILL_OFF,
        BorderSizePixel = 0,
        Parent = track,
    })
    local edge = new("Frame", {
        Name = "Edge",
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.new(0, 2, 1, 0),
        BackgroundColor3 = LINE_OFF,
        BorderSizePixel = 0,
        Parent = track,
    })
    local notch: Frame? = nil
    if o.default then
        notch = new("Frame", {
            Name = "Default",
            AnchorPoint = Vector2.new(0.5, 1),
            Size = UDim2.fromOffset(2, 5),
            BackgroundColor3 = C.white,
            BackgroundTransparency = 0.65,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = track,
        })
    end
    local label = Create.text({ text = o.title(), size = 13, font = F.medium }, {
        Name = "Label",
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(0.7, -12, 1, 0),
        ZIndex = 2,
        Parent = frame,
    })
    local number = Create.text(
        { text = "", size = 12.5, font = F.mono, x = Enum.TextXAlignment.Right },
        {
            Name = "Value",
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -12, 0, 0),
            Size = UDim2.fromScale(0.3, 1),
            ZIndex = 2,
            Parent = frame,
        }
    )

    local function frac(v: number): number
        if o.max <= o.min then
            return 0
        end
        return math.clamp((v - o.min) / (o.max - o.min), 0, 1)
    end
    if notch and o.default then
        notch.Position = UDim2.fromScale(frac(o.default), 1)
    end

    local hovering = false
    local isDragging = false
    local current = o.value()

    local function paint(v: number, animate: boolean)
        local a = frac(v)
        local on = o.active() or isDragging
        local enabled = o.enabled()
        local fillProps =
            { Size = UDim2.fromScale(a, 1), BackgroundColor3 = if on then FILL_ON else FILL_OFF }
        local edgeProps = {
            Position = UDim2.fromScale(a, 0),
            BackgroundColor3 = if on then LINE_ON else LINE_OFF,
            Size = UDim2.new(0, if isDragging then 3 else 2, 1, 0),
        }
        if animate then
            tween(fill, fillProps)
            tween(edge, edgeProps)
        else
            for k, val in fillProps do
                (fill :: any)[k] = val
            end
            for k, val in edgeProps do
                (edge :: any)[k] = val
            end
        end
        edge.Visible = a > 0.005 and a < 0.995
        track.BackgroundColor3 = if hovering or isDragging then C.trackHover else C.track
        track.GroupTransparency = if enabled then 0 else 0.6
        number.Text = o.format(v)
        number.TextColor3 = if on then C.white else C.text2
        label.TextColor3 = if enabled then C.text1 else C.text3
    end

    local function fromX(x: number): number
        local left = track.AbsolutePosition.X
        local width = math.max(track.AbsoluteSize.X, 1)
        local v = o.min + math.clamp((x - left) / width, 0, 1) * (o.max - o.min)
        v = math.floor(v / o.step + 0.5) * o.step
        return math.clamp(v, o.min, o.max)
    end

    local press: Vector3? = nil
    local scrollWas = true

    o.jan:Connect(frame.InputBegan, function(io: InputObject)
        if not o.enabled() then
            return
        end
        local t = io.UserInputType
        if t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch then
            press = io.Position
            isDragging = false
        elseif t == Enum.UserInputType.MouseMovement and not hovering then
            hovering = true
            paint(current, true)
        end
    end)
    o.jan:Connect(frame.MouseLeave, function()
        hovering = false
        if not isDragging then
            paint(current, true)
        end
    end)
    o.jan:Connect(UserInputService.InputChanged, function(io: InputObject)
        local p = press
        if not p then
            return
        end
        local t = io.UserInputType
        if t ~= Enum.UserInputType.MouseMovement and t ~= Enum.UserInputType.Touch then
            return
        end
        local d = io.Position - p
        if not isDragging then
            if math.abs(d.Y) > SLOP and math.abs(d.Y) > math.abs(d.X) then
                press = nil -- a vertical swipe: let the list scroll
                return
            end
            if math.abs(d.X) <= SLOP then
                return
            end
            isDragging = true
            if o.scroll then
                scrollWas = o.scroll.ScrollingEnabled
                o.scroll.ScrollingEnabled = false
            end
        end
        local v = fromX(io.Position.X)
        if v ~= current then
            current = v
            paint(v, false)
        end
    end)
    o.jan:Connect(UserInputService.InputEnded, function(io: InputObject)
        local p = press
        local t = io.UserInputType
        if not p or (t ~= Enum.UserInputType.MouseButton1 and t ~= Enum.UserInputType.Touch) then
            return
        end
        local v = if isDragging then current else fromX(p.X)
        press = nil
        isDragging = false
        if o.scroll then
            o.scroll.ScrollingEnabled = scrollWas
        end
        current = v
        paint(v, true)
        o.commit(v)
    end)

    paint(current, false)

    return {
        frame = frame,
        refresh = function()
            if not isDragging then
                current = o.value()
                label.Text = o.title()
                paint(current, true)
            end
        end,
        dragging = function()
            return isDragging
        end,
    }
end

return FillBar
