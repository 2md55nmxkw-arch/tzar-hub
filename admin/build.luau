--!strict
-- lune run build            bundle public/tzar-admin.lua and write public/tzar-admin-commands.json
-- lune run build -- --check fail if either committed file is out of date (CI)

local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local Commands = require("./src/Commands")

local OUT_SCRIPT = "../public/tzar-admin.lua"
local OUT_JSON = "../public/tzar-admin-commands.json"
local TMP = "build/tzar-admin.lua"
local CATEGORIES = { "avatar", "character", "camera", "visual", "utility", "hub" }
local LANGS = { "en", "ru", "uk", "es", "pt", "de" }

local check = table.find(process.args, "--check") ~= nil

local function fail(msg: string)
    print("build: " .. msg)
    process.exit(1)
end

-- Bundle
if not fs.isDir("build") then
    fs.writeDir("build")
end
local darklua = process.env.DARKLUA or "darklua"
local res = process.exec(darklua, { "process", "src/main.luau", TMP, "--config", ".darklua.json" })
if not res.ok then
    fail("darklua failed\n" .. res.stdout .. res.stderr)
end
local header = "-- TZAR Hub Admin "
    .. Commands.VERSION
    .. " · https://hub.2md.space/tzar-admin.lua\n"
local script = header .. fs.readFile(TMP)

-- Command list for the docs page
local strings: { [string]: { [string]: any } } = {}
for _, lang in LANGS do
    strings[lang] = {}
end
for _, bundle in Commands.strings do
    for lang, map in bundle do
        if strings[lang] then
            for k, v in map do
                strings[lang][k] = v
            end
        end
    end
end
local function localized(key: string): { [string]: string }
    local out = {}
    for _, lang in LANGS do
        local v = strings[lang][key] or strings.en[key]
        if type(v) ~= "string" then
            fail("missing string " .. key)
        end
        out[lang] = v
    end
    return out
end

local commands = {}
for _, s in Commands.specs do
    local args = {}
    for _, a in s.args or {} do
        table.insert(args, {
            name = a.name,
            kind = a.kind,
            optional = a.optional == true,
            min = a.min,
            max = a.max,
            options = a.options,
        })
    end
    table.insert(commands, {
        name = s.name,
        aliases = s.aliases or {},
        category = s.category,
        kind = s.kind,
        args = args,
        title = localized("c." .. s.name),
        description = localized("d." .. s.name),
    })
end
local categories = {}
for _, c in CATEGORIES do
    table.insert(categories, { id = c, title = localized("cat." .. c) })
end

-- Every language must have every key English has.
local missing = {}
for key in strings.en do
    for _, lang in LANGS do
        if strings[lang][key] == nil then
            table.insert(missing, lang .. ":" .. key)
        end
    end
end
if #missing > 0 then
    table.sort(missing)
    fail("untranslated strings:\n  " .. table.concat(missing, "\n  "))
end

local json = serde.encode("json", {
    version = Commands.VERSION,
    categories = categories,
    commands = commands,
}, true) .. "\n"

if check then
    local stale = {}
    if not fs.isFile(OUT_SCRIPT) or fs.readFile(OUT_SCRIPT) ~= script then
        table.insert(stale, OUT_SCRIPT)
    end
    if not fs.isFile(OUT_JSON) or fs.readFile(OUT_JSON) ~= json then
        table.insert(stale, OUT_JSON)
    end
    if #stale > 0 then
        fail("out of date, run `lune run build`: " .. table.concat(stale, ", "))
    end
    print("build: up to date")
else
    fs.writeFile(OUT_SCRIPT, script)
    fs.writeFile(OUT_JSON, json)
    print(
        string.format(
            "build: %s (%d KB), %d commands",
            OUT_SCRIPT,
            math.floor(#script / 1024),
            #commands
        )
    )
end
