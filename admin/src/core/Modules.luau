--!strict
-- Game modules: feature state, whole-section and whole-module switches, presets (built in and
-- saved by the user) and the module's start/pause/stop routine. A feature either drives a hub
-- command (its state then mirrors the registry) or a handler of the module's Impl with its own
-- Janitor, so turning it off undoes exactly what it did.

local CtxTypes = require("../Ctx")
local Janitor = require("./Janitor")
local Registry = require("./Registry")
local Signal = require("./Signal")
local Store = require("./Store")
local Types = require("../Types")

type Ctx = CtxTypes.Ctx
type Spec = Types.GameModuleSpec
type Feature = Types.Feature

export type RunState = "idle" | "running" | "paused"

export type Run = {
    state: RunState,
    status: string,
    progress: number,
    elapsed: () -> number,
}

export type Preset = { id: string, name: string?, values: { [string]: any }, builtin: boolean }

export type Modules = {
    specs: { Spec },
    -- (module id, feature id or "run" / "presets")
    Changed: Signal.Signal<string, string>,
    SetCtx: (self: Modules, ctx: Ctx) -> (),
    Get: (self: Modules, id: string) -> Spec?,
    Available: (self: Modules) -> { Spec },
    Feature: (self: Modules, mod: string, fid: string) -> Feature?,
    IsOn: (self: Modules, mod: string, fid: string) -> boolean,
    Value: (self: Modules, mod: string, fid: string) -> any,
    Set: (self: Modules, mod: string, fid: string, value: any) -> (boolean, string?),
    SetSection: (self: Modules, mod: string, section: string, on: boolean) -> (),
    AllOff: (self: Modules, mod: string) -> (),
    Count: (self: Modules, mod: string, section: string?) -> (number, number),
    Presets: (self: Modules, mod: string) -> { Preset },
    PresetActive: (self: Modules, mod: string, presetId: string) -> boolean,
    ApplyPreset: (self: Modules, mod: string, presetId: string) -> (),
    TogglePreset: (self: Modules, mod: string, presetId: string) -> (),
    SavePreset: (self: Modules, mod: string, name: string) -> string,
    PresetTitle: (self: Modules, mod: string, p: Preset) -> string,
    PresetKey: (self: Modules, mod: string, p: Preset) -> string,
    PresetKeys: (self: Modules) -> { string },
    FindPreset: (self: Modules, key: string) -> (string?, Preset?),
    DeletePreset: (self: Modules, mod: string, presetId: string) -> (),
    Run: (self: Modules, mod: string) -> Run,
    Start: (self: Modules, mod: string) -> (),
    Pause: (self: Modules, mod: string) -> (),
    Stop: (self: Modules, mod: string) -> (),
    Destroy: (self: Modules) -> (),
}

type FeatureState = { on: boolean, value: any, jan: Janitor.Janitor? }

type RunInternal = {
    state: RunState,
    status: string,
    progress: number,
    thread: thread?,
    jan: Janitor.Janitor?,
    startedAt: number,
    pausedAt: number,
    pausedTotal: number,
}

local Modules = {}
Modules.__index = Modules

local function trace(err: any): string
    return debug.traceback(tostring(err), 2)
end

function Modules.new(
    specs: { Spec },
    loaders: { [string]: () -> CtxTypes.GameImpl },
    registry: Registry.Registry,
    store: Store.Store
): Modules
    local self = {
        specs = specs,
        Changed = Signal.new(),
        _byId = {} :: { [string]: Spec },
        _features = {} :: { [string]: { [string]: Feature } },
        _state = {} :: { [string]: { [string]: FeatureState } },
        _impls = {} :: { [string]: CtxTypes.GameImpl },
        _loaders = loaders,
        _runs = {} :: { [string]: RunInternal },
        _reg = registry,
        _store = store,
        _ctx = nil :: Ctx?,
        _conn = nil :: any,
    }
    for _, s in specs do
        self._byId[s.id] = s
        local byFid: { [string]: Feature } = {}
        for _, f in s.features do
            assert(byFid[f.id] == nil, "duplicate feature " .. s.id .. "." .. f.id)
            byFid[f.id] = f
        end
        self._features[s.id] = byFid
        self._state[s.id] = {}
        self._runs[s.id] = {
            state = "idle",
            status = "",
            progress = 0,
            startedAt = 0,
            pausedAt = 0,
            pausedTotal = 0,
        }
    end
    setmetatable(self, Modules)
    -- Command-driven features follow the registry.
    self._conn = registry.StateChanged:Connect(function(name: string)
        for _, s in specs do
            for _, f in s.features do
                if f.command == name then
                    self.Changed:Fire(s.id, f.id)
                end
            end
        end
    end)
    return (self :: any) :: Modules
