local _, CF = ...
local P=CF.PassiveSkin
local M=P:New(function()
  local f=_G.FocusFrame
  local c=CF.Compat:Path(f,"TargetFrameContent","TargetFrameContentMain")
  local health=c and c.HealthBarsContainer; local power=c and c.ManaBar
  if f and not CF.API.IsSecret(f.smallSize) and f.smallSize==true and
      P:Owned(f,f.TargetFrameContent) and P:Owned(f.TargetFrameContent,c) and
      P:Owned(c,health,power) and P:Owned(health,health.HealthBar) then
    return {{key="health",owner=c,anchor=health,edge="TOP",outside=1,asset="CLASSIC_MAXLEVEL"},
      {key="power",owner=c,anchor=power,edge="BOTTOM",outside=1,asset="CLASSIC_MAXLEVEL"}}
  end
  return {}
end,{"CLASSIC_MAXLEVEL"},{"PLAYER_FOCUS_CHANGED"},
  "Compact focus exterior trim; native scale, health, predictions, power, auras and portrait retained.")
local initialize=M.Initialize
M.FocusHooks={}
function M:Initialize()
  local f=_G.FocusFrame
  if f and type(f.SetSmallSize)=="function" and type(hooksecurefunc)=="function" and not self.FocusHooks[f] then
    hooksecurefunc(f,"SetSmallSize",function()
      self:HideArt(); CF:RequestApply()
    end)
    self.FocusHooks[f]=true
  end
  return initialize(self)
end
CF:RegisterModule("CompactFocus",M)
