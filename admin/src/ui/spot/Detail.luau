--!strict
-- Right pane of the desktop command bar: what the selected command or player is, with its own
-- control (switch or fill bar), key bind, dock pin and aliases.

local Analyze = require("./Analyze")
local Controls = require("../Controls")
local Create = require("../Create")
local Format = require("../Format")
local Janitor = require("../../core/Janitor")
local Rows = require("./Rows")
local Theme = require("../Theme")
local Types = require("../../Types")

local C, F = Theme.C, Theme.F
local new, list = Create.new, Create.list

type Item = Analyze.Item
type Spec = Types.CommandSpec

export type Hooks = {
    -- Runs the line the bar would run for this item (Enter).
    accept: () -> (),
}

local Detail = {}

local function wrap(
    parent: Instance,
    text: string,
    size: number,
    color: Color3,
    order: number
): TextLabel
    return Create.text({ text = Create.marked(text, nil), size = size, color = color }, {
        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.None,
        LayoutOrder = order,
        Parent = parent,
    })
end

local function kv(parent: Instance, key: string, order: number): Frame
    local r = new("Frame", {
        Name = "Row",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        LayoutOrder = order,
        Parent = parent,
    })
    Create.text(
        { text = key, size = 12, color = C.text3 },
        { Size = UDim2.fromScale(0.5, 1), Parent = r }
    )
    local right = new("Frame", {
        Name = "Right",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.fromScale(0.6, 1),
        Parent = r,
    })
    local l = list("x", 6)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Right
    l.Parent = right
    return right
end

local function runButton(
    parent: Instance,
    text: string,
    hooks: Hooks,
    jan: Janitor.Janitor,
    order: number
)
    local b = Controls.button(parent, text, "accent")
    b.AutomaticSize = Enum.AutomaticSize.None
    b.Size = UDim2.new(1, 0, 0, 34)
    b.LayoutOrder = order
    local l = b:FindFirstChildOfClass("UIListLayout")
    if l then
        l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    end
    Controls.kbd(b, "Enter").LayoutOrder = 3
    jan:Connect(b.Activated, hooks.accept)
end

function Detail.home(frame: Instance, deps: Rows.Deps)
    local t = deps.t
    Create.text({ text = t("sp.home_title"), size = 18, font = F.medium }, {
        Size = UDim2.new(1, 0, 0, 24),
        LayoutOrder = 1,
        Parent = frame,
    })
    wrap(frame, t("sp.home_text"), 12, C.text3, 2)
    local tips = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 3,
        Parent = frame,
    }, { list("y", 6) })
    for i, tip in { "fly", "speed 50", "help" } do
        local r = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            LayoutOrder = i,
            Parent = tips,
        })
        Controls.kbd(r, tip)
    end
end

