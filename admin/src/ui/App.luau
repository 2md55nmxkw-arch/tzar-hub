--!strict
-- Puts the interface together: command bar, dock, launcher, floating panels, toasts. Everything
-- except toasts sits in one layer, so the hide key shows and hides TZAR in one go.

local AvatarPanel = require("./panels/Avatar")
local Binds = require("./panels/Binds")
local Commands = require("./panels/Commands")
local Common = require("./panels/Common")
local Create = require("./Create")
local Dock = require("./Dock")
local EmoteWheel = require("./EmoteWheel")
local Format = require("./Format")
local I18n = require("../core/I18n")
local Janitor = require("../core/Janitor")
local Launcher = require("./Launcher")
local Log = require("../core/Log")
local LogPanel = require("./panels/Log")
local ModulePanel = require("./panels/Module")
local Modules = require("../core/Modules")
local Panel = require("./Panel")
local Pins = require("./panels/Pins")
local Registry = require("../core/Registry")
local Settings = require("./panels/Settings")
local Spotlight = require("./Spotlight")
local Store = require("../core/Store")
local Theme = require("./Theme")
local Toasts = require("./Toasts")
local Types = require("../Types")

local new = Create.new

type Spec = Types.CommandSpec

export type Deps = {
    parent: Instance,
    registry: Registry.Registry,
    modules: Modules.Modules,
    store: Store.Store,
    i18n: I18n.I18n,
    log: Log.Log,
    t: (key: string, ...any) -> string,
    run: (line: string) -> (boolean, string?),
    capture: (fn: ((Enum.KeyCode) -> ())?) -> (),
    info: () -> string,
    unload: () -> (),
}

export type App = {
    toast: (kind: Types.Toast, text: string) -> (),
    notify: (title: string, text: string) -> (),
    openBar: (prefill: string?) -> (),
    closeBar: () -> (),
    toggleAll: () -> (),
    openPanel: (id: string) -> (),
    closePanel: (id: string) -> (),
    openView: (view: string) -> (),
    -- A game module's panel; "" opens the first module for this place.
    openModule: (id: string) -> (),
    closeModule: (id: string) -> (),
    -- The avatar panel ("look" | "catalog" | "emotes") and the emote wheel.
    openAvatar: (tab: string?) -> (),
    closeAvatar: () -> (),
    toggleWheel: () -> (),
    -- The dock's slider card for a value command (what a long press opens).
    popover: (name: string) -> (),
    visible: () -> boolean,
    gui: () -> ScreenGui,
    rebuild: () -> (),
    debug: () -> { [string]: any },
    destroy: () -> (),
}

local App = {}

