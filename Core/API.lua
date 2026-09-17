local _, CF = ...
CF.API = {}
function CF.API.IsSecret(value) return type(issecretvalue) == "function" and issecretvalue(value) end
function CF.API.SafeText(value)
  if CF.API.IsSecret(value) then return "[restricted value]" end
  return tostring(value)
end
function CF.API.IsInCombatLockdown()
  -- Missing combat API is not evidence that protected mutations are safe.
  return type(InCombatLockdown) ~= "function" or InCombatLockdown()
end
function CF.API.GetInterfaceVersion() return CF.Environment.Interface end
function CF.API.GetUnitHealth(unit) return UnitHealth(unit) end
function CF.API.GetUnitPower(unit) return UnitPower(unit) end
function CF.API.GetUnitName(unit) return UnitName(unit) end
function CF.API.GetUnitLevel(unit) return UnitLevel(unit) end
function CF.API.GetAtlasInfo(name)
  if C_Texture and type(C_Texture.GetAtlasInfo) == "function" then return C_Texture.GetAtlasInfo(name) end
end
function CF.API.RegisterEvent(frame, event) return pcall(frame.RegisterEvent, frame, event) end
function CF.API.NextFrame(callback)
  if C_Timer and C_Timer.After then C_Timer.After(0, callback) else
    local frame = CreateFrame("Frame")
    frame:SetScript("OnUpdate", function(self) self:SetScript("OnUpdate", nil); callback() end)
  end
end
function CF.API.SetTexture(texture, assetID) return CF.Assets:Apply(texture, assetID) end
function CF.API.LayoutScale() return math.min(1, UIParent:GetWidth() / 1280) end
function CF.API.Required(names)
  for _, name in ipairs(names) do
    if type(_G[name]) ~= "function" then return false, "Missing API: " .. name end
  end
  return true
end
function CF.API.UpdateUnit(visual, unit)
  -- Secret power/name goes straight to Blizzard's allowed display sinks.
  -- Native health and its predictions are never read or written by this skin.
  -- No comparisons, arithmetic, caching, formatting or table keys use it.
  visual.Power:SetMinMaxValues(0, UnitPowerMax(unit))
  visual.Power:SetValue(UnitPower(unit))
  visual.Name:SetText(UnitName(unit))
  visual.PowerText:SetText(UnitPower(unit))
  local level = UnitLevel(unit)
  if CF.API.IsSecret(level) then visual.Level:SetText("") else
    visual.Level:SetText(type(level) == "number" and level > 0 and level or "??")
  end
  local _, token = UnitPowerType(unit)
  local color
  if not CF.API.IsSecret(token) and token ~= nil then color = PowerBarColor and PowerBarColor[token] end
  if color then visual.Power:SetStatusBarColor(color.r, color.g, color.b)
  else visual.Power:SetStatusBarColor(0.1, 0.3, 0.9) end
end
function CF.API.DisplayUnit(frame, fallback)
  local token = frame.unit
  if not CF.API.IsSecret(token) and type(token) == "string" then return token end
  return fallback
end
function CF.API.WatchedFaction()
  if C_Reputation and C_Reputation.GetWatchedFactionData then return C_Reputation.GetWatchedFactionData() end
  if GetWatchedFactionInfo then
    local name, reaction, low, high, value = GetWatchedFactionInfo()
    if name then return { name=name, reaction=reaction, currentReactionThreshold=low,
      nextReactionThreshold=high, currentStanding=value } end
  end
end
