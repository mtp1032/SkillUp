-- Localizations.lua — basic localization scaffolding (Classic/Turtle, Lua 5.0)
-- UPDATED: 29 Aug 2025

SkillUp = SkillUp or {}
SkillUp.Localizations = SkillUp.Localizations or {}
local L = SkillUp.Localizations

-- ===== Resolve addon metadata WITHOUT depending on Core.lua =====
-- NOTE: In 1.12, GetAddOnMetadata keys by the *folder name*.
local folderName = "SkillUp"   -- <- ensure this matches your addon folder
local addonName = folderName
local addonVersion = ""
local addonExpansionName = ""

if type(GetAddOnMetadata) == "function" then
    local title = GetAddOnMetadata(folderName, "Title")
    if title and title ~= "" then addonName = title end

    local ver = GetAddOnMetadata(folderName, "Version")
    if ver and ver ~= "" then addonVersion = ver end

    -- Optional custom TOC field if you add it:
    -- ## X-Expansion: Turtle
    local exp = GetAddOnMetadata(folderName, "X-Expansion")
    if exp and exp ~= "" then addonExpansionName = exp end
end

-- Build a clean "X loaded" line with conditional pieces (no double spaces, no empty parens)
local function buildLoadedLine()
    local parts = { addonName }
    if addonVersion ~= "" then
        parts[table.getn(parts) + 1] = addonVersion
    end
    local base = table.concat(parts, " ")
    if addonExpansionName ~= "" then
        base = base .. " (" .. addonExpansionName .. ")"
    end
    return base .. " loaded"
end

-- ===== Locale detection =====
local LOCALE = (type(GetLocale) == "function" and GetLocale()) or "enUS"

-- ===== English base (fallback) =====
local EN = {
    ADDON_LOADED_MESSAGE = string.format("%s v%s (%s)", addonName, addonVersion, addonExpansionName )
}

-- ===== Per-locale tables (only override differences) =====
L._t = L._t or {}
L._t["enUS"] = EN
L._t["enGB"] = EN

-- Example for another locale (copy & translate):
-- L._t["deDE"] = {
--     ADDON_LOADED_MESSAGE = (function()
--         local parts = { addonName }
--         if addonVersion ~= "" then parts[table.getn(parts) + 1] = addonVersion end
--         local base = table.concat(parts, " ")
--         if addonExpansionName ~= "" then base = base .. " (" .. addonExpansionName .. ")" end
--         return base .. " geladen"
--     end)(),
--     EARNINGS_POPUP = "Transaktion abgeschlossen. Einnahmen: %s",
--     KACHING_BTN_TOOLTIP = "Bis zu 12 geeignete Gegenstände verkaufen.",
--     MONEY_GAINED = "Geld erhalten: %s",
--     MONEY_SPENT  = "Geld ausgegeben: %s",
-- }

-- Active locale table (falls back to EN)
local ACTIVE = L._t[LOCALE] or EN

setmetatable(L, {
    __index = function(_, k)
        local v = ACTIVE[k]
        if v ~= nil then return v end
        return EN[k]
    end
})

-- Lua 5.0-safe formatter (no `select`, no `#`)
function L:fmt(key, ...)
    local tmpl = self[key]
    if tmpl == nil then return key end
    local args = arg  -- Lua 5.0 varargs table
    if not args or table.getn(args) == 0 then
        return tmpl
    end
    return string.format(tmpl, unpack(args))
end

L.loaded = true
