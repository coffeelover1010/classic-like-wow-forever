"""Source-shaped window borders. No game transactions are executed."""
WINDOWS = r'''
function Mock.Windows()
  local inset={TopLeftCorner="UI-Frame-InnerTopLeft",TopRightCorner="UI-Frame-InnerTopRight",
    BottomLeftCorner="UI-Frame-InnerBotLeftCorner",BottomRightCorner="UI-Frame-InnerBotRight",
    TopEdge="_UI-Frame-InnerTopTile",BottomEdge="_UI-Frame-InnerBotTile",
    LeftEdge="!UI-Frame-InnerLeftTile",RightEdge="!UI-Frame-InnerRightTile"}
  local bag={TopEdge="_UI-Frame-Metal-EdgeTop",BottomEdge="_UI-Frame-Metal-EdgeBottom",LeftEdge="!UI-Frame-Metal-EdgeLeft",RightEdge="!UI-Frame-Metal-EdgeRight"}
  local function border(owner, atlases)
    local nine=Mock.Child(owner,"NineSlice")
    for key,atlas in pairs(atlases) do
      local t=Mock.Child(nine,key); t:SetAtlas(atlas); t:SetAlpha(.65)
    end
  end
  for i=1,7 do
    local f=Mock.Native(i==7 and "ContainerFrameCombinedBags" or "ContainerFrame"..i)
    f.layoutType="HeldBagLayout"; Mock.Child(f,"PortraitButton"); Mock.Child(f,"CloseButton")
    border(f,bag)
    f.itemButtonPool={sentinel="untouched"}
  end
  local f=Mock.Native("BankFrame"); Mock.Child(f,"CloseButton"); Mock.Child(f,"TabSystem"); Mock.Child(f,"BankItemSearchBox")
  local p=Mock.Child(f,"BankPanel"); p.layoutType="InsetFrameTemplate"
  Mock.Child(p,"AutoDepositFrame"); Mock.Child(p,"AutoSortButton"); border(p,inset)
  f=Mock.Native("MerchantFrame"); Mock.Child(f,"CloseButton"); Mock.Child(f,"FilterDropdown")
  p=Mock.Child(f,"Inset"); p.layoutType="InsetFrameTemplate"; border(p,inset)
  Mock.Child(f,"Buyback"):SetTexture("native-buyback")
end
Mock.Windows()
'''

run("three independent window skins preserve every native border property", '''
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI
local native=MerchantFrame.Inset.NineSlice.LeftEdge
local writes=Mock.nativeWrites
for _,name in ipairs({"BagWindows","BankWindow","MerchantWindow"}) do
  local m=cf.Modules[name]; assert(m.Active); m:RefreshArt()
  assert(m.Detail:find(name=="BagWindows" and "borders: 7" or "borders: 1"))
end
assert(Mock.nativeWrites==writes and native:GetAlpha()==.65)
assert(native:GetAtlas()=="!UI-Frame-InnerLeftTile")
assert(MerchantFrame.Buyback:GetTexture()=="native-buyback")
assert(ContainerFrame1.itemButtonPool.sentinel=="untouched")
SlashCmdList.CLASSICFOREVERUI("module MerchantWindow off"); Mock.Flush()
for _,t in pairs(cf.Modules.MerchantWindow.Art) do assert(not t:IsShown()) end
assert(cf.Modules.BankWindow.Active and cf.Modules.BagWindows.Active)
assert(native:GetAlpha()==.65 and native:GetAtlas()=="!UI-Frame-InnerLeftTile")
''', WINDOWS)

run("window partial hook registration retries remaining methods", '''
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI; local m=cf.Modules.BankWindow
assert(m.State=="ERROR" and not m.Active)
hooksecurefunc=originalHook
cf:RetryModules(); Mock.Flush(); assert(m.Active)
local n=BankFrame.BankPanel.NineSlice.LeftEdge
n:SetTexture("custom"); Mock.Flush(); assert(m.Detail:find("borders: 0"))
''', WINDOWS+'''
originalHook=hooksecurefunc
local count=0
hooksecurefunc=function(object,method,callback)
  if object:GetParent()==BankFrame.BankPanel.NineSlice then
    count=count+1; if count==3 then error("hook registration fault") end
  end
  return originalHook(object,method,callback)
end
''')

