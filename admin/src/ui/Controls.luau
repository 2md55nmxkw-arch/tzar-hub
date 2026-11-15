--!strict
-- Small building blocks: switch, check, key cap, buttons, icons, avatars.

local Assets = require("./Assets")
local Create = require("./Create")
local Theme = require("./Theme")

local C, F, LINE, S = Theme.C, Theme.F, Theme.LINE, Theme.SIZE
local new, corner, tween = Create.new, Create.corner, Create.tween

local Controls = {}

export type Switch = { frame: Frame, set: (on: boolean) -> () }

function Controls.switch(parent: Instance): Switch
    local track = new("Frame", {
        Name = "Switch",
        Size = UDim2.fromOffset(32, 18),
        BackgroundColor3 = C.control,
        Parent = parent,
    }, { corner(9) })
    local knob = new("Frame", {
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.fromOffset(2, 2),
        BackgroundColor3 = C.text2,
        Parent = track,
    }, { corner(7) })
    local function set(on: boolean)
        tween(track, { BackgroundColor3 = if on then C.accent else C.control })
        tween(knob, {
            Position = UDim2.fromOffset(if on then 16 else 2, 2),
            BackgroundColor3 = if on then C.white else C.text2,
        })
    end
    return { frame = track, set = set }
end

-- An icon from the TZAR set, tinted; a dot when the file is not on disk yet.
function Controls.glyph(name: string, parent: Instance, size: number?, color: Color3?): GuiObject
    local px = size or 16
    local id = Assets.image(name)
    if id then
        return new("ImageLabel", {
            Name = "Icon",
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(px, px),
            Image = id,
            ImageColor3 = color or C.text2,
            ScaleType = Enum.ScaleType.Fit,
            Parent = parent,
        })
    end
    return Create.text({
        text = "•",
        size = px,
        color = color or C.text2,
        x = Enum.TextXAlignment.Center,
    }, { Name = "Icon", Size = UDim2.fromOffset(px, px), Parent = parent })
end

function Controls.tint(icon: GuiObject, color: Color3)
    if icon:IsA("ImageLabel") then
        icon.ImageColor3 = color
    elseif icon:IsA("TextLabel") then
        icon.TextColor3 = color
    end
end

-- The TZAR mark.
function Controls.logo(parent: Instance, size: number): GuiObject
    local id = Assets.image("logo")
    if id then
        return new("ImageLabel", {
            Name = "Logo",
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(size, size),
            Image = id,
            ScaleType = Enum.ScaleType.Fit,
            Parent = parent,
        })
    end
    local box = new("Frame", {
        Name = "Logo",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(size, size),
        Parent = parent,
    })
    local u = size / 24
    new("Frame", {
        Position = UDim2.fromOffset(3 * u, 4 * u),
        Size = UDim2.fromOffset(18 * u, 3.2 * u),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        Parent = box,
    })
    new("Frame", {
        Position = UDim2.fromOffset(10.4 * u, 7 * u),
        Size = UDim2.fromOffset(3.2 * u, 13 * u),
        BackgroundColor3 = C.accent,
        BorderSizePixel = 0,
        Parent = box,
    })
    return box
end

-- A key cap: "Tab", ";", "RightShift".
function Controls.kbd(parent: Instance, text: string): TextLabel
    local k = Create.text({
        text = text,
        size = 11,
        font = F.mono,
        color = C.text1,
        auto = true,
        x = Enum.TextXAlignment.Center,
    }, {
        Name = "Kbd",
        Size = UDim2.fromOffset(0, 22),
        BackgroundTransparency = 0,
        BackgroundColor3 = C.control,
        Parent = parent,
    })
    corner(5).Parent = k
    Create.stroke(LINE.subtle).Parent = k
    Create.pad(7, 7).Parent = k
    return k
end

export type ButtonKind = "plain" | "accent" | "ghost" | "danger"

local BUTTON_BG: { [string]: { Color3 | number } } = {
    plain = { C.control, 0 },
    accent = { C.accent, 0 },
    ghost = { C.surface, 1 },
    danger = { C.accent, 0.86 },
}

