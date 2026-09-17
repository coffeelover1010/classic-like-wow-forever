local _, CF = ...
local M = { Art={}, Papers={}, Slots={} }
local panelNames = {"QuestFrameDetailPanel","QuestFrameProgressPanel","QuestFrameRewardPanel","QuestFrameGreetingPanel"}
function M:Initialize()
  if not CF.DialogueSkin:Validate(_G.QuestFrame) then return false, "Standard quest inset missing; native window retained" end
  self.Panels = {}
  for _,name in ipairs(panelNames) do
    local panel = _G[name]
    if not panel or panel:GetParent() ~= QuestFrame or not panel.Bg or
        panel.Bg:GetParent() ~= panel or not panel.MaterialTopLeft then
      return false, "Standard quest panel missing; native window retained"
    end
    self.Panels[#self.Panels+1] = panel
  end
  return CF.DialogueSkin:Require(true)
end
function M:RefreshArt()
  for _,panel in ipairs(self.Panels) do CF.DialogueSkin:Paper(self,panel.Bg) end
  local rewards = _G.QuestInfoRewardsFrame
  if not rewards or type(rewards.RewardButtons) ~= "table" then return end
  -- Only the large NPC reward list, never MapQuestInfoRewardsFrame or spell pools.
  for _,button in ipairs(rewards.RewardButtons) do
    if button:GetParent() == rewards and button.Icon and button.Icon:GetParent() == button and button.NameFrame then
      local t = self.Slots[button]
      if not t then
        t=button:CreateTexture(nil,"ARTWORK",nil,-2)
        self.Slots[button]=t; t:Hide()
        t:SetPoint("TOPLEFT",button.Icon,"TOPLEFT",-10,10)
        t:SetPoint("BOTTOMRIGHT",button.Icon,"BOTTOMRIGHT",10,-10)
      end
      if not CF.Assets:Apply(t,"CLASSIC_QUICKSLOT") then error("Quest reward trim rejected") end
      t:Show()
    end
  end
end
function M:Enable()
  CF.DialogueSkin:Border(self,QuestFrame)
  self:RefreshArt()
  CF.Events:Bind(self,{"QUEST_DETAIL","QUEST_PROGRESS","QUEST_COMPLETE","QUEST_GREETING",
    "QUEST_ITEM_UPDATE","LEARNED_SPELL_IN_SKILL_LINE"},function(m) CF.DialogueSkin:Queue(m) end)
  return true, "Standard NPC quest parchment/inset/reward trim; native Classic buttons retained. Special materials, contrast backgrounds, map/popups and spell rewards unchanged"
end
function M:Disable()
  CF.DialogueSkin:Disable(self)
  for _,t in pairs(self.Slots) do t:Hide() end
end
CF:RegisterModule("QuestDialogue",M)
