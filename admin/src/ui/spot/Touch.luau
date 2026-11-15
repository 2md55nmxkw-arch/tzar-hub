--!strict
-- Touch body of the command bar: everything works by tapping. Recents as chips, favourites as
-- tiles, commands as rows with their own switch or fill bar, players as a grid with avatars.

local Analyze = require("./Analyze")
local Controls = require("../Controls")
local Create = require("../Create")
local Format = require("../Format")
local Janitor = require("../../core/Janitor")
local Rows = require("./Rows")
local Theme = require("../Theme")
local Types = require("../../Types")

local C, F, S = Theme.C, Theme.F, Theme.SIZE
local new, corner, pad, list = Create.new, Create.corner, Create.pad, Create.list

type Item = Analyze.Item
type Spec = Types.CommandSpec

export type Hooks = {
    setLine: (text: string, keyboard: boolean?) -> (),
    -- Tap on a favourite: toggle it or run it, the same as on the dock.
    quick: (spec: Spec) -> (),
    refreshers: { () -> () },
}

local Touch = {}

local H = S.rowTouch

local function flow(parent: Instance, order: number): Frame
    local f = new("Frame", {
        Name = "Flow",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order,
        Parent = parent,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Wraps = true,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = f,
    })
    return f
end

local function grid(
    parent: Instance,
    order: number,
    cols: number,
    count: number,
    cellH: number
): { Frame }
    local cells: { Frame } = {}
    local rowsN = math.ceil(count / cols)
    local holder = new("Frame", {
        Name = "Grid",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, rowsN * cellH + (rowsN - 1) * 6),
        LayoutOrder = order,
        Parent = parent,
    }, { list("y", 6) })
    for r = 1, rowsN do
        local row = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, cellH),
            LayoutOrder = r,
            Parent = holder,
        }, { list("x", 6) })
        for c = 1, cols do
            if (r - 1) * cols + c > count then
                break
            end
            local cell = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1 / cols, -6 * (cols - 1) / cols, 1, 0),
                LayoutOrder = c,
                Parent = row,
            })
            table.insert(cells, cell)
        end
    end
    return cells
end

local function tapCard(parent: Instance, on: boolean): TextButton
    return new("TextButton", {
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = if on then C.accent else C.track,
        Size = UDim2.fromScale(1, 1),
        Parent = parent,
    }, { corner(S.radius), pad(10, 10) })
end

local function commandRow(
    parent: Instance,
    spec: Spec,
    deps: Rows.Deps,
    jan: Janitor.Janitor,
    hooks: Hooks,
    order: number,
    scroll: ScrollingFrame?
)
    local name = spec.name
    local a1 = spec.args and spec.args[1]
    if spec.kind == "value" and a1 and a1.kind == "number" then
        local holder = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, H),
            LayoutOrder = order,
            Parent = parent,
        })
        local ctl = Rows.control(spec, holder, deps, jan, H, scroll)
        table.insert(hooks.refreshers, ctl.refresh)
        return
    end
    local row = new("TextButton", {
        Name = "Row",
        Text = "",
        AutoButtonColor = false,
        BackgroundColor3 = C.track,
        Size = UDim2.new(1, 0, 0, H),
        LayoutOrder = order,
        Parent = parent,
    }, { corner(S.radius), pad(12, 10) })
    local texts = new(
        "Frame",
        { BackgroundTransparency = 1, Size = UDim2.new(1, -50, 1, 0), Parent = row },
        { list("x", 8) }
    )
    Create.text(
        { text = deps.t("c." .. name), size = 14, font = F.medium, auto = true },
        { LayoutOrder = 1, Parent = texts }
    )
    Create.text(
        { text = name, size = 10.5, font = F.mono, color = C.text3, auto = true },
        { LayoutOrder = 2, Parent = texts }
    )
    local right = new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.fromScale(1, 0.5),
        Size = UDim2.fromOffset(32, 18),
        Parent = row,
    })
    local ctl = Rows.control(spec, right, deps, jan, 18, nil)
    table.insert(hooks.refreshers, ctl.refresh)
    local req = Format.requiredArg(spec)
    jan:Connect(row.Activated, function()
        if req then
            hooks.setLine(
                name .. " ",
                req.kind == "string" or req.kind == "rest" or req.kind == "number"
            )
        else
            deps.run(name)
        end
    end)
