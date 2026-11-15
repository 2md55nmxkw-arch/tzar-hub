--!strict
-- Settings: language, keys, behaviour, the log, turning the hub off, and what it runs on.

local Common = require("./Common")
local Controls = require("../Controls")
local Create = require("../Create")
local I18n = require("../../core/I18n")
local Panel = require("../Panel")
local Rows = require("../spot/Rows")
local Theme = require("../Theme")

local C, F, S = Theme.C, Theme.F, Theme.SIZE
local new, corner, pad, list = Create.new, Create.corner, Create.pad, Create.list

local Settings = {}

function Settings.build(panel: Panel.Panel, deps: Common.Deps, openLog: () -> ())
    panel.clear()
    local store, t = deps.store, deps.t
    local body = panel.body
    local order = 0
    local function nextOrder(): number
        order += 1
        return order
    end

    Rows.group(body, t("st.lang"), nextOrder())
    local seg = new("Frame", {
        Name = "Langs",
        BackgroundColor3 = C.track,
        Size = UDim2.new(1, 0, 0, if Theme.touch then 40 else 34),
        LayoutOrder = nextOrder(),
        Parent = body,
    }, { corner(S.radius), pad(3, 3, 3, 3), list("x", 3) })
    for i, code in I18n.LANGS do
        local on = deps.i18n.lang == code
        local b = new("TextButton", {
            Text = string.upper(code),
            AutoButtonColor = false,
            BackgroundColor3 = C.accent,
            BackgroundTransparency = if on then 0 else 1,
            Size = UDim2.new(1 / #I18n.LANGS, -3, 1, 0),
            TextSize = 12,
            FontFace = F.mono,
            TextColor3 = if on then C.white else C.text2,
            LayoutOrder = i,
            AutoLocalize = false,
            Parent = seg,
        }, { corner(6) })
        panel.content:Connect(b.Activated, function()
            deps.setLang(code)
        end)
    end

    local function row(label: string): (TextButton, Frame)
        local r = Panel.row(body, nextOrder(), if Theme.touch then S.rowTouch else 36)
        Create.text({ text = label, size = 13, auto = true }, { LayoutOrder = 1, Parent = r })
        Panel.spacer(r, 2)
        local right = new("Frame", {
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromScale(0, 1),
            LayoutOrder = 3,
            Parent = r,
        }, { list("x", 6) })
        return r, right
    end

    if not Theme.touch then
        Rows.group(body, t("st.keys"), nextOrder())
        for _, field in { { "st.bar_key", "paletteKey" }, { "st.hide_key", "toggleKey" } } do
            local r, right = row(t(field[1]))
            local cap = Controls.kbd(right, (store.data :: any)[field[2]])
            panel.content:Connect(r.Activated, function()
                cap.Text = t("ui.press_key")
                deps.capture(function(k: Enum.KeyCode)
                    if k ~= Enum.KeyCode.Escape then
                        (store.data :: any)[field[2]] = k.Name
                        store:Save(field[2])
                    end
                    cap.Text = (store.data :: any)[field[2]]
                end)
            end)
        end
    end

    Rows.group(body, t("st.behavior"), nextOrder())
    for _, field in { { "st.chat", "chatCommands" }, { "st.sound", "sound" } } do
        local r, right = row(t(field[1]))
        local sw = Controls.switch(right)
        sw.set((store.data :: any)[field[2]] == true)
        panel.content:Connect(r.Activated, function()
            local v = not (store.data :: any)[field[2]];
            (store.data :: any)[field[2]] = v
            store:Save(field[2])
            sw.set(v)
        end)
    end
    local logRow, logRight = row(t("st.log"))
    local errors = 0
    for _, e in deps.log:Entries() do
        if e.level == "error" then
            errors += 1
        end
    end
    if errors > 0 then
        Create.text({
            text = t("st.errors", errors),
            size = 10.5,
            font = F.mono,
            color = C.accent,
            auto = true,
        }, {
            LayoutOrder = 1,
            Parent = logRight,
        })
    end
    Controls.glyph("arrow-right", logRight, 14, C.text3).LayoutOrder = 2
    panel.content:Connect(logRow.Activated, openLog)

    local off = Controls.button(body, t("st.unload"), "danger", "log-out")
    off.AutomaticSize = Enum.AutomaticSize.None
    off.Size = UDim2.new(1, 0, 0, if Theme.touch then 40 else 34)
    off.LayoutOrder = nextOrder()
    local l = off:FindFirstChildOfClass("UIListLayout")
    if l then
        l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    end
    panel.content:Connect(off.Activated, deps.unload)

    Create.text({ text = deps.info(), size = 10, font = F.mono, color = C.text3 }, {
        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.None,
        LayoutOrder = nextOrder(),
        Parent = body,
    })
end

return Settings
