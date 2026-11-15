--!strict
-- Shared types. Specs are plain data so the build can read them outside Roblox.

export type Lang = "ru" | "en" | "uk" | "es" | "pt" | "de"

export type Category = "avatar" | "character" | "camera" | "visual" | "utility" | "hub"

export type ArgKind =
    "player"
    | "user"
    | "number"
    | "boolean"
    | "enum"
    | "string"
    | "rest"
    | "key"
    | "outfit"
    | "waypoint"
    | "emote"
    | "command"
    | "module"
    | "preset"

export type ArgSpec = {
    name: string,
    kind: ArgKind,
    optional: boolean?,
    min: number?,
    max: number?,
    step: number?,
    options: { string }?,
}

-- action: runs once. toggle: on/off state. value: holds a value; no argument restores the original.
export type CommandKind = "action" | "toggle" | "value"

export type CommandSpec = {
    name: string,
    aliases: { string }?,
    category: Category,
    kind: CommandKind,
    args: { ArgSpec }?,
    module: string,
    -- Re-run enable on respawn while active, for commands that touch the character.
    respawn: boolean?,
    -- Shown in the value chip before the user sets anything.
    default: number?,
    -- Executor functions the command cannot work without.
    needs: { string }?,
    -- Icon file name (without .png) for the dock and the command bar.
    icon: string?,
    -- Quick values offered next to the slider; derived from the default when missing.
    presets: { number }?,
}

-- Game modules: big feature sets (dozens of toggles) with sections, presets and a runner.
-- "toggle" is on/off, "number" holds a value (off = the game's own), "choice" picks an option.
export type FeatureKind = "toggle" | "number" | "choice"

export type Feature = {
    id: string,
    section: string,
    kind: FeatureKind,
    -- Number features: range and the value shown while off.
    min: number?,
    max: number?,
    step: number?,
    default: number?,
    -- Choice features: option ids (titles come from strings).
    options: { string }?,
    -- Drive a hub command instead of a module handler: toggles run "<cmd> on|off",
    -- numbers run "<cmd> <value>" / "un<cmd>".
    command: string?,
}

export type PresetSpec = { id: string, values: { [string]: any } }

export type GameModuleSpec = {
    id: string,
    -- Place ids where the module applies; nil = every place.
    places: { number }?,
    badge: string?,
    badgeColor: string?,
    sections: { string },
    features: { Feature },
    presets: { PresetSpec }?,
    -- Has a start/pause/stop routine.
    runner: boolean?,
}

export type Toast = "info" | "ok" | "error"

-- A plural entry lists forms: ru/uk use {one, few, many}, the rest {one, other}.
export type I18nValue = string | { string }
export type Bundle = { [string]: { [string]: I18nValue } }

export type Suggestion = {
    text: string, -- what Tab inserts
    label: string,
    sub: string?,
    why: string?,
    marks: { number }?, -- matched character positions in label
    subMarks: { number }?,
    score: number,
    player: Player?,
}

return nil
