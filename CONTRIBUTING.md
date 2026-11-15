# Contributing to TZAR Hub

Thanks for helping. This guide covers the website. For the Cmdr Panel (Luau, `admin/`), read [admin/CONTRIBUTING.md](admin/CONTRIBUTING.md) as well.

## Ways to help

- **Report a bug.** Use the bug report form in [Issues](../../issues/new/choose). Name the script (website, Avatar Changer or Cmdr Panel), your executor, what you did and what happened. Copy the executor's console output if there is any.
- **Suggest something.** Use the feature request form, or talk it through in the [Discord](https://discord.gg/As2QHxxVjU) first.
- **Send a pull request.** Small, focused PRs are reviewed fastest. For anything large, open an issue first so we can agree on the approach.
- **Write a game module.** Read [admin/docs/modules.md](admin/docs/modules.md). Authors don't publish modules themselves: send yours to the TZAR team on Discord, and the owner reviews and publishes it.

## Set up

```sh
git clone https://github.com/2md55nmxkw-arch/tzar-hub.git
cd tzar-hub
npm ci
npm run dev
```

You need Node.js 22 or newer. The Playwright checks also need `npx playwright install chromium`.

## Before you open a pull request

Run what CI runs:

```sh
npm run build
npm run lint
npm run format:check   # or npm run format to fix
npm run check:site     # needs the dev server or AUDIT_URL
```

If you changed anything in `admin/src/`, rebuild the bundle (`cd admin && lune run build`) and commit `public/tzar-admin.lua` and `public/tzar-admin-commands.json` with it.

## Code style

- TypeScript in strict mode. No `any` unless there is no other way, and then with a comment.
- Formatting and linting come from oxfmt and oxlint. Don't hand-format against them.
- Components live next to where they are used (`src/components/landing`, `docs`, `source`, `ui`). A new folder under `src/components/` needs an `@source` line in `src/index.css`.
- Respect reduced motion: animations go through `useReducedMotion()` and stop when the visitor pauses them.
- Keep the site accessible: real buttons and links, labels on icon buttons, text contrast of at least 4.5:1, and touch targets of at least 24 px.
- UI text is plain and short, in sentence case.

## Commits and pull requests

- Write commit subjects in the imperative, in sentence case, without a trailing period, like the existing history ("Keep accessories when avatar changer applies game rules").
- Say in the PR what changed, why, and how you checked it. Add screenshots for visual changes.
- Keep unrelated changes in separate PRs.

## Assets and licensing

By contributing you agree that your contribution is released under the [MIT License](LICENSE).

Only add images, fonts, icons or code that you made yourself or that come with a license allowing it, and say where they come from in the PR. Don't add trial or commercial fonts, ripped game assets, or code copied from sites or products without a compatible license. If an item is not MIT, add it to [NOTICE.md](NOTICE.md).

## Be kind

Be respectful in issues, PRs and the Discord. No harassment, no slurs and no posting other people's personal information. The scripts must not be used to harass players either.
