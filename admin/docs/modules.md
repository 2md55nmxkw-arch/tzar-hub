# Writing a game module

A game module is a feature set for one game (or for any place): dozens of toggles, numbers and
choices grouped into sections, with presets and an optional start/pause/stop routine. The panel,
search, presets, dock pins and run controls are built from your spec, so you only describe the
features and write what each one does.

The reference module is `sandbox` in `src/games/sandbox/`. It works in any place, so read it next
to this guide. Types are defined in `src/Types.luau` (`GameModuleSpec`, `Feature`, `PresetSpec`)
and `src/Ctx.luau` (`GameImpl`, `FeatureHandler`, `Runner`).

## Files

Each module is three files in `src/games/<id>/`:

| File            | Contents                                                     | Roblox APIs |
| --------------- | ------------------------------------------------------------ | ----------- |
| `Spec.luau`     | A `Types.GameModuleSpec` table: sections, features, presets   | No          |
| `Impl.luau`     | A function returning `CtxTypes.GameImpl`: what each feature does, and the routine | Yes |
| `Strings.luau`  | A `Types.Bundle`: every title in all six languages            | No          |

`Spec.luau` and `Strings.luau` are pure data. The build reads them in Lune, outside Roblox, so
they must not call `game:GetService` or any other Roblox API. Every file starts with `--!strict`.

## Spec

```lua
--!strict
local Types = require("../../Types")

local spec: Types.GameModuleSpec = {
    id = "sandbox",
    badge = "Demo",
    sections = { "light", "camera", "body", "tour" },
    runner = true,
    features = {
        { id = "brightness", section = "light", kind = "number", min = 0, max = 6, step = 0.1, default = 2 },
        { id = "nofog", section = "light", kind = "toggle" },
        { id = "tone", section = "light", kind = "choice", options = { "neutral", "warm", "cold", "mono" } },
        { id = "fly", section = "body", kind = "toggle", command = "fly" },
        -- ...
    },
    presets = {
        { id = "night", values = { night = true, nofog = true, tone = "cold", brightness = 1 } },
    },
}

return spec
```

### `GameModuleSpec` fields

| Field        | Type             | Meaning |
| ------------ | ---------------- | ------- |
| `id`         | `string`         | Module id, lowercase. Used by `module <id>`, in string keys (`m.<id>.…`), in preset keys (`<id>.<preset>`) and as the loader name in `main.luau`. Must be unique. |
| `places`     | `{ number }?`    | Place ids (`game.PlaceId`) where the module is offered. `nil` means every place. In other places the module does not appear in the command bar, in `module` completions or in the module list. |
| `badge`      | `string?`        | Short label next to the panel title, for example `"Demo"` or `"Beta"`. Shown as written, not translated. |
| `badgeColor` | `string?`        | Badge color as a hex string without `#`, for example `"ff9c48"` (the default). |
| `sections`   | `{ string }`     | Section ids in display order. The first one is open when the panel opens. |
| `features`   | `{ Feature }`    | Every feature of the module. |
| `presets`    | `{ PresetSpec }?`| Built-in presets. |
| `runner`     | `boolean?`       | `true` adds the run row (Start / Pause / Resume / Stop, status, timer, progress bar). The Impl must then provide `run`. |

### `Feature` fields

