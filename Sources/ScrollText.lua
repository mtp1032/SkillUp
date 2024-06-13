--------------------------------------------------------------------------------------
-- ScrollText.lua 
-- AUTHOR: Michael Peterson 
-- ORIGINAL DATE: 16 April, 2023
--------------------------------------------------------------------------------------
-- Ensure SkillUp namespace exists
local ADDON_NAME, _ = ...

-- Make the SkillUp table available to other files
SkillUp = SkillUp or {}
SkillUp.ScrollText = SkillUp.ScrollText or {}
scroll = SkillUp.ScrollText

local L = SkillUp.L
local sprintf = _G.string.format

local UtilsLib = LibStub("UtilsLib")
local utils = UtilsLib
if not utils then return end

local thread = LibStub:GetLibrary( "WoWThreads-1.0" )
if not thread then return end

-- set the color
	-- f.Text:SetTextColor( 1.0, 1.0, 1.0 )  -- white
	-- f.Text:SetTextColor( 0.0, 1.0, 0.0 )  -- green
	-- f.Text:SetTextColor( 1.0, 1.0, 0.0 )  -- yellow
	-- f.Text:SetTextColor( 0.0, 1.0, 1.0 )  -- turquoise
	-- f.Text:SetTextColor( 0.0, 0.0, 1.0 )  -- blue
	-- f.Text:SetTextColor( 1.0, 0.0, 0.0 )  -- red

local DAMAGE_EVENT  = 1
local HEALING_EVENT	= 2
local AURA_EVENT    = 3
local MISS_EVENT	= 4

local TICKS_PER_INTERVAL = 4

local framePool = {}

local count = 1
local function createNewFrame()
	local f = CreateFrame("Frame", nil, UIParent)
	f:SetSize(5, 5)
	f:SetPoint( "CENTER", 0, 0 )
	f.Text = f:CreateFontString("Bazooka")
	f.Text:SetFont( "Interface\\Addons\\SkillUp\\LibFonts\\Bazooka.ttf", 16 )
	f.Text:SetPoint( "CENTER" )
	f.Text:SetJustifyH("LEFT")
	f.Text:SetJustifyV("TOP")
	f.Text:SetText("")

	f.IsCrit 			= false
	f.alpha				= 0.03
	f.TotalTicks 		= 0
	f.TicksPerFrame 	= TICKS_PER_INTERVAL
	f.TicksRemaining 	= f.TicksPerFrame
  return f
end
local function releaseFrame( f ) 
    f.Text:SetText("")
	f:Hide()
    table.insert( framePool, f )
end
local function initFramePool()
  local f = createNewFrame()
  table.insert( framePool, f )
end
local function acquireFrame()
  	local f = table.remove( framePool )
  	if f == nil then 
      	f = createNewFrame() 
    end
	f:Show()
    return f
end

local DMG_STARTX 	= 50
local DMG_XDELTA	= 0
local DMG_STARTY 	= 25
local DMG_YDELTA	= 3
local HEAL_STARTX 	= -DMG_STARTX
local HEAL_XDELTA	= 0
local HEAL_STARTY 	= DMG_STARTY
local HEAL_YDELTA	= 3

local AURA_STARTX 	= -600
local AURA_XDELTA	= 0
local AURA_STARTY 	= 200
local AURA_YDELTA	= 3

local MISS_STARTX 	= 0
local MISS_XDELTA	= 0
local MISS_STARTY 	= 100
local MISS_YDELTA	= 3

local function getStartingPositions( combatType )
  
	if combatType == DAMAGE_EVENT then 
		return DMG_STARTX, DMG_XDELTA, DMG_STARTY, DMG_YDELTA
	end
	if combatType == HEALING_EVENT then
		return HEAL_STARTX, HEAL_XDELTA, HEAL_STARTY, HEAL_YDELTA
	end 
	if combatType == AURA_EVENT then
		return AURA_STARTX, AURA_XDELTA, AURA_STARTY, AURA_YDELTA
	end

	if combatType == MISS_EVENT then    -- -400 pixels left of center, 200 pixels above center
	return MISS_STARTX, MISS_XDELTA, MISS_STARTY, MISS_YDELTA
	end
end

