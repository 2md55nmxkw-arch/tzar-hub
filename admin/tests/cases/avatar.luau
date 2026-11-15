-- Avatar module on your own character: wear a user, switch to a saved outfit without stacking,
-- keep the look through a respawn, export and re-import an outfit, emotes, game rules.
-- Uses the Roblox account (user id 1) as the look to wear. Nothing here touches other players.
-- return function(A, check, expect, connCounts) ... end

local Players = game:GetService("Players")

local lp = Players.LocalPlayer
local TEST_OUTFIT = "tzar test"
-- "Salute", one of Roblox's own emotes.
local EMOTE_ID = 3360689775

local function signature()
    local char = lp.Character
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
end

local function waitFor(seconds, fn)
    local t0 = os.clock()
    while os.clock() - t0 < seconds do
        if fn() then
            return true
        end
        task.wait(0.2)
    end
    return fn()
end

return function(A, check, expect)
    local mine = signature()
    local worn = nil

    check("wear a user puts their look on and unwear gives yours back", function()
        local ok, msg = A.Run("wear 1")
        expect(ok, msg)
        expect(A.IsActive("wear"), "wear not active")
        worn = signature()
        expect(worn ~= mine, "look did not change")
        ok, msg = A.Run("unwear")
        expect(ok, msg)
        expect(
            waitFor(2, function()
                return signature() == mine
            end),
            "own look not back: " .. signature()
        )
    end)

    check("wear yourself from the server reads your own description", function()
        local ok, msg = A.Run("wear " .. lp.Name)
        expect(ok, msg)
        A.Run("unwear")
        expect(
            waitFor(2, function()
                return signature() == mine
            end),
            "own look not back"
        )
    end)

    check("saved outfit: wear switches over without stacking", function()
        A.Run("wear 1")
        local ok, msg = A.Run("saveoutfit " .. TEST_OUTFIT)
        expect(ok, msg)
        local raw = readfile("TZAR/admin/avatar.json")
        expect(string.find(raw, TEST_OUTFIT, 1, true), "outfit not in avatar.json")
        A.Run("unwear")
        waitFor(2, function()
            return signature() == mine
        end)
        A.Run("wear " .. lp.Name)
        ok, msg = A.Run('outfit "' .. TEST_OUTFIT .. '"')
        expect(ok, msg)
        expect(A.IsActive("outfit") and not A.IsActive("wear"), "wear still on next to outfit")
        expect(signature() == worn, "outfit does not look like the saved one")
        local acc = 0
        for _, d in lp.Character:GetChildren() do
            if d:IsA("Accoutrement") then
                acc += 1
            end
        end
        local wantAcc = select(2, string.gsub(worn, "acc:", ""))
        expect(acc == wantAcc, acc .. " accessories, want " .. wantAcc)
        A.Run("unoutfit")
        expect(
            waitFor(2, function()
                return signature() == mine
            end),
            "own look not back after outfit"
        )
    end)

    check("rename, export and the ApplyOutfit API", function()
        local ok, msg = A.Run('renameoutfit "' .. TEST_OUTFIT .. '" tzar test 2')
        expect(ok, msg)
        ok, msg = A.Run('renameoutfit "tzar test 2" ' .. TEST_OUTFIT)
        expect(ok, msg)
        ok, msg = A.Run('exportoutfit "' .. TEST_OUTFIT .. '"')
        expect(ok, msg)
        local path = "TZAR/exports/tzar_test.lua"
        expect(isfile(path), "no export file")
        local src = readfile(path)
        expect(string.find(src, 'Module("avatar").ApplyOutfit', 1, true), "export does not apply")
        local json = string.match(src, "%[==%[(.-)%]==%]")
        expect(json, "no outfit json in export")
        A.Run('deloutfit "' .. TEST_OUTFIT .. '"')
        A.Module("avatar").ApplyOutfit(json)
        expect(
            waitFor(5, function()
                return A.IsActive("outfit")
            end),
            "ApplyOutfit did not wear it"
        )
        expect(signature() == worn, "imported outfit looks different")
        A.Run("unoutfit")
        waitFor(2, function()
            return signature() == mine
        end)
        A.Run('deloutfit "' .. TEST_OUTFIT .. '"')
        pcall(delfile, path)
    end)

    check("game avatar rules rebuild the worn look", function()
        A.Run("wear 1")
        local ok, msg = A.Run("avatarrules on")
        expect(ok, msg)
        expect(A.IsActive("wear"), "wear dropped by rules")
        A.Run("avatarrules off")
        A.Run("unwear")
        expect(
            waitFor(2, function()
                return signature() == mine
            end),
            "own look not back"
        )
    end)

    check("worn look stays through a respawn", function()
        A.Run("wear 1")
        local before = lp.Character
        local ok, msg = A.Run("respawn")
        expect(ok, msg)
        expect(
            waitFor(12, function()
                return lp.Character ~= before
                    and lp.Character
                    and lp.Character:FindFirstChild("Humanoid")
            end),
            "no new character"
        )
        expect(
            waitFor(12, function()
                return signature() == worn
            end),
            "look lost on respawn: " .. signature()
        )
        A.Run("unwear")
        expect(
            waitFor(3, function()
                return signature() == mine
            end),
            "own look not back after respawn"
        )
    end)

    check("emote: add by id, play, remove", function()
        local hum = lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if not hum or hum.RigType ~= Enum.HumanoidRigType.R15 then
            return
        end
        local ok, msg = A.Run("addemote " .. EMOTE_ID .. " tzar salute")
        expect(ok, msg)
        ok, msg = A.Run('emote "tzar salute"')
        expect(ok, msg)
        local animator = hum:FindFirstChildOfClass("Animator")
        local playing = waitFor(2, function()
            for _, t in animator:GetPlayingAnimationTracks() do
                if t.Name == "TZAR_Emote_" .. EMOTE_ID then
                    return true
                end
            end
            return false
        end)
        expect(playing, "no emote track playing")
        ok, msg = A.Run('delemote "tzar salute"')
        expect(ok, msg)
        ok = A.Run("addemote 1")
        expect(not ok, "a non-emote id was accepted")
    end)

    local function panel()
        return A.Debug().avatar
    end
    local function textIn(root, s)
        for _, x in root:GetDescendants() do
            if (x:IsA("TextLabel") or x:IsA("TextButton")) and string.find(x.Text, s, 1, true) then
                return x
            end
        end
        return nil
    end

    check("avatar panel: three tabs, preview, outfits", function()
        local ok, msg = A.Run("avatar")
        expect(ok, msg)
        expect(
            waitFor(3, function()
                return panel() and panel().Visible
            end),
            "panel not open"
        )
        local p = panel()
        for _, id in { "look", "catalog", "emotes" } do
            expect(p:FindFirstChild("Tab/" .. id, true), "no tab " .. id)
        end
        local vf = p:FindFirstChildWhichIsA("ViewportFrame", true)
        expect(vf and vf:FindFirstChildWhichIsA("WorldModel"), "no preview model")
        expect(p:FindFirstChild("Outfits", true), "no outfits strip")
        local vp = workspace.CurrentCamera.ViewportSize
        local bottom = p.AbsolutePosition.Y + p.AbsoluteSize.Y
        expect(bottom <= vp.Y + 1, "panel runs off the screen: " .. bottom)
    end)

    check("wearing shows in the panel status", function()
        A.Run("wear 1")
        expect(
            waitFor(3, function()
                return textIn(panel(), "Roblox") ~= nil
            end),
            "status does not name the worn look"
        )
        expect(panel():FindFirstChild("Outfit/Roblox", true), "worn look not in the outfits strip")
        A.Run("unwear")
        waitFor(2, function()
            return signature() == mine
        end)
    end)

    check("catalog tab finds body bundles", function()
        A.App().openAvatar("catalog")
        local found = waitFor(10, function()
            local r = panel():FindFirstChild("Results", true)
            return r and r:FindFirstChildWhichIsA("TextButton") ~= nil
        end)
        expect(found, "no catalog results")
        local page = panel():FindFirstChild("Page", true)
        expect(page.AbsoluteCanvasSize.Y >= page.AbsoluteWindowSize.Y, "page cannot scroll")
    end)

    check("emotes tab lists the wheel", function()
        A.Run("addemote " .. EMOTE_ID .. " tzar salute")
        A.App().openAvatar("emotes")
        expect(
            waitFor(2, function()
                return panel():FindFirstChild("Emote/" .. EMOTE_ID, true) ~= nil
            end),
            "added emote not on the tab"
        )
        A.Run('delemote "tzar salute"')
        expect(
            waitFor(2, function()
                return panel():FindFirstChild("Emote/" .. EMOTE_ID, true) == nil
            end),
            "removed emote still shown"
        )
        A.App().closeAvatar()
        expect(not panel().Visible, "panel still open")
    end)

    check("emote wheel opens with 8 slots and closes", function()
        A.Run("addemote " .. EMOTE_ID .. " tzar salute")
        -- Your outfit's own emotes would fill the first page.
        local api = A.Module("avatar")
        local outfitFirst = api.OutfitEmotes()
        api.SetOutfitEmotes(false)
        A.Run("emotewheel")
        expect(
            waitFor(2, function()
                return A.Debug().wheel ~= nil
            end),
            "wheel did not open"
        )
        local slots = 0
        for _, x in A.Debug().wheel:GetDescendants() do
            if string.sub(x.Name, 1, 5) == "Slot/" then
                slots += 1
            end
        end
        -- Your own list may be long (imported from Avatar Changer): the page shows its first 8.
        local list = api.Wheel()
        local listed = false
        for _, e in list do
            listed = listed or e.id == EMOTE_ID
        end
        local onWheel = listed and textIn(A.Debug().wheel, list[1].name) ~= nil
        A.Run("emotewheel")
        local closed = A.Debug().wheel == nil
        api.SetOutfitEmotes(outfitFirst)
        A.Run('delemote "tzar salute"')
        expect(slots == 8, slots .. " slots")
        expect(onWheel, "emote not on the wheel")
        expect(closed, "wheel did not close")
    end)

    check("TZAR wheel setting hides the Roblox wheel and gives it back", function()
        local StarterGui = game:GetService("StarterGui")
        local store = A.Modules()._store
        store.data.emoteWheel = true
        store:Save("emoteWheel")
        task.wait()
        expect(
            not StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu),
            "Roblox wheel still on"
        )
        store.data.emoteWheel = false
        store:Save("emoteWheel")
        task.wait()
        expect(StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu), "Roblox wheel not back")
    end)

    -- Left on on purpose: the unload check that follows must find your own look back.
    check("look left on for the unload check", function()
        local ok, msg = A.Run("wear 1")
        expect(ok, msg)
        expect(signature() == worn, "not wearing the test look")
    end)
end
