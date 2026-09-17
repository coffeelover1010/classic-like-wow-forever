"""Behavior/failure tests for the remaining scoped feature pass; no live transactions."""
FEATURES = WINDOWS + (ROOT / "Tests/FeatureFixtures.lua").read_text()

run("new window skins preserve native actions and correctly scope shared insets", '''
local action=TradeFrame.Action:GetScript("OnClick")
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI
for name,count in pairs({MailWindow=3,TradeWindow=6,InspectWindow=1,TrainerWindow=2,LootWindow=1,MerchantWindow=3}) do
 local m=cf.Modules[name]; assert(m.Active and m.Detail:find("borders: "..count),name..":"..tostring(m.Detail))
end
assert(TradeFrame.Action:GetScript("OnClick")==action and TradeFrame.Action.secureToken=="native")
local m=cf.Modules.MailWindow
SendMailFrame:Hide()
assert(not m.Art[SendMailMoneyInset.NineSlice.LeftEdge]:IsVisible())
assert(m.Art[MailFrame.Inset.NineSlice.LeftEdge]:IsVisible())
OpenMailFrame:Hide(); assert(not m.Art[OpenMailFrame.Inset.NineSlice.LeftEdge]:IsVisible())
assert(not cf.Modules.TrainerWindow.Art[ClassTrainerFrame.bottomInset.NineSlice.LeftEdge]:IsVisible())
''', FEATURES)

run("loot skin never decorates pooled cards or changes looting animation and inputs", '''
local f=LootFrame; local row=f.ScrollBox.Row; local click=row.Item:GetScript("OnClick")
Mock.Event("PLAYER_LOGIN"); local m=ClassicForeverUI.Modules.LootWindow
local writes=Mock.nativeWrites; local count=#Mock.frames
Mock.Event("LOOT_OPENED"); Mock.Event("LOOT_CLOSED"); Mock.Flush()
assert(Mock.nativeWrites==writes and #Mock.frames==count)
assert(f.ScrollBox.pool.sentinel=="native-pool" and row.Item:GetScript("OnClick")==click)
assert(row.QualityStripe:GetTexture()=="native-QualityStripe" and row.IconQuestTexture:GetTexture()=="native-IconQuestTexture")
for _,t in pairs(m.Art) do assert(t:GetParent()==f.NineSlice) end
f:Hide(); for _,t in pairs(m.Art) do assert(not t:IsVisible()) end
''', FEATURES)

run("window discovery retries missing frames on their open event without a reload", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI
assert(cf.Modules.MailWindow.State=="UNAVAILABLE")
Mock.MoreWindows(); Mock.Event("MAIL_SHOW"); Mock.Flush()
assert(cf.Modules.MailWindow.Active and cf.Modules.LootWindow.Active)
cf:SetModuleEnabled("MailWindow",false); Mock.Flush()
Mock.Event("MAIL_SHOW"); Mock.Flush(); assert(not cf.Modules.MailWindow.Active)
''', FEATURES+'\nMailFrame=nil; OpenMailFrame=nil; LootFrame=nil')

run("new window structures fail closed and theme tint reveals native art in combat", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI
assert(cf.Modules.InspectWindow.State=="UNAVAILABLE" and cf.Modules.LootWindow.State=="UNAVAILABLE")
assert(cf.Modules.TradeWindow.Detail:find("borders: 5"))
local m=cf.Modules.MailWindow; local n=MailFrame.Inset.NineSlice.LeftEdge
Mock.combat=true; local writes=Mock.nativeWrites
n:SetVertexColor(.4,.4,.4,1)
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
Mock.Flush(); assert(cf.Pending and Mock.nativeWrites==writes)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(m.Detail:find("borders: 2"))
n:SetVertexColor(1,1,1,1); Mock.Flush(); assert(m.Detail:find("borders: 3"))
''', FEATURES+'\nInspectFrame.Inset.parent=UIParent; LootFrame.ScrollBox.parent=UIParent; TradePlayerItemsInset.NineSlice.LeftEdge=nil')

