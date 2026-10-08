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
Skillup.Testing = Skillup.Testing or {}
local test      = Skillup.Testing
local skillUp   = ns.SkillUp
local dbg       = ns.Debug
local L         = ns.Locales.L

-- Debug tests
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
------------- RUN TESTS -------------
dbg:print("Starting tests")

-- Does the API work?
dbg:disableDebugging()
if dbg:isDebuggingEnabled() then
    error("[SkillUp] Failed to disable debugging")
    return
end

dbg:enableDebugging()
if not dbg:isDebuggingEnabled() then
    error("[SkillUp] Failed to enable debugging")
    return
end


stackTest(L["TEST_MSG"])