function Detail.command(
    frame: Instance,
    spec: Spec,
    deps: Rows.Deps,
    jan: Janitor.Janitor,
    hooks: Hooks
): { () -> () }
    local t, reg, store = deps.t, deps.registry, deps.store
    local name = spec.name
    local refreshers: { () -> () } = {}
    Create.text({ text = t("c." .. name), size = 18, font = F.medium }, {
        Size = UDim2.new(1, 0, 0, 24),
        LayoutOrder = 1,
        Parent = frame,
    })
    Create.text({
        text = Create.marked(Format.signature(spec), nil),
        size = 12,
        font = F.mono,
        color = C.text2,
    }, {
        Size = UDim2.new(1, 0, 0, 16),
        LayoutOrder = 2,
        Parent = frame,
    })
    wrap(frame, t("d." .. name), 12, C.text3, 3)

    local missing = reg:Missing(spec)
    if missing then
        wrap(frame, t("err.needs", name, missing), 12, C.accent, 4)
        return refreshers
    end
    local req = Format.requiredArg(spec)
    if spec.kind == "value" then
        local holder = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 40),
            LayoutOrder = 4,
            Parent = frame,
        })
        local ctl = Rows.control(spec, holder, deps, jan, 40, nil)
        table.insert(refreshers, ctl.refresh)
    elseif spec.kind == "toggle" and not req then
        local right = kv(frame, t("sp.state_on"), 4)
        local sw = new("TextButton", {
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(32, 18),
            Parent = right,
        })
        local ctl = Rows.control(spec, sw, deps, jan, 18, nil)
        table.insert(refreshers, ctl.refresh)
        jan:Connect(sw.Activated, function()
            deps.run(name)
        end)
    elseif req then
        wrap(frame, t("sp.choose_arg", Format.argLabel(req)), 12, C.text2, 4)
    else
        runButton(frame, t("sp.run"), hooks, jan, 4)
    end

    -- Key bind: click the cap, press a key (Backspace clears).
    local keyRight = kv(frame, t("sp.key"), 5)
    local key = Rows.keyFor(store, name)
    local cap = Controls.kbd(keyRight, key or t("sp.no_key"))
    local capBtn = new(
        "TextButton",
        { Text = "", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = cap }
    )
    jan:Connect(capBtn.Activated, function()
        cap.Text = t("ui.press_key")
        deps.capture(function(k: Enum.KeyCode)
            local binds = store.data.binds
            for bk, line in binds do
                if line == name then
                    binds[bk] = nil
                end
            end
            if k ~= Enum.KeyCode.Backspace and k ~= Enum.KeyCode.Escape then
                binds[k.Name] = name
            end
            store:Save("binds")
            cap.Text = Rows.keyFor(store, name) or t("sp.no_key")
        end)
    end)

    if not req then
        local pinRight = kv(frame, t("sp.dock"), 6)
        local star = new("TextButton", {
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(22, 22),
            Parent = pinRight,
        })
        local g =
            Controls.glyph("star", star, 16, if deps.isPinned(name) then C.accent else C.text3)
        g.AnchorPoint = Vector2.new(0.5, 0.5)
        g.Position = UDim2.fromScale(0.5, 0.5)
        jan:Connect(star.Activated, function()
            deps.togglePin(name)
            Controls.tint(g, if deps.isPinned(name) then C.accent else C.text3)
        end)
    end
    if spec.aliases and #spec.aliases > 0 then
        local r = kv(frame, t("sp.also"), 7)
        Create.text({
            text = table.concat(spec.aliases, " · "),
            size = 11,
            font = F.mono,
            color = C.text2,
            auto = true,
        }, {
            Parent = r,
        })
    end
    return refreshers
end

function Detail.player(
    frame: Instance,
    item: Item,
    spec: Spec?,
    deps: Rows.Deps,
    jan: Janitor.Janitor,
    hooks: Hooks
)
    local t = deps.t
    local p = item.player :: Player
    local who = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 48),
        LayoutOrder = 1,
        Parent = frame,
    })
    Controls.avatar(who, p.UserId, 48)
    Create.text({ text = Create.marked(p.DisplayName, nil), size = 18, font = F.medium }, {
        Position = UDim2.fromOffset(60, 4),
        Size = UDim2.new(1, -60, 0, 22),
        Parent = who,
    })
    Create.text(
        { text = "@" .. p.Name .. " · " .. p.UserId, size = 10.5, font = F.mono, color = C.text3 },
        {
            Position = UDim2.fromOffset(60, 28),
            Size = UDim2.new(1, -60, 0, 14),
            Parent = who,
        }
    )
    local age = kv(frame, t("sp.account"), 2)
    Create.text(
        { text = t("sp.days", p.AccountAge), size = 12, font = F.mono, auto = true },
        { Parent = age }
    )
    local team = kv(frame, t("sp.team"), 3)
    Create.text(
        { text = if p.Team then p.Team.Name else "—", size = 12, font = F.mono, auto = true },
        { Parent = team }
    )
    if spec then
        runButton(frame, t("c." .. spec.name), hooks, jan, 4)
    end
end

function Detail.value(
    frame: Instance,
    item: Item,
    spec: Spec?,
    deps: Rows.Deps,
    jan: Janitor.Janitor,
    hooks: Hooks
)
    Create.text({ text = Create.marked(item.label, nil), size = 18, font = F.medium }, {
        Size = UDim2.new(1, 0, 0, 24),
        LayoutOrder = 1,
        Parent = frame,
    })
    if spec then
        wrap(frame, deps.t("d." .. spec.name), 12, C.text3, 2)
        runButton(frame, deps.t("c." .. spec.name), hooks, jan, 3)
    end
end

return Detail
