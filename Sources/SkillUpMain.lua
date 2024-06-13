--------------------------------------------------------------------------------------
-- SkillUpMain.lua 
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 9 March, 2021  
local ADDON_NAME, _ = ...

-- Ensure SkillUp namespace exists
SkillUp = SkillUp or {}
SkillUp.SkillUpMain = SkillUp.SkillUpMain or {}
local sprintf     = _G.string.format

local UtilsLib = LibStub("UtilsLib")
local utils = UtilsLib
if not utils then return end

local thread = LibStub:GetLibrary( "WoWThreads-1.0" )
if not thread then return end

local SIG_ALERT         = thread.SIG_ALERT
local SIG_GET_DATA      = thread.SIG_GET_DATA
local SIG_RETURN_DATA   = thread.SIG_RETURN_DATA
local SIG_BEGIN         = thread.SIG_BEGIN
local SIG_HALT          = thread.SIG_HALT
local SIG_TERMINATE     = thread.SIG_TERMINATE
local SIG_IS_COMPLETE   = thread.SIG_IS_COMPLETE
local SIG_SUCCESS       = thread.SIG_SUCCESS
local SIG_FAILURE       = thread.SIG_FAILURE  
local SIG_READY         = thread.SIG_READY 
local SIG_WAKEUP        = thread.SIG_WAKEUP 
local SIG_CALLBACK      = thread.SIG_CALLBACK
local SIG_THREAD_DEAD   = thread.SIG_THREAD_DEAD
local SIG_NONE_PENDING  = thread.SIG_NONE_PENDINGlocal L = SkillUp.L

local main_h = nil
local mainId = nil
local publisher_h = nil
local publisherId = nil

local function main()
    local fname = "main()"
    local errorMsg = nil
    local DONE = false
    local addonName = skill:getAddonName()

    ------------------------------------------------------------/reload
    -- Create the publisher thread, publisher_h
    -----------------------------------------------------------------
    local clockInterval = 20
    publisher_h, publisherId, errorMsg = thread:create( clockInterval, 
                            function() 
                                publish:skillUp() 
                            end )
    if publisher_h == nil then
        local st = utils:simplifyStackTrace( debugstack() )
        errorMsg = sprintf("%s in %s.\n%s ", errorMsg, fname, st )
        handleError( addonName, errorMsg )
    end
    handler:setPublisherThread( publisher_h )

    while not DONE do
        thread:yield()
        local sigEntry, errorMsg = thread:getSignal()
        if sigEntry[1] == SIG_FAILURE then
            error( "Full Stack Trace: " )
        elseif sigEntry[1] == SIG_THREAD_DEAD then
            return sigEntry, errorMsg
        end

        local signal = sigEntry[1]
        if signal == SIG_TERMINATE then
            local wasSent, errorMsg = thread:sendSignal( publisher_h, SIG_TERMINATE )
            if wasSent == nil then
                error( errorMsg )
            end
            DONE = true
        end
    end
    utils:postMsg( sprintf("main_h terminated.\n"))
end

----------------------------------------------------------
-- Create the main thread. The publisher thread is created
-- inside the main thread's action routine.
----------------------------------------------------------
local errorMsg = nil
main_h, mainId, errorMsg = thread:create( 20, main )
if not main_h then 
    error( errorMsg )
end

SLASH_SKILLUP_COMMANDS1 = "/skillup"
SLASH_SKILLUP_COMMANDS2 = "/skill"

SlashCmdList["SKILLUP_COMMANDS"] = function( msg )
    local errorMsg  = nil
    local wasSent = nil

    if msg == nil then
        return
    end
    local msg = strupper( msg )

    if msg == "TERM" or msg == "TERMINATE" then
        wasSent, errorMsg = thread:sendSignal( main_h, SIG_TERMINATE)
        if wasSent == nil then
            error( errorMsg )
		end
        return
    end

    if msg == "DBG" then
        core:enableDebugging()
        DEFAULT_CHAT_FRAME:AddMessage( "Debugging Enabled", 1.0, 1.0, 0.0 )
        return
    end
    if msg == "NODBG" then
        core:disableDebugging()
        DEFAULT_CHAT_FRAME:AddMessage( "Debugging Disabled", 1.0, 1.0, 0.0 )
        return
    end
    if msg == "GLOBALS" then
        skill:printGlobalVars( skill:getAddonName() )
        return
    end

    local errorMsg = sprintf(L["INVALID_COMMAND_OPTION"])
    DEFAULT_CHAT_FRAME:AddMessage( errorMsg , 1.0, 1.0, 0.0 )
end
local fileName = "SkillUpMain.lua"
if core:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( fileName, 0.0, 1.0, 1.0 )
end
