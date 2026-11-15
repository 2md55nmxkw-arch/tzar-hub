--!strict
-- What the command bar shows for a line of text: home (empty), command search, or suggestions for
-- the argument under the cursor. Also turns a picked suggestion into the next line.

local Args = require("../../core/Args")
local Format = require("../Format")
local Fuzzy = require("../../core/Fuzzy")
local Modules = require("../../core/Modules")
local Registry = require("../../core/Registry")
local Types = require("../../Types")

type Spec = Types.CommandSpec

export type Mode = "home" | "command" | "args" | "unknown"

export type Analysis = {
    mode: Mode,
    query: string,
    spec: Spec?,
    argIndex: number,
    arg: Types.ArgSpec?,
    tokens: { string },
    trailing: boolean,
}

-- "command" | "player" | "value" | "line"
export type ItemKind = string

export type Item = {
    kind: ItemKind,
    text: string, -- what goes into the line
    label: string,
    sub: string?,
    tag: string?,
    marks: { number }?,
    subMarks: { number }?,
    score: number,
    spec: Spec?,
    player: Player?,
    -- Group title for items that are not plain commands (modules and their sets).
    group: string?,
}

export type Group = { title: string?, items: { Item } }

local Analyze = {}

local MAX_COMMANDS = 8
local MAX_SUGGESTIONS = 8
local MAX_RECENT = 4