end

function Touch.home(
    body: Instance,
    groups: { Analyze.Group },
    deps: Rows.Deps,
    jan: Janitor.Janitor,
    hooks: Hooks
)
    local order = 0
    local function nextOrder(): number
        order += 1
        return order
    end
    for _, g in groups do
        if g.title then
            Rows.group(body, g.title, nextOrder())
        end
        local isRecent = g.items[1] and g.items[1].kind == "line"
        if isRecent then
            local f = flow(body, nextOrder())
            for i, item in g.items do
                local on = not item.group
                    and item.spec
                    and deps.registry:IsActive((item.spec :: Spec).name)
                local chip = new("TextButton", {
                    Text = "",
                    AutoButtonColor = false,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2.fromOffset(0, 38),
                    BackgroundColor3 = if on then Color3.fromHex("3b1a1d") else C.control,
                    LayoutOrder = i,
                    Parent = f,
                }, { corner(S.radius), pad(12, 12), list("x", 6) })
                if on then
                    new("Frame", {
                        Size = UDim2.fromOffset(6, 6),
                        BackgroundColor3 = C.accent,
                        LayoutOrder = 1,
                        Parent = chip,
                    }, { corner(3) })
                end
                Create.text({
                    text = Create.marked(item.label, nil),
                    size = 12.5,
                    font = if item.group then F.medium else F.mono,
                    auto = true,
                }, { LayoutOrder = 2, Parent = chip })
                jan:Connect(chip.Activated, function()
                    deps.run(item.text)
                end)
            end
        else
            local cells = grid(body, nextOrder(), 4, #g.items, 52)
            for i, item in g.items do
                local spec = item.spec :: Spec
                local on = deps.registry:IsActive(spec.name)
                local card = tapCard(cells[i], on)
                local l = list("x", 8)
                l.Parent = card
                Controls.glyph(spec.icon or "command", card, 16, if on then C.white else C.text2).LayoutOrder =
                    1
                Create.text({
                    text = deps.t("c." .. spec.name),
                    size = 13,
                    font = F.medium,
                    color = if on then C.white else C.text1,
                }, {
                    Size = UDim2.new(1, -24, 1, 0),
                    LayoutOrder = 2,
                    Parent = card,
                })
                jan:Connect(card.Activated, function()
                    hooks.quick(spec)
                end)
            end
        end
    end
    local all = new("TextButton", {
        Name = "All",
        Text = "",
        AutoButtonColor = false,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 34),
        LayoutOrder = nextOrder(),
        Parent = body,
    }, { pad(4, 4) })
    Create.text(
        { text = deps.t("sp.all"), size = 13, font = F.medium, color = C.text2 },
        { Size = UDim2.new(1, -20, 1, 0), Parent = all }
    )
    local chev = Controls.glyph("arrow-right", all, 14, C.text3)
    chev.AnchorPoint = Vector2.new(1, 0.5)
    chev.Position = UDim2.fromScale(1, 0.5)
    jan:Connect(all.Activated, function()
        deps.openPanel("commands")
    end)
end