end

function Modules.SetCtx(self: any, ctx: Ctx)
    self._ctx = ctx
end

function Modules.Get(self: any, id: string): Spec?
    return self._byId[id]
end

-- Modules for the current place (and the ones that apply everywhere).
function Modules.Available(self: any): { Spec }
    local out = {}
    for _, s in self.specs :: { Spec } do
        if not s.places or table.find(s.places, game.PlaceId) then
            table.insert(out, s)
        end
    end
    return out
end

function Modules.Feature(self: any, mod: string, fid: string): Feature?
    local m = self._features[mod]
    return m and m[fid]
end

function Modules.IsOn(self: any, mod: string, fid: string): boolean
    local f: Feature? = self:Feature(mod, fid)
    if not f then
        return false
    end
    if f.command then
        return self._reg:IsActive(f.command)
    end
    local st: FeatureState? = self._state[mod][fid]
    return st ~= nil and st.on
end

function Modules.Value(self: any, mod: string, fid: string): any
    local f: Feature? = self:Feature(mod, fid)
    if not f then
        return nil
    end
    if f.command then
        if f.kind == "toggle" then
            return self._reg:IsActive(f.command)
        end
        return self._reg:Value(f.command)
    end
    local st: FeatureState? = self._state[mod][fid]
    if st and st.on then
        return st.value
    end
    if f.kind == "toggle" then
        return false
    elseif f.kind == "choice" then
        return f.options and f.options[1]
    end
    return f.default
end

function Modules._impl(self: any, mod: string): CtxTypes.GameImpl
    local cached: CtxTypes.GameImpl? = self._impls[mod]
    if cached then
        return cached
    end
    local loader: (() -> CtxTypes.GameImpl)? = self._loaders[mod]
    if not loader then
        error("no module " .. mod)
    end
    local impl = loader()
    self._impls[mod] = impl
    return impl
end

-- value: true/false for toggles; a number, or nil/false to go back, for numbers; an option or nil.
function Modules.Set(self: any, mod: string, fid: string, value: any): (boolean, string?)
    local f: Feature? = self:Feature(mod, fid)
    if not f then
        return false, "no feature " .. mod .. "." .. fid
    end
    local feature = f :: Feature
    local off = value == nil or value == false
    if feature.command then
        local cmd = feature.command :: string
        local line: string
        if feature.kind == "toggle" then
            line = cmd .. (if off then " off" else " on")
        elseif off then
            line = "un" .. cmd
        else
            line = cmd .. " " .. tostring(value)
        end
        return self._reg:Run(line, "module")
    end

    local states: { [string]: FeatureState } = self._state[mod]
    local st: FeatureState = states[fid] or { on = false, value = nil, jan = nil }
    states[fid] = st
    local old = st.jan
    if old then
        st.jan = nil
        old:Cleanup()
    end
    if off then
        local was = st.on
        st.on = false
        st.value = nil
        if was then
            self.Changed:Fire(mod, fid)
        end
        return true, nil
    end
    local ctx: Ctx = self._ctx
    local handler = self:_impl(mod).features[fid]
    if not handler then
        return false, "no handler for " .. mod .. "." .. fid
    end
    local jan = Janitor.new(function(msg: string)
        ctx.log:Error(mod .. "." .. fid .. ": " .. msg)
    end)
    local ok, err = xpcall(function(): string?
        handler.enable(ctx, value, jan)
        return nil
    end, trace)
    if not ok then
        jan:Cleanup()
        st.on = false
        st.value = nil
        ctx.log:Error(mod .. "." .. fid .. ": " .. tostring(err))
        self.Changed:Fire(mod, fid)
        return false, string.match(tostring(err), "^[^\n]*")
    end
    st.on = true
    st.value = value
    st.jan = jan
    self.Changed:Fire(mod, fid)
    return true, nil
end

-- Turns every toggle of a section on, or every feature of it off.
function Modules.SetSection(self: any, mod: string, section: string, on: boolean)
    local spec: Spec? = self._byId[mod]
    if not spec then
        return
    end
    for _, f in spec.features do
        if f.section == section then
            if on and f.kind == "toggle" then
                self:Set(mod, f.id, true)
            elseif not on and self:IsOn(mod, f.id) then
                self:Set(mod, f.id, nil)
            end
        end
    end
