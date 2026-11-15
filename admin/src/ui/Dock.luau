--!strict
-- Pinned commands in a strip at the top edge, clear of the thumbstick and the jump button.
-- Tap = on/off; hold (or right-click) a value command = big slider with ± and presets; the logo
-- opens the command bar and drags the strip; "+" chooses what is pinned.

local Common = require("./panels/Common")
local Controls = require("./Controls")
local Create = require("./Create")
local Drag = require("./Drag")
local FillBar = require("./FillBar")
local Format = require("./Format")
local Janitor = require("../core/Janitor")
local Modules = require("../core/Modules")
local Theme = require("./Theme")
local Types = require("../Types")

local C, F, LINE, S = Theme.C, Theme.F, Theme.LINE, Theme.SIZE
local new, corner, pad, list = Create.new, Create.corner, Create.pad, Create.list

type Spec = Types.CommandSpec

export type Deps = Common.Deps & {
    quick: (spec: Spec) -> (),
    openPins: () -> (),
}

export type Dock = {
    frame: Frame,
    rebuild: () -> (),
    popover: (spec: Spec) -> (),
    closePopover: () -> (),
    setVisible: (v: boolean) -> (),
}

local LONG_PRESS = 0.45

local Dock = {}

local function presetsFor(spec: Spec): { number }
    if spec.presets then
        return spec.presets
    end
    local a1 = spec.args and spec.args[1]
    local d = spec.default or (a1 and a1.min) or 1
    local hi = (a1 and a1.max) or d * 10
    local out: { number } = {}
    for _, k in { 1, 2, 4, 6, 9, 12 } do
        local v = math.min(hi, math.floor(d * k + 0.5))
        if not table.find(out, v) then
            table.insert(out, v)
        end
    end
    return out
end

