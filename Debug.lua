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
local debuggingIsEnabled = true
local L = ns.Locales.L
ns.Debug = ns.Debug or {} 
local dbg = ns.Debug
-----------------------------------------------------------------
-- Private (local) functions
-----------------------------------------------------------------
local function getprefix(stackTrace)
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
function dbg:prefix()
    stackTrace = stackTrace or debugstack(3) 

    local sourceFile, lineNumber =
        stackTrace:match("[\\/]([^\\/:]+):(%d+)")

    if not sourceFile or not lineNumber then
        return "[Unknown:0] "
    end
    local prefix = string.format("[%s:%s] ", sourceFile, lineNumber)
    return prefix
end

function dbg:print(...)
    if not dbg:isDebuggingEnabled() then
        return
    end
    local message = getprefix(debugstack(2)) .. formatMessage(...)
    -- print(message)
    return message
end

function dbg:isDebuggingEnabled()
    return ns.Locales.debuggingIsEnabled
end

function dbg:enableDebugging()
    ns.Locales.debuggingIsEnabled = true
end

function dbg:disableDebugging()
    ns.Locales.debuggingIsEnabled = false
end

ns.Debug.loaded = true
if dbg:isDebuggingEnabled() then
    print("[SkillUp] Debug.lua loaded")
end 

----------------------------- TESTS -----------------------------
-- local function foo()
--     dbg:print("Called by foo()")
-- end
-- local function bar()
--     dbg:print("Called by bar()")
-- end
-- local function fooBar()
--     print("In fooBar()")
--     foo()
--     bar()
-- end

-- fooBar()
