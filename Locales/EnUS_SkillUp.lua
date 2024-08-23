--------------------------------------------------------------------------------------
-- EnUS_SkillUp.lua   
-- AUTHOR: Michael Peterson 
-- ORIGINAL DATE: 16 August, 2024
--------------------------------------------------------------------------------------
-- Ensure SkillUp namespace exists
local ADDON_NAME, SkillUp= ...
-- Make the SkillUp table available to other files

SkillUp.EnUS_SkillUp = SkillUp.EnUS_SkillUp or {}

local LibStub = LibStub
local LIBSTUB_MAJOR, LIBSTUB_MINOR = "EnUS_SkillUp", 1
local LibStub = LibStub -- If LibStub is not global, adjust accordingly
local EnUS_SkillUp, oldVersion = LibStub:NewLibrary(LIBSTUB_MAJOR, LIBSTUB_MINOR)
if not EnUS_SkillUp then 
    return 
end



-- Configure WoWThreads as a LibStub managed library
local MAJOR = tonumber(C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-MAJOR"))
local MINOR = tonumber(C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-MINOR"))
local PATCH = tonumber(C_AddOns.GetAddOnMetadata(ADDON_NAME, "X-PATCH"))

if not (MAJOR and MINOR and PATCH) then
    error("Failed to retrieve version information from the .toc file.")
end
-- Combine version components into a single github-style version number
local versionNumber = MAJOR * 10000 + MINOR * 100 + PATCH

local version = string.format("%s.%s.%s", MAJOR, MINOR, PATCH )

local function getExpansionName( )
    local expansionLevel = GetExpansionLevel()
    local expansionNames = { -- Use a table to map expansion levels to names
                                [LE_EXPANSION_DRAGONFLIGHT] = "Dragon Flight",
                                [LE_EXPANSION_SHADOWLANDS] = "Shadowlands",
                                [LE_EXPANSION_CATACLYSM] = "Classic (Cataclysm)",
                                [LE_EXPANSION_WRATH_OF_THE_LICH_KING] = "Classic (WotLK)",
                                [LE_EXPANSION_CLASSIC] = "Classic (Vanilla)",
                                [LE_EXPANSION_MISTS_OF_PANDARIA] = "Classic (Mists of Pandaria",
                                [LE_EXPANSION_LEGION] = "Classic (Legion)",
                                [LE_EXPANSION_BATTLE_FOR_AZEROTH] = "Classic (Battle for Azeroth)",
                                [LE_EXPANSION_WAR_WITHIN]   = "Retail (The War Within)"                            }
    return expansionNames[expansionLevel]
end

-- =====================================================================
--                      LOCALIZATION
-- =====================================================================
local L = setmetatable({}, { __index = function(t, k) 
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })

EnUS_SkillUp.L = L

local LOCALE = GetLocale()

if LOCALE == "enUS" then

    L["VERSION"] 			        = version
    L["EXPANSION_NAME"]             = getExpansionName()
    L["ADDON_LOADED_MSG"]           = string.format("%s v%s (%s) Loaded.", ADDON_NAME, L["VERSION"], L["EXPANSION_NAME"]  )

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
