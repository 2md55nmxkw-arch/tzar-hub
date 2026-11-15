--!strict
-- Every module's specs and strings in one place. Pure data: the build reads this file in Lune
-- to write the command list for the docs page.

local Types = require("./Types")

local Commands = {}

local SPEC_MODULES: { { Types.CommandSpec } } = {
    require("./modules/avatar/Spec"),
    require("./modules/character/Spec"),
    require("./modules/hub/Spec"),
}

local STRING_MODULES: { Types.Bundle } = {
    require("./i18n/Core"),
    require("./i18n/Ui"),
    require("./modules/avatar/Strings"),
    require("./i18n/Avatar"),
    require("./modules/character/Strings"),
    require("./modules/hub/Strings"),
    require("./i18n/Modules"),
    require("./games/sandbox/Strings"),
}

local specs: { Types.CommandSpec } = {}
for _, list in SPEC_MODULES do
    for _, s in list do
        table.insert(specs, s)
    end
end

-- Game modules (big feature sets with presets and a runner).
local GAME_MODULES: { Types.GameModuleSpec } = {
    require("./games/sandbox/Spec"),
}

Commands.specs = specs
Commands.games = GAME_MODULES
Commands.strings = STRING_MODULES
Commands.VERSION = "1.0.0"

return Commands
