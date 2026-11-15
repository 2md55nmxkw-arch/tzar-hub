--!strict
-- Character module: movement, poses, waypoints, anti-AFK and respawn. Local character only.

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

local Body = require("./Body")
local CtxTypes = require("../../Ctx")
local Janitor = require("../../core/Janitor")
local Movement = require("./Movement")
local Waypoints = require("./Waypoints")

type Ctx = CtxTypes.Ctx

local RESPAWN_TIMEOUT = 15

local function respawn(ctx: Ctx)
    local hum = ctx.humanoid()
    if not hum then
        ctx.fail(ctx.t("chr.no_character"))
    end
    -- The client owns its own Humanoid, so zero health resets the character like the menu does.
    (hum :: Humanoid).Health = 0
end

return function(): CtxTypes.Module
    local handlers = Movement.handlers()
    local wpHandlers, wpNames = Waypoints.module()
    for k, v in wpHandlers do
        handlers[k] = v
    end

    handlers.sit = {
        run = function(ctx: Ctx)
            local _, hum = Body.need(ctx)
            hum.Sit = true
        end,
    }
    handlers.lay = {
        run = function(ctx: Ctx)
            local _, hum, root = Body.need(ctx)
            hum.Sit = true
            task.wait(0.15)
            if root.Parent then
                root.CFrame = root.CFrame * CFrame.Angles(math.pi / 2, 0, 0)
            end
        end,
    }
    handlers.antiafk = {
        enable = function(_ctx: Ctx, _args: { any }, jan: Janitor.Janitor)
            -- Roblox fires Idled after ~2 minutes without input; a virtual click resets the timer.
            jan:Connect(Players.LocalPlayer.Idled, function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero)
            end)
        end,
    }
    handlers.respawn = {
        run = function(ctx: Ctx)
            respawn(ctx)
            ctx.toast("info", ctx.t("chr.respawned"))
        end,
    }
    handlers.refresh = {
        run = function(ctx: Ctx)
            local _, _, root = Body.need(ctx)
            local at = root.CFrame
            local lp = Players.LocalPlayer
            local done = false
            local newChar: Model? = nil
            local conn = lp.CharacterAdded:Connect(function(c: Model)
                newChar = c
                done = true
            end)
            respawn(ctx)
            local start = os.clock()
            while not done and os.clock() - start < RESPAWN_TIMEOUT do
                task.wait(0.1)
            end
            conn:Disconnect()
            local c = newChar
            if not c then
                ctx.fail(ctx.t("chr.no_character"))
            end
            local r = (c :: Model):WaitForChild("HumanoidRootPart", 10)
            if r and r:IsA("BasePart") then
                task.wait(0.1)
                r.CFrame = at
            end
            ctx.toast("info", ctx.t("chr.respawned"))
        end,
    }

    return {
        handlers = handlers,
        lists = { waypoint = wpNames },
    }
end
