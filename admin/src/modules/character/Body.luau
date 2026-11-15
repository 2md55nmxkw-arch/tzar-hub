--!strict
-- Shared lookups for the local character.

local CtxTypes = require("../../Ctx")

type Ctx = CtxTypes.Ctx

local Body = {}

-- The character, its Humanoid and root part, or a user-facing error.
function Body.need(ctx: Ctx): (Model, Humanoid, BasePart)
    local char = ctx.character()
    local hum = ctx.humanoid()
    local root = ctx.root()
    if not (char and hum and root) or hum.Health <= 0 then
        ctx.fail(ctx.t("chr.no_character"))
    end
    return char :: Model, hum :: Humanoid, root :: BasePart
end

return Body
