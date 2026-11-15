-- Game-module frame on the sandbox module: panel, handler and command features, sections, sets
-- (built in, saved, pinned, by command), the routine and the bar search. Everything is local:
-- lighting, camera and your own character.
-- return function(A, check, expect, connCounts) ... end

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local ACCENT = Color3.fromHex("e53945")

local function find(root, name)
    return root and root:FindFirstChild(name, true)
end

local function hasText(root, text)
    for _, x in root:GetDescendants() do
        if x:IsA("TextLabel") and string.find(x.Text, text, 1, true) then
            return true
        end
    end
    return false
end

return function(A, check, expect)
    local M = A.Modules()
    local function panel()
        return A.Debug().modules and A.Debug().modules.sandbox
    end

    check("module command opens the sandbox panel", function()
        expect(M, "no module manager on the handle")
        local ok, msg = A.Run("module sandbox")
        expect(ok, msg)
        task.wait(0.15)
        local p = panel()
        expect(p and p.Visible, "panel hidden")
        for _, s in { "light", "camera", "body", "tour" } do
            expect(find(p, "Section/" .. s), "no section " .. s)
        end
        expect(find(p, "Check/nofog"), "no check for nofog")
        expect(find(p, "Param/brightness"), "no fill bar for brightness")
        expect(find(p, "Param/tone"), "no choice for tone")
        expect(find(p, "Preset/night"), "no night set")
        expect(find(p, "Run"), "no run row")
        local _, total = M:Count("sandbox")
        expect(total == 19, "features: " .. total)
        local ok2 = A.Run("module")
        expect(ok2, "module without a name failed")
    end)

    check("handler feature changes lighting and gives it back", function()
        local fog = Lighting.FogEnd
        local ok, msg = M:Set("sandbox", "nofog", true)
        expect(ok, msg)
        expect(M:IsOn("sandbox", "nofog"), "nofog not on")
        expect(Lighting.FogEnd >= 1e8, "fog end " .. Lighting.FogEnd)
        Lighting.FogEnd = 100 -- the game sets it back: held
        task.wait()
        expect(Lighting.FogEnd >= 1e8, "fog not held")
        M:Set("sandbox", "nofog", nil)
        expect(not M:IsOn("sandbox", "nofog"), "nofog still on")
        expect(Lighting.FogEnd == fog, "fog end " .. Lighting.FogEnd .. " not " .. fog)
    end)

    check("number and choice features hold their value and undo it", function()
        local cam = workspace.CurrentCamera
        local fov = cam.FieldOfView
        M:Set("sandbox", "fov", 95)
        expect(math.abs(cam.FieldOfView - 95) < 0.01, "fov " .. cam.FieldOfView)
        expect(M:Value("sandbox", "fov") == 95, "value " .. tostring(M:Value("sandbox", "fov")))
        M:Set("sandbox", "fov", 60) -- a new value replaces the old one, no stacking
        expect(math.abs(cam.FieldOfView - 60) < 0.01, "fov " .. cam.FieldOfView)
        M:Set("sandbox", "fov", nil)
        expect(math.abs(cam.FieldOfView - fov) < 0.01, "fov not restored")
        M:Set("sandbox", "tone", "mono")
        local cc = Lighting:FindFirstChild("TZAR_Sandbox")
        expect(cc and cc.Saturation == -1, "no mono correction")
        M:Set("sandbox", "tone", "warm")
        local n = 0
        for _, x in Lighting:GetChildren() do
            if x.Name == "TZAR_Sandbox" then
                n += 1
            end
        end
        expect(n == 1, n .. " corrections")
        M:Set("sandbox", "tone", nil)
        expect(not Lighting:FindFirstChild("TZAR_Sandbox"), "correction left behind")
    end)

    check("command-driven feature mirrors the hub command", function()
        local ok, msg = M:Set("sandbox", "noclip", true)
        expect(ok, msg)
        expect(A.IsActive("noclip"), "noclip command not active")
        A.Run("unnoclip")
        expect(not M:IsOn("sandbox", "noclip"), "module still shows noclip")
        M:Set("sandbox", "speed", 40)
        expect(
            A.IsActive("speed") and A.Value("speed") == 40,
            "speed " .. tostring(A.Value("speed"))
        )
        M:Set("sandbox", "speed", nil)
        expect(not A.IsActive("speed"), "speed still set")
    end)

    check("section switches and the counts follow", function()
        M:SetSection("sandbox", "light", true)
        local on, total = M:Count("sandbox", "light")
        expect(on == 3 and total == 6, on .. "/" .. total .. " after all on")
        expect(Lighting.ClockTime == 0, "night not on")
        task.wait(0.1)
        local p = panel()
        local cell = find(p, "Check/night")
        local box = cell and find(cell, "Check")
        expect(box and box.BackgroundColor3 == ACCENT, "night check not red")
        M:SetSection("sandbox", "light", false)
        on = M:Count("sandbox", "light")
        expect(on == 0, on .. " still on")
    end)

    check("built-in set: on, shown as active, off again", function()
        M:TogglePreset("sandbox", "night")
        expect(M:PresetActive("sandbox", "night"), "night set not active")
        expect(
            M:IsOn("sandbox", "nofog") and M:Value("sandbox", "tone") == "cold",
            "set incomplete"
        )
        task.wait(0.1)
        local chip = find(panel(), "Preset/night")
        expect(chip and chip.BackgroundColor3 ~= Color3.fromHex("232323"), "chip not tinted")
        M:TogglePreset("sandbox", "night")
        expect(not M:PresetActive("sandbox", "night"), "night set still active")
        expect(not M:IsOn("sandbox", "nofog"), "nofog left on")
    end)

    check("preset command by key, unknown set rejected", function()
        local ok, msg = A.Run("preset sandbox.explore")
        expect(ok, msg)
        expect(A.IsActive("fly") and A.IsActive("noclip"), "explore did not fly/noclip")
        expect(A.Value("speed") == 64, "speed " .. tostring(A.Value("speed")))
        ok, msg = A.Run("preset sandbox.explore")
        expect(ok, msg)
        expect(not A.IsActive("fly") and not A.IsActive("speed"), "explore not off")
        ok = A.Run("preset sandbox.definitelynot")
        expect(not ok, "unknown set accepted")
    end)

    check("saved set persists and can be deleted", function()
        M:Set("sandbox", "night", true)
        M:Set("sandbox", "zoom", 900)
        local id = M:SavePreset("sandbox", "Tzar Test")
        M:AllOff("sandbox")
        local on = M:Count("sandbox")
        expect(on == 0, on .. " on after all off")
        local found = false
        for _, p in M:Presets("sandbox") do
            if p.id == id then
                found = p.values.night == true and p.values.zoom == 900
            end
        end
        expect(found, "saved set missing or wrong")
        task.wait(1.2) -- the store writes in the background
        local raw = readfile("TZAR/admin/settings.json")
        expect(string.find(raw, "Tzar Test", 1, true), "not in settings.json")
        local ok, msg = A.Run("preset sandbox.tzar-test")
        expect(ok, msg)
        expect(Players.LocalPlayer.CameraMaxZoomDistance == 900, "saved zoom not applied")
        A.Run("preset sandbox.tzar-test")
        M:DeletePreset("sandbox", id)
        for _, p in M:Presets("sandbox") do
            expect(p.id ~= id, "deleted set still listed")
        end
    end)

    check("pinned set on the dock lights up with the set", function()
        local pins = M._store.data.pins
        table.insert(pins, "preset:sandbox:photo")
        M.Changed:Fire("sandbox", "presets")
        task.wait(0.1)
        local cell = A.Debug().dock:FindFirstChild("Pin/preset:sandbox:photo")
        expect(cell, "set not on the dock")
        expect(cell.BackgroundColor3 ~= ACCENT, "lit before it is on")
        M:ApplyPreset("sandbox", "photo")
        task.wait(0.1)
        cell = A.Debug().dock:FindFirstChild("Pin/preset:sandbox:photo")
        expect(cell and cell.BackgroundColor3 == ACCENT, "not lit while on")
        M:TogglePreset("sandbox", "photo")
        table.remove(pins, table.find(pins, "preset:sandbox:photo"))
        M.Changed:Fire("sandbox", "presets")
        task.wait(0.1)
        expect(not A.Debug().dock:FindFirstChild("Pin/preset:sandbox:photo"), "unpinned set stays")
    end)

    check("routine: start, pause keeps the clock, resume, stop", function()
        A.Run("setwp tzartest_a")
        A.Run("setwp tzartest_b")
        M:Set("sandbox", "delay", 0.5)
        M:Start("sandbox")
        task.wait(0.2)
        local r = M:Run("sandbox")
        expect(r.state == "running", "state " .. r.state)
        expect(r.status ~= "", "no status")
        M:Pause("sandbox")
        local t1 = M:Run("sandbox").elapsed()
        task.wait(0.4)
        local t2 = M:Run("sandbox").elapsed()
        expect(M:Run("sandbox").state == "paused", "not paused")
        expect(math.abs(t2 - t1) < 0.05, "clock ran while paused")
        M:Start("sandbox")
        expect(M:Run("sandbox").state == "running", "did not resume")
        task.wait(0.1)
        local runRow = find(panel(), "Run")
        expect(runRow and hasText(runRow, A.T("md.pause")), "run button does not say pause")
        M:Stop("sandbox")
        expect(M:Run("sandbox").state == "idle", "not stopped")
        M:Set("sandbox", "delay", nil)
        A.Run("delwp tzartest_a")
        A.Run("delwp tzartest_b")
    end)

    check("the bar finds modules and sets", function()
        A.App().openBar("sandbox")
        task.wait(0.15)
        local bar = A.Debug().bar
        expect(hasText(bar, A.T("m.sandbox.title")), "module not in the results")
        expect(hasText(bar, A.T("sp.modules")), "no modules group")
        A.App().openBar("explore")
        task.wait(0.15)
        expect(hasText(A.Debug().bar, A.T("m.sandbox.p.explore")), "set not in the results")
        A.App().openBar("")
        task.wait(0.1)
        expect(hasText(A.Debug().bar, A.T("sp.modules")), "empty bar has no modules group")
        A.App().closeBar()
    end)

    check("module panel comes back after a language switch", function()
        local lang = A.Debug().lang
        A.App().openModule("sandbox")
        A.Run(if lang == "en" then "lang de" else "lang en")
        task.wait(0.2)
        local p = panel()
        expect(p and p.Visible and p.Parent, "panel gone after rebuild")
        A.Run("lang " .. lang)
        task.wait(0.2)
        A.App().closeModule("sandbox")
        expect(not panel().Visible, "panel still open")
    end)

    -- Left on on purpose: the unload check that follows must find lighting and camera restored.
    check("features left on for the unload check", function()
        M:Set("sandbox", "nofog", true)
        M:Set("sandbox", "night", true)
        M:Set("sandbox", "brightness", 4)
        M:Set("sandbox", "fov", 100)
        M:Set("sandbox", "zoom", 1500)
        expect(M:Count("sandbox") == 5, "count " .. M:Count("sandbox"))
    end)
end
