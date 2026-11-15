-- Character module cases. Loaded by tests/ingame.luau with its helpers:
-- return function(A, check, expect, connCounts) ... end

local Players = game:GetService("Players")

local lp = Players.LocalPlayer

local function body()
    local c = lp.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    local r = c and c:FindFirstChild("HumanoidRootPart")
    return c, h, r
end

local function waitBody(timeout)
    local start = os.clock()
    while os.clock() - start < (timeout or 10) do
        local c, h, r = body()
        if c and h and r and h.Health > 0 then
            return c, h, r
        end
        task.wait(0.1)
    end
    error("character did not load")
end

local function collisions(c)
    local out = {}
    for _, d in c:GetDescendants() do
        if d:IsA("BasePart") then
            out[d] = d.CanCollide
        end
    end
    return out
end

-- True when the player is holding a movement key (or Roblox thinks one is stuck down).
local function movingInput()
    local UIS = game:GetService("UserInputService")
    for _, k in { "W", "A", "S", "D", "Space", "E", "Q", "LeftControl" } do
        if UIS:IsKeyDown(Enum.KeyCode[k]) then
            return k
        end
    end
    return nil
end

local function frames(n)
    for _ = 1, n do
        game:GetService("RunService").Heartbeat:Wait()
    end
end

return function(A, check, expect, connCounts)
    waitBody()

    check("speed sets, holds and restores", function()
        local _, h = waitBody()
        local base = h.WalkSpeed
        local ok, msg = A.Run("speed 40")
        expect(ok, msg)
        expect(h.WalkSpeed == 40, "WalkSpeed " .. h.WalkSpeed)
        h.WalkSpeed = 10 -- as if the game reset it
        frames(1)
        expect(h.WalkSpeed == 40, "not held: " .. h.WalkSpeed)
        expect(A.Value("speed") == 40, "chip value " .. tostring(A.Value("speed")))
        ok, msg = A.Run("speed")
        expect(ok, msg)
        expect(h.WalkSpeed == base, "not restored: " .. h.WalkSpeed .. " vs " .. base)
        expect(not A.IsActive("speed"), "still active")
    end)

    check("ws alias and range check", function()
        local ok, msg = A.Run("ws 9999")
        expect(not ok and msg, "accepted 9999")
        ok, msg = A.Run("ws 25")
        expect(ok, msg)
        ok, msg = A.Run("unspeed")
        expect(ok, msg)
    end)

    check("jumppower sets and restores", function()
        local _, h = waitBody()
        local baseJp, baseUse = h.JumpPower, h.UseJumpPower
        local ok, msg = A.Run("jp 120")
        expect(ok, msg)
        expect(h.UseJumpPower == true and h.JumpPower == 120, "JumpPower " .. h.JumpPower)
        ok, msg = A.Run("unjumppower")
        expect(ok, msg)
        expect(h.JumpPower == baseJp and h.UseJumpPower == baseUse, "not restored")
    end)

    check("flyspeed value", function()
        local ok, msg = A.Run("flyspeed 80")
        expect(ok, msg)
        expect(A.Value("flyspeed") == 80, tostring(A.Value("flyspeed")))
        ok, msg = A.Run("flyspeed")
        expect(ok, msg)
        expect(A.Value("flyspeed") == 50, tostring(A.Value("flyspeed")))
    end)

    check("fly on and off", function()
        local _, h, r = waitBody()
        local ticks = A.Debug().tickers
        local ok, msg = A.Run("fly")
        expect(ok, msg)
        expect(r:FindFirstChild("TZAR_Fly"), "no LinearVelocity")
        expect(h.PlatformStand, "PlatformStand off")
        expect(A.Debug().tickers == ticks + 1, "ticker not added")
        task.wait(0.4)
        local held = movingInput()
        local speed = r.AssemblyLinearVelocity.Magnitude
        if not held and speed >= 3 then
            A.Run("unfly")
            error("drifting " .. tostring(r.AssemblyLinearVelocity))
        elseif held and speed < 3 then
            A.Run("unfly")
            error(held .. " is held but fly does not move")
        end
        ok, msg = A.Run("fly")
        expect(ok, msg)
        expect(not r:FindFirstChild("TZAR_Fly"), "LinearVelocity left")
        expect(not r:FindFirstChild("TZAR_FlyAttachment"), "attachment left")
        expect(not h.PlatformStand, "PlatformStand left on")
        expect(A.Debug().tickers == ticks, "ticker left")
    end)

    check("noclip on and off", function()
        local c = waitBody()
        local before = collisions(c)
        local ok, msg = A.Run("noclip")
        expect(ok, msg)
        frames(3)
        for p in before do
            if p.Parent then
                expect(not p.CanCollide, p.Name .. " still collides")
            end
        end
        ok, msg = A.Run("noclip off")
        expect(ok, msg)
        frames(2)
        for p, was in before do
            if p.Parent then
                expect(p.CanCollide == was, p.Name .. " not restored")
            end
        end
    end)

    check("infjump connects and disconnects", function()
        local n = connCounts().JumpRequest
        local ok, msg = A.Run("infjump")
        expect(ok, msg)
        expect(connCounts().JumpRequest == n + 1, "no JumpRequest connection")
        ok, msg = A.Run("uninfjump")
        expect(ok, msg)
        expect(connCounts().JumpRequest == n, "connection left")
    end)

    check("antiafk connects and disconnects", function()
        local n = connCounts().Idled
        local ok, msg = A.Run("antiafk on")
        expect(ok, msg)
        expect(connCounts().Idled == n + 1, "no Idled connection")
        ok, msg = A.Run("antiafk off")
        expect(ok, msg)
        expect(connCounts().Idled == n, "connection left")
    end)

    check("sit and lay", function()
        local _, h = waitBody()
        local ok, msg = A.Run("sit")
        expect(ok, msg)
        expect(h.Sit, "not sitting")
        h.Sit = false
        task.wait(0.2)
        ok, msg = A.Run("lay")
        expect(ok, msg)
        expect(h.Sit, "not laying")
        h.Sit = false
        h:ChangeState(Enum.HumanoidStateType.GettingUp)
        task.wait(0.5)
    end)

    check("waypoints save, go, list, delete", function()
        local _, _, r = waitBody()
        local home = r.Position
        local ok, msg = A.Run("setwp tzar test")
        expect(ok, msg)
        r.CFrame = r.CFrame + Vector3.new(8, 0, 0)
        task.wait(0.1)
        ok, msg = A.Run('wp "tzar test"')
        expect(ok, msg)
        task.wait(0.1)
        expect((r.Position - home).Magnitude < 2, "off by " .. (r.Position - home).Magnitude)
        ok, msg = A.Run("waypoints")
        expect(ok, msg)
        ok, msg = A.Run('delwp "tzar test"')
        expect(ok, msg)
        ok, msg = A.Run('wp "tzar test"')
        expect(not ok and msg, "went to a deleted waypoint")
    end)

    check("fly and speed come back after respawn", function()
        local old = waitBody()
        local ok, msg = A.Run("speed 30")
        expect(ok, msg)
        ok, msg = A.Run("fly")
        expect(ok, msg)
        ok, msg = A.Run("respawn")
        expect(ok, msg)
        local start = os.clock()
        while lp.Character == old and os.clock() - start < 15 do
            task.wait(0.2)
        end
        expect(lp.Character ~= old, "no new character")
        local _, h, r = waitBody(10)
        task.wait(1.5)
        expect(r:FindFirstChild("TZAR_Fly"), "fly not back after respawn")
        expect(h.WalkSpeed == 30, "speed not back: " .. h.WalkSpeed)
        A.Run("unfly")
        A.Run("unspeed")
        expect(not r:FindFirstChild("TZAR_Fly"), "fly left after unfly")
        expect(not h.PlatformStand, "PlatformStand left")
    end)

    check("refresh returns to the same spot", function()
        local old, _, r = waitBody()
        local at = r.Position
        local ok, msg = A.Run("refresh")
        expect(ok, msg)
        local c, _, r2 = waitBody(5)
        expect(c ~= old, "same character")
        expect((r2.Position - at).Magnitude < 4, "off by " .. (r2.Position - at).Magnitude)
    end)

    check("no character commands left active", function()
        for _, name in { "fly", "noclip", "speed", "jumppower", "infjump", "antiafk", "flyspeed" } do
            expect(not A.IsActive(name), name .. " still active")
        end
    end)
end