-- Text button with an optional leading icon. Height follows the touch size.
function Controls.button(
    parent: Instance,
    text: string,
    kind: ButtonKind?,
    icon: string?
): TextButton
    local k = kind or "plain"
    local bg = BUTTON_BG[k]
    local fg = if k == "accent" then C.white elseif k == "danger" then C.accent else C.text1
    local b = new("TextButton", {
        Name = "Button",
        Text = "",
        AutoButtonColor = false,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, if Theme.touch then 38 else 32),
        BackgroundColor3 = bg[1] :: Color3,
        BackgroundTransparency = bg[2] :: number,
        Parent = parent,
    }, { corner(S.radius), Create.pad(12, 12), Create.list("x", 7) })
    if k == "ghost" then
        Create.stroke(LINE.strong).Parent = b
    end
    if icon then
        Controls.glyph(icon, b, 14, fg).LayoutOrder = 1
    end
    Create.text({ text = text, size = 13, font = F.medium, color = fg, auto = true }, {
        Name = "Label",
        LayoutOrder = 2,
        Parent = b,
    })
    local base = b.BackgroundColor3
    b.MouseEnter:Connect(function()
        if k == "plain" then
            tween(b, { BackgroundColor3 = C.hover })
        end
    end)
    b.MouseLeave:Connect(function()
        if k == "plain" then
            tween(b, { BackgroundColor3 = base })
        end
    end)
    return b
end

-- Square icon-only button (close, back, settings).
function Controls.iconButton(
    parent: Instance,
    icon: string,
    size: number?,
    filled: boolean?
): TextButton
    local px = size or (if Theme.touch then 34 else 28)
    local b = new("TextButton", {
        Name = "IconButton",
        Text = "",
        AutoButtonColor = false,
        Size = UDim2.fromOffset(px, px),
        BackgroundColor3 = C.control,
        BackgroundTransparency = if filled then 0 else 1,
        Parent = parent,
    }, { corner(S.radius) })
    local g = Controls.glyph(icon, b, 14, C.text2)
    g.AnchorPoint = Vector2.new(0.5, 0.5)
    g.Position = UDim2.fromScale(0.5, 0.5)
    b.MouseEnter:Connect(function()
        tween(b, { BackgroundTransparency = 0 })
    end)
    b.MouseLeave:Connect(function()
        tween(b, { BackgroundTransparency = if filled then 0 else 1 })
    end)
    return b
end

-- Round headshot. Roblox serves rbxthumb URLs itself, so no web request is made here.
function Controls.avatar(parent: Instance, userId: number, size: number): ImageLabel
    local a = new("ImageLabel", {
        Name = "Avatar",
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = C.control,
        Image = string.format("rbxthumb://type=AvatarHeadShot&id=%d&w=48&h=48", userId),
        ScaleType = Enum.ScaleType.Crop,
        Parent = parent,
    }, { corner(size // 2) })
    return a
end

export type Check = { frame: Frame, set: (on: boolean) -> () }

-- Square check for dense module grids: red with a tick when on.
function Controls.check(parent: Instance): Check
    local box = new("Frame", {
        Name = "Check",
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = C.control,
        Parent = parent,
    }, { corner(5) })
    local stroke = Create.stroke(LINE.default)
    stroke.Parent = box
    local tick = Controls.glyph("check", box, 12, C.white)
    tick.AnchorPoint = Vector2.new(0.5, 0.5)
    tick.Position = UDim2.fromScale(0.5, 0.5)
    tick.Visible = false
    return {
        frame = box,
        set = function(on: boolean)
            box.BackgroundColor3 = if on then C.accent else C.control
            stroke.Enabled = not on
            tick.Visible = on
        end,
    }
end

-- Eyebrow label in small caps (RichText uppercases Cyrillic too, string.upper does not).
function Controls.eyebrow(parent: Instance, text: string): TextLabel
    return Create.text({
        text = "<uc>" .. Create.marked(text, nil) .. "</uc>",
        size = 10,
        font = F.medium,
        color = C.text3,
        auto = true,
    }, { Name = "Eyebrow", Size = UDim2.fromOffset(0, 16), Parent = parent })
end

-- 1px divider that spans its parent.
function Controls.hairline(parent: Instance, order: number?): Frame
    return new("Frame", {
        Name = "Hairline",
        BackgroundColor3 = C.white,
        BackgroundTransparency = LINE.default,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 1),
        LayoutOrder = order or 0,
        Parent = parent,
    })
end

return Controls
