local _, CF = ...
CF.Visuals = {}
-- Retail creates these buttons before it fills them with aura data. Skin the
-- button identity, never the aura data (which can contain restricted values).
function CF.Visuals:AuraModule(frameName)
  local M = { Borders = {} }
  function M:Initialize()
    local frame = _G[frameName]
    if not frame or type(frame.auraFrames) ~= "table" then
      return false, "Native aura buttons unavailable"
    end
    self.Frame = frame
    return CF.Assets:Require({"CLASSIC_QUICKSLOT"})
  end
  function M:Refresh(event, eventUnit)
    if CF.API.IsSecret(eventUnit) or (eventUnit and eventUnit ~= "player") then return end
    if CF.API.IsInCombatLockdown() then CF.Pending = true; CF:RefreshOptions(); return end
    for _, button in ipairs(self.Frame.auraFrames) do
      local icon = button.Icon
      -- Private aura anchors have a Frame named Icon, not a texture.
      if icon and type(icon.GetTexture) == "function" then
        local border = self.Borders[button]
        if not border then
          border = button:CreateTexture(nil,"ARTWORK",nil,-2)
          self.Borders[button] = border
          border:Hide()
          border:SetPoint("TOPLEFT",icon,"TOPLEFT",-7,7)
          border:SetPoint("BOTTOMRIGHT",icon,"BOTTOMRIGHT",7,-7)
        end
        if not CF.Assets:Apply(border,"CLASSIC_QUICKSLOT") then error("Aura border rejected") end
        border:Show()
      end
    end
  end
  function M:Enable()
    self:Refresh()
    CF.Events:Bind(self,{"UNIT_AURA"},self.Refresh)
    return true, "Classic slots; native timers, dispel colors, enchant borders and clicks retained"
  end
  function M:Disable()
    CF.Events:Unbind(self)
    for _,border in pairs(self.Borders) do border:Hide() end
  end
  return M
end
function CF.Visuals:Texture(parent, id, layer, width, height, point, relative, relativePoint, x, y)
  local texture = parent:CreateTexture(nil, layer or "ARTWORK")
  texture:SetSize(width, height)
  texture:SetPoint(point, relative, relativePoint, x or 0, y or 0)
  if not CF.Assets:Apply(texture, id) then texture:Hide(); error("Asset load rejected: " .. id) end
  return texture
end
function CF.Visuals:Label(parent, template, width, height, x, y)
  local text = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormalSmall")
  text:SetSize(width, height)
  text:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  return text
end
function CF.Visuals:Fill(parent, x, y, width, height, r, g, b)
  local bar = CreateFrame("StatusBar", nil, parent)
  bar:SetSize(width, height)
  bar:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
  bar:SetStatusBarTexture(CF.Assets:Get("CLASSIC_STATUSBAR").path)
  bar:SetStatusBarColor(r, g, b)
  local background = bar:CreateTexture(nil, "BACKGROUND")
  background:SetAllPoints()
  background:SetColorTexture(0, 0, 0, 0.85)
  return bar
end

