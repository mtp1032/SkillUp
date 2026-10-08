--------------------------------------------------------------------------------------
-- FILE: Debug.lua
-- AUTHOR: Michael Peterson
-- REWRITE: October 2026
--------------------------------------------------------------------------------------
local ADDON_NAME, ns = ...
if not ns.Locales.loaded then 
    error("[SkillUp] Locales.lua not loaded")
    return
else
    print("[SkillUp] Locales.lua loaded")
end
local L = ns.Locales.L
ns.Debug = ns.Debug or {} 
local dbg = ns.Debug

local dbgIsEnabled = true

-----------------------------------------------------------------
-- Private (local) functions
-----------------------------------------------------------------
local function getPrefix(stackTrace)
    stackTrace = stackTrace or debugstack(3)

    local sourceFile, lineNumber =
        stackTrace:match("[\\/]([^\\/:]+):(%d+)")

    if not sourceFile or not lineNumber then
        return "[Unknown:0] "
    end
    local prefix = string.format("[%s:%s] ", sourceFile, lineNumber)
    return prefix
end

local function formatMessage(...)
    local values = {}
    local valueCount = select("#", ...)

    for index = 1, valueCount do
        local value = select(index, ...)

        if value == nil then
            value = "<nil>"
        elseif type(value) ~= "string" then
            value = tostring(value)
        end

        values[#values + 1] = value
    end
    return table.concat(values, " ")
end

-----------------------------------------------------------------
-- Public functions
-----------------------------------------------------------------
function dbg:print(...)
    if not dbgIsEnabled then
        return
    end
    local message = getPrefix(debugstack(2)) .. formatMessage(...)
    -- print(message)
    return message
end

function dbg:isDebuggingEnabled()
    return dbgIsEnabled
end

function dbg:enableDebugging()
    dbgIsEnabled = true
    return dbgIsEnabled
end

function dbg:disableDebugging()
    dbgIsEnabled = false
    return dbgIsEnabled
end

ns.Debug.loaded = true
if dbg:isDebuggingEnabled() then
    print("[SkillUp] Debug.lua loaded.")
end
