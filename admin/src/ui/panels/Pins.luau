--!strict
-- What sits on the dock: every command that runs without an argument, with a star to pin it.

local Common = require("./Common")
local Controls = require("../Controls")
local Create = require("../Create")
local Format = require("../Format")
local Panel = require("../Panel")
local Theme = require("../Theme")

local C, F = Theme.C, Theme.F

local Pins = {}

Pins.MAX = 6

function Pins.build(panel: Panel.Panel, deps: Common.Deps, done: () -> ())
    panel.clear()
    local reg, t, store = deps.registry, deps.t, deps.store
    panel.setTitle(t("pn.pins") .. "  " .. #store.data.pins .. "/" .. Pins.MAX)
    local order = 0
    for _, spec in reg.specs do
        if spec.category == "hub" or Format.requiredArg(spec) and spec.kind ~= "value" then
            continue
        end
        order += 1
        local name = spec.name
        local pinned = deps.isPinned(name)
        local row = Panel.row(panel.body, order)
        Controls.glyph(spec.icon or "command", row, 14, C.text2).LayoutOrder = 1
        Create.text(
            { text = t("c." .. name), size = 13, auto = true },
            { LayoutOrder = 2, Parent = row }
        )
        Create.text(
            { text = name, size = 10.5, font = F.mono, color = C.text3, auto = true },
            { LayoutOrder = 3, Parent = row }
        )
        Panel.spacer(row, 4)
        Controls.glyph("star", row, 16, if pinned then C.accent else C.text3).LayoutOrder = 5
        panel.content:Connect(row.Activated, function()
            if not pinned and #store.data.pins >= Pins.MAX then
                return
            end
            deps.togglePin(name)
            Pins.build(panel, deps, done)
        end)
    end
    -- Sets of the game modules for this place.
    local M = deps.modules
    for _, s in M:Available() do
        for _, p in M:Presets(s.id) do
            order += 1
            local key = "preset:" .. s.id .. ":" .. p.id
            local pinned = deps.isPinned(key)
            local row = Panel.row(panel.body, order)
            row.Name = "Row/" .. key
            Controls.glyph("sparkles", row, 14, C.text2).LayoutOrder = 1
            Create.text(
                { text = Create.marked(M:PresetTitle(s.id, p), nil), size = 13, auto = true },
                { LayoutOrder = 2, Parent = row }
            )
            Create.text({
                text = Create.marked(t("m." .. s.id .. ".title"), nil),
                size = 10.5,
                color = C.text3,
                auto = true,
            }, { LayoutOrder = 3, Parent = row })
            Panel.spacer(row, 4)
            Controls.glyph("star", row, 16, if pinned then C.accent else C.text3).LayoutOrder = 5
            panel.content:Connect(row.Activated, function()
                if not pinned and #store.data.pins >= Pins.MAX then
                    return
                end
                deps.togglePin(key)
                Pins.build(panel, deps, done)
            end)
        end
    end
    order += 1
    local ok = Controls.button(panel.body, t("dk.done"), "accent", "check")
    ok.AutomaticSize = Enum.AutomaticSize.None
    ok.Size = UDim2.new(1, 0, 0, if Theme.touch then 40 else 34)
    ok.LayoutOrder = order
    local l = ok:FindFirstChildOfClass("UIListLayout")
    if l then
        l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    end
    panel.content:Connect(ok.Activated, done)
end

return Pins
