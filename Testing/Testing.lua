--------------------------------------------------------------------------------------
-- FILE: Testing.lua
-- AUTHOR: Michael Peterson
-- REWRITE: October 2026
--------------------------------------------------------------------------------------
local ADDON_NAME, ns = ...

if not ns.SkillUp.loaded then
    error("[SkillUp] SkillUp.lua not loaded")
    return
end
local TESTING_ENABLED = true
if not TESTING_ENABLED then
    return
end

ns.Testing = ns.Testing or {}

local dbg       = ns.Debug
local L         = ns.Locales.L

local function oneLevelDeep( st )
    dbg:print("Called by oneLevelDeep()", st )
end
local function twoLevelsDeep( st)
    dbg:print("Called by twoLevelsDeep()", st )
end
local function stackTest(testString)
    dbg:print( L["TEST_MSG"])
    oneLevelDeep(testString)
    twoLevelsDeep(testString)
end
local function unitTest_DebugServices()
    local isEnabled = dbg:disableDebugging()
    if isEnabled then
        error("[Testing.lua] FAIL: Debugging was expected to be disabled")
        return
    end
    dbg:enableDebugging()

    stackTest(L["TEST_MSG"])
end
local isDebuggingEnabled = dbg:enableDebugging()
if not isDebuggingEnabled then
    error("[Testing.lua] FAIL: Debugging was expected to be enabled")
    return
end
unitTest_DebugServices()

ns.Testing.loaded = true
if dbg:isDebuggingEnabled() then
    dbg:print("[SkillUp] Testing.lua loaded.")
end

