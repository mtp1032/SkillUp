--------------------------------------------------------------------------------------
-- FILE: CommandLine.lua
--------------------------------------------------------------------------------------
local ADDON_NAME, ns = ...

local dbg = ns.Debug
local test = ns.Tests

SLASH_SKILLUP1 = "/skill"
SlashCmdList["SKILLUP"] = function(message)
    local command, argument = (message or ""):match("^(%S+)%s*(.-)%s*$")
    command = command and command:lower()
    argument = argument and argument:lower()

    if command == "debug" and argument == "enable" then
        dbg:enableDebugging()
        print("[SkillUp] Debugging enabled.")
    elseif command == "debug" and argument == "disable" then
        dbg:disableDebugging()
        print("[SkillUp] Debugging disabled.")
    elseif command == "run" and argument == "unittest" then
        test:runAllTests()
    else
        print("[SkillUp] Usage: /skill debug [enable|disable] or /skill run unittest")
    end
end

ns.CommandLine = ns.CommandLine or {}
ns.CommandLine.loaded = true