end

function Modules.AllOff(self: any, mod: string)
    local spec: Spec? = self._byId[mod]
    if not spec then
        return
    end
    for _, f in spec.features do
        if self:IsOn(mod, f.id) then
            self:Set(mod, f.id, nil)
        end
    end
end

-- (on, total) for the module or one section.
function Modules.Count(self: any, mod: string, section: string?): (number, number)
    local spec: Spec? = self._byId[mod]
    if not spec then
        return 0, 0
    end
    local on, total = 0, 0
    for _, f in spec.features do
        if not section or f.section == section then
            total += 1
            if self:IsOn(mod, f.id) then
                on += 1
            end
        end
    end
    return on, total
end

local function userEntry(store: Store.Store, mod: string)
    local all = store.data.modules
    all[mod] = all[mod] or { presets = {} }
    return all[mod]
end

function Modules.Presets(self: any, mod: string): { Preset }
    local out: { Preset } = {}
    local spec: Spec? = self._byId[mod]
    if not spec then
        return out
    end
    for _, p in spec.presets or {} do
        table.insert(out, { id = p.id, values = p.values, builtin = true })
    end
    for _, p in userEntry(self._store, mod).presets do
        table.insert(out, { id = p.id, name = p.name, values = p.values, builtin = false })
    end
    return out
end

local function findPreset(self: any, mod: string, presetId: string): Preset?
    for _, p in self:Presets(mod) :: { Preset } do
        if p.id == presetId then
            return p
        end
    end
    return nil
end

local function matches(self: any, mod: string, fid: string, want: any): boolean
    local f: Feature? = self:Feature(mod, fid)
    if not f then
        return true
    end
    if f.kind == "toggle" then
        return self:IsOn(mod, fid) == (want == true)
    end
    if want == nil or want == false then
        return not self:IsOn(mod, fid)
    end
    return self:IsOn(mod, fid) and tostring(self:Value(mod, fid)) == tostring(want)
end

function Modules.PresetActive(self: any, mod: string, presetId: string): boolean
    local p = findPreset(self, mod, presetId)
    if not p then
        return false
    end
    for fid, want in p.values do
        if not matches(self, mod, fid, want) then
            return false
        end
    end
    return next(p.values) ~= nil
end

function Modules.ApplyPreset(self: any, mod: string, presetId: string)
    local p = findPreset(self, mod, presetId)
    if not p then
        return
    end
    for fid, want in p.values do
        if not matches(self, mod, fid, want) then
            self:Set(mod, fid, want)
        end
    end
    self.Changed:Fire(mod, "presets")
end

-- On: apply it. Already on: turn its features off again.
function Modules.TogglePreset(self: any, mod: string, presetId: string)
    if not self:PresetActive(mod, presetId) then
        self:ApplyPreset(mod, presetId)
        return
    end
    local p = findPreset(self, mod, presetId) :: Preset
    for fid in p.values do
        if self:IsOn(mod, fid) then
            self:Set(mod, fid, nil)
        end
    end
    self.Changed:Fire(mod, "presets")
end

