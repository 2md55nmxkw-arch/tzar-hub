--!strict
-- TZAR's emote wheel: "." once it is switched on in the avatar panel (the Roblox wheel is hidden
-- then), the emotewheel command, or the round button above the jump button on a phone.
-- 1–8 play a slot, Q / E or the mouse wheel turn the page, Esc or a click outside closes it.

local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")

local Common = require("./panels/Common")
local Controls = require("./Controls")
local Create = require("./Create")
local Janitor = require("../core/Janitor")
local Theme = require("./Theme")

local C, F, LINE = Theme.C, Theme.F, Theme.LINE
local new, corner, pad, list = Create.new, Create.corner, Create.pad, Create.list

export type Wheel = {
    open: () -> (),
    close: () -> (),
    toggle: () -> (),
    isOpen: () -> boolean,
    frame: () -> GuiObject?,
}

type Emote = { id: number, name: string, fromOutfit: boolean }

local PER_PAGE = 8
local KEYS: { [Enum.KeyCode]: number } = {
    [Enum.KeyCode.One] = 1,
    [Enum.KeyCode.Two] = 2,
    [Enum.KeyCode.Three] = 3,
    [Enum.KeyCode.Four] = 4,
    [Enum.KeyCode.Five] = 5,
    [Enum.KeyCode.Six] = 6,
    [Enum.KeyCode.Seven] = 7,
    [Enum.KeyCode.Eight] = 8,
    [Enum.KeyCode.KeypadOne] = 1,
    [Enum.KeyCode.KeypadTwo] = 2,
    [Enum.KeyCode.KeypadThree] = 3,
    [Enum.KeyCode.KeypadFour] = 4,
    [Enum.KeyCode.KeypadFive] = 5,
    [Enum.KeyCode.KeypadSix] = 6,
    [Enum.KeyCode.KeypadSeven] = 7,
    [Enum.KeyCode.KeypadEight] = 8,
}

local EmoteWheel = {}

local function setRobloxWheel(enabled: boolean)
    pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.EmotesMenu, enabled)
end

