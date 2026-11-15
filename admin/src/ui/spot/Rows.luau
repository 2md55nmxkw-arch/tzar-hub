--!strict
-- Rows and controls shared by the command bar (desktop list, detail pane, touch body).

local Analyze = require("./Analyze")
local Controls = require("../Controls")
local Create = require("../Create")
local FillBar = require("../FillBar")
local Format = require("../Format")
local Janitor = require("../../core/Janitor")
local Modules = require("../../core/Modules")
local Registry = require("../../core/Registry")
local Store = require("../../core/Store")
local Theme = require("../Theme")
local Types = require("../../Types")

local C, F, S = Theme.C, Theme.F, Theme.SIZE
local new, corner, pad, list = Create.new, Create.corner, Create.pad, Create.list

type Item = Analyze.Item
type Spec = Types.CommandSpec

export type Deps = {
    registry: Registry.Registry,
    store: Store.Store,
    t: (key: string, ...any) -> string,
    run: (line: string) -> (),
    capture: (fn: ((Enum.KeyCode) -> ())?) -> (),
    openPanel: (id: string) -> (),
    isPinned: (name: string) -> boolean,
    togglePin: (name: string) -> (),
    modules: Modules.Modules,
    openModule: (id: string) -> (),
}

local Rows = {}

-- Arguments only: "<0–500>", "[speed]".
function Rows.argText(spec: Spec): string
    local parts = {}
    for _, a in spec.args or {} do
        table.insert(parts, Format.argLabel(a))
    end
    return table.concat(parts, " ")
end

function Rows.keyFor(store: Store.Store, name: string): string?
    for key, line in store.data.binds do
        if line == name then
            return key
        end
    end
    return nil
end

function Rows.group(parent: Instance, title: string, order: number): Frame
    local f = new("Frame", {
        Name = "Group",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        LayoutOrder = order,
        Parent = parent,
    }, { pad(8, 8, 6, 0) })
    Controls.eyebrow(f, title)
    return f
end

local function base(parent: Instance, order: number, height: number, selected: boolean): TextButton
    return new("TextButton", {
        Name = "Result",
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = C.control,
        BackgroundTransparency = if selected then 0 else 1,
        Size = UDim2.new(1, 0, 0, height),
        LayoutOrder = order,
        Parent = parent,
    }, { corner(S.radius), pad(10, 10) })
end

-- Two lines: name, arguments and alias; then the description.
function Rows.command(
    parent: Instance,
    item: Item,
    selected: boolean,
    deps: Deps,
    order: number
): TextButton
    local spec = item.spec :: Spec
    local b = base(parent, order, 46, selected)
    local top = new("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 7),
        Size = UDim2.new(1, 0, 0, 18),
        Parent = b,
    }, { list("x", 6) })
    if deps.registry:IsActive(spec.name) then
        new("Frame", {
            Name = "On",
            Size = UDim2.fromOffset(5, 5),
            BackgroundColor3 = C.accent,
            LayoutOrder = 1,
            Parent = top,
        }, { corner(3) })
    end
    Create.text(
        { text = Create.marked(item.label, item.marks), size = 13, font = F.medium, auto = true },
        {
            Name = "Name",
            LayoutOrder = 2,
            Parent = top,
        }
    )
    local value = if spec.kind == "value" and deps.registry:IsActive(spec.name)
        then Format.value(deps.registry:Value(spec.name))
        else Rows.argText(spec)
    Create.text({
        text = Create.marked(value, nil),
        size = 10.5,
        font = F.mono,
        color = C.text3,
        auto = true,
    }, {
        Name = "Args",
        LayoutOrder = 3,
        Parent = top,
    })
    if item.tag then
        Create.text(
            { text = item.tag, size = 10, color = C.text3, x = Enum.TextXAlignment.Right },
            {
                Name = "Tag",
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 7),
                Size = UDim2.fromOffset(80, 18),
                Parent = b,
            }
        )
    end
    Create.text(
        { text = item.sub or "", size = 12, color = if selected then C.text2 else C.text3 },
        {
            Name = "Desc",
            Position = UDim2.fromOffset(0, 25),
            Size = UDim2.new(1, 0, 0, 16),
            Parent = b,
        }
    )
    return b
end

