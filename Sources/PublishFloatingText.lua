--------------------------------------------------------------------------------------
-- PublishFloatingText.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 22 May, 2023
--------------------------------------------------------------------------------------
local ADDON_NAME, _ = ...

-- Ensure SkillUp namespace exists
SkillUp = SkillUp or {}
SkillUp.PublishFloatingText = SkillUp.PublishFloatingText or {}
publish = SkillUp.PublishFloatingText

local UtilsLib = LibStub("UtilsLib")
local utils = UtilsLib
if not utils then return end

local thread = LibStub:GetLibrary( "WoWThreads-1.0" )
if not thread then return end

local SIG_ALERT         = thread.SIG_ALERT
local SIG_GET_DATA      = thread.SIG_GET_DATA
local SIG_SEND_DATA     = thread.SIG_SEND_DATA
local SIG_BEGIN         = thread.SIG_BEGIN
local SIG_HALT          = thread.SIG_HALT
local SIG_TERMINATE     = thread.SIG_TERMINATE
local SIG_IS_COMPLETE   = thread.SIG_IS_COMPLETE
local SIG_SUCCESS       = thread.SIG_SUCCESS
local SIG_FAILURE       = thread.SIG_FAILURE  
local SIG_READY         = thread.SIG_READY 
local SIG_WAKEUP        = thread.SIG_WAKEUP 
local SIG_CALLBACK      = thread.SIG_CALLBACK
local SIG_THREAD_DEAD   = thread.SIG_THREAD_DEAD
local SIG_NONE_PENDING  = thread.SIG_NONE_PENDING

local L = SkillUp.L

local sprintf     = _G.string.format

local SKILLUP = handler.SKILLUP
local LOOT		= handler.LOOT
local MONEY		= handler.MONEY

local framePool = {}
local CENTER_Y = -400
local CENTER_X = 275

-- Upper Right - #1
local QUADRANT_UR_Y = CENTER_Y + 20
local QUADRANT_UR_X = CENTER_X + 150

-- Upper Left - #2
local QUADRANT_UL_Y = CENTER_Y + 20
local QUADRANT_UL_X = CENTER_X - 150

-- Lower Left - #3
local QUADRANT_LL_Y = CENTER_Y - 10
local QUADRANT_LL_X = CENTER_X - 150

-- Lower Right #4
local QUADRANT_LR_Y = CENTER_Y - 10
local QUADRANT_LR_X = CENTER_X + 150

local quadrant = 1
local clockInterval = (1/GetFramerate())

local function createNewFrame()
  local f = CreateFrame( "Frame" )
  f.Text = f:CreateFontString("TrashHand")
  -- f.Text:SetFont( "Interface\\Addons\\SkillUp\\Fonts\\ActionMan.ttf", 18 )
  f.Text:SetFont( "Interface\\Addons\\SkillUp\\LibFonts\\Bazooka.ttf", 18 )
  -- f.Text:SetFont( "Interface\\Addons\\SkillUp\\Fonts\\SFWonderComic.ttf", 18 )

  f.Text:SetWidth( 600 )
  f.Text:SetJustifyH("LEFT")
  f.Text:SetJustifyV("TOP")
  f.Text:SetTextColor( 1.0, 1.0, 0.0 )
  f.Text:SetText("")

  f.Text:SetJustifyH("LEFT")
  f.Text:SetJustifyV("TOP")
  f.Done = false
  f.TotalTicks = 0
  f.UpdateTicks = 2 -- Move the frame once every 2 ticks
  f.UpdateTickCount = f.UpdateTicks
  return f
end

local function initFramePool()
  local f = createNewFrame()
  table.insert( framePool, f )
end
local function releaseFrame( f )
  f.Text:SetText("")
  table.insert( framePool, f )
end
local function acquireFrame()
  local f = table.remove( framePool )
  if f == nil then 
      f = createNewFrame() 
    end
    return f
end  
initFramePool()
local function getQuadrantXandYPositions( quadIndex )
  local isRightSide = true
	if quadIndex == 1 then
		return isRightSide, QUADRANT_UR_X, QUADRANT_UR_Y
	end

	if quadIndex == 2 then
		return not isRightSide, QUADRANT_UL_X, QUADRANT_UL_Y
	end
	if quadIndex == 3 then
		return not isRightSide, QUADRANT_LL_X, QUADRANT_LL_Y
	end
	if quadIndex == 4 then
		return isRightSidee, QUADRANT_LR_X, QUADRANT_LR_Y
	end
