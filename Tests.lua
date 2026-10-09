--------------------------------------------------------------------------------------
-- FILE: Tests.lua
-- AUTHOR: Michael Peterson
-- REWRITE: October 2026
--------------------------------------------------------------------------------------
local ADDON_NAME, ns = ...

if not ns.SkillUp.loaded then
    error("[SkillUp] SkillUp.lua not loaded")
    return
end
ns.Tests = ns.Tests or {}
local tests = ns.Tests

local dbg       = ns.Debug
local L         = ns.Locales.L

------------------- Local/private Functions -------------------
local function oneLevelDeep( msg )
    dbg:print("Called by oneLevelDeep()", msg )
end
local function twoLevelsDeep( msg )
    dbg:print("Called by twoLevelsDeep()", msg )
end
local function stackTest(testString)
    oneLevelDeep(testString)
    twoLevelsDeep(testString)
end

-- These tests assume that dbg:print() is available and functioning correctly
local function unitTestDebugServices()
    local savedEnabled = dbg:isDebuggingEnabled()
    local isEnabled = true
    dbg:print("[Tests.lua] Starting unitTestDebugServices()")

    isEnabled = dbg:enableDebugging()
    if isEnabled == false then
        error( dbg:print("[Tests.lua: FAIL] Debugging was expected to be enabled"))
    else
        dbg:print("[Tests.lua: PASSED] dbg:enableDebugging() worked as expected")
    end
    
    isEnabled = dbg:disableDebugging()
    if isEnabled == true then
        error( dbg:print("[Tests.lua: FAIL] Debugging was expected to be disabled"))
    else
        dbg:print("[Tests.lua: PASSED] dbg:disableDebugging() worked as expected")
    end

    stackTest(L["TEST_MSG"])

    -- Restore the original debugging state
    if savedEnabled then
    dbg:enableDebugging()
    else
        dbg:disableDebugging()
    end
end

function tests:runAllTests()
    unitTestDebugServices()
end

---------------------- RUN THE TESTS ----------------------
tests:runAllTests()

ns.Tests.loaded = true
if dbg:isDebuggingEnabled() then
    dbg:print("[SkillUp] Tests.lua loaded.")
end

