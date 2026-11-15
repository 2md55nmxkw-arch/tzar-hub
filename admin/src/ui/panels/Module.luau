--!strict
-- A game module's panel, built from its spec: presets, sections with on-counts, a dense grid of
-- checks, the section's numbers and choices, a search across the module and the run controls.
-- Desktop: a 760px window. Touch: a drawer between the thumbstick and the jump button.

local UserInputService = game:GetService("UserInputService")

local Common = require("./Common")
local Controls = require("../Controls")
local Create = require("../Create")
local Drag = require("../Drag")
local FillBar = require("../FillBar")
local Format = require("../Format")
local Janitor = require("../../core/Janitor")
local Theme = require("../Theme")
local Types = require("../../Types")

local C, F, LINE, S = Theme.C, Theme.F, Theme.LINE, Theme.SIZE
local new, corner, pad, list = Create.new, Create.corner, Create.pad, Create.list

type Feature = Types.Feature

export type Deps = Common.Deps

export type ModulePanel = {
    frame: Frame,
    open: () -> (),
    close: () -> (),
    isOpen: () -> boolean,
}

local ON_BG = Color3.fromHex("2a1416")
local PRESET_ON = Color3.fromHex("3b1a1d")

local ModulePanel = {}

function ModulePanel.new(
    layer: Instance,
    jan: Janitor.Janitor,
    deps: Deps,
    mod: string
): ModulePanel
    local touch = Theme.touch
    local M, t, store = deps.modules, deps.t, deps.store
    local spec = M:Get(mod) :: Types.GameModuleSpec
    local W = if touch then S.panelTouch else 760
    local CELL = if touch then 40 else 34
    local function key(suffix: string): string
        return "m." .. mod .. "." .. suffix
    end

    local frame = new("Frame", {
        Name = "Module/" .. mod,
        Size = UDim2.fromOffset(W, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.surface,
        Visible = false,
        Active = true,
        Parent = layer,
    }, { corner(if touch then S.card else S.window), Create.stroke(LINE.strong), list("y", 0) })
    Create.shadow(frame, Theme.SHADOW.window)

    local section = spec.sections[1]
    local query = ""
    local isOpen = false
    local bodyJan = Janitor.new()
    jan:Add(bodyJan)

    -- Header
    local header = new("Frame", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, if touch then 48 else 50),
        LayoutOrder = 1,
        Active = true,
        Parent = frame,
    }, { pad(14, 10) })
    local hl = new(
        "Frame",
        { BackgroundTransparency = 1, Size = UDim2.fromScale(0.6, 1), Parent = header },
        { list("x", 9) }
    )
    Controls.logo(hl, 15).LayoutOrder = 1
    Create.text(
        { text = t(key("title")), size = 14, font = F.semibold, auto = true },
        { LayoutOrder = 2, Parent = hl }
    )
    if spec.badge then
        local tint = Color3.fromHex(spec.badgeColor or "ff9c48")
        local badge = Create.text(
            { text = spec.badge, size = 10.5, font = F.medium, color = tint, auto = true },
            {
                Size = UDim2.fromOffset(0, 20),
                BackgroundTransparency = 0.84,
                BackgroundColor3 = tint,
                LayoutOrder = 3,
                Parent = hl,
            }
        )
        corner(5).Parent = badge
        pad(7, 7).Parent = badge
    end
    local count = Create.text(
        { text = "", size = 10.5, font = F.mono, color = C.text3, auto = true },
        { LayoutOrder = 4, Parent = hl }
    )
    local hr = new("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.fromScale(0.4, 1),
        Parent = header,
    })
    local hrl = list("x", 6)
    hrl.HorizontalAlignment = Enum.HorizontalAlignment.Right
    hrl.Parent = hr
    local search = new("Frame", {
        Name = "Search",
        BackgroundColor3 = C.track,
        Size = UDim2.fromOffset(if touch then 150 else 200, if touch then 34 else 30),
        LayoutOrder = 1,
        Parent = hr,
    }, { corner(S.radius), pad(10, 8) })
    Controls.glyph("search", search, 13, C.text3).Position = UDim2.new(0, 0, 0.5, -6)
    local searchBox = new("TextBox", {
        Name = "Query",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(20, 0),
        Size = UDim2.new(1, -20, 1, 0),
        Text = "",
        PlaceholderText = t("md.search"),
        PlaceholderColor3 = C.text3,
        TextColor3 = C.text1,
        TextSize = 12.5,
        FontFace = F.regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        AutoLocalize = false,
        Parent = search,
    })
    local close = Controls.iconButton(hr, "x")
    close.LayoutOrder = 2

    -- Presets: a swipeable strip on touch; on desktop chips wrap onto more lines, since the mouse
    -- wheel cannot scroll sideways and chips past the edge would be out of reach.
    local presets: GuiObject
    if touch then
        presets = new("ScrollingFrame", {
            Name = "Presets",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 44),
            CanvasSize = UDim2.fromScale(0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.X,
            ScrollingDirection = Enum.ScrollingDirection.X,
            ScrollBarThickness = 0,
            LayoutOrder = 2,
            Parent = frame,
        }, { pad(14, 14, 0, 10), list("x", 6) })
    else
        presets = new("Frame", {
            Name = "Presets",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 2,
            Parent = frame,
        }, { pad(14, 14, 6, 10) })
        new("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Wraps = true,
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Center,
            Parent = presets,
        })
    end
    Controls.hairline(frame, 3)

    -- Body
    local body = new("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, if touch then 0 else 360),
        AutomaticSize = if touch then Enum.AutomaticSize.Y else Enum.AutomaticSize.None,
        LayoutOrder = 4,
        Parent = frame,
    })
    local NAV = if touch then 0 else 170
    local nav: ScrollingFrame? = nil
    local tabs: ScrollingFrame? = nil
    if touch then
        tabs = new("ScrollingFrame", {
            Name = "Sections",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 44),
            CanvasSize = UDim2.fromScale(0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.X,
            ScrollingDirection = Enum.ScrollingDirection.X,
            ScrollBarThickness = 0,
            Parent = body,
        }, { pad(10, 10, 6, 4), list("x", 6) })
    else
        nav = new("ScrollingFrame", {
            Name = "Sections",
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Size = UDim2.new(0, NAV, 1, 0),
            CanvasSize = UDim2.fromScale(0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = C.text3,
            Parent = body,
        }, { pad(8, 8, 10, 10), list("y", 2) })
        new("Frame", {
            BackgroundColor3 = C.white,
            BackgroundTransparency = LINE.default,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(NAV, 0),
            Size = UDim2.new(0, 1, 1, 0),
            Parent = body,
        })
    end
    local content = new("ScrollingFrame", {
        Name = "Content",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(if touch then 0 else NAV + 1, if touch then 44 else 0),
        Size = if touch then UDim2.fromScale(1, 0) else UDim2.new(1, -NAV - 1, 1, 0),
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.text3,
        Parent = body,
    }, {
        pad(if touch then 10 else 14, if touch then 10 else 14, if touch then 4 else 12, 12),
        list("y", 6),
    })
    if touch then
        -- The drawer stays between the thumbstick and the jump button: the grid scrolls past that.
        Create.fitScroll(content, function(): number
            return 190
        end)
        content.Position = UDim2.fromOffset(0, 0)
        -- Touch: tabs above the content in a column.
        list("y", 0).Parent = body
        if tabs then
            tabs.LayoutOrder = 1
        end
        content.LayoutOrder = 2
    end

    -- Run controls
    local runRow: Frame? = nil
    local runDot: Frame, runText: TextLabel, runTime: TextLabel, runBar: Frame, runStart: TextButton, runStop: TextButton
    if spec.runner then
        Controls.hairline(frame, 5)
        local r = new("Frame", {
            Name = "Run",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, if touch then 50 else 48),
            LayoutOrder = 6,
            Parent = frame,
        }, { pad(14, 10), list("x", 10) })
        runRow = r
        runDot = new("Frame", {
            Size = UDim2.fromOffset(8, 8),
            BackgroundColor3 = C.text3,
            LayoutOrder = 1,
            Parent = r,
        }, { corner(4) })
        runText = Create.text(
            { text = "", size = 13, font = F.medium, auto = true },
            { LayoutOrder = 2, Parent = r }
        )
        runTime = Create.text(
            { text = "", size = 11, font = F.mono, color = C.text3, auto = true },
            { LayoutOrder = 3, Parent = r }
        )
        local prog = new("Frame", {
            Size = UDim2.fromOffset(if touch then 70 else 140, 4),
            BackgroundColor3 = C.control,
            LayoutOrder = 4,
            ClipsDescendants = true,
            Parent = r,
        }, { corner(2) })
        runBar = new(
            "Frame",
            { Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.ok, Parent = prog },
            { corner(2) }
        )
        local sp = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(0, 1),
            LayoutOrder = 5,
            Parent = r,
        })
        pcall(function()
            new("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = sp })
        end)
        runStart = Controls.button(r, t("md.start"), "accent", "zap")
        runStart.LayoutOrder = 6
        runStop = Controls.button(r, t("md.stop"), "ghost")
        runStop.LayoutOrder = 7
    end

    local function updateRun()
        if not runRow then
            return
        end
        local run = M:Run(mod)
        local state = run.state
        runDot.BackgroundColor3 = if state == "running"
            then C.ok
            elseif state == "paused" then Color3.fromHex("f5b544")
            else C.text3
        local status = run.status
        if status == "" then
            status = if state == "idle" then t(key("run")) else t("md." .. state)
        end
        runText.Text = Create.marked(status, nil)
        local secs = math.floor(run.elapsed())
        runTime.Text = if state == "idle"
            then ""
            else string.format("%02d:%02d", secs // 60, secs % 60)
        runBar.Size = UDim2.fromScale(run.progress, 1)
        local label = runStart:FindFirstChild("Label") :: TextLabel?
        if label then
            label.Text = if state == "running"
                then t("md.pause")
                elseif state == "paused" then t("md.resume")
                else t("md.start")
        end
        runStop.Visible = state ~= "idle"
    end

    local function clear(f: Instance)
        for _, c in f:GetChildren() do
            if c:IsA("GuiObject") then
                c:Destroy()
            end
        end
    end

    local function grid(
        parent: Instance,
        order: number,
        cols: number,
        n: number,
        h: number
    ): { Frame }
        local cells: { Frame } = {}
        local rows = math.ceil(n / cols)
        for r = 1, rows do
            local row = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, h),
                LayoutOrder = order + r / 100,
                Parent = parent,
            }, { list("x", 6) })
            for c = 1, cols do
                if (r - 1) * cols + c > n then
                    break
                end
                table.insert(
                    cells,
                    new("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1 / cols, -6 * (cols - 1) / cols, 1, 0),
                        LayoutOrder = c,
                        Parent = row,
                    })
                )
            end
        end
        return cells
    end

    local function checkCell(cell: Frame, f: Feature)
        local on = M:IsOn(mod, f.id)
        local b = new("TextButton", {
            Name = "Check/" .. f.id,
            Text = "",
            AutoButtonColor = false,
            BackgroundColor3 = if on then ON_BG else C.track,
            Size = UDim2.fromScale(1, 1),
            Parent = cell,
        }, { corner(S.radius), pad(10, 8) })
        Create.text(
            { text = t(key("f." .. f.id)), size = 12.5 },
            { Size = UDim2.new(1, -26, 1, 0), Parent = b }
        )
        local ck = Controls.check(b)
        ck.frame.AnchorPoint = Vector2.new(1, 0.5)
        ck.frame.Position = UDim2.fromScale(1, 0.5)
        ck.set(on)
        bodyJan:Connect(b.Activated, function()
            task.spawn(function()
                local ok, msg = M:Set(mod, f.id, not M:IsOn(mod, f.id))
                if not ok and msg then
                    deps.toast("error", msg)
                end
            end)
        end)
    end

    local function paramCell(cell: Frame, f: Feature)
        if f.kind == "number" then
            local bar = FillBar.new(cell, {
                height = CELL,
                min = f.min or 0,
                max = f.max or 100,
                step = f.step or 1,
                default = f.default,
                scroll = content,
                jan = bodyJan,
                title = function()
                    return t(key("f." .. f.id))
                end,
                format = function(v: number)
                    return Format.value(v)
                end,
                value = function()
                    return tonumber(M:Value(mod, f.id)) or f.default or 0
                end,
                active = function()
                    return M:IsOn(mod, f.id)
                end,
                enabled = function()
                    return true
                end,
                commit = function(v: number)
                    task.spawn(M.Set, M, mod, f.id, v)
                end,
            })
            bar.frame.Name = "Param/" .. f.id
            bodyJan:Connect(bar.frame.MouseButton2Click, function()
                task.spawn(M.Set, M, mod, f.id, nil)
            end)
            return
        end
        -- Choice: tap cycles the options, right-click (or the last option) turns it off.
        local on = M:IsOn(mod, f.id)
        local b = new("TextButton", {
            Name = "Param/" .. f.id,
            Text = "",
            AutoButtonColor = false,
            BackgroundColor3 = if on then ON_BG else C.track,
            Size = UDim2.fromScale(1, 1),
            Parent = cell,
        }, { corner(S.radius), pad(12, 8) })
        Create.text(
            { text = t(key("f." .. f.id)), size = 12.5, color = C.text3 },
            { Size = UDim2.fromScale(0.5, 1), Parent = b }
        )
        local v = M:Value(mod, f.id)
        Create.text({
            text = t(key("o." .. tostring(v))),
            size = 12.5,
            color = if on then C.text1 else C.text2,
            x = Enum.TextXAlignment.Right,
        }, {
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.new(1, -18, 0, 0),
            Size = UDim2.new(0.5, -18, 1, 0),
            Parent = b,
        })
        local chev = Controls.glyph("chevron-down", b, 13, C.text3)
        chev.AnchorPoint = Vector2.new(1, 0.5)
        chev.Position = UDim2.fromScale(1, 0.5)
        bodyJan:Connect(b.Activated, function()
            local opts = f.options or {}
            local i = table.find(opts, M:Value(mod, f.id)) or 0
            local nextV = if M:IsOn(mod, f.id) then opts[i % #opts + 1] else opts[math.max(i, 1)]
            if M:IsOn(mod, f.id) and i == #opts then
                nextV = nil
            end
            task.spawn(M.Set, M, mod, f.id, nextV)
        end)
        bodyJan:Connect(b.MouseButton2Click, function()
            task.spawn(M.Set, M, mod, f.id, nil)
        end)
    end

    local renderBody: () -> ()

    local function renderPresets()
        clear(presets)
        if not touch then
            Controls.eyebrow(presets, t("md.presets")).LayoutOrder = 0
        end
        for i, p in M:Presets(mod) do
            local active = M:PresetActive(mod, p.id)
            local name = p.name or t(key("p." .. p.id))
            local n = 0
            for _ in p.values do
                n += 1
            end
            local chip = new("TextButton", {
                Name = "Preset/" .. p.id,
                Text = "",
                AutoButtonColor = false,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromOffset(0, if touch then 34 else 30),
                BackgroundColor3 = if active then PRESET_ON else C.control,
                LayoutOrder = i,
                Parent = presets,
            }, { corner(S.radius), pad(10, 10), list("x", 6) })
            if active then
                new("Frame", {
                    Size = UDim2.fromOffset(6, 6),
                    BackgroundColor3 = C.accent,
                    LayoutOrder = 1,
                    Parent = chip,
                }, { corner(3) })
            end
            Create.text(
                { text = Create.marked(name, nil), size = 12.5, font = F.medium, auto = true },
                { LayoutOrder = 2, Parent = chip }
            )
            Create.text(
                { text = tostring(n), size = 10.5, font = F.mono, color = C.text3, auto = true },
                { LayoutOrder = 3, Parent = chip }
            )
            if deps.isPinned("preset:" .. mod .. ":" .. p.id) then
                Controls.glyph("star", chip, 11, C.accent).LayoutOrder = 4
            end
            bodyJan:Connect(chip.Activated, function()
                task.spawn(M.TogglePreset, M, mod, p.id)
            end)
            -- Right-click: pin to the dock (user presets: delete with Shift held).
            bodyJan:Connect(chip.MouseButton2Click, function()
                if not p.builtin and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    M:DeletePreset(mod, p.id)
                else
                    deps.togglePin("preset:" .. mod .. ":" .. p.id)
                    renderPresets()
                end
            end)
        end
        local save = new("TextButton", {
            Name = "SavePreset",
            Text = "",
            AutoButtonColor = false,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromOffset(0, if touch then 34 else 30),
            BackgroundTransparency = 1,
            LayoutOrder = 90,
            Parent = presets,
        }, { corner(S.radius), Create.stroke(LINE.strong), pad(10, 10), list("x", 5) })
        Controls.glyph("plus", save, 12, C.text2).LayoutOrder = 1
        Create.text(
            { text = t("md.save"), size = 12.5, color = C.text2, auto = true },
            { LayoutOrder = 2, Parent = save }
        )
        bodyJan:Connect(save.Activated, function()
            local n = #(store.data.modules[mod] and store.data.modules[mod].presets or {}) + 1
            M:SavePreset(mod, t("md.my_preset", n))
            deps.toast("ok", t("md.saved"))
        end)
        local off = Controls.button(presets, t("md.all_off"), "ghost")
        off.LayoutOrder = 91
        bodyJan:Connect(off.Activated, function()
            task.spawn(M.AllOff, M, mod)
        end)
    end

    local function renderSections()
        local holder: Instance = if touch then tabs :: ScrollingFrame else nav :: ScrollingFrame
        clear(holder)
        for i, s in spec.sections do
            local on, total = M:Count(mod, s)
            local selected = s == section and query == ""
            local b = new("TextButton", {
                Name = "Section/" .. s,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = C.control,
                BackgroundTransparency = if selected then 0 else 1,
                AutomaticSize = if touch then Enum.AutomaticSize.X else Enum.AutomaticSize.None,
                Size = if touch then UDim2.fromOffset(0, 34) else UDim2.new(1, 0, 0, 34),
                LayoutOrder = i,
                Parent = holder,
            }, { corner(S.radius), pad(10, 10), list("x", 8) })
            Create.text({
                text = t(key("s." .. s)),
                size = 13,
                font = F.medium,
                color = if selected then C.text1 else C.text2,
                auto = true,
            }, {
                LayoutOrder = 1,
                Parent = b,
            })
            if not touch then
                local sp = new("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(0, 1),
                    LayoutOrder = 2,
                    Parent = b,
                })
                pcall(function()
                    new("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = sp })
                end)
            end
            local cnt = Create.text({
                text = on .. "/" .. total,
                size = 10.5,
                font = F.mono,
                color = if on > 0 then Color3.fromHex("ff8a93") else C.text3,
                auto = true,
            }, {
                Size = UDim2.fromOffset(0, 18),
                BackgroundTransparency = if on > 0 then 0.84 else 1,
                BackgroundColor3 = C.accent,
                LayoutOrder = 3,
                Parent = b,
            })
            corner(4).Parent = cnt
            pad(5, 5).Parent = cnt
            bodyJan:Connect(b.Activated, function()
                section = s
                query = ""
                searchBox.Text = ""
                renderBody()
            end)
        end
        if touch and tabs then
            local allOn = select(1, M:Count(mod, section)) == 0
            local b = Controls.button(
                tabs,
                if allOn then t("md.section_on") else t("md.section_off"),
                "plain"
            )
            b.LayoutOrder = 99
            b.Size = UDim2.fromOffset(0, 34)
            bodyJan:Connect(b.Activated, function()
                task.spawn(M.SetSection, M, mod, section, allOn)
            end)
        end
    end

    local function matchesQuery(f: Feature): boolean
        if query == "" then
            return f.section == section
        end
        local title = string.lower(t(key("f." .. f.id)))
        return string.find(title, string.lower(query), 1, true) ~= nil
            or string.find(string.lower(f.id), string.lower(query), 1, true) ~= nil
    end

    local function renderContent()
        clear(content)
        local toggles: { Feature } = {}
        local params: { Feature } = {}
        for _, f in spec.features do
            if matchesQuery(f) then
                table.insert(if f.kind == "toggle" then toggles else params, f)
            end
        end
        local order = 1
        if not touch then
            local head = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 34),
                LayoutOrder = order,
                Parent = content,
            })
            local hlist = new(
                "Frame",
                { BackgroundTransparency = 1, Size = UDim2.fromScale(0.6, 1), Parent = head },
                { list("x", 8) }
            )
            local titleText = if query == ""
                then t(key("s." .. section))
                else t("md.found", #toggles + #params)
            Create.text(
                { text = Create.marked(titleText, nil), size = 20, font = F.medium, auto = true },
                { LayoutOrder = 1, Parent = hlist }
            )
            if query == "" then
                local on, total = M:Count(mod, section)
                Create.text({
                    text = t("md.of", on, total),
                    size = 10.5,
                    font = F.mono,
                    color = C.text3,
                    auto = true,
                }, { LayoutOrder = 2, Parent = hlist })
                local hb = new("Frame", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.fromScale(1, 0.5),
                    Size = UDim2.fromScale(0.4, 1),
                    Parent = head,
                })
                local hbl = list("x", 6)
                hbl.HorizontalAlignment = Enum.HorizontalAlignment.Right
                hbl.Parent = hb
                local allOn = Controls.button(hb, t("md.section_on"), "plain")
                allOn.LayoutOrder = 1
                local allOff = Controls.button(hb, t("md.section_off"), "plain")
                allOff.LayoutOrder = 2
                bodyJan:Connect(allOn.Activated, function()
                    task.spawn(M.SetSection, M, mod, section, true)
                end)
                bodyJan:Connect(allOff.Activated, function()
                    task.spawn(M.SetSection, M, mod, section, false)
                end)
            end
        end
        order += 1
        local cols = 3
        for i, cell in grid(content, order, cols, #toggles, CELL) do
            checkCell(cell, toggles[i])
        end
        order += 1
        if #params > 0 then
            local eb = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                LayoutOrder = order,
                Parent = content,
            }, { pad(2, 2, 6, 0) })
            Controls.eyebrow(eb, t("md.params"))
            order += 1
            for i, cell in
                grid(
                    content,
                    order,
                    if touch then 1 else cols,
                    #params,
                    if touch then S.rowTouch else CELL
                )
            do
                paramCell(cell, params[i])
            end
        end
        if #toggles + #params == 0 then
            Create.text(
                { text = t("ui.nothing"), size = 13, color = C.text3 },
                { Size = UDim2.new(1, 0, 0, 30), LayoutOrder = order + 1, Parent = content }
            )
        end
    end

    renderBody = function()
        bodyJan:Cleanup()
        local on, total = M:Count(mod)
        count.Text = t("md.of", on, total)
        renderPresets()
        renderSections()
        renderContent()
        updateRun()
    end

    -- Wiring
    jan:Connect(close.Activated, function()
        isOpen = false
        frame.Visible = false
    end)
    jan:Connect(searchBox:GetPropertyChangedSignal("Text"), function()
        query = searchBox.Text
        if isOpen then
            renderBody()
        end
    end)
    if runRow then
        jan:Connect(runStart.Activated, function()
            local state = M:Run(mod).state
            if state == "running" then
                M:Pause(mod)
            else
                M:Start(mod)
            end
        end)
        jan:Connect(runStop.Activated, function()
            M:Stop(mod)
        end)
    end
    -- Switching a whole section fires one change per feature: redraw once after them.
    local queued = false
    jan:Add(M.Changed:Connect(function(changed: string, what: string)
        if changed ~= mod or not isOpen then
            return
        end
        if what == "run" then
            updateRun()
        elseif not queued then
            queued = true
            task.defer(function()
                queued = false
                if isOpen and frame.Parent then
                    renderBody()
                end
            end)
        end
    end))
    -- Tick the run clock once a second while the panel is open.
    local ticking = true
    jan:Defer(function()
        ticking = false
    end)
    task.spawn(function()
        while ticking do
            task.wait(1)
            if ticking and isOpen and M:Run(mod).state ~= "idle" then
                updateRun()
            end
        end
    end)

    Drag.attach(header, frame, jan, function(x: number, y: number)
        if not touch then
            store.data.panels["module:" .. mod] = { x = x, y = y }
            store:Save()
        end
    end)

    return {
        frame = frame,
        open = function()
            isOpen = true
            frame.Visible = true
            renderBody()
            task.defer(function()
                local vp = Drag.viewport()
                local saved = store.data.panels["module:" .. mod]
                if touch then
                    Drag.place(frame, (vp.X - W) / 2, 0)
                elseif saved then
                    Drag.place(frame, saved.x, saved.y)
                else
                    Drag.place(frame, (vp.X - W) / 2, 96)
                end
            end)
        end,
        close = function()
            isOpen = false
            frame.Visible = false
        end,
        isOpen = function()
            return isOpen
        end,
    }
end

return ModulePanel
