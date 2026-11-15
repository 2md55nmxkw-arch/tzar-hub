--!strict
-- TZAR Hub Admin entry point: builds the core, the registry and the interface, and owns unload.

local T0 = os.clock()

local Players = game:GetService("Players")

if not game:IsLoaded() then
    game.Loaded:Wait()
end
while not Players.LocalPlayer do
    task.wait()
end

local Env = require("./platform/Env")

-- Running the script again replaces the old hub instead of stacking a second one.
local genv = Env.genv()
local previous = genv.TZAR_ADMIN
if type(previous) == "table" and type(previous.Unload) == "function" then
    pcall(previous.Unload)
end

local App = require("./ui/App")
local Binds = require("./core/Binds")
local Commands = require("./Commands")
local CtxTypes = require("./Ctx")
local HubImpl = require("./modules/hub/Impl")
local I18n = require("./core/I18n")
local Janitor = require("./core/Janitor")
local Log = require("./core/Log")
local Modules = require("./core/Modules")
local Registry = require("./core/Registry")
local Scheduler = require("./core/Scheduler")
local Store = require("./core/Store")
local Assets = require("./ui/Assets")
local Theme = require("./ui/Theme")

local lp = Players.LocalPlayer
local log = Log.new()
local hub = Janitor.new(function(msg: string)
    log:Error(msg)
end)
local store = Store.new()
local i18n = I18n.new(I18n.detect(store.data.lang))
for _, bundle in Commands.strings do
    i18n:Register(bundle)
end
local function t(key: string, ...: any): string
    return i18n:T(key, ...)
end

local scheduler = Scheduler.new()

local app: App.App? = nil
local unloaded = false
local readyMs = 0

local registry: Registry.Registry
local modules: Modules.Modules
local unload: () -> ()

local hooks: HubImpl.Hooks = {
    unload = function()
        unload()
    end,
    setDisabled = function(name: string, disabled: boolean)
        registry:SetDisabled(name, disabled)
        store:Save("disabled")
    end,
    spec = function(name: string)
        return registry:Get(name)
    end,
    count = function()
        return #registry.specs
    end,
    setLang = function(lang: string)
        if i18n:SetLang(lang) then
            store.data.lang = lang
            store:Save("lang")
        end
    end,
    togglePreset = function(key: string): (boolean?, string?)
        local mod, p = modules:FindPreset(key)
        if not mod or not p then
            return nil, nil
        end
        modules:TogglePreset(mod, p.id)
        return modules:PresetActive(mod, p.id), modules:PresetTitle(mod, p)
    end,
}

-- Each loader requires its module only when called, so unused modules cost nothing at start.
local loaders: { [string]: () -> CtxTypes.Module } = {
    hub = function()
        return HubImpl(hooks)
    end,
    character = function()
        return require("./modules/character/Impl")()
    end,
    avatar = function()
        return require("./modules/avatar/Impl")()
    end,
}

registry = Registry.new(Commands.specs, loaders, store.data.disabled)

-- Game modules load their handlers the first time a feature of theirs is switched on.
modules = Modules.new(Commands.games, {
    sandbox = function()
        return require("./games/sandbox/Impl")()
    end,
}, registry, store)
registry:SetList("module", function()
    local out = {}
    for _, s in modules:Available() do
        table.insert(out, s.id)
    end
    return out
end)
registry:SetList("preset", function()
    return modules:PresetKeys()
end)

local function character(): Model?
    return lp.Character
end

-- Reads the file each time: the tour asks once per point and setwp may have just written it.
local function waypoint(name: string): Vector3?
    local body = Env.readFile("TZAR/admin/waypoints.json")
    local data = body and Env.json(body)
    local here = type(data) == "table" and data[tostring(game.PlaceId)]
    local pt = type(here) == "table" and here[name]
    if type(pt) == "table" and type(pt.x) == "number" then
        return Vector3.new(pt.x, pt.y, pt.z)
    end
    return nil
end

