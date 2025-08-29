-- EventHandler.lua (SkillUp)
-- UPDATED: 29 Aug 2025
-- Lua 5.0 / Classic 1.12-friendly

SkillUp = SkillUp or {}
SkillUp.EventHandler = SkillUp.EventHandler or {}

-- Robust guard: don't index .loaded on a nil table
if not (SkillUp.ScrollMessage and SkillUp.ScrollMessage.loaded) then
    local cf = getglobal and getglobal("DEFAULT_CHAT_FRAME") or DEFAULT_CHAT_FRAME
    if cf and cf.AddMessage then
        cf:AddMessage("ERROR: ScrollMessage.lua not loaded.", 1.0, 0.2, 0.2)
    end
    return -- Stop execution to prevent further errors
end

-- Positive dependency check
if SkillUp._require and not SkillUp._require("ScrollMessage", "EventHandler") then
    return
end

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
f:RegisterEvent("PLAYER_MONEY")               -- money delta
f:RegisterEvent("CHAT_MSG_LOOT")              -- localized text
f:RegisterEvent("CHAT_MSG_SKILL")             -- localized text
f:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")    -- localized text

f:SetScript("OnEvent", function()
    local e  = event
    local a1 = arg1

    -- Bootstrap
    if e == "ADDON_LOADED" and a1 == "SkillUp" then
        if GetMoney then lastMoney = GetMoney() end

        if core and core.getAddonInfo then
            local addonName, addonVersion, addonExpansionName = core:getAddonInfo()
            local msg = string.format("%s v%s (%s) loaded.", addonName or "SkillUp", addonVersion or "?", addonExpansionName or "")
            local cf = getglobal and getglobal("DEFAULT_CHAT_FRAME") or DEFAULT_CHAT_FRAME
            if cf and cf.AddMessage then cf:AddMessage(msg, 0, 1, 0) end
        end

        f:UnregisterEvent("ADDON_LOADED")
        return
    end

    -- Message-style events: pass Blizzard-localized text straight through
    if e == "CHAT_MSG_COMBAT_XP_GAIN" or e == "CHAT_MSG_SKILL" then
        scroll:eventMessage(e, a1)
        return
    end

    if e == "CHAT_MSG_LOOT" then
        lastLootMsgTime = GetTime and GetTime() or 0
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
        local nowT = GetTime and GetTime() or 0
        local recentLoot = (nowT - lastLootMsgTime) <= DEDUPE_WINDOW
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

SkillUp.EventHandler.loaded = true
if SkillUp._mark then SkillUp._mark("EventHandler") end