-- A recent line such as "speed 96".
function Rows.line(
    parent: Instance,
    item: Item,
    selected: boolean,
    deps: Deps,
    order: number
): TextButton
    local b = base(parent, order, 34, selected)
    list("x", 8).Parent = b
    local spec = item.spec
    Controls.glyph((spec and spec.icon) or "command", b, 14, C.text3).LayoutOrder = 1
    Create.text({
        text = Create.marked(item.label, nil),
        size = 12.5,
        font = if item.sub then F.medium else F.mono,
        auto = true,
    }, {
        LayoutOrder = 2,
        Parent = b,
    })
    if item.sub then
        -- A module's description is long: it ends in "…" instead of running past the row.
        local sub = Create.text(
            { text = Create.marked(item.sub, nil), size = 11.5, color = C.text3, auto = true },
            { LayoutOrder = 4, TextTruncate = Enum.TextTruncate.AtEnd, Parent = b }
        )
        new("UISizeConstraint", { MaxSize = Vector2.new(S.bar * 0.45, math.huge), Parent = sub })
    end
    if spec and not item.group and deps.registry:IsActive(spec.name) then
        new("Frame", {
            Size = UDim2.fromOffset(5, 5),
            BackgroundColor3 = C.accent,
            LayoutOrder = 3,
            Parent = b,
        }, {
            corner(3),
        })
    end
    return b
end

function Rows.player(parent: Instance, item: Item, selected: boolean, order: number): TextButton
    local b = base(parent, order, 44, selected)
    local p = item.player :: Player
    local av = Controls.avatar(b, p.UserId, 28)
    av.AnchorPoint = Vector2.new(0, 0.5)
    av.Position = UDim2.fromScale(0, 0.5)
    Create.text({ text = Create.marked(item.label, item.marks), size = 13, font = F.medium }, {
        Position = UDim2.fromOffset(38, 5),
        Size = UDim2.new(1, -110, 0, 18),
        Parent = b,
    })
    Create.text({
        text = Create.marked(item.sub or "", item.subMarks),
        size = 10.5,
        font = F.mono,
        color = C.text3,
    }, {
        Position = UDim2.fromOffset(38, 23),
        Size = UDim2.new(1, -110, 0, 14),
        Parent = b,
    })
    Create.text(
        { text = item.tag or "", size = 10, color = C.text3, x = Enum.TextXAlignment.Right },
        {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.fromScale(1, 0.5),
            Size = UDim2.fromOffset(70, 16),
            Parent = b,
        }
    )
    return b
end

function Rows.value(parent: Instance, item: Item, selected: boolean, order: number): TextButton
    local b = base(parent, order, 34, selected)
    Create.text({ text = Create.marked(item.label, item.marks), size = 13 }, {
        Size = UDim2.fromScale(1, 1),
        Parent = b,
    })
    return b
end

export type Control = { kind: "switch" | "bar" | "arrow", refresh: () -> (), bar: FillBar.FillBar? }

-- The command's own control: a switch for toggles, a fill bar for number values, an arrow otherwise.
function Rows.control(
    spec: Spec,
    parent: Instance,
    deps: Deps,
    jan: Janitor.Janitor,
    height: number,
    scroll: ScrollingFrame?
): Control
    local reg = deps.registry
    local name = spec.name
    local a1 = spec.args and spec.args[1]
    if spec.kind == "value" and a1 and a1.kind == "number" then
        local lo, hi = a1.min or 0, a1.max or 100
        local bar = FillBar.new(parent, {
            height = height,
            min = lo,
            max = hi,
            step = a1.step or 1,
            default = spec.default,
            scroll = scroll,
            jan = jan,
            title = function()
                return deps.t("c." .. name)
            end,
            format = function(v: number)
                return Format.value(v)
            end,
            value = function()
                return tonumber(reg:Value(name)) or spec.default or lo
            end,
            active = function()
                return reg:IsActive(name)
            end,
            enabled = function()
                return not reg:IsDisabled(name) and reg:Missing(spec) == nil
            end,
            commit = function(v: number)
                deps.run(name .. " " .. Format.value(v))
            end,
        })
        return { kind = "bar", refresh = bar.refresh, bar = bar }
    elseif spec.kind == "toggle" then
        local sw = Controls.switch(parent)
        sw.set(reg:IsActive(name))
        return {
            kind = "switch",
            refresh = function()
                sw.set(reg:IsActive(name))
            end,
        }
    end
    Controls.glyph(
        if Format.requiredArg(spec) then "chevron-down" else "arrow-right",
        parent,
        14,
        C.text3
    )
    return { kind = "arrow", refresh = function() end }
end

return Rows
