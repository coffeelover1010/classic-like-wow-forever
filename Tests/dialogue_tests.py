"""Source-shaped NPC window regressions, not engine/taint validation."""
run("quest and gossip preserve controls, materials, reward state and exact rollback", """
local cf=ClassicForeverUI
local accept=QuestFrameAcceptButton:GetScript("OnClick")
local reward=QuestInfoRewardsFrame.RewardButtons[1]
Mock.Event("PLAYER_LOGIN")
local q,g=cf.Modules.QuestDialogue,cf.Modules.GossipDialogue
assert(q.Active and g.Active)
assert(q.Papers[QuestFrameDetailPanel.Bg]:IsShown())
assert(QuestFrameDetailPanel.Bg:GetAtlas()=="QuestBG-Parchment")
assert(QuestFrameDetailPanel.MaterialTopLeft:GetTexture()=="native-material")
assert(QuestFrameAcceptButton:GetScript("OnClick")==accept)
Mock.Click(QuestFrameAcceptButton); assert(Mock.questClicks==1)
Mock.Click(reward); reward:GetScript("OnEnter")(); assert(Mock.selected==reward and Mock.tooltip==reward)
assert(reward.IconBorder:GetTexture()=="quality-border" and reward.Icon:GetTexture()=="reward-icon")
assert(q.Slots[reward]:IsShown() and q.Slots[reward].layer=="ARTWORK")
assert(QuestFrame:GetWidth()==338 and GossipFrame.GreetingPanel.ScrollBox:GetAlpha()==1)
QuestFrame:Hide(); assert(not q.Slots[reward]:IsVisible()); QuestFrame:Show()
GossipFrame.Inset.NineSlice.LeftEdge:SetAtlas("new-native-theme")
SlashCmdList.CLASSICFOREVERUI("off"); Mock.Flush()
assert(GossipFrame.Inset.NineSlice.LeftEdge:GetAtlas()=="new-native-theme")
assert(GossipFrame.Inset.NineSlice.LeftEdge:GetAlpha()==.7)
assert(not q.Slots[reward]:IsShown() and not g.Papers[GossipFrame.Background]:IsShown())
""", "Mock.Dialogues()")

run("partial secure-hook registration can retry without leaving accessibility hooks missing", """
Mock.Event("PLAYER_LOGIN")
local q=ClassicForeverUI.Modules.QuestDialogue
assert(q.State=="ERROR" and not q.Active)
hooksecurefunc=Mock.originalHook
SlashCmdList.CLASSICFOREVERUI("refresh"); Mock.Flush(); assert(q.Active)
local t=q.Papers[QuestFrameDetailPanel.Bg]
QuestFrameDetailPanel.Bg:Hide(); assert(not t:IsShown()); Mock.Flush()
QuestFrameDetailPanel.Bg:Show(); Mock.Flush(); assert(t:IsShown())
""", '''Mock.Dialogues(); Mock.originalHook=hooksecurefunc
hooksecurefunc=function(object,method,callback)
  if object==QuestFrameDetailPanel.Bg and method=="Hide" then error("hook rejected") end
  Mock.originalHook(object,method,callback)
end''')

run("changed inset ownership and unknown backgrounds remain native", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.QuestDialogue.State=="UNAVAILABLE")
local g=ClassicForeverUI.Modules.GossipDialogue
assert(g.Active and not g.Papers[GossipFrame.Background]:IsShown())
""", 'Mock.Dialogues(); QuestFrame.Inset.NineSlice.LeftEdge.parent=UIParent; GossipFrame.Background:SetTexture("custom-background")')

run("accessibility and themed backgrounds immediately reveal native art even in combat", """
Mock.Event("PLAYER_LOGIN")
local q=ClassicForeverUI.Modules.QuestDialogue
local t=q.Papers[QuestFrameDetailPanel.Bg]
Mock.combat=true; local writes=Mock.nativeWrites
QuestFrameDetailPanel.Bg:SetAtlas("QuestBG-Parchment-Accessibility4")
assert(not t:IsShown()); Mock.Flush()
assert(Mock.nativeWrites==writes and ClassicForeverUI.Pending)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(not t:IsShown())
QuestFrameDetailPanel.Bg:SetAtlas("QuestBG-Parchment"); Mock.Flush(); assert(t:IsShown())
GossipFrame.Background:SetAtlas("QuestBG-Dragonflight"); Mock.Flush()
assert(not ClassicForeverUI.Modules.GossipDialogue.Papers[GossipFrame.Background]:IsShown())
QuestFrameDetailPanel.Bg:Hide(); Mock.Flush(); assert(not t:IsShown())
QuestFrameDetailPanel.Bg:Show(); Mock.Flush(); assert(t:IsShown())
""", "Mock.Dialogues()")

run("late reward creation waits for event completion and combat; reuse does not grow art", """
Mock.Event("PLAYER_LOGIN")
local q=ClassicForeverUI.Modules.QuestDialogue
q.EventFrame:GetScript("OnEvent")(q.EventFrame,"QUEST_COMPLETE")
local b=Mock.Reward(); Mock.Flush(); assert(q.Slots[b]:IsShown())
local count=#Mock.frames
Mock.Event("QUEST_ITEM_UPDATE"); Mock.Flush(); assert(#Mock.frames==count)
Mock.combat=true; local c=Mock.Reward(); local writes=Mock.nativeWrites
Mock.Event("QUEST_DETAIL"); Mock.Flush(); assert(not q.Slots[c] and ClassicForeverUI.Pending)
assert(writes==Mock.nativeWrites)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED"); assert(q.Slots[c]:IsShown())
""", "Mock.Dialogues()")

run("missing quest structure isolates fallback from standard gossip and HUD", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.QuestDialogue.State=="UNAVAILABLE")
assert(ClassicForeverUI.Modules.GossipDialogue.Active and ClassicForeverUI.Modules.ActionBars.Active)
assert(QuestFrame.Inset.NineSlice.LeftEdge:GetAlpha()==.7)
""", "Mock.Dialogues(); QuestFrameRewardPanel.Bg=nil")

