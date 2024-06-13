--=================================================================================
-- Filename: Core.lua
-- Date: 9 March, 2021
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 9 March, 2021
--=================================================================================
local ADDON_NAME, _ = ...

-- Ensure SkillUp namespace exists
SkillUp = SkillUp or {}
SkillUp.Core = SkillUp.Core or {}

local core = SkillUp.Core

local L = SkillUp.L
local sprintf = _G.string.format

local UtilsLib = LibStub("UtilsLib")
local utils = UtilsLib
if not utils then return end

local thread = LibStub:GetLibrary( "WoWThreads-1.0" )
if not thread then return end

local DEBUGGING_ENABLED	= false
local ADDON_NAME = "SkillUp"

local function skillUpErrorHandler( errorMsg )
	local errorMsg = sprintf("%s\n", errorMsg )
	utils:postMsg( errorMsg )
end
thread:registerErrorHandler( skill:getAddonName(), skillUpErrorHandler )

function core:enableDebugging()
	DEBUGGING_ENABLED = true
	DEFAULT_CHAT_FRAME:AddMessage( "Debugging is Now ENABLED", 0.0, 1.0, 1.0 )
end
function core:disableDebugging()
	DEBUGGING_ENABLED = false
	DEFAULT_CHAT_FRAME:AddMessage( "Debugging is Now DISABLED", 0.0, 1.0, 1.0 )
end
function core:debuggingIsEnabled()
	return DEBUGGING_ENABLED
end

function core:handleError( addonName, errorMsg )
	thread:invokeCallback( "SkillUp", errorMsg )
	if utils.strict then
		error( "STOPPED: Full Stack Follows: ")
	end
end


local fileName = "Core.lua"
if core:debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage( fileName, 0.0, 1.0, 1.0 )
end