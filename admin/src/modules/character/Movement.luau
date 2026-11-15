--!strict
-- fly, flyspeed, noclip, speed, jumppower, infjump. Everything acts on the local character only
-- and is undone through the command's Janitor.

local UserInputService = game:GetService("UserInputService")

local Body = require("./Body")
local CtxTypes = require("../../Ctx")
local Janitor = require("../../core/Janitor")

type Ctx = CtxTypes.Ctx
type Handler = CtxTypes.Handler

local FLY_DEFAULT = 50
-- A jump request this recent counts as "jump held" (touch jump button has no IsKeyDown).
local JUMP_HOLD = 0.25

local K = Enum.KeyCode

local Movement = {}

function Movement.handlers(): { [string]: Handler }
    local flySpeed = FLY_DEFAULT

    local function fly(ctx: Ctx, args: { any }, jan: Janitor.Janitor)
        local _, hum, root = Body.need(ctx)
        local fixed: number? = args[1]

        local att = Instance.new("Attachment")
        att.Name = "TZAR_FlyAttachment"
        att.Parent = root
        jan:Add(att)
        local lv = Instance.new("LinearVelocity")
        lv.Name = "TZAR_Fly"
        lv.Attachment0 = att
        lv.RelativeTo = Enum.ActuatorRelativeTo.World
        lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
        lv.MaxForce = math.huge
        lv.VectorVelocity = Vector3.zero
        lv.Parent = root
        jan:Add(lv)
        local ao = Instance.new("AlignOrientation")
        ao.Name = "TZAR_FlyAlign"
        ao.Mode = Enum.OrientationAlignmentMode.OneAttachment
        ao.Attachment0 = att
        ao.MaxTorque = math.huge
        ao.Responsiveness = 60
        ao.CFrame = root.CFrame.Rotation
        ao.Parent = root
        jan:Add(ao)
        jan:Set(hum, "PlatformStand", true)

        local lastJump = 0
        jan:Connect(UserInputService.JumpRequest, function()
            lastJump = os.clock()
        end)

        -- Per frame: no tables, closures or strings. Vector3 is a value type; the camera CFrame
        -- read is the one engine allocation we cannot avoid.
        local remove = ctx.scheduler:Add("render", function()
            local cam = workspace.CurrentCamera
            if not cam or root.Parent == nil then
                return
            end
            local cf = cam.CFrame
            local look, right = cf.LookVector, cf.RightVector
            local fwd, side, up = 0, 0, 0
            if not UserInputService:GetFocusedTextBox() then
                if UserInputService:IsKeyDown(K.W) then
                    fwd += 1
                end
                if UserInputService:IsKeyDown(K.S) then
                    fwd -= 1
                end
                if UserInputService:IsKeyDown(K.D) then
                    side += 1
                end
                if UserInputService:IsKeyDown(K.A) then
                    side -= 1
                end
                if UserInputService:IsKeyDown(K.Space) or UserInputService:IsKeyDown(K.E) then
                    up += 1
                end
                if UserInputService:IsKeyDown(K.LeftControl) or UserInputService:IsKeyDown(K.Q) then
                    up -= 1
                end
            end
            if fwd == 0 and side == 0 then
                -- Touch stick (and gamepad): MoveDirection is camera-relative on the ground plane.
                local md = hum.MoveDirection
                if md.Magnitude > 0.05 then
                    local flatLook = Vector3.new(look.X, 0, look.Z)
                    local flatRight = Vector3.new(right.X, 0, right.Z)
                    if flatLook.Magnitude > 0.01 then
                        fwd = md:Dot(flatLook.Unit)
                        side = md:Dot(flatRight.Unit)
                    end
                end
            end
            if up == 0 and os.clock() - lastJump < JUMP_HOLD then
                up = 1
            end
            local dir = look * fwd + right * side + Vector3.yAxis * up
            if dir.Magnitude > 1 then
                dir = dir.Unit
            end
            lv.VectorVelocity = dir * (fixed or flySpeed)
            local flat = Vector3.new(look.X, 0, look.Z)
            if flat.Magnitude > 0.01 then
                -- Attachment X axis = character right; Y = up. Faces where the camera looks.
                ao.PrimaryAxis = flat.Unit:Cross(Vector3.yAxis)
                ao.SecondaryAxis = Vector3.yAxis
            end
        end, function(msg: string)
            ctx.log:Error("fly: " .. msg)
        end)
        jan:Defer(function()
            if root.Parent then
                root.AssemblyLinearVelocity = Vector3.zero
            end
        end)
        jan:Defer(remove)
    end

    local function noclip(ctx: Ctx, _args: { any }, jan: Janitor.Janitor)
        local char = Body.need(ctx)
        local parts: { BasePart } = {}
        local original: { [BasePart]: boolean } = {}
        local function track(d: Instance)
            if d:IsA("BasePart") and original[d] == nil then
                original[d] = d.CanCollide
                table.insert(parts, d)
            end
        end
        for _, d in char:GetDescendants() do
            track(d)
        end
        jan:Connect(char.DescendantAdded, track)
        jan:Connect(char.DescendantRemoving, function(d: Instance)
            if d:IsA("BasePart") then
                local i = table.find(parts, d)
                if i then
                    table.remove(parts, i)
                end
                original[d] = nil
            end
        end)
        -- Before physics every frame: the Humanoid turns collision back on for some parts.
        local remove = ctx.scheduler:Add("stepped", function()
            for i = 1, #parts do
                local p = parts[i]
                if p.CanCollide then
                    p.CanCollide = false
                end
            end
        end)
        jan:Defer(function()
            for p, was in original do
                if p.Parent then
                    p.CanCollide = was
                end
            end
        end)
        jan:Defer(remove)
    end

    -- A value the game might reset (e.g. on a state change) is put back as long as we hold it.
    local function hold(jan: Janitor.Janitor, hum: Humanoid, prop: string, value: any)
        jan:Set(hum, prop, value)
        jan:Connect(hum:GetPropertyChangedSignal(prop), function()
            if (hum :: any)[prop] ~= value then
                (hum :: any)[prop] = value
            end
        end)
    end

    return {
        fly = { enable = fly },
        flyspeed = {
            enable = function(_ctx: Ctx, args: { any }, jan: Janitor.Janitor)
                flySpeed = args[1] :: number
                jan:Defer(function()
                    flySpeed = FLY_DEFAULT
                end)
            end,
            current = function()
                return flySpeed
            end,
        },
        noclip = { enable = noclip },
        speed = {
            enable = function(ctx: Ctx, args: { any }, jan: Janitor.Janitor)
                local _, hum = Body.need(ctx)
                hold(jan, hum, "WalkSpeed", args[1])
            end,
            current = function(ctx: Ctx)
                local hum = ctx.humanoid()
                return hum and hum.WalkSpeed
            end,
        },
        jumppower = {
            enable = function(ctx: Ctx, args: { any }, jan: Janitor.Janitor)
                local _, hum = Body.need(ctx)
                jan:Set(hum, "UseJumpPower", true)
                hold(jan, hum, "JumpPower", args[1])
            end,
            current = function(ctx: Ctx)
                local hum = ctx.humanoid()
                return hum and hum.UseJumpPower and hum.JumpPower or nil
            end,
        },
        infjump = {
            enable = function(ctx: Ctx, _args: { any }, jan: Janitor.Janitor)
                local last = 0
                jan:Connect(UserInputService.JumpRequest, function()
                    local now = os.clock()
                    if now - last < 0.12 then
                        return
                    end
                    last = now
                    local hum = ctx.humanoid()
                    if hum and hum.Health > 0 then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end)
            end,
        },
    }
end

return Movement
