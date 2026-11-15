--!strict
-- The only place that touches executor functions. Each one is optional: callers get a plain
-- result or nil and the hub keeps working on executors that lack it.

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

export type Response = { ok: boolean, status: number, body: string }

local Env = {}

local CAP_NAMES = table.freeze({
    "getgenv",
    "gethui",
    "writefile",
    "readfile",
    "isfile",
    "isfolder",
    "makefolder",
    "request",
    "setclipboard",
    "getcustomasset",
    "sethiddenproperty",
    "gethiddenproperty",
    "getconnections",
    "queue_on_teleport",
    "identifyexecutor",
    "cloneref",
})
Env.CAP_NAMES = CAP_NAMES

-- Reading a missing global yields nil at runtime, so this table is safe on any executor.
local globals: { [string]: any } = {
    getgenv = getgenv,
    gethui = gethui,
    writefile = writefile,
    readfile = readfile,
    isfile = isfile,
    isfolder = isfolder,
    makefolder = makefolder,
    request = request,
    setclipboard = setclipboard,
    getcustomasset = getcustomasset,
    sethiddenproperty = sethiddenproperty,
    gethiddenproperty = gethiddenproperty,
    getconnections = getconnections,
    queue_on_teleport = queue_on_teleport,
    identifyexecutor = identifyexecutor,
    cloneref = cloneref,
}
local caps: { [string]: boolean } = {}
for _, name in CAP_NAMES do
    caps[name] = type(globals[name]) == "function"
end
Env.caps = table.freeze(caps)

local function fn(name: string): any
    return if caps[name] then globals[name] else nil
end

function Env.has(name: string): boolean
    return caps[name] == true
end

function Env.genv(): { [string]: any }
    local g = fn("getgenv")
    if g then
        local ok, t = pcall(g)
        if ok and type(t) == "table" then
            return t
        end
    end
    -- selene: allow(global_usage)
    return _G
end

-- gethui hides our GUI from the game's own scripts; CoreGui and then PlayerGui are fallbacks.
function Env.guiParent(): Instance
    local h = fn("gethui")
    if h then
        local ok, parent = pcall(h)
        if ok and typeof(parent) == "Instance" then
            return parent
        end
    end
    local ok = pcall(function()
        local probe = Instance.new("Folder")
        probe.Parent = CoreGui
        probe:Destroy()
    end)
    if ok then
        return CoreGui
    end
    local lp = Players.LocalPlayer
    return lp:WaitForChild("PlayerGui")
end

function Env.readFile(path: string): string?
    local isfile, readfile = fn("isfile"), fn("readfile")
    if not (isfile and readfile) then
        return nil
    end
    local ok, exists = pcall(isfile, path)
    if not ok or not exists then
        return nil
    end
    local ok2, body = pcall(readfile, path)
    return if ok2 and type(body) == "string" then body else nil
end

local function ensureFolder(path: string)
    local isfolder, makefolder = fn("isfolder"), fn("makefolder")
    if not (isfolder and makefolder) then
        return
    end
    local acc = ""
    for part in string.gmatch(path, "[^/]+") do
        acc = if acc == "" then part else acc .. "/" .. part
        local ok, exists = pcall(isfolder, acc)
        if ok and not exists then
            pcall(makefolder, acc)
        end
    end
end

function Env.writeFile(path: string, body: string): boolean
    local writefile = fn("writefile")
    if not writefile then
        return false
    end
    local dir = string.match(path, "^(.*)/[^/]+$")
    if dir then
        ensureFolder(dir)
    end
    return (pcall(writefile, path, body))
end

function Env.clipboard(text: string): boolean
    local set = fn("setclipboard")
    return if set then (pcall(set, text)) else false
end

function Env.http(url: string, method: string?): Response?
    local req = fn("request")
    if req then
        local ok, res = pcall(req, { Url = url, Method = method or "GET" })
        if ok and type(res) == "table" then
            local status = tonumber(res.StatusCode) or 0
            return {
                ok = status >= 200 and status < 300,
                status = status,
                body = tostring(res.Body or ""),
            }
        end
        return nil
    end
    local ok, body = pcall(function()
        return (game :: any):HttpGet(url)
    end)
    return if ok then { ok = true, status = 200, body = body } else nil
end

function Env.json(body: string): any
    local ok, v = pcall(HttpService.JSONDecode, HttpService, body)
    return if ok then v else nil
end

function Env.executor(): (string, string)
    local id = fn("identifyexecutor")
    if id then
        local ok, name, ver = pcall(id)
        if ok then
            return tostring(name or "?"), tostring(ver or "")
        end
    end
    return "Unknown", ""
end

function Env.exists(path: string): boolean
    local isfile = fn("isfile")
    if not isfile then
        return false
    end
    local ok, yes = pcall(isfile, path)
    return ok and yes == true
end

function Env.customAsset(path: string): string?
    local get = fn("getcustomasset")
    if not get or not Env.exists(path) then
        return nil
    end
    local ok, id = pcall(get, path)
    return if ok and type(id) == "string" then id else nil
end

-- Hidden properties (MeshPart.InitialSize); nil / false when the executor cannot reach them.
function Env.getHidden(inst: Instance, prop: string): any
    local get = fn("gethiddenproperty")
    if not get then
        return nil
    end
    local ok, v = pcall(get, inst, prop)
    return if ok then v else nil
end

function Env.setHidden(inst: Instance, prop: string, value: any): boolean
    local set = fn("sethiddenproperty")
    return if set then (pcall(set, inst, prop, value)) else false
end

function Env.queueOnTeleport(source: string): boolean
    local q = fn("queue_on_teleport")
    return if q then (pcall(q, source)) else false
end

return Env