| Field     | Type          | Meaning |
| --------- | ------------- | ------- |
| `id`      | `string`      | Feature id. Must be unique within the module; a duplicate stops the hub at start. |
| `section` | `string`      | One of the module's `sections`. |
| `kind`    | `FeatureKind` | `"toggle"`, `"number"` or `"choice"`. |
| `min`     | `number?`     | Number features: lowest value. The panel uses 0 if missing. |
| `max`     | `number?`     | Number features: highest value. The panel uses 100 if missing. |
| `step`    | `number?`     | Number features: slider step. The panel uses 1 if missing. |
| `default` | `number?`     | Number features: the value shown while the feature is off (usually the game's own value). Always set it. |
| `options` | `{ string }?` | Choice features: option ids. Their titles come from strings. |
| `command` | `string?`     | Drive an existing hub command instead of a handler in your Impl. See below. |

## Feature kinds

There are exactly three kinds. Every feature is either **off** or **on with a value**.

| Kind       | Value passed to `enable` | Value while off       | In the panel |
| ---------- | ------------------------ | --------------------- | ------------ |
| `"toggle"` | `true`                   | `false`               | A check in the section grid. |
| `"number"` | a number in `min..max`   | `default`             | A fill bar under "Section settings". Dragging sets the value; right-click turns it off. |
| `"choice"` | one of `options`         | the first option      | A row under "Section settings". A tap moves to the next option, the tap after the last option turns it off; right-click turns it off. |

Changing the value of a number or choice feature that is already on first cleans up the previous
value (its Janitor runs), then calls `enable` again with the new value.

### Features that drive a hub command

With `command` set, the feature needs no handler. It runs a command line through the registry:

- toggles run `<command> on` and `<command> off`
- numbers run `<command> <value>`, and `un<command>` to turn off

The feature's state follows the command, so it stays in sync with the dock, binds and the command
bar. Use it for things the hub already does (`fly`, `noclip`, `speed`, `jumppower`, `infjump`,
`antiafk`, …) instead of writing them again. The command must exist and be a toggle or value
command. Run `help` in game for the full list.

## Sections

Each section is a tab in the panel showing how many of its features are on. Inside a section,
toggles form a grid of checks, and numbers and choices are listed under "Section settings".
"All on" turns on every **toggle** of the section (numbers and choices are left alone); "All off"
turns off every feature of the section. "Turn all off" in the presets row turns off the whole
module, and the search box in the header finds features across all sections by title.

## Presets

```lua
presets = {
    { id = "night", values = { night = true, nofog = true, tone = "cold", brightness = 1 } },
    { id = "explore", values = { fly = true, noclip = true, speed = 64, fov = 90 } },
},
```

A `PresetSpec` is `{ id: string, values: { [featureId]: value } }`. Values are `true` for a toggle,
a number for a number feature and an option id for a choice. `false` means "this feature is off".

- A preset is shown as active when every listed feature matches its value.
- Clicking an inactive preset applies it. Clicking an active preset turns its features off.
- Players can also save their own presets ("Save current"). These are stored in their settings.
- Each preset has a key, `<module>.<preset>` (for example `sandbox.night`). The `preset` command
  toggles it (`preset sandbox.night`), so it can be bound to a key, pinned on the dock or found from
  the command bar.

## Impl

```lua
--!strict
local Lighting = game:GetService("Lighting")

local CtxTypes = require("../../Ctx")
local Janitor = require("../../core/Janitor")

type Ctx = CtxTypes.Ctx

return function(): CtxTypes.GameImpl
    local features: { [string]: CtxTypes.FeatureHandler } = {
        night = {
            enable = function(_ctx: Ctx, _v: any, jan: Janitor.Janitor)
                jan:Set(Lighting, "ClockTime", 0)
            end,
        },
        -- Read only by the routine: switching it on is all it needs.
        loop = { enable = function() end },
    }

    local function run(ctx: Ctx, r: CtxTypes.Runner, jan: Janitor.Janitor)
        -- ...
    end

    return { features = features, run = run }
end
```

`GameImpl` has two fields:

| Field      | Type                                                     | Meaning |
| ---------- | -------------------------------------------------------- | ------- |
| `features` | `{ [string]: FeatureHandler }`                           | One entry per feature id that has no `command`. |
| `run`      | `((ctx: Ctx, r: Runner, jan: Janitor) -> ())?`           | The routine, required when the spec has `runner = true`. |

A `FeatureHandler` is `{ enable: (ctx: Ctx, value: any, jan: Janitor) -> () }`.

- The Impl is loaded the first time one of the module's features is switched on or its routine
  starts. Nothing in it runs before that.
- Every feature without `command` needs an entry in `features`, or switching it on fails with "no
  handler". A setting that only the routine reads gets an empty `enable`.
- If `enable` throws, its Janitor is cleaned, the feature stays off, the error is written to the
  log and its first line is shown as a toast.

### The Janitor rule

**Turning a feature off must undo exactly what it did.** The same goes for changing its value and
for `unload`. Everything `enable` creates or changes must go into the `jan` it receives: when the
feature goes off, the Janitor undoes it all in reverse order. Nothing should be left behind, and the
in-game tests check this (character, camera, lighting and signal connections are compared before
and after).

| Janitor method             | What it owns |
| -------------------------- | ------------ |
| `jan:Add(item)`            | An Instance (destroyed), a connection (disconnected), a function (called), a thread (cancelled), or a table with `Destroy`, `Disconnect` or `Cleanup`. Returns `item`. |
| `jan:Connect(signal, fn)`  | Connects `fn` and disconnects it on cleanup. A callback that errors is logged and stays connected. |
| `jan:Set(target, prop, v)` | Sets a property and restores the previous value on cleanup. |
| `jan:Defer(fn)`            | Runs `fn` on cleanup. |

Patterns from the sandbox:

```lua
-- Hold a property while the feature is on, even if the game sets it back.
local function hold(jan: Janitor.Janitor, target: Instance, prop: string, value: any)
    jan:Set(target, prop, value)
    jan:Connect(target:GetPropertyChangedSignal(prop), function()
        if (target :: any)[prop] ~= value then
            (target :: any)[prop] = value
        end
    end)
end

-- An instance you create goes into the Janitor so it is destroyed when the feature goes off.
local cc = Instance.new("ColorCorrectionEffect")
cc.Parent = Lighting
jan:Add(cc)
```

For per-frame work use the hub's scheduler and let the Janitor remove the ticker:

```lua
local remove = ctx.scheduler:Add("heartbeat", function(dt: number)
    -- no tables, closures or strings created here
end)
jan:Defer(remove)
```

Phases are `"stepped"` (before physics), `"heartbeat"` (after physics) and `"render"` (after the
camera). A ticker that throws is dropped and reported.

### What `ctx` gives you

The `Ctx` type in `src/Ctx.luau` lists everything. The parts game modules usually need:

| Field                         | Use |
| ----------------------------- | --- |
| `ctx.t(key, ...)`             | A translated string (`string.format` placeholders). |
| `ctx.toast(kind, text)`       | A notification; `kind` is `"info"`, `"ok"` or `"error"`. |
| `ctx.log`                     | The hub log (Log panel). |
| `ctx.character()`, `ctx.humanoid()`, `ctx.root()` | The local player's character, Humanoid and HumanoidRootPart, or `nil`. |
| `ctx.listOf("waypoint")`, `ctx.waypoint(name)` | The player's saved waypoints for this place and their positions. |
| `ctx.run(line)`, `ctx.isActive(name)` | Run a hub command line; check whether a command is on. |
| `ctx.scheduler`               | Per-frame tickers (see above). |

## Runner

Set `runner = true` in the spec and provide `run` in the Impl. The routine gets a `Runner`:

| Runner field          | Meaning |
| --------------------- | ------- |
| `r.status(text)`      | The text shown in the run row. |
| `r.progress(frac)`    | The progress bar, `0` to `1` (clamped). |
| `r.wait(seconds)`     | Sleeps. Time does not count while paused. Returns `false` once the run was stopped. |
| `r.value(featureId)`  | The current value of a feature of this module (the "value while off" if it is off). |

Lifecycle:

- **Start** runs `run(ctx, r, jan)` in a new thread with a fresh Janitor.
- **Pause** is cooperative: the routine keeps going until its next `r.wait`, which then holds until
  Resume or Stop.
- **Stop** makes `r.wait` return `false`, cancels the thread if it is waiting, and cleans the run's
  Janitor.
- When `run` returns, its Janitor is cleaned and the state goes back to idle.
- If `run` throws, the error is logged and shown as a toast, and the progress resets.

While idle, the row shows `m.<id>.run`; while running with no status set, it shows "Running" or
"Paused", plus the elapsed time.

Write the routine so it stops cleanly, and read settings through `r.value` so changes apply
mid-run:

```lua
local function run(ctx: Ctx, r: CtxTypes.Runner, _jan: Janitor.Janitor)
    local names = ctx.listOf("waypoint")
    repeat
        for i, name in names do
            r.status(ctx.t("m.sandbox.at", i, #names, name))
            r.progress(i / #names)
            -- ... do the step ...
            if not r.wait(tonumber(r.value("delay")) or 3) then
                return -- stopped
            end
        end
    until not r.value("loop")
    r.status(ctx.t("m.sandbox.done"))
end
```

## Strings

All titles come from `Strings.luau`, keyed under `m.<id>.`:

| Key                     | Shown as |
| ----------------------- | -------- |
| `m.<id>.title`          | Panel title and the module's name in the command bar |
| `m.<id>.desc`           | One-line description in the command bar |
| `m.<id>.s.<section>`    | Section title |
| `m.<id>.f.<feature>`    | Feature title |
| `m.<id>.o.<option>`     | Choice option title (shared by every choice feature of the module) |
| `m.<id>.p.<preset>`     | Built-in preset title |
| `m.<id>.run`            | Run row label while idle (runner modules) |
| anything else           | Your own messages, read with `ctx.t` (for example `m.sandbox.at`) |

The sandbox adds the prefix with a small helper:

```lua
--!strict
local Types = require("../../Types")

local function lang(t: { [string]: Types.I18nValue }): { [string]: Types.I18nValue }
    local out: { [string]: Types.I18nValue } = {}
    for k, v in t do
        out["m.sandbox." .. k] = v
    end
    return out
end

local bundle: Types.Bundle = {
    en = lang({ title = "Sandbox", ["s.light"] = "Lighting", ["f.nofog"] = "No fog", at = "Point %d/%d · %s" }),
    ru = lang({ ... }),
    uk = lang({ ... }),
    es = lang({ ... }),
    pt = lang({ ... }),
    de = lang({ ... }),
}

return bundle
```

- Provide all six languages: `en`, `ru`, `uk`, `es`, `pt`, `de`. The build fails if a key that
  exists in English is missing in any other language.
- Placeholders use `string.format` (`%d`, `%s`).
- A plural entry is a list: `{one, few, many}` for `ru` and `uk`, `{one, other}` for the others.
  `ctx.t(key, n)` picks the form when the first argument is a number.

## Registering the module

A module becomes part of the bundle in three places:

1. `src/Commands.luau`: add the spec to `GAME_MODULES`:

   ```lua
   local GAME_MODULES: { Types.GameModuleSpec } = {
       require("./games/sandbox/Spec"),
       require("./games/<id>/Spec"),
   }
   ```

2. `src/Commands.luau`: add the strings to `STRING_MODULES`:

   ```lua
   require("./games/<id>/Strings"),
   ```

3. `src/main.luau`: add a loader to the table passed to `Modules.new`, keyed by the module id:

   ```lua
   modules = Modules.new(Commands.games, {
       sandbox = function()
           return require("./games/sandbox/Impl")()
       end,
       ["<id>"] = function()
           return require("./games/<id>/Impl")()
       end,
   }, registry, store)
   ```

Requires must be plain relative string paths so darklua can bundle them. Then, from `admin/`:

```sh
lune run build    # bundles ../public/tzar-admin.lua; fails on missing translations
```

Run the checks listed in [CONTRIBUTING.md](../CONTRIBUTING.md), load the built
`../public/tzar-admin.lua` in game and open your module with `module <id>`. From a script, the
`TZAR_ADMIN` handle gives access to the module manager for testing: `TZAR_ADMIN.Modules()` has
`Set(mod, featureId, value)`, `IsOn`, `Value`, `Start`, `Stop` and more (see
`tests/cases/modules.luau`).

## Checklist

- [ ] `Spec.luau` and `Strings.luau` use no Roblox APIs; every file starts with `--!strict`.
- [ ] Every feature id is unique and belongs to a listed section.
- [ ] Number features have `min`, `max`, `step` and `default`.
- [ ] Every feature without `command` has an `enable` in the Impl.
- [ ] Turning each feature off (and `unload`) puts the game back exactly as it was.
- [ ] The routine returns as soon as `r.wait` returns `false`.
- [ ] Every string exists in all six languages; `lune run build` passes.
- [ ] `places` is set if the module only makes sense in one game.

## Publishing

Authors do not publish modules and do not upload anything themselves.

1. Send your module to the TZAR team in the Discord: https://discord.gg/As2QHxxVjU. Include the
   three files (or a branch or pull request), the game and place ids, what each feature does, and
   where and with which executor you tested it.
2. Only the TZAR owner reviews modules and publishes them into the panel. The review may ask for
   changes, and a module can be declined.
3. A published module ships inside the script served at https://hub.2md.space/tzar-admin.lua.

If you want your module's source kept closed, say so when you send it; the owner decides how it
ships. Be aware of what that can and cannot mean: any code an executor runs is downloaded to the
player's machine and runs there. A closed module can be obfuscated, but it cannot be hidden, and a
determined person can read it. Never put secrets such as tokens, webhooks or API keys in a module.
