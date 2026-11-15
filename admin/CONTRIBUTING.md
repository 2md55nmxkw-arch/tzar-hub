# Contributing to TZAR Admin

Bug reports, fixes, translations and new commands are welcome.

## Proposing a change

1. For anything bigger than a small fix, open an issue first (or ask in the TZAR Discord,
   https://discord.gg/As2QHxxVjU) so we can agree on the approach.
2. Install the pinned tools: `cd admin && rokit install` (see [README.md](README.md#toolchain)).
3. Make the change. Keep a pull request to one topic.
4. Run the checks (all must pass, the same as CI):

   ```sh
   stylua --check src tests build.luau
   selene src
   luau-lsp analyze --flag LuauSolverV2=true --platform roblox \
     --definitions defs/roblox.d.luau --definitions defs/potassium.d.luau src
   lune run tests/unit/fuzzy
   lune run build -- --check
   ```

5. Rebuild with `lune run build` and commit `../public/tzar-admin.lua` and
   `../public/tzar-admin-commands.json` together with your source change. CI fails if they are out
   of date.
6. If the change touches gameplay, run the in-game tests (see
   [README.md](README.md#in-game-tests)) and say in the pull request where you ran them.

## Code style

- **Formatting**: StyLua with `stylua.toml` (100 columns, 4 spaces, double quotes, call
  parentheses always). Run `stylua src tests build.luau` before committing.
- **Linting**: selene with `selene.toml`. The standard library is `roblox.yml` plus
  `executor.yml`. Declare a new executor global in `executor.yml` and wrap it in
  `src/platform/Env.luau`.
- **Strict types**: every file under `src/` starts with `--!strict`, and `.luaurc` sets strict mode.
  Type checking uses luau-lsp with the new solver (`LuauSolverV2`) and the definitions in `defs/`.
  Prefer real types over `any`. Shared types live in `src/Types.luau` and `src/Ctx.luau`.
- **Executor functions** are touched only in `src/platform/Env.luau`. Every one is optional: check
  with `Env.has(name)`, and list it in a command's `needs` if the command cannot work without it.
- **Specs and Strings are pure data.** `src/Commands.luau` and every file it requires are also read
  by Lune at build time, so they must not call Roblox APIs.
- **Every user-facing string** goes through `ctx.t(key)` and must exist in all six languages
  (`en`, `ru`, `uk`, `es`, `pt`, `de`). The build fails if a key exists in English and is missing
  in another language. Plural forms are a list: `{one, few, many}` for `ru` and `uk`,
  `{one, other}` for the rest.
- **Cleanup**: anything a toggle or feature creates (instances, connections, property changes,
  scheduler tickers, threads) is added to the Janitor it receives. Turning it off, or `unload`,
  must leave the game as it was. The in-game tests check this.
- **Per-frame work** goes through `ctx.scheduler`, not your own `RunService` connections. Avoid
  allocating tables, closures or strings inside a ticker.
- **Comments** explain why, not what. Keep them short.
- Requires use relative string paths (`require("../core/Janitor")`) so darklua can bundle them.

## Tests

- **Unit tests** for pure modules (no Roblox APIs) go in `tests/unit/<name>.luau` and run with
  `lune run tests/unit/<name>`. Exit with a non-zero code on failure (see `tests/unit/fuzzy.luau`).
  Add a new file to the CI job and to `check.ps1`, which run each test file by name.
- **In-game cases** go in `tests/cases/<area>.luau` and return
  `function(A, check, expect, connCounts) ... end`, where `A` is the `TZAR_ADMIN` handle. Add the
  case name to the list in `tests/ingame.luau`.

## Translations

String files are `src/i18n/*.luau` and each module's `Strings.luau`. Fix a translation by editing
the entry for that language. Adding a new language means changing `Types.Lang`, `I18n.LANGS`, the
`lang` command options and `LANGS` in `build.luau`, and translating every key.

## Game modules from authors

Game modules written by outside authors follow their own process: you send the module to the TZAR
team, and only the TZAR owner reviews and publishes it. You do not upload anything yourself. See
[docs/modules.md](docs/modules.md) for the module format and the
[Publishing](docs/modules.md#publishing) section.

## License

By contributing you agree that your contribution is released under the [MIT License](../LICENSE). See [NOTICE.md](../NOTICE.md) for what the license does not cover.
