-- === SkillUp Core: Addon identity detection (Lua 5.0 / Classic 1.12) ===
SkillUp = SkillUp or {}
SkillUp.Core = SkillUp.Core or {}
local core = SkillUp.Core

local ADDON_NAME = "SkillUp"

-- Derive AddonName (folder/.toc) from the Lua call stack; library-friendly.
local function detectAddonNameFromStack()
    if type(debugstack) ~= "function" then return nil end
    local s = debugstack()
    if not s or s == "" then return nil end
    local lower = string.lower(s)
    local a, b = string.find(lower, "interface[\\/]addons[\\/]")
    if not b then return nil end
    local rest = string.sub(lower, b + 1)
    local sepPos = string.find(rest, "[\\/]")
    if not sepPos then return nil end
    local start_index = b + 1
    local end_index   = b + sepPos - 1
    local folder = string.sub(s, start_index, end_index)
    -- trim leading/trailing spaces (no string.match in 5.0)
    if folder and folder ~= "" then
        while string.sub(folder, 1, 1) == " " do folder = string.sub(folder, 2) end
        while string.sub(folder, string.len(folder), string.len(folder)) == " " do
            folder = string.sub(folder, 1, string.len(folder)-1)
        end
    end
    return folder
end

local function initIdsOnce()
    if SkillUp.AddonName then return end
    local folder = detectAddonNameFromStack() or ADDON_NAME
    SkillUp.AddonName = folder or ADDON_NAME

    local title, ver, exp = folder, "", ""
    if type(GetAddOnMetadata) == "function" then
        local t = GetAddOnMetadata(folder, "Title");       if t and t ~= "" then title = t end
        local v = GetAddOnMetadata(folder, "Version");     if v and v ~= "" then ver   = v end
        local x = GetAddOnMetadata(folder, "X-Expansion"); if x and x ~= "" then exp   = x end
    end
    SkillUp.AddonTitle     = title
    SkillUp.AddonVersion   = ver
    SkillUp.AddonExpansion = exp
end

initIdsOnce()

-- Public API: always returns (AddonName, AddonTitle, Version, Expansion)
function core:getAddonInfo()
    initIdsOnce()
    return SkillUp.AddonName,
           SkillUp.AddonTitle or (SkillUp.AddonName or "SkillUp"),
           SkillUp.AddonVersion or "",
           SkillUp.AddonExpansion or ""
end

SkillUp.Core.loaded = true
if SkillUp._mark then SkillUp._mark("Core") end

