--------------------------------------------------------------------------------------
-- SkillUp.lua 
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 9 March, 2021 

local _, SkillUp = ...
SkillUp.SkillUp = {}
skillup = SkillUp.SkillUp

local Major ="LibThreads-1.0"
local thread = LibStub:GetLibrary( Major )
if not thread then 
    return 
end

local SIG_ALERT             = thread.SIG_ALERT
local SIG_JOIN_DATA_READY   = thread.SIG_JOIN_DATA_READY
local SIG_TERMINATE         = thread.SIG_TERMINATE
local SIG_METRICS           = thread.SIG_METRICS
local SIG_NONE_PENDING      = thread.SIG_NONE_PENDING
local L = SkillUp.L
local sprintf = _G.string.format

local EMPTY_STR = core.EMPTY_STR
local SUCCESS	= core.SUCCESS
local FAILURE	= core.FAILURE

local main_h = nil
local publisherThread_h = nil

local function main()
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR }

    ------------------------------------------------------------/reload
    -- Create the publisher thread, publisherThread_h
    -----------------------------------------------------------------
    main_h, threadId = thread:self()

    local clockInterval = 300
    publisherThread_h, result = thread:create( clockInterval, 
        function() publish:skillUp() 
        end )
    if not result[1] then mf:postResult( result ) return end
    handler:setPublisherThread( publisherThread_h )

    local FINISHED = false
    while not FINISHED do
        thread:yield()
        local signal, sender_h = thread:getSignal()
        if signal == SIG_TERMINATE then
            result = thread:sendSignal( publisherThread_h, SIG_TERMINATE )
            if not result[1] then mf:postResult( result ) return end   

            FINISHED = true
        end
    end
    mf:postMsg( sprintf("main_h terminated.\n"))
end

----------------------------------------------------------
-- Create the main thread. The publisher thread is created
-- inside the main thread's action routine.
----------------------------------------------------------
main_h, result = thread:create( 50, main )
if not result[1] then mf:postResult(result) return end

SLASH_SKILLUP_COMMANDS1 = "/skillup"
SLASH_SKILLUP_COMMANDS2 = "/skill"

SlashCmdList["SKILLUP_COMMANDS"] = function( msg )
    local result = {SUCCESS, EMPTY_STR, EMPTY_STR }
    local errStr  = nil

    if msg == nil then
        return
    end
    local msg = strupper( msg )

    if msg == "TERM" or msg == "TERMINATE" then
        result = thread:sendSignal( main_h, SIG_TERMINATE)
        if not result[1] then mf:postResult( result ) return end
        return
    end

    if msg == "DBG" then
        skill:enableDebugging()
        DEFAULT_CHAT_FRAME:AddMessage( "Debugging Enabled", 1.0, 1.0, 0.0 )
        return
    end
    if msg == "NODBG" then
        skill:disableDebugging()
        DEFAULT_CHAT_FRAME:AddMessage( "Debugging Disabled", 1.0, 1.0, 0.0 )
        return
    end

    local errStr = sprintf(L["UNKNOWN_OR_INVALID_SLASH_COMMAND_OPTION"])
    DEFAULT_CHAT_FRAME:AddMessage( errStr, 1.0, 1.0, 0.0 )
end

local fileName = "SkillUp.lua"
if skill:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end