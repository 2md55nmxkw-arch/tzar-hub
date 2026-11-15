--!strict
-- What every panel builder gets.

local I18n = require("../../core/I18n")
local Log = require("../../core/Log")
local Rows = require("../spot/Rows")
local Types = require("../../Types")

export type Deps = Rows.Deps & {
    toast: (kind: Types.Toast, text: string) -> (),
    i18n: I18n.I18n,
    log: Log.Log,
    info: () -> string,
    setLang: (code: string) -> (),
    openBar: (prefill: string?) -> (),
    unload: () -> (),
}

return nil
