local _, CF = ...
local M = {}
function M:Initialize()
  self.Frame,self.Cluster = _G.Minimap,_G.MinimapCluster
  if not self.Frame or not self.Cluster then return false,"Minimap or MinimapCluster missing" end
  return CF.Assets:Require({"CLASSIC_MINIMAP_BORDER"})
end
function M:Enable()
  local j = self.Journal
  j:Point(self.Cluster,"TOPRIGHT",UIParent,"TOPRIGHT",-12,-12)
  j:Scale(self.Cluster,0.8)
  -- Preserve native map, mask, clicks, tracking, zoom and minimap buttons.
  j:Alpha(_G.MinimapCompassTexture,0)
  j:Alpha(_G.MinimapBorder,0)
  if not self.Visual then
    self.Visual = CreateFrame("Frame",nil,self.Frame)
    self.Visual:EnableMouse(false)
    self.Visual:SetAllPoints(self.Frame)
    self.Visual:SetFrameLevel(self.Frame:GetFrameLevel()+3)
    -- Original sheet ring is centered at (168,104); this crop's center is (160,128).
    self.Visual.Border = CF.Visuals:Texture(self.Visual,"CLASSIC_MINIMAP_BORDER","OVERLAY",
      264,264,"CENTER",self.Frame,"CENTER",-11,-33)
  end
  self.Visual:Show()
  return true,"Original round minimap border; native map and controls retained"
end
function M:Disable() if self.Visual then self.Visual:Hide() end end
function M:Refresh() CF:RequestApply() end
function M:RunDiagnostics() return self.State,self.Detail end
CF:RegisterModule("Minimap",M)
