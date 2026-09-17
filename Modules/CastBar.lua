local _, CF = ...
local M = {}
function M:Initialize()
  self.Frame = _G.PlayerCastingBarFrame
  if not self.Frame or not self.Frame.Border then return false,"Retail PlayerCastingBarFrame missing" end
  return CF.Assets:Require({"CLASSIC_CAST_BORDER"})
end
function M:Enable()
  local f,j = self.Frame,self.Journal
  j:Point(f,"BOTTOM",UIParent,"BOTTOM",0,155)
  -- Keep Blizzard's duration, channel, empower stages, interrupt state and secret values.
  j:Alpha(f.Border,0)
  if not self.Visual then
    self.Visual = CreateFrame("Frame",nil,f)
    self.Visual:SetAllPoints()
    self.Visual:EnableMouse(false)
    self.Visual:SetFrameLevel(f:GetFrameLevel()+1)
    self.Visual.Border = CF.Visuals:Texture(self.Visual,"CLASSIC_CAST_BORDER","ARTWORK",
      f:GetWidth()*1.28,64,"CENTER",f,"CENTER",0,0)
  end
  self.Visual:Show()
  return true,"Original border and Classic position; native cast/channel/empower engine retained"
end
function M:Disable() if self.Visual then self.Visual:Hide() end end
function M:Refresh() CF:RequestApply() end
function M:RunDiagnostics() return self.State,self.Detail end
CF:RegisterModule("CastBar",M)
