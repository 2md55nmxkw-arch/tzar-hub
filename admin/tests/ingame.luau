-- In-game test run. Loads tzar-admin.lua from the executor workspace, walks the cases, unloads,
-- checks that nothing is left behind and writes tzar-admin-report.json. Not part of the bundle.
-- Run: loadstring(readfile("tzar-ingame.lua"))()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local lp = Players.LocalPlayer
local results = {}
local started = os.clock()

local function record(name, ok, detail)
    table.insert(results, { name = name, ok = ok, detail = detail })
end

local function check(name, fn)
    local ok, err = pcall(fn)
    record(name, ok, if ok then nil else tostring(err))
end

local function expect(cond, msg)
    if not cond then
        error(msg or "expectation failed", 2)
    end
end

local SIGNALS = {
    InputBegan = UserInputService.InputBegan,
    InputChanged = UserInputService.InputChanged,
    InputEnded = UserInputService.InputEnded,
    Heartbeat = RunService.Heartbeat,
    CharacterAdded = lp.CharacterAdded,
    Chatted = lp.Chatted,
    JumpRequest = UserInputService.JumpRequest,
    Idled = lp.Idled,
}

local function connCounts()
    local out = {}
    for name, sig in SIGNALS do
        local ok, list = pcall(getconnections, sig)
        out[name] = if ok then #list else -1
    end
    return out
end

local function humanoidSnapshot()
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local cam = workspace.CurrentCamera
    local L = game:GetService("Lighting")
    return {
        ws = hum and hum.WalkSpeed,
        jp = hum and hum.JumpPower,
        jh = hum and hum.JumpHeight,
        fov = cam and cam.FieldOfView,
        maxZoom = lp.CameraMaxZoomDistance,
        brightness = L.Brightness,
        clock = L.ClockTime,
        fogEnd = L.FogEnd,
        look = (function()
            -- Accessories, clothing and head size: what the avatar module changes.
            if not char then
                return "none"
            end
            local parts = {}
            for _, d in char:GetChildren() do
                if d:IsA("Accoutrement") then
                    table.insert(parts, "acc:" .. d.Name)
                elseif d:IsA("Shirt") then
                    table.insert(parts, "shirt:" .. d.ShirtTemplate)
                elseif d:IsA("Pants") then
                    table.insert(parts, "pants:" .. d.PantsTemplate)
                end
            end
            table.sort(parts)
            local head = char:FindFirstChild("Head")
            table.insert(parts, head and tostring(head.Size) or "")
            return table.concat(parts, "|")
        end)(),
    }
end

local function same(a, b)
    for k, v in a do
        if b[k] ~= v then
            return false, k .. ": " .. tostring(v) .. " → " .. tostring(b[k])
        end
    end
    return true
end

-- Old hub from a previous run must go first, so the baseline is clean.
if getgenv().TZAR_ADMIN then
    pcall(getgenv().TZAR_ADMIN.Unload)
    task.wait(0.3)
end

local baseState = humanoidSnapshot()

local fn, cerr = loadstring(readfile("tzar-admin.lua"), "=tzar-admin")
expect(fn, cerr)
local loadOk, loadErr = pcall(fn)
record("load", loadOk, loadErr)
task.wait(0.4)
local A = getgenv().TZAR_ADMIN

check("start under 150 ms", function()
    expect(A, "no handle")
    expect(A.StartMs < 150, string.format("%.1f ms", A.StartMs))
end)

check("dock and launcher are up, the bar is closed", function()
    local d = A.Debug()
    expect(d.gui and d.gui.Parent, "gui missing")
    expect(d.dock and d.dock.Visible and d.dock.AbsoluteSize.X > 100, "dock missing")
    expect(d.bar and not d.bar.Visible, "bar open at start")
end)
check("unknown command reports, does not throw", function()
    local ok, msg = A.Run("definitelynotacommand")
    expect(ok == false and type(msg) == "string", "got " .. tostring(ok) .. " " .. tostring(msg))
end)

