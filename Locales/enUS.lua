----------------------------------------------------------------------------------------
-- enUS.lua
-- AUTHOR: mtpeterson1948 at gmail dot com
-- ORIGINAL DATE: 9 March, 2021
----------------------------------------------------------------------------------------
local _, SkillUp = ...
SkillUp.enUS = {}
local L = setmetatable({}, { __index = function(t, k)
	local v = tostring(k)
	rawset(t, k, v)
	return v
end })
lang = SkillUp.enUS

SkillUp.L = L 
SkillUp.EMPTY_STR = ""
local EMPTY_STR = SkillUp.EMPTY_STR

local sprintf = _G.string.format

-- English translations
local LOCALE = GetLocale()      -- BLIZZ
if LOCALE == "enUS" then

	-- SkillUp Localizations
	L["ADDON_NAME"]					= "SkillUp"
	L["VERSION"]					= "Prerelease V 0.2 (Classic TBC/WOTLK)"
	L["LOADED"]						= "loaded"
	L["ADDON_LOADED_MESSAGE"] 		= sprintf("[INFO] %s %s - %s", L["ADDON_NAME"], L["LOADED"], L["VERSION"] )

	L["INPUT_PARAM_NIL"]				= "[ERROR] Input Parameter nil "
	L["INVALID_TYPE"]		= "[ERROR] Input Parameter type invalid . "
	L["INVALID_COMMAND"]		= "[ERROR] Invalid or Unsupported Command. "
	L["PUBLISHER_THREAD_NOT_INITIALIZED"] = "[ERROR] The publisher thread was nil. "
end
