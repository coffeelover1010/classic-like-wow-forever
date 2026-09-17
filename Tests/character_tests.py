"""Pinned Retail-shaped character checks; not native interaction or taint proof."""
run("character skin retains controls, original buttons and all native art", """
local b=CharacterHeadSlot; local click=b:GetScript("OnClick")
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.CharacterWindow
assert(m.Active and m.Art[CharacterFrame.Background]:IsShown())
local writes=Mock.nativeWrites
m:RefreshArt(); assert(Mock.nativeWrites==writes)
assert(m.Detail:find("18/18"))
assert(m.Slots.CharacterHeadSlotTOP:IsShown())
assert(m.Slots.CharacterHeadSlotTOP.layer=="ARTWORK" and m.Slots.CharacterHeadSlotTOP.sublevel==-2)
assert(b:GetScript("OnClick")==click and b.secureToken=="native")
Mock.Click(b); b:GetScript("OnEnter")(); b:GetScript("OnDragStart")()
assert(Mock.equipped==b and Mock.tooltip==b and Mock.dragged==b)
assert(b.icon:GetTexture()=="native-icon" and b.NormalTexture:GetTexture()=="native-NormalTexture")
assert(b.IconBorder:GetAlpha()==1 and b.Cooldown:GetAlpha()==1 and b.SocketDisplay:GetAlpha()==1)
assert(CharacterModelScene.Background:GetTexture()=="native-content")
assert(CharacterStatsPane.Background:GetTexture()=="native-content")
assert(PaperDollEquipmentManagerPane.Background:GetTexture()=="native-content")
assert(CharacterFrame:GetWidth()==540 and CharacterFrame.Inset.NineSlice.LeftEdge:GetAlpha()==.7)
SlashCmdList.CLASSICFOREVERUI("module CharacterWindow off"); Mock.Flush()
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
for _,t in pairs(m.Slots) do assert(not t:IsShown()) end
assert(CharacterFrame.Background:GetAtlas()=="character-panel-background")
""", "Mock.Character()")

run("character overlays follow paper-doll visibility and native resize anchors", """
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.CharacterWindow
PaperDollFrame:Hide()
for _,t in pairs(m.Art) do assert(not t:IsVisible()) end
for _,t in pairs(m.Slots) do assert(not t:IsVisible()) end
CharacterFrame:SetWidth(400); PaperDollFrame:Show()
assert(m.Art[CharacterFrame.Background].allPoints==CharacterFrame.Background)
assert(m.Art[CharacterFrame.Background]:IsVisible())
local count=#Mock.frames
Mock.Event("PLAYER_EQUIPMENT_CHANGED"); Mock.Flush(); assert(#Mock.frames==count)
""", "Mock.Character()")

run("character themes reveal native background and trim immediately in combat", """
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.CharacterWindow
Mock.combat=true; local writes=Mock.nativeWrites
CharacterFrame.Background:SetAtlas("accessibility-custom")
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
for _,t in pairs(m.Slots) do assert(not t:IsShown()) end
Mock.Flush(); assert(Mock.nativeWrites==writes and ClassicForeverUI.Pending)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(not m.Art[CharacterFrame.Background]:IsShown())
CharacterFrame.Background:SetAtlas("character-panel-background"); Mock.Flush()
assert(m.Art[CharacterFrame.Background]:IsShown())
CharacterFrame.Background:Hide(); Mock.Flush(); assert(not m.Art[CharacterFrame.Background]:IsShown())
CharacterFrame.Background:Show(); Mock.Flush(); assert(m.Art[CharacterFrame.Background]:IsShown())
""", "Mock.Character()")