function App.new(deps: Deps): App
    local reg, store, t = deps.registry, deps.store, deps.t
    local jan = Janitor.new()
    local uiJan = Janitor.new()
    jan:Add(uiJan)

    local gui: ScreenGui
    local layer: Frame
    local toasts: Toasts.Toasts
    local bar: Spotlight.Spotlight
    local dock: Dock.Dock
    local launcher: TextButton?
    local panels: { [string]: Panel.Panel } = {}
    local modulePanels: { [string]: ModulePanel.ModulePanel } = {}
    local avatar: AvatarPanel.AvatarPanel? = nil
    local wheel: EmoteWheel.Wheel? = nil
    local shown = true

    local function toast(kind: Types.Toast, text: string)
        if toasts then
            toasts.show(kind, text)
        end
    end

    -- Runs off the caller's thread so a slow command never freezes the UI.
    local function runLine(line: string)
        task.spawn(function()
            local ok, msg = deps.run(line)
            if not ok and msg then
                toast("error", msg)
            end
        end)
    end

    local function isPinned(name: string): boolean
        return table.find(store.data.pins, name) ~= nil
    end
    local function togglePin(name: string)
        local pins = store.data.pins
        local i = table.find(pins, name)
        if i then
            table.remove(pins, i)
        elseif #pins < Pins.MAX then
            table.insert(pins, name)
        end
        store:Save("pins")
        if dock then
            dock.rebuild()
        end
    end

    local function setShown(v: boolean)
        shown = v
        if layer then
            layer.Visible = v
        end
        if not v and bar then
            bar.close()
        end
    end

    local openBar: (prefill: string?) -> ()
    local openPanel: (id: string) -> ()
    local closePanel: (id: string) -> ()
    local openModule: (id: string) -> ()

    local openAvatar: (tab: string?) -> ()

    -- Phones show one thing at a time; this closes the module and avatar panels.
    local function closeModules(except: string?)
        for id, p in modulePanels do
            if id ~= except then
                p.close()
            end
        end
        if except ~= "avatar" and avatar then
            avatar.close()
        end
    end

    -- Dock tap / favourite tile: the quickest sensible thing for each kind of command.
    local function quick(spec: Spec)
        local name = spec.name
        local req = Format.requiredArg(spec)
        if spec.kind == "value" then
            if reg:IsActive(name) then
                runLine("un" .. name)
                return
            end
            local last = reg:Args(name)[1]
            if last ~= nil then
                runLine(name .. " " .. Format.value(last))
            elseif dock then
                dock.popover(spec)
            end
        elseif req then
            openBar(name .. " ")
        else
            runLine(name)
        end
    end

    local common: Common.Deps

    local function panelDeps(): Common.Deps
        return common
    end

    local builders: { [string]: (p: Panel.Panel) -> () } = {
        commands = function(p)
            Commands.build(p, panelDeps())
        end,
        binds = function(p)
            Binds.build(p, panelDeps(), function()
                openPanel("binds")
            end)
        end,
        settings = function(p)
            Settings.build(p, panelDeps(), function()
                openPanel("log")
            end)
        end,
        log = function(p)
            LogPanel.build(p, panelDeps())
        end,
        pins = function(p)
            Pins.build(p, panelDeps(), function()
                closePanel("pins")
            end)
        end,
    }

    local function origin(id: string): (vp: Vector2, w: number) -> (number, number)
        return function(vp: Vector2, w: number)
            if id == "commands" then
                return 40, 150
            elseif id == "pins" then
                return 16, 132
            elseif id == "log" then
                return (vp.X - w) / 2, 140
            end
            return vp.X - w - 40, 150
        end
    end

    local function getPanel(id: string): Panel.Panel
        local p = panels[id]
        if p then
            return p
        end
        p = Panel.new(layer, uiJan, {
            id = id,
            title = t("pn." .. id),
            width = if id == "settings" or id == "binds"
                then 300
                elseif id == "log" then 420
                else nil,
            store = store,
            origin = origin(id),
        })
        panels[id] = p
        return p
    end

    openPanel = function(id: string)
        if not shown then
            setShown(true)
        end
        if Theme.touch then
            -- One thing at a time on a phone: the panel takes the bar's place.
            bar.close()
            closeModules(nil)
            for other, p in panels do
                if other ~= id then
                    p.close()
                end
            end
        end
        local p = getPanel(id)
        builders[id](p)
        p.open()
    end

    closePanel = function(id: string)
        local p = panels[id]
        if p then
            p.close()
        end
    end

    openBar = function(prefill: string?)
        if not shown then
            setShown(true)
        end
        if Theme.touch then
            closeModules(nil)
            for _, p in panels do
                p.close()
            end
        end
        bar.open(prefill)
    end

    openModule = function(id: string)
        local mods = deps.modules
        if id == "" then
            local first = mods:Available()[1]
            if not first then
                toast("info", t("md.none"))
                return
            end
            id = first.id
        end
        if not mods:Get(id) then
            toast("error", t("arg.module", id))
            return
        end
        if not shown then
            setShown(true)
        end
        bar.close()
        if Theme.touch then
            for _, p in panels do
                p.close()
            end
        end
        closeModules(id)
        local p = modulePanels[id]
        if not p then
            p = ModulePanel.new(layer, uiJan, common, id)
            modulePanels[id] = p
        end
        p.open()
    end

    openAvatar = function(tab: string?)
        if not shown then
            setShown(true)
        end
        bar.close()
        if Theme.touch then
            for _, p in panels do
                p.close()
            end
            closeModules("avatar")
        end
        local a = avatar
        if not a then
            -- Loads the avatar module the first time; a broken module must not break the UI.
            local ok, made = pcall(AvatarPanel.new, layer, uiJan, common)
            if not ok then
                deps.log:Error("avatar panel: " .. tostring(made))
                toast("error", t("err.failed", "avatar", tostring(made)))
                return
            end
            a = made
            avatar = made
        end
        (a :: AvatarPanel.AvatarPanel).open(tab)
    end

    local function build()
        local reopen: { string } = {}
        for id, p in panels do
            if p.isOpen() then
                table.insert(reopen, id)
            end
        end
        local reopenModules: { string } = {}
        for id, p in modulePanels do
            if p.isOpen() then
                table.insert(reopenModules, id)
            end
        end
        local reopenAvatar = avatar ~= nil and (avatar :: AvatarPanel.AvatarPanel).isOpen()
        uiJan:Cleanup()
        table.clear(panels)
        table.clear(modulePanels)
        avatar = nil
        wheel = nil
        launcher = nil

        gui = new("ScreenGui", {
            Name = "TZAR_Admin",
            ResetOnSpawn = false,
            IgnoreGuiInset = true,
            DisplayOrder = 1001,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        })
        uiJan:Add(gui)
        layer = new("Frame", {
            Name = "Layer",
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Visible = shown,
            Parent = gui,
        })
        toasts = Toasts.new(gui, store)

        common = {
            registry = reg,
            store = store,
            t = t,
            run = runLine,
            capture = deps.capture,
            openPanel = function(id: string)
                openPanel(id)
            end,
            isPinned = isPinned,
            togglePin = togglePin,
            modules = deps.modules,
            openModule = function(id: string)
                openModule(id)
            end,
            toast = toast,
            i18n = deps.i18n,
            log = deps.log,
            info = deps.info,
            setLang = function(code: string)
                if deps.i18n:SetLang(code) then
                    store.data.lang = code
                    store:Save("lang")
                end
            end,
            openBar = function(prefill: string?)
                openBar(prefill)
            end,
            unload = deps.unload,
        }

        dock = Dock.new(
            layer,
            uiJan,
            (
                    setmetatable({
                        quick = quick,
                        openPins = function()
                            openPanel("pins")
                        end,
                    }, { __index = common }) :: any
                ) :: Dock.Deps
        )

        if not Theme.touch then
            launcher = Launcher.new(layer, uiJan, t("pn.commands"), ";", function()
                openBar(nil)
            end)
        end

        bar = Spotlight.new(
            layer,
            uiJan,
            (setmetatable({ quick = quick }, { __index = common }) :: any) :: Spotlight.Deps
        )

        wheel = EmoteWheel.new(layer, uiJan, common)

        gui.Parent = deps.parent
        for _, id in reopen do
            openPanel(id)
        end
        for _, id in reopenModules do
            openModule(id)
        end
        if reopenAvatar then
            openAvatar(nil)
        end
    end

    build()

    jan:Add(reg.StateChanged:Connect(function()
        bar.refresh()
        local p = panels.commands
        if p and p.isOpen() then
            builders.commands(p)
        end
    end))
    jan:Add(deps.i18n.Changed:Connect(function()
        build()
    end))

    local function debugInfo(): { [string]: any }
        local open: { [string]: Frame } = {}
        for id, p in panels do
            open[id] = p.frame
        end
        local mods: { [string]: Frame } = {}
        for id, p in modulePanels do
            mods[id] = p.frame
        end
        local a = avatar
        local w = wheel
        return {
            gui = gui,
            layer = layer,
            bar = bar.frame,
            barOpen = bar.isOpen(),
            barInput = bar.input,
            dock = dock.frame,
            launcher = launcher,
            panels = open,
            modules = mods,
            avatar = if a then a.frame else nil,
            wheel = if w then w.frame() else nil,
            shown = shown,
        }
    end

    return {
        toast = toast,
        notify = function(title: string, text: string)
            if toasts then
                toasts.notify(title, text)
            end
        end,
        openBar = function(prefill: string?)
            openBar(prefill)
        end,
        closeBar = function()
            bar.close()
        end,
        toggleAll = function()
            setShown(not shown)
        end,
        openPanel = function(id: string)
            openPanel(id)
        end,
        closePanel = function(id: string)
            closePanel(id)
        end,
        openView = function(view: string)
            if view == "avatar" then
                openAvatar(nil)
                return
            elseif view == "emotewheel" then
                local w = wheel
                if w then
                    w.toggle()
                end
                return
            end
            if
                view == "settings"
                or view == "log"
                or view == "binds"
                or view == "commands"
                or view == "pins"
            then
                openPanel(view)
            else
                openPanel("commands")
            end
        end,
        openModule = function(id: string)
            openModule(id)
        end,
        openAvatar = function(tab: string?)
            openAvatar(tab)
        end,
        closeAvatar = function()
            local a = avatar
            if a then
                a.close()
            end
        end,
        toggleWheel = function()
            local w = wheel
            if w then
                w.toggle()
            end
        end,
        closeModule = function(id: string)
            local p = modulePanels[id]
            if p then
                p.close()
            end
        end,
        popover = function(name: string)
            local spec = reg:Get(name)
            if spec then
                dock.popover(spec)
            end
        end,
        visible = function()
            return shown
        end,
        gui = function()
            return gui
        end,
        rebuild = build,
        debug = debugInfo,
        destroy = function()
            jan:Cleanup()
        end,
    }
end

return App
