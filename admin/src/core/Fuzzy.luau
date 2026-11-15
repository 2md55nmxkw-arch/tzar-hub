--!strict
-- Subsequence matcher for the palette. Prefix and word-start hits score higher, gaps lower.
-- Returns nil when the query is not a subsequence of the target.

local Fuzzy = {}

local SCORE = table.freeze({
    EXACT = 1000,
    PREFIX = 400,
    CHAR = 10,
    CONSECUTIVE = 15,
    WORD_START = 25,
    GAP = -1,
    LENGTH = -0.5,
})

local function isBoundary(prev: string): boolean
    return prev == " " or prev == "_" or prev == "-" or prev == "." or prev == "@"
end

-- `marks` (optional) receives the 1-based positions of matched characters.
function Fuzzy.score(query: string, target: string, marks: { number }?): number?
    if query == "" then
        return 0
    end
    local q, t = string.lower(query), string.lower(target)
    if q == t then
        if marks then
            for i = 1, #t do
                marks[i] = i
            end
        end
        return SCORE.EXACT
    end
    local score = 0
    local ti = 1
    local last = 0
    for qi = 1, #q do
        local c = string.sub(q, qi, qi)
        local found = string.find(t, c, ti, true)
        if not found then
            return nil
        end
        score += SCORE.CHAR
        if found == last + 1 then
            score += SCORE.CONSECUTIVE
        elseif last > 0 then
            score += SCORE.GAP * (found - last - 1)
        end
        if found == 1 or isBoundary(string.sub(t, found - 1, found - 1)) then
            score += SCORE.WORD_START
        end
        if marks then
            marks[qi] = found
        end
        last = found
        ti = found + 1
    end
    if string.sub(t, 1, #q) == q then
        score += SCORE.PREFIX
    end
    return score + SCORE.LENGTH * (#t - #q)
end

-- Edit distance with adjacent swaps (Damerau / optimal string alignment), so "hlep" is 1 from "help".
function Fuzzy.distance(a: string, b: string): number
    a, b = string.lower(a), string.lower(b)
    local n, m = #a, #b
    if n == 0 then
        return m
    elseif m == 0 then
        return n
    end
    local prev2: { number } = {}
    local prev: { number } = {}
    for j = 0, m do
        prev[j] = j
    end
    for i = 1, n do
        local cur: { number } = { [0] = i }
        local ai = string.byte(a, i)
        for j = 1, m do
            local bj = string.byte(b, j)
            local cost = if ai == bj then 0 else 1
            local v = math.min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost)
            if i > 1 and j > 1 and ai == string.byte(b, j - 1) and string.byte(a, i - 1) == bj then
                v = math.min(v, prev2[j - 2] + 1)
            end
            cur[j] = v
        end
        prev2, prev = prev, cur
    end
    return prev[m]
end

return Fuzzy
