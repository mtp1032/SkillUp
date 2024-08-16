--------------------------------------------------------------------------------------
-- SkillUpMain.lua   
-- AUTHOR: Michael Peterson 
-- ORIGINAL DATE: 16 August, 2024
--------------------------------------------------------------------------------------
-- Ensure SkillUp namespace exists
local ADDON_NAME, _ = ...

-- Make the SkillUp table available to other files
SkillUp = SkillUp or {}
SkillUp.SkillUpMain = SkillUpMain or {}
local main = SkillUp.SkillUpMain

local EnUS_SkillUp = LibStub("EnUS_SkillUp")
local L = EnUS_SkillUp.L

local DEBUG_ENABLED = true

local SKILL	= 1
local LOOT	= 2
local MONEY	= 3

local SKILL_STARTX = 100
local SKILL_XDELTA = 4
local SKILL_STARTY = 25
local SKILL_YDELTA = 4

local LOOT_STARTX = SKILL_STARTX
local LOOT_XDELTA = SKILL_XDELTA
local LOOT_STARTY = -SKILL_STARTY
local LOOT_YDELTA = SKILL_YDELTA

local MONEY_STARTX = -SKILL_STARTX
local MONEY_XDELTA = -4
local MONEY_STARTY = SKILL_STARTY
local MONEY_YDELTA =  4


-- local count = 0
local function getStartingPositions( msgType )
	if msgType == SKILL then 
		-- if count == 1 then
		-- 	SKILL_STARTX = 70
		-- 	count = 0
		-- else
		-- 	SKILL_STARTX = 50
		-- 	count = 1
		-- end
		return SKILL_STARTX, SKILL_XDELTA, SKILL_STARTY, SKILL_YDELTA
	end

	if msgType == MONEY then
		return MONEY_STARTX, MONEY_XDELTA, MONEY_STARTY, MONEY_YDELTA
	end 
	if msgType == LOOT then
		return LOOT_STARTX, LOOT_XDELTA, LOOT_STARTY, LOOT_YDELTA
	end
	return nil, nil, nil, nil
end

local framePool = {}

local TICKS_PER_INTERVAL = 4
local function createNewFrame()
	local f = CreateFrame("Frame", nil, UIParent)
	f:SetSize(5, 5)
	f:SetPoint("CENTER", 0, 0)

	-- Create a FontString to hold the text
	f.Text = f:CreateFontString(nil, "OVERLAY")

	-- Set the font, size, and outline
	f.Text:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")

	-- Center the text within the frame
	f.Text:SetPoint("CENTER")

	-- Set the text color to red
	f.Text:SetTextColor(1.0, 0.0, 0.0)

	-- Set the shadow offset to create a black shadow (simulating Blizzard's combat text style)
	f.Text:SetShadowOffset(1, -1)

	-- Initialize the text content (this will be updated dynamically)
	f.Text:SetText("")

	-- Additional properties for managing the frame's behavior
	f.Alpha = 1.0
	f.TotalTicks = 0
	f.TicksPerFrame = TICKS_PER_INTERVAL
	f.TicksRemaining = f.TicksPerFrame

	return f
end
local function releaseFrame(f) 
	f.Text:SetText("")
	f:Hide()
	table.insert(framePool, f)
end
local function initFramePool()
	local f = createNewFrame()
	table.insert(framePool, f)
end
local function acquireFrame()
	local f = table.remove(framePool)
	if f == nil then 
		f = createNewFrame()
	end
	f:Show()
	return f
end

local function scrollText(f, startX, xDelta, startY, yDelta)
	local xPos = startX
	local yPos = startY

	-- Speed of scrolling (you can adjust this value)
	local scrollSpeed = 10 -- pixels per second
	local curveIntensity = 0.02 -- Intensity of the curve

	-- Duration for the text to stay on screen (in seconds)
	local duration = 3

	-- Time passed since the text started scrolling
	local timeElapsed = 0

	f:SetScript("OnUpdate", 
	function(f, elapsed)
		-- Update the total time elapsed
		timeElapsed = timeElapsed + elapsed

		-- Calculate the distance to move based on time elapsed
		local distance = scrollSpeed * elapsed

		-- Update horizontal position
		xPos = xPos + (xDelta * distance)

		-- Create a curved effect by adjusting the vertical position
		yPos = startY + (curveIntensity * (xPos - startX)^2)

		-- Move the text to the new position
		f:ClearAllPoints()
		f:SetPoint("CENTER", xPos, yPos)

		-- Calculate the remaining alpha based on the elapsed time
		local remainingAlpha = 1 - (timeElapsed / duration)
		f:SetAlpha(math.max(remainingAlpha, 0))

		-- Check if the text should be fully faded out and removed
		if timeElapsed >= duration then
			f:SetScript("OnUpdate", nil)
			f.Text:SetText("")
			f:ClearAllPoints()
			f:SetPoint("CENTER", 0, 0)
			releaseFrame(f)
		end
	end)
end
local function displayMsg( typeEntry, msg )
	local f = acquireFrame()
	f.Text:SetText( msg )

	local startX, xDelta, startY, yDelta = getStartingPositions( typeEntry )
	local xPos = startX
	local yPos = startY

	f:ClearAllPoints()
	f:SetPoint("CENTER", xPos, yPos)

	scrollText(f, xPos, xDelta, yPos, yDelta)
end

initFramePool()

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_SKILL")
eventFrame:RegisterEvent("CHAT_MSG_LOOT")
eventFrame:RegisterEvent("CHAT_MSG_MONEY")

local function OnEvent( self, event, ... )
	local args = ...
	local skillupType = nil

	if event == "ADDON_LOADED" and args == ADDON_NAME then
		DEFAULT_CHAT_FRAME:AddMessage( L["ADDON_LOADED_MSG"], 1.0, 1.0, 0)
		
		eventFrame:UnregisterEvent("ADDON_LOADED")  
		return
	end

	if event == "CHAT_MSG_LOOT" then
		displayMsg( LOOT, args )

	elseif event == "CHAT_MSG_SKILL" then
		displayMsg( SKILL, args )

	elseif event == "CHAT_MSG_MONEY" then
		displayMsg( MONEY, args )
	end
end
eventFrame:SetScript( "OnEvent", OnEvent )

local fileName = "SkillUpMain.lua"
if DEBUG_ENABLED then
	DEFAULT_CHAT_FRAME:AddMessage( fileName .. " loaded.", 0.0, 1.0, 1.0 )
end