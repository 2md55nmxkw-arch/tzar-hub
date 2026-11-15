--!strict
-- lune run tests/unit/fuzzy
local process = require("@lune/process")

local Fuzzy = require("../../src/core/Fuzzy")

local failures = 0
local function eq(name: string, got: any, want: any)
    if got ~= want then
        failures += 1
        print(string.format("FAIL %s: got %s, want %s", name, tostring(got), tostring(want)))
    end
end

eq(
    "exact beats prefix",
    (Fuzzy.score("fly", "fly") :: number) > (Fuzzy.score("fly", "flyspeed") :: number),
    true
)
eq(
    "prefix beats scattered",
    (Fuzzy.score("fs", "flyspeed") :: number) > (Fuzzy.score("fs", "fullbright") or -1e9),
    true
)
eq("not a subsequence", Fuzzy.score("xyz", "fly"), nil)
eq("empty query", Fuzzy.score("", "fly"), 0)
local marks = {}
Fuzzy.score("ro", "@ro_mka", marks)
eq("marks first", marks[1], 2)
eq("marks second", marks[2], 3)
eq("distance swap", Fuzzy.distance("hlep", "help"), 1)
eq("distance same", Fuzzy.distance("fly", "FLY"), 0)
eq("distance insert", Fuzzy.distance("noclp", "noclip"), 1)

if failures > 0 then
    process.exit(1)
end
print("fuzzy: ok")
