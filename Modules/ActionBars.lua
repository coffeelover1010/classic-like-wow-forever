local _, CF = ...
local M = {}
function M:Initialize()
  self.Bar = _G.MainActionBar
  if not self.Bar then return false, "Retail MainActionBar missing; stock bar retained" end
  self.Buttons = {}
  for i = 1, 12 do
    local button = _G["ActionButton"..i]
    if not button then return false, "ActionButton"..i.." missing" end
    self.Buttons[i] = button
  end
  return CF.Assets:Require({"CLASSIC_MAINBAR_LEFT","CLASSIC_MAINBAR_RIGHT","CLASSIC_MAINBAR_MIDDLE_LEFT",
    "CLASSIC_MAINBAR_MIDDLE_RIGHT","CLASSIC_GRYPHON_LEFT","CLASSIC_GRYPHON_RIGHT","CLASSIC_QUICKSLOT"})
end
function M:Build()
  local dock = CreateFrame("Frame",nil,self.Bar)
  self.Dock = dock
  dock:Hide()
  dock:EnableMouse(false)
  dock:SetSize(1024,43)
  dock:SetPoint("BOTTOMLEFT",self.Bar,"BOTTOMLEFT",-8,-4)
  dock:SetFrameLevel(math.max(0,self.Bar:GetFrameLevel()-1))
  local ids = {"CLASSIC_MAINBAR_LEFT","CLASSIC_MAINBAR_MIDDLE_LEFT","CLASSIC_MAINBAR_MIDDLE_RIGHT","CLASSIC_MAINBAR_RIGHT"}
  for i,id in ipairs(ids) do CF.Visuals:Texture(dock,id,"BACKGROUND",256,43,"BOTTOMLEFT",dock,"BOTTOMLEFT",(i-1)*256,0) end
  CF.Visuals:Texture(dock,"CLASSIC_GRYPHON_LEFT","ARTWORK",128,128,"BOTTOM",dock,"BOTTOMLEFT",-32,0)
  CF.Visuals:Texture(dock,"CLASSIC_GRYPHON_RIGHT","ARTWORK",128,128,"BOTTOM",dock,"BOTTOMRIGHT",32,0)
  self.SlotBorders = {}
  for i,button in ipairs(self.Buttons) do
    self.SlotBorders[i] = CF.Visuals:Texture(button,"CLASSIC_QUICKSLOT","OVERLAY",64,64,
      "CENTER",button,"CENTER",0,0)
  end
end
function M:Enable()
  if not self.Dock then self:Build() end
  local j,scale = self.Journal,CF.API.LayoutScale()
  j:Scale(self.Bar,scale)
  j:Size(self.Bar,498,36)
  -- The native bar remains parent of every button and owns secure paging.
  j:Point(self.Bar,"BOTTOMLEFT",UIParent,"BOTTOM",-504,4)
  j:Alpha(self.Bar.BorderArt,0)
  j:Alpha(self.Bar.EndCaps,0)
  for i,button in ipairs(self.Buttons) do
    j:Size(button,36,36)
    j:Point(button,"BOTTOMLEFT",self.Bar,"BOTTOMLEFT",(i-1)*42,0)
    j:Alpha(button.SlotBackground,0)
    j:Alpha(button.SlotArt,0)
    j:Alpha(button.NormalTexture,0)
    self.SlotBorders[i]:Show()
  end
  if self.Bar.ActionBarPageNumber then
    j:Point(self.Bar.ActionBarPageNumber,"LEFT",self.Bar,"RIGHT",6,0)
  end
  for _,poolName in ipairs({"HorizontalDividersPool","VerticalDividersPool"}) do
    local pool = self.Bar[poolName]
    if pool and pool.EnumerateActive then for divider in pool:EnumerateActive() do j:Alpha(divider,0) end end
  end
  -- Keep the native extra bars and tracking UI usable above the stone strip.
  for _,item in ipairs({{"MultiBarBottomLeft",-504,86},{"MultiBarBottomRight",12,86}}) do
    local frame = _G[item[1]]
    if frame then j:Scale(frame,scale); j:Point(frame,"BOTTOMLEFT",UIParent,"BOTTOM",item[2],item[3]) end
  end
  for i,name in ipairs({"MainStatusTrackingBarContainer","SecondaryStatusTrackingBarContainer"}) do
    local frame = _G[name]
    if frame then
      j:Scale(frame,scale)
      j:Point(frame,"BOTTOM",UIParent,"BOTTOM",0,43+(i-1)*17)
    end
  end
  self.Dock:Show()
  return true, "12 native action buttons, original stone/gryphons; paging and override bars remain Blizzard-owned"
end
function M:Disable()
  if self.Dock then self.Dock:Hide() end
  for _,border in ipairs(self.SlotBorders or {}) do border:Hide() end
end
function M:Refresh() CF:RequestApply() end
function M:RunDiagnostics() return self.State,self.Detail end
CF:RegisterModule("ActionBars",M)
