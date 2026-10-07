--------------------------------------------------------------------------------------
-- FILE: Locales.lua   
-- AUTHOR: Michael Peterson -
-- ORIGINAL DATE: 16 August, 2024
--------------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
ns.Locales = ns.Locales or {}
ns.Locales.debuggingIsEnabled = true

local EXPANSION_NAMES = {
    [LE_EXPANSION_CLASSIC] = "Classic",
    [LE_EXPANSION_BURNING_CRUSADE] = "Burning Crusade",
    [LE_EXPANSION_WRATH_OF_THE_LICH_KING] = "Wrath of the Lich King",
    [LE_EXPANSION_CATACLYSM] = "Cataclysm",
    [LE_EXPANSION_MISTS_OF_PANDARIA] = "Mists of Pandaria",
    [LE_EXPANSION_WARLORDS_OF_DRAENOR] = "Warlords of Draenor",
    [LE_EXPANSION_LEGION] = "Legion",
    [LE_EXPANSION_BATTLE_FOR_AZEROTH] = "Battle for Azeroth",
    [LE_EXPANSION_SHADOWLANDS] = "Shadowlands",
    [LE_EXPANSION_DRAGONFLIGHT] = "Dragonflight",
    [LE_EXPANSION_WAR_WITHIN] = "The War Within",
    [LE_EXPANSION_MIDNIGHT] = "Midnight",
}
   
-----------------------------------------------------------------
-- Private functions
-----------------------------------------------------------------

local function getExpansionName()
    local expansionName = "World of Warcraft: Forever"
    local expansionLevel = GetExpansionLevel()
    if expansionLevel == 0 then
        return expansionName
    end
    return EXPANSION_NAMES[expansionLevel]
        or select(4, GetBuildInfo())
end

local majorVersion = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-MAJOR") or "0"
local minorVersion = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-MINOR") or "0"
local patchVersion = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-PATCH") or "0"
local addonVersion = string.format( "%s.%s.%s", majorVersion, minorVersion, patchVersion )
local expansionName = getExpansionName()

local L = setmetatable({}, {
    __index = function(t, k)
        local v = tostring(k)
        rawset(t, k, v)
        return v
    end
})

ns.Locales.L = L
local LOCALE = GetLocale()
if LOCALE == "enUS" then
    L["VERSION"]          = addonVersion
    L["EXPANSION_NAME"]   = expansionName

    L["ADDON_LOADED_MSG"] = string.format(
        "%s v%s, %s (Beta).",
        ADDON_NAME,
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

ns.Locales.loaded = true 