local function scrollText(f, startX, xDelta, startY, yDelta )
	local xPos = startX
	local yPos = startY

	local missString = f.Text:GetText()
	f:SetScript("OnUpdate", 
	function( f )
		f.TicksRemaining = f.TicksRemaining - 1
		if f.TicksRemaining > 0 then
			return
		end
		f.TicksRemaining = TICKS_PER_INTERVAL
		f.TotalTicks = f.TotalTicks + 1

		if f.TotalTicks == 4 then 
			xPos = xPos + xDelta
			yPos = yPos + yDelta
		elseif f.TotalTicks == 10 then 
			xPos = xPos + xDelta
			yPos = yPos + yDelta
		elseif f.TotalTicks == 20 then
			xPos = xPos + xDelta
			yPos = yPos + yDelta
		elseif f.TotalTicks == 30 then 
			xPos = xPos + xDelta
			yPos = yPos + yDelta
		elseif f.TotalTicks == 40 then
			xPos = xPos + xDelta
			yPos = yPos + yDelta
		end	

		if f.TotalTicks <=  20 then 	-- move the frame
			xPos = xPos + xDelta
			yPos = yPos + yDelta
			f:ClearAllPoints()
			f:SetPoint( "CENTER", xPos, yPos )
		end
		if f.TotalTicks > 20 then	-- reset and release the frame
			f.TotalTicks = 0
			f.Text:SetText("")
			if f.IsCrit then
				f.Text:SetFont( "Interface\\Addons\\SkillUp\\LibFonts\\Bazooka.ttf", 16 )
			end
			f:ClearAllPoints()
			f:SetPoint( "CENTER", 0, 0 )
			releaseFrame(f)
		elseif f.TotalTicks < 50 then
			f:ClearAllPoints()
			f:SetPoint( "CENTER", xPos, yPos )
		end
	end)
end

function scroll:damageEntry( isCrit, floatingText )
	local f = acquireFrame()
	f.Text:SetTextColor( 1.0, 0.0, 0.0 )	-- red
	f.Text:SetText( floatingText )
	f.IsCrit = isCrit

	local startX, xDelta, startY, yDelta = getStartingPositions( DAMAGE_EVENT )
	local xPos 		= startX
	local yPos 		= startY
	f.Text:SetFont( "Interface\\Addons\\SkillUp\\LibFonts\\Bazooka.ttf", 16 )
	if f.IsCrit then
		f.Alpha	= 0.9
		f.Text:SetFont( "Interface\\Addons\\SkillUp\\LibFonts\\Bazooka.ttf", 32 )
		yDelta 	= 6
		xDelta	= 6
		xPos	= xPos + 25
	end

	f:ClearAllPoints()
	f:SetPoint("CENTER", xPos, yPos )

	scrollText(f, xPos, xDelta, yPos, yDelta )
end
function scroll:healEntry( isCrit, floatingText )
	local f = acquireFrame()
	f.Text:SetTextColor( 0.0, 1.0, 0.0 )  -- green
	f.Text:SetText( floatingText )
	f.IsCrit 		= isCrit

	local startX, xDelta, startY, yDelta = getStartingPositions( HEALING_EVENT )
	local xPos 		= startX
	local yPos 		= startY
	f.Text:SetFont( "Interface\\Addons\\SkillUp\\LibFonts\\Bazooka.ttf", 16 )
	if f.IsCrit then
		f.Alpha	= 0.9
		f.Text:SetFont( "Interface\\Addons\\SkillUp\\LibFonts\\Bazooka.ttf", 32 )
		yDelta 	= 6
		xDelta	= -6
		xPos	= xPos + 25
	end

	f:ClearAllPoints()
	f:SetPoint("CENTER", xPos, yPos )

	scrollText(f, xPos, xDelta, yPos, yDelta )
end
function scroll:auraEntry( auraStr )
	local f = acquireFrame()
	f.Text:SetFont( "Interface\\Addons\\SkillUp\\LibFonts\\Bazooka.ttf", 16 )
	f.Text:SetTextColor( 1.0, 1.0, 0.0 )  -- yellow
	f.Text:SetText( auraStr )

	local startX, xDelta, startY, yDelta = getStartingPositions( AURA_EVENT )
	local xPos 		= startX 
	local yPos 		= startY

	f:ClearAllPoints()
	f:SetPoint("CENTER", xPos, 200 )

	scrollText(f, xPos, xDelta, startY, yDelta)
end
function scroll:missEntry( missString )
	local f = acquireFrame()
	f.Text:SetFont( "Interface\\Addons\\SkillUp\\LibFonts\\Bazooka.ttf", 24 )
	f.Text:SetTextColor( 1.0, 1.0, 1.0 )  -- white
	f.Text:SetText( missString )

	local startX, xDelta, startY, yDelta = getStartingPositions( MISS_EVENT )
	local xPos 		= startX 
	local yPos 		= startY

	f:ClearAllPoints()
	f:SetPoint("CENTER", xPos, yPos )
	scrollText(f, xPos, xDelta, startY, yDelta)
end
initFramePool()

local fileName = "ScrollText.lua"
if core:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( fileName, 0.0, 1.0, 1.0 )
end