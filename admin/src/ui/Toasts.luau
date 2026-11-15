--!strict
-- Pill toasts at the bottom centre (between the thumbstick and jump on phones), and one
-- notification card bottom-right with Teto for the welcome.

local SoundService = game:GetService("SoundService")

local Assets = require("./Assets")
local Create = require("./Create")
local Store = require("../core/Store")
local Theme = require("./Theme")
local Types = require("../Types")

local C, F, LINE, S = Theme.C, Theme.F, Theme.LINE, Theme.SIZE
local new, corner, pad, list, tween =
    Create.new, Create.corner, Create.pad, Create.list, Create.tween

export type Toasts = {
    show: (kind: Types.Toast, text: string) -> (),
    notify: (title: string, text: string) -> (),
}

local MAX = 3
local LIFE = 3
local LIFE_ERROR = 5
local LIFE_NOTE = 7
local PING = "rbxasset://sounds/electronicpingshort.wav"

local Toasts = {}

function Toasts.new(layer: Instance, store: Store.Store): Toasts
    local stack = new("Frame", {
        Name = "Toasts",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -20),
        Size = UDim2.fromOffset(420, 200),
        Parent = layer,
    })
    local l = list("y", 6, Enum.VerticalAlignment.Bottom)
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.Parent = stack
    local order = 0

    local function fade(card: CanvasGroup, life: number)
        tween(card, { GroupTransparency = 0 })
        task.delay(life, function()
            if card.Parent then
                tween(card, { GroupTransparency = 1 })
                task.wait(0.2)
                card:Destroy()
            end
        end)
    end

    local function ping()
        if store.data.sound then
            local s = Instance.new("Sound")
            s.SoundId = PING
            s.Volume = 0.35
            pcall(SoundService.PlayLocalSound, SoundService, s)
            task.delay(2, function()
                s:Destroy()
            end)
        end
    end

    local function show(kind: Types.Toast, text: string)
        order += 1
        local items: { GuiObject } = {}
        for _, c in stack:GetChildren() do
            if c:IsA("CanvasGroup") then
                table.insert(items, c)
            end
        end
        table.sort(items, function(a: GuiObject, b: GuiObject)
            return a.LayoutOrder < b.LayoutOrder
        end)
        for i = 1, #items - MAX + 1 do
            items[i]:Destroy()
        end
        local card = new("CanvasGroup", {
            Name = "Toast",
            BackgroundColor3 = C.surface,
            AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2.fromOffset(0, 0),
            LayoutOrder = order,
            GroupTransparency = 1,
            Parent = stack,
        }, { corner(10), Create.stroke(LINE.default), pad(12, 14, 7, 7), list("x", 8) })
        new("Frame", {
            Size = UDim2.fromOffset(6, 6),
            BackgroundColor3 = if kind == "error"
                then C.accent
                elseif kind == "ok" then C.accent
                else C.text2,
            LayoutOrder = 1,
            Parent = card,
        }, { corner(3) })
        Create.text({ text = Create.marked(text, nil), size = 13, auto = true }, {
            Size = UDim2.fromOffset(0, 18),
            TextWrapped = true,
            LayoutOrder = 2,
            Parent = card,
        })
        new("UISizeConstraint", { MaxSize = Vector2.new(420, 80), Parent = card })
        fade(card, if kind == "error" then LIFE_ERROR else LIFE)
        if kind == "error" then
            ping()
        end
    end

    local note: CanvasGroup? = nil
    local function notify(title: string, text: string)
        if note then
            note:Destroy()
        end
        local card = new("CanvasGroup", {
            Name = "Notification",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -20, 1, -20),
            BackgroundColor3 = C.surface,
            AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2.fromOffset(0, 0),
            GroupTransparency = 1,
            Parent = layer,
        }, { corner(S.card), Create.stroke(LINE.strong), pad(10, 14, 10, 10), list("x", 10) })
        note = card
        local teto = Assets.image("teto")
        if teto then
            new("ImageLabel", {
                Name = "Teto",
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(40, 40),
                Image = teto,
                ScaleType = Enum.ScaleType.Fit,
                LayoutOrder = 1,
                Parent = card,
            })
        end
        local col = new("Frame", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.XY,
            Size = UDim2.fromOffset(0, 0),
            LayoutOrder = 2,
            Parent = card,
        }, {
            list("y", 2),
        })
        Create.text(
            { text = Create.marked(title, nil), size = 13, font = F.medium, auto = true },
            { Size = UDim2.fromOffset(0, 18), LayoutOrder = 1, Parent = col }
        )
        Create.text(
            { text = Create.marked(text, nil), size = 12, color = C.text2, auto = true },
            { Size = UDim2.fromOffset(0, 16), LayoutOrder = 2, Parent = col }
        )
        fade(card, LIFE_NOTE)
        ping()
    end

    return { show = show, notify = notify }
end

return Toasts