run("character changed hierarchy fails closed without affecting HUD", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.CharacterWindow.State=="UNAVAILABLE")
assert(ClassicForeverUI.Modules.ActionBars.Active)
""", "Mock.Character(); PaperDollItemsFrame.parent=UIParent")

run("unsupported character slots and changed ownership stay native", """
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.CharacterWindow
assert(m.Active and not m.Slots.CharacterHeadSlotTOP and m.Slots.CharacterNeckSlotTOP)
assert(m.Detail:find("17/18"))
CharacterNeckSlot.parent=UIParent
Mock.Event("PLAYER_EQUIPMENT_CHANGED"); Mock.Flush()
assert(not m.Slots.CharacterNeckSlotTOP:IsShown())
""", "Mock.Character(); CharacterHeadSlot.icon=nil")

run("late character discovery settings combat and Edit Mode preserve lifecycle", """
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI; local m=cf.Modules.CharacterWindow
assert(m.State=="UNAVAILABLE")
Mock.Character(); Mock.Event("ADDON_LOADED","Blizzard_UIPanels_Game"); Mock.Flush(); assert(m.Active)
Mock.Callback("EditMode.Enter"); assert(not m.Active)
Mock.Callback("EditMode.Exit"); assert(m.Active)
SlashCmdList.CLASSICFOREVERUI(""); assert(cf.Options.Rows.CharacterWindow)
Mock.combat=true; local writes=Mock.nativeWrites
Mock.Click(cf.Options.Rows.CharacterWindow); assert(cf.Pending and m.Active and writes==Mock.nativeWrites)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED"); assert(not m.Active)
assert(cf.DB.modules.CharacterWindow==false)
""")

run("partial character failure rolls back and retry recovers", """
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.CharacterWindow
assert(m.State=="ERROR" and not m.Active and ClassicForeverUI.Modules.ActionBars.Active)
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
for _,t in pairs(m.Slots) do assert(not t:IsShown()) end
CharacterNeckSlot.CreateTexture=nil
SlashCmdList.CLASSICFOREVERUI("refresh"); Mock.Flush(); assert(m.Active)
""", 'Mock.Character(); CharacterNeckSlot.CreateTexture=function() error("slot fault") end')

run("character deferred refresh failure is isolated", """
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.CharacterWindow
CharacterFrame.Background.GetAtlas=function() error("theme fault") end
Mock.Event("PLAYER_EQUIPMENT_CHANGED"); Mock.Flush()
assert(m.Faulted and not m.Active and m.State=="UPDATE_FAILED")
assert(ClassicForeverUI.Modules.ActionBars.Active)
""", "Mock.Character()")

run("character missing artwork rejects before application", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.CharacterWindow.State=="UNAVAILABLE")
assert(CharacterFrame.Inset.NineSlice.LeftEdge:GetAlpha()==.7)
""", r'Mock.Character(); Mock.missingTexture="Interface\\PaperDollInfoFrame\\UI-Character-CharacterTab-L1"')

run("character missing secure hooks fails safely", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.CharacterWindow.State=="UNAVAILABLE")
""", "Mock.Character(); hooksecurefunc=nil")

run("character queued refresh cannot revive disabled art", """
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI; local m=cf.Modules.CharacterWindow
m.EventFrame:GetScript("OnEvent")(m.EventFrame,"PLAYER_EQUIPMENT_CHANGED")
cf.DB.modules.CharacterWindow=false; cf:Apply(); Mock.Flush()
assert(not m.Active)
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
""", "Mock.Character()")

run("partial character hook registration retries every remaining hook", """
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.CharacterWindow
assert(m.State=="ERROR" and not m.Active)
hooksecurefunc=Mock.originalHook
SlashCmdList.CLASSICFOREVERUI("refresh"); Mock.Flush(); assert(m.Active)
CharacterFrame.Background:Hide()
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
""", '''Mock.Character(); Mock.originalHook=hooksecurefunc
hooksecurefunc=function(object,method,callback)
  if object==CharacterFrame.Background and method=="Hide" then error("hook fault") end
  Mock.originalHook(object,method,callback)
end''')

run("character opaque background is never compared or replaced", """
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.CharacterWindow
assert(m.Active and next(m.Art)==nil and next(m.Slots)==nil)
""", "Mock.Character(); CharacterFrame.Background.GetAtlas=function() return Mock.Secret() end")
