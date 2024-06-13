--------------------------------------------------------------------------------------
-- SkillUpEventHandler.lua   
-- AUTHOR: Michael Peterson 
-- ORIGINAL DATE: 22 May, 2023
--------------------------------------------------------------------------------------
-- Ensure SkillUp namespace exists
local ADDON_NAME, _ = ...

-- Make the SkillUp table available to other files
SkillUp = SkillUp or {}
SkillUp.SkillUpEventHandler = SkillUp.SkillUpEventHandler or {}
handler = SkillUp.SkillUpEventHandler

local UtilsLib = LibStub("UtilsLib")
local utils = UtilsLib
if not utils then return end

local thread = LibStub:GetLibrary( "WoWThreads-1.0" )
if not thread then return end

local L = SkillUp.L

local SIG_ALERT         = thread.SIG_ALERT
local SIG_GET_DATA      = thread.SIG_GET_DATA
local SIG_RETURN_DATA   = thread.SIG_RETURN_DATA
local SIG_BEGIN         = thread.SIG_BEGIN
local SIG_HALT          = thread.SIG_HALT
local SIG_TERMINATE     = thread.SIG_TERMINATE
local SIG_IS_COMPLETE   = thread.SIG_IS_COMPLETE
local SIG_SUCCESS       = thread.SIG_SUCCESS
local SIG_FAILURE       = thread.SIG_FAILURE  
local SIG_SEND_DATA         = thread.SIG_SEND_DATA 
local SIG_WAKEUP        = thread.SIG_WAKEUP 
local SIG_CALLBACK      = thread.SIG_CALLBACK
local SIG_THREAD_DEAD   = thread.SIG_THREAD_DEAD
local SIG_NONE_PENDING  = thread.SIG_NONE_PENDING

local sprintf 	= _G.string.format

handler.SKILLUP = 1
handler.LOOT	= 2
handler.MONEY	= 3

local SKILLUP 	= handler.SKILLUP 
local LOOT		= handler.LOOT
local MONEY		= handler.MONEY

local chatEntries = {}
local publisher_h = nil

function handler:setPublisherThread( thread_h )
	publisher_h = thread_h
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_SKILL")
eventFrame:RegisterEvent("CHAT_MSG_LOOT")
eventFrame:RegisterEvent("CHAT_MSG_MONEY")

local function OnEvent( self, event, ... )
	local args = ...
	local skillupType = nil

	if event == "ADDON_LOADED" and args == L["ADDON_NAME"] then
		DEFAULT_CHAT_FRAME:AddMessage( L["ADDON_LOADED_MESSAGE"], 1.0, 1.0, 0)
		
		eventFrame:UnregisterEvent("ADDON_LOADED")  
		return
	end

	if event == "CHAT_MSG_LOOT" then
		local msgEntry = {LOOT, args}
		-- utils:postMsg( sprintf("Code: %d, Msg:%s\n",msgEntry[1], msgEntry[2]))
		thread:sendSignal( publisher_h, SIG_SEND_DATA, msgEntry )

	elseif event == "CHAT_MSG_SKILL" then
		local msgEntry = {SKILLUP, args}
		thread:sendSignal( publisher_h,  SIG_SEND_DATA, msgEntry)

	elseif event == "CHAT_MSG_MONEY" then
		local msgEntry = {MONEY, args}
		thread:sendSignal( publisher_h, SIG_SEND_DATA, msgEntry )
	end
end
eventFrame:SetScript( "OnEvent", OnEvent )

local fileName = "SkillUpEventHandler.lua"
if core:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( fileName, 0.0, 1.0, 1.0 )
end