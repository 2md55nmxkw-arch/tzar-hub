--!strict
-- Small helpers for building instances.

local TweenService = game:GetService("TweenService")

local Theme = require("./Theme")

local C, F, LINE = Theme.C, Theme.F, Theme.LINE

local Create = {}

function Create.new(class: string, props: { [string]: any }, children: { Instance }?): any
    local inst = Instance.new(class)
    for k, v in props do
        if k ~= "Parent" then
            (inst :: any)[k] = v
        end
    end
    for _, child in children or {} do
        child.Parent = inst
    end
    if props.Parent then
        inst.Parent = props.Parent
    end
    return inst
end

local new = Create.new

function Create.corner(px: number): UICorner
    return new("UICorner", { CornerRadius = UDim.new(0, px) })
end

function Create.stroke(transparency: number?, color: Color3?): UIStroke
    return new("UIStroke", {
        Color = color or C.white,
        Transparency = transparency or LINE.default,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

function Create.pad(l: number, r: number?, t: number?, b: number?): UIPadding
    return new("UIPadding", {
        PaddingLeft = UDim.new(0, l),
        PaddingRight = UDim.new(0, r or l),
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or t or 0),
    })
end

function Create.list(dir: "x" | "y", gap: number, align: Enum.VerticalAlignment?): UIListLayout
    return new("UIListLayout", {
        FillDirection = if dir == "x"
            then Enum.FillDirection.Horizontal
            else Enum.FillDirection.Vertical,
        Padding = UDim.new(0, gap),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = align
            or (if dir == "x" then Enum.VerticalAlignment.Center else Enum.VerticalAlignment.Top),
    })
end

export type TextProps = {
    text: string,
    size: number?,
    font: Font?,
    color: Color3?,
    x: Enum.TextXAlignment?,
    auto: boolean?,
}

function Create.text(p: TextProps, extra: { [string]: any }?): TextLabel
    local props: { [string]: any } = {
        BackgroundTransparency = 1,
        Text = p.text,
        TextSize = p.size or 13,
        FontFace = p.font or F.regular,
        TextColor3 = p.color or C.text1,
        TextXAlignment = p.x or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextTruncate = Enum.TextTruncate.AtEnd,
        RichText = true,
        AutoLocalize = false,
    }
    if p.auto then
        props.AutomaticSize = Enum.AutomaticSize.X
        props.Size = UDim2.fromScale(0, 1)
        props.TextTruncate = Enum.TextTruncate.None
    end
    for k, v in extra or {} do
        props[k] = v
    end
    return new("TextLabel", props)
end

function Create.shadow(parent: Instance, preset: any)
    -- UIShadow is new; older clients simply get no shadow.
    local ok, s = pcall(function(): Instance
        return Instance.new("UIShadow" :: any)
    end)
    if not ok then
        return
    end
    for k, v in preset do
        pcall(function()
            (s :: any)[k] = v
        end)
    end
    s.Parent = parent
end

-- A ScrollingFrame as tall as its content, up to `max()`, scrolling past that. AutomaticSize does
-- not respect a UISizeConstraint on a ScrollingFrame: the frame grows past the limit, so it never
-- scrolls and its parent cuts it off. The height is therefore set here by hand.
function Create.fitScroll(sf: ScrollingFrame, max: () -> number): () -> ()
    local layout = sf:FindFirstChildOfClass("UIListLayout")
    local padding = sf:FindFirstChildOfClass("UIPadding")
    sf.AutomaticSize = Enum.AutomaticSize.None
    local function refit()
        local h = if layout then layout.AbsoluteContentSize.Y else 0
        if padding then
            h += padding.PaddingTop.Offset + padding.PaddingBottom.Offset
        end
        local x = sf.Size.X
        sf.Size = UDim2.new(x.Scale, x.Offset, 0, math.floor(math.min(h, max())))
    end
    if layout then
        -- Dies with the frame, so it needs no Janitor.
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(refit)
    end
    refit()
    return refit
end

local TWEEN = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

function Create.tween(inst: Instance, props: { [string]: any }, info: TweenInfo?)
    TweenService:Create(inst, info or TWEEN, props):Play()
end

-- Escapes text for RichText labels and underlines matched positions in the accent colour.
function Create.marked(text: string, marks: { number }?): string
    local function esc(s: string): string
        return (string.gsub(string.gsub(string.gsub(s, "&", "&amp;"), "<", "&lt;"), ">", "&gt;"))
    end
    if not marks or #marks == 0 then
        return esc(text)
    end
    local set: { [number]: boolean } = {}
    for _, m in marks do
        set[m] = true
    end
    local out = {}
    local i, n = 1, #text
    while i <= n do
        local j = i
        local on = set[i] == true
        while j + 1 <= n and (set[j + 1] == true) == on do
            j += 1
        end
        local chunk = esc(string.sub(text, i, j))
        table.insert(
            out,
            if on then '<u><font color="#ffffff">' .. chunk .. "</font></u>" else chunk
        )
        i = j + 1
    end
    return table.concat(out)
end

return Create
