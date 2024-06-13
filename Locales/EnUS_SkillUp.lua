----------------------------------------------------------------------------------------
-- EnUS_SkillUp.lua
-- AUTHOR: mtpeterson1948 at gmail dot com
-- ORIGINAL DATE: 9 March, 2021
----------------------------------------------------------------------------------------
local SkillUp = SkillUp or {}

SkillUp.EnUS_SkillUp = {}

local L = setmetatable({}, { __index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })
SkillUp.L = L 
local sprintf = _G.string.format

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

local ADDON_NAME 		= skill:getAddonName()
local ADDON_VERSION 	= GetAddOnMetadata( ADDON_NAME, "Version")
local EXPANSION_NAME 	= getExpansionName()


-- English translations
local LOCALE = GetLocale()
if LOCALE == "enUS" then

	-- SkillUp Localizations
	L["ADDON_NAME"]					= ADDON_NAME
	L["VERSION"]					= ADDON_VERSION
	L["EXPANSION_NAME"]				= EXPANSION_NAME
	L["ADDON_LOADED_MESSAGE"] 		= sprintf("%s loaded - %s %s", L["ADDON_NAME"], L["VERSION"], L["EXPANSION_NAME"] )
	
	L["INPUT_PARAM_NIL"]			= "[ERROR] Input Parameter nil "
	L["INVALID_TYPE"]				= "[ERROR] Input Parameter type invalid . "
	L["INVALID_COMMAND_OPTION"] 	= "[ERROR] Invalid Slash Command Option. "
end

local fileName = "EnUS_SkillUp.lua"
if core:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage( fileName, 0.0, 1.0, 1.0 )
end