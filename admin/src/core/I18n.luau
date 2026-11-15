--!strict
-- Strings by key. Each scope (core, every module) registers one table with all six languages;
-- a missing key falls back to English and then to the key itself.

local LocalizationService = game:GetService("LocalizationService")

local Signal = require("./Signal")
local Types = require("../Types")

type Lang = Types.Lang

export type Value = Types.I18nValue
export type Bundle = Types.Bundle

export type I18n = {
    lang: Lang,
    Changed: Signal.Signal<Lang>,
    Register: (self: I18n, bundle: Bundle) -> (),
    T: (self: I18n, key: string, ...any) -> string,
    Has: (self: I18n, key: string) -> boolean,
    Plural: (self: I18n, key: string, n: number) -> string,
    SetLang: (self: I18n, lang: string) -> boolean,
    Destroy: (self: I18n) -> (),
}

local LANGS: { Lang } = { "ru", "en", "uk", "es", "pt", "de" }

local function isLang(s: string?): boolean
    return s ~= nil and table.find(LANGS, s :: any) ~= nil
end

local function slavic(n: number): number
    local m10, m100 = n % 10, n % 100
    if m10 == 1 and m100 ~= 11 then
        return 1
    elseif m10 >= 2 and m10 <= 4 and (m100 < 12 or m100 > 14) then
        return 2
    end
    return 3
end

local I18n = {}
I18n.__index = I18n
I18n.LANGS = LANGS

function I18n.detect(saved: string?): Lang
    if isLang(saved) then
        return saved :: Lang
    end
    local ok, locale = pcall(function()
        return LocalizationService.RobloxLocaleId
    end)
    local code = if ok and type(locale) == "string" then string.sub(locale, 1, 2) else "en"
    return if isLang(code) then code :: Lang else "en"
end

function I18n.new(lang: Lang): I18n
    local self = {
        lang = lang,
        Changed = Signal.new(),
        _tables = {} :: { [string]: { [string]: Value } },
    }
    for _, l in LANGS do
        self._tables[l] = {}
    end
    return (setmetatable(self, I18n) :: any) :: I18n
end

function I18n.Register(self: any, bundle: Bundle)
    for lang, strings in bundle do
        local into = self._tables[lang]
        if into then
            for k, v in strings do
                into[k] = v
            end
        end
    end
end

local function lookup(self: any, key: string): Value?
    return self._tables[self.lang][key] or self._tables.en[key]
end

function I18n.Has(self: any, key: string): boolean
    return lookup(self, key) ~= nil
end

function I18n.T(self: any, key: string, ...: any): string
    local v = lookup(self, key)
    if v == nil then
        return key
    end
    if type(v) == "table" and type((...)) == "number" then
        return self:Plural(key, (...))
    end
    local s: string = if type(v) == "table" then v[#v] else v
    if select("#", ...) > 0 then
        local ok, out = pcall(string.format, s, ...)
        return if ok then out else s
    end
    return s
end

function I18n.Plural(self: any, key: string, n: number): string
    local v = lookup(self, key)
    if type(v) ~= "table" then
        return self:T(key, n)
    end
    local lang = if self._tables[self.lang][key] then self.lang else "en"
    local idx
    if lang == "ru" or lang == "uk" then
        idx = slavic(math.abs(n))
    else
        idx = if n == 1 then 1 else 2
    end
    local form = v[math.min(idx, #v)]
    local ok, out = pcall(string.format, form, n)
    return if ok then out else form
end

function I18n.SetLang(self: any, lang: string): boolean
    if not isLang(lang) then
        return false
    end
    self.lang = lang
    self.Changed:Fire(lang)
    return true
end

function I18n.Destroy(self: any)
    self.Changed:DisconnectAll()
end

return I18n