run("dialogue discovery is late-load safe and settings suspend through Edit Mode", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.QuestDialogue.State=="UNAVAILABLE")
Mock.Dialogues(); Mock.Event("ADDON_LOADED","Blizzard_UIPanels_Game"); Mock.Flush()
local q=ClassicForeverUI.Modules.QuestDialogue; assert(q.Active)
Mock.Callback("EditMode.Enter"); assert(not q.Active)
assert(QuestFrame.Inset.NineSlice.LeftEdge:GetAlpha()==.7)
Mock.Callback("EditMode.Exit"); assert(q.Active)
SlashCmdList.CLASSICFOREVERUI("")
assert(ClassicForeverUI.Options.Rows.QuestDialogue and ClassicForeverUI.Options.Rows.GossipDialogue)
Mock.combat=true; Mock.Click(ClassicForeverUI.Options.Rows.QuestDialogue)
assert(q.Active and ClassicForeverUI.Pending)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(not q.Active and ClassicForeverUI.Modules.GossipDialogue.Active)
""")

run("partial dialogue failure restores inset and retry reuses tracked textures", """
Mock.Event("PLAYER_LOGIN")
local q=ClassicForeverUI.Modules.QuestDialogue
assert(q.State=="ERROR" and not q.Active)
assert(QuestFrame.Inset.NineSlice.LeftEdge:GetAlpha()==.7)
for _,t in pairs(q.Art) do assert(not t:IsShown()) end
assert(ClassicForeverUI.Modules.GossipDialogue.Active)
QuestFrameDetailPanel.Bg.GetAtlas=Mock.savedGetAtlas
SlashCmdList.CLASSICFOREVERUI("refresh"); Mock.Flush(); assert(q.Active)
""", 'Mock.Dialogues(); Mock.savedGetAtlas=QuestFrameDetailPanel.Bg.GetAtlas; QuestFrameDetailPanel.Bg.GetAtlas=function() error("background fault") end')

run("queued reward fault rolls back only quest module and explicit retry recovers", """
Mock.Event("PLAYER_LOGIN")
local q=ClassicForeverUI.Modules.QuestDialogue
local b=Mock.Reward(); b.CreateTexture=function() error("reward fault") end
Mock.Event("QUEST_ITEM_UPDATE"); Mock.Flush()
assert(q.Faulted and q.State=="UPDATE_FAILED" and not q.Active)
assert(ClassicForeverUI.Modules.GossipDialogue.Active)
assert(QuestFrame.Inset.NineSlice.LeftEdge:GetAlpha()==.7)
b.CreateTexture=nil
SlashCmdList.CLASSICFOREVERUI("refresh"); Mock.Flush(); assert(q.Active)
""", "Mock.Dialogues()")

run("missing quest artwork and secure hook API fail without native mutations", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.QuestDialogue.State=="UNAVAILABLE")
assert(QuestFrame.Inset.NineSlice.LeftEdge:GetAlpha()==.7)
assert(ClassicForeverUI.Modules.ActionBars.Active)
""", 'Mock.Dialogues(); hooksecurefunc=nil')

run("missing parchment retains native windows and leaves unit skins running", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.QuestDialogue.State=="UNAVAILABLE")
assert(ClassicForeverUI.Modules.GossipDialogue.State=="UNAVAILABLE")
assert(ClassicForeverUI.Modules.PlayerFrame.Active)
""", r'Mock.Dialogues(); Mock.missingTexture="Interface\\QuestFrame\\UI-QuestGreeting-TopLeft"')

run("disabled modules ignore stale queued work and background hooks", """
Mock.Event("PLAYER_LOGIN")
local q=ClassicForeverUI.Modules.QuestDialogue
q.EventFrame:GetScript("OnEvent")(q.EventFrame,"QUEST_COMPLETE")
ClassicForeverUI.DB.modules.QuestDialogue=false; ClassicForeverUI:Apply()
QuestFrameDetailPanel.Bg:SetAtlas("QuestBG-Parchment"); Mock.Flush()
assert(not q.Active and not q.Papers[QuestFrameDetailPanel.Bg]:IsShown())
assert(QuestFrame.Inset.NineSlice.LeftEdge:GetAlpha()==.7)
""", "Mock.Dialogues()")
