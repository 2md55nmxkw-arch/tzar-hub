--!strict
-- Every command by category. Tap runs a toggle or a plain action; anything that needs a value or
-- an argument opens in the command bar. A red dot marks what is on.

local Common = require("./Common")
local Controls = require("../Controls")
local Create = require("../Create")
local Format = require("../Format")
local Panel = require("../Panel")
local Rows = require("../spot/Rows")
local Theme = require("../Theme")

local C = Theme.C
local new, corner = Create.new, Create.corner

local CATEGORIES = { "avatar", "character", "camera", "visual", "utility", "hub" }

local Commands = {}

function Commands.build(panel: Panel.Panel, deps: Common.Deps)
    panel.clear()
    local reg, t = deps.registry, deps.t
    local order = 0
    for _, cat in CATEGORIES do
        local first = true
        for _, spec in reg.specs do
            if spec.category ~= cat then
                continue
            end
            if first then
                order += 1
                Rows.group(panel.body, t("cat." .. cat), order)
                first = false
            end
            order += 1
            local name = spec.name
            local on = reg:IsActive(name)
            local disabled = reg:IsDisabled(name) or reg:Missing(spec) ~= nil
            local row = Panel.row(panel.body, order, if Theme.touch then 40 else 32)
            row.BackgroundTransparency = 1
            new("Frame", {
                Name = "Dot",
                Size = UDim2.fromOffset(5, 5),
                BackgroundColor3 = if on then C.accent else C.control,
                LayoutOrder = 1,
                Parent = row,
            }, { corner(3) })
            local label = name
            if spec.kind == "value" and on then
                label ..= " " .. Format.value(reg:Value(name))
            end
            Create.text({
                text = label,
                size = 13,
                color = if disabled then C.text3 elseif on then C.text1 else C.text2,
                auto = true,
            }, {
                LayoutOrder = 2,
                Parent = row,
            })
            Panel.spacer(row, 3)
            local key = Rows.keyFor(deps.store, name)
            if key and not Theme.touch then
                Controls.kbd(row, key).LayoutOrder = 4
            elseif deps.isPinned(name) then
                Controls.glyph("star", row, 12, C.text3).LayoutOrder = 4
            end
            Create.text({ text = t("c." .. name), size = 10, color = C.text3, auto = true }, {
                LayoutOrder = 5,
                Parent = row,
            })
            panel.content:Connect(row.MouseEnter, function()
                row.BackgroundTransparency = 0
            end)
            panel.content:Connect(row.MouseLeave, function()
                row.BackgroundTransparency = 1
            end)
            panel.content:Connect(row.Activated, function()
                local req = Format.requiredArg(spec)
                if spec.kind == "value" or req then
                    deps.openBar(name .. " ")
                else
                    deps.run(name)
                end
            end)
            panel.content:Connect(row.MouseButton2Click, function()
                deps.openBar(name)
            end)
        end
    end
end

return Commands
