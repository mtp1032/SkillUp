-- EventHandler.lua (SkillUp)
-- UPDATED: 29 Aug 2025
-- Lua 5.0 / Classic 1.12-friendly

SkillUp = SkillUp or {}
SkillUp.EventHandler = SkillUp.EventHandler or {}

local ADDON_FOLDER = "SkillUp"  -- fallback; will be overwritten by arg1 on ADDON_LOADED

local core   = SkillUp.Core
local scroll = SkillUp.ScrollMessage
local L      = SkillUp.Localizations

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

-- Warn once if ScrollMessage isn't ready, but DO NOT return early.
local _scrollWarned = false
local function ensureScroll()
    if SkillUp and SkillUp.ScrollMessage and SkillUp.ScrollMessage.loaded then
        if not scroll then scroll = SkillUp.ScrollMessage end
        return true
    end
    if not _scrollWarned then
        local cf = (getglobal and getglobal("DEFAULT_CHAT_FRAME")) or DEFAULT_CHAT_FRAME
        if cf and cf.AddMessage then
            cf:AddMessage("ERROR: ScrollMessage.lua not loaded (continuing).", 1.0, 0.2, 0.2)
        end
        _scrollWarned = true
    end
    return false
end

-- ========== State (for deltas & de-dupe) ==========
local lastMoney = nil           -- updated on each PLAYER_MONEY
local lastLootMsgTime = 0       -- time of last CHAT_MSG_LOOT (for coin de-dupe)
local DEDUPE_WINDOW = 0.25      -- seconds; suppress $ line if loot just fired

-- ========== Frame / Events ==========
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")               -- fallback in case ADDON_LOADED filter misses
-- f:RegisterEvent("PLAYER_MONEY")               -- money delta
-- f:RegisterEvent("CHAT_MSG_LOOT")              -- localized text
f:RegisterEvent("CHAT_MSG_SKILL")             -- localized text
f:RegisterEvent("CHAT_MSG_COMBAT_XP_GAIN")    -- localized text

local printedLoaded = false
local function printLoadedOnce()
    if printedLoaded then return end
    printedLoaded = true
    local cf = (getglobal and getglobal("DEFAULT_CHAT_FRAME")) or DEFAULT_CHAT_FRAME
    if not (cf and cf.AddMessage) then return end
    local line = (L and L["ADDON_LOADED_MESSAGE"]) or "SkillUp loaded"
    cf:AddMessage(line)
end

f:SetScript("OnEvent", function()
    local e  = event
    local a1 = arg1

    -- Bootstrap: capture identifiers, print loaded message
    if e == "ADDON_LOADED" then
        -- Cache the actual folder/.toc name Blizzard passes
        SkillUp.AddonName = a1 or SkillUp.AddonName or ADDON_FOLDER

        -- Capture Title/Version/Expansion if available
        if type(GetAddOnMetadata) == "function" then
            local t = GetAddOnMetadata(SkillUp.AddonName, "Title")
            if t and t ~= "" then SkillUp.AddonTitle = t end
            local v = GetAddOnMetadata(SkillUp.AddonName, "Version")
            if v and v ~= "" then SkillUp.AddonVersion = v end
            local x = GetAddOnMetadata(SkillUp.AddonName, "X-Expansion")
            if x and x ~= "" then SkillUp.AddonExpansion = x end
        end
        SkillUp.AddonTitle     = SkillUp.AddonTitle or SkillUp.AddonName
        SkillUp.AddonVersion   = SkillUp.AddonVersion or ""
        SkillUp.AddonExpansion = SkillUp.AddonExpansion or ""

        if a1 == SkillUp.AddonName then
            if GetMoney then lastMoney = GetMoney() end
            local msg = string.format("%s %s (%s)", a1, SkillUp.AddonVersion, SkillUp.AddonExpansion )
            DEFAULT_CHAT_FRAME:AddMessage( msg )
        end
        f:UnregisterEvent( "ADDON_LOADED")
        return
    end

    -- Backstop: PLAYER_LOGIN always fires after UI init; print if we missed earlier.
    if e == "PLAYER_LOGIN" then
        if lastMoney == nil and GetMoney then lastMoney = GetMoney() end
        -- printLoadedOnce()
        return
    end

    -- Message-style events: pass Blizzard-localized text straight through
    if e == "CHAT_MSG_COMBAT_XP_GAIN" or e == "CHAT_MSG_SKILL" then
        if ensureScroll() then
            scroll:eventMessage(e, a1)
        end
        return
    end

    if e == "CHAT_MSG_LOOT" then
        lastLootMsgTime = (GetTime and GetTime()) or 0
        if ensureScroll() then
            scroll:eventMessage(e, a1)
        end
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
        local nowT = (GetTime and GetTime()) or 0
        local recentLoot = (nowT - lastLootMsgTime) <= DEDUPE_WINDOW
        if recentLoot and delta > 0 then
            return
        end

        local msg
        if delta > 0 then
            msg = (L and L.MONEY_GAINED and string.format(L.MONEY_GAINED, formatMoney(delta)))
                  or ("Money Gained: " .. formatMoney(delta))
        else
            msg = (L and L.MONEY_SPENT and string.format(L.MONEY_SPENT, formatMoney(-delta)))
                  or ("Money Spent: " .. formatMoney(-delta))
        end

        if ensureScroll() then
            scroll:eventMessage(e, msg)
        end
        return
    end
end)

SkillUp.EventHandler.loaded = true
if SkillUp._mark then SkillUp._mark("EventHandler") end
