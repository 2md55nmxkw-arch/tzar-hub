--!strict
-- Avatar module (the former Avatar Changer). wear / outfit / bundle each put a look on your own
-- character; only one of them is on at a time and turning it off gives your own look back.
-- Outfits and the emote list live in TZAR/admin/avatar.json.

local AssetService = game:GetService("AssetService")
local AvatarEditorService = game:GetService("AvatarEditorService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local CtxTypes = require("../../Ctx")
local Data = require("./Data")
local Emotes = require("./Emotes")
local Env = require("../../platform/Env")
local Janitor = require("../../core/Janitor")
local Look = require("./Look")
local Rules = require("./Rules")
local Signal = require("../../core/Signal")

type Ctx = CtxTypes.Ctx

-- What the avatar panel reads (TZAR_ADMIN.Module("avatar") / registry:Api("avatar")).
export type State = {
    -- "wear" | "outfit" | "bundle", or nil while you wear your own look.
    owner: string?,
    label: string?,
    -- "server" | "profile" | "outfit" | "bundle"
    source: string?,
}
export type CatalogItem = { id: number, name: string }
export type CatalogPage = {
    items: { CatalogItem },
    finished: () -> boolean,
    -- The next page's items (yields); empty once finished.
    next: () -> { CatalogItem },
}

local SORTS: { [string]: string } =
    { best = "Bestselling", fav = "MostFavorited", new = "RecentlyCreated" }

-- Commands that put a look on; switching between them never shows your own look in between.
local LOOKS = { "wear", "outfit", "bundle" }
local ADMIN_URL = "https://hub.2md.space/tzar-admin.lua"
local EXPORT_DIR = "TZAR/exports/"
local DESC_CACHE = 8

type Cached = { key: string, desc: HumanoidDescription, label: string }

return function(): CtxTypes.Module
    local lp = Players.LocalPlayer
    local ctxRef: Ctx? = nil
    local data: Data.Data? = nil
    local look = Look.new(function(msg: string)
        local c = ctxRef
        if c then
            c.log:Error(msg)
        end
    end)
    -- The last looks fetched, so a respawn or a repeat needs no web request.
    local recent: { Cached } = {}
    local changed: Signal.Signal<> = Signal.new()
    local source: string? = nil
    -- After the look swap (and its deferred restore) has happened.
    local function notify()
        task.defer(function()
            if not look.owner() then
                source = nil
            end
            changed:Fire()
        end)
    end

    local function store(): Data.Data
        local d = data
        if d then
            return d
        end
        local loaded, imported = Data.load()
        data = loaded
        local c = ctxRef
        if imported > 0 and c then
            c.log:Info(string.format("avatar: imported %d items from Avatar Changer", imported))
        end
        return loaded
    end

    local function remember(key: string, desc: HumanoidDescription, label: string)
        for i, r in recent do
            if r.key == key then
                table.remove(recent, i)
                break
            end
        end
        table.insert(recent, 1, { key = key, desc = desc, label = label })
        while #recent > DESC_CACHE do
            table.remove(recent)
        end
    end

    local function cached(key: string): Cached?
        for _, r in recent do
            if r.key == key then
                return r
            end
        end
        return nil
    end

    -- Takes over the look for `name` and turns the other look commands off without a flash.
    local function wearLook(
        ctx: Ctx,
        name: string,
        desc: HumanoidDescription,
        label: string,
        jan: Janitor.Janitor,
        from: string
    )
        look.claim(name)
        for _, other in LOOKS do
            if other ~= name and ctx.isActive(other) then
                ctx.disable(other)
            end
        end
        local char = ctx.character()
        if not char or not ctx.humanoid() then
            ctx.fail(ctx.t("av.no_character"))
        end
        local notes = look.apply(name, desc, label)
        if #notes > 0 then
            ctx.log:Info("avatar rules: " .. table.concat(notes, ", "))
        end
        source = from
        notify()
        jan:Defer(function()
            look.release(name)
            notify()
        end)
    end

    local function resolveUser(ctx: Ctx, text: string): (number, string)
        local s = string.gsub(string.gsub(text, "^%s+", ""), "%s+$", "")
        s = string.gsub(s, "^@", "")
        local id = tonumber(s)
        if id then
            -- The status line and outfit names read better as a name than as digits.
            local okN, name = pcall(Players.GetNameFromUserIdAsync, Players, id)
            return id, if okN and type(name) == "string" then name else s
        end
        local ok, found = pcall(Players.GetUserIdFromNameAsync, Players, s)
        if ok and type(found) == "number" then
            return found, s
        end
        ctx.fail(ctx.t("av.not_found", s))
        return 0, s
    end

    -- Their look as it is in this server, read from their description (their character is left alone).
    local function serverLook(ctx: Ctx, plr: Player): HumanoidDescription
        local hum = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid")
        if not hum then
            ctx.fail(ctx.t("av.no_character_of", plr.Name))
        end
        local ok, desc = pcall(function(): HumanoidDescription
            return (hum :: Humanoid):GetAppliedDescription()
        end)
        if ok then
            return desc
        end
        local child = (hum :: Humanoid):FindFirstChildOfClass("HumanoidDescription")
        if not child then
            ctx.fail(ctx.t("av.no_character_of", plr.Name))
        end
        return child :: HumanoidDescription
    end

    -- What saveoutfit / exportoutfit take when no outfit is named: the worn look, else your own.
    local function currentDesc(ctx: Ctx): (HumanoidDescription, string)
        local desc, label = look.current()
        if desc and label then
            return desc, label
        end
        local hum = ctx.humanoid()
        if not hum then
            ctx.fail(ctx.t("av.no_character"))
        end
        local ok, mine = pcall(function(): HumanoidDescription
            return (hum :: Humanoid):GetAppliedDescription()
        end)
        if not ok then
            ctx.fail(ctx.t("av.no_character"))
        end
        return mine, lp.Name
    end

    local function wheel(): { Emotes.WheelEmote }
        local d = store()
        local desc = look.current()
        return Emotes.wheel(desc, d.emotes, d.outfitEmotes)
    end

    local function exportScript(name: string, outfitData: any): string
        local payload = table.clone(outfitData)
        payload.label = name
        return table.concat({
            '-- TZAR outfit "' .. name .. '" (' .. os.date("%d.%m.%Y %H:%M") .. ")",
            "-- Put this file in your executor's autoexec folder to wear the outfit on every join.",
            "local OUTFIT = [==[" .. HttpService:JSONEncode(payload) .. "]==]",
            "if not game:IsLoaded() then game.Loaded:Wait() end",
            'local Players = game:GetService("Players")',
            "while not Players.LocalPlayer do task.wait() end",
            "if not getgenv().TZAR_ADMIN then",
            '\tlocal src = isfile("tzar-admin.lua") and readfile("tzar-admin.lua")',
            '\t\tor game:HttpGet("' .. ADMIN_URL .. '")',
            "\tloadstring(src)()",
            "end",
            'getgenv().TZAR_ADMIN.Module("avatar").ApplyOutfit(OUTFIT)',
            "",
        }, "\n")
    end

    local handlers: { [string]: CtxTypes.Handler } = {
        wear = {
            enable = function(ctx: Ctx, args: { any }, jan: Janitor.Janitor)
                local who: any = args[1]
                local plr: Player? = if typeof(who) == "Instance"
                        and (who :: Instance):IsA("Player")
                    then who :: Player
                    else nil
                local key: string
                local desc: HumanoidDescription
                local label: string
                if plr then
                    key = "player:" .. plr.UserId
                    local hit = cached(key)
                    if hit and not (plr.Parent and plr.Character) then
                        desc, label = hit.desc, hit.label
                    else
                        desc, label = serverLook(ctx, plr), plr.Name
                    end
                else
                    local id, name = resolveUser(ctx, tostring(who))
                    key = "user:" .. id
                    local hit = cached(key)
                    if hit then
                        desc, label = hit.desc, hit.label
                    else
                        local ok, got = Rules.call(Players, "GetHumanoidDescriptionFromUserId", id)
                        if not ok or typeof(got) ~= "Instance" then
                            ctx.fail(ctx.t("av.avatar_failed", name))
                        end
                        desc, label = got :: HumanoidDescription, name
                    end
                end
                remember(key, desc, label)
                wearLook(ctx, "wear", desc, label, jan, if plr then "server" else "profile")
            end,
        },
        outfit = {
            enable = function(ctx: Ctx, args: { any }, jan: Janitor.Janitor)
                local o = Data.find(store(), tostring(args[1]))
                if not o then
                    ctx.fail(ctx.t("arg.outfit", tostring(args[1])))
                end
                local outfit = o :: Data.Outfit
                local key = "outfit:" .. outfit.id
                local hit = cached(key)
                local desc = if hit then hit.desc else Data.deserialize(outfit.data)
                remember(key, desc, outfit.name)
                wearLook(ctx, "outfit", desc, outfit.name, jan, "outfit")
            end,
        },
        bundle = {
            enable = function(ctx: Ctx, args: { any }, jan: Janitor.Janitor)
                local id = tonumber(string.match(tostring(args[1]), "%d+") or "")
                if not id then
                    ctx.fail(ctx.t("av.bundle_bad", tostring(args[1])))
                end
                local bundleId = id :: number
                local key = "bundle:" .. bundleId
                local hit = cached(key)
                local desc: HumanoidDescription
                local label: string
                if hit then
                    desc, label = hit.desc, hit.label
                else
                    local ok, details =
                        pcall(AssetService.GetBundleDetailsAsync, AssetService, bundleId)
                    if not ok or type(details) ~= "table" then
                        ctx.fail(ctx.t("av.bundle_bad", tostring(bundleId)))
                    end
                    local outfitId: number? = nil
                    for _, it in (details :: any).Items do
                        if
                            it.Type == "UserOutfit"
                            and (it.Name == (details :: any).Name or not outfitId)
                        then
                            outfitId = it.Id
                        end
                    end
                    if not outfitId then
                        ctx.fail(ctx.t("av.bundle_bad", tostring(bundleId)))
                    end
                    local okD, got = Rules.call(
                        Players,
                        "GetHumanoidDescriptionFromOutfitId",
                        outfitId :: number
                    )
                    if not okD or typeof(got) ~= "Instance" then
                        ctx.fail(ctx.t("av.avatar_failed", tostring((details :: any).Name)))
                    end
                    desc, label = got :: HumanoidDescription, tostring((details :: any).Name)
                end
                remember(key, desc, label)
                wearLook(ctx, "bundle", desc, label, jan, "bundle")
            end,
        },
        saveoutfit = {
            run = function(ctx: Ctx, args: { any })
                local desc, label = currentDesc(ctx)
                local d = store()
                local given = args[1] and string.match(tostring(args[1]), "^%s*(.-)%s*$")
                local name = Data.unique(d, if given and given ~= "" then given else label)
                table.insert(d.outfits, {
                    id = HttpService:GenerateGUID(false),
                    name = name,
                    data = Data.serialize(desc),
                })
                Data.save(d)
                notify()
                ctx.toast("ok", ctx.t("av.outfit_saved", name))
            end,
        },
        renameoutfit = {
            run = function(ctx: Ctx, args: { any })
                local d = store()
                local o = Data.find(d, tostring(args[1]))
                if not o then
                    ctx.fail(ctx.t("arg.outfit", tostring(args[1])))
                end
                local outfit = o :: Data.Outfit
                local new = string.match(tostring(args[2]), "^%s*(.-)%s*$") or ""
                if new == "" then
                    ctx.fail(ctx.t("arg.missing", "name"))
                end
                local old = outfit.name
                outfit.name = if string.lower(new) == string.lower(old)
                    then new
                    else Data.unique(d, new)
                Data.save(d)
                notify()
                ctx.toast("ok", ctx.t("av.outfit_renamed", old, outfit.name))
            end,
        },
        deloutfit = {
            run = function(ctx: Ctx, args: { any })
                local d = store()
                local o = Data.find(d, tostring(args[1]))
                if not o then
                    ctx.fail(ctx.t("arg.outfit", tostring(args[1])))
                end
                local outfit = o :: Data.Outfit
                if ctx.isActive("outfit") and look.owner() == "outfit" then
                    local _, label = look.current()
                    if label == outfit.name then
                        ctx.disable("outfit")
                    end
                end
                table.remove(d.outfits, table.find(d.outfits, outfit) :: number)
                Data.save(d)
                notify()
                ctx.toast("ok", ctx.t("av.outfit_deleted", outfit.name))
            end,
        },
        outfits = {
            run = function(ctx: Ctx)
                local names = {}
                for _, o in store().outfits do
                    table.insert(names, o.name)
                end
                if #names == 0 then
                    ctx.toast("info", ctx.t("av.outfits_none"))
                else
                    ctx.toast("info", ctx.t("av.outfits_list", table.concat(names, ", ")))
                end
            end,
        },
        exportoutfit = {
            run = function(ctx: Ctx, args: { any })
                local name: string
                local outfitData: any
                if args[1] then
                    local o = Data.find(store(), tostring(args[1]))
                    if not o then
                        ctx.fail(ctx.t("arg.outfit", tostring(args[1])))
                    end
                    name, outfitData = (o :: Data.Outfit).name, (o :: Data.Outfit).data
                else
                    local desc, label = currentDesc(ctx)
                    name, outfitData = label, Data.serialize(desc)
                end
                local source = exportScript(name, outfitData)
                local file = EXPORT_DIR .. string.gsub(name, "[^%w_%-]", "_") .. ".lua"
                local saved = Env.writeFile(file, source)
                local copied = Env.clipboard(source)
                if not saved and not copied then
                    ctx.fail(ctx.t("av.export_failed"))
                end
                ctx.toast("ok", ctx.t(if copied then "av.exported" else "av.exported_file", file))
            end,
        },
        avatarrules = {
            enable = function(_ctx: Ctx, _args: { any }, jan: Janitor.Janitor)
                look.setRules(true)
                jan:Defer(function()
                    look.setRules(false)
                end)
            end,
        },
        emote = {
            run = function(ctx: Ctx, args: { any })
                local token = tostring(args[1])
                local id = tonumber(token)
                if not id then
                    for _, e in wheel() do
                        if string.lower(e.name) == string.lower(token) then
                            id = e.id
                            break
                        end
                    end
                end
                if not id then
                    ctx.fail(ctx.t("arg.emote", token))
                end
                local ok, why = Emotes.play(id :: number)
                if not ok then
                    ctx.fail(ctx.t(why or "av.emote_failed", token))
                end
            end,
        },
        addemote = {
            run = function(ctx: Ctx, args: { any })
                local id = tonumber(string.match(tostring(args[1]), "(%d+)") or "")
                if not id then
                    ctx.fail(ctx.t("av.not_emote", tostring(args[1])))
                end
                local d = store()
                for _, e in d.emotes do
                    if e.id == id then
                        ctx.toast("info", ctx.t("av.emote_exists", e.name))
                        return
                    end
                end
                local title, isEmote = Emotes.lookup(id :: number)
                if not title then
                    ctx.fail(ctx.t("av.asset_missing", tostring(id)))
                end
                if not isEmote then
                    ctx.fail(ctx.t("av.not_emote", tostring(title)))
                end
                local given = args[2] and string.match(tostring(args[2]), "^%s*(.-)%s*$")
                local name = if given and given ~= "" then given else tostring(title)
                table.insert(d.emotes, { id = id :: number, name = name })
                Data.save(d)
                notify()
                ctx.toast("ok", ctx.t("av.emote_added", name))
            end,
        },
        delemote = {
            run = function(ctx: Ctx, args: { any })
                local token = tostring(args[1])
                local d = store()
                local id = tonumber(token)
                for i, e in d.emotes do
                    if e.id == id or string.lower(e.name) == string.lower(token) then
                        table.remove(d.emotes, i)
                        Data.save(d)
                        notify()
                        ctx.toast("ok", ctx.t("av.emote_removed", e.name))
                        return
                    end
                end
                ctx.fail(ctx.t("arg.emote", token))
            end,
        },
        emotes = {
            run = function(ctx: Ctx)
                local names = {}
                for _, e in wheel() do
                    table.insert(names, e.name)
                end
                if #names == 0 then
                    ctx.toast("info", ctx.t("av.emotes_none"))
                else
                    ctx.toast("info", ctx.t("av.emotes_list", table.concat(names, ", ")))
                end
            end,
        },
        avatar = {
            run = function(ctx: Ctx)
                ctx.openView("avatar")
            end,
        },
        emotewheel = {
            run = function(ctx: Ctx)
                ctx.openView("emotewheel")
            end,
        },
    }

    local function items(page: any): { CatalogItem }
        local out: { CatalogItem } = {}
        if type(page) ~= "table" then
            return out
        end
        for _, it in page do
            local id = type(it) == "table" and tonumber(it.Id)
            if id and it.Name then
                table.insert(out, { id = id, name = tostring(it.Name) })
            end
        end
        return out
    end

    -- Body bundles from the catalog (what the panel's catalog tab shows).
    local function search(query: string, sort: string?): CatalogPage?
        local params: any = nil
        local okP = pcall(function()
            params = (CatalogSearchParams :: any).new()
            params.BundleTypes = { Enum.BundleType.BodyParts }
            if string.match(query, "%S") then
                params.SearchKeyword = query
            end
        end)
        if not okP then
            return nil
        end
        pcall(function()
            params.SortType = (Enum.CatalogSortType :: any)[SORTS[sort or "best"] or "Bestselling"]
        end)
        local ok, pages = Rules.call(AvatarEditorService, "SearchCatalog", params)
        if not ok or typeof(pages) ~= "Instance" then
            return nil
        end
        local p: any = pages
        local okFirst, first = pcall(function(): any
            return p:GetCurrentPage()
        end)
        return {
            items = if okFirst then items(first) else {},
            finished = function(): boolean
                local okF, done = pcall(function(): any
                    return p.IsFinished
                end)
                return not okF or done == true
            end,
            next = function(): { CatalogItem }
                local okN, page = pcall(function(): any
                    if p.IsFinished then
                        return nil
                    end
                    p:AdvanceToNextPageAsync()
                    return p:GetCurrentPage()
                end)
                return if okN then items(page) else {}
            end,
        }
    end

    -- For exported autoexec scripts (and old Avatar Changer exports through the site's shim).
    local api = {
        ApplyOutfit = function(json: any)
            local c = ctxRef
            if not c then
                return
            end
            local ctx = c :: Ctx
            local t = if type(json) == "string" then Env.json(json) else json
            if type(t) ~= "table" then
                ctx.toast("error", ctx.t("av.export_bad"))
                return
            end
            task.spawn(function()
                local char = lp.Character or lp.CharacterAdded:Wait()
                char:WaitForChild("Humanoid", 10)
                -- Kept as a saved outfit under its label, then worn like any other.
                local d = store()
                local name = tostring(t.label or "Autoexec")
                local o = Data.find(d, name)
                local payload = table.clone(t)
                payload.label = nil
                if o then
                    o.data = payload
                else
                    table.insert(
                        d.outfits,
                        { id = HttpService:GenerateGUID(false), name = name, data = payload }
                    )
                end
                Data.save(d)
                notify()
                for i = #recent, 1, -1 do
                    if string.sub(recent[i].key, 1, 7) == "outfit:" then
                        table.remove(recent, i)
                    end
                end
                local ok, msg = ctx.run('outfit "' .. name .. '"')
                if not ok and msg then
                    ctx.toast("error", msg)
                end
            end)
        end,
        Reset = function()
            local c = ctxRef
            if c then
                for _, name in LOOKS do
                    if c.isActive(name) then
                        c.run("un" .. name)
                    end
                end
            end
        end,
        -- Fires after the worn look, the outfits or the emote list changed.
        Changed = changed,
        State = function(): State
            local _, label = look.current()
            return { owner = look.owner(), label = label, source = source }
        end,
        Outfits = function(): { string }
            local out = {}
            for _, o in store().outfits do
                table.insert(out, o.name)
            end
            return out
        end,
        Wheel = function(): { Emotes.WheelEmote }
            return wheel()
        end,
        OutfitEmotes = function(): boolean
            return store().outfitEmotes
        end,
        SetOutfitEmotes = function(on: boolean)
            local d = store()
            d.outfitEmotes = on
            Data.save(d)
            notify()
        end,
        Preview = function(): Model?
            return look.preview()
        end,
        Search = search,
    }

    return {
        handlers = handlers,
        api = api,
        init = function(ctx: Ctx, jan: Janitor.Janitor)
            ctxRef = ctx
            jan:Defer(function()
                look.destroy()
                changed:DisconnectAll()
            end)
        end,
        lists = {
            outfit = function()
                local out = {}
                for _, o in store().outfits do
                    table.insert(out, o.name)
                end
                return out
            end,
            emote = function()
                local out = {}
                for _, e in wheel() do
                    table.insert(out, e.name)
                end
                return out
            end,
        },
    }
end
