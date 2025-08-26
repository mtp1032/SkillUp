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

-- Font settings
local FONT_PATH  = "Fonts\\FRIZQT__.TTF"
local FONT_SIZE  = 32          -- <— make this bigger/smaller to taste
local FONT_FLAGS = "OUTLINE"   -- "", "OUTLINE", "THICKOUTLINE"

-- Return BOTH: numeric code and string key (code, key)
local function getEventKind(event)
  if event == "CHAT_MSG_SKILL"           then return SKILLUP, "SKILLUP" end
  if event == "CHAT_MSG_COMBAT_XP_GAIN"  then return XP_GAIN, "XP_GAIN" end
  if event == "CHAT_MSG_LOOT"            then return LOOT,    "LOOT"    end
  if event == "PLAYER_MONEY"             then return MONEY,   "MONEY"   end
  return nil, nil
end

local function isValidMsg(msg)
  return (type(msg) == "string" and msg ~= "")
end

-- ===== robust screen size (never trust 0 on Classic/Turtle) =====
local function getScreenSize()
  local sw, sh
  if UIParent and UIParent.GetWidth  then sw = UIParent:GetWidth()  end
  if UIParent and UIParent.GetHeight then sh = UIParent:GetHeight() end
  if (not sw) or (sw <= 1) then if WorldFrame and WorldFrame.GetWidth  then sw = WorldFrame:GetWidth()  end end
  if (not sh) or (sh <= 1) then if WorldFrame and WorldFrame.GetHeight then sh = WorldFrame:GetHeight() end end
  if (not sw) or (sw <= 1) then if GetScreenWidth  then sw = GetScreenWidth()  end end
  if (not sh) or (sh <= 1) then if GetScreenHeight then sh = GetScreenHeight() end end
  if (not sw) or (sw <= 1) then sw = 1024 end
  if (not sh) or (sh <= 1) then sh = 768  end
  return sw, sh
end

-- ===== per-lane tuning =====
-- All offsets are center-relative pixels used in SetPoint("CENTER", UIParent, "CENTER", x, y)
local LANE = {
  -- SKILLUP & XP: vertical up, start at {0, 0}
  vertical = {
    speed  = 100,                  -- px/sec along path
    x0     = 0,                    -- start offset X
    y0     = 0,                    -- start offset Y
    theta  = 90,                   -- degrees from +X (90 = straight up)
    pad    = 30,                   -- offscreen top padding
  },
  -- LOOT: 45° up-right, start at { 10, -90 }
  loot = {
    speed  = 100,                   -- originally 300
    x0     = 10,
    y0     = -90,
    theta  = 45,                   -- up-right
    padX   = 40,                   -- offscreen X padding
    padY   = 40,                   -- offscreen Y padding
  },
  -- MONEY: 34° up-left, start at { -10, -90 }  (90+34 = 124° from +X)
  money = {
    speed  = 100,
    x0     = -10,
    y0     = -90,
    theta  = 124,                  -- up-left (34° left of vertical)
    padX   = 40,
    padY   = 40,
  },
}

-- ===== lanes: each has its own frame, FS, queue, and OnUpdate =====
local lanes = {
  vertical = { queue={}, anim={active=false}, runner=nil, fs=nil },
  loot     = { queue={}, anim={active=false}, runner=nil, fs=nil },
  money    = { queue={}, anim={active=false}, runner=nil, fs=nil },
}

local function laneNameForCode(code)
  if code == LOOT  then return "loot"
  elseif code == MONEY then return "money"
  else return "vertical" end
end

-- ===== runner creation per lane =====
local function ensureRunner(name)
  local lane = lanes[name]
  if lane.runner then return end

  local parent = UIParent or WorldFrame
  local r = CreateFrame("Frame", "SkillUp_Lane_"..name, parent)
  r:Hide()
  r:SetFrameStrata("TOOLTIP")
  r:SetWidth(512); r:SetHeight(FONT_SIZE + 20)

  local fs = r:CreateFontString(nil, "OVERLAY")
  fs:SetFont(FONT_PATH, FONT_SIZE, FONT_FLAGS)
  
  fs:SetJustifyH("CENTER"); fs:SetJustifyV("MIDDLE")
  fs:ClearAllPoints(); fs:SetPoint("CENTER", r, "CENTER", 0, 0); fs:Show()

  lane.runner, lane.fs = r, fs
end

local function q_push(name, item) table.insert(lanes[name].queue, item) end
local function q_pop(name)
  local q = lanes[name].queue
  if table.getn(q) == 0 then return nil end
  return table.remove(q, 1)
end