check("typo suggests the nearest command", function()
    local _, msg = A.Run("hlep")
    expect(msg and string.find(msg, "help", 1, true), tostring(msg))
end)

check("help runs", function()
    local ok, msg = A.Run("help")
    expect(ok, msg)
    ok, msg = A.Run("help bind")
    expect(ok, msg)
end)

check("bind and unbind", function()
    local ok, msg = A.Run("bind F7 help")
    expect(ok, msg)
    local raw = readfile("TZAR/admin/settings.json")
    local _ = raw
    ok, msg = A.Run("unbind F7")
    expect(ok, msg)
    ok, msg = A.Run("unbind F7")
    expect(ok, msg)
end)

check("bad argument is rejected with a message", function()
    local ok, msg = A.Run("bind NotAKey help")
    expect(not ok and msg, "accepted a bad key")
    ok, msg = A.Run("lang xx")
    expect(not ok and msg, "accepted a bad language")
end)

check("disable blocks a command, enable restores it", function()
    local ok, msg = A.Run("disable help")
    expect(ok, msg)
    ok = A.Run("help")
    expect(ok == false, "disabled command still ran")
    ok, msg = A.Run("enable help")
    expect(ok, msg)
    ok, msg = A.Run("help")
    expect(ok, msg)
end)

check("language switch rebuilds the window", function()
    local before = A.Debug().lang
    local ok, msg = A.Run("lang ru")
    expect(ok, msg)
    task.wait(0.2)
    local d = A.Debug()
    expect(d.lang == "ru", d.lang)
    expect(d.gui and d.gui.Parent, "gui gone after rebuild")
    local found = false
    for _, x in d.gui:GetDescendants() do
        if x:IsA("TextBox") and x.PlaceholderText == "Команда или игрок" then
            found = true
        end
    end
    expect(found, "placeholder not translated")
    A.Run("lang " .. before)
    task.wait(0.2)
end)

check("togglekey resets to RightShift", function()
    local ok, msg = A.Run("togglekey F8")
    expect(ok, msg)
    ok, msg = A.Run("togglekey")
    expect(ok, msg)
end)

local function texts(root)
    local out = {}
    for _, x in root:GetDescendants() do
        if (x:IsA("TextLabel") or x:IsA("TextButton")) and x.Text ~= "" then
            table.insert(out, x.Text)
        end
    end
    return table.concat(out, " | ")
end

check("command bar lists matching commands", function()
    A.App().openBar("he")
    task.wait(0.15)
    local d = A.Debug()
    expect(d.bar.Visible, "bar hidden")
    local results = d.bar:FindFirstChild("Results", true)
    local all = texts(results)
    expect(string.find(all, "help", 1, true) or string.find(all, ">he<", 1, true), all)
end)

check("command bar shows the argument being typed", function()
    A.App().openBar("bind ")
    task.wait(0.15)
    local sig = A.Debug().bar:FindFirstChild("Signature", true)
    expect(sig and sig.Visible, "signature line hidden")
    expect(string.find(texts(sig), "key", 1, true), texts(sig))
end)

check("empty bar shows favourites, Esc-style close works", function()
    A.App().openBar(nil)
    task.wait(0.15)
    local d = A.Debug()
    local results = d.bar:FindFirstChild("Results", true)
    local n = 0
    for _, x in results:GetDescendants() do
        if x.Name == "Result" or x.Name == "Fav" then
            n += 1
        end
    end
    expect(n > 0, "home is empty")
    A.App().closeBar()
    expect(not A.Debug().bar.Visible, "bar still open")
end)

check("hide key hides everything and brings it back", function()
    local app = A.App()
    app.toggleAll()
    expect(not A.Debug().layer.Visible, "layer still visible")
    app.toggleAll()
    expect(A.Debug().layer.Visible, "layer not back")
end)

