local _, CF = ...
local M = {}
function M:Initialize()
  self.Frame = _G.BagsBar
  if not self.Frame then return false,"Retail BagsBar missing" end
  return true
end
function M:Enable()
  self.Journal:Scale(self.Frame,0.75*CF.API.LayoutScale())
  self.Journal:Point(self.Frame,"BOTTOMRIGHT",UIParent,"BOTTOM",675,0)
  return true,"Native bag buttons, reagent bag, expand toggle and clicks retained"
end
function M:Disable() end
function M:Refresh() CF:RequestApply() end
function M:RunDiagnostics() return self.State,self.Detail end
CF:RegisterModule("Bags",M)
