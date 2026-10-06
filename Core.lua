--------------------------------------------------------------------------------------
-- FILE: Core.lua
-- AUTHOR: Michael Peterson
-- REWRITE: October 2026
--------------------------------------------------------------------------------------
local ADDON_NAME, ns = ...

ns.Core = ns.Core or {} 
local core = ns.Core

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

local function getLinePrefix(stackTrace)
    stackTrace = stackTrace or debugstack(3)

    local sourceFile, lineNumber =
        stackTrace:match("[\\/]([^\\/:]+):(%d+)")

    if not sourceFile or not lineNumber then
        return "[Unknown:0] "
    end
    local prefix = string.format("[%s:%s] ", sourceFile, lineNumber)
    return prefix
end

local function formatMessage(...)
    local values = {}
    local valueCount = select("#", ...)

    for index = 1, valueCount do
        local value = select(index, ...)

        if value == nil then
            value = "<nil>"
        elseif type(value) ~= "string" then
            value = tostring(value)
        end

        values[#values + 1] = value
    end
    return table.concat(values, " ")
end

local function _getAddonInfo()
    local majorVersion = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-MAJOR") or "0"
    local minorVersion = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-MINOR") or "0"
    local patchVersion = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-PATCH") or "0"
    local addonVersion = string.format( "%s.%s.%s", majorVersion, minorVersion, patchVersion )
    local expansionName = getExpansionName()
    return ADDON_NAME, addonVersion, expansionName
end

-----------------------------------------------------------------
-- Public functions
-----------------------------------------------------------------
function core:getAddonInfo()
    local majorVersion = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-MAJOR") or "0"
    local minorVersion = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-MINOR") or "0"
    local patchVersion = C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-PATCH") or "0"
    
    local addonVersion = string.format( "%s.%s.%s", majorVersion, minorVersion, patchVersion )
    local expansionName = getExpansionName()
    return ADDON_NAME, addonVersion, expansionName
end

function core:errorPrint(...)
    if not core:isDebuggingEnabled() then
        return
    end
    local message = getLinePrefix(debugstack(2)) .. formatMessage(...)
    return message
end

function core:linePrefix()
    return getLinePrefix(debugstack(2))
end

local debuggingEnabled = true
function core:isDebuggingEnabled()
    return debuggingEnabled
end

function core:enableDebugging()
    debuggingEnabled = true

end

function core:disableDebugging()
    debuggingEnabled = false
end

ns.Core.loaded = true
if core:isDebuggingEnabled() then
    print("[SkillUp] Core.lua loaded")
end