run("window native alpha is followed without changing native border properties", '''
Mock.Event("PLAYER_LOGIN"); local m=ClassicForeverUI.Modules.MailWindow
local n=MailFrame.Inset.NineSlice.LeftEdge; n:SetAlpha(.25); Mock.Flush()
assert(m.Art[n]:GetAlpha()==.25 and n:GetAlpha()==.25)
''', FEATURES)

run("target and focus cast skins preserve restricted values indicators scripts and anchors", '''
local f=TargetFrame.spellbar; local onupdate=f:GetScript("OnUpdate"); local onEvent=f:GetScript("OnEvent")
local p,r,rp,x,y=f:GetPoint(1); local level=f:GetFrameLevel()
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI
assert(cf.Modules.TargetCastBar.Active and cf.Modules.FocusCastBar.Active)
assert(f.value==Mock.secret and f.empowerStages.sentinel=="native-stages")
assert(f:GetScript("OnUpdate")==onupdate and f:GetScript("OnEvent")==onEvent)
assert(f:GetWidth()==150 and f:GetHeight()==10 and f:GetFrameLevel()==level)
local p2,r2,rp2,x2,y2=f:GetPoint(1); assert(p==p2 and r==r2 and x==x2 and y==y2)
assert(not f.BorderShield:IsShown() and f.Border:GetAtlas()=="ui-castingbar-frame")
f.BorderShield:Show(); f.Flash:Hide(); cf:SetModuleEnabled("TargetCastBar",false); Mock.Flush()
assert(f.BorderShield:IsShown() and not f.Flash:IsShown() and cf.Modules.FocusCastBar.Active)
''', FEATURES)

