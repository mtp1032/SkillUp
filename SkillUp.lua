--------------------------------------------------------------------------------------
-- FILE: SkillUp.lua
-- AUTHOR: Michael Peterson
-- REWRITE: October 2026
--------------------------------------------------------------------------------------
local ADDON_NAME, ns = ...

if not ns.EnUS.loaded then
    error("[SkillUp] EnUS.lua not loaded")
    return
end

local core = ns.Core
local L    = ns.EnUS.L

------------------------------------------------------------
-- Message Types
------------------------------------------------------------
local SKILL = 1
local LOOT  = 2
local MONEY = 3

------------------------------------------------------------
-- Starting Positions (per message type)
------------------------------------------------------------
local START_POSITIONS = {
    [SKILL] = { x = 100,  y = 25,  dx = 4,  dy = 4 },
    [LOOT]  = { x = 100,  y = -25, dx = 4,  dy = 4 },
    [MONEY] = { x = -100, y = 25,  dx = -4, dy = 4 },
}

local function getStartingPositions(msgType)
    local p = START_POSITIONS[msgType]
    if not p then return 0, 0, 0, 0 end
    return p.x, p.dx, p.y, p.dy
end

------------------------------------------------------------
-- Frame Pool + Active Frames
------------------------------------------------------------
local framePool    = {}
local activeFrames = {}

local STACK_SPACING     = 28     -- vertical spacing between messages
local MESSAGE_DURATION  = 3.0    -- seconds before fade-out
local SCROLL_SPEED      = 40     -- upward scroll speed (pixels/sec)

------------------------------------------------------------
-- Create a new floating text frame
------------------------------------------------------------
local function createNewFrame()
    local f = CreateFrame("Frame", nil, UIParent)
    f:SetSize(5, 5)

    f.Text = f:CreateFontString(nil, "OVERLAY")
    f.Text:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
    f.Text:SetPoint("CENTER")
    f.Text:SetTextColor(1, 0, 0)
    f.Text:SetShadowOffset(1, -1)

    f.timeElapsed = 0
    f.startX = 0
    f.startY = 0

    return f
end

local function releaseFrame(f)
    f:SetScript("OnUpdate", nil)
    f:Hide()
    f.Text:SetText("")
    table.insert(framePool, f)
end

local function acquireFrame()
    local f = table.remove(framePool)
    if not f then
        f = createNewFrame()
    end
    f:Show()
    return f
end

------------------------------------------------------------
-- Conveyor Animation (single OnUpdate for all frames)
------------------------------------------------------------
local conveyor = CreateFrame("Frame")
conveyor:SetScript("OnUpdate", function(_, elapsed)
    for i = #activeFrames, 1, -1 do
        local f = activeFrames[i]

        f.timeElapsed = f.timeElapsed + elapsed

        -- Correct extraction of x,y offsets
        local _, _, _, x, y = f:GetPoint()

        -- Scroll upward
        f:SetPoint("CENTER", x, y + (SCROLL_SPEED * elapsed))

        -- Fade out
        local alpha = 1 - (f.timeElapsed / MESSAGE_DURATION)
        f:SetAlpha(math.max(alpha, 0))

        -- Remove when done
        if f.timeElapsed >= MESSAGE_DURATION then
            table.remove(activeFrames, i)
            releaseFrame(f)
        end
    end
end)

------------------------------------------------------------
-- Display a new message (stacking + scrolling)
------------------------------------------------------------
local function displayMsg(msgType, msg)
    local f = acquireFrame()
    f.Text:SetText(msg)

    local startX, dx, startY, dy = getStartingPositions(msgType)

    -- Dynamic stacking: each new message is placed lower
    local dynamicY = startY - (#activeFrames * STACK_SPACING)

    f.startX = startX
    f.startY = dynamicY
    f.timeElapsed = 0
    f:SetAlpha(1)

    f:ClearAllPoints()
    f:SetPoint("CENTER", startX, dynamicY)

    table.insert(activeFrames, f)
end

------------------------------------------------------------
-- Event Handling
------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_SKILL")
eventFrame:RegisterEvent("CHAT_MSG_LOOT")
eventFrame:RegisterEvent("CHAT_MSG_MONEY")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    local msg = ...

    if event == "ADDON_LOADED" and msg == ADDON_NAME then
        print(L["ADDON_LOADED_MSG"])
        eventFrame:UnregisterEvent("ADDON_LOADED")
        return
    end

    if event == "CHAT_MSG_LOOT" then
        displayMsg(LOOT, msg)

    elseif event == "CHAT_MSG_SKILL" then
        displayMsg(SKILL, msg)

    elseif event == "CHAT_MSG_MONEY" then
        displayMsg(MONEY, msg)
    end
end)

if core:debuggingIsEnabled() then
    print("[SkillUp] SkillUpMain.lua loaded.")
end