end
local function scrollText( skillupType, chatMsg )

  local ScrollMax = (UIParent:GetHeight() * UIParent:GetEffectiveScale())/2 -- max scroll height
  local f = acquireFrame()

  --   f.Text:SetTextColor( 1.0, 1.0, 1.0 )	-- white
  --   f.Text:SetTextColor( 0.0, 1.0, 0.0 )	-- green
  --   f.Text:SetTextColor( 1.0, 1.0, 0.0 )  -- yellow
  --   f.Text:SetTextColor( 0.0, 1.0, 1.0 )  -- turquoise
  --	 f.Text:SetTextColor( 0.0, 0.0, 1.0 )	-- blue
  --	 f.Text:SetTextColor( 1.0, 0.0, 0.0 )  -- red

	if skillupType == LOOT then
  		f.Text:SetTextColor( 0.0, 1.0, 0.0 ) -- green
  end 
  if skillupType == MONEY then
  		f.Text:SetTextColor( 1.0, 1.0, 0.0 ) -- yellow/gold
  end
  if skillupType == SKILLUP then
    f.Text:SetTextColor( 1.0, 0.0, 0.0 )   -- red
  end

  	f.Text:SetText( chatMsg )
  
  	local rightSide, xPos, yPos = getQuadrantXandYPositions( quadrant )
  	quadrant = quadrant + 1
  	if quadrant > 4 then
		quadrant = 1
  	end

  	local yDelta = 2.0 -- move this much each update
  	local xDelta = 0.0 -- this means the text will scroll vertically

  	if skillupType == SKILLUP then -- scroll the text faster at a 45 degree angle.
		  yDelta = 4.0
		  if rightSide then
			  xDelta = 2.0
		  else
			  xDelta = -2.0
		  end	
    end

  f:ClearAllPoints()
  f.Text:SetPoint("TOP", UIParent, xPos, yPos )
  f.Done = false

  f.TotalTicks = 0
  f.UpdateTicks = 4 -- Move the frame once every 4 ticks
  f.UpdateTickCount = f.UpdateTicks
  f:Show()
  f:SetScript("OnUpdate", 
  
    function(self, elapsed)
      self.UpdateTickCount = self.UpdateTickCount - 1
      if self.UpdateTickCount > 0 then
        return
      end

      self.UpdateTickCount = self.UpdateTicks
      self.TotalTicks = self.TotalTicks + 1
              
      if self.TotalTicks == 40 then f:SetAlpha( 0.8 ) end
      if self.TotalTicks == 45 then f:SetAlpha( 0.6 ) end
      if self.TotalTicks == 50 then f:SetAlpha( 0.4 ) end
      if self.TotalTicks == 55 then f:SetAlpha( 0.2 ) end
      if self.TotalTicks == 60 then f:SetAlpha( 0.1 ) end
      if self.TotalTicks >= 65 then 
      f:Hide()
        f.Done = true
      else
        yPos = yPos + yDelta
        xPos = xPos + xDelta
        f:ClearAllPoints()
        f.Text:SetPoint("TOP", UIParent, xPos, yPos ) -- reposition the text to its new location
      end

    end)

    if f.Done == true then
      releaseFrame(f)
    end
end
function publish:skillUp() -- This is the skillup thread's action routine - set in SkillUp.lua
  local DONE = false

  while not DONE do 
    thread:yield()
    local sigEntry, errorMsg = thread:getSignal()

    if sigEntry[1] == SIG_SEND_DATA then
      local sigData = sigEntry[3]
      scrollText( sigData[1], sigData[2] )      
    end

    if signal == SIG_TERMINATE then
      DONE = true
    end
  end
utils:postMsg( sprintf("publisher_h terminated.\n"))
end

local fileName = "PublishFloatingText.lua"
if core:debuggingIsEnabled() then
  DEFAULT_CHAT_FRAME:AddMessage( fileName, 0.0, 1.0, 1.0 )
end