run("missing window art fails before native changes", '''
Mock.Event("PLAYER_LOGIN")
for _,name in ipairs({"BagWindows","BankWindow","MerchantWindow"}) do
  assert(ClassicForeverUI.Modules[name].State=="UNAVAILABLE")
end
assert(ClassicForeverUI.Modules.ActionBars.Active)
''', WINDOWS+r'\nMock.missingTexture="Interface\\PaperDollInfoFrame\\UI-Character-CharacterTab-L1"'.replace(r'\n','\n'))

run("missing secure hook support retains native windows", '''
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.BagWindows.State=="UNAVAILABLE")
assert(ClassicForeverUI.Modules.BankWindow.State=="UNAVAILABLE")
assert(ClassicForeverUI.Modules.MerchantWindow.State=="UNAVAILABLE")
assert(MerchantFrame.Inset.NineSlice.LeftEdge:GetAlpha()==.65)
''', WINDOWS+'\nhooksecurefunc=nil')

run("window skins leave native item scripts states and search controls identical", '''
local f=MerchantFrame; local click=f.Item:GetScript("OnClick")
local drag=f.Item:GetScript("OnDragStart"); local search=f.FilterDropdown:GetScript("OnClick")
Mock.Event("PLAYER_LOGIN"); Mock.Event("MERCHANT_UPDATE"); Mock.Flush()
SlashCmdList.CLASSICFOREVERUI("module MerchantWindow off"); Mock.Flush()
assert(f.Item:GetScript("OnClick")==click and f.Item:GetScript("OnDragStart")==drag)
assert(f.FilterDropdown:GetScript("OnClick")==search)
assert(f.Item.icon:GetTexture()=="native-icon" and f.Item.IconBorder:GetAlpha()==.45)
assert(f.Item.Count.text=="17" and f.Item.Cooldown:GetAlpha()==.8)
assert(f.Item.secureToken=="native" and f.Item:GetParent()==f)
''', WINDOWS+'''
local f=MerchantFrame; local b=Mock.Child(f,"Item"); b.secureToken="native"
b:SetScript("OnClick",function() error("must not buy") end)
b:SetScript("OnDragStart",function() error("must not move") end)
f.FilterDropdown:SetScript("OnClick",function() error("must not filter") end)
Mock.Child(b,"icon"):SetTexture("native-icon"); Mock.Child(b,"IconBorder"):SetAlpha(.45)
Mock.Child(b,"Count"):SetText("17"); Mock.Child(b,"Cooldown"):SetAlpha(.8)
''')

run("window overlays inherit visibility and native geometry without creating item art", '''
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI
local nine=BankFrame.BankPanel.NineSlice
assert(cf.Modules.BankWindow.Art[nine.LeftEdge].allPoints==nine.LeftEdge)
BankFrame.BankPanel:Hide()
for _,t in pairs(cf.Modules.BankWindow.Art) do assert(not t:IsVisible()) end
BankFrame.BankPanel:Show()
local count=#Mock.frames
ContainerFrame1.itemButtonPool={sentinel="replacement"}
Mock.Event("BAG_UPDATE_DELAYED"); Mock.Event("MERCHANT_UPDATE"); Mock.Flush()
assert(#Mock.frames==count and ContainerFrame1.itemButtonPool.sentinel=="replacement")
local art=cf.Modules.BagWindows.Art[ContainerFrame1.NineSlice.LeftEdge]
assert(art:GetWidth()==4 and art.layer=="OVERLAY")
assert(art.points[1][2]==ContainerFrame1.NineSlice.LeftEdge)
''', WINDOWS)

run("window themes hide immediately during combat and recover after combat", '''
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.BankWindow; local n=BankFrame.BankPanel.NineSlice.LeftEdge
Mock.combat=true; local writes=Mock.nativeWrites
n:SetAtlas("accessibility-custom")
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
Mock.Flush(); assert(ClassicForeverUI.Pending and Mock.nativeWrites==writes)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(m.Detail:find("borders: 0"))
n:SetAtlas("!UI-Frame-InnerLeftTile"); Mock.Flush(); assert(m.Art[n]:IsShown())
n:Hide(); Mock.Flush(); assert(not m.Art[n]:IsShown())
n:Show(); Mock.Flush(); assert(m.Art[n]:IsShown())
''', WINDOWS)