-- ===== start animating the next message in a lane =====
local function startNext(name)
  local lane = lanes[name]
  if lane.anim.active then return end
  ensureRunner(name)

  local item = q_pop(name)
  if not item then
    lane.runner:SetScript("OnUpdate", nil)
    lane.runner:Hide()
    return
  end

  lane.anim.active = true
  lane.anim.item = item

  local fs, runner = lane.fs, lane.runner
  fs:SetText(item.text or "")
  local col = item.color or { r=1, g=1, b=1 }
  fs:SetTextColor(col.r, col.g, col.b)

  local sw, sh = getScreenSize()
  local w  = fs:GetStringWidth() or 200
  if w <= 0 then w = 200 end

  -- per-lane setup
  if name == "vertical" then
    local cfg = LANE.vertical
    local x0  = cfg.x0
    local y0  = cfg.y0
    local yTop = (sh / 2) + cfg.pad
    local distY = (yTop - y0)
    if distY < 1 then distY = sh end -- safety
    local duration = distY / cfg.speed
    if duration < 0.35 then duration = 0.35 end

    lane.anim.t = 0
    lane.anim.duration = duration
    lane.anim.x0 = x0
    lane.anim.y0 = y0
    lane.anim.y1 = yTop

    runner:SetWidth(w + 20); runner:SetHeight(FONT_SIZE + 20)
    runner:ClearAllPoints(); runner:SetPoint("CENTER", UIParent, "CENTER", x0, y0)
    runner:Show()

    runner:SetScript("OnUpdate", function()
      local dt = arg1 or 0
      lane.anim.t = lane.anim.t + dt
      local t = lane.anim.t / lane.anim.duration
      if t >= 1 then
        lane.anim.active = false
        runner:SetScript("OnUpdate", nil)
        startNext("vertical")
        return
      end
      local y = lane.anim.y0 + (lane.anim.y1 - lane.anim.y0) * t
      runner:ClearAllPoints()
      runner:SetPoint("CENTER", UIParent, "CENTER", lane.anim.x0, y)
    end)

  else
    -- diagonal lanes: "loot" (45° up-right) and "money" (124° up-left)
    local cfg   = LANE[name]
    local x0    = cfg.x0
    local y0    = cfg.y0
    local padX  = cfg.padX or 40
    local padY  = cfg.padY or 40

    local rad   = math.pi * (cfg.theta / 180.0)
    local vx    = math.cos(rad) * cfg.speed
    local vy    = math.sin(rad) * cfg.speed

    -- offscreen bounds (include text width for X so the whole string exits)
    local xRight =  (sw / 2) + w + padX
    local xLeft  = -(sw / 2) - w - padX
    local yTop   =  (sh / 2) + padY

    local tx, ty
    if vx > 0 then
      tx = (xRight - x0) / vx
    else
      tx = (xLeft  - x0) / vx  -- vx < 0 here
    end
    ty = (yTop - y0) / (vy ~= 0 and vy or 1)  -- vy should be >0 (up), but guard anyway

    -- total time: long enough to clear both axes
    local duration = tx
    if ty > duration then duration = ty end
    if duration < 0.35 then duration = 0.35 end

    lane.anim.t = 0
    lane.anim.duration = duration
    lane.anim.x0 = x0
    lane.anim.y0 = y0
    lane.anim.vx = vx
    lane.anim.vy = vy

    runner:SetWidth(w + 20); runner:SetHeight(FONT_SIZE + 20)
    runner:ClearAllPoints(); runner:SetPoint("CENTER", UIParent, "CENTER", x0, y0)
    runner:Show()

    runner:SetScript("OnUpdate", function()
      local dt = arg1 or 0
      lane.anim.t = lane.anim.t + dt
      local t = lane.anim.t / lane.anim.duration
      if t >= 1 then
        lane.anim.active = false
        runner:SetScript("OnUpdate", nil)
        startNext(name)
        return
      end
      local x = lane.anim.x0 + lane.anim.vx * (lane.anim.t)
      local y = lane.anim.y0 + lane.anim.vy * (lane.anim.t)
      runner:ClearAllPoints()
      runner:SetPoint("CENTER", UIParent, "CENTER", x, y)
    end)
  end
end

-- ===== Public API: event + message =====
function scroll:eventMessage(event, msg)
  if not isValidMsg(msg) then return end
  if not UIParent then
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(msg, 1, 1, 1) end
    return
  end

  local code, key = getEventKind(event)
  if not code or not key then return end

  local laneName = laneNameForCode(code)
  local color = EVENT_COLOR[key] or { r=1, g=1, b=1 }

  q_push(laneName, { text=msg, kind=code, color=color })
  startNext(laneName)
end

-- (optional) debug ping
if core and core.debuggingIsEnabled and core.debuggingIsEnabled() then
  local sw, sh = getScreenSize()
  DEFAULT_CHAT_FRAME:AddMessage("SkillUp: ScrollMessage.lua (lanes) loaded  sw="..sw.." sh="..sh, 0.5, 1.0, 0.5)
end

-- (optional) self-test
function scroll:_debugTest()
  scroll:eventMessage("CHAT_MSG_SKILL", "[Test] SkillUp +1")
  scroll:eventMessage("CHAT_MSG_COMBAT_XP_GAIN", "+250 XP")
  scroll:eventMessage("CHAT_MSG_LOOT", "[Test] You receive loot: Linen Cloth")
  scroll:eventMessage("PLAYER_MONEY", "Money Gained: 1g 23s 45c")
end