run("late native spell bars discover on target change and create no art during combat", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI
assert(cf.Modules.TargetCastBar.State=="UNAVAILABLE")
Mock.Casts(); Mock.combat=true; local writes=Mock.nativeWrites; local frames=#Mock.frames
Mock.Event("PLAYER_TARGET_CHANGED"); Mock.Flush()
assert(cf.Pending and Mock.nativeWrites==writes and #Mock.frames==frames)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED"); assert(cf.Modules.TargetCastBar.Active)
''', FEATURES+'\nTargetFrame.spellbar=nil; FocusFrame.spellbar=nil')

run("cast theme changes hide passive surround immediately and partial errors roll back", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI; local m=cf.Modules.TargetCastBar
Mock.combat=true; TargetFrame.spellbar.Border:SetAtlas("new-cast-theme")
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
Mock.Flush(); Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(m.Detail:find("pieces: 0") and cf.Modules.FocusCastBar.Active)
TargetFrame.spellbar.Border:SetAtlas("ui-castingbar-frame"); Mock.Flush()
local t=m.Art[TargetFrame.spellbar.Border]; local original=t.SetTexture
t.SetTexture=function() error("texture failure") end
Mock.Event("PLAYER_TARGET_CHANGED"); Mock.Flush()
assert(m.State=="UPDATE_FAILED" and not t:IsShown() and cf.Modules.FocusCastBar.Active)
t.SetTexture=original; cf:RetryModules(); Mock.Flush(); assert(m.Active)
''', FEATURES)

run("micro art uses native state textures and restores exactly while leaving alerts intact", '''
local b=QuestLogMicroButton; local click=b:GetScript("OnClick"); local down=b:GetScript("OnMouseDown")
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI
assert(cf.Modules.MicroArtwork.Detail:find("2/2"))
assert(b.Normal:GetTexture():find("Quest%-Up") and b.Pushed:GetTexture():find("Quest%-Down"))
assert(b.Disabled:GetTexture():find("Quest%-Disabled") and b.Highlight:GetAtlas()=="native-highlight")
assert(b:GetScript("OnClick")==click and b:GetScript("OnMouseDown")==down and b:GetParent()==MicroMenu)
cf:SetModuleEnabled("MicroArtwork",false); Mock.Flush()
assert(b.Normal:GetAtlas()=="UI-HUD-MicroMenu-Questlog-Up")
assert(b.Pushed:GetAtlas()=="UI-HUD-MicroMenu-Questlog-Down")
assert(b.Disabled:GetAtlas()=="UI-HUD-MicroMenu-Questlog-Disabled")
''', FEATURES)

run("micro rollback preserves a newer native theme and skips changed buttons", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI; local b=QuestLogMicroButton
assert(cf.Modules.MicroArtwork.Detail:find("1/2"))
Mock.combat=true; b.Normal:SetAtlas("new-theme"); b.Normal:SetTexCoord(.1,.9,.1,.9)
cf:SetModuleEnabled("MicroArtwork",false); Mock.Flush()
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(b.Normal:GetAtlas()=="new-theme" and b.Pushed:GetAtlas()=="UI-HUD-MicroMenu-Questlog-Down")
local c={b.Normal:GetTexCoord()}; assert(c[1]==.1)
''', FEATURES+'\nPlayerSpellsMicroButton.Disabled:SetAtlas("new-state")')

run("micro partial crop failure rolls back prior states and isolates the module", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI
assert(cf.Modules.MicroArtwork.State=="ERROR" and not cf.Modules.MicroArtwork.Active)
assert(QuestLogMicroButton.Normal:GetAtlas()=="UI-HUD-MicroMenu-Questlog-Up")
assert(QuestLogMicroButton.Pushed:GetAtlas()=="UI-HUD-MicroMenu-Questlog-Down")
assert(cf.Modules.ActionBars.Active)
''', FEATURES+'''
local t=QuestLogMicroButton.Pushed; local original=t.SetTexCoord; local once=true
t.SetTexCoord=function(self,...) if once then once=false; error("crop error") end; return original(self,...) end
''')

run("minimap details preserve clock tracking and utility controls and respect themes", '''
local clock=TimeManagerClockButton; local click=clock:GetScript("OnClick")
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI; local m=cf.Modules.MinimapDetails
assert(m.Active and m.Detail:find("pieces: 5"))
assert(clock:GetScript("OnClick")==click and TimeManagerClockTicker.text=="19:42")
local writes=Mock.nativeWrites
Mock.combat=true; MinimapCluster.BorderTop.Center:SetAtlas("contrast-header")
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
Mock.Flush(); assert(Mock.nativeWrites==writes)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED"); assert(m.Detail:find("pieces: 1"))
''', FEATURES)

run("bag artwork retains circular masks native icons reagent slot and count", '''
local b=CharacterReagentBag0Slot; local click=b:GetScript("OnClick")
Mock.Event("PLAYER_LOGIN"); local m=ClassicForeverUI.Modules.BagArtwork
assert(m.Active and m.Detail:find("pieces: 6"))
assert(b:GetScript("OnClick")==click and b.icon:GetTexture()=="native-icon")
assert(b.CircleMask:GetAlpha()==1 and b:GetParent()==BagsBar)
ClassicForeverUI:SetModuleEnabled("Bags",false); Mock.Flush(); assert(m.Active)
''', FEATURES)

run("character reputation currency overlays follow page visibility and preserve row engines", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI; local m=cf.Modules.CharacterPages
assert(m.Active and m.Detail:find("pieces: 18"))
for _,t in pairs(m.Art) do assert(not t:IsVisible()) end
ReputationFrame:Show(); assert(m.Art[ReputationFrame]:IsVisible() and not m.Art[TokenFrame]:IsVisible())
ReputationFrame:Hide(); TokenFrame:Show(); assert(m.Art[TokenFrame]:IsVisible())
local writes=Mock.nativeWrites
Mock.Event("UPDATE_FACTION"); Mock.Event("CURRENCY_DISPLAY_UPDATE"); Mock.Flush(); assert(Mock.nativeWrites==writes)
Mock.combat=true; CharacterFrame.Background:SetVertexColor(.2,.2,.2,1)
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
Mock.Flush(); Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED"); assert(m.Detail:find("pieces: 0"))
''', FEATURES)

run("compact focus and focus-target never replace native values or protected behavior", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI
assert(cf.Modules.FocusTarget.Active and not cf.Modules.CompactFocus.Active)
FocusFrame:SetSmallSize(true); Mock.Flush()
assert(cf.Modules.CompactFocus.Active and not cf.Modules.FocusFrame.Active)
local main=FocusFrame.TargetFrameContent.TargetFrameContentMain
assert(main.HealthBarsContainer.HealthBar:GetAlpha()==1 and main.ManaBar:GetAlpha()==1)
local writes=Mock.nativeWrites; local m=cf.Modules.CompactFocus
m:RefreshArt(); assert(writes==Mock.nativeWrites and m.Detail:find("pieces: 2"))
Mock.combat=true; FocusFrame:SetSmallSize(false)
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
Mock.Flush(); assert(cf.Pending and Mock.nativeWrites==writes)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(cf.Modules.FocusFrame.Active and not m.Active)
''', FEATURES)

run("restricted compact mode and changed focus-target ownership fail closed", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI
assert(not cf.Modules.CompactFocus.Active and not cf.Modules.FocusTarget.Active)
assert(cf.Modules.TargetFrame.Active)
''', FEATURES+'\nFocusFrame.smallSize=Mock.secret; FocusFrame.totFrame.parent=UIParent')

run("item trim leaves all native item state scripts and data untouched", '''
local b=ContainerFrame1.Items[1]; local click=b:GetScript("OnClick"); local drag=b:GetScript("OnDragStart")
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI; local m=cf.Modules.ItemSlots
assert(m.Active and m.Detail:find("pieces: 21"),m.Detail)
local buyback=MerchantBuyBackItemItemButton
assert(m.Art[buyback.icon]:IsShown() and buyback.UndoFrame.Arrow:GetAtlas()=="common-icon-undo")
local writes=Mock.nativeWrites
Mock.Event("MERCHANT_UPDATE"); Mock.Event("BAG_UPDATE_DELAYED"); Mock.Flush()
assert(Mock.nativeWrites==writes and b:GetScript("OnClick")==click and b:GetScript("OnDragStart")==drag)
assert(b.secureToken=="native-item" and b.icon:GetTexture()=="native-icon" and b.IconBorder:GetTexture()=="native-IconBorder")
assert(b.IconQuestTexture:GetTexture()=="native-IconQuestTexture" and b.searchOverlay:GetAlpha()==1)
for _,t in pairs(m.Art) do assert(t.layer=="BACKGROUND") end
''', FEATURES)

run("bag and bank pool growth reuse and release track art without control mutation", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI; local m=cf.Modules.ItemSlots
local old=ContainerFrame1.Items[1]; old:Hide()
local b=Mock.Item(ContainerFrame1); b.emptyBackgroundAtlas="bags-item-slot64"; ContainerFrame1.Items={b}
ContainerFrame1:UpdateItemSlots(); Mock.Flush()
assert(not m.Art[old.icon]:IsShown() and m.Art[b.icon]:IsShown())
local panel=BankFrame.BankPanel; local item=Mock.Item(panel); item.Background:SetAtlas("bags-item-slot64")
panel.itemButtonPool.active[item]=true; panel:GenerateItemSlotsForSelectedTab(); Mock.Flush()
assert(m.Art[item.icon]:IsShown())
local count=#Mock.frames
panel:GenerateItemSlotsForSelectedTab(); Mock.Flush(); assert(#Mock.frames==count)
panel.itemButtonPool.active[item]=nil; item:Hide(); panel:GenerateItemSlotsForSelectedTab(); Mock.Flush()
assert(not m.Art[item.icon]:IsShown())
''', FEATURES)

run("new pooled items wait through combat and stale callbacks cannot revive disabled skins", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI; local m=cf.Modules.ItemSlots
local b=Mock.Item(ContainerFrame1); b.emptyBackgroundAtlas="bags-item-slot64"; ContainerFrame1.Items[2]=b
Mock.combat=true; local writes=Mock.nativeWrites; local count=#Mock.frames
ContainerFrame1:UpdateItemSlots(); Mock.Flush()
assert(cf.Pending and not m.Art[b.icon] and writes==Mock.nativeWrites and count==#Mock.frames)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED"); assert(m.Art[b.icon]:IsShown())
ContainerFrame1:UpdateItemSlots(); cf:SetModuleEnabled("ItemSlots",false); cf:Apply(); Mock.Flush()
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
''', FEATURES)

run("item theme and hierarchy fallbacks skip only unsupported slots", '''
Mock.Event("PLAYER_LOGIN"); local m=ClassicForeverUI.Modules.ItemSlots
assert(m.Detail:find("pieces: 19"),m.Detail)
assert(not m.Art[ContainerFrame1.Items[1].icon])
''', FEATURES+'''
ContainerFrame1.Items[1].icon.parent=UIParent
for b in pairs(BankFrame.BankPanel.itemButtonPool.active) do b.Background:SetAtlas("custom") end
''')

run("optional chat starts off and preserves unsent text focus states and native tabs", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI; local m=cf.Modules.ChatStyle
assert(m.State=="DISABLED" and cf.DB.modules.ChatStyle==false)
local b=ChatFrame1EditBox; local enter=b:GetScript("OnEnterPressed")
cf:SetModuleEnabled("ChatStyle",true); Mock.Flush(); assert(m.Active)
for _,t in pairs(m.Art) do assert(not t:IsVisible()) end
b:Show(); b.focusMid:Show(); assert(b.text=="unsent draft" and b:GetScript("OnEnterPressed")==enter)
cf:SetModuleEnabled("ChatStyle",false); Mock.Flush()
assert(b.focusMid:IsShown() and b.text=="unsent draft")
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
''', FEATURES)

run("saved chat opt-in survives startup and new settings are paged and reversible", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI
assert(cf.Modules.ChatStyle.Active)
cf.Options:Show(); local o=cf.Options
assert(o.Rows.Minimap:IsVisible() and not o.Rows.MailWindow:IsVisible())
Mock.Click(o.PageButtons[2]); assert(o.Rows.MailWindow:IsVisible() and not o.Rows.Minimap:IsVisible())
Mock.combat=true; local writes=Mock.nativeWrites; Mock.Click(o.Rows.MailWindow)
assert(cf.Pending and cf.DB.modules.MailWindow==false and Mock.nativeWrites==writes)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED"); assert(not cf.Modules.MailWindow.Active)
Mock.Callback("EditMode.Enter"); assert(not cf.Modules.TargetCastBar.Active)
Mock.Callback("EditMode.Exit"); assert(cf.Modules.TargetCastBar.Active)
Mock.Click(o.PageButtons[1]); assert(o.Rows.Minimap:IsVisible())
''', FEATURES+'\nClassicForeverUIDB={modules={ChatStyle=true}}')

run("passive hook partial registration retries remaining methods and missing APIs fail safely", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI
assert(cf.Modules.MinimapDetails.State=="ERROR")
hooksecurefunc=originalHook; cf:RetryModules(); Mock.Flush(); assert(cf.Modules.MinimapDetails.Active)
MinimapCluster.BorderTop.Center:SetVertexColor(.5,.5,.5,1); Mock.Flush()
assert(cf.Modules.MinimapDetails.Detail:find("pieces: 1"))
''', FEATURES+'''
originalHook=hooksecurefunc; local n=0
hooksecurefunc=function(object,method,callback)
 if object==MinimapCluster.BorderTop.Center then n=n+1; if n==3 then error("partial hook") end end
 return originalHook(object,method,callback)
end
''')

run("missing cast and micro artwork isolate new modules before native mutations", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI
assert(cf.Modules.TargetCastBar.State=="UNAVAILABLE" and cf.Modules.FocusCastBar.State=="UNAVAILABLE")
assert(cf.Modules.MicroArtwork.Active and cf.Modules.MailWindow.Active)
''', FEATURES+r'\nMock.missingTexture="Interface\\CastingBar\\UI-CastingBar-Border-Small"'.replace(r'\n','\n'))

run("all new passive skins remain inert with no secure hook API", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI
for _,name in ipairs({"MailWindow","LootWindow","TargetCastBar","MinimapDetails","ItemSlots","CharacterPages","BagArtwork"}) do
 assert(cf.Modules[name].State=="UNAVAILABLE",name)
end
assert(cf.Modules.ActionBars.Active)
''', FEATURES+'\nhooksecurefunc=nil')