function Analyze.line(text: string, registry: Registry.Registry): Analysis
    local tokens, trailing = Args.tokenize(text)
    if #tokens == 0 then
        return { mode = "home", query = "", argIndex = 0, tokens = tokens, trailing = trailing }
    end
    if #tokens == 1 and not trailing then
        return {
            mode = "command",
            query = tokens[1],
            argIndex = 0,
            tokens = tokens,
            trailing = trailing,
        }
    end
    local spec = registry:Resolve(tokens[1])
    if not spec then
        return {
            mode = "unknown",
            query = tokens[1],
            argIndex = 0,
            tokens = tokens,
            trailing = trailing,
        }
    end
    local first = 2
    if
        spec.kind == "toggle"
        and tokens[2]
        and Args.parseBool(tokens[2]) ~= nil
        and (trailing or #tokens > 2)
    then
        first = 3
    end
    local given = #tokens - first + 1
    local idx = if trailing then given + 1 else math.max(given, 1)
    local args = spec.args or {}
    local arg = args[idx]
    if not arg and #args > 0 and args[#args].kind == "rest" then
        arg = args[#args]
        idx = #args
    end
    return {
        mode = "args",
        query = if trailing then "" else (tokens[#tokens] or ""),
        spec = spec,
        argIndex = idx,
        arg = arg,
        tokens = tokens,
        trailing = trailing,
    }
end

-- Commands matching the query, best first, grouped by category in order of their best hit.
function Analyze.commands(
    q: string,
    registry: Registry.Registry,
    t: (string, ...any) -> string,
    extra: { Item }?
): { Group }
    local found: { Item } = {}
    for _, item in extra or {} do
        table.insert(found, item)
    end
    local un = string.sub(string.lower(q), 1, 2) == "un" and #q > 2
    for _, spec in registry.specs do
        if registry:IsDisabled(spec.name) then
            continue
        end
        local marks: { number } = {}
        local best = Fuzzy.score(q, spec.name, marks)
        local via: string? = nil
        for _, a in spec.aliases or {} do
            local s = Fuzzy.score(q, a)
            if s and (not best or s > best) then
                best, via, marks = s, a, {}
            end
        end
        if un and spec.kind ~= "action" then
            local m2: { number } = {}
            local s = Fuzzy.score(q, "un" .. spec.name, m2)
            if s and (not best or s > best) then
                best, via, marks = s, nil, m2
                table.insert(found, {
                    kind = "command",
                    text = "un" .. spec.name,
                    label = "un" .. spec.name,
                    sub = t("d." .. spec.name),
                    marks = m2,
                    score = s,
                    spec = spec,
                })
                continue
            end
        end
        if best then
            table.insert(found, {
                kind = "command",
                text = spec.name,
                label = spec.name,
                sub = t("d." .. spec.name),
                tag = via,
                marks = marks,
                score = best,
                spec = spec,
            })
        end
    end
    table.sort(found, function(a: Item, b: Item)
        return a.score > b.score
    end)
    local groups: { Group } = {}
    local byCat: { [string]: Group } = {}
    for i, item in found do
        if i > MAX_COMMANDS then
            break
        end
        local cat = item.group or (item.spec :: Spec).category
        local g: Group? = byCat[cat]
        if not g then
            local fresh: Group = { title = item.group or t("cat." .. cat), items = {} }
            byCat[cat] = fresh
            table.insert(groups, fresh)
            g = fresh
        end
        table.insert((g :: Group).items, item)
    end
    return groups
end

local function moduleItem(
    s: Types.GameModuleSpec,
    registry: Registry.Registry,
    t: (string, ...any) -> string,
    score: number
): Item
    return {
        kind = "line",
        text = "module " .. s.id,
        label = t("m." .. s.id .. ".title"),
        sub = t("m." .. s.id .. ".desc"),
        score = score,
        spec = registry:Get("module"),
        group = t("sp.modules"),
    }
end

-- Game modules and their sets that match the query, as lines that open or toggle them.
function Analyze.modules(
    q: string,
    modules: Modules.Modules,
    registry: Registry.Registry,
    t: (string, ...any) -> string
): { Item }
    local out: { Item } = {}
    if registry:IsDisabled("module") or not registry:Get("module") then
        return out
    end
    local function best(...: string): number?
        local top: number? = nil
        for _, s in { ... } do
            local v = Fuzzy.score(q, s)
            if v and (not top or v > top) then
                top = v
            end
        end
        return top
    end
    for _, s in modules:Available() do
        local title = t("m." .. s.id .. ".title")
        local score = best(s.id, title)
        if score then
            table.insert(out, moduleItem(s, registry, t, score))
        end
        if registry:IsDisabled("preset") then
            continue
        end
        for _, p in modules:Presets(s.id) do
            local pt = modules:PresetTitle(s.id, p)
            local key = modules:PresetKey(s.id, p)
            local ps = best(pt, p.id, key)
            if ps then
                table.insert(out, {
                    kind = "line",
                    text = "preset " .. key,
                    label = pt,
                    sub = title,
                    score = ps - 1,
                    spec = registry:Get("preset"),
                    group = t("sp.modules"),
                })
            end
        end
    end
    return out
end

-- Suggestions for the argument under the cursor.
function Analyze.suggestions(
    a: Analysis,
    registry: Registry.Registry,
    t: (string, ...any) -> string
): { Group }
    local arg = a.arg
    if not arg then
        return {}
    end
    local argCtx: Args.Ctx = {
        t = t,
        list = function(kind: string)
            return registry:List(kind)
        end,
    }
    local items: { Item } = {}
    for i, s in Args.suggest(arg, a.query, argCtx) do
        if i > MAX_SUGGESTIONS then
            break
        end
        table.insert(items, {
            kind = if s.player then "player" else "value",
            text = s.text,
            label = s.label,
            sub = s.sub,
            tag = s.why,
            marks = s.marks,
            subMarks = s.subMarks,
            score = s.score,
            player = s.player,
        })
    end
    if #items == 0 then
        return {}
    end
    local title = if arg.kind == "player" or arg.kind == "user" then t("sp.players") else arg.name
    return { { title = title, items = items } }
end

-- Recent lines and pinned commands for the empty bar.
function Analyze.home(
    registry: Registry.Registry,
    history: { string },
    pins: { string },
    t: (string, ...any) -> string,
    modules: Modules.Modules?
): { Group }
    local groups: { Group } = {}
    local recent: { Item } = {}
    local seen: { [string]: boolean } = {}
    for i = #history, 1, -1 do
        local line = history[i]
        if not seen[line] then
            seen[line] = true
            local word = string.match(line, "^%S+") or line
            local spec = registry:Resolve(word)
            if spec then
                table.insert(
                    recent,
                    { kind = "line", text = line, label = line, score = 0, spec = spec }
                )
            end
        end
        if #recent >= MAX_RECENT then
            break
        end
    end
    if #recent > 0 then
        table.insert(groups, { title = t("sp.recent"), items = recent })
    end
    local fav: { Item } = {}
    for _, name in pins do
        local spec = registry:Get(name)
        if spec and not registry:IsDisabled(name) then
            table.insert(fav, {
                kind = "command",
                text = spec.name,
                label = spec.name,
                sub = t("d." .. spec.name),
                score = 0,
                spec = spec,
            })
        end
    end
    if #fav > 0 then
        table.insert(groups, { title = t("sp.favorites"), items = fav })
    end
    if modules and registry:Get("module") and not registry:IsDisabled("module") then
        local mods: { Item } = {}
        for _, s in modules:Available() do
            table.insert(mods, moduleItem(s, registry, t, 0))
        end
        if #mods > 0 then
            table.insert(groups, { title = t("sp.modules"), items = mods })
        end
    end
    return groups
end

-- The line after picking `item`, and whether it is complete enough to run.
function Analyze.accept(text: string, a: Analysis, item: Item?): (string, boolean)
    if a.mode == "home" then
        if not item then
            return text, false
        end
        local spec = item.spec
        if item.kind == "line" then
            return item.text, true
        end
        local needs = spec and Format.requiredArg(spec)
        return item.text .. (if needs then " " else ""), needs == nil
    elseif a.mode == "command" then
        if not item then
            return text, true
        end
        if item.kind == "line" then
            return item.text, true
        end
        local spec = item.spec
        local needs = spec and string.sub(item.text, 1, 2) ~= "un" and Format.requiredArg(spec)
        return item.text .. (if needs then " " else ""), not needs
    elseif a.mode == "args" then
        local spec = a.spec :: Spec
        local line = text
        if item and a.arg then
            line = string.sub(text, 1, #text - #a.query) .. Format.quote(item.text)
        end
        local lastReq = 0
        for i, arg in spec.args or {} do
            if not arg.optional then
                lastReq = i
            end
        end
        local ready = a.argIndex >= lastReq
        if not ready then
            line ..= " "
        end
        return line, ready
    end
    return text, true
end

return Analyze
