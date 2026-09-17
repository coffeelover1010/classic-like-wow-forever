local _, CF = ...
local M = { Art={}, Papers={} }
function M:Initialize()
  local f = _G.GossipFrame
  if not CF.DialogueSkin:Validate(f) or not f.Background or f.Background:GetParent() ~= f or
      not f.GreetingPanel or f.GreetingPanel:GetParent() ~= f or
      not f.GreetingPanel.ScrollBox or not f.GreetingPanel.ScrollBar or not f.GreetingPanel.GoodbyeButton then
    return false, "Standard gossip structure missing; native dialogue retained"
  end
  self.Frame=f
  return CF.DialogueSkin:Require()
end
function M:RefreshArt() CF.DialogueSkin:Paper(self,self.Frame.Background) end
function M:Enable()
  CF.DialogueSkin:Border(self,self.Frame)
  self:RefreshArt()
  CF.Events:Bind(self,{"GOSSIP_SHOW"},function(m) CF.DialogueSkin:Queue(m) end)
  return true, "Standard gossip parchment/inset; native Classic goodbye button, choices, scroll and friendship controls retained. Themed backgrounds and custom dialogue unchanged"
end
function M:Disable() CF.DialogueSkin:Disable(self) end
CF:RegisterModule("GossipDialogue",M)
