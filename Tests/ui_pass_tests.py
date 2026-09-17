"""Additional 0.5 cases, executed by run_tests.py with its isolated run helper."""

run("native health predictions and shields retain state, geometry and scripts", """
local cf=ClassicForeverUI
local bars={PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer,
  TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer}
local snapshots={}
for i,h in ipairs(bars) do
  snapshots[i]={h:GetPoint(1)}
  h.HealthBar.MyHealPredictionBar:Hide()
end
Mock.Event("PLAYER_LOGIN")
for i,h in ipairs(bars) do
  assert(h:GetAlpha()==1 and h.HealthBar:GetAlpha()==1)
  assert(h:GetWidth()==(i==1 and 124 or 126) and h.HealthBar:GetHeight()==20)
  assert(h.HealthBar.value==37 and h.HealthBar:GetStatusBarTexture():GetTexture()=="native-health")
  assert(h.HealthBar:GetScript("OnValueChanged"))
  assert(h.HealthBar.TotalAbsorbBar:GetAlpha()==1 and h.HealthBar.TotalAbsorbBar:IsVisible())
  assert(not h.HealthBar.MyHealPredictionBar:IsShown())
  assert(h.HealthBar:GetParent()==h and h.HealthBarMask:GetAlpha()==1)
  assert(h:GetFrameLevel()>cf.Modules.PlayerFrame.Visual:GetFrameLevel())
end
assert(not cf.Modules.PlayerFrame.Visual.Health and not cf.Modules.TargetFrame.Visual.HealthText)
Mock.combat=true
local writes=Mock.nativeWrites
bars[1].HealthBar.MyHealPredictionBar:Show()
bars[1].HealthBar.TotalAbsorbBar:Hide()
Mock.Event("UNIT_HEALTH","player")
assert(Mock.nativeWrites==writes)
SlashCmdList.CLASSICFOREVERUI("off"); Mock.Flush()
assert(cf.Pending)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
for i,h in ipairs(bars) do
  assert(h:GetFrameLevel()==50 and h.HealthBar:GetFrameLevel()==50)
  local point={h:GetPoint(1)}
  for n,v in ipairs(snapshots[i]) do assert(point[n]==v) end
end
assert(bars[1].HealthBar.MyHealPredictionBar:IsShown())
assert(not bars[1].HealthBar.TotalAbsorbBar:IsShown())
""")

run("unit skin no longer reads or writes native health values", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.PlayerFrame.Active and ClassicForeverUI.Modules.TargetFrame.Active)
Mock.combat=true; Mock.Event("UNIT_HEALTH","player")
assert(ClassicForeverUI.Modules.PlayerFrame.Active)
""", 'UnitHealth=function() error("health must stay native") end; UnitHealthMax=UnitHealth')

run("changed native health hierarchy retains stock unit frame", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.PlayerFrame.State=="UNAVAILABLE")
assert(PlayerFrame.PlayerFrameContainer:GetAlpha()==1)
assert(ClassicForeverUI.Modules.TargetFrame.Active)
""", 'PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.HealthBarsContainer.HealthBar=nil')

run("aura skin preserves clicks, timers, colors and hidden pooled entries", """
local b=BuffFrame.auraFrames[1]
local click,update=b:GetScript("OnClick"),b:GetScript("OnUpdate")
b:Hide()
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI; local m=cf.Modules.Buffs
assert(m.Active and cf.Modules.Debuffs.Active)
assert(m.Borders[b] and not m.Borders[b]:IsVisible())
b:Show()
assert(m.Borders[b]:IsVisible() and m.Borders[b].layer=="ARTWORK")
assert(b:GetScript("OnClick")==click and b:GetScript("OnUpdate")==update)
for _,key in ipairs({"Icon","Count","Duration","DebuffBorder","TempEnchantBorder"}) do
  assert(b[key]:GetAlpha()==1 and b[key]:GetTexture()=="native-"..key)
end
local count=#Mock.frames
for i=1,4 do Mock.Event("UNIT_AURA","player") end
assert(#Mock.frames==count)
cf:SetModuleEnabled("Buffs",false); Mock.Flush()
assert(not m.Borders[b]:IsShown() and cf.Modules.Debuffs.Active)
""")

run("aura private anchors stay untouched and new buttons defer in combat", """
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI; local m=cf.Modules.Buffs
local b=Mock.Aura(BuffFrame)
local private=Mock.Native(nil,BuffFrame); private.Icon={}
BuffFrame.auraFrames[#BuffFrame.auraFrames+1]=private
Mock.combat=true
local count,writes=#Mock.frames,Mock.nativeWrites
Mock.Event("UNIT_AURA","player")
assert(cf.Pending and not m.Borders[b] and #Mock.frames==count and writes==Mock.nativeWrites)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(m.Borders[b]:IsShown() and not m.Borders[private])
""")

run("aura runtime artwork failure isolates and restores one module", """
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI; local m=cf.Modules.Buffs
m.Borders[BuffFrame.auraFrames[1]].SetTexture=function() error("texture rejected") end
Mock.Event("UNIT_AURA","player")
assert(m.Faulted and not m.Active and m.State=="UPDATE_FAILED")
for _,border in pairs(m.Borders) do assert(not border:IsShown()) end
assert(cf.Modules.Debuffs.Active and cf.Modules.Tooltips.Active)
""")