function CF.Visuals:UnitModule(unit, frameName, screenX)
  local M = {}
  function M:Initialize()
    self.Frame = _G[frameName]
    if not self.Frame then return false, "Missing " .. frameName end
    if unit == "focus" and (CF.API.IsSecret(self.Frame.smallSize) or self.Frame.smallSize) then
      return false, "Compact focus unsupported; native frame retained"
    end
    local contentName = unit == "player" and "PlayerFrameContent" or "TargetFrameContent"
    local mainName = unit == "player" and "PlayerFrameContentMain" or "TargetFrameContentMain"
    self.Main = CF.Compat:Path(self.Frame, contentName, mainName)
    self.Container = self.Frame[unit == "player" and "PlayerFrameContainer" or "TargetFrameContainer"]
    if not self.Main or not self.Container or not self.Main.HealthBarsContainer or
        not self.Main.HealthBarsContainer.HealthBar then
      return false, "Retail unit frame hierarchy absent; default retained"
    end
    local ok, why = CF.API.Required({"UnitPower","UnitPowerMax",
      "UnitPowerType","UnitName","UnitLevel","SetPortraitTexture"})
    if not ok then return false, why end
    return CF.Assets:Require({unit == "player" and "CLASSIC_PLAYERFRAME_BORDER" or "CLASSIC_TARGETFRAME_BORDER", "CLASSIC_STATUSBAR"})
  end
  function M:Build()
    local root = CreateFrame("Frame", nil, self.Frame)
    self.Visual = root
    root:Hide()
    root:SetAllPoints(self.Frame)
    root:EnableMouse(false)
    root:SetFrameLevel(self.Frame:GetFrameLevel() + 10)
    local player = unit == "player"
    local barX, portraitX, borderX = player and 87 or 28, player and 22 or 148, player and -20 or -2
    root.Portrait = root:CreateTexture(nil, "BACKGROUND")
    root.Portrait:SetSize(64,64)
    root.Portrait:SetPoint("TOPLEFT", portraitX, -16)
    -- Native health owns predictions, masks, losses, text and restricted values.
    -- Keep its full geometry; never draw a duplicate opaque health bar over it.
    root.Power = CF.Visuals:Fill(root, barX, -64, 119, 10, 0.1,0.3,0.9)
    root.Power:SetFrameLevel(root:GetFrameLevel()+4)
    local face = CreateFrame("Frame", nil, root)
    face:SetAllPoints()
    face:SetFrameLevel(root:GetFrameLevel() + 3)
    root.Border = CF.Visuals:Texture(face, player and "CLASSIC_PLAYERFRAME_BORDER" or "CLASSIC_TARGETFRAME_BORDER",
      "ARTWORK",256,128,"TOPLEFT",root,"TOPLEFT",borderX,-4)
    root.Name = CF.Visuals:Label(face,"GameFontNormalSmall",116,16,barX,-27)
    root.Level = CF.Visuals:Label(face,"GameNormalNumberFont",24,16,player and 26 or 190,-62)
    root.PowerText = CF.Visuals:Label(root.Power,"GameFontHighlightSmall",117,10,0,1)
  end
  function M:Refresh(event, eventUnit)
    if unit == "focus" and (CF.API.IsSecret(self.Frame.smallSize) or self.Frame.smallSize) then
      CF:RequestApply(); return
    end
    local displayUnit = CF.API.DisplayUnit(self.Frame, unit)
    if not CF.API.IsSecret(eventUnit) and eventUnit and event:match("^UNIT_") and
      eventUnit ~= unit and eventUnit ~= displayUnit then return end
    CF.API.UpdateUnit(self.Visual, displayUnit)
    if not event or event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" or event == "PLAYER_ENTERING_WORLD" or
      event == "UNIT_PORTRAIT_UPDATE" or event == "UNIT_MODEL_CHANGED" or
      event == "UNIT_ENTERED_VEHICLE" or event == "UNIT_EXITED_VEHICLE" or event == "UNIT_PET" then
      SetPortraitTexture(self.Visual.Portrait, displayUnit)
    end
    if (unit == "target" or unit == "focus") and type(UnitClassification) == "function" then
      local classification = UnitClassification(unit)
      local id = "CLASSIC_TARGETFRAME_BORDER"
      if not CF.API.IsSecret(classification) then
        local ids = { elite="CLASSIC_TARGET_ELITE", worldboss="CLASSIC_TARGET_ELITE",
          rare="CLASSIC_TARGET_RARE", rareelite="CLASSIC_TARGET_RARE_ELITE" }
        id = ids[classification] or id
      end
      if id ~= self.BorderID then
        if not CF.Assets:Apply(self.Visual.Border,id) then CF.Assets:Apply(self.Visual.Border,"CLASSIC_TARGETFRAME_BORDER") end
        self.BorderID = id
      end
    end
  end
  function M:Enable()
    if not self.Visual then self:Build() end
    local j = self.Journal
    if screenX then
      j:Point(self.Frame,"TOPLEFT",UIParent,"TOPLEFT",screenX,-20)
      j:Scale(self.Frame,1)
    end
    j:Alpha(self.Container,0)
    local main = self.Main
    local health = main.HealthBarsContainer
    j:Point(health,"TOPLEFT",self.Frame,"TOPLEFT",unit == "player" and 87 or 22,-40)
    -- Above the passive border, including its child frames. Keep native masks,
    -- bar dimensions, scripts, values and visibility entirely Blizzard-owned.
    j:FrameLevel(health,self.Visual:GetFrameLevel()+5)
    j:FrameLevel(health.HealthBar,self.Visual:GetFrameLevel()+5)
    if unit == "player" then
      j:Alpha(main.ManaBarArea,0)
      j:Alpha(_G.PlayerName,0)
      j:Alpha(_G.PlayerLevelText,0)
      j:Alpha(main.StatusTexture,0)
      j:Alpha(main.HitIndicator,0)
    else
      j:Alpha(main.ManaBar,0)
      j:Alpha(main.Name,0)
      j:Alpha(main.LevelText,0)
      j:Alpha(main.ReputationColor,0)
    end
    self:Refresh()
    local events = {"PLAYER_ENTERING_WORLD","PLAYER_TARGET_CHANGED","UNIT_HEALTH","UNIT_MAXHEALTH",
      "UNIT_POWER_UPDATE","UNIT_MAXPOWER","UNIT_DISPLAYPOWER","UNIT_NAME_UPDATE","UNIT_LEVEL",
      "UNIT_PORTRAIT_UPDATE","UNIT_MODEL_CHANGED","UNIT_CLASSIFICATION_CHANGED",
      "UNIT_ENTERED_VEHICLE","UNIT_EXITED_VEHICLE","UNIT_PET"}
    if unit == "focus" then events[#events+1] = "PLAYER_FOCUS_CHANGED" end
    CF.Events:Bind(self,events,self.Refresh)
    self.Visual:Show()
    return true, "Classic border/power; full native health, healing and shields retained"
  end
  function M:Disable()
    CF.Events:Unbind(self)
    if self.Visual then self.Visual:Hide() end
  end
  function M:RunDiagnostics() return self.State, self.Detail end
  return M
end

function CF.Visuals:TrackingModule(kind)
  local M = {}
  function M:Initialize()
    self.Bars = {}
    local enum = StatusTrackingBarInfo and StatusTrackingBarInfo.BarsEnum
    if not enum or not enum[kind] then return false, "Retail tracking bar API absent" end
    for _, name in ipairs({"MainStatusTrackingBarContainer","SecondaryStatusTrackingBarContainer"}) do
      local container = _G[name]
      local bar = container and container.bars and container.bars[enum[kind]]
      if bar and bar.StatusBar and bar.StatusBar.GetStatusBarTexture then self.Bars[#self.Bars+1] = bar end
    end
    if #self.Bars == 0 then return false, "Native " .. kind .. " bars not created" end
    return CF.Assets:Require({"CLASSIC_STATUSBAR","CLASSIC_MAXLEVEL"})
  end
  function M:Enable()
    self.Trim = self.Trim or {}
    for i, bar in ipairs(self.Bars) do
      local texture = bar.StatusBar:GetStatusBarTexture()
      if texture then self.Journal:Texture(texture, "CLASSIC_STATUSBAR") end
      if not self.Trim[i] then
        local trim = CreateFrame("Frame",nil,bar)
        trim:SetAllPoints(bar)
        trim:EnableMouse(false)
        trim.Top = CF.Visuals:Texture(trim,"CLASSIC_MAXLEVEL","OVERLAY",bar:GetWidth(),3,
          "BOTTOM",bar,"TOP",0,0)
        trim.Bottom = CF.Visuals:Texture(trim,"CLASSIC_MAXLEVEL","OVERLAY",bar:GetWidth(),3,
          "TOP",bar,"BOTTOM",0,0)
        self.Trim[i] = trim
      end
      self.Trim[i]:Show()
    end
    return true, "Native tracking, rested XP, reputation and tooltips retained; original fill/trim applied"
  end
  function M:Disable() for _, trim in ipairs(self.Trim or {}) do trim:Hide() end end
  function M:Refresh() end
  function M:RunDiagnostics() return self.State,self.Detail end
  return M
end

-- Small frames retain all native regions, bars and controls. Trim is anchored
-- outside the bar pair on the unit button's BACKGROUND layer, below health
-- children and their prediction/glow/text regions. No unit values are read.
function CF.Visuals:SmallUnitModule(resolve)
  local M = {}
  function M:Initialize()
    local frame, health, power, portrait, border = resolve()
    if not frame or not health or not power or not portrait or not border or
        type(health.GetStatusBarTexture) ~= "function" or
        type(power.GetStatusBarTexture) ~= "function" or
        health:GetParent() ~= frame or power:GetParent() ~= frame then
      return false, "Retail small unit hierarchy absent; native frame retained"
    end
    self.Frame, self.Health, self.Power = frame, health, power
    return CF.Assets:Require({"CLASSIC_MAXLEVEL"})
  end
  function M:Enable()
    self.Trims = self.Trims or {}
    local pair = self.Trims[self.Frame]
    if not pair then pair = {}; self.Trims[self.Frame] = pair end
    for index, bar in ipairs({self.Health, self.Power}) do
      local trim = pair[index]
      if not trim then
        trim = self.Frame:CreateTexture(nil,"BACKGROUND",nil,-1)
        pair[index] = trim
        trim:Hide()
      end
      trim:ClearAllPoints()
      trim:SetHeight(2)
      local side = index == 1 and "TOP" or "BOTTOM"
      local edge = index == 1 and "BOTTOM" or "TOP"
      local offset = index == 1 and 1 or -1
      trim:SetPoint(edge.."LEFT",bar,side.."LEFT",0,offset)
      trim:SetPoint(edge.."RIGHT",bar,side.."RIGHT",0,offset)
      if not CF.Assets:Apply(trim,"CLASSIC_MAXLEVEL") then error("Small unit trim rejected") end
      trim:Show()
    end
    return true, "Classic metal trim; native portrait, bars, predictions, text and layout retained"
  end
  function M:Disable()
    for _,pair in pairs(self.Trims or {}) do
      for _,trim in pairs(pair) do trim:Hide() end
    end
  end
  return M
end
