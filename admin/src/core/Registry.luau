--!strict
-- Commands: lookup by name and alias, parsing, on/off state, and error isolation. Specs are known
-- from the start; a module's Impl is loaded the first time one of its commands runs or one
-- of its lists (waypoints, outfits) is needed.

local Players = game:GetService("Players")

local Args = require("./Args")
local CtxTypes = require("../Ctx")
local Env = require("../platform/Env")
local Fuzzy = require("./Fuzzy")
local Janitor = require("./Janitor")
local Signal = require("./Signal")
local Types = require("../Types")

type Spec = Types.CommandSpec
type Ctx = CtxTypes.Ctx
type Module = CtxTypes.Module

type State = {
    active: boolean,
    jan: Janitor.Janitor?,
    args: { any },
}

export type Registry = {
    specs: { Spec },
    StateChanged: Signal.Signal<string, boolean>,
    Ran: Signal.Signal<string, boolean>,
    SetCtx: (self: Registry, ctx: Ctx) -> (),
    Resolve: (self: Registry, word: string) -> (Spec?, boolean?),
    Get: (self: Registry, name: string) -> Spec?,
    Run: (self: Registry, line: string, source: string?) -> (boolean, string?),
    IsActive: (self: Registry, name: string) -> boolean,
    IsDisabled: (self: Registry, name: string) -> boolean,
    SetDisabled: (self: Registry, name: string, disabled: boolean) -> (),
    Missing: (self: Registry, spec: Spec) -> string?,
    Value: (self: Registry, name: string) -> any,
    Args: (self: Registry, name: string) -> { any },
    List: (self: Registry, kind: string) -> { string },
    SetList: (self: Registry, kind: string, provider: () -> { string }) -> (),
    Disable: (self: Registry, name: string) -> (),
    -- A module's public functions; loads the module when needed.
    Api: (self: Registry, module: string) -> { [string]: any }?,
    ActiveCount: (self: Registry) -> number,
    Destroy: (self: Registry) -> (),
}

local Registry = {}
Registry.__index = Registry

-- ctx.fail marks expected failures with this prefix: shown as-is, not logged as errors.
local USER_ERROR = "\1"

local function trace(err: any): string
    local s = tostring(err)
    if string.sub(s, 1, 1) == USER_ERROR then
        return s
    end
    return debug.traceback(s, 2)
end

function Registry.fail(text: string): never
    error(USER_ERROR .. text, 0)
end

function Registry.new(
    specs: { Spec },
    loaders: { [string]: () -> Module },
    disabled: { string }
): Registry
    local byName: { [string]: Spec } = {}
    for _, s in specs do
        assert(byName[s.name] == nil, "duplicate command " .. s.name)
        byName[s.name] = s
        for _, a in s.aliases or {} do
            assert(byName[a] == nil, "duplicate alias " .. a)
            byName[a] = s
        end
    end
    local self = {
        specs = specs,
        StateChanged = Signal.new(),
        Ran = Signal.new(),
        _byName = byName,
        _loaders = loaders,
        _impls = {} :: { [string]: Module },
        _modJan = Janitor.new(),
        _state = {} :: { [string]: State },
        _disabled = disabled,
        _lists = {} :: { [string]: () -> { string } },
        _ctx = nil :: Ctx?,
        _respawnConn = nil :: RBXScriptConnection?,
    }
    setmetatable(self, Registry)
    self._respawnConn = Players.LocalPlayer.CharacterAdded:Connect(function(char: Model)
        (self :: any):_onRespawn(char)
    end)
    return (self :: any) :: Registry
end

function Registry.SetCtx(self: any, ctx: Ctx)
    self._ctx = ctx
end

function Registry.Get(self: any, name: string): Spec?
    return self._byName[string.lower(name)]
end

-- "unfly" resolves to fly with a forced off state.
function Registry.Resolve(self: any, word: string): (Spec?, boolean?)
    local w = string.lower(word)
    local s = self._byName[w]
    if s then
        return s, nil
    end
    if string.sub(w, 1, 2) == "un" then
        local base = self._byName[string.sub(w, 3)]
        if base and base.kind ~= "action" then
            return base, false
        end
    end
    return nil, nil
end

function Registry.IsActive(self: any, name: string): boolean
    local st = self._state[name]
    return st ~= nil and st.active
end

function Registry.ActiveCount(self: any): number
    local n = 0
    for _, st in self._state do
        if st.active then
            n += 1
        end
    end
    return n
end

function Registry.IsDisabled(self: any, name: string): boolean
    return table.find(self._disabled, name) ~= nil
end

