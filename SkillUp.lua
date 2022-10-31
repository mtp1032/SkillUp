--------------------------------------------------------------------------------------
-- SkillUp.lua 
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 9 March, 2021 

local _, SkillUp = ...
SkillUp.SkillUp = {}
skill = SkillUp.SkillUp

local sprintf = _G.string.format
local SUCCESS   = threadErrors.SUCCESS
local E = threadErrors
local EMPTY_STR = SkillUp.EMPTY_STR
local L = SkillUp.L

-- Access WoWThreads signal interface
 local SIG_WAKEUP            = thread.SIG_WAKEUP
 local SIG_RETURN            = thread.SIG_RETURN
 local SIG_NONE_PENDING      = thread.SIG_NONE_PENDING
 
local publisherThread_h   = nil
local main_h = nil
local function main()
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR }
    local isValid = true

    ------------------------------------------------------------/reload
    -- Create the publisher thread, publisherThread_h
    -----------------------------------------------------------------
    thread_h, result = thread:self()
    if not result[1] then mf:postResult( result ) end

    -- local areEqual, result = thread:areEqual(thread_h, main_h )
    -- if not result[1] then mf:postResult( result ) end
    local clockInterval = 50
    publisherThread_h, result = thread:create( 50, function() publish:floatSkillup() end)
    if not result[1] then mf:postResult( result ) return end
    result = handler:setPublisherThread( publisherThread_h )
    if not result[1] then mf:postResult( result ) return end  

    -- Wait for termination signal (SIG_RETURN)
    local signal = SIG_NONE_PENDING
    local sender_h = nil
    while signal ~= SIG_RETURN do
        result = thread:yield()
        if not result[1] then mf:postResult( result ) return end
        signal, sender_h = thread:getSignal()
    end
end

----------------------------------------------------------
-- Create the main thread. The publisher thread is created
-- inside the main thread's action routine.
----------------------------------------------------------
main_h, result = thread:create( 50, main )
if not result[1] then mf:postResult( result ) return end

SLASH_SKILLUP_COMMANDS1 = "/skillup"
SLASH_SKILLUP_COMMANDS2 = "/skill"

SlashCmdList["SKILLUP_COMMANDS"] = function( msg )
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR }
    local errStr  = nil

    if msg == nil then
        return
    end
    local msg = strupper( msg )

    if msg == "SUSPEND" then
        handler:suspend()


    elseif msg == "RESUME" then
            handler:resume()
    else
		local errStr = sprintf(L["UNKNOWN_OR_INVALID_SLASH_COMMAND_OPTION"])
		UIErrorsFrame:AddMessage( errStr, 1.0, 1.0, 0.0, 1, 20 )
    end
end

local fileName = "SkillUp.lua"
if E:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end