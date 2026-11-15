--!strict
-- What every command handler receives. Built once in main.luau.

local I18n = require("./core/I18n")
local Janitor = require("./core/Janitor")
local Log = require("./core/Log")
local Scheduler = require("./core/Scheduler")
local Store = require("./core/Store")
local Types = require("./Types")

export type Ctx = {
    t: (key: string, ...any) -> string,
    toast: (kind: Types.Toast, text: string) -> (),
    -- Stops the command with a message for the user (no "failed", no traceback).
    fail: (text: string) -> never,
    log: Log.Log,
    store: Store.Store,
    i18n: I18n.I18n,
    scheduler: Scheduler.Scheduler,
    -- Lives as long as the hub; cleaned on unload.
    hub: Janitor.Janitor,
    run: (line: string) -> (boolean, string?),
    isActive: (name: string) -> boolean,
    -- Turns a toggle or value command off without a toast (one look replacing another).
    disable: (name: string) -> (),
    setList: (kind: string, provider: () -> { string }) -> (),
    -- UI hooks a module may use; no-ops until the window exists.
    openView: (view: string, arg: any?) -> (),
    character: () -> Model?,
    -- Opens a game module's panel.
    openModule: (id: string) -> (),
    -- Names an argument kind offers (waypoint, outfit, ...).
    listOf: (kind: string) -> { string },
    -- Position of a saved waypoint in this place.
    waypoint: (name: string) -> Vector3?,
    humanoid: () -> Humanoid?,
    root: () -> BasePart?,
}

-- Handlers a module's Impl returns, keyed by command name.
export type Handler = {
    -- action: does the work. value commands may also use it to read args.
    run: ((ctx: Ctx, args: { any }) -> ())?,
    -- toggle/value: sets things up; everything added to `jan` is undone on disable.
    enable: ((ctx: Ctx, args: { any }, jan: Janitor.Janitor) -> ())?,
    -- value: what the chip shows when the command is not active.
    current: ((ctx: Ctx) -> any)?,
}

-- What a module's Impl returns.
export type Module = {
    handlers: { [string]: Handler },
    -- Runs once when the module first loads; `jan` lives until the hub unloads.
    init: ((ctx: Ctx, jan: Janitor.Janitor) -> ())?,
    -- Names for argument kinds this module owns (waypoint, outfit, emote).
    lists: { [string]: (ctx: Ctx) -> { string } }?,
    -- Functions other scripts may call through TZAR_ADMIN.Module(name) (exported outfits).
    api: { [string]: any }?,
}

-- Game modules (see Types.GameModuleSpec).
export type Runner = {
    status: (text: string) -> (),
    progress: (frac: number) -> (),
    -- Sleeps while respecting pause; false once the run was stopped.
    wait: (seconds: number) -> boolean,
    value: (featureId: string) -> any,
}

export type FeatureHandler = {
    -- Everything added to `jan` is undone when the feature goes off or changes value.
    enable: (ctx: Ctx, value: any, jan: Janitor.Janitor) -> (),
}

export type GameImpl = {
    features: { [string]: FeatureHandler },
    run: ((ctx: Ctx, r: Runner, jan: Janitor.Janitor) -> ())?,
}

return nil
