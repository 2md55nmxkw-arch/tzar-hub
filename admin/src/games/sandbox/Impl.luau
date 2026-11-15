--!strict
-- Sandbox handlers. Lighting and camera changes happen on this client only and are restored by
-- each feature's Janitor; the tour moves your own character between your own saved waypoints.

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")

local CtxTypes = require("../../Ctx")
local Janitor = require("../../core/Janitor")

type Ctx = CtxTypes.Ctx

local TONES: { [string]: Color3 } = {
    neutral = Color3.new(1, 1, 1),
    warm = Color3.fromRGB(255, 226, 196),
    cold = Color3.fromRGB(205, 225, 255),
    mono = Color3.new(1, 1, 1),
}

-- One ColorCorrection shared by the tone and contrast features.
local function correction(jan: Janitor.Janitor): ColorCorrectionEffect
    local cc = Instance.new("ColorCorrectionEffect")
    cc.Name = "TZAR_Sandbox"
    cc.Parent = Lighting
    jan:Add(cc)
    return cc
end

-- Holds a Lighting property while the feature is on, even if the game sets it back.
local function hold(jan: Janitor.Janitor, target: Instance, prop: string, value: any)
    jan:Set(target, prop, value)
    jan:Connect(target:GetPropertyChangedSignal(prop), function()
        if (target :: any)[prop] ~= value then
            (target :: any)[prop] = value
        end
    end)
end

return function(): CtxTypes.GameImpl
    local features: { [string]: CtxTypes.FeatureHandler } = {
        brightness = {
            enable = function(_ctx: Ctx, v: any, jan: Janitor.Janitor)
                hold(jan, Lighting, "Brightness", v)
            end,
        },
        nofog = {
            enable = function(_ctx: Ctx, _v: any, jan: Janitor.Janitor)
                hold(jan, Lighting, "FogEnd", 1e9)
                for _, a in Lighting:GetChildren() do
                    if a:IsA("Atmosphere") then
                        jan:Set(a, "Density", 0)
                        jan:Set(a, "Haze", 0)
                    end
                end
            end,
        },
        night = {
            enable = function(_ctx: Ctx, _v: any, jan: Janitor.Janitor)
                hold(jan, Lighting, "ClockTime", 0)
            end,
        },
        tone = {
            enable = function(_ctx: Ctx, v: any, jan: Janitor.Janitor)
                local cc = correction(jan)
                cc.TintColor = TONES[v] or TONES.neutral
                cc.Saturation = if v == "mono" then -1 else 0
            end,
        },
        contrast = {
            enable = function(_ctx: Ctx, v: any, jan: Janitor.Janitor)
                correction(jan).Contrast = v
            end,
        },
        noshadows = {
            enable = function(_ctx: Ctx, _v: any, jan: Janitor.Janitor)
                hold(jan, Lighting, "GlobalShadows", false)
            end,
        },
        fov = {
            enable = function(_ctx: Ctx, v: any, jan: Janitor.Janitor)
                local cam = workspace.CurrentCamera
                if cam then
                    hold(jan, cam, "FieldOfView", v)
                end
            end,
        },
        zoom = {
            enable = function(_ctx: Ctx, v: any, jan: Janitor.Janitor)
                jan:Set(Players.LocalPlayer, "CameraMaxZoomDistance", v)
            end,
        },
        camclip = {
            enable = function(_ctx: Ctx, _v: any, jan: Janitor.Janitor)
                jan:Set(
                    Players.LocalPlayer,
                    "DevCameraOcclusionMode",
                    Enum.DevCameraOcclusionMode.Invisicam
                )
            end,
        },
        -- Tour settings are read by the routine; switching them on is all they need.
        delay = { enable = function() end },
        loop = { enable = function() end },
        fromNearest = { enable = function() end },
        announce = { enable = function() end },
    }

    -- Walk your own character through this place's waypoints.
    local function run(ctx: Ctx, r: CtxTypes.Runner, _jan: Janitor.Janitor)
        local names = ctx.listOf("waypoint")
        if #names == 0 then
            r.status(ctx.t("m.sandbox.no_waypoints"))
            r.wait(3)
            return
        end
        repeat
            local start = 1
            if r.value("fromNearest") then
                local root = ctx.root()
                local best, bestD = 1, math.huge
                for i, name in names do
                    local p = ctx.waypoint(name)
                    if root and p then
                        local d = (root.Position - p).Magnitude
                        if d < bestD then
                            best, bestD = i, d
                        end
                    end
                end
                start = best
            end
            for step = 0, #names - 1 do
                local i = (start + step - 1) % #names + 1
                local name = names[i]
                r.status(ctx.t("m.sandbox.at", i, #names, name))
                r.progress((step + 1) / #names)
                local root, p = ctx.root(), ctx.waypoint(name)
                if root and p then
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.CFrame = CFrame.new(p) * root.CFrame.Rotation
                end
                if r.value("announce") then
                    ctx.toast("info", ctx.t("m.sandbox.at", i, #names, name))
                end
                if not r.wait(tonumber(r.value("delay")) or 3) then
                    return
                end
            end
        until not r.value("loop")
        r.status(ctx.t("m.sandbox.done"))
    end

    return { features = features, run = run }
end