function Touch.commands(
    body: Instance,
    groups: { Analyze.Group },
    deps: Rows.Deps,
    jan: Janitor.Janitor,
    hooks: Hooks,
    scroll: ScrollingFrame?
)
    local order = 0
    for _, g in groups do
        for _, item in g.items do
            order += 1
            if item.kind == "line" then
                -- A module or a set: one tap runs it.
                local row = new("TextButton", {
                    Name = "Row",
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundColor3 = C.track,
                    Size = UDim2.new(1, 0, 0, H),
                    LayoutOrder = order,
                    Parent = body,
                }, { corner(S.radius), pad(12, 10), list("x", 8) })
                local icon = item.spec and (item.spec :: Spec).icon or "box"
                Controls.glyph(icon, row, 16, C.text2).LayoutOrder = 1
                Create.text({
                    text = Create.marked(item.label, nil),
                    size = 14,
                    font = F.medium,
                    auto = true,
                }, { LayoutOrder = 2, Parent = row })
                if item.sub then
                    Create.text({
                        text = Create.marked(item.sub, nil),
                        size = 11,
                        color = C.text3,
                        auto = true,
                    }, { LayoutOrder = 3, Parent = row })
                end
                jan:Connect(row.Activated, function()
                    deps.run(item.text)
                end)
            elseif item.spec then
                commandRow(body, item.spec :: Spec, deps, jan, hooks, order, scroll)
            end
        end
    end
end

function Touch.args(
    body: Instance,
    a: Analyze.Analysis,
    groups: { Analyze.Group },
    deps: Rows.Deps,
    jan: Janitor.Janitor,
    hooks: Hooks,
    text: string
)
    local spec = a.spec :: Spec
    local head = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 22),
        LayoutOrder = 1,
        Parent = body,
    }, { list("x", 8) })
    Create.text(
        { text = deps.t("c." .. spec.name), size = 14, font = F.medium, auto = true },
        { LayoutOrder = 1, Parent = head }
    )
    Create.text({
        text = Create.marked(Format.signature(spec, a.argIndex, true), nil),
        size = 10.5,
        font = F.mono,
        color = C.text3,
        auto = true,
    }, {
        LayoutOrder = 2,
        Parent = head,
    })
    local items = groups[1] and groups[1].items or {}
    if #items == 0 then
        Create.text(
            { text = deps.t("ui.nothing"), size = 13, color = C.text3 },
            { Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 2, Parent = body }
        )
        return
    end
    local pick = function(item: Item)
        local line, ready = Analyze.accept(text, a, item)
        if ready then
            deps.run(line)
            hooks.setLine("")
        else
            hooks.setLine(line)
        end
    end
    if items[1].kind == "player" then
        local cells = grid(body, 2, 3, #items, 52)
        for i, item in items do
            local p = item.player :: Player
            local card = tapCard(cells[i], false)
            local av = Controls.avatar(card, p.UserId, 30)
            av.AnchorPoint = Vector2.new(0, 0.5)
            av.Position = UDim2.fromScale(0, 0.5)
            Create.text(
                { text = Create.marked(p.DisplayName, item.marks), size = 13, font = F.medium },
                {
                    Position = UDim2.fromOffset(38, 7),
                    Size = UDim2.new(1, -38, 0, 18),
                    Parent = card,
                }
            )
            Create.text({
                text = Create.marked("@" .. p.Name, item.subMarks),
                size = 10,
                font = F.mono,
                color = C.text3,
            }, {
                Position = UDim2.fromOffset(38, 26),
                Size = UDim2.new(1, -38, 0, 14),
                Parent = card,
            })
            jan:Connect(card.Activated, function()
                pick(item)
            end)
        end
    else
        local f = flow(body, 2)
        for i, item in items do
            local chip = new("TextButton", {
                Text = "",
                AutoButtonColor = false,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromOffset(0, 40),
                BackgroundColor3 = C.control,
                LayoutOrder = i,
                Parent = f,
            }, { corner(S.radius), pad(14, 14) })
            Create.text(
                { text = Create.marked(item.label, item.marks), size = 13, auto = true },
                { Parent = chip }
            )
            jan:Connect(chip.Activated, function()
                pick(item)
            end)
        end
    end
end

return Touch
