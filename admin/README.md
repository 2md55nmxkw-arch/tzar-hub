# TZAR Admin

> **In development.** The Cmdr Panel works, but it is not finished: commands, keys, saved data and
> the module format can change between updates, and some things may break. Report bugs in the
> [TZAR Hub Discord](https://discord.gg/As2QHxxVjU).

TZAR Admin (the "Cmdr Panel") is an in-game command panel for Roblox, run through an executor. It is
written in strict Luau and bundled into one script, served at
https://hub.2md.space/tzar-admin.lua. It is free and needs no key.

## What it does

- **Command bar**: press `;` and type a command (`fly`, `speed 64`, `wear <user>`). Suggestions
  are fuzzy-matched, and Tab completes. `unfly` / `unspeed` turn a command off again. On desktop, a
  small "Commands ;" pill in the top-right corner also opens the bar.
- **Show / hide**: `RightShift` shows and hides everything TZAR draws (dock, panels, launcher).
  Both keys can be changed in Settings, and `togglekey <key>` changes the hide key.
- **Dock**: a strip of pinned commands at the top edge (by default `fly`, `speed`, `noclip`). Tap a
  pin to turn it on or off. Hold or right-click a value command to get a slider with quick values.
  `+` picks what is pinned, and module presets can be pinned too.
- **Binds**: `bind <key> <command>` runs a command line on a key press. Hold binds run on press and
  are undone on release. `binds` opens the list.
- **Panels**: Commands, Binds, Settings, Log, Pins, Avatar and one panel per game module. Panels
  can be dragged and remember their position. On touch screens they sit between the thumbstick and
  the jump button.
- **Chat commands** (off by default): `;fly` typed in chat. Other players still see the message.

Built-in modules:

| Module      | Commands                                                                 |
| ----------- | ------------------------------------------------------------------------ |
| `avatar`    | Wear another user's look, saved outfits, bundles, outfit export, emotes and an emote wheel, game avatar rules. Looks are local to your client. |
| `character` | Fly, noclip, walk speed, jump power, infinite jump, sit / lay, waypoints, anti-AFK, respawn. |
| `hub`       | help, bind / unbind, togglekey, lang, enable / disable a command, settings, log, module, preset, unload. |

**Game modules** are larger feature sets (dozens of toggles, numbers and choices) grouped into
sections, with presets and an optional start/pause/stop routine. They open with `module <id>`. The
bundle ships `sandbox`, a demo module that works in any place. See
[docs/modules.md](docs/modules.md) to write one.

The full command list with descriptions in every language is generated into
`../public/tzar-admin-commands.json` by the build.

## Running the published build

In your executor:

```lua
loadstring(game:HttpGet("https://hub.2md.space/tzar-admin.lua"))()
```

Running it again replaces the running copy instead of stacking a second one. `unload` (or
Settings → "Turn TZAR off") removes everything TZAR created.

Every executor function the hub uses is optional (`src/platform/Env.luau` checks for each one), so
features that need a missing function are skipped and the rest still work.

What the hub stores on your machine, in the executor's workspace folder:

- `TZAR/admin/` for settings, waypoints, avatar data and fonts
- `TZAR/assets/` for icons and fonts, downloaded once from `https://hub.2md.space/tzar-assets/`
- `TZAR/exports/` for exported outfit scripts

It also reads the older `AvatarChanger/` folders if they exist. Besides the asset download, the
only web requests go to Roblox's own APIs (catalog, avatar rules, asset delivery) from the avatar
module.

## Project layout

```
admin/
├── build.luau          bundles src/ into ../public/tzar-admin.lua and writes the command list
├── check.ps1           runs the same checks as CI (Windows / PowerShell)
├── rokit.toml          pinned tool versions
├── stylua.toml         formatter config
├── selene.toml         linter config (std = roblox + executor)
├── roblox.yml          selene standard library for Roblox
├── executor.yml        selene standard library for the executor globals the hub may use
├── .luaurc             strict mode for every file
├── .darklua.json       bundler config (path requires, strips types and comments)
├── defs/               type definitions for luau-lsp (Roblox API and executor globals)
├── src/
│   ├── main.luau       entry point: builds the core, registry and UI, owns unload
│   ├── Types.luau      shared types (CommandSpec, GameModuleSpec, Feature, ...)
│   ├── Ctx.luau        what handlers receive (Ctx, Handler, Module, GameImpl, Runner)
│   ├── Commands.luau   lists every Spec and Strings file. Pure data, also read by the build
│   ├── core/           registry, arguments, binds, settings store, i18n, Janitor, scheduler, ...
│   ├── platform/       Env.luau, the only file that touches executor functions
│   ├── modules/        command modules: avatar, character, hub (Spec, Impl, Strings each)
│   ├── games/          game modules: sandbox (Spec, Impl, Strings)
│   ├── i18n/           strings for the core, UI, avatar panel and game-module frame
│   └── ui/             command bar, dock, panels, theme, toasts
└── tests/
    ├── unit/           Lune unit tests for pure modules
    ├── ingame.luau     in-game test runner (run inside Roblox through an executor)
    └── cases/          in-game test cases per area
```

## Toolchain

Tools are pinned in `rokit.toml` and installed with [Rokit](https://github.com/rojo-rbx/rokit):

| Tool     | Version | Used for                         |
| -------- | ------- | -------------------------------- |
| lune     | 0.11.0  | build script and unit tests      |
| darklua  | 0.19.0  | bundling                         |
| stylua   | 2.6.0   | formatting                       |
| selene   | 0.32.0  | linting                          |
| luau-lsp | 1.70.1  | strict type checking             |

```sh
cd admin
rokit install
```

The bundle check compares bytes, so use the pinned darklua version. Other versions may produce a
different file.

## Building

Run from `admin/`:

```sh
lune run build              # writes ../public/tzar-admin.lua and ../public/tzar-admin-commands.json
lune run build -- --check   # fails if either committed file is out of date (CI runs this)
```

The build calls `darklua` from `PATH`, or the binary named in the `DARKLUA` environment variable.
It also fails if any string key that exists in English is missing in another language.

Both output files are committed. Rebuild and commit them together with any change under `src/`.

## Checks and tests

CI (`.github/workflows/ci.yml`, job "TZAR Admin") runs these from `admin/`:

```sh
stylua --check src tests build.luau
selene src
luau-lsp analyze --flag LuauSolverV2=true --platform roblox \
  --definitions defs/roblox.d.luau --definitions defs/potassium.d.luau src
lune run tests/unit/fuzzy
lune run build -- --check
```

On Windows, `./check.ps1` runs the same steps, and `./check.ps1 -Fix` formats and rebuilds instead
of only checking. It reads the tools from the folder set in `$bin` at the top of the script, so
point that at your own tools folder (for example Rokit's `bin`).

### In-game tests

`tests/ingame.luau` loads the bundle inside a live game, runs every case, unloads, checks that
nothing was left behind (character, camera, lighting, signal connections) and writes a report. To
run it, copy these files into your executor's workspace folder:

| From                         | To                    |
| ---------------------------- | --------------------- |
| `../public/tzar-admin.lua`   | `tzar-admin.lua`      |
| `tests/ingame.luau`          | `tzar-ingame.lua`     |
| `tests/cases/<name>.luau`    | `tzar-case-<name>.lua` (one per case file) |

Then execute:

```lua
loadstring(readfile("tzar-ingame.lua"))()
```

Results are written to `tzar-admin-report.json` in the same folder. The runner uses
`getconnections` to look for leaked connections.

## Languages

English, Russian, Ukrainian, Spanish, Portuguese and German (`en`, `ru`, `uk`, `es`, `pt`, `de`).
The language follows the Roblox locale. Change it with `lang <code>` or in Settings. Missing
strings fall back to English.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Module authors: see [docs/modules.md](docs/modules.md).
Questions: the TZAR Discord, https://discord.gg/As2QHxxVjU.

## License

TZAR Admin is released under the [MIT License](../LICENSE), like the rest of TZAR Hub. The TZAR
logo, the Teto artwork and the bundled fonts and icons in `public/tzar-assets/` keep their own
terms; see [NOTICE.md](../NOTICE.md). Game modules from outside authors belong to their authors.
