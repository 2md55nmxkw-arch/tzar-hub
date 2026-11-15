-- Interface details: fill bars, the dock and its slider card, toasts, TZAR icons and radii.
-- return function(A, check, expect, connCounts) ... end

local function find(root, name)
    return root:FindFirstChild(name, true)
end

local ACCENT = Color3.fromHex("e53945")

return function(A, check, expect)
    local function dbg()
        return A.Debug()
    end

    check("value command shows a fill bar that follows the value", function()
        A.App().openBar("speed")
        task.wait(0.15)
        local bar = find(dbg().bar, "FillBar")
        expect(bar, "no fill bar for speed")
        local ok, msg = A.Run("speed 250")
        expect(ok, msg)
        task.wait(0.35)
        bar = find(dbg().bar, "FillBar")
        local fill = find(bar, "Bar")
        expect(
            math.abs(fill.Size.X.Scale - 0.5) < 0.02,
            "fill " .. fill.Size.X.Scale .. " for 250 of 500"
        )
        expect(fill.BackgroundColor3 == ACCENT, "fill is not red while set")
        local value = find(bar, "Value")
        expect(value and value.Text == "250", "bar shows " .. tostring(value and value.Text))
        A.Run("speed")
        A.App().closeBar()
    end)

    check("fill bar uses the shared 8px radius and spans its row", function()
        A.App().openBar("speed")
        task.wait(0.15)
        local bar = find(dbg().bar, "FillBar")
        local track = find(bar, "Track")
        local c = track:FindFirstChildWhichIsA("UICorner")
        expect(c and c.CornerRadius.Offset == 8, "radius " .. tostring(c and c.CornerRadius))
        expect(
            math.abs(track.AbsoluteSize.X - bar.AbsoluteSize.X) <= 1,
            "track does not span the bar"
        )
        A.App().closeBar()
    end)

    check("dock shows pinned commands and their state", function()
        local dock = dbg().dock
        local fly = dock:FindFirstChild("Pin/fly")
        expect(fly, "fly is not on the dock")
        expect(fly.BackgroundColor3 ~= ACCENT, "fly looks on before it is")
        A.Run("fly")
        task.wait(0.1)
        fly = dbg().dock:FindFirstChild("Pin/fly")
        expect(fly.BackgroundColor3 == ACCENT, "fly tile not red while on")
        A.Run("unfly")
        task.wait(0.1)
        fly = dbg().dock:FindFirstChild("Pin/fly")
        expect(fly.BackgroundColor3 ~= ACCENT, "fly tile still red")
    end)

    check("dock slider card: bar, ± and presets", function()
        A.App().popover("speed")
        task.wait(0.15)
        local pop = find(dbg().layer, "Popover")
        expect(pop and pop.Visible, "no slider card")
        expect(find(pop, "FillBar"), "card has no bar")
        local presets = 0
        for _, x in pop:GetDescendants() do
            if x:IsA("TextButton") and tonumber(x.Text) then
                presets += 1
            end
        end
        expect(presets >= 4, "presets: " .. presets)
        A.Run("speed 64")
        task.wait(0.1)
        local lit = false
        for _, x in pop:GetDescendants() do
            if x:IsA("TextButton") and x.Text == "64" and x.TextColor3 == ACCENT then
                lit = true
            end
        end
        expect(lit, "preset 64 not highlighted")
        A.Run("speed")
        A.App().popover("speed") -- reopening replaces, never stacks
        local count = 0
        for _, x in dbg().layer:GetChildren() do
            if x.Name == "Popover" then
                count += 1
            end
        end
        expect(count == 1, count .. " slider cards")
    end)

    check("long lists scroll inside their panel instead of being cut off", function()
        local vp = workspace.CurrentCamera.ViewportSize
        local function fits(label, sf, box)
            local bottom = sf.AbsolutePosition.Y + sf.AbsoluteSize.Y
            expect(
                bottom <= box.AbsolutePosition.Y + box.AbsoluteSize.Y + 1,
                label .. " runs past its panel: " .. sf.AbsoluteSize.Y .. " tall"
            )
            expect(sf.AbsoluteSize.Y <= vp.Y, label .. " taller than the screen")
            local canvas, window = sf.AbsoluteCanvasSize.Y, sf.AbsoluteWindowSize.Y
            local content = sf:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y
            if content > window + 1 then
                expect(canvas > window, label .. " has more rows than room but cannot scroll")
            end
        end
        A.App().openPanel("commands")
        task.wait(0.3)
        local p = dbg().panels.commands
        fits("commands", p.Body, p)
        A.App().closePanel("commands")
        A.App().openBar("a")
        task.wait(0.3)
        local results = find(dbg().bar, "Results")
        fits("bar results", results, dbg().bar)
        A.App().closeBar()
    end)

    check("toasts appear at the bottom", function()
        A.Run("infjump on")
        task.wait(0.1)
        local stack = find(dbg().gui, "Toasts")
        expect(stack and #stack:GetChildren() > 1, "no toast")
        A.Run("infjump off")
    end)

    check("TZAR images are used when they are on disk", function()
        if not (isfile("TZAR/assets/logo.png") or isfile("AvatarChanger/assets/logo.png")) then
            return
        end
        local logo = find(dbg().dock, "Logo")
        expect(
            logo and logo:IsA("ImageLabel") and logo.Image ~= "",
            "dock logo is not the TZAR image"
        )
        if isfile("TZAR/assets/zap.png") then
            local fly = dbg().dock:FindFirstChild("Pin/fly")
            local icon = fly and find(fly, "Icon")
            expect(icon and icon:IsA("ImageLabel"), "fly has no icon image")
        end
    end)
end