function Registry.SetDisabled(self: any, name: string, disabled: boolean)
    local i = table.find(self._disabled, name)
    if disabled and not i then
        table.insert(self._disabled, name)
        self:Disable(name)
    elseif not disabled and i then
        table.remove(self._disabled, i)
    end
    self.StateChanged:Fire(name, self:IsActive(name))
end

-- Name of the first executor function the command needs but this executor lacks.
function Registry.Missing(_self: any, spec: Spec): string?
    for _, need in spec.needs or {} do
        if not Env.has(need) then
            return need
        end
    end
    return nil
end

function Registry.Args(self: any, name: string): { any }
    local st = self._state[name]
    return if st then st.args else {}
end

function Registry.Value(self: any, name: string): any
    local st = self._state[name]
    if st and st.active and st.args[1] ~= nil then
        return st.args[1]
    end
    local spec: Spec? = self._byName[name]
    local impl: Module? = spec and self._impls[spec.module]
    local h: CtxTypes.Handler? = impl and impl.handlers[name]
    local current = h and h.current
    local ctx: Ctx? = self._ctx
    if current and ctx then
        local ok, v = pcall(current, ctx)
        if ok and v ~= nil then
            return v
        end
    end
    return spec and spec.default
end

function Registry.SetList(self: any, kind: string, provider: () -> { string })
    self._lists[kind] = provider
end

function Registry.List(self: any, kind: string): { string }
    if kind == "command" then
        local out = {}
        for _, s in self.specs do
            table.insert(out, s.name)
        end
        return out
    end
    local p = self._lists[kind]
    if not p then
        -- The module whose commands take this kind of argument provides the list.
        for _, s in self.specs :: { Spec } do
            for _, a in s.args or {} do
                if a.kind == kind and not self._impls[s.module] then
                    pcall(self._impl, self, s)
                    p = self._lists[kind]
                    break
                end
            end
            if p then
                break
            end
        end
        if not p then
            return {}
        end
    end
    local ok, list = pcall(p)
    return if ok and type(list) == "table" then list else {}
end

function Registry._impl(self: any, spec: Spec): Module
    local impl = self._impls[spec.module]
    if impl then
        return impl
    end
    local loader: (() -> Module)? = self._loaders[spec.module]
    assert(loader, "no module " .. spec.module)
    local m = (loader :: () -> Module)()
    self._impls[spec.module] = m
    local ctx: Ctx = self._ctx
    for kind, provider in m.lists or {} do
        self._lists[kind] = function()
            return provider(ctx)
        end
    end
    if m.init then
        m.init(ctx, self._modJan)
    end
    return m
end

function Registry.Api(self: any, module: string): { [string]: any }?
    for _, s in self.specs :: { Spec } do
        if s.module == module then
            local ok, m = pcall(self._impl, self, s)
            return if ok then (m :: Module).api else nil
        end
    end
    return nil
end

function Registry._setActive(self: any, name: string, st: State, active: boolean)
    local was = st.active
    st.active = active
    if was ~= active then
        self.StateChanged:Fire(name, active)
    end
end

function Registry.Disable(self: any, name: string)
    local st: State? = self._state[name]
    if not st or not st.active then
        return
    end
    local jan = st.jan
    st.jan = nil
    if jan then
        jan:Cleanup()
    end
    self:_setActive(name, st, false)
end

function Registry._enable(self: any, spec: Spec, args: { any })
    local name = spec.name
    local st: State = self._state[name] or { active = false, args = {} }
    self._state[name] = st
    local was = st.active
    if st.jan then
        st.jan:Cleanup()
    end
    local ctx: Ctx = self._ctx
    local h: CtxTypes.Handler? = self:_impl(spec).handlers[name]
    local enable = h and h.enable
    assert(enable, "no enable for " .. name)
    local jan = Janitor.new(function(msg: string)
        ctx.log:Error(name .. ": " .. msg)
    end)
    st.jan = jan
    st.args = args
    local ok, err = xpcall(function(): string?
        enable(ctx, args, jan)
        return nil
    end, trace)
    if not ok then
        st.jan = nil
        jan:Cleanup()
        self:_setActive(name, st, false)
        error(err, 0)
    end
    self:_setActive(name, st, true)
    if was then
        -- Still active with new arguments; the UI refreshes its value chip.
        self.StateChanged:Fire(name, true)
    end
end

function Registry._onRespawn(self: any, char: Model)
    local ctx: Ctx? = self._ctx
    if not ctx then
        return
    end
    local list: { Spec } = {}
    for name, st in self._state :: { [string]: State } do
        local spec: Spec = self._byName[name]
        if st.active and spec.respawn then
            if st.jan then
                st.jan:Cleanup()
                st.jan = nil
            end
            table.insert(list, spec)
        end
    end
    if #list == 0 then
        return
    end
    task.spawn(function()
        char:WaitForChild("Humanoid", 10)
        char:WaitForChild("HumanoidRootPart", 10)
        for _, spec in list do
            local st = self._state[spec.name]
            if st and st.active and char.Parent then
                local ok, err = pcall(self._enable, self, spec, st.args)
                if not ok then
                    ctx.log:Error(spec.name .. " (respawn): " .. tostring(err))
                end
            end
        end
    end)
