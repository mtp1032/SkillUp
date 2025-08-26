--------------------------------------------------------------------------------------
-- Core.lua
-- ORIGINAL DATE: 4 August, 2025

SkillUp = SkillUp or {}          -- Create or reuse global addon table
SkillUp.Core = SkillUp.Core or {} -- Sub-table for your module
local core = SkillUp.Core        -- Local alias for easier typing

local addonName = "SkillUp"

local DEBUGGING_ENABLED = true

local addonExpansionName = "Classic (Turtle WoW)"
local addonVersion = GetAddOnMetadata( "SkillUp", "Version")

function core:getAddonInfo()
    return addonName, addonVersion, addonExpansionName 
end
function core:enableDebugging()
    DEBUGGING_ENABLED = true
end
function core:disableDebugging() 
    DEBUGGING_ENABLED = false
end
function core:debuggingIsEnabled()
    return DEBUGGING_ENABLED
end

-- Optional: debug ping so you can see when this file loads
if SkillUp.Core and SkillUp.Core.debuggingIsEnabled and SkillUp.Core.debuggingIsEnabled() then
    DEFAULT_CHAT_FRAME:AddMessage("Core.lua loaded", 0, 1, 0 )
end
