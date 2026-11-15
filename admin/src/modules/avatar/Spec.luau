--!strict
-- Avatar commands (the former Avatar Changer). Looks are put on your own character and only you
-- see them; emotes play through your own character's Animator.

local Types = require("../../Types")

local specs: { Types.CommandSpec } = {
    { name = "avatar", icon = "user", category = "avatar", kind = "action", module = "avatar" },
    {
        name = "emotewheel",
        icon = "sparkles",
        aliases = { "wheel" },
        category = "avatar",
        kind = "action",
        module = "avatar",
    },
    {
        name = "wear",
        icon = "user",
        aliases = { "char" },
        category = "avatar",
        kind = "value",
        module = "avatar",
        respawn = true,
        args = { { name = "user", kind = "user" } },
    },
    {
        name = "outfit",
        icon = "star",
        category = "avatar",
        kind = "value",
        module = "avatar",
        respawn = true,
        args = { { name = "outfit", kind = "outfit" } },
    },
    {
        name = "bundle",
        icon = "box",
        category = "avatar",
        kind = "value",
        module = "avatar",
        respawn = true,
        args = { { name = "bundle id", kind = "string" } },
    },
    {
        name = "saveoutfit",
        icon = "plus",
        category = "avatar",
        kind = "action",
        module = "avatar",
        args = { { name = "name", kind = "rest", optional = true } },
    },
    {
        name = "renameoutfit",
        icon = "list",
        category = "avatar",
        kind = "action",
        module = "avatar",
        args = { { name = "outfit", kind = "outfit" }, { name = "name", kind = "rest" } },
    },
    {
        name = "deloutfit",
        icon = "x",
        category = "avatar",
        kind = "action",
        module = "avatar",
        args = { { name = "outfit", kind = "outfit" } },
    },
    { name = "outfits", icon = "list", category = "avatar", kind = "action", module = "avatar" },
    {
        name = "exportoutfit",
        icon = "arrow-right",
        category = "avatar",
        kind = "action",
        module = "avatar",
        needs = { "writefile" },
        args = { { name = "outfit", kind = "outfit", optional = true } },
    },
    {
        name = "avatarrules",
        icon = "check",
        category = "avatar",
        kind = "toggle",
        module = "avatar",
    },
    {
        name = "emote",
        icon = "sparkles",
        aliases = { "e" },
        category = "avatar",
        kind = "action",
        module = "avatar",
        args = { { name = "emote", kind = "emote" } },
    },
    {
        name = "addemote",
        icon = "plus",
        category = "avatar",
        kind = "action",
        module = "avatar",
        args = {
            { name = "emote id", kind = "string" },
            { name = "name", kind = "rest", optional = true },
        },
    },
    {
        name = "delemote",
        icon = "x",
        category = "avatar",
        kind = "action",
        module = "avatar",
        args = { { name = "emote", kind = "emote" } },
    },
    { name = "emotes", icon = "list", category = "avatar", kind = "action", module = "avatar" },
}

return specs
