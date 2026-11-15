--!strict
-- Tokenizer and argument parsers. Each parser returns a value or an error string, and each kind
-- can list suggestions for the palette and the tap-to-pick rows.

local Fuzzy = require("./Fuzzy")
local PlayerFind = require("./PlayerFind")
local Types = require("../Types")

type ArgSpec = Types.ArgSpec
type Suggestion = Types.Suggestion

export type Ctx = {
    t: (key: string, ...any) -> string,
    -- Names for outfit / waypoint / emote / command kinds.
    list: (kind: string) -> { string },
}

local Args = {}

local TRUE_WORDS = table.freeze({
    "on",
    "true",
    "1",
    "yes",
    "вкл",
    "да",
    "увімк",
    "так",
    "sí",
    "si",
    "sim",
    "ligado",
    "an",
    "ein",
    "ja",
})
local FALSE_WORDS = table.freeze({
    "off",
    "false",
    "0",
    "no",
    "выкл",
    "нет",
    "вимк",
    "ні",
    "não",
    "nao",
    "desligado",
    "aus",
    "nein",
})

function Args.parseBool(token: string): boolean?
    local t = string.lower(token)
    if table.find(TRUE_WORDS, t) then
        return true
    elseif table.find(FALSE_WORDS, t) then
        return false
    end
    return nil
end

-- Splits on spaces; "double quotes" keep a phrase together. Also returns whether the line
-- ends in whitespace, so the palette knows the user moved on to the next argument.
function Args.tokenize(line: string): ({ string }, boolean)
    local out: { string } = {}
    local i, n = 1, #line
    while i <= n do
        local c = string.sub(line, i, i)
        if c == " " or c == "\t" then
            i += 1
        elseif c == '"' then
            local close = string.find(line, '"', i + 1, true)
            local stop = close or (n + 1)
            table.insert(out, string.sub(line, i + 1, stop - 1))
            i = stop + 1
        else
            local stop = string.find(line, "[ \t]", i) or (n + 1)
            table.insert(out, string.sub(line, i, stop - 1))
            i = stop
        end
    end
    local trailing = n > 0 and string.match(string.sub(line, n, n), "%s") ~= nil
    return out, trailing
end

local function keyFromName(token: string): Enum.KeyCode?
    local lower = string.lower(token)
    for _, item in Enum.KeyCode:GetEnumItems() do
        if string.lower(item.Name) == lower then
            return item
        end
    end
    return nil
end
Args.keyFromName = keyFromName

local function pickName(list: { string }, token: string): string?
    local lower = string.lower(token)
    for _, name in list do
        if string.lower(name) == lower then
            return name
        end
    end
    local best, bestScore = nil, -math.huge
    for _, name in list do
        local s = Fuzzy.score(token, name)
        if s and s > bestScore then
            best, bestScore = name, s
        end
    end
    return best
end

-- Returns (value, nil) or (nil, error message).
function Args.parse(spec: ArgSpec, token: string, ctx: Ctx): (any, string?)
    local kind = spec.kind
    if kind == "string" or kind == "rest" then
        return token, nil
    elseif kind == "number" then
        local n = tonumber(token)
        local lo, hi = spec.min or -math.huge, spec.max or math.huge
        if not n or n ~= n or n < lo or n > hi then
            return nil, ctx.t("arg.number", spec.min or "-∞", spec.max or "∞")
        end
        return n, nil
    elseif kind == "boolean" then
        local b = Args.parseBool(token)
        if b == nil then
            return nil, ctx.t("arg.boolean")
        end
        return b, nil
    elseif kind == "enum" then
        local opts = spec.options or {}
        local found = pickName(opts, token)
        if not found or not string.find(string.lower(found), string.lower(token), 1, true) then
            return nil, ctx.t("arg.enum", table.concat(opts, ", "))
        end
        return found, nil
    elseif kind == "player" then
        local p = PlayerFind.resolve(token, true)
        if not p then
            return nil, ctx.t("arg.player", token)
        end
        return p, nil
    elseif kind == "user" then
        -- Digits are a user id, unless a player here is named exactly that; a fuzzy match on
        -- "1" would otherwise pick whoever has a 1 in their name.
        if string.match(token, "^%d+$") then
            local exact = game:GetService("Players"):FindFirstChild(token)
            return if exact and exact:IsA("Player") then exact else token, nil
        end
        -- A server player if one matches, otherwise the raw username for a web lookup.
        local p = PlayerFind.resolve(token, true)
        return p or token, nil
    elseif kind == "key" then
        local k = keyFromName(token)
        if not k then
            return nil, ctx.t("arg.key", token)
        end
        return k, nil
    elseif kind == "emote" and string.match(token, "^%d+$") then
        -- An emote asset id works even when it is not on the wheel yet.
        return token, nil
    else
        local found = pickName(ctx.list(kind), token)
        if not found then
            return nil, ctx.t("arg." .. kind, token)
        end
        return found, nil
    end
end

local function playerSuggestions(query: string, ctx: Ctx): { Suggestion }
    local out: { Suggestion } = {}
    for _, h in PlayerFind.search(query, true) do
        local p = h.player
        table.insert(
            out,
            {
                text = p.Name,
                label = p.DisplayName,
                sub = "@" .. p.Name,
                why = if h.why == "display"
                    then ctx.t("ui.why.display")
                    elseif h.why == "me" then ctx.t("ui.why.me")
                    else ctx.t("ui.why.name"),
                marks = h.marksDisplay,
                subMarks = h.marksName,
                score = h.score,
                player = p,
            } :: any
        )
    end
    return out
end

local function listSuggestions(list: { string }, query: string): { Suggestion }
    local out: { Suggestion } = {}
    for _, name in list do
        local marks = {}
        local s = Fuzzy.score(query, name, marks)
        if s then
            table.insert(out, { text = name, label = name, marks = marks, score = s })
        end
    end
    table.sort(out, function(a: Suggestion, b: Suggestion)
        return a.score > b.score
    end)
    return out
end

function Args.suggest(spec: ArgSpec, query: string, ctx: Ctx): { Suggestion }
    local kind = spec.kind
    if kind == "player" or kind == "user" then
        return playerSuggestions(query, ctx)
    elseif kind == "boolean" then
        return listSuggestions({ "on", "off" }, query)
    elseif kind == "enum" then
        return listSuggestions(spec.options or {}, query)
    elseif kind == "key" then
        if query == "" then
            return {}
        end
        local names = {}
        for _, item in Enum.KeyCode:GetEnumItems() do
            table.insert(names, item.Name)
        end
        local out = listSuggestions(names, query)
        for i = #out, 9, -1 do
            out[i] = nil
        end
        return out
    elseif kind == "number" or kind == "string" or kind == "rest" then
        return {}
    end
    return listSuggestions(ctx.list(kind), query)
end

return Args