run("tooltip content, scripts, anchors, resizing and embedded visibility stay native", """
local cf=ClassicForeverUI; local tip=GameTooltip
local show,clear=tip:GetScript("OnShow"),tip:GetScript("OnTooltipCleared")
Mock.Event("PLAYER_LOGIN")
local skin=cf.Modules.Tooltips.Skins[tip]
assert(skin and not skin:IsVisible() and skin.mouse==false)
tip:Show(); assert(skin:IsVisible())
assert(skin:GetParent()==tip.NineSlice and skin.allPoints==tip)
assert(skin:GetFrameLevel()<tip:GetFrameLevel())
assert(tip.NineSlice.Center:GetAlpha()==0 and tip.NineSlice:GetAlpha()==1)
assert(tip:GetScript("OnShow")==show and tip:GetScript("OnTooltipCleared")==clear)
tip:SetSize(440,500); assert(tip:GetWidth()==440 and skin.allPoints==tip)
tip.NineSlice:Hide(); assert(not skin:IsVisible())
cf:SetModuleEnabled("Tooltips",false); Mock.Flush()
assert(not skin:IsShown() and not tip.NineSlice:IsShown())
assert(tip.NineSlice.Center:GetAlpha()==0.8 and tip:GetWidth()==440)
assert(ShoppingTooltip1.NineSlice.Center:GetAlpha()==0.8)
""")

run("tooltip missing artwork leaves native backdrop and other modules intact", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.Tooltips.State=="UNAVAILABLE")
assert(GameTooltip.NineSlice.Center:GetAlpha()==0.8 and ClassicForeverUI.Modules.Buffs.Active)
""", r'Mock.missingTexture="Interface\\Tooltips\\UI-Tooltip-Border"')

run("partial tooltip enable failure restores every masked native region", """
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI; local m=cf.Modules.Tooltips
assert(m.State=="ERROR" and not m.Active)
assert(GameTooltip.NineSlice.Center:GetAlpha()==0.8)
for _,skin in pairs(m.Skins) do assert(not skin:IsShown()) end
assert(cf.Modules.QuestTracker.Active)
""", '''
local original=CreateFrame
CreateFrame=function(kind,name,parent,template)
  local frame=original(kind,name,parent,template)
  if parent==ItemRefTooltip.NineSlice then frame.SetBackdrop=function() error("backdrop failure") end end
  return frame
end
''')

run("tracker header rolls back atlas and crop without altering controls or layout", """
local h=ObjectiveTrackerFrame.Header
local click=h.MinimizeButton:GetScript("OnClick")
h.Background:SetTexCoord(0.1,0.9,0.2,0.8)
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI; local m=cf.Modules.QuestTracker
assert(m.Active and m.Trim[h]:IsShown())
assert(h.MinimizeButton:GetScript("OnClick")==click and h.MinimizeButton:GetAlpha()==1)
assert(ObjectiveTrackerFrame:GetWidth()==232)
local count=#Mock.frames
Mock.Callback("EditMode.Enter")
assert(h.Background:GetAtlas()=="native-tracker" and not m.Trim[h]:IsShown())
ObjectiveTrackerFrame:SetSize(350,600)
Mock.Callback("EditMode.Exit")
assert(m.Active and #Mock.frames==count and ObjectiveTrackerFrame:GetWidth()==350)
cf:SetModuleEnabled("QuestTracker",false); Mock.Flush()
local a,b,c,d=h.Background:GetTexCoord()
assert(a==0.1 and b==0.9 and c==0.2 and d==0.8)
assert(h.Background:GetAtlas()=="native-tracker" and ObjectiveTrackerFrame:GetHeight()==600)
""")

run("late native frames recover independently after addon loading", """
local b,t,q=BuffFrame,GameTooltip,ObjectiveTrackerFrame
BuffFrame=nil; GameTooltip=nil; ObjectiveTrackerFrame=nil
ItemRefTooltip=nil; ShoppingTooltip1=nil; ShoppingTooltip2=nil
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI
for _,name in ipairs({"Buffs","Tooltips","QuestTracker"}) do assert(cf.Modules[name].State=="UNAVAILABLE") end
assert(cf.Modules.Debuffs.Active)
BuffFrame=b; GameTooltip=t; ObjectiveTrackerFrame=q
Mock.Event("ADDON_LOADED","Blizzard_ObjectiveTracker")
for _,name in ipairs({"Buffs","Tooltips","QuestTracker"}) do assert(cf.Modules[name].Active) end
""")

run("all four new choices save and defer their restore during combat", """
Mock.Event("PLAYER_LOGIN"); SlashCmdList.CLASSICFOREVERUI("")
local cf=ClassicForeverUI
Mock.combat=true
local writes=Mock.nativeWrites
for _,name in ipairs({"Buffs","Debuffs","Tooltips","QuestTracker"}) do
  Mock.Click(cf.Options.Rows[name])
  assert(cf.Modules[name].Active and cf.DB.modules[name]==false)
  assert(cf.Options.Rows[name].Status.text=="Queued")
end
assert(Mock.nativeWrites==writes)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
for _,name in ipairs({"Buffs","Debuffs","Tooltips","QuestTracker"}) do
  assert(not cf.Modules[name].Active and cf.Options.Rows[name].Status.text=="Off")
end
assert(cf.Modules.PlayerFrame.Active)
""")
