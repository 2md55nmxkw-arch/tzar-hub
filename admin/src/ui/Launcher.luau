--!strict
-- Desktop: a small "Commands ;" pill in the top-right corner that opens the command bar.

local Controls = require("./Controls")
local Create = require("./Create")
local Janitor = require("../core/Janitor")
local Theme = require("./Theme")

local C, F, LINE, S = Theme.C, Theme.F, Theme.LINE, Theme.SIZE
local new, corner, pad, list = Create.new, Create.corner, Create.pad, Create.list

local Launcher = {}

function Launcher.new(
    layer: Instance,
    jan: Janitor.Janitor,
    label: string,
    key: string,
    onOpen: () -> ()
): TextButton
    local b = new("TextButton", {
        Name = "Launcher",
        Text = "",
        AutoButtonColor = false,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 12),
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 34),
        BackgroundColor3 = C.surface,
        BackgroundTransparency = 0.06,
        Parent = layer,
    }, { corner(S.radius + 2), Create.stroke(LINE.strong), pad(10, 6), list("x", 8) })
    Controls.logo(b, 14).LayoutOrder = 1
    Create.text(
        { text = label, size = 13, font = F.medium, auto = true },
        { Name = "Label", LayoutOrder = 2, Parent = b }
    )
    Controls.kbd(b, key).LayoutOrder = 3
    jan:Connect(b.Activated, onOpen)
    return b
end

return Launcher
