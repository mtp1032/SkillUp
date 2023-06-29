--------------------------------------------------------------------------------------
-- SkillUpEventHandler.lua   
-- AUTHOR: Michael Peterson 
-- ORIGINAL DATE: 22 May, 2023
local _, SkillUp = ...
SkillUp.SkillUpEventHandler = {}
handler = SkillUp.SkillUpEventHandler

local Major = "WoWThreads-1.0"
local thread = LibStub:GetLibrary( Major )
if not thread then 
    return 
end
local L = SkillUp.L

local SIG_ALERT             = thread.SIG_ALERT
local SIG_JOIN_DATA_READY   = thread.SIG_JOIN_DATA_READY
local SIG_TERMINATE         = thread.SIG_TERMINATE
local SIG_METRICS           = thread.SIG_METRICS
local SIG_STOP              = thread.SIG_STOP
local SIG_NONE_PENDING      = thread.SIG_NONE_PENDING

local sprintf 		= _G.string.format
local EMPTY_STR 	= skill.EMPTY_STR
local SUCCESS		= skill.SUCCESS

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
function handler:getChatEntry()
	if #chatEntries == 0 then return nil, nil, 0 end

    local entry = table.remove( chatEntries, 1)
	local isSkillUp = entry[1]
	local chatMsg	= entry[2]

	return isSkillUp, chatMsg, #chatEntries
end
local function insertChatEntry( skillupType, chatMsg )
	local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
	assert( chatMsg ~= nil, "ASSERT FAILED: chatMsg was nil.")

	if skillupType ~= SKILLUP and
		skillupType ~= LOOT and
		skillupType ~= MONEY then
		local s = sprintf("ASSERT FAILED: Skillup Type, %d, not recognized", skillupType)
		assert( false, s )
	end

	local entry = {skillupType, chatMsg}
	table.insert( chatEntries, entry )

	if publisher_h == nil then
		result = skilldbg:setResult( "Publisher thread was nil", debugstack() )
		return result
	end
	result = thread:sendSignal( publisher_h, SIG_ALERT )
	return result
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_SKILL")
eventFrame:RegisterEvent("CHAT_MSG_LOOT")
eventFrame:RegisterEvent("CHAT_MSG_MONEY")

local function OnEvent( self, event, ... )
	local arg1 = ...
	local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
	local skillupType = nil

	if event == "ADDON_LOADED" and arg1 == L["ADDON_NAME"] then
		DEFAULT_CHAT_FRAME:AddMessage( L["ADDON_LOADED_MESSAGE"], 1.0, 1.0, 0)
		eventFrame:UnregisterEvent("ADDON_LOADED")  
	end

	-- if handler:isSuspended() == true then return end
	-- TODO: Signals lootThread_h
	if event == "CHAT_MSG_LOOT" then
		local chatMsg = arg1
		result = insertChatEntry( LOOT, chatMsg )
		if not result[1] then mf:postResult( result ) return end
		return
	end

	if event == "CHAT_MSG_SKILL" then
		local chatMsg = arg1
		result = insertChatEntry( SKILLUP, chatMsg )
		if not result[1] then mf:postResult( result ) return end
		return
	end
	if event == "CHAT_MSG_MONEY" then
		local chatMsg = arg1
		result = insertChatEntry( MONEY, chatMsg )
		if not result[1] then mf:postResult( result ) return end
		return
	end
	return
end
eventFrame:SetScript( "OnEvent", OnEvent )

local fileName = "SkillUpEventHandler.lua"
if skill:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end
