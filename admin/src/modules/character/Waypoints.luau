--!strict
-- Waypoints per place in TZAR/admin/waypoints.json: { [placeId]: { [name]: {x, y, z, yaw} } }.

local HttpService = game:GetService("HttpService")

local Body = require("./Body")
local CtxTypes = require("../../Ctx")
local Env = require("../../platform/Env")

type Ctx = CtxTypes.Ctx
type Point = { x: number, y: number, z: number, yaw: number }

local PATH = "TZAR/admin/waypoints.json"

local Waypoints = {}

function Waypoints.module(): ({ [string]: CtxTypes.Handler }, (ctx: Ctx) -> { string })
    local all: { [string]: { [string]: Point } }? = nil

    local function place(): { [string]: Point }
        if not all then
            local body = Env.readFile(PATH)
            local data = body and Env.json(body)
            all = if type(data) == "table" then data else {}
        end
        local key = tostring(game.PlaceId)
        local t = all :: { [string]: { [string]: Point } }
        t[key] = t[key] or {}
        return t[key]
    end

    local function save()
        local ok, body = pcall(HttpService.JSONEncode, HttpService, all or {})
        if ok then
            Env.writeFile(PATH, body)
        end
    end

    local function names(): { string }
        local out = {}
        for name in place() do
            table.insert(out, name)
        end
        table.sort(out)
        return out
    end

    local handlers: { [string]: CtxTypes.Handler } = {
        setwp = {
            run = function(ctx: Ctx, args: { any })
                local _, _, root = Body.need(ctx)
                local name = string.gsub(args[1] :: string, "^%s*(.-)%s*$", "%1")
                local p = root.Position
                local _, yaw = root.CFrame:ToOrientation()
                place()[name] = { x = p.X, y = p.Y, z = p.Z, yaw = yaw }
                save()
                ctx.toast("ok", ctx.t("chr.wp_saved", name))
            end,
        },
        wp = {
            run = function(ctx: Ctx, args: { any })
                local _, _, root = Body.need(ctx)
                local name = args[1] :: string
                local pt = place()[name]
                if not pt then
                    ctx.fail(ctx.t("arg.waypoint", name))
                end
                root.AssemblyLinearVelocity = Vector3.zero
                root.CFrame = CFrame.new(pt.x, pt.y, pt.z) * CFrame.Angles(0, pt.yaw or 0, 0)
                ctx.toast("ok", ctx.t("chr.wp_moved", name))
            end,
        },
        delwp = {
            run = function(ctx: Ctx, args: { any })
                local name = args[1] :: string
                place()[name] = nil
                save()
                ctx.toast("ok", ctx.t("chr.wp_deleted", name))
            end,
        },
        waypoints = {
            run = function(ctx: Ctx)
                local list = names()
                if #list == 0 then
                    ctx.toast("info", ctx.t("chr.wp_none"))
                else
                    ctx.toast("info", ctx.t("chr.wp_list", table.concat(list, ", ")))
                end
            end,
        },
    }
    return handlers, function()
        return names()
    end
end

return Waypoints
