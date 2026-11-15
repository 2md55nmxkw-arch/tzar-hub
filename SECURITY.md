# Security policy

## Reporting a problem

Please **don't** open a public issue for a security problem.

Report it privately instead:

- through **[Report a vulnerability](../../security/advisories/new)** on GitHub (Security tab), or
- by direct message to the TZAR team in the [TZAR Hub Discord](https://discord.gg/As2QHxxVjU).

Describe what you found, how to reproduce it and what it affects. We will confirm that we received it, work on a fix, and credit you when it is released, unless you'd rather stay anonymous.

## What counts

- The website (hub.2md.space): anything that lets someone run code in a visitor's browser, change what the site serves, or read data they shouldn't.
- The published scripts (`avatar-changer.lua`, `tzar-admin.lua`): anything that lets a third party run code through them, or makes them send data anywhere other than Roblox and this site.
- Leaked secrets or credentials in this repository.

Being detected or moderated by a game's anti-cheat, or by Roblox, is not a security issue in TZAR Hub. Executors break the Roblox Terms of Use, and that risk is part of using them.

## Supported versions

Only the latest version is supported. The loaders always fetch the current build, so fixes reach everyone as soon as they are deployed.
