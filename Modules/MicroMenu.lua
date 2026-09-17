local _, CF = ...
local M = {}
function M:Initialize()
  self.Frame = _G.MicroMenuContainer
  if not self.Frame or not _G.MicroMenu then return false,"Retail MicroMenuContainer missing" end
  return true
end
function M:Enable()
  -- Retain modern functions and icons; there is no exact Vanilla counterpart for every Retail button.
  self.Journal:Scale(self.Frame,0.72*CF.API.LayoutScale())
  self.Journal:Point(self.Frame,"BOTTOMRIGHT",UIParent,"BOTTOM",450,5)
  return true,"Native micro menu moved beside action buttons; Retail button artwork retained"
end
function M:Disable() end
function M:Refresh() CF:RequestApply() end
function M:RunDiagnostics() return self.State,self.Detail end
CF:RegisterModule("MicroMenu",M)
