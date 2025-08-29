-- Core.lua (SkillUp)
-- UPDATED: 29 Aug 2025
-- Lua 5.0 / Classic 1.12-friendly

SkillUp = SkillUp or {}
SkillUp.Core = SkillUp.Core or {}
local core = SkillUp.Core

-- === tiny load-order helpers (Lua 5.0-safe) ===
SkillUp._load = SkillUp._load or { seen = {}, order = {} }

-- Mark a module as loaded
function SkillUp._mark(name)
    local t = SkillUp._load
    t.seen[name] = true
    tinsert(t.order, name)  -- Lua 5.0: prefer tinsert
end

-- Require that 'prev' was loaded before 'current'.
-- Returns true if OK; prints a red error and returns false otherwise.
function SkillUp._require(prev, current)
    local ok = SkillUp and SkillUp._load and SkillUp._load.seen[prev]
    if not ok then
        local cf = getglobal and getglobal("DEFAULT_CHAT_FRAME") or DEFAULT_CHAT_FRAME
        if cf and cf.AddMessage then
            cf:AddMessage("ERROR: "..current.." expected "..prev.." to be loaded first.", 1.0, 0.2, 0.2)
        end
        return false
    end
    return true
end

-- === core metadata & debugging toggles ===
local addonName = "SkillUp"
local DEBUGGING_ENABLED = true
local addonExpansionName = "Classic (Turtle WoW)"
local addonVersion = GetAddOnMetadata and GetAddOnMetadata("SkillUp", "Version") or "?"

function core:getAddonInfo()
    return addonName, addonVersion, addonExpansionName
end
function core:enableDebugging()  DEBUGGING_ENABLED = true  end
function core:disableDebugging() DEBUGGING_ENABLED = false end
function core:debuggingIsEnabled() return DEBUGGING_ENABLED end

SkillUp.Core.loaded = false
if SkillUp._mark then SkillUp._mark("Core") end