end

-- Nearest name by edit distance (typos), then by fuzzy subsequence (abbreviations).
local function suggestName(self: any, word: string): string?
    local best, bestDist = nil, math.max(1, math.floor(#word / 3))
    for _, s in self.specs :: { Spec } do
        local d = Fuzzy.distance(word, s.name)
        if d <= bestDist then
            best, bestDist = s.name, d
        end
    end
    if best then
        return best
    end
    local bestScore = 0
    for _, s in self.specs :: { Spec } do
        local sc = Fuzzy.score(word, s.name)
        if sc and sc > bestScore then
            best, bestScore = s.name, sc
        end
    end
    return best
end

-- Parses and executes one command line. Never throws.
function Registry.Run(self: any, line: string, source: string?): (boolean, string?)
    local ctx: Ctx = self._ctx
    local t = ctx.t
    local tokens = Args.tokenize(line)
    if #tokens == 0 then
        return false, nil
    end
    local word = table.remove(tokens, 1) :: string
    local spec, forced = self:Resolve(word)
    if not spec then
        local near = suggestName(self, word)
        return false, if near then t("err.unknown_near", word, near) else t("err.unknown", word)
    end
    local name = spec.name
    if self:IsDisabled(name) then
        return false, t("err.disabled", name)
    end
    local missing = self:Missing(spec)
    if missing then
        return false, t("err.needs", name, missing)
    end

    if spec.kind ~= "action" and forced == nil and tokens[1] then
        local b = Args.parseBool(tokens[1])
        if b ~= nil and (spec.kind == "toggle" or b == false) then
            forced = b
            table.remove(tokens, 1)
        end
    end
    -- A value command with nothing after it means "back to the original".
    if spec.kind == "value" and forced == nil and #tokens == 0 then
        forced = false
    end

    local argCtx: Args.Ctx = {
        t = t,
        list = function(kind: string)
            return self:List(kind)
        end,
    }
    local values: { any } = {}
    local given = 0
    for i, a in spec.args or {} do
        local token: string? = tokens[i]
        if a.kind == "rest" and token then
            token = table.concat(tokens, " ", i)
        end
        if token == nil or token == "" then
            if not a.optional and forced ~= false then
                return false, t("err.arg", name, t("arg.missing", a.name))
            end
        else
            local v, err = Args.parse(a, token, argCtx)
            if err then
                return false, t("err.arg", name, err)
            end
            values[i] = v
            given += 1
        end
    end

    if source == "palette" then
        local h = ctx.store.data.history
        if h[#h] ~= line then
            table.insert(h, line)
            if #h > 50 then
                table.remove(h, 1)
            end
            ctx.store:Save()
        end
    end

    local ok, err = xpcall(function(): string?
        if spec.kind == "action" then
            local h: CtxTypes.Handler? = self:_impl(spec).handlers[name]
            local run = h and h.run
            assert(run, "no run for " .. name)
            run(ctx, values)
            return nil
        end
        local active = self:IsActive(name)
        local target: boolean
        if forced ~= nil then
            target = forced
        elseif spec.kind == "value" then
            target = given > 0
        else
            target = not active or given > 0
        end
        if target then
            self:_enable(spec, values)
            local shown = values[1]
            if spec.kind == "value" and shown ~= nil then
                ctx.toast("ok", t("toast.value", t("c." .. name), tostring(shown)))
            else
                ctx.toast("ok", t("toast.on", t("c." .. name)))
            end
        elseif active then
            self:Disable(name)
            ctx.toast(
                "info",
                t(if spec.kind == "value" then "toast.reset" else "toast.off", t("c." .. name))
            )
        end
        return nil
    end, trace)

    self.Ran:Fire(name, ok)
    if not ok then
        local msg = tostring(err)
        if string.sub(msg, 1, 1) == USER_ERROR then
            return false, string.sub(msg, 2)
        end
        ctx.log:Error(name .. ": " .. msg)
        local short = string.match(msg, "^[^\n]*") or msg
        short = string.gsub(short, "^.-:%d+: ", "")
        return false, t("err.failed", name, short)
    end
    return true, nil
end

function Registry.Destroy(self: any)
    if self._respawnConn then
        self._respawnConn:Disconnect()
    end
    for name in self._state do
        self:Disable(name)
    end
    self._modJan:Cleanup()
    self.StateChanged:DisconnectAll()
    self.Ran:DisconnectAll()
end

return Registry
