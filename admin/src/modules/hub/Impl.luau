--!strict
local CtxTypes = require("../../Ctx")
local Format = require("../../ui/Format")

type Ctx = CtxTypes.Ctx

-- Filled in by main.luau: these reach parts of the hub a plain handler cannot see.
export type Hooks = {
    unload: () -> (),
    setDisabled: (name: string, disabled: boolean) -> (),
    spec: (name: string) -> any,
    count: () -> number,
    setLang: (lang: string) -> (),
    -- "sandbox.night" (module id, then preset id or name); nil when there is no such set.
    togglePreset: (key: string) -> (boolean?, string?),
}

return function(hooks: Hooks): CtxTypes.Module
    local handlers: { [string]: CtxTypes.Handler } = {
        help = {
            run = function(ctx: Ctx, args: { any })
                local name = args[1]
                if name then
                    local spec = hooks.spec(name)
                    ctx.toast(
                        "info",
                        ctx.t("help.one", Format.signature(spec), ctx.t("d." .. spec.name))
                    )
                    ctx.openView("list")
                else
                    ctx.toast("info", ctx.t("help.count", hooks.count()))
                    ctx.openView("all")
                end
            end,
        },
        bind = {
            run = function(ctx: Ctx, args: { any })
                local key = args[1] :: Enum.KeyCode
                local line = args[2] :: string
                ctx.store.data.binds[key.Name] = line
                ctx.store:Save("binds")
                ctx.toast("ok", ctx.t("toast.bound", key.Name, line))
            end,
        },
        unbind = {
            run = function(ctx: Ctx, args: { any })
                local key = args[1] :: Enum.KeyCode
                local binds = ctx.store.data.binds
                if binds[key.Name] == nil then
                    ctx.toast("info", ctx.t("hub.no_bind", key.Name))
                    return
                end
                binds[key.Name] = nil
                ctx.store:Save("binds")
                ctx.toast("ok", ctx.t("toast.unbound", key.Name))
            end,
        },
        binds = {
            run = function(ctx: Ctx)
                ctx.openView("settings")
            end,
        },
        togglekey = {
            run = function(ctx: Ctx, args: { any })
                local key = args[1] :: Enum.KeyCode?
                ctx.store.data.toggleKey = if key then key.Name else "RightShift"
                ctx.store:Save("toggleKey")
                ctx.toast("ok", ctx.t("hub.togglekey", ctx.store.data.toggleKey))
            end,
        },
        lang = {
            run = function(_ctx: Ctx, args: { any })
                hooks.setLang(args[1] :: string)
            end,
        },
        enable = {
            run = function(ctx: Ctx, args: { any })
                hooks.setDisabled(args[1] :: string, false)
                ctx.toast("ok", ctx.t("toast.cmd_enabled", args[1]))
            end,
        },
        disable = {
            run = function(ctx: Ctx, args: { any })
                hooks.setDisabled(args[1] :: string, true)
                ctx.toast("info", ctx.t("toast.cmd_disabled", args[1]))
            end,
        },
        settings = {
            run = function(ctx: Ctx)
                ctx.openView("settings")
            end,
        },
        log = {
            run = function(ctx: Ctx)
                ctx.openView("log")
            end,
        },
        module = {
            run = function(ctx: Ctx, args: { any })
                ctx.openModule((args[1] :: string?) or "")
            end,
        },
        preset = {
            run = function(ctx: Ctx, args: { any })
                local key = args[1] :: string
                local on, title = hooks.togglePreset(key)
                if on == nil then
                    ctx.fail(ctx.t("arg.preset", key))
                end
                ctx.toast("ok", ctx.t(if on then "md.preset_on" else "md.preset_off", title))
            end,
        },
        unload = {
            run = function()
                -- Defer so the command finishes before the registry it runs in is torn down.
                task.defer(hooks.unload)
            end,
        },
    }
    return { handlers = handlers }
end
