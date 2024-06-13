--=================================================================================
-- Filename: SkillUp.lua
-- Date: 9 March, 2021
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 9 March, 2021
--=================================================================================
local ADDON_NAME, _ = ...

-- Register the table globally for other addon files to use
_G.SkillUp = SkillUp

-- Make the SkillUp table available to other files
SkillUp = SkillUp or {}
SkillUp.SkillUp = SkillUp.SkillUp or {}
skill = SkillUp.SkillUp

local sprintf     = _G.string.format


local UtilsLib = LibStub("UtilsLib")
local utils = UtilsLib
if not utils then return end

function skill:getAddonName()
    return ADDON_NAME
end

-- Helper function to recursively print table contents
local function printTable(t, indent)
    indent = indent or "   "
    for k, v in pairs(t) do
        if type(v) == "table" then
            local str = indent .. k .. ":"
            utils:postMsg(sprintf("%s\n", str ))
            printTable(v, indent .. "  ")
        else
            local str = indent .. k .. ": " .. tostring(v)
            utils:postMsg( sprintf("%s\n", str ))
        end
    end
end

-- Function to get all global variables for a specified addon
function skill:printGlobalVars(addonName)
    local globals = {}
    
    for k, v in pairs(_G) do
        -- Check if the variable name starts with the addon name
        if type(k) == "string" and k:find("^" .. addonName) then
            globals[k] = v
        end
    end
    
    printTable( globals )
end