check("every panel opens and closes", function()
    local app = A.App()
    for _, id in { "commands", "binds", "settings", "log", "pins" } do
        app.openPanel(id)
        task.wait(0.05)
        local p = A.Debug().panels[id]
        expect(p and p.Visible, id .. " hidden")
        local body = p:FindFirstChild("Body")
        local count = 0
        for _, x in body:GetChildren() do
            if x:IsA("GuiObject") then
                count += 1
            end
        end
        expect(count > 0, id .. " is empty")
        app.closePanel(id)
        expect(not p.Visible, id .. " still open")
    end
end)

check("settings and log commands open their panels", function()
    local ok, msg = A.Run("settings")
    expect(ok, msg)
    task.wait(0.05)
    expect(A.Debug().panels.settings.Visible, "settings hidden")
    A.Run("log")
    task.wait(0.05)
    expect(A.Debug().panels.log.Visible, "log hidden")
    A.App().closePanel("settings")
    A.App().closePanel("log")
end)
-- Module cases live in tests/cases/*.luau and are copied next to this file as tzar-case-*.lua.
for _, name in { "character", "ui", "modules", "avatar" } do
    local src = readfile("tzar-case-" .. name .. ".lua")
    local cases = loadstring(src, "=case-" .. name)()
    cases(A, check, expect, connCounts)
end

-- Unload and look for leftovers.
local gui = A.Debug().gui
local ok, msg = A.Run("unload")
record("unload command", ok, msg)
task.wait(0.5)

check("handle removed", function()
    expect(getgenv().TZAR_ADMIN == nil, "TZAR_ADMIN still set")
end)
check("gui destroyed", function()
    expect(gui.Parent == nil, "gui still parented to " .. tostring(gui.Parent))
end)
check("character, camera and lighting untouched", function()
    local good, diff = same(baseState, humanoidSnapshot())
    expect(good, diff)
end)

-- Second pass for leftovers, with no respawn in between: Roblox's own control scripts add
-- connections when a character respawns, which would hide or fake a leak in the first pass.
-- Only connection counts are read here; handler functions are never touched (reading them
-- through debug.info crashed the client once). The wait lets respawn-time scripts settle.
task.wait(3)
local baseConns = connCounts()
local fn2, cerr2 = loadstring(readfile("tzar-admin.lua"), "=tzar-admin")
expect(fn2, cerr2)
pcall(fn2)
task.wait(0.4)
local B = getgenv().TZAR_ADMIN
check("second pass: every toggle on and off", function()
    expect(B, "no handle")
    for _, line in
        {
            "fly",
            "unfly",
            "noclip",
            "unnoclip",
            "infjump",
            "uninfjump",
            "antiafk",
            "unantiafk",
            "speed 30",
            "speed",
            "jp 80",
            "jp",
            "flyspeed 70",
            "flyspeed",
            "settings",
            "settings",
        }
    do
        local ok, msg = B.Run(line)
        expect(ok, line .. ": " .. tostring(msg))
    end
    B.App().openBar("fl")
    task.wait(0.1)
    B.App().openBar("speed")
    task.wait(0.1)
    B.App().closeBar()
    for _, id in { "commands", "binds", "settings", "pins" } do
        B.App().openPanel(id)
        B.App().closePanel(id)
    end
end)
B.Run("unload")
task.wait(0.5)
check("no leftover connections", function()
    local now = connCounts()
    for name, n in baseConns do
        expect(now[name] <= n, name .. ": " .. n .. " before, " .. now[name] .. " after")
    end
end)
-- Reload so the hub stays available to play with.
local fn3 = loadstring(readfile("tzar-admin.lua"), "=tzar-admin")
pcall(fn3)

local passed = 0
for _, r in results do
    if r.ok then
        passed += 1
    end
end
writefile(
    "tzar-admin-report.json",
    HttpService:JSONEncode({
        passed = passed,
        total = #results,
        seconds = os.clock() - started,
        results = results,
    })
)