-- Saves what is on right now; returns the new preset id.
function Modules.SavePreset(self: any, mod: string, name: string): string
    local spec: Spec = self._byId[mod]
    local values: { [string]: any } = {}
    for _, f in spec.features do
        if self:IsOn(mod, f.id) then
            values[f.id] = if f.kind == "toggle" then true else self:Value(mod, f.id)
        end
    end
    local entry = userEntry(self._store, mod)
    local id = "u" .. tostring(os.time()) .. tostring(#entry.presets + 1)
    table.insert(entry.presets, { id = id, name = name, values = values })
    self._store:Save("modules")
    self.Changed:Fire(mod, "presets")
    return id
end

function Modules.PresetTitle(self: any, mod: string, p: Preset): string
    if p.name then
        return p.name
    end
    local ctx: Ctx? = self._ctx
    return if ctx then ctx.t("m." .. mod .. ".p." .. p.id) else p.id
end

-- "sandbox.night": the module, then a built-in preset's id or a saved one's name with dashes.
local function presetKey(mod: string, p: Preset): string
    local tail = if p.builtin then p.id else string.gsub(string.lower(p.name or p.id), "%s+", "-")
    return mod .. "." .. tail
end

function Modules.PresetKey(_self: any, mod: string, p: Preset): string
    return presetKey(mod, p)
end

function Modules.PresetKeys(self: any): { string }
    local out: { string } = {}
    for _, s in self:Available() :: { Spec } do
        for _, p in self:Presets(s.id) :: { Preset } do
            table.insert(out, presetKey(s.id, p))
        end
    end
    return out
end

function Modules.FindPreset(self: any, key: string): (string?, Preset?)
    local want = string.lower(key)
    for _, s in self:Available() :: { Spec } do
        for _, p in self:Presets(s.id) :: { Preset } do
            if string.lower(presetKey(s.id, p)) == want then
                return s.id, p
            end
        end
    end
    return nil, nil
end

function Modules.DeletePreset(self: any, mod: string, presetId: string)
    local entry = userEntry(self._store, mod)
    for i, p in entry.presets do
        if p.id == presetId then
            table.remove(entry.presets, i)
            break
        end
    end
    self._store:Save("modules")
    self.Changed:Fire(mod, "presets")
end

function Modules.Run(self: any, mod: string): Run
    local r: RunInternal = self._runs[mod]
    return {
        state = r.state,
        status = r.status,
        progress = r.progress,
        elapsed = function()
            if r.state == "idle" then
                return 0
            end
            local now = if r.state == "paused" then r.pausedAt else os.clock()
            return now - r.startedAt - r.pausedTotal
        end,
    }
end

function Modules.Start(self: any, mod: string)
    local r: RunInternal = self._runs[mod]
    if r.state == "paused" then
        r.pausedTotal += os.clock() - r.pausedAt
        r.state = "running"
        self.Changed:Fire(mod, "run")
        return
    end
    if r.state == "running" then
        return
    end
    local impl: CtxTypes.GameImpl = self:_impl(mod)
    local maybe = impl.run
    if not maybe then
        return
    end
    local routine: (Ctx, CtxTypes.Runner, Janitor.Janitor) -> () = maybe
    local ctx: Ctx = self._ctx
    local jan = Janitor.new(function(msg: string)
        ctx.log:Error(mod .. " run: " .. msg)
    end)
    r.jan = jan
    r.state = "running"
    r.status = ""
    r.progress = 0
    r.startedAt = os.clock()
    r.pausedTotal = 0
    local runner: CtxTypes.Runner = {
        status = function(text: string)
            r.status = text
            self.Changed:Fire(mod, "run")
        end,
        progress = function(frac: number)
            r.progress = math.clamp(frac, 0, 1)
            self.Changed:Fire(mod, "run")
        end,
        wait = function(seconds: number): boolean
            local left = seconds
            while left > 0 do
                if r.state == "idle" then
                    return false
                end
                local dt = task.wait(math.min(left, 0.1))
                if r.state == "running" then
                    left -= dt
                end
            end
            return r.state ~= "idle"
        end,
        value = function(fid: string)
            return self:Value(mod, fid)
        end,
    }
    self.Changed:Fire(mod, "run")
    r.thread = task.spawn(function()
        local ok, err = xpcall(function(): string?
            routine(ctx, runner, jan)
            return nil
        end, trace)
        if not ok then
            ctx.log:Error(mod .. " run: " .. tostring(err))
            ctx.toast("error", string.match(tostring(err), "^[^\n]*") or tostring(err))
        end
        if r.jan == jan then
            jan:Cleanup()
            r.jan = nil
            r.thread = nil
            r.state = "idle"
            r.progress = if ok then r.progress else 0
            self.Changed:Fire(mod, "run")
        end
    end)
end

function Modules.Pause(self: any, mod: string)
    local r: RunInternal = self._runs[mod]
    if r.state == "running" then
        r.state = "paused"
        r.pausedAt = os.clock()
        self.Changed:Fire(mod, "run")
    end
end

function Modules.Stop(self: any, mod: string)
    local r: RunInternal = self._runs[mod]
    if r.state == "idle" then
        return
    end
    r.state = "idle"
    local th = r.thread
    r.thread = nil
    if th and coroutine.status(th) == "suspended" then
        pcall(task.cancel, th)
    end
    if r.jan then
        r.jan:Cleanup()
        r.jan = nil
    end
    r.status = ""
    r.progress = 0
    self.Changed:Fire(mod, "run")
end

function Modules.Destroy(self: any)
    if self._conn then
        self._conn:Disconnect()
    end
    for _, s in self.specs :: { Spec } do
        self:Stop(s.id)
        for _, st in self._state[s.id] :: { [string]: FeatureState } do
            if st.jan then
                st.jan:Cleanup()
                st.jan = nil
            end
            st.on = false
        end
    end
    self.Changed:DisconnectAll()
end

return Modules
