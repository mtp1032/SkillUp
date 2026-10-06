--------------------------------------------------------------------------------------
-- FILE: EnUS.lua   
-- AUTHOR: Michael Peterson -
-- ORIGINAL DATE: 16 August, 2024
--------------------------------------------------------------------------------------
local ADDON_NAME, ns = ...

if not ns.Core.loaded then 
    error("[SkillUp] Core.lua not loaded")
    return
end
ns.EnUS = ns.EnUS or {}
local core = ns.Core
local addonName, addonVersion, expansionName = core:getAddonInfo()

local L = setmetatable({}, {
    __index = function(t, k)
        local v = tostring(k)
        rawset(t, k, v)
        return v
    end
})
ns.EnUS.L = L

local LOCALE = GetLocale()

if LOCALE == "enUS" then
    L["VERSION"]          = addonVersion
    L["EXPANSION_NAME"]   = expansionName
    L["ADDON_LOADED_MSG"] = string.format(
        "%s v%s, %s (Beta).",
        addonName,
        L["VERSION"],
        L["EXPANSION_NAME"]
    )
end

if LOCALE == "frFR" then
end
if LOCALE == "deDE" then
end
if LOCALE == "itIT" then
end
if LOCALE == "ptBR" then
end
if LOCALE == "koKR" then
end
if LOCALE == "ruRU" then
end
if LOCALE == "esES" or LOCALE == "esMX" then
end
if LOCALE == "zhTW" then
end
if LOCALE == "zhCN" then
end
if LOCALE == "svSE" then
end

ns.EnUS.loaded = true
if core:isDebuggingEnabled() then
    print( "[SkillUp] EnUS.lua loaded")
end