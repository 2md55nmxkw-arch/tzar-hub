--!strict
-- Floating panel shell: header (back, title, close), hairline, scrolling body. Dragged by the
-- header; the position is remembered per panel. On touch screens panels sit top-centre, between
-- the thumbstick and the jump button.

local Controls = require("./Controls")
local Create = require("./Create")
local Drag = require("./Drag")
local Janitor = require("../core/Janitor")
local Store = require("../core/Store")
local Theme = require("./Theme")

local C, F, LINE, S = Theme.C, Theme.F, Theme.LINE, Theme.SIZE
local new, corner, pad, list = Create.new, Create.corner, Create.pad, Create.list

export type Options = {
    id: string,
    title: string,
    width: number?,
    maxHeight: number?,
    store: Store.Store,
    -- Where it opens the first time (desktop), as offsets from the top-left.
    origin: (vp: Vector2, w: number) -> (number, number),
    onClose: (() -> ())?,
}

export type Panel = {
    id: string,
    frame: Frame,
    body: ScrollingFrame,
    -- Owns what the content builder connects; cleaned on every rebuild and on close.
    content: Janitor.Janitor,
    setTitle: (text: string) -> (),
    setBack: (fn: (() -> ())?) -> (),
    open: () -> (),
    close: () -> (),
    isOpen: () -> boolean,
    clear: () -> (),
}

local Panel = {}

function Panel.new(layer: Instance, jan: Janitor.Janitor, o: Options): Panel
    local width = if Theme.touch
        then math.min(S.panelTouch, o.width or S.panel + 60)
        else o.width or S.panel
    local frame = new("Frame", {
        Name = "Panel/" .. o.id,
        Size = UDim2.fromOffset(width, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.surface,
        Visible = false,
        Active = true,
        Parent = layer,
    }, { corner(S.card), Create.stroke(LINE.strong), list("y", 0) })
    Create.shadow(frame, Theme.SHADOW.pop)

    local header = new("Frame", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, if Theme.touch then 44 else 38),
        LayoutOrder = 1,
        Active = true,
        Parent = frame,
    }, { pad(8, 8) })
    local back = Controls.iconButton(header, "arrow-left")
    back.AnchorPoint = Vector2.new(0, 0.5)
    back.Position = UDim2.fromScale(0, 0.5)
    back.Visible = false
    local logo = Controls.logo(header, 14)
    logo.AnchorPoint = Vector2.new(0, 0.5)
    logo.Position = UDim2.new(0, 6, 0.5, 0)
    local title = Create.text(
        { text = o.title, size = 13, font = F.medium, x = Enum.TextXAlignment.Center },
        {
            Name = "Title",
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.fromScale(0.5, 0),
            Size = UDim2.new(1, -80, 1, 0),
            Parent = header,
        }
    )
    local close = Controls.iconButton(header, "x")
    close.AnchorPoint = Vector2.new(1, 0.5)
    close.Position = UDim2.fromScale(1, 0.5)
    Controls.hairline(frame, 2)

    local body = new("ScrollingFrame", {
        Name = "Body",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 0),
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.text3,
        LayoutOrder = 3,
        Parent = frame,
    }, { pad(8, 8, 8, 10), list("y", 4) })

    local content = Janitor.new()
    jan:Add(content)

    -- As tall as the rows, but never past the bottom of the screen.
    local fitHeight = Create.fitScroll(body, function(): number
        local vp = Drag.viewport()
        local headerH = header.AbsoluteSize.Y + 1
        local top = math.max(frame.Position.Y.Offset, 0)
        return math.max(120, math.min(o.maxHeight or 420, vp.Y - top - headerH - 16))
    end)

    local function placeInitial()
        local vp = Drag.viewport()
        if Theme.touch then
            Drag.place(frame, (vp.X - width) / 2, 8)
            return
        end
        local saved = o.store.data.panels[o.id]
        if saved then
            Drag.place(frame, saved.x, saved.y)
        else
            local x, y = o.origin(vp, width)
            Drag.place(frame, x, y)
        end
    end

    Drag.attach(header, frame, jan, function(x: number, y: number)
        if not Theme.touch then
            o.store.data.panels[o.id] = { x = x, y = y }
            o.store:Save()
        end
    end)

    local isOpen = false
    local self: Panel
    local function closePanel()
        if not isOpen then
            return
        end
        isOpen = false
        frame.Visible = false
        if o.onClose then
            o.onClose()
        end
    end
    jan:Connect(close.Activated, closePanel)

    local backFn: (() -> ())? = nil
    jan:Connect(back.Activated, function()
        if backFn then
            backFn()
        end
    end)

    self = {
        id = o.id,
        frame = frame,
        body = body,
        content = content,
        setTitle = function(text: string)
            title.Text = text
        end,
        setBack = function(fn: (() -> ())?)
            backFn = fn
            back.Visible = fn ~= nil
            logo.Visible = fn == nil
        end,
        open = function()
            fitHeight()
            if not isOpen then
                isOpen = true
                frame.Visible = true
                task.defer(function()
                    placeInitial()
                    fitHeight()
                end)
            end
        end,
        close = closePanel,
        isOpen = function()
            return isOpen
        end,
        clear = function()
            content:Cleanup()
            for _, c in body:GetChildren() do
                if c:IsA("GuiObject") then
                    c:Destroy()
                end
            end
        end,
    }
    return self
end

-- A full-width row card inside a panel body.
function Panel.row(parent: Instance, order: number, height: number?): TextButton
    return new("TextButton", {
        Name = "Row",
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = C.track,
        Size = UDim2.new(1, 0, 0, height or (if Theme.touch then S.rowTouch else 34)),
        LayoutOrder = order,
        Parent = parent,
    }, { corner(S.radius), pad(10, 8), list("x", 8) })
end

-- Pushes the following siblings in a horizontal list to the right edge.
function Panel.spacer(parent: Instance, order: number): Frame
    local s = new("Frame", {
        Name = "Spacer",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0, 1),
        LayoutOrder = order,
        Parent = parent,
    })
    -- UIFlexItem is recent; without it the spacer simply takes no room.
    pcall(function()
        new("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = s })
    end)
    return s
end

return Panel
