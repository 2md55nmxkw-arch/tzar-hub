// The loader fetches the script from this site (public/avatar-changer.lua). When the domain
// changes, update it here and in SOURCE_URL at the top of public/avatar-changer.lua.
export const TZAR_SITE = 'https://hub.2md.space'
export const TZAR_LOADER = `loadstring(game:HttpGet("${TZAR_SITE}/avatar-changer.lua"))()`
// TZAR Admin, the in-game command panel built from admin/ (public/tzar-admin.lua).
export const TZAR_ADMIN_LOADER = `loadstring(game:HttpGet("${TZAR_SITE}/tzar-admin.lua"))()`
export const TZAR_DISCORD = 'https://discord.gg/As2QHxxVjU'
// The public repository. The code is MIT; NOTICE.md lists what is not.
export const TZAR_REPO = 'https://github.com/2md55nmxkw-arch/tzar-hub'
export const SCRIPTS_AVAILABLE = true