function Dock.new(layer: Instance, jan: Janitor.Janitor, deps: Deps): Dock
    local reg, t, store = deps.registry, deps.t, deps.store
    local touch = Theme.touch
    local cellW, cellH = if touch then 60 else 56, if touch then 54 else 50

    local frame = new("Frame", {
        Name = "Dock",
        AutomaticSize = Enum.AutomaticSize.XY,
        Size = UDim2.fromOffset(0, 0),
        BackgroundColor3 = C.surface,
        BackgroundTransparency = 0.06,
        Active = true,
        Parent = layer,
    }, { corner(S.card), Create.stroke(LINE.strong), pad(6, 6, 6, 6), list("x", 6) })
    Create.shadow(frame, Theme.SHADOW.pop)

    local cellsJan = Janitor.new()
    jan:Add(cellsJan)
    local popJan = Janitor.new()
    jan:Add(popJan)
    local pop: Frame? = nil
    local popFor: string? = nil

    local function placeDefault()
        local saved = store.data.dock
        if saved then
            Drag.place(frame, saved.x, saved.y)
        elseif touch then
            Drag.place(frame, 96, 8)
        else
            Drag.place(frame, 16, 66)
        end
    end

    local closePopover: () -> ()

    local function openPopover(spec: Spec)
        closePopover()
        local a1 = spec.args and spec.args[1]
        if not (a1 and a1.kind == "number") then
            deps.openBar(spec.name .. " ")
            return
        end
        local name = spec.name
        popFor = name
        local lo, hi = a1.min or 0, a1.max or 100
        local card = new("Frame", {
            Name = "Popover",
            Size = UDim2.fromOffset(if touch then 400 else 380, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = C.surface,
            Active = true,
            Parent = layer,
        }, { corner(S.card), Create.stroke(LINE.strong), pad(14, 14, 12, 14), list("y", 10) })
        Create.shadow(card, Theme.SHADOW.pop)
        pop = card

        local head = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 24),
            LayoutOrder = 1,
            Parent = card,
        })
        local titles = new(
            "Frame",
            { BackgroundTransparency = 1, Size = UDim2.new(1, -30, 1, 0), Parent = head },
            { list("x", 8) }
        )
        Create.text(
            { text = t("c." .. name), size = 14, font = F.medium, auto = true },
            { LayoutOrder = 1, Parent = titles }
        )
        if spec.default then
            Create.text({
                text = t("dk.default", Format.value(spec.default)),
                size = 12,
                color = C.text3,
                auto = true,
            }, {
                LayoutOrder = 2,
                Parent = titles,
            })
        end
        local x = Controls.iconButton(head, "x", 24)
        x.AnchorPoint = Vector2.new(1, 0)
        x.Position = UDim2.fromScale(1, 0)
        popJan:Connect(x.Activated, function()
            closePopover()
        end)

        local h = if touch then 52 else 46
        local ctl = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, h),
            LayoutOrder = 2,
            Parent = card,
        }, { list("x", 6) })
        local step = (a1.step or 1) * math.max(1, math.floor((hi - lo) / 100 + 0.5))
        local function nudge(delta: number)
            local cur = tonumber(reg:Value(name)) or spec.default or lo
            local v = math.clamp(cur + delta, lo, hi)
            deps.run(name .. " " .. Format.value(v))
        end
        local minus = Controls.iconButton(ctl, "minus", h, true)
        minus.LayoutOrder = 1
        local barHolder = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -2 * (h + 6), 1, 0),
            LayoutOrder = 2,
            Parent = ctl,
        })
        local bar = FillBar.new(barHolder, {
            height = h,
            min = lo,
            max = hi,
            step = a1.step or 1,
            default = spec.default,
            jan = popJan,
            title = function()
                return ""
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
                return true
            end,
            commit = function(v: number)
                deps.run(name .. " " .. Format.value(v))
            end,
        })
        local plus = Controls.iconButton(ctl, "plus", h, true)
        plus.LayoutOrder = 3
        popJan:Connect(minus.Activated, function()
            nudge(-step)
        end)
        popJan:Connect(plus.Activated, function()
            nudge(step)
        end)

        local presets = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, if touch then 40 else 34),
            LayoutOrder = 3,
            Parent = card,
        }, {
            list("x", 6),
        })
        local values = presetsFor(spec)
        for i, v in values do
            local current = reg:IsActive(name) and tonumber(reg:Value(name)) == v
            local b = new("TextButton", {
                Text = Format.value(v),
                AutoButtonColor = false,
                BackgroundColor3 = if current then Color3.fromHex("3b1a1d") else C.control,
                Size = UDim2.new(1 / #values, -6 * (#values - 1) / #values, 1, 0),
                TextSize = 12.5,
                FontFace = F.mono,
                TextColor3 = if current then C.accent else C.text1,
                LayoutOrder = i,
                AutoLocalize = false,
                Parent = presets,
            }, { corner(S.radius) })
            popJan:Connect(b.Activated, function()
                deps.run(name .. " " .. Format.value(v))
            end)
        end

        local foot = new("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            LayoutOrder = 4,
            Parent = card,
        })
        local reset = new("TextButton", {
            Text = t("dk.reset"),
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromScale(0, 1),
            TextSize = 13,
            FontFace = F.medium,
            TextColor3 = C.text2,
            AutoLocalize = false,
            Parent = foot,
        })
        local typeIt = reset:Clone()
        typeIt.Text = t("dk.type")
        typeIt.AnchorPoint = Vector2.new(1, 0)
        typeIt.Position = UDim2.fromScale(1, 0)
        typeIt.Parent = foot
        popJan:Connect(reset.Activated, function()
            deps.run("un" .. name)
        end)
        popJan:Connect(typeIt.Activated, function()
            closePopover()
            deps.openBar(name .. " ")
        end)

        popJan:Add(reg.StateChanged:Connect(function(changed: string)
            if changed == name then
                bar.refresh()
                for _, b in presets:GetChildren() do
                    if b:IsA("TextButton") then
                        local on = reg:IsActive(name)
                            and tonumber(reg:Value(name)) == tonumber(b.Text)
                        b.BackgroundColor3 = if on then Color3.fromHex("3b1a1d") else C.control
                        b.TextColor3 = if on then C.accent else C.text1
                    end
                end
            end
        end))

        task.defer(function()
            if card.Parent then
                -- Offsets, not AbsolutePosition: with IgnoreGuiInset the two differ by the top bar.
                Drag.place(
                    card,
                    frame.Position.X.Offset,
                    frame.Position.Y.Offset + frame.AbsoluteSize.Y + 8
                )
            end
        end)
    end

    closePopover = function()
        popJan:Cleanup()
        if pop then
            pop:Destroy()
            pop = nil
        end
        popFor = nil
    end

    local function cell(name: string, w: number): TextButton
        return new("TextButton", {
            Name = name,
            Text = "",
            AutoButtonColor = false,
            BackgroundColor3 = C.track,
            Size = UDim2.fromOffset(w, cellH),
            Parent = frame,
        }, { corner(S.radius) })
    end

    -- A pinned set of a game module: tap turns the whole set on or off, hold opens the module.
    local function presetCell(order: number, mod: string, pid: string)
        local M = deps.modules
        local preset: Modules.Preset? = nil
        for _, p in M:Presets(mod) do
            if p.id == pid then
                preset = p
            end
        end
        if not preset then
            return
        end
        local p = preset :: Modules.Preset
        local on = M:PresetActive(mod, pid)
        local b = cell("Pin/preset:" .. mod .. ":" .. pid, cellW)
        b.LayoutOrder = order
        b.BackgroundColor3 = if on then C.accent else C.track
        local inner = new(
            "Frame",
            { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = b },
            { pad(4, 4, 7, 6) }
        )
        local col = list("y", 4)
        col.HorizontalAlignment = Enum.HorizontalAlignment.Center
        col.VerticalAlignment = Enum.VerticalAlignment.Center
        col.Parent = inner
        Controls.glyph("sparkles", inner, 16, if on then C.white else C.text2).LayoutOrder = 1
        Create.text({
            text = Create.marked(M:PresetTitle(mod, p), nil),
            size = 10,
            color = if on then C.white else C.text2,
            x = Enum.TextXAlignment.Center,
        }, {
            Size = UDim2.new(1, 0, 0, 12),
            LayoutOrder = 2,
            Parent = inner,
        })
        local pressAt = 0
        local longFired = false
        cellsJan:Connect(b.InputBegan, function(io: InputObject)
            if
                io.UserInputType == Enum.UserInputType.Touch
                or io.UserInputType == Enum.UserInputType.MouseButton1
            then
                pressAt = os.clock()
                longFired = false
                local stamp = pressAt
                task.delay(LONG_PRESS, function()
                    if pressAt == stamp and b.Parent then
                        longFired = true
                        deps.openModule(mod)
                    end
                end)
            elseif io.UserInputType == Enum.UserInputType.MouseButton2 then
                deps.openModule(mod)
            end
        end)
        cellsJan:Connect(b.InputEnded, function(io: InputObject)
            if
                io.UserInputType == Enum.UserInputType.Touch
                or io.UserInputType == Enum.UserInputType.MouseButton1
            then
                pressAt = 0
            end
        end)
        cellsJan:Connect(b.Activated, function()
            if longFired then
                longFired = false
                return
            end
            task.spawn(M.TogglePreset, M, mod, pid)
        end)
    end

    local function rebuild()
        cellsJan:Cleanup()
        for _, c in frame:GetChildren() do
            if c:IsA("GuiObject") then
                c:Destroy()
            end
        end
        -- Logo: opens the bar; dragging it moves the dock.
        local open = cell("Open", if touch then 44 else 40)
        open.BackgroundTransparency = 1
        open.LayoutOrder = 0
        local lg = Controls.logo(open, 18)
        lg.AnchorPoint = Vector2.new(0.5, 0.5)
        lg.Position = UDim2.fromScale(0.5, 0.5)
        local drag = Drag.attach(open, frame, cellsJan, function(x: number, y: number)
            store.data.dock = { x = x, y = y }
            store:Save()
        end)
        cellsJan:Connect(open.Activated, function()
            if not drag.moved() then
                deps.openBar(nil)
            end
        end)

        for i, name in store.data.pins do
            local mod, pid = string.match(name, "^preset:([^:]+):(.+)$")
            if mod and pid then
                presetCell(i, mod, pid)
                continue
            end
            local spec = reg:Get(name)
            if not spec or reg:IsDisabled(name) then
                continue
            end
            local on = reg:IsActive(name)
            local b = cell("Pin/" .. name, cellW)
            b.LayoutOrder = i
            b.BackgroundColor3 = if on then C.accent else C.track
            local inner = new(
                "Frame",
                { BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), Parent = b },
                { pad(4, 4, 7, 6) }
            )
            local col = list("y", 4)
            col.HorizontalAlignment = Enum.HorizontalAlignment.Center
            col.VerticalAlignment = Enum.VerticalAlignment.Center
            col.Parent = inner
            if spec.kind == "value" then
                Create.text({
                    text = Format.value(reg:Value(name)),
                    size = 13,
                    font = F.mono,
                    color = if on then C.white else C.text1,
                    x = Enum.TextXAlignment.Center,
                }, { Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 1, Parent = inner })
            else
                Controls.glyph(spec.icon or "command", inner, 16, if on then C.white else C.text2).LayoutOrder =
                    1
            end
            Create.text({
                text = t("c." .. name),
                size = 10,
                color = if on then C.white else C.text2,
                x = Enum.TextXAlignment.Center,
            }, {
                Size = UDim2.new(1, 0, 0, 12),
                LayoutOrder = 2,
                Parent = inner,
            })

            local pressAt = 0
            local longFired = false
            cellsJan:Connect(b.InputBegan, function(io: InputObject)
                if
                    io.UserInputType == Enum.UserInputType.Touch
                    or io.UserInputType == Enum.UserInputType.MouseButton1
                then
                    pressAt = os.clock()
                    longFired = false
                    local stamp = pressAt
                    task.delay(LONG_PRESS, function()
                        if pressAt == stamp and b.Parent then
                            longFired = true
                            if spec.kind == "value" then
                                openPopover(spec)
                            else
                                deps.openBar(name)
                            end
                        end
                    end)
                elseif io.UserInputType == Enum.UserInputType.MouseButton2 then
                    if spec.kind == "value" then
                        openPopover(spec)
                    else
                        deps.openBar(name)
                    end
                end
            end)
            cellsJan:Connect(b.InputEnded, function(io: InputObject)
                if
                    io.UserInputType == Enum.UserInputType.Touch
                    or io.UserInputType == Enum.UserInputType.MouseButton1
                then
                    pressAt = 0
                end
            end)
            cellsJan:Connect(b.Activated, function()
                if longFired then
                    longFired = false
                    return
                end
                if popFor == name then
                    closePopover()
                    return
                end
                deps.quick(spec)
            end)
        end

        local add = cell("Add", if touch then 40 else 34)
        add.LayoutOrder = 99
        add.BackgroundTransparency = 1
        Create.stroke(LINE.strong).Parent = add
        local pg = Controls.glyph("plus", add, 14, C.text2)
        pg.AnchorPoint = Vector2.new(0.5, 0.5)
        pg.Position = UDim2.fromScale(0.5, 0.5)
        cellsJan:Connect(add.Activated, deps.openPins)
    end

    rebuild()
    task.defer(placeDefault)
    -- A whole section or set switching fires many changes; rebuild once after them.
    local queued = false
    local function soon()
        if queued then
            return
        end
        queued = true
        task.defer(function()
            queued = false
            if frame.Parent then
                rebuild()
            end
        end)
    end
    jan:Add(reg.StateChanged:Connect(function()
        rebuild()
    end))
    jan:Add(deps.modules.Changed:Connect(function(_mod: string, what: string)
        if what ~= "run" then
            soon()
        end
    end))

    return {
        frame = frame,
        rebuild = rebuild,
        popover = openPopover,
        closePopover = function()
            closePopover()
        end,
        setVisible = function(v: boolean)
            frame.Visible = v
            if not v then
                closePopover()
            end
        end,
    }
end

return Dock