local ctx: CtxTypes.Ctx = {
    t = t,
    toast = function(kind, text)
        if app then
            app.toast(kind, text)
        end
    end,
    fail = Registry.fail,
    log = log,
    store = store,
    i18n = i18n,
    scheduler = scheduler,
    hub = hub,
    run = function(line: string)
        return registry:Run(line)
    end,
    isActive = function(name: string)
        return registry:IsActive(name)
    end,
    disable = function(name: string)
        registry:Disable(name)
    end,
    setList = function(kind: string, provider: () -> { string })
        registry:SetList(kind, provider)
    end,
    openView = function(view: string)
        if app then
            app.openView(view)
        end
    end,
    openModule = function(id: string)
        if app then
            app.openModule(id)
        end
    end,
    listOf = function(kind: string)
        return registry:List(kind)
    end,
    waypoint = waypoint,
    character = character,
    humanoid = function()
        local c = lp.Character
        return if c then c:FindFirstChildOfClass("Humanoid") else nil
    end,
    root = function()
        local c = lp.Character
        local r = c and c:FindFirstChild("HumanoidRootPart")
        return if r and r:IsA("BasePart") then r else nil
    end,
}
registry:SetCtx(ctx)
modules:SetCtx(ctx)

local binds = Binds.new(store, {
    toggleAll = function()
        if app then
            app.toggleAll()
        end
    end,
    openBar = function()
        if app then
            app.openBar(nil)
        end
    end,
    run = function(line: string)
        task.spawn(function()
            local ok, msg = registry:Run(line, "bind")
            if not ok and msg then
                ctx.toast("error", msg)
            end
        end)
    end,
})

local function info(): string
    local name, ver = Env.executor()
    return t("set.info", name, ver, math.floor(readyMs + 0.5), #registry.specs)
end

app = App.new({
    parent = Env.guiParent(),
    registry = registry,
    modules = modules,
    store = store,
    i18n = i18n,
    log = log,
    t = t,
    run = function(line: string)
        return registry:Run(line, "palette")
    end,
    capture = function(fn)
        binds:Capture(fn)
    end,
    info = info,
    unload = function()
        unload()
    end,
})

-- Optional chat commands: ";fly" in chat. Off by default because others still see the message.
hub:Connect(lp.Chatted, function(msg: string)
    if store.data.chatCommands and string.sub(msg, 1, 1) == ";" then
        local ok, err = registry:Run(string.sub(msg, 2), "chat")
        if not ok and err then
            ctx.toast("error", err)
        end
    end
end)

unload = function()
    if unloaded then
        return
    end
    unloaded = true
    -- Modules first: their command-driven features still need the registry to turn off.
    modules:Destroy()
    registry:Destroy()
    binds:Destroy()
    hub:Cleanup()
    if app then
        app.destroy()
        app = nil
    end
    scheduler:Destroy()
    store:Destroy()
    i18n:Destroy()
    log:Destroy()
    if genv.TZAR_ADMIN and genv.TZAR_ADMIN.Unload == unload then
        genv.TZAR_ADMIN = nil
    end
end

readyMs = (os.clock() - T0) * 1000
log:Info(string.format("ready in %.1f ms", readyMs))

-- Public handle: re-execution guard, autoexec and the in-game test runner use it.
genv.TZAR_ADMIN = {
    Version = Commands.VERSION,
    StartMs = readyMs,
    Unload = unload,
    Run = function(line: string): (boolean, string?)
        return registry:Run(line, "api")
    end,
    IsActive = function(name: string): boolean
        return registry:IsActive(name)
    end,
    Value = function(name: string): any
        return registry:Value(name)
    end,
    Specs = function()
        return registry.specs
    end,
    Modules = function()
        return modules
    end,
    -- A command module's public functions, e.g. Module("avatar").ApplyOutfit(json) in exports.
    Module = function(name: string)
        return registry:Api(name)
    end,
    T = function(key: string, ...: any): string
        return t(key, ...)
    end,
    Debug = function()
        local ui: { [string]: any } = if app then app.debug() else {}
        ui.active = registry:ActiveCount()
        ui.tickers = scheduler:Count()
        ui.hubTasks = hub:Count()
        ui.visible = if app then app.visible() else false
        ui.lang = i18n.lang
        return ui
    end,
    App = function()
        return app
    end,
}

task.defer(function()
    if not app then
        return
    end
    if Theme.touch then
        app.notify(t("nt.title"), t("nt.touch"))
    else
        app.notify(t("nt.title"), t("nt.pc", ";", store.data.toggleKey))
    end
end)

-- Icons and fonts this machine does not have yet arrive in the background; the window is rebuilt
-- once they are on disk, so start-up never waits for the network.
Assets.download(Assets.missing(), function(got: number)
    if got > 0 and not unloaded and app then
        Theme.loadFonts()
        app.rebuild()
    end
end)