function EmoteWheel.new(layer: Instance, jan: Janitor.Janitor, deps: Common.Deps): Wheel
    local touch = Theme.touch
    local t, store = deps.t, deps.store
    local W = if touch then 344 else 440
    local SLOT = if touch then 72 else 84
    local RING = if touch then 124 else 158
    local CENTER = if touch then 128 else 168

    local overlay: GuiObject? = nil
    local isOpen = false
    local pageNo = 1
    local list_: { Emote } = {}
    local openJan = Janitor.new()
    jan:Add(openJan)

    -- The Roblox wheel stays hidden while ours is on; switched back when it goes off or TZAR unloads.
    local hidden = false
    local floatBtn: TextButton? = nil
    local toggle: () -> ()
    local function applySetting()
        local on = store.data.emoteWheel
        if on ~= hidden then
            setRobloxWheel(not on)
            hidden = on
        end
        if touch then
            if on and not floatBtn then
                local b = new("TextButton", {
                    Name = "EmoteButton",
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2.new(1, 1),
                    Position = UDim2.new(1, -100, 1, -186),
                    Size = UDim2.fromOffset(56, 56),
                    BackgroundColor3 = C.accent,
                    Parent = layer,
                }, { corner(28), list("y", 1, Enum.VerticalAlignment.Center) })
                local l = b:FindFirstChildOfClass("UIListLayout")
                if l then
                    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
                end
                Controls.glyph("sparkles", b, 18, C.white).LayoutOrder = 1
                Create.text({
                    text = t("avu.wheel_button"),
                    size = 9,
                    font = F.medium,
                    color = C.white,
                    x = Enum.TextXAlignment.Center,
                }, {
                    Size = UDim2.fromOffset(52, 11),
                    LayoutOrder = 2,
                    Parent = b,
                })
                jan:Connect(b.Activated, function()
                    toggle()
                end)
                floatBtn = b
            elseif not on and floatBtn then
                floatBtn:Destroy()
                floatBtn = nil
            end
        end
    end
    jan:Defer(function()
        if hidden then
            setRobloxWheel(true)
        end
    end)
    jan:Add(store.Changed:Connect(function(key: string)
        if key == "emoteWheel" then
            applySetting()
        end
    end))
    applySetting()

    local close: () -> ()

    local function play(e: Emote?)
        if e then
            deps.run("emote " .. e.id)
        end
        close()
    end

    local function render()
        openJan:Cleanup()
        local o = overlay
        if o then
            o:Destroy()
        end
        local root = new("TextButton", {
            Name = "EmoteWheel",
            Text = "",
            AutoButtonColor = false,
            BackgroundColor3 = C.black,
            BackgroundTransparency = 0.65,
            Size = UDim2.fromScale(1, 1),
            ZIndex = 20,
            Parent = layer,
        })
        overlay = root
        openJan:Add(root)
        openJan:Connect(root.Activated, function()
            close()
        end)
        local pages = math.max(1, math.ceil(#list_ / PER_PAGE))
        pageNo = math.clamp(pageNo, 1, pages)

        local wheel = new("Frame", {
            Name = "Wheel",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(W, W),
            BackgroundColor3 = C.surface,
            BackgroundTransparency = 0.08,
            Active = true,
            ZIndex = 21,
            Parent = root,
        }, { corner(W // 2), Create.stroke(LINE.default) })
        Create.shadow(wheel, Theme.SHADOW.window)

        local center = new("Frame", {
            Name = "Center",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(CENTER, CENTER),
            BackgroundColor3 = C.base,
            ZIndex = 22,
            Parent = wheel,
        }, {
            corner(CENTER // 2),
            Create.stroke(LINE.subtle),
            list("y", 6, Enum.VerticalAlignment.Center),
        })
        local cl = center:FindFirstChildOfClass("UIListLayout")
        if cl then
            cl.HorizontalAlignment = Enum.HorizontalAlignment.Center
        end
        local cName = Create.text({
            text = "",
            size = if touch then 16 else 20,
            font = F.semibold,
            x = Enum.TextXAlignment.Center,
        }, {
            Name = "Name",
            Size = UDim2.new(1, -20, 0, 24),
            ZIndex = 23,
            LayoutOrder = 1,
            Parent = center,
        })
        local cSub = Create.text({
            text = "",
            size = 10.5,
            font = F.mono,
            color = C.text3,
            x = Enum.TextXAlignment.Center,
        }, {
            Size = UDim2.new(1, -20, 0, 14),
            ZIndex = 23,
            LayoutOrder = 2,
            Parent = center,
        })
        local dots = new("Frame", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromOffset(0, 6),
            LayoutOrder = 3,
            Parent = center,
        }, { list("x", 5) })
        for i = 1, pages do
            new("Frame", {
                Size = UDim2.fromOffset(6, 6),
                BackgroundColor3 = if i == pageNo then C.accent else C.text3,
                ZIndex = 23,
                LayoutOrder = i,
                Parent = dots,
            }, { corner(3) })
        end

        local function show(i: number?)
            local e = if i then list_[(pageNo - 1) * PER_PAGE + i] else nil
            if e then
                cName.Text = Create.marked(e.name, nil)
                cSub.Text = t("avu.slot", i)
                    .. (if e.fromOutfit then " · " .. t("avu.from_outfit") else "")
            elseif #list_ == 0 then
                cName.Text = ""
                cSub.Text = t("avu.wheel_empty")
            else
                cName.Text = ""
                cSub.Text = if touch then t("avu.wheel_touch") else t("avu.page", pageNo, pages)
            end
        end

        for i = 1, PER_PAGE do
            local e = list_[(pageNo - 1) * PER_PAGE + i]
            local a = (i - 1) * math.pi / 4
            local b = new("TextButton", {
                Name = "Slot/" .. i,
                Text = "",
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.new(0.5, RING * math.sin(a), 0.5, -RING * math.cos(a)),
                Size = UDim2.fromOffset(SLOT, SLOT),
                BackgroundColor3 = C.surface,
                BackgroundTransparency = if e then 0 else 0.5,
                ZIndex = 22,
                Parent = wheel,
            }, {
                corner(SLOT // 2),
                Create.stroke(LINE.strong),
                pad(6, 6),
                list("y", 2, Enum.VerticalAlignment.Center),
            })
            local bl = b:FindFirstChildOfClass("UIListLayout")
            if bl then
                bl.HorizontalAlignment = Enum.HorizontalAlignment.Center
            end
            if e then
                new("ImageLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(if touch then 22 else 26, if touch then 22 else 26),
                    Image = string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", e.id),
                    ZIndex = 23,
                    LayoutOrder = 1,
                    Parent = b,
                })
                Create.text({
                    text = Create.marked(e.name, nil),
                    size = 11,
                    font = F.medium,
                    x = Enum.TextXAlignment.Center,
                }, {
                    Size = UDim2.new(1, 0, 0, 14),
                    ZIndex = 23,
                    LayoutOrder = 2,
                    Parent = b,
                })
            end
            Create.text({
                text = tostring(i),
                size = 9.5,
                font = F.mono,
                color = C.text3,
                x = Enum.TextXAlignment.Center,
            }, {
                Size = UDim2.new(1, 0, 0, 11),
                ZIndex = 23,
                LayoutOrder = 3,
                Parent = b,
            })
            openJan:Connect(b.MouseEnter, function()
                if e then
                    b.BackgroundColor3 = C.accent
                    show(i)
                end
            end)
            openJan:Connect(b.MouseLeave, function()
                b.BackgroundColor3 = C.surface
                show(nil)
            end)
            openJan:Connect(b.Activated, function()
                play(e)
            end)
        end
        show(nil)

        if not touch then
            for _, side in { { "Q", "arrow-left", -1 }, { "E", "arrow-right", 1 } } do
                local key, icon, dir = side[1] :: string, side[2] :: string, side[3] :: number
                local b = new("TextButton", {
                    Name = "Page" .. key,
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new(0.5, dir * (W / 2 + 48), 0.5, 0),
                    Size = UDim2.fromOffset(56, 72),
                    BackgroundColor3 = C.surface,
                    BackgroundTransparency = 0.08,
                    ZIndex = 21,
                    Parent = root,
                }, {
                    corner(12),
                    Create.stroke(LINE.default),
                    list("y", 6, Enum.VerticalAlignment.Center),
                })
                local l = b:FindFirstChildOfClass("UIListLayout")
                if l then
                    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
                end
                Controls.glyph(icon, b, 16, C.text2).LayoutOrder = 1
                Controls.kbd(b, key).LayoutOrder = 2
                openJan:Connect(b.Activated, function()
                    pageNo = (pageNo - 1 + dir) % pages + 1
                    render()
                end)
            end
            local hints = new("Frame", {
                Name = "Hints",
                AnchorPoint = Vector2.new(0.5, 0),
                Position = UDim2.new(0.5, 0, 0.5, W / 2 + 28),
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromOffset(0, 36),
                BackgroundColor3 = C.surface,
                BackgroundTransparency = 0.06,
                ZIndex = 21,
                Parent = root,
            }, { corner(10), Create.stroke(LINE.subtle), pad(14, 14), list("x", 8) })
            local n = 0
            for _, h in
                {
                    { "1–8", "avu.wheel_play" },
                    { "Q / E", "avu.wheel_page" },
                    { "⇅", "avu.wheel_scroll" },
                    { "Esc", "avu.wheel_close" },
                }
            do
                n += 1
                Controls.kbd(hints, h[1]).LayoutOrder = n
                n += 1
                Create.text(
                    { text = t(h[2]), size = 12, color = C.text2, auto = true },
                    { LayoutOrder = n, Parent = hints }
                )
            end
        end

        -- Swipe sideways on the ring to turn the page on a phone.
        local swipeFrom: Vector3? = nil
        openJan:Connect(wheel.InputBegan, function(io: InputObject)
            if io.UserInputType == Enum.UserInputType.Touch then
                swipeFrom = io.Position
            end
        end)
        openJan:Connect(wheel.InputEnded, function(io: InputObject)
            local from = swipeFrom
            if from and io.UserInputType == Enum.UserInputType.Touch then
                swipeFrom = nil
                local dx = io.Position.X - from.X
                if math.abs(dx) > 60 and pages > 1 then
                    pageNo = (pageNo - 1 + (if dx < 0 then 1 else -1)) % pages + 1
                    render()
                end
            end
        end)
    end

    local function open()
        if isOpen then
            return
        end
        local api: any = deps.registry:Api("avatar")
        if not api then
            return
        end
        list_ = api.Wheel()
        isOpen = true
        pageNo = 1
        render()
    end

    close = function()
        if not isOpen then
            return
        end
        isOpen = false
        openJan:Cleanup()
        overlay = nil
    end

    toggle = function()
        if isOpen then
            close()
        else
            task.spawn(open)
        end
    end

    jan:Connect(UserInputService.InputBegan, function(io: InputObject, processed: boolean)
        if processed or UserInputService:GetFocusedTextBox() then
            return
        end
        local kc = io.KeyCode
        if kc == Enum.KeyCode.Period and store.data.emoteWheel then
            toggle()
            return
        end
        if not isOpen then
            return
        end
        if kc == Enum.KeyCode.Escape then
            close()
        elseif kc == Enum.KeyCode.Q or kc == Enum.KeyCode.E then
            local pages = math.max(1, math.ceil(#list_ / PER_PAGE))
            pageNo = (pageNo - 1 + (if kc == Enum.KeyCode.E then 1 else -1)) % pages + 1
            render()
        else
            local slot = KEYS[kc]
            if slot then
                play(list_[(pageNo - 1) * PER_PAGE + slot])
            end
        end
    end)
    jan:Connect(UserInputService.InputChanged, function(io: InputObject)
        if isOpen and io.UserInputType == Enum.UserInputType.MouseWheel then
            local pages = math.max(1, math.ceil(#list_ / PER_PAGE))
            if pages > 1 then
                pageNo = (pageNo - 1 + (if io.Position.Z < 0 then 1 else -1)) % pages + 1
                render()
            end
        end
    end)

    return {
        open = function()
            task.spawn(open)
        end,
        close = function()
            close()
        end,
        toggle = function()
            toggle()
        end,
        isOpen = function()
            return isOpen
        end,
        frame = function()
            return overlay
        end,
    }
end

return EmoteWheel
