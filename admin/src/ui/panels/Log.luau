--!strict
-- The hub log, newest at the bottom; errors in red. New lines appear while the panel is open.

local Common = require("./Common")
local Create = require("../Create")
local Log = require("../../core/Log")
local Panel = require("../Panel")
local Theme = require("../Theme")

local C, F = Theme.C, Theme.F

local LogPanel = {}

function LogPanel.build(panel: Panel.Panel, deps: Common.Deps)
    panel.clear()
    local n = 0
    local function add(e: Log.Entry)
        n += 1
        local color = if e.level == "error"
            then C.accent
            elseif e.level == "warn" then C.text1
            else C.text2
        Create.text({
            text = os.date("%H:%M:%S", e.time) .. "  " .. Create.marked(e.text, nil),
            size = 11,
            font = F.mono,
            color = color,
        }, {
            Size = UDim2.fromScale(1, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            TextWrapped = true,
            TextTruncate = Enum.TextTruncate.None,
            LayoutOrder = n,
            Parent = panel.body,
        })
    end
    for _, e in deps.log:Entries() do
        add(e)
    end
    if n == 0 then
        Create.text({ text = deps.t("set.log_empty"), size = 12, color = C.text3 }, {
            Size = UDim2.new(1, 0, 0, 24),
            Parent = panel.body,
        })
    end
    panel.content:Add(deps.log.Added:Connect(add))
end

return LogPanel