run("changed window hierarchies fail closed independently", '''
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.BankWindow.State=="UNAVAILABLE")
assert(ClassicForeverUI.Modules.MerchantWindow.Active)
assert(ClassicForeverUI.Modules.BagWindows.Detail:find("borders: 6"))
''', WINDOWS+'\nBankFrame.BankPanel.parent=UIParent; ContainerFrame6.NineSlice.LeftEdge=nil')

run("late windows discover through addon loading and restore through Edit Mode", '''
Mock.Event("PLAYER_LOGIN"); local cf=ClassicForeverUI
assert(cf.Modules.BankWindow.State=="UNAVAILABLE")
Mock.Windows(); Mock.Event("ADDON_LOADED","Blizzard_UIPanels_Game"); Mock.Flush()
assert(cf.Modules.BankWindow.Active and cf.Modules.BagWindows.Active and cf.Modules.MerchantWindow.Active)
Mock.Callback("EditMode.Enter")
for _,t in pairs(cf.Modules.BankWindow.Art) do assert(not t:IsShown()) end
Mock.Callback("EditMode.Exit"); assert(cf.Modules.BankWindow.Active)
SlashCmdList.CLASSICFOREVERUI("")
Mock.combat=true; local writes=Mock.nativeWrites
Mock.Click(cf.Options.Rows.BagWindows); assert(cf.Pending and cf.Modules.BagWindows.Active)
assert(writes==Mock.nativeWrites)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(not cf.Modules.BagWindows.Active and cf.DB.modules.BagWindows==false)
''', WINDOWS+'\nBankFrame=nil; MerchantFrame=nil; for i=1,6 do _G["ContainerFrame"..i]=nil end; ContainerFrameCombinedBags=nil')

run("window partial creation rolls back and leaves other features running", '''
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.BankWindow
assert(m.State=="ERROR" and not m.Active)
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
assert(ClassicForeverUI.Modules.MerchantWindow.Active)
assert(BankFrame.BankPanel.NineSlice.LeftEdge:GetAlpha()==.65)
''', WINDOWS+'''
local nine=BankFrame.BankPanel.NineSlice; local original=nine.CreateTexture; local count=0
nine.CreateTexture=function(self,...) count=count+1; if count==3 then error("creation fault") end; return original(self,...) end
''')

run("window refresh failures isolate and retry without leaking overlays", '''
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI; local m=cf.Modules.MerchantWindow
local original=cf.Assets.Apply
cf.Assets.Apply=function() error("refresh failure") end
Mock.Event("MERCHANT_UPDATE"); Mock.Flush()
assert(m.Faulted and m.State=="UPDATE_FAILED" and not m.Active)
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
assert(cf.Modules.BankWindow.Active)
cf.Assets.Apply=original; cf:RetryModules(); Mock.Flush(); assert(m.Active and not m.Faulted)
''', WINDOWS)

run("stale window callbacks cannot revive disabled art", '''
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI; local m=cf.Modules.BankWindow
Mock.Event("BANKFRAME_OPENED")
cf.DB.modules.BankWindow=false; cf:Apply(); Mock.Flush()
BankFrame.BankPanel.NineSlice.LeftEdge:SetAtlas("!UI-Frame-InnerLeftTile"); Mock.Flush()
assert(not m.Active)
for _,t in pairs(m.Art) do assert(not t:IsShown()) end
''', WINDOWS)

run("unknown and opaque border themes stay native", '''
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.MerchantWindow.Detail:find("borders: 0"))
assert(ClassicForeverUI.Modules.BankWindow.Active)
''', WINDOWS+'\nMerchantFrame.Inset.NineSlice.LeftEdge:SetAtlas(Mock.Secret())')

run("replacement borders hide old art and reuse only current native anchors", '''
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.BankWindow
local old=BankFrame.BankPanel.NineSlice.LeftEdge; local oldArt=m.Art[old]
local n=Mock.Child(BankFrame.BankPanel.NineSlice,"LeftEdge"); n:SetAtlas("!UI-Frame-InnerLeftTile")
Mock.Event("BANKFRAME_OPENED"); Mock.Flush()
assert(not oldArt:IsShown() and m.Art[n]:IsShown() and m.Art[n].allPoints==n)
''', WINDOWS)
