--------------------------------------------------------------------------------------
-- ErrorHandling.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------
local _, SkillUp = ...
SkillUp.ErrorHandling = {}	  
dbg = SkillUp.ErrorHandling	-- use for error reporting services

local L = SkillUp.lua
local sprintf = _G.string.format

local SUCCESS   		= skill.SUCCESS
local EMPTY_STR 		= skill.EMPTY_STR

---------------------------------------------------------------------------------------------------
--                      PUBLIC/EXPORTED FUNCTIONS
----------------------------------------------------------------------------------------------------
function dbg:prefix( stackTrace )
	if stackTrace == nil then stackTrace = debugstack(2) end
	
	local pieces = {strsplit( ":", stackTrace, 5 )}
	local segments = {strsplit( "\\", pieces[1], 5 )}

	local fileName = segments[#segments]
	
	local strLen = string.len( fileName )
	local fileName = string.sub( fileName, 1, strLen - 2 )
	local names = strsplittable( "\/", fileName )
	local lineNumber = tonumber(pieces[2])
	local location = sprintf("[%s:%d] ", names[#names], lineNumber)
	return location
end
function dbg:print( msg )
	local fileAndLine = dbg:prefix( debugstack(2) )
	-- print(fileAndLine .. " " .. msg)
	local str = msg
	if str then
		str = sprintf("%s %s", fileAndLine, str )
	else
		str = fileAndLine
	end
	DEFAULT_CHAT_FRAME:AddMessage( str, 0.0, 1.0, 1.0 )
end	
	-- see https://us.forums.blizzard.com/en/wow/t/scope-issue/1547258/3
function dbg:printx( ... )
	local prefix = dbg:prefix( debugstack(2) )
	print( prefix, ... )
end
function dbg:setResult( errMsg, stackTrace )
	local result = { FAILURE, EMPTY_STR, EMPTY_STR }

	local fileLocation = dbg:prefix( stackTrace )
	errMsg = sprintf("%s %s\n", fileLocation, errMsg )
	result[2] = errMsg

	if stackTrace ~= nil then
		result[3] = stackTrace
	end
	return result
end

local fileName = "ErrorHandling.lua" 
if skill:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end



