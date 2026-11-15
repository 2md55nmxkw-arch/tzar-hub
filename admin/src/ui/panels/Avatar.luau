--!strict
-- The avatar panel: wear someone from this server or by name, saved outfits, body bundles from the
-- catalog and the emote wheel's contents. Everything goes through the avatar commands, so the
-- panel, the command bar and binds always agree. Desktop: a 760px window with a live preview on
-- the left. Touch: a drawer between the thumbstick and the jump button.

local Players = game:GetService("Players")

local Common = require("./Common")
local Controls = require("../Controls")
local Create = require("../Create")
local Drag = require("../Drag")
local Janitor = require("../../core/Janitor")
local Signal = require("../../core/Signal")
local Theme = require("../Theme")

local C, F, LINE, S = Theme.C, Theme.F, Theme.LINE, Theme.SIZE
local new, corner, pad, list = Create.new, Create.corner, Create.pad, Create.list

-- What the avatar module hands out (see modules/avatar/Impl.luau).
type Page = {
    items: { { id: number, name: string } },
    finished: () -> boolean,
    next: () -> { { id: number, name: string } },
}
type Api = {
    Changed: Signal.Signal<>,
    State: () -> { owner: string?, label: string?, source: string? },
    Outfits: () -> { string },
    Wheel: () -> { { id: number, name: string, fromOutfit: boolean } },
    OutfitEmotes: () -> boolean,
    SetOutfitEmotes: (on: boolean) -> (),
    Preview: () -> Model?,
    Search: (query: string, sort: string?) -> Page?,
    Reset: () -> (),
}

type Entry = { name: string, meta: string, selected: boolean, wear: () -> (), saved: boolean }

export type AvatarPanel = {
    frame: Frame,
    open: (tab: string?) -> (),
    close: () -> (),
    isOpen: () -> boolean,
}

local ON_BG = Color3.fromHex("2a1416")
local ON_TEXT = Color3.fromHex("ff8a93")
local LONG_PRESS = 0.45
local SORTS = { "best", "fav", "new" }
local TABS = { "look", "catalog", "emotes" }

local AvatarPanel = {}

local function quote(s: string): string
    return '"' .. string.gsub(s, '"', "") .. '"'
end

-- Right-click on desktop, long press on touch.
local function onSecondary(jan: Janitor.Janitor, b: GuiButton, fn: () -> ()): () -> boolean
    local pressAt, fired = 0, false
    jan:Connect(b.MouseButton2Click, fn)
    jan:Connect(b.InputBegan, function(io: InputObject)
        if io.UserInputType == Enum.UserInputType.Touch then
            pressAt = os.clock()
            fired = false
            local stamp = pressAt
            task.delay(LONG_PRESS, function()
                if pressAt == stamp and b.Parent then
                    fired = true
                    fn()
                end
            end)
        end
    end)
    jan:Connect(b.InputEnded, function(io: InputObject)
        if io.UserInputType == Enum.UserInputType.Touch then
            pressAt = 0
        end
    end)
    -- Activated after a long press should do nothing.
    return function(): boolean
        if fired then
            fired = false
            return true
        end
        return false
    end
end

-- A grey stand-in figure for outfits that have no picture of their own.
local function figure(parent: Instance, w: number, h: number): Frame
    local box = new("Frame", {
        Name = "Figure",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(w, h),
        Parent = parent,
    })
    local col = Color3.fromHex("3a3a3a")
    for _, p in
        {
            { 0.38, 0.0, 0.24, 0.19 },
            { 0.3, 0.21, 0.4, 0.34 },
            { 0.14, 0.21, 0.14, 0.32 },
            { 0.72, 0.21, 0.14, 0.32 },
            { 0.31, 0.57, 0.18, 0.4 },
            { 0.51, 0.57, 0.18, 0.4 },
        }
    do
        new("Frame", {
            BackgroundColor3 = col,
            BorderSizePixel = 0,
            Position = UDim2.fromScale(p[1], p[2]),
            Size = UDim2.fromScale(p[3], p[4]),
            Parent = box,
        }, { corner(3) })
    end
    return box
end

local function flow(parent: Instance, order: number, gap: number): Frame
    local f = new("Frame", {
        Name = "Flow",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order,
        Parent = parent,
    })
    new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Wraps = true,
        Padding = UDim.new(0, gap),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = f,
    })
    return f
end

local function row(parent: Instance, order: number, h: number): Frame
    return new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, h),
        LayoutOrder = order,
        Parent = parent,
    }, { list("x", 8) })
end

local function flex(parent: Instance, order: number)
    local sp = new("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(0, 1),
        LayoutOrder = order,
        Parent = parent,
    })
    pcall(function()
        new("UIFlexItem", { FlexMode = Enum.UIFlexMode.Fill, Parent = sp })
    end)
end

local function field(
    parent: Instance,
    placeholder: string,
    w: UDim2,
    order: number
): (Frame, TextBox)
    local f = new("Frame", {
        Name = "Field",
        BackgroundColor3 = C.raised,
        Size = w,
        LayoutOrder = order,
        Parent = parent,
    }, { corner(S.radius), pad(10, 8) })
    local box = new("TextBox", {
        Name = "Input",
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Text = "",
        PlaceholderText = placeholder,
        PlaceholderColor3 = C.text3,
        TextColor3 = C.text1,
        TextSize = 12.5,
        FontFace = F.regular,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        AutoLocalize = false,
        Parent = f,
    })
    return f, box
