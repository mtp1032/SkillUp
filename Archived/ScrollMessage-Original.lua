-- ScrollMessage.lua

SkillUp = SkillUp or {}
SkillUp.ScrollMessage = SkillUp.ScrollMessage or {}

local scroll = SkillUp.ScrollMessage
local core  = SkillUp.Core

-- Event codes (enums)
local SKILLUP = 1
local XP_GAIN = 2
local LOOT    = 3
local MONEY   = 4

-- (Optional) export enums
scroll.KIND = { SKILLUP=SKILLUP, XP_GAIN=XP_GAIN, LOOT=LOOT, MONEY=MONEY }

-- Map kind *string key* → color (presentation only)
local EVENT_COLOR = {
  SKILLUP = { r = 0.1, g = 0.9, b = 0.1 }, -- green
  XP_GAIN = { r = 0.1, g = 0.9, b = 0.1 }, -- green (same as skill)
  LOOT    = { r = 0.1, g = 0.6, b = 1.0 }, -- light blue
  MONEY   = { r = 1.0, g = 0.84, b = 0.0 },-- gold
}

-- Return BOTH: numeric code and string key (code, key)
local function getEventKind(event)
  if event == "CHAT_MSG_SKILL"           then return SKILLUP, "SKILLUP" end
  if event == "CHAT_MSG_COMBAT_XP_GAIN"  then return XP_GAIN, "XP_GAIN" end
  if event == "CHAT_MSG_LOOT"            then return LOOT,    "LOOT"    end
  if event == "PLAYER_MONEY"             then return MONEY,   "MONEY"   end

  return nil, nil
end

local function isValidMsg(msg)
  if not msg then return false end
  return (type(msg) == "string" and msg ~= "")
end

-- Preliminary: only prints event message to the Chat window in the event color.
function scroll:eventMessage(event, msg)
  
  local code, key = getEventKind(event)
  if not code or not key then return end
  if not isValidMsg(msg) then return end
  if not DEFAULT_CHAT_FRAME then return end

  local color = EVENT_COLOR[key] or { r=1, g=1, b=1 }
  DEFAULT_CHAT_FRAME:AddMessage(msg, color.r, color.g, color.b)
end

-- load ping (optional)
if core and core.debuggingIsEnabled and core.debuggingIsEnabled() then
  DEFAULT_CHAT_FRAME:AddMessage("ScrollMessage.lua loaded (event codes + color keys)", 0, 1, 0)
end
