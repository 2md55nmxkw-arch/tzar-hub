--!strict
-- Key binds: the list (key, line, mode, remove) and a form for a new one. A hold bind runs the
-- line on press and turns it off on release.

local Common = require("./Common")
local Controls = require("../Controls")
local Create = require("../Create")
local Panel = require("../Panel")
local Rows = require("../spot/Rows")
local Theme = require("../Theme")

local C, F, S = Theme.C, Theme.F, Theme.SIZE
local new = Create.new

local Binds = {}

function Binds.build(panel: Panel.Panel, deps: Common.Deps, rebuild: () -> ())
    panel.clear()
    local store, t = deps.store, deps.t
    local body = panel.body
    local order = 0
    local function nextOrder(): number
        order += 1
        return order
    end

    local keys = {}
    for k in store.data.binds do
        table.insert(keys, k)
    end
    table.sort(keys)
    if #keys == 0 then
        Create.text({ text = t("bd.empty"), size = 12, color = C.text3 }, {
            Size = UDim2.new(1, 0, 0, 26),
            LayoutOrder = nextOrder(),
            Parent = body,
        })
    end
    for _, key in keys do
        local row = Panel.row(body, nextOrder())
        Controls.kbd(row, key).LayoutOrder = 1
        Create.text(
            { text = store.data.binds[key], size = 12.5, font = F.mono, auto = true },
            { LayoutOrder = 2, Parent = row }
        )
        if store.data.holdBinds[key] then
            Create.text(
                { text = t("bd.hold_tag"), size = 10, color = C.text3, auto = true },
                { LayoutOrder = 3, Parent = row }
            )
        end
        Panel.spacer(row, 4)
        local x = Controls.iconButton(row, "x", 24)
        x.LayoutOrder = 5
        panel.content:Connect(x.Activated, function()
            store.data.binds[key] = nil
            store.data.holdBinds[key] = nil
            store:Save("binds")
            rebuild()
        end)
    end

    Rows.group(body, t("bd.new"), nextOrder())
    local state = { key = nil :: string?, hold = false }
    local function field(label: string): (TextButton, Frame)
        local f = Panel.row(body, nextOrder(), if Theme.touch then S.rowTouch else 36)
        Create.text(
            { text = label, size = 12, color = C.text3, auto = true },
            { LayoutOrder = 1, Parent = f }
        )
        Panel.spacer(f, 2)
        local right = new("Frame", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromScale(0, 1),
            LayoutOrder = 3,
            Parent = f,
        }, {
            Create.list("x", 6),
        })
        return f, right
    end

    local _, cmdRight = field(t("bd.command"))
    local cmdBox = new("TextBox", {
        Name = "Command",
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(150, 24),
        Text = "",
        PlaceholderText = "fly",
        PlaceholderColor3 = C.text3,
        TextColor3 = C.text1,
        TextSize = 12.5,
        FontFace = F.mono,
        TextXAlignment = Enum.TextXAlignment.Right,
        ClearTextOnFocus = false,
        AutoLocalize = false,
        Parent = cmdRight,
    })

    local keyRow, keyRight = field(t("bd.key"))
    local keyText = Create.text(
        { text = t("ui.press_key"), size = 12.5, font = F.mono, color = C.text2, auto = true },
        { Parent = keyRight }
    )
    panel.content:Connect(keyRow.Activated, function()
        keyText.Text = t("ui.press_key")
        keyRow.BackgroundColor3 = C.trackHover
        local stroke = Create.stroke(0)
        stroke.Color = C.accent
        stroke.Parent = keyRow
        deps.capture(function(k: Enum.KeyCode)
            stroke:Destroy()
            keyRow.BackgroundColor3 = C.track
            if k == Enum.KeyCode.Escape then
                return
            end
            state.key = k.Name
            keyText.Text = k.Name
            keyText.TextColor3 = C.text1
        end)
    end)

    local modeRow, modeRight = field(t("bd.mode"))
    local modeText = Create.text(
        { text = t("bd.press"), size = 12.5, font = F.mono, auto = true },
        { Parent = modeRight }
    )
    panel.content:Connect(modeRow.Activated, function()
        state.hold = not state.hold
        modeText.Text = if state.hold then t("bd.hold") else t("bd.press")
    end)

    local add = Controls.button(body, t("bd.add"), "accent", "plus")
    add.AutomaticSize = Enum.AutomaticSize.None
    add.Size = UDim2.new(1, 0, 0, if Theme.touch then 40 else 34)
    add.LayoutOrder = nextOrder()
    local l = add:FindFirstChildOfClass("UIListLayout")
    if l then
        l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    end
    panel.content:Connect(add.Activated, function()
        local line = string.gsub(cmdBox.Text, "^%s*(.-)%s*$", "%1")
        local key = state.key
        if line == "" or not key then
            deps.toast("error", t("bd.need"))
            return
        end
        store.data.binds[key] = line
        store.data.holdBinds[key] = if state.hold then true else nil
        store:Save("binds")
        rebuild()
    end)
end

return Binds