end

function AvatarPanel.new(layer: Instance, jan: Janitor.Janitor, deps: Common.Deps): AvatarPanel
    local touch = Theme.touch
    local t, store, reg = deps.t, deps.store, deps.registry
    local api: Api = reg:Api("avatar") :: any
    local W = if touch then S.panelTouch else 760
    local NAV = if touch then 0 else 222
    local BODY_H = 404

    local frame = new("Frame", {
        Name = "Avatar",
        Size = UDim2.fromOffset(W, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = C.surface,
        Visible = false,
        Active = true,
        Parent = layer,
    }, { corner(if touch then S.card else S.window), Create.stroke(LINE.strong), list("y", 0) })
    Create.shadow(frame, Theme.SHADOW.window)

    local tab = "look"
    local isOpen = false
    local pageJan = Janitor.new()
    jan:Add(pageJan)
    local previewJan = Janitor.new()
    jan:Add(previewJan)

    local function state()
        return api.State()
    end

    -- Header
    local header = new("Frame", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, if touch then 50 else 52),
        LayoutOrder = 1,
        Active = true,
        Parent = frame,
    }, { pad(if touch then 12 else 16, 12), list("x", 9) })
    Controls.logo(header, 15).LayoutOrder = 1
    Create.text(
        { text = t("avu.title"), size = if touch then 15 else 14, font = F.semibold, auto = true },
        { LayoutOrder = 2, Parent = header }
    )
    local badge = new("Frame", {
        Name = "Badge",
        BackgroundColor3 = C.white,
        BackgroundTransparency = 0.94,
        AutomaticSize = Enum.AutomaticSize.X,
        Size = UDim2.fromOffset(0, 20),
        LayoutOrder = 3,
        Parent = header,
    }, { corner(6), pad(7, 8), list("x", 5) })
    Controls.glyph("eye", badge, 11, C.text2).LayoutOrder = 1
    Create.text(
        { text = t("avu.only_you"), size = 10, font = F.medium, color = C.text2, auto = true },
        { LayoutOrder = 2, Parent = badge }
    )
    flex(header, 4)
    local searchFrame, searchBox = field(
        header,
        t("avu.search"),
        UDim2.fromOffset(if touch then 150 else 250, if touch then 36 else 30),
        5
    )
    searchFrame.Name = "Search"
    local close = Controls.iconButton(header, "x")
    close.LayoutOrder = 6
    Controls.hairline(frame, 2)

    -- Body
    local body = new("Frame", {
        Name = "Body",
        BackgroundTransparency = 1,
        Size = if touch then UDim2.fromScale(1, 0) else UDim2.new(1, 0, 0, BODY_H),
        AutomaticSize = if touch then Enum.AutomaticSize.Y else Enum.AutomaticSize.None,
        LayoutOrder = 3,
        Parent = frame,
    })

    -- Preview (desktop)
    local viewport: ViewportFrame? = nil
    local previewName: TextLabel? = nil
    local previewMeta: TextLabel? = nil
    if not touch then
        local left = new("Frame", {
            Name = "Preview",
            BackgroundTransparency = 1,
            Size = UDim2.new(0, NAV, 1, 0),
            Parent = body,
        }, { pad(16, 16, 16, 16), list("y", 10) })
        local card = new("Frame", {
            Name = "Card",
            BackgroundColor3 = C.track,
            Size = UDim2.new(1, 0, 0, 262),
            ClipsDescendants = true,
            LayoutOrder = 1,
            Parent = left,
        }, { corner(S.card), Create.stroke(LINE.subtle) })
        local vf = new("ViewportFrame", {
            Name = "Viewport",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -34),
            Ambient = Color3.fromRGB(150, 150, 150),
            LightColor = Color3.new(1, 1, 1),
            LightDirection = Vector3.new(-0.6, -1, -0.8),
            Parent = card,
        })
        viewport = vf
        local cap = new("Frame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 1, -34),
            Size = UDim2.new(1, 0, 0, 34),
            Parent = card,
        }, { pad(12, 12) })
        previewName = Create.text(
            { text = "", size = 13, font = F.medium },
            { Size = UDim2.new(1, -34, 1, 0), Parent = cap }
        )
        Create.text({
            text = "R15",
            size = 10,
            font = F.mono,
            color = C.text3,
            x = Enum.TextXAlignment.Right,
        }, {
            Name = "Rig",
            AnchorPoint = Vector2.new(1, 0),
            Position = UDim2.fromScale(1, 0),
            Size = UDim2.new(0, 30, 1, 0),
            Parent = cap,
        })
        previewMeta = Create.text(
            { text = "", size = 10, font = F.mono, color = C.text3, x = Enum.TextXAlignment.Center },
            {
                Size = UDim2.new(1, 0, 0, 14),
                LayoutOrder = 2,
                Parent = left,
            }
        )
        local reset = Controls.button(left, t("avu.reset"), "plain", "refresh")
        reset.Name = "Reset"
        reset.AutomaticSize = Enum.AutomaticSize.None
        reset.Size = UDim2.new(1, 0, 0, 36)
        reset.LayoutOrder = 3
        local rl = reset:FindFirstChildOfClass("UIListLayout")
        if rl then
            rl.HorizontalAlignment = Enum.HorizontalAlignment.Center
        end
        jan:Connect(reset.Activated, function()
            task.spawn(api.Reset)
        end)
        new("Frame", {
            BackgroundColor3 = C.white,
            BackgroundTransparency = LINE.default,
            BorderSizePixel = 0,
            Position = UDim2.fromOffset(NAV, 0),
            Size = UDim2.new(0, 1, 1, 0),
            Parent = body,
        })
    end

    local right = new("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(if touch then 0 else NAV + 1, 0),
        Size = if touch then UDim2.fromScale(1, 0) else UDim2.new(1, -NAV - 1, 1, 0),
        AutomaticSize = if touch then Enum.AutomaticSize.Y else Enum.AutomaticSize.None,
        Parent = body,
    }, {
        pad(
            if touch then 12 else 16,
            if touch then 12 else 16,
            if touch then 8 else 14,
            if touch then 4 else 0
        ),
        list("y", 10),
    })
    local CONTENT_W = W - (if touch then 24 else NAV + 1 + 32) - 6

    local tabsBar = new("Frame", {
        Name = "Tabs",
        BackgroundColor3 = C.track,
        AutomaticSize = if touch then Enum.AutomaticSize.None else Enum.AutomaticSize.X,
        Size = if touch then UDim2.new(1, 0, 0, 38) else UDim2.fromOffset(0, 34),
        LayoutOrder = 1,
        Parent = right,
    }, { corner(S.radius), pad(3, 3, 3, 3), list("x", 2) })
    local tabButtons: { [string]: TextButton } = {}
    for i, id in TABS do
        local b = new("TextButton", {
            Name = "Tab/" .. id,
            Text = t("avu.tab_" .. id),
            AutoButtonColor = false,
            BackgroundColor3 = C.control,
            BackgroundTransparency = 1,
            AutomaticSize = if touch then Enum.AutomaticSize.None else Enum.AutomaticSize.X,
            Size = if touch then UDim2.new(1 / #TABS, -2, 1, 0) else UDim2.fromScale(0, 1),
            TextSize = 13,
            FontFace = F.medium,
            TextColor3 = C.text2,
            AutoLocalize = false,
            LayoutOrder = i,
            Parent = tabsBar,
        }, { corner(6), pad(10, 10) })
        tabButtons[id] = b
    end

    local page = new("ScrollingFrame", {
        Name = "Page",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = if touch then UDim2.fromScale(1, 0) else UDim2.new(1, 0, 1, -44),
        CanvasSize = UDim2.fromScale(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = C.text3,
        LayoutOrder = 2,
        Parent = right,
    }, { pad(0, 6, 0, 12), list("y", 10) })
    if touch then
        Create.fitScroll(page, function(): number
            return 150
        end)
    end

    -- Footer
    Controls.hairline(frame, 4)
    local foot = new("Frame", {
        Name = "Status",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, if touch then 54 else 52),
        LayoutOrder = 5,
        Parent = frame,
    }, { pad(if touch then 12 else 16, 14), list("x", 10) })
    local dot = new("Frame", {
        Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = C.text3,
        LayoutOrder = 1,
        Parent = foot,
    }, { corner(4) })
    local statusText = Create.text(
        { text = "", size = 13, font = F.medium, auto = true },
        { Name = "Text", LayoutOrder = 2, Parent = foot }
    )
    local hintText = Create.text(
        { text = "", size = 10.5, font = F.mono, color = C.text3, auto = true },
        { LayoutOrder = 3, Parent = foot }
    )
    hintText.Visible = not touch
    flex(foot, 4)
    local leftBtn = if touch
        then Controls.button(foot, t("avu.reset"), "plain")
        else Controls.button(foot, t("avu.export"), "ghost", "arrow-right")
    leftBtn.LayoutOrder = 5
    local saveBtn = Controls.button(
        foot,
        if touch then t("avu.save_short") else t("avu.save"),
        "accent",
        if touch then nil else "check"
    )
    saveBtn.Name = "Save"
    saveBtn.LayoutOrder = 6
    jan:Connect(leftBtn.Activated, function()
        if touch then
            task.spawn(api.Reset)
        else
            deps.run("exportoutfit")
        end
    end)
    jan:Connect(saveBtn.Activated, function()
        deps.run("saveoutfit")
    end)

    local function sourceText(s: { owner: string?, label: string?, source: string? }): string
        if not s.owner then
            return t("avu.status_mine")
        end
        return t("avu.status_worn", s.label or "?")
            .. (if s.source then " · " .. t("avu.src_" .. s.source) else "")
    end

    local function renderStatus()
        local s = state()
        dot.BackgroundColor3 = if s.owner then C.ok else C.text3
        statusText.Text = Create.marked(sourceText(s), nil)
        hintText.Text = if s.owner then t("avu.hint_unwear") else t("avu.hint_wear")
        if previewName then
            previewName.Text = Create.marked(s.label or Players.LocalPlayer.DisplayName, nil)
        end
        if previewMeta then
            previewMeta.Text = if s.owner
                then t("avu.src_" .. (s.source or "outfit"))
                else "@" .. Players.LocalPlayer.Name
        end
    end

    -- Live preview of what you wear, on a turntable you can turn by dragging.
    local function renderPreview()
        if not viewport then
            return
        end
        local vf: ViewportFrame = viewport :: any
        previewJan:Cleanup()
        for _, c in vf:GetChildren() do
            c:Destroy()
        end
        local model = api.Preview()
        if not model then
            return
        end
        local world = Instance.new("WorldModel")
        world.Parent = vf
        previewJan:Add(world)
        model:PivotTo(CFrame.new())
        model.Parent = world
        local cf, size = model:GetBoundingBox()
        local cam = Instance.new("Camera")
        cam.FieldOfView = 30
        local dist = (size.Y / 2) / math.tan(math.rad(15)) * 1.12
        local yaw = 0
        local function place()
            local rot = CFrame.Angles(0, yaw, 0)
            cam.CFrame = CFrame.lookAt(
                cf.Position + rot:VectorToWorldSpace(Vector3.new(0, size.Y * 0.04, -dist)),
                cf.Position
            )
        end
        place()
        cam.Parent = vf
        vf.CurrentCamera = cam
        local dragging: Vector3? = nil
        previewJan:Connect(vf.InputBegan, function(io: InputObject)
            if
                io.UserInputType == Enum.UserInputType.MouseButton1
                or io.UserInputType == Enum.UserInputType.Touch
            then
                dragging = io.Position
            end
        end)
        previewJan:Connect(vf.InputChanged, function(io: InputObject)
            local d = dragging
            if
                d
                and (
                    io.UserInputType == Enum.UserInputType.MouseMovement
                    or io.UserInputType == Enum.UserInputType.Touch
                )
            then
                yaw -= (io.Position.X - d.X) * 0.012
                dragging = io.Position
                place()
            end
        end)
        previewJan:Connect(vf.InputEnded, function(io: InputObject)
            if
                io.UserInputType == Enum.UserInputType.MouseButton1
                or io.UserInputType == Enum.UserInputType.Touch
            then
                dragging = nil
            end
        end)
    end

    -- Pages
    local expanded = false
    local sort = 1
    local catalogKind = "bodies"
    local query = ""
    local results: { { id: number, name: string } } = {}
    local pager: Page? = nil
    local searching = false
    local searchToken = 0

    local renderPage: () -> ()

    local function clearPage()
        pageJan:Cleanup()
        for _, c in page:GetChildren() do
            if c:IsA("GuiObject") then
                c:Destroy()
            end
        end
    end

    local function eyebrowRow(order: number, text: string): Frame
        local r = row(page, order, 22)
        Controls.eyebrow(r, text).LayoutOrder = 1
        flex(r, 2)
        return r
    end

    local function note(order: number, text: string)
        Create.text(
            { text = text, size = 12.5, color = C.text3 },
            { Size = UDim2.new(1, 0, 0, 28), LayoutOrder = order, Parent = page }
        )
    end

    local function lookPage()
        local s = state()
        local others: { Player } = {}
        for _, p in Players:GetPlayers() do
            if p ~= Players.LocalPlayer then
                table.insert(others, p)
            end
        end
        table.sort(others, function(a: Player, b: Player)
            return string.lower(a.DisplayName) < string.lower(b.DisplayName)
        end)
        local head = eyebrowRow(1, t("avu.server", #others))
        if not touch then
            Create.text(
                { text = t("avu.server_hint"), size = 10.5, color = C.text3, auto = true },
                { LayoutOrder = 3, Parent = head }
            )
        end
        local function worn(p: Player): boolean
            return s.owner == "wear" and s.source == "server" and s.label == p.Name
        end
        if #others == 0 then
            note(2, t("avu.alone"))
        elseif touch then
            local strip = new("ScrollingFrame", {
                Name = "Players",
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 68),
                CanvasSize = UDim2.fromScale(0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.X,
                ScrollingDirection = Enum.ScrollingDirection.X,
                ScrollBarThickness = 0,
                LayoutOrder = 2,
                Parent = page,
            }, { list("x", 8, Enum.VerticalAlignment.Top) })
            for i, p in others do
                local on = worn(p)
                local b = new("TextButton", {
                    Name = "Player/" .. p.Name,
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(62, 66),
                    LayoutOrder = i,
                    Parent = strip,
                })
                local av = Controls.avatar(b, p.UserId, 44)
                av.AnchorPoint = Vector2.new(0.5, 0)
                av.Position = UDim2.fromScale(0.5, 0)
                if on then
                    Create.stroke(0, C.accent).Parent = av
                end
                Create.text({
                    text = Create.marked(p.DisplayName, nil),
                    size = 11,
                    font = if on then F.medium else F.regular,
                    color = if on then ON_TEXT else C.text2,
                    x = Enum.TextXAlignment.Center,
                }, {
                    Position = UDim2.fromOffset(0, 49),
                    Size = UDim2.new(1, 0, 0, 16),
                    Parent = b,
                })
                pageJan:Connect(b.Activated, function()
                    deps.run("wear " .. p.Name)
                end)
            end
        else
            local grid = flow(page, 2, 6)
            grid.Name = "Players"
            local shown = if expanded or #others <= 6 then #others else 5
            local tileW = math.floor((CONTENT_W - 12) / 3)
            for i = 1, shown do
                local p = others[i]
                local on = worn(p)
                local b = new("TextButton", {
                    Name = "Player/" .. p.Name,
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundColor3 = if on then ON_BG else C.track,
                    Size = UDim2.fromOffset(tileW, 44),
                    LayoutOrder = i,
                    Parent = grid,
                }, { corner(S.radius), pad(6, 10), list("x", 9) })
                Controls.avatar(b, p.UserId, 32).LayoutOrder = 1
                local col = new("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -54, 1, 0),
                    LayoutOrder = 2,
                    Parent = b,
                }, { list("y", 0, Enum.VerticalAlignment.Center) })
                Create.text(
                    { text = Create.marked(p.DisplayName, nil), size = 13, font = F.medium },
                    { Size = UDim2.new(1, 0, 0, 17), Parent = col }
                )
                Create.text(
                    { text = "@" .. p.Name, size = 10.5, font = F.mono, color = C.text3 },
                    { Size = UDim2.new(1, 0, 0, 13), LayoutOrder = 2, Parent = col }
                )
                if on then
                    new("Frame", {
                        Size = UDim2.fromOffset(6, 6),
                        BackgroundColor3 = C.accent,
                        LayoutOrder = 3,
                        Parent = b,
                    }, { corner(3) })
                end
                pageJan:Connect(b.Activated, function()
                    deps.run("wear " .. p.Name)
                end)
            end
            if shown < #others then
                local more = new("TextButton", {
                    Name = "More",
                    Text = t("avu.more", #others - shown),
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(tileW, 44),
                    TextSize = 12.5,
                    FontFace = F.medium,
                    TextColor3 = C.text2,
                    AutoLocalize = false,
                    LayoutOrder = 99,
                    Parent = grid,
                }, { corner(S.radius), Create.stroke(LINE.default) })
                pageJan:Connect(more.Activated, function()
                    expanded = true
                    renderPage()
                end)
            end
        end

        -- Outfits
        local outfits = api.Outfits()
        local oh = eyebrowRow(3, t("avu.outfits", #outfits))
        local saveCur = new("TextButton", {
            Name = "SaveCurrent",
            Text = "",
            AutoButtonColor = false,
            BackgroundTransparency = 1,
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.fromScale(0, 1),
            LayoutOrder = 3,
            Parent = oh,
        }, { list("x", 5) })
        Controls.glyph("plus", saveCur, 12, C.text2).LayoutOrder = 1
        Create.text({
            text = t("avu.save_current"),
            size = 12.5,
            font = F.medium,
            color = C.text2,
            auto = true,
        }, { LayoutOrder = 2, Parent = saveCur })
        pageJan:Connect(saveCur.Activated, function()
            deps.run("saveoutfit")
        end)

        local entries: { Entry } = {
            {
                name = t("avu.mine"),
                meta = t("avu.meta_mine"),
                selected = s.owner == nil,
                saved = false,
                wear = function()
                    task.spawn(api.Reset)
                end,
            },
        }
        if s.owner and s.owner ~= "outfit" then
            table.insert(entries, {
                name = s.label or "?",
                meta = t("avu.meta_worn"),
                selected = true,
                saved = false,
                wear = function() end,
            })
        end
        for _, name in outfits do
            table.insert(entries, {
                name = name,
                meta = t("avu.meta_saved"),
                selected = s.owner == "outfit" and s.label == name,
                saved = true,
                wear = function()
                    deps.run("outfit " .. quote(name))
                end,
            })
        end
        local grid = flow(page, 4, if touch then 6 else 8)
        grid.Name = "Outfits"
        for i, e in entries do
            local b: TextButton
            if touch then
                b = new("TextButton", {
                    Name = "Outfit/" .. e.name,
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundColor3 = if e.selected then ON_BG else C.control,
                    AutomaticSize = Enum.AutomaticSize.X,
                    Size = UDim2.fromOffset(0, 38),
                    LayoutOrder = i,
                    Parent = grid,
                }, { corner(S.radius), pad(12, 12), list("x", 6) })
                if e.selected then
                    new("Frame", {
                        Size = UDim2.fromOffset(6, 6),
                        BackgroundColor3 = C.accent,
                        LayoutOrder = 1,
                        Parent = b,
                    }, { corner(3) })
                end
                Create.text(
                    { text = Create.marked(e.name, nil), size = 13, font = F.medium, auto = true },
                    { LayoutOrder = 2, Parent = b }
                )
            else
                b = new("TextButton", {
                    Name = "Outfit/" .. e.name,
                    Text = "",
                    AutoButtonColor = false,
                    BackgroundTransparency = 1,
                    Size = UDim2.fromOffset(104, 120),
                    LayoutOrder = i,
                    Parent = grid,
                }, { corner(S.radius), pad(4, 4, 4, 6), list("y", 4) })
                Create.stroke(
                    if e.selected then 0 else LINE.subtle,
                    if e.selected then C.accent else nil
                ).Parent =
                    b
                local thumb = new("Frame", {
                    BackgroundColor3 = C.control,
                    Size = UDim2.new(1, 0, 0, 66),
                    LayoutOrder = 1,
                    Parent = b,
                }, { corner(6) })
                figure(thumb, 30, 44)
                local txtCol = new("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 36),
                    LayoutOrder = 2,
                    Parent = b,
                }, { pad(4, 4), list("y", 1) })
                Create.text(
                    { text = Create.marked(e.name, nil), size = 13, font = F.medium },
                    { Size = UDim2.new(1, 0, 0, 17), Parent = txtCol }
                )
                Create.text({
                    text = "<uc>" .. Create.marked(e.meta, nil) .. "</uc>",
                    size = 9.5,
                    font = F.mono,
                    color = C.text3,
                }, {
                    Size = UDim2.new(1, 0, 0, 13),
                    LayoutOrder = 2,
                    Parent = txtCol,
                })
            end
            local suppressed = onSecondary(pageJan, b, function()
                if e.saved then
                    deps.openBar("deloutfit " .. quote(e.name))
                end
            end)
            pageJan:Connect(b.Activated, function()
                if not suppressed() then
                    e.wear()
                end
            end)
        end

        -- Game rules
        local rules = new("TextButton", {
            Name = "Rules",
            Text = "",
            AutoButtonColor = false,
            BackgroundColor3 = C.track,
            Size = UDim2.new(1, 0, 0, if touch then 44 else 50),
            LayoutOrder = 5,
            Parent = page,
        }, { corner(S.radius), pad(12, 12) })
        local rc = new(
            "Frame",
            { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 1, 0), Parent = rules },
            { list("y", 2, Enum.VerticalAlignment.Center) }
        )
        Create.text(
            { text = t("avu.rules"), size = 13, font = F.medium },
            { Size = UDim2.new(1, 0, 0, 17), Parent = rc }
        )
        if not touch then
            Create.text(
                { text = t("avu.rules_sub"), size = 11, color = C.text3 },
                { Size = UDim2.new(1, 0, 0, 14), LayoutOrder = 2, Parent = rc }
            )
        end
        local sw = Controls.switch(rules)
        sw.frame.AnchorPoint = Vector2.new(1, 0.5)
        sw.frame.Position = UDim2.fromScale(1, 0.5)
        sw.set(reg:IsActive("avatarrules"))
        pageJan:Connect(rules.Activated, function()
            deps.run("avatarrules")
        end)
    end

    local function catalogPage()
        local r = row(page, 1, 32)
        local f, box = field(r, t("avu.catalog_search"), UDim2.new(1, -150, 1, 0), 1)
        f.Name = "CatalogSearch"
        box.Text = query
        local sortBtn = new("TextButton", {
            Name = "Sort",
            Text = "",
            AutoButtonColor = false,
            BackgroundColor3 = C.track,
            Size = UDim2.new(0, 142, 1, 0),
            LayoutOrder = 2,
            Parent = r,
        }, { corner(S.radius), pad(10, 10), list("x", 6) })
        Create.text({
            text = t("avu.sort_" .. SORTS[sort]),
            size = 12.5,
            font = F.medium,
            color = C.text2,
            auto = true,
        }, { LayoutOrder = 1, Parent = sortBtn })
        Controls.glyph("chevron-down", sortBtn, 12, C.text3).LayoutOrder = 2

        local chips = row(page, 2, if touch then 34 else 30)
        for i, kind in { "bodies", "mine" } do
            local on = catalogKind == kind
            local c = new("TextButton", {
                Name = "Kind/" .. kind,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = if on then ON_BG else C.track,
                AutomaticSize = Enum.AutomaticSize.X,
                Size = UDim2.fromScale(0, 1),
                LayoutOrder = i,
                Parent = chips,
            }, { corner(S.radius), pad(12, 12), list("x", 6) })
            Create.text(
                { text = t("avu.kind_" .. kind), size = 12.5, font = F.medium, auto = true },
                { LayoutOrder = 1, Parent = c }
            )
            pageJan:Connect(c.Activated, function()
                catalogKind = kind
                renderPage()
            end)
        end

        local cols = 3
        local cellW = math.floor((CONTENT_W - (cols - 1) * 8) / cols)
        local thumbH = if touch then 76 else 100
        local grid = flow(page, 3, 8)
        grid.Name = "Results"
        local s = state()
        local function cell(
            i: number,
            name: string,
            meta: string,
            image: string?,
            selected: boolean,
            onTap: () -> (),
            onSecondaryTap: (() -> ())?
        )
            local b = new("TextButton", {
                Name = "Cell/" .. name,
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(cellW, thumbH + 42),
                LayoutOrder = i,
                Parent = grid,
            }, { list("y", 4) })
            local thumb = new("Frame", {
                Name = "Thumb",
                BackgroundColor3 = C.raised,
                Size = UDim2.new(1, 0, 0, thumbH),
                LayoutOrder = 1,
                ClipsDescendants = true,
                Parent = b,
            }, { corner(S.radius) })
            if selected then
                Create.stroke(0, C.accent).Parent = thumb
            end
            if image then
                new("ImageLabel", {
                    BackgroundTransparency = 1,
                    Size = UDim2.fromScale(1, 1),
                    Image = image,
                    ScaleType = Enum.ScaleType.Fit,
                    Parent = thumb,
                })
            else
                figure(thumb, 40, 58)
            end
            Create.text(
                { text = Create.marked(name, nil), size = 12.5, font = F.medium },
                { Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 2, Parent = b }
            )
            Create.text(
                { text = meta, size = 10, font = F.mono, color = C.text3 },
                { Size = UDim2.new(1, 0, 0, 13), LayoutOrder = 3, Parent = b }
            )
            local suppressed = onSecondary(pageJan, b, function()
                if onSecondaryTap then
                    onSecondaryTap()
                end
            end)
            pageJan:Connect(b.Activated, function()
                if not suppressed() then
                    onTap()
                end
            end)
        end

        if catalogKind == "mine" then
            local outfits = api.Outfits()
            for i, name in outfits do
                cell(
                    i,
                    name,
                    t("avu.meta_saved"),
                    nil,
                    s.owner == "outfit" and s.label == name,
                    function()
                        deps.run("outfit " .. quote(name))
                    end
                )
            end
            if #outfits == 0 then
                note(4, t("av.outfits_none"))
            end
        else
            for i, it in results do
                cell(
                    i,
                    it.name,
                    t("avu.body"),
                    string.format("rbxthumb://type=BundleThumbnail&id=%d&w=150&h=150", it.id),
                    s.owner == "bundle" and s.label == it.name,
                    function()
                        deps.run("bundle " .. it.id)
                    end,
                    function()
                        -- Wear it and keep it as an outfit in one go.
                        task.spawn(function()
                            deps.run("bundle " .. it.id)
                            task.wait(1.5)
                            deps.run("saveoutfit " .. it.name)
                        end)
                    end
                )
            end
            if searching then
                note(4, t("avu.searching"))
            elseif #results == 0 then
                note(4, t("ui.nothing"))
            elseif pager and not (pager :: Page).finished() then
                local more = Controls.button(page, t("avu.load_more"), "plain")
                more.LayoutOrder = 5
                pageJan:Connect(more.Activated, function()
                    local p = pager :: Page
                    searching = true
                    renderPage()
                    task.spawn(function()
                        local got = p.next()
                        for _, it in got do
                            table.insert(results, it)
                        end
                        searching = false
                        if isOpen and tab == "catalog" then
                            renderPage()
                        end
                    end)
                end)
            end
        end

        local function run()
            searchToken += 1
            local my = searchToken
            searching = true
            results = {}
            pager = nil
            renderPage()
            task.spawn(function()
                local got = api.Search(query, SORTS[sort])
                if my ~= searchToken then
                    return
                end
                searching = false
                pager = got
                results = if got then table.clone(got.items) else {}
                if isOpen and tab == "catalog" then
                    renderPage()
                end
            end)
        end
        pageJan:Connect(box.FocusLost, function(enter: boolean)
            if enter then
                query = box.Text
                catalogKind = "bodies"
                run()
            end
        end)
        pageJan:Connect(sortBtn.Activated, function()
            sort = sort % #SORTS + 1
            run()
        end)
        if
            catalogKind == "bodies"
            and not searching
            and not pager
            and #results == 0
            and searchToken == 0
        then
            task.defer(run)
        end
    end

    local function emotesPage()
        local wheel = api.Wheel()
        local head = eyebrowRow(1, t("avu.wheel", #wheel))
        local f, box =
            field(head, t("avu.emote_id"), UDim2.fromOffset(if touch then 130 else 160, 30), 3)
        f.Name = "EmoteId"
        local add = Controls.iconButton(head, "plus", 30, true)
        add.LayoutOrder = 4
        local function addIt()
            local id = string.match(box.Text, "(%d+)")
            if id then
                deps.run("addemote " .. id)
                box.Text = ""
            end
        end
        pageJan:Connect(add.Activated, addIt)
        pageJan:Connect(box.FocusLost, function(enter: boolean)
            if enter then
                addIt()
            end
        end)

        local cols = 4
        local tileW = math.floor((CONTENT_W - (cols - 1) * 6) / cols)
        local grid = flow(page, 2, 6)
        grid.Name = "Emotes"
        for i, e in wheel do
            local b = new("TextButton", {
                Name = "Emote/" .. e.id,
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = C.track,
                Size = UDim2.fromOffset(tileW, if touch then 70 else 80),
                LayoutOrder = i,
                Parent = grid,
            }, { corner(S.radius), pad(10, 10, 8, 8), list("y", 4) })
            local top = new("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                LayoutOrder = 1,
                Parent = b,
            }, { list("x", 4) })
            Create.text(
                { text = tostring(i), size = 10, font = F.mono, color = C.text3, auto = true },
                { LayoutOrder = 1, Parent = top }
            )
            flex(top, 2)
            if e.fromOutfit then
                Create.text(
                    { text = t("avu.tag_outfit"), size = 10, color = C.text3, auto = true },
                    { LayoutOrder = 3, Parent = top }
                )
            end
            new("ImageLabel", {
                Name = "Icon",
                BackgroundTransparency = 1,
                Size = UDim2.fromOffset(if touch then 22 else 26, if touch then 22 else 26),
                Image = string.format("rbxthumb://type=Asset&id=%d&w=150&h=150", e.id),
                LayoutOrder = 2,
                Parent = b,
            })
            Create.text(
                { text = Create.marked(e.name, nil), size = 12.5, font = F.medium },
                { Size = UDim2.new(1, 0, 0, 16), LayoutOrder = 3, Parent = b }
            )
            local suppressed = onSecondary(pageJan, b, function()
                if not e.fromOutfit then
                    deps.run("delemote " .. e.id)
                end
            end)
            pageJan:Connect(b.Activated, function()
                if not suppressed() then
                    deps.run("emote " .. e.id)
                end
            end)
        end
        if #wheel == 0 then
            note(3, t("avu.wheel_empty"))
        end

        local function option(
            order: number,
            title: string,
            sub: string,
            key: string?,
            on: boolean,
            toggle: () -> ()
        )
            local o = new("TextButton", {
                Name = "Option",
                Text = "",
                AutoButtonColor = false,
                BackgroundColor3 = C.track,
                Size = UDim2.new(1, 0, 0, if touch then 44 else 50),
                LayoutOrder = order,
                Parent = page,
            }, { corner(S.radius), pad(12, 12) })
            local col = new(
                "Frame",
                { BackgroundTransparency = 1, Size = UDim2.new(1, -44, 1, 0), Parent = o },
                { list("y", 2, Enum.VerticalAlignment.Center) }
            )
            Create.text(
                { text = title, size = 13, font = F.medium },
                { Size = UDim2.new(1, 0, 0, 17), Parent = col }
            )
            if not touch then
                local subRow = new("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 16),
                    LayoutOrder = 2,
                    Parent = col,
                }, { list("x", 6) })
                Create.text(
                    { text = sub, size = 11, color = C.text3, auto = true },
                    { LayoutOrder = 1, Parent = subRow }
                )
                if key then
                    Controls.kbd(subRow, key).LayoutOrder = 2
                end
            end
            local sw = Controls.switch(o)
            sw.frame.AnchorPoint = Vector2.new(1, 0.5)
            sw.frame.Position = UDim2.fromScale(1, 0.5)
            sw.set(on)
            pageJan:Connect(o.Activated, toggle)
        end
        option(
            4,
            t("avu.outfit_first"),
            t("avu.outfit_first_sub"),
            nil,
            api.OutfitEmotes(),
            function()
                api.SetOutfitEmotes(not api.OutfitEmotes())
            end
        )
        option(5, t("avu.own_wheel"), t("avu.own_wheel_sub"), ".", store.data.emoteWheel, function()
            store.data.emoteWheel = not store.data.emoteWheel
            store:Save("emoteWheel")
            renderPage()
        end)
    end

    renderPage = function()
        clearPage()
        for id, b in tabButtons do
            local on = id == tab
            b.BackgroundTransparency = if on then 0 else 1
            b.TextColor3 = if on then C.text1 else C.text2
        end
        if tab == "catalog" then
            catalogPage()
        elseif tab == "emotes" then
            emotesPage()
        else
            lookPage()
        end
        renderStatus()
    end

    for id, b in tabButtons do
        jan:Connect(b.Activated, function()
            tab = id
            page.CanvasPosition = Vector2.zero
            renderPage()
        end)
    end

    jan:Connect(searchBox.FocusLost, function(enter: boolean)
        local text = string.match(searchBox.Text, "^%s*(.-)%s*$") or ""
        if enter and text ~= "" then
            deps.run("wear " .. string.gsub(text, "%s+", ""))
            searchBox.Text = ""
        end
    end)
    jan:Connect(close.Activated, function()
        isOpen = false
        frame.Visible = false
    end)

    -- Redraw once after a burst of changes (a look swap fires several).
    local queued = false
    local function soon(withPreview: boolean)
        if not isOpen or queued then
            return
        end
        queued = true
        task.defer(function()
            queued = false
            if isOpen and frame.Parent then
                renderPage()
                if withPreview then
                    renderPreview()
                end
            end
        end)
    end
    jan:Add(api.Changed:Connect(function()
        soon(true)
    end))
    jan:Add(reg.StateChanged:Connect(function(name: string)
        if name == "avatarrules" then
            soon(false)
        end
    end))
    jan:Connect(Players.PlayerAdded, function()
        if tab == "look" then
            soon(false)
        end
    end)
    jan:Connect(Players.PlayerRemoving, function()
        if tab == "look" then
            soon(false)
        end
    end)

    Drag.attach(header, frame, jan, function(x: number, y: number)
        if not touch then
            store.data.panels.avatar = { x = x, y = y }
            store:Save()
        end
    end)

    return {
        frame = frame,
        open = function(which: string?)
            if which and table.find(TABS, which) then
                tab = which
            end
            isOpen = true
            frame.Visible = true
            renderPage()
            renderPreview()
            task.defer(function()
                local vp = Drag.viewport()
                local saved = store.data.panels.avatar
                if touch then
                    Drag.place(frame, (vp.X - W) / 2, 0)
                elseif saved then
                    Drag.place(frame, saved.x, saved.y)
                else
                    Drag.place(frame, (vp.X - W) / 2, 96)
                end
            end)
        end,
        close = function()
            isOpen = false
            frame.Visible = false
        end,
        isOpen = function()
            return isOpen
        end,
    }
end

return AvatarPanel
