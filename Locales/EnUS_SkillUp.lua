----------------------------------------------------------------------------------------
-- EnUS_SkillUp.lua
-- AUTHOR: mtpeterson1948 at gmail dot com
-- ORIGINAL DATE: 9 March, 2021
----------------------------------------------------------------------------------------
local _, SkillUp = ...
SkillUp.EnUS_SkillUp = {}
skill = SkillUp.EnUS_SkillUp

local L = setmetatable({}, { __index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })
lang = SkillUp.enUS

SkillUp.L = L 
local sprintf = _G.string.format

skill.SUCCESS 	        = true
skill.FAILURE 	        = false
skill.EMPTY_STR 	    = ""
skill.DEBUGGING_ENABLED	= false

local EMPTY_STR 		= skill.EMPTY_STR
local SUCCESS			= skill.SUCCESS
local FAILURE			= skill.FAILURE
local function getExpansionName() 
	local isValid = false
	local expansionName = nil

	local releaseName = GetServerExpansionLevel()

	if releaseName == LE_EXPANSION_CLASSIC then
		expansionName = "Classic (Vanilla)"
	end
	if releaseName == LE_EXPANSION_WRATH_OF_THE_LICH_KING then
		expansionName = "Classic (WotLK)"
	end
	if releaseName == LE_EXPANSION_DRAGONFLIGHT then
		expansionName = "Dragon Flight"
	end
	return expansionName
end
local function getAddonName()
	local stackTrace = debugstack(2)
	local dirNames = nil
	local addonName = nil

	if 	EXPANSION_LEVEL == LE_EXPANSION_DRAGONFLIGHT then
		dirNames = {strsplittable( "\/", stackTrace, 5 )}	end
	if EXPANSION_LEVEL == LE_EXPANSION_WRATH_OF_THE_LICH_KING then
		dirNames = {strsplittable( "\/", stackTrace, 5 )}
	end
	if EXPANSION_LEVEL == LE_EXPANSION_CLASSIC then
		dirNames = {strsplittable( "\/", stackTrace, 5 )}
	end

	addonName = dirNames[1][3]
	return addonName
end

skill.ADDON_NAME 		= getAddonName()
skill.ADDON_VERSION 	= GetAddOnMetadata( skill.ADDON_NAME, "Version")
skill.EXPANSION_NAME 	= getExpansionName()

function skill:enableDebugging()
	skill.DEBUGGING_ENABLED = true
	DEFAULT_CHAT_FRAME:AddMessage( "Debugging is Now ENABLED", 0.0, 1.0, 1.0 )
end
function skill:disableDebugging()
	skill.DEBUGGING_ENABLED = false
	DEFAULT_CHAT_FRAME:AddMessage( "Debugging is Now DISABLED", 0.0, 1.0, 1.0 )
end
function skill:debuggingIsEnabled()
	return skill.DEBUGGING_ENABLED
end

-- English translations
local LOCALE = GetLocale()      -- BLIZZ
if LOCALE == "enUS" then

	-- SkillUp Localizations
	L["ADDON_NAME"]					= skill.ADDON_NAME
	L["VERSION"]					= skill.ADDON_VERSION
	L["EXPANSION_NAME"]				= skill.EXPANSION_NAME
	L["ADDON_LOADED_MESSAGE"] 		= sprintf("%s loaded - %s %s", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )
	
	L["INPUT_PARAM_NIL"]			= "[ERROR] Input Parameter nil "
	L["INVALID_TYPE"]				= "[ERROR] Input Parameter type invalid . "
	L["INVALID_COMMAND"]			= "[ERROR] Invalid or Unsupported Command. "
	L["OUT_OF_RANGE"]				= "[ERROR] Invalide skillUp type: out-of-range. "
	L["PUBLISHER_THREAD_NOT_INITIALIZED"] = "[ERROR] The publisher thread was nil. "
end

local fileName = "EnUs_SkillUp.lua"
if skill:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end
