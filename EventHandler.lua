-- EventHandler.lua (SkillUp)
-- UPDATED: 26 Aug 2025
-- Lua 5.0 / Classic 1.12-friendly

SkillUp = SkillUp or {}
SkillUp.EventHandler = SkillUp.EventHandler or {}

local core   = SkillUp.Core
local scroll = SkillUp.ScrollMessage

-- ========== Utilities ==========
local function formatMoney(copper)
    if type(copper) ~= "number" or copper <= 0 then return "0g 0s 0c" end
    local g = math.floor(copper / 10000)
    local s = math.floor((copper - g * 10000) / 100)
    local c = copper - g * 10000 - s * 100
    local out = ""
    if g > 0 then out = out .. g .. "g " end
    if s > 0 or g > 0 then out = out .. s .. "s " end
    return out .. c .. "c"
end

-- ========== State (for deltas & de-dupe) ==========
local lastMoney = nil           -- updated on each PLAYER_MONEY
local lastLootMsgTime = 0       -- time of last CHAT_MSG_LOOT (for coin de-dupe)
local DEDUPE_WINDOW = 0.25      -- seconds; suppress $ line if loot just fired

-- ========== Frame / Events ==========
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
-- f:RegisterEvent("PLAYER_MONEY")               -- no arg1
-- f:RegisterEvent("CHAT_MSG_LOOT")              -- arg1: localized text
f:RegisterEvent("CHAT_MSG_SKILL")             -- arg1: localized text
f:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")    -- arg1: localized text

f:SetScript("OnEvent", function()
    local e  = event
    local a1 = arg1

    -- Bootstrap
    if e == "ADDON_LOADED" and a1 == "SkillUp" then
        if GetMoney then lastMoney = GetMoney() end

        -- Optional: nice loaded line (keep or localize as you wish)
        if core and core.getAddonInfo then
            local addonName, addonVersion, addonExpansionName = core:getAddonInfo()
            local msg = string.format("%s v%s (%s) loaded.", addonName, addonVersion, addonExpansionName)
            if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(msg, 0, 1, 0) end
        end

        f:UnregisterEvent("ADDON_LOADED")
        return
    end

    -- Message-style events: pass Blizzard-localized text straight through
    if e == "CHAT_MSG_COMBAT_XP_GAIN" or
       e == "CHAT_MSG_SKILL" or
       e == "CHAT_MSG_LOOT" then

        scroll:eventMessage(e, a1)

        return
    end

    -- Money delta (fires on loot, vendor, repair, mail, etc.)
    if e == "PLAYER_MONEY" then
        if not GetMoney then return end
        local now = GetMoney()
        if lastMoney == nil then
            lastMoney = now
            return
        end

        local delta = now - lastMoney
        lastMoney = now
        if delta == 0 then return end

        -- If we just showed a loot line (likely coin loot), suppress duplicate "Money Gained"
        local recentLoot = (GetTime and (GetTime() - lastLootMsgTime) or 1) <= DEDUPE_WINDOW
        if recentLoot and delta > 0 then
            return
        end

        local msg
        if delta > 0 then
            msg = "Money Gained: " .. formatMoney(delta)
        else
            msg = "Money Spent: " .. formatMoney(-delta)
        end

        scroll:eventMessage(e, msg)
        return
    end
end)

-- Optional: file-load ping (respects Core debug style)
if core and ((core.debuggingIsEnabled and core:debuggingIsEnabled()) or 
    (core.debug and core.debug == true)) then
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("EventHandler.lua loaded", 0, 1, 0) end
end
