--------------------------------------------------------------------------------------
-- PublishFloatingText.lua
-- AUTHOR: Michael Peterson
-- ORIGINAL DATE: 11 December, 2020
local _, SkillUp = ...
SkillUp.PublishFloatingText = {}
publish = SkillUp.PublishFloatingText

local sprintf = _G.string.format
local SUCCESS   = threadErrors.SUCCESS
local E = threadErrors
local EMPTY_STR = SkillUp.EMPTY_STR
local L = SkillUp.L

-- Access WoWThreads signal interface
 local SIG_WAKEUP            = thread.SIG_WAKEUP
 local SIG_RETURN            = thread.SIG_RETURN
 local SIG_NONE_PENDING      = thread.SIG_NONE_PENDING


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

--   f.Text1:SetTextColor( 1.0, 1.0, 1.0 )	-- white
--   f.Text1:SetTextColor( 0.0, 1.0, 0.0 )	-- green
--   f.Text1:SetTextColor( 1.0, 1.0, 0.0 )  -- yellow
--   f.Text1:SetTextColor( 0.0, 1.0, 1.0 )  -- turquoise
--	 f.Text1:SetTextColor( 0.0, 0.0, 1.0 )	-- blue
--	 f.Text1:SetTextColor( 1.0, 0.0, 0.0 )  -- red
local counter = 1
local clockInterval = (1/GetFramerate())

-- Supporting / local functions
local function createNewFrame()
  local f = CreateFrame( "Frame" )
  f.Text1 = f:CreateFontString("TrashHand")
  -- f.Text1:SetFont( "Interface\\Addons\\SkillUp\\Fonts\\ActionMan.ttf", 18 )
  f.Text1:SetFont( "Interface\\Addons\\SkillUp\\Fonts\\Bazooka.ttf", 18 )
  -- f.Text1:SetFont( "Interface\\Addons\\SkillUp\\Fonts\\SFWonderComic.ttf", 18 )


  f.Text1:SetWidth( 600 )
  f.Text1:SetJustifyH("LEFT")
  f.Text1:SetJustifyV("TOP")
  f.Text1:SetTextColor( 1.0, 1.0, 0.0 )
  f.Text1:SetText("")

  f.Text1:SetJustifyH("LEFT")
  f.Text1:SetJustifyV("TOP")
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
  f.Text1:SetText("")
  table.insert( framePool, f )
end
local function acquireFrame()
    local f = table.remove( framePool )
    if f == nil then 
        f = createNewFrame() 
      end
      return f
  end
  
  -- *********************** BEGIN ADDON CODE ***********************
initFramePool()
local function setStartingPosition( index )
	if index == 1 then
		return true, QUADRANT_UR_X, QUADRANT_UR_Y
	end
	if index == 2 then
		return false, QUADRANT_UL_X, QUADRANT_UL_Y
	end
	if index == 3 then
		return false, QUADRANT_LL_X, QUADRANT_LL_Y
	end
	if index == 4 then
		return true, QUADRANT_LR_X, QUADRANT_LR_Y
	end
end

local function scrollText( isSkillUp, logEntry )

  local ScrollMax = (UIParent:GetHeight() * UIParent:GetEffectiveScale())/2 -- max scroll height
  local f = acquireFrame()

	if isSkillUp then
  		f.Text1:SetTextColor( 0.0, 1.0, 0.0 ) -- green
	else
  		f.Text1:SetTextColor( 1.0, 1.0, 0.0 )
	end

  	f.Text1:SetText( logEntry )
  
  	local rightSide, xPos, yPos = setStartingPosition(counter)
  	counter = counter + 1
  	if counter > 4 then
		counter = 1
  	end

  	local yDelta = 2.0 -- move this much each update
  	local xDelta = 0.0 -- this means the text will scroll vertically

  	if isSkillUp then -- scroll the text faster at a 45 degree angle.
		  yDelta = 4.0
		  if rightSide then
			  xDelta = 2.0
		  else
			  xDelta = -2.0
		  end	
    end

  f:ClearAllPoints()
  f.Text1:SetPoint("TOP", UIParent, xPos, yPos )
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
        f.Text1:SetPoint("TOP", UIParent, xPos, yPos ) -- reposition the text to its new location
      end

    end)
    if f.Done == true then
      releaseFrame(f)
    end
end

-- This is the skillup thread's action routine - set in SkillUp.lua
function publish:floatSkillup()
  local result = {SUCCESS, EMPTY_STR, EMPTY_STR}
  local signal = SIG_NONE_PENDING
  local sender_h = nil

  while signal ~= SIG_RETURN do
    result = thread:yield()
    if not result[1] then mf:postResult( result ) return end

    signal, sender_h = thread:getSignal()
    if signal == SIG_WAKEUP then
      while handler:numChatEntries() > 0 do
        local isSkillUp, logEntry = handler:getChatEntry()
        scrollText( isSkillUp, logEntry )
        result = thread:yield()
        if not result[1] then mf:postResult( result ) return end
      end
    end
  end
  mf:postMsg( sprintf("SkillUp thread terminated.\n"))
end

local fileName = "PublishFloatingText.lua"
if E:debuggingIsEnabled() then
	DEFAULT_CHAT_FRAME:AddMessage( sprintf("%s loaded", fileName), 1.0, 1.0, 0.0 )
end
