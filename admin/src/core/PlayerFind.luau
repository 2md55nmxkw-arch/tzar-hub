--!strict
-- Finds players on the server by username or display name. Read-only: nothing here touches them.

local Players = game:GetService("Players")

local Fuzzy = require("./Fuzzy")

export type Hit = {
    player: Player,
    score: number,
    why: "name" | "display" | "me",
    marksName: { number },
    marksDisplay: { number },
}

local PlayerFind = {}

local SCORE_ME = 2000

local function scoreField(query: string, text: string, marks: { number }): number?
    -- Prefer contiguous substring hits over scattered ones for names.
    local q, t = string.lower(query), string.lower(text)
    local at = string.find(t, q, 1, true)
    if at then
        for i = 1, #q do
            marks[i] = at + i - 1
        end
        local bonus = if at == 1 then 600 else 300
        return bonus - #t
    end
    return Fuzzy.score(query, text, marks)
end

function PlayerFind.search(query: string, includeSelf: boolean?): { Hit }
    local lp = Players.LocalPlayer
    local hits: { Hit } = {}
    local q = string.gsub(query, "^@", "")
    for _, p in Players:GetPlayers() do
        if p == lp and not includeSelf then
            continue
        end
        if q == "" then
            local hit: Hit =
                { player = p, score = 0, why = "name", marksName = {}, marksDisplay = {} }
            table.insert(hits, hit)
            continue
        end
        local mn: { number }, md: { number } = {}, {}
        local sn = scoreField(q, p.Name, mn)
        local sd = if p.DisplayName ~= p.Name then scoreField(q, p.DisplayName, md) else nil
        if sn or sd then
            local useDisplay = sd ~= nil and (sn == nil or (sd :: number) > (sn :: number))
            local hit: Hit = {
                player = p,
                score = if useDisplay then sd :: number else sn :: number,
                why = if useDisplay then "display" else "name",
                marksName = if useDisplay then {} else mn,
                marksDisplay = if useDisplay then md else {},
            }
            table.insert(hits, hit)
        end
    end
    if includeSelf and (q == "me" or q == "") then
        for _, h in hits do
            if h.player == lp then
                h.score = SCORE_ME
                h.why = "me"
            end
        end
    end
    table.sort(hits, function(a: Hit, b: Hit)
        if a.score ~= b.score then
            return a.score > b.score
        end
        return a.player.Name < b.player.Name
    end)
    return hits
end

-- Exact name, then exact display name, then the single best partial hit.
function PlayerFind.resolve(query: string, includeSelf: boolean?): Player?
    local lp = Players.LocalPlayer
    local q = string.lower((string.gsub(query, "^@", "")))
    if q == "me" then
        return lp
    end
    for _, p in Players:GetPlayers() do
        if string.lower(p.Name) == q and (includeSelf or p ~= lp) then
            return p
        end
    end
    for _, p in Players:GetPlayers() do
        if string.lower(p.DisplayName) == q and (includeSelf or p ~= lp) then
            return p
        end
    end
    local hits = PlayerFind.search(q, includeSelf)
    return if hits[1] then hits[1].player else nil
end

return PlayerFind
