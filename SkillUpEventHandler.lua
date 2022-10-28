--------------------------------------------------------------------------------------
-- SkillUpEventHandler.lua 
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 9 March, 2021
local _, SkillUp = ...
SkillUp.SkillUpEventHandler = {}
handler = SkillUp.SkillUpEventHandler

local sprintf 	= _G.string.format
local SUCCESS   = threadErrors.SUCCESS
local E 		= threadErrors
local EMPTY_STR = SkillUp.EMPTY_STR

local L = SkillUp.L

-- Access WoWThreads signal interface
 local SIG_WAKEUP            = thread.SIG_WAKEUP
 local SIG_RETURN            = thread.SIG_RETURN
 local SIG_NONE_PENDING      = thread.SIG_NONE_PENDING
 
 local function ClassicGetProfessions( ... )
	local good = false
	local skills = { }
	local skillnum = 0
	local header1 = string.lower( TRADE_SKILLS )
	local header2 = string.lower( SECONDARY_SKILLS )
	for k = 1, GetNumSkillLines( ) do
		local name, header = GetSkillLineInfo( k )
		if header ~= nil then
			name = string.lower( name )
			if string.match( header1, name ) or string.match( header2, name ) then
				good = true
				if string.match( header2, name ) and skillnum < 2 then
					skillnum = 2
				end
			else
				good = false
			end
		else
			if good then
				skillnum = skillnum + 1
				skills[skillnum] = k
			end
		end
	end
	return skills[1], skills[2], skills[3], skills[4], skills[5]
end

-- for _, v in ipairs( { ClassicGetProfessions( ) } ) do
--     if v then
--         --                          Return values					
--         -- skillName,			-- string - e.g., Engineering, Alchemy, Cooking, etc.,
--         -- header,	 			-- number - 1 if a header, nil otherwis
--         -- isExpanded,			-- number - 1 if the line is an expanded header, otherwise nil
--         -- skillRank 			-- number - current skill rank 
--         -- numTempPoints,		-- number - ?
--         -- skillModifier,		-- number - ?
--         -- skillMaxRank,		-- number - max skill rank, should be nil
--         -- isAbandonable,		-- number - 1 is skill is unlearnable
--         -- stepCost,			-- number - 1 if skill can be learned, nil otherwise
--         -- rankCost,			-- number - 1 if skillcan be trained
--         -- miniLevel,			-- number - minimum level skill can be trained
--         -- skillCostType,		-- number - ?
--         -- skillDescription	-- string
                                
--         local skillName, header, isExpanded, skillRank, numTempPoints, skillModifier, skillMaxRank, 
--               isAbandonable, stepCost, rankCost, minLevel, skillCostType, skillDescription = GetSkillLineInfo(v)
--         skillMsg = sprintf("Your %s skill increased to %d (of %d max)\n", skillName, skillRank+1, skillMaxRank)
--         DEFAULT_CHAT_FRAME:AddMessage( skillMsg, 0.0, 1.0, 0.0)
--     end
-- end
-- ******************* END SKILLUPS USING BLIZZ CODE ***********************

local chatEntries = {}
local publisherThread_h = nil

local SUSPEND = false
function handler:suspend()
	SUSPEND = true
end
function handler:resume()
	SUSPEND = false
end
function handler:isSuspended()
	return SUSPEND
end

function handler:setPublisherThread( thread_h )
	local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
	if thread_h == nil then 
		result = E:setResult( L["INPUT_PARAM_NIL"], debugstack())
		return result
	end

	publisherThread_h = thread_h
	return result
end

-- Remove the first table entry in the buffer table
-- Called by the publisher thread.
function handler:getChatEntry()
	if #chatEntries == 0 then return nil end

	-- removes the first element in the table.
    local entry = table.remove( chatEntries, 1)

	-- entry[1] is the boolean, isSkillUp, entry[2] is the text of the entry
	return entry[1], entry[2]
end

function handler:numChatEntries()
	return #chatEntries
end

local function insertChatEntry( isSkillUp, msgString )
	local isValid = true
	local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
	local entry = {isSkillUp, msgString}

	if isSkillUp == nil then
		result = E:setResult( L["INPUT_PARAM_NIL"], dbgstack())
		return false, result
	end
	if type(isSkillUp) ~= "boolean" then
		result = E:setResult( L["INVALID_TYPE"] .. " Expected boolean", dbgstack())
		return false, result
	end
	if msgString == nil then
		result = E:setResult( L["INPUT_PARAM_NIL"], dbgstack())
		return false, result
	end
	if type( msgString) ~= "string" then
		result = E:setResult( L["INVALID_TYPE"] .. " Expected boolean", dbgstack())
		return false, result
	end


	-- after insert, entry is the last element in the table
	table.insert( chatEntries, entry )

	if publisherThread_h == nil then
		result = E:setResult(L["PUBLISHER_THREAD_NOT_INITIALIZED"], debugstack())
		mf:postResult( result )
	end

	result = thread:sendSignal( publisherThread_h, SIG_WAKEUP )
	return result
end

local function OnEvent( self, event, ... )
	local arg1 = ...
	local result = {SUCCESS, EMPTY_STR, EMPTY_STR}

	if event == "ADDON_LOADED" and arg1 == "SkillUp" then
		DEFAULT_CHAT_FRAME:AddMessage( L["ADDON_LOADED_MESSAGE"], 1.0, 1.0, 0)
	end

	-- if handler:isSuspended() == true then return end
	-- TODO: Signals lootThread_h
	if event == "CHAT_MSG_LOOT" then
		result = insertChatEntry( false, arg1 )
		if not result[1] then mf:postResult( result ) return end
		return
	end 

	-- TODO: Signals skillThread_h
	if event == "CHAT_MSG_SKILL" then
		result = insertChatEntry( true, arg1 )
		if not result[1] then mf:postResult( result ) return end
		return
	end

	-- TODO: Signals moneyThread_h
	if event == "CHAT_MSG_MONEY" then
		result = insertChatEntry( true, arg1 )
		if not result[1] then mf:postResult( result ) return end
		return
	end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_SKILL")
eventFrame:RegisterEvent("CHAT_MSG_LOOT")
eventFrame:RegisterEvent("CHAT_MSG_MONEY")
eventFrame:SetScript( "OnEvent", OnEvent )

local fileName = "SkillUpEventHandler.lua"
if E:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end
