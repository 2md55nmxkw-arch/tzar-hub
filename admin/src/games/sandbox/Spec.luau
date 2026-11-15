--!strict
-- Sandbox: a demo of the big-module frame that works in any place. Everything is local to this
-- client and to your own character.

local Types = require("../../Types")

local spec: Types.GameModuleSpec = {
    id = "sandbox",
    badge = "Demo",
    sections = { "light", "camera", "body", "tour" },
    runner = true,
    features = {
        {
            id = "brightness",
            section = "light",
            kind = "number",
            min = 0,
            max = 6,
            step = 0.1,
            default = 2,
        },
        { id = "nofog", section = "light", kind = "toggle" },
        { id = "night", section = "light", kind = "toggle" },
        {
            id = "tone",
            section = "light",
            kind = "choice",
            options = { "neutral", "warm", "cold", "mono" },
        },
        {
            id = "contrast",
            section = "light",
            kind = "number",
            min = -1,
            max = 1,
            step = 0.05,
            default = 0,
        },
        { id = "noshadows", section = "light", kind = "toggle" },
        {
            id = "fov",
            section = "camera",
            kind = "number",
            min = 40,
            max = 120,
            step = 1,
            default = 70,
        },
        {
            id = "zoom",
            section = "camera",
            kind = "number",
            min = 10,
            max = 2000,
            step = 10,
            default = 400,
        },
        { id = "camclip", section = "camera", kind = "toggle" },
        { id = "fly", section = "body", kind = "toggle", command = "fly" },
        { id = "noclip", section = "body", kind = "toggle", command = "noclip" },
        {
            id = "speed",
            section = "body",
            kind = "number",
            min = 0,
            max = 200,
            step = 1,
            default = 16,
            command = "speed",
        },
        {
            id = "jump",
            section = "body",
            kind = "number",
            min = 0,
            max = 300,
            step = 1,
            default = 50,
            command = "jumppower",
        },
        { id = "infjump", section = "body", kind = "toggle", command = "infjump" },
        { id = "antiafk", section = "body", kind = "toggle", command = "antiafk" },
        {
            id = "delay",
            section = "tour",
            kind = "number",
            min = 0.5,
            max = 10,
            step = 0.5,
            default = 3,
        },
        { id = "loop", section = "tour", kind = "toggle" },
        { id = "fromNearest", section = "tour", kind = "toggle" },
        { id = "announce", section = "tour", kind = "toggle" },
    },
    presets = {
        { id = "night", values = { night = true, nofog = true, tone = "cold", brightness = 1 } },
        { id = "explore", values = { fly = true, noclip = true, speed = 64, fov = 90 } },
        {
            id = "photo",
            values = { fov = 50, zoom = 800, camclip = true, brightness = 3, tone = "warm" },
        },
    },
}

return spec
