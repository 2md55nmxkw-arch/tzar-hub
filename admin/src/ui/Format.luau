--!strict
-- Text helpers shared by views: command signatures and value formatting.

local Types = require("../Types")

local Format = {}

function Format.argLabel(a: Types.ArgSpec): string
    local inner = a.name
    if a.kind == "number" and a.min and a.max then
        inner = string.format("%s–%s", Format.value(a.min), Format.value(a.max))
    elseif a.kind == "enum" and a.options then
        inner = table.concat(a.options, "|")
    end
    return if a.optional then "[" .. inner .. "]" else "<" .. inner .. ">"
end

-- `current` underlines that argument (1-based) using RichText.
function Format.signature(spec: Types.CommandSpec, current: number?, rich: boolean?): string
    local parts = { spec.name }
    for i, a in spec.args or {} do
        local s = Format.argLabel(a)
        if rich then
            s = string.gsub(string.gsub(s, "<", "&lt;"), ">", "&gt;")
            if i == current then
                s = '<u><font color="#ededed">' .. s .. "</font></u>"
            end
        end
        table.insert(parts, s)
    end
    return table.concat(parts, " ")
end

function Format.value(v: any): string
    if type(v) == "number" then
        if v == math.floor(v) then
            return tostring(math.floor(v))
        end
        return string.format("%.1f", v)
    elseif typeof(v) == "Instance" then
        return (v :: Instance).Name
    elseif typeof(v) == "EnumItem" then
        return (v :: EnumItem).Name
    elseif v == nil then
        return "—"
    end
    return tostring(v)
end

-- Quotes an argument that contains spaces so the tokenizer keeps it whole.
function Format.quote(s: string): string
    return if string.find(s, "%s") then '"' .. s .. '"' else s
end

-- First argument the user has to supply, if any.
function Format.requiredArg(spec: Types.CommandSpec): (Types.ArgSpec?, number)
    for i, a in spec.args or {} do
        if not a.optional then
            return a, i
        end
    end
    return nil, 0
end

return Format
