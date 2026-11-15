--!strict
-- The command bar. Desktop: results on the left, the selected command or player on the right,
-- ↑↓ Tab Enter Esc, ↑ in an empty bar walks the history. Touch: one column, everything by tap.

local UserInputService = game:GetService("UserInputService")

local Analyze = require("./spot/Analyze")
local Controls = require("./Controls")
local Create = require("./Create")
local Detail = require("./spot/Detail")
local Format = require("./Format")
local Janitor = require("../core/Janitor")
local Rows = require("./spot/Rows")
local Theme = require("./Theme")
local Touch = require("./spot/Touch")
local Types = require("../Types")

local C, F, LINE, S = Theme.C, Theme.F, Theme.LINE, Theme.SIZE
local new, corner, pad, list = Create.new, Create.corner, Create.pad, Create.list

type Item = Analyze.Item
type Spec = Types.CommandSpec

export type Deps = Rows.Deps & {
    quick: (spec: Spec) -> (),
}

export type Spotlight = {
    frame: Frame,
    input: TextBox,
    open: (prefill: string?) -> (),
    close: () -> (),
    isOpen: () -> boolean,
    refresh: () -> (),
    text: () -> string,
}

local Spotlight = {}

local MAX_DESKTOP = 330

function Spotlight.new(layer: Instance, jan: Janitor.Janitor, deps: Deps): Spotlight
    local touch = Theme.touch
    local t, reg, store = deps.t, deps.registry, deps.store
    local W = if touch then S.barTouch else S.bar
    local LEFT = S.results

    local root = new("Frame", {
        Name = "Spotlight",
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, if touch then 8 else S.barTop),
        Size = UDim2.fromOffset(W, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.surface,
        Visible = false,
        Active = true,
        Parent = layer,
    }, { corner(if touch then S.card else S.window), Create.stroke(LINE.strong), list("y", 0) })
    Create.shadow(root, Theme.SHADOW.window)

    -- Head (desktop)
    local stats: TextLabel? = nil
    if not touch then
        local head = new("Frame", {
            Name = "Head",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            LayoutOrder = 1,
            Parent = root,
        }, { pad(16, 14, 10, 0) })
        local hl = new(
            "Frame",
            { BackgroundTransparency = 1, Size = UDim2.fromScale(0.6, 1), Parent = head },
            { list("x", 8) }
        )
        Controls.logo(hl, 13).LayoutOrder = 1
        Controls.eyebrow(hl, t("sp.title")).LayoutOrder = 2
        stats = Create.text(
            { text = "", size = 10, font = F.mono, color = C.text3, x = Enum.TextXAlignment.Right },
            {
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.fromScale(1, 0),
                Size = UDim2.fromScale(0.4, 1),
                Parent = head,
            }
        )
    end

    -- Input
    local inputRow = new("Frame", {
        Name = "InputRow",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, if touch then 50 else 46),
        LayoutOrder = 2,
        Parent = root,
    }, { pad(if touch then 12 else 16, if touch then 8 else 14) })
    local lead = new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(18, 18),
        Parent = inputRow,
    })
    if touch then
        Controls.logo(lead, 16)
    else
        Controls.glyph("search", lead, 16, C.text2)
    end
    local textSize = if touch then 15 else 18
    local ghost = Create.text({ text = "", size = textSize, font = F.medium, color = C.text3 }, {
        Name = "Ghost",
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -90, 1, 0),
        TextTruncate = Enum.TextTruncate.None,
        ClipsDescendants = true,
        Parent = inputRow,
    })
    local input = new("TextBox", {
        Name = "Input",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -90, 1, 0),
        Text = "",
        PlaceholderText = t("ui.search"),
        PlaceholderColor3 = C.text3,
        TextColor3 = C.text1,
        TextSize = textSize,
        FontFace = F.medium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        AutoLocalize = false,
        ClipsDescendants = true,
        Parent = inputRow,
    })
    local rightSlot = new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.fromScale(1, 0.5),
        Size = UDim2.fromOffset(60, 34),
        Parent = inputRow,
    })
    local rl = list("x", 6)
    rl.HorizontalAlignment = Enum.HorizontalAlignment.Right
    rl.Parent = rightSlot
    local keyCap: TextLabel? = nil
    local closeBtn: TextButton? = nil
    if touch then
        closeBtn = Controls.iconButton(rightSlot, "x", 34, true)
    else
        keyCap = Controls.kbd(rightSlot, "Esc")
    end

    -- Argument hint line
    local sigRow = new("Frame", {
        Name = "Signature",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        LayoutOrder = 3,
        Visible = false,
        Parent = root,
    }, { pad(if touch then 12 else 16, 16, 0, 6), list("x", 6) })
    local sigCmd = Create.text(
        { text = "", size = 12, font = F.mono, color = C.text2, auto = true },
        { LayoutOrder = 1, Parent = sigRow }
    )
    local sigArg = Create.text(
        { text = "", size = 12, font = F.mono, color = C.accent, auto = true },
        {
            LayoutOrder = 2,
            BackgroundTransparency = 0.84,
            BackgroundColor3 = C.accent,
            Parent = sigRow,
        }
    )
    corner(4).Parent = sigArg
    pad(6, 6).Parent = sigArg
    local sigDesc = Create.text({ text = "", size = 12, color = C.text3 }, {
        LayoutOrder = 3,
        Size = UDim2.new(1, -200, 1, 0),
        Parent = sigRow,
    })

    Controls.hairline(root, 4)

    -- Body
    local body = new("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 5,
        Parent = root,
    })
    local results = new("ScrollingFrame", {
        Name = "Results",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(if touch then 1 else 0, if touch then 0 else LEFT, 0, 0),
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.text3,
        Parent = body,
    }, { pad(8, 8, 8, 10), list("y", if touch then 6 else 2) })
    local resultsMax = MAX_DESKTOP
    local refitResults = Create.fitScroll(results, function(): number
        return resultsMax
    end)
    local detail: Frame? = nil
    if not touch then
        new("UISizeConstraint", { MinSize = Vector2.new(0, 210), Parent = body })
        new("Frame", {
            Name = "Divider",
            BackgroundColor3 = C.white,
            BackgroundTransparency = LINE.default,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(LEFT, 0),
            Size = UDim2.new(0, 1, 1, 0),
            Parent = body,
        })
        detail = new("Frame", {
            Name = "Detail",
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(LEFT + 1, 0),
            Size = UDim2.new(1, -LEFT - 1, 1, 0),
            ClipsDescendants = true,
            Parent = body,
        }, { pad(16, 16, 14, 14), list("y", 10) })
    end

    Controls.hairline(root, 6)

    -- Footer: key hints (desktop) or panel buttons (touch)
    local foot = new("Frame", {
        Name = "Foot",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, if touch then 52 else 30),
        LayoutOrder = 7,
        Parent = root,
    }, {
        pad(
            if touch then 8 else 16,
            if touch then 8 else 16,
            if touch then 6 else 0,
            if touch then 6 else 0
        ),
    })
    local panelButtons: { [string]: TextButton } = {}
    if touch then
        list("x", 6).Parent = foot
        for i, entry in { { "commands", "list" }, { "binds", "key" }, { "settings", "settings" } } do
            local b = Controls.button(foot, t("pn." .. entry[1]), "plain", entry[2])
            b.AutomaticSize = Enum.AutomaticSize.None
            b.Size = UDim2.new(1 / 3, -4, 1, 0)
            b.LayoutOrder = i
            local l = b:FindFirstChildOfClass("UIListLayout")
            if l then
                l.HorizontalAlignment = Enum.HorizontalAlignment.Center
            end
            panelButtons[entry[1]] = b
        end
    else
        local hints = new(
            "Frame",
            { BackgroundTransparency = 1, Size = UDim2.fromScale(0.8, 1), Parent = foot },
            { list("x", 14) }
        )
        for i, h in
            { { "↑↓", "sp.k_select" }, { "Tab", "sp.k_complete" }, { "Enter", "sp.k_run" } }
        do
            Create.text({
                text = h[1] .. "  " .. t(h[2]),
                size = 10,
                font = F.mono,
                color = C.text3,
                auto = true,
            }, {
                LayoutOrder = i,
                Parent = hints,
            })
        end
        Create.text({
            text = "Esc  " .. t("sp.k_close"),
            size = 10,
            font = F.mono,
            color = C.text3,
            x = Enum.TextXAlignment.Right,
        }, {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.fromScale(0.3, 1),
            Parent = foot,
        })
    end

    -- State
    local text = ""
    local analysis: Analyze.Analysis = Analyze.line("", reg)
    local flat: { Item } = {}
    local buttons: { TextButton } = {}
    local sel = 1
    local historyAt = 0
    local suppress = false
    local isOpen = false
    local renderJan = Janitor.new()
    local detailJan = Janitor.new()
    jan:Add(renderJan)
    jan:Add(detailJan)
    local refreshers: { () -> () } = {}

    local function clear(frame: Instance)
        for _, c in frame:GetChildren() do
            if c:IsA("GuiObject") then
                c:Destroy()
            end
        end
    end

    local function fitHeight()
        local cam = workspace.CurrentCamera
        local vpY = if cam then cam.ViewportSize.Y else 720
        local top = root.Position.Y.Offset
        local fixed = if touch then 50 + 52 + 26 else 30 + 46 + 30 + 26
        resultsMax = math.max(120, math.min(MAX_DESKTOP, vpY - top - fixed - 16))
        refitResults()
    end

    local setText: (string, boolean?) -> ()
    local accept: (boolean) -> ()

    local function hooksDetail(): Detail.Hooks
        return {
            accept = function()
                accept(true)
            end,
        }
    end

    local function renderDetail()
        local d = detail
        if not d then
            return
        end
        detailJan:Cleanup()
        clear(d)
        local item = flat[sel]
        if analysis.mode == "home" and not item then
            Detail.home(d, deps)
            return
        end
        if not item then
            local spec = analysis.spec
            if spec then
                for _, r in Detail.command(d, spec, deps, detailJan, hooksDetail()) do
                    table.insert(refreshers, r)
                end
            end
            return
        end
        if item.kind == "player" then
            Detail.player(d, item, analysis.spec, deps, detailJan, hooksDetail())
        elseif item.kind == "value" then
            Detail.value(d, item, analysis.spec, deps, detailJan, hooksDetail())
        elseif item.spec then
            for _, r in Detail.command(d, item.spec :: Spec, deps, detailJan, hooksDetail()) do
                table.insert(refreshers, r)
            end
        end
    end

    local function paintSelection()
        for i, b in buttons do
            b.BackgroundTransparency = if i == sel then 0 else 1
            local desc = b:FindFirstChild("Desc")
            if desc and desc:IsA("TextLabel") then
                desc.TextColor3 = if i == sel then C.text2 else C.text3
            end
        end
        renderDetail()
    end

    local function setGhost(completion: string?)
        if
            completion
            and #completion > #text
            and string.lower(string.sub(completion, 1, #text)) == string.lower(text)
        then
            ghost.Text = '<font transparency="1">'
                .. Create.marked(text, nil)
                .. "</font>"
                .. Create.marked(string.sub(completion, #text + 1), nil)
        else
            ghost.Text = ""
        end
    end

    local function render()
        renderJan:Cleanup()
        clear(results)
        table.clear(refreshers)
        table.clear(flat)
        table.clear(buttons)
        analysis = Analyze.line(text, reg)
        local mode = analysis.mode
        local groups: { Analyze.Group }
        if mode == "home" then
            groups = Analyze.home(reg, store.data.history, store.data.pins, t, deps.modules)
        elseif mode == "command" then
            groups = Analyze.commands(
                analysis.query,
                reg,
                t,
                Analyze.modules(analysis.query, deps.modules, reg, t)
            )
        elseif mode == "args" then
            groups = Analyze.suggestions(analysis, reg, t)
        else
            groups = {}
        end
        for _, g in groups do
            for _, item in g.items do
                table.insert(flat, item)
            end
        end
        sel = math.clamp(sel, 1, math.max(#flat, 1))

        -- Signature line while typing arguments
        local spec = analysis.spec
        if mode == "args" and spec then
            sigRow.Visible = true
            sigCmd.Text = spec.name
            local arg = analysis.arg
            sigArg.Visible = arg ~= nil
            sigArg.Text = if arg then Create.marked(Format.argLabel(arg), nil) else ""
            sigDesc.Text = " · " .. t("d." .. spec.name)
        else
            sigRow.Visible = false
        end

        -- Ghost completion
        if mode == "command" then
            setGhost(flat[1] and flat[1].text)
        elseif mode == "args" and flat[1] then
            setGhost(string.sub(text, 1, #text - #analysis.query) .. flat[1].text)
        else
            ghost.Text = ""
        end

        if keyCap then
            keyCap.Text = if mode == "home" then "Esc" else "Tab"
        end
        if stats then
            stats.Text = t("sp.stats", #reg.specs, reg:ActiveCount())
        end

        if touch then
            local th: Touch.Hooks = {
                setLine = function(line: string, keyboard: boolean?)
                    setText(line, keyboard)
                end,
                quick = deps.quick,
                refreshers = refreshers,
            }
            if mode == "home" then
                Touch.home(results, groups, deps, renderJan, th)
            elseif mode == "command" then
                Touch.commands(results, groups, deps, renderJan, th, results)
            elseif mode == "args" then
                Touch.args(results, analysis, groups, deps, renderJan, th, text)
            else
                Create.text(
                    { text = t("err.unknown", analysis.query), size = 13, color = C.text3 },
                    {
                        Size = UDim2.new(1, 0, 0, 32),
                        Parent = results,
                    }
                )
            end
            return
        end

        local order = 0
        for _, g in groups do
            if g.title then
                order += 1
                Rows.group(results, g.title, order)
            end
            for _, item in g.items do
                order += 1
                local index = #buttons + 1
                local b: TextButton
                if item.kind == "player" then
                    b = Rows.player(results, item, index == sel, order)
                elseif item.kind == "value" then
                    b = Rows.value(results, item, index == sel, order)
                elseif item.kind == "line" then
                    b = Rows.line(results, item, index == sel, deps, order)
                else
                    b = Rows.command(results, item, index == sel, deps, order)
                end
                table.insert(buttons, b)
                renderJan:Connect(b.MouseEnter, function()
                    if sel ~= index then
                        sel = index
                        paintSelection()
                    end
                end)
                renderJan:Connect(b.Activated, function()
                    sel = index
                    accept(true)
                end)
            end
        end
        if #flat == 0 and mode ~= "home" then
            Create.text({
                text = if mode == "unknown"
                    then t("err.unknown", analysis.query)
                    else t("ui.nothing"),
                size = 13,
                color = C.text3,
            }, { Size = UDim2.new(1, 0, 0, 30), LayoutOrder = 999, Parent = results })
        end
        renderDetail()
    end

    setText = function(line: string, keyboard: boolean?)
        suppress = true
        text = line
        input.Text = line
        input.CursorPosition = #line + 1
        suppress = false
        sel = 1
        render()
        if keyboard or (not touch and isOpen) then
            input:CaptureFocus()
            input.CursorPosition = #line + 1
        end
    end

    local function close()
        if not isOpen then
            return
        end
        isOpen = false
        root.Visible = false
        input:ReleaseFocus()
        historyAt = 0
        suppress = true
        text = ""
        input.Text = ""
        suppress = false
    end

    accept = function(runIt: boolean)
        local item = flat[sel]
        local line, ready = Analyze.accept(text, analysis, item)
        if analysis.mode == "home" and not item then
            close()
            return
        end
        if ready and runIt and string.match(line, "%S") then
            deps.run(line)
            if touch then
                setText("")
            else
                close()
            end
        else
            setText(line, true)
        end
    end

    jan:Connect(input:GetPropertyChangedSignal("Text"), function()
        if suppress then
            return
        end
        local v = input.Text
        if string.find(v, "\t", 1, true) then
            setText((string.gsub(v, "\t", "")))
            return
        end
        text = v
        historyAt = 0
        sel = 1
        render()
    end)
    jan:Connect(input.FocusLost, function(enter: boolean)
        if enter and isOpen then
            accept(true)
        end
    end)
    jan:Connect(UserInputService.InputBegan, function(io: InputObject)
        if not isOpen then
            return
        end
        local key = io.KeyCode
        if key == Enum.KeyCode.Escape then
            task.defer(close)
            return
        end
        if not input:IsFocused() then
            return
        end
        if key == Enum.KeyCode.Tab then
            local item = flat[sel]
            local line = Analyze.accept(text, analysis, item)
            task.defer(setText, line, true)
        elseif key == Enum.KeyCode.Down or key == Enum.KeyCode.Up then
            local hist = store.data.history
            if text == "" or historyAt > 0 then
                if #hist == 0 then
                    return
                end
                historyAt = if key == Enum.KeyCode.Up
                    then math.min(historyAt + 1, #hist)
                    else math.max(historyAt - 1, 0)
                local at = historyAt
                task.defer(function()
                    setText(if at > 0 then hist[#hist - at + 1] else "")
                    historyAt = at
                end)
            elseif #flat > 0 then
                sel = if key == Enum.KeyCode.Down then sel % #flat + 1 else (sel - 2) % #flat + 1
                paintSelection()
            end
        end
    end)
    if closeBtn then
        jan:Connect(closeBtn.Activated, close)
    end
    for id, b in panelButtons do
        jan:Connect(b.Activated, function()
            deps.openPanel(id)
        end)
    end

    return {
        frame = root,
        input = input,
        open = function(prefill: string?)
            isOpen = true
            root.Visible = true
            fitHeight()
            local needsKeyboard = not touch or (prefill ~= nil and prefill ~= "")
            setText(prefill or "", needsKeyboard)
        end,
        close = close,
        isOpen = function()
            return isOpen
        end,
        refresh = function()
            if not isOpen then
                return
            end
            local pos = results.CanvasPosition
            local keepSel = sel
            render()
            sel = math.clamp(keepSel, 1, math.max(#flat, 1))
            if not touch then
                paintSelection()
            end
            results.CanvasPosition = pos
        end,
        text = function()
            return text
        end,
    }
end

return Spotlight
