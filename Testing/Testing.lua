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
ns.SkillUp.Testing = ns.SkillUp.Testing or {}

local test      = ns.SkillUp.Testing
local skillUp   = ns.SkillUp
local dbg       = ns.Debug
local L         = ns.Locales.L

local UNIT_TESTING_ENABLED = true

------------ UNIT TESTS ------------
if not UNIT_TESTING_ENABLED then
    return
end

local function oneLevelDeep( st )
    dbg:print("Called by foo()", st )
end
local function twoLevelsDeep( st)
    dbg:print("Called by bar()", st )
end
local function stackTest(testString)
    oneLevelDeep(testString)
    twoLevelsDeep(testString)
end

-- Debug Services
local function unitTest_DebugServices()
    dbg:disableDebugging()
    if dbg:isDebuggingEnabled() then
        error("[Testing.lua] Failed to disable debugging")
        return
    end

    dbg:print("[Testing.lua] Re-enabling debugging")
    dbg:enableDebugging()
    if not dbg:isDebuggingEnabled() then
        error("[Testing.lua] Failed to enable debugging")
        return
    end

    stackTest(L["TEST_MSG"])
end

unitTest_DebugServices()

ns.Testing.loaded = true
if dbg:isDebuggingEnabled() then
    print("[SkillUp] Testing.lua loaded.")
end

