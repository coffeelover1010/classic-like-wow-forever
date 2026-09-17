-- Shapes checked against the pinned Blizzard sources. Actions are inert sentinels.
local insetAtlases={TopLeftCorner="UI-Frame-InnerTopLeft",TopRightCorner="UI-Frame-InnerTopRight",
  BottomLeftCorner="UI-Frame-InnerBotLeftCorner",BottomRightCorner="UI-Frame-InnerBotRight",
  TopEdge="_UI-Frame-InnerTopTile",BottomEdge="_UI-Frame-InnerBotTile",
  LeftEdge="!UI-Frame-InnerLeftTile",RightEdge="!UI-Frame-InnerRightTile"}
function Mock.Inset(owner,key,name)
  local p=Mock.Native(name,owner); owner[key]=p; p.layoutType="InsetFrameTemplate"
  local n=Mock.Child(p,"NineSlice")
  for k,a in pairs(insetAtlases) do Mock.Child(n,k):SetAtlas(a) end
  return p
end
function Mock.ButtonPanel(name)
  local f=Mock.Native(name); Mock.Child(f,"CloseButton"); Mock.Inset(f,"Inset")
  f:SetScript("OnShow",function() end); f:SetScript("OnHide",function() end)
  return f
end
function Mock.MoreWindows()
  local f=Mock.ButtonPanel("MailFrame")
  Mock.Native("InboxFrame",f); Mock.Native("SendMailFrame",f)
  Mock.Inset(SendMailFrame,"MoneyInset","SendMailMoneyInset")
  f=Mock.ButtonPanel("OpenMailFrame"); Mock.Native("OpenMailScrollFrame",f)
  f=Mock.ButtonPanel("TradeFrame")
  for _,name in ipairs({"TradeRecipientItemsInset","TradeRecipientEnchantInset","TradePlayerItemsInset",
      "TradePlayerEnchantInset","TradePlayerInputMoneyInset","TradeRecipientMoneyInset"}) do Mock.Inset(f,name,name) end
  Mock.ButtonPanel("InspectFrame")
  Mock.Inset(MerchantFrame,"MoneyInset","MerchantMoneyInset")
  Mock.Inset(MerchantFrame,"ExtraCurrencyInset","MerchantExtraCurrencyInset")
  f=Mock.ButtonPanel("ClassTrainerFrame"); Mock.Inset(f,"bottomInset"):Hide()
  for _,name in ipairs({"MailFrame","OpenMailFrame","TradeFrame","InspectFrame","ClassTrainerFrame"}) do
    local b=Mock.Child(_G[name],"Action"); b.secureToken="native"
    b:SetScript("OnClick",function() error("native transaction must not be called by tests") end)
  end
  f=Mock.Native("LootFrame"); f.layoutType="ButtonFrameTemplateNoPortrait"
  Mock.Child(f,"ScrollBox"); Mock.Child(f,"ScrollBar"); Mock.Child(f,"ClosePanelButton")
  local nine=Mock.Child(f,"NineSlice")
  for k,a in pairs({TopEdge="_UI-Frame-Metal-EdgeTop",BottomEdge="_UI-Frame-Metal-EdgeBottom",
      LeftEdge="!UI-Frame-Metal-EdgeLeft",RightEdge="!UI-Frame-Metal-EdgeRight"}) do Mock.Child(nine,k):SetAtlas(a) end
  f.ScrollBox.pool={sentinel="native-pool"}
  local row=Mock.Child(f.ScrollBox,"Row")
  for _,key in ipairs({"Item","QualityStripe","QualityText","BorderFrame","IconQuestTexture","HighlightNameFrame"}) do
    Mock.Child(row,key):SetTexture("native-"..key)
  end
  row.Item:SetScript("OnClick",function() error("must not loot") end)
end
function Mock.Casts()
  for _,f in ipairs({TargetFrame,FocusFrame}) do
    local b=Mock.Child(f,"spellbar"); b:SetSize(150,10)
    for _,key in ipairs({"Border","BorderShield","Icon","Text","Spark","Flash"}) do Mock.Child(b,key) end
    b.Border:SetAtlas("ui-castingbar-frame"); b.BorderShield:Hide()
    b:SetStatusBarTexture("native-cast-fill"); b.value=Mock.secret
    b:SetScript("OnUpdate",function() end); b:SetScript("OnEvent",function() end)
    b.empowerStages={sentinel="native-stages"}
  end
  function FocusFrame:SetSmallSize(value) self.smallSize=value end
  FocusFrame.totFrame=Mock.Native(nil,FocusFrame)
  for _,key in ipairs({"HealthBar","ManaBar","Portrait","FrameTexture"}) do Mock.Child(FocusFrame.totFrame,key) end
end
function Mock.MicroArt()
  for _,spec in ipairs({{"QuestLogMicroButton","Questlog"},{"PlayerSpellsMicroButton","SpecTalents"}}) do
    local b=Mock.Native(spec[1],MicroMenu)
    for _,s in ipairs({"Normal","Pushed","Disabled","Highlight"}) do Mock.Child(b,s) end
    b.Normal:SetAtlas("UI-HUD-MicroMenu-"..spec[2].."-Up")
    b.Pushed:SetAtlas("UI-HUD-MicroMenu-"..spec[2].."-Down")
    b.Disabled:SetAtlas("UI-HUD-MicroMenu-"..spec[2].."-Disabled")
    b.Highlight:SetAtlas("native-highlight"); Mock.Child(b,"FlashBorder")
    function b:GetNormalTexture() return self.Normal end
    function b:GetPushedTexture() return self.Pushed end
    function b:GetDisabledTexture() return self.Disabled end
    b:SetScript("OnClick",function() end); b:SetScript("OnMouseDown",function() end)
  end
end
function Mock.Item(owner,name)
  local b=Mock.Native(name,owner)
  for _,key in ipairs({"icon","IconBorder","Count","Cooldown","IconQuestTexture","searchOverlay","Background"}) do
    Mock.Child(b,key):SetTexture("native-"..key)
  end
  b:SetScript("OnClick",function() error("must not move or buy") end)
  b:SetScript("OnDragStart",function() error("must not drag") end)
  b.secureToken="native-item"; return b
end
function Mock.Items()
  for i=1,7 do
    local f=i==7 and ContainerFrameCombinedBags or _G["ContainerFrame"..i]
    local b=Mock.Item(f); b.emptyBackgroundAtlas="bags-item-slot64"; f.Items={b}
    function f:UpdateItemSlots() end
  end
  local p=BankFrame.BankPanel; local b=Mock.Item(p); b.Background:SetAtlas("bags-item-slot64")
  p.itemButtonPool={active={[b]=true}}
  function p:EnumerateValidItems() return pairs(self.itemButtonPool.active) end
  function p:GenerateItemSlotsForSelectedTab() end
  for i=1,12 do
    local row=Mock.Native("MerchantItem"..i,MerchantFrame)
    Mock.Item(row,"MerchantItem"..i.."ItemButton")
  end
  local row=Mock.Native("MerchantBuyBackItem",MerchantFrame)
  local buyback=Mock.Item(row,"MerchantBuyBackItemItemButton"); buyback.IconQuestTexture=nil
  Mock.Child(Mock.Child(buyback,"UndoFrame"),"Arrow"):SetAtlas("common-icon-undo")
  for _,name in ipairs({"MainMenuBarBackpackButton","CharacterBag0Slot","CharacterBag1Slot",
      "CharacterBag2Slot","CharacterBag3Slot","CharacterReagentBag0Slot"}) do
    local b=Mock.Item(BagsBar,name); Mock.Child(b,"CircleMask"); Mock.Child(b,"SlotHighlightTexture")
  end
end
function Mock.MapDetails()
  local h=Mock.Child(MinimapCluster,"BorderTop")
  h.layoutType="UniqueCornersLayout"; h.layoutTextureKit="ui-hud-minimap-button"
  for _,key in ipairs({"Center","TopEdge","BottomEdge"}) do
    Mock.Child(h,key):SetAtlas(key=="Center" and "ui-hud-minimap-button-NineSlice-Center" or
      "_ui-hud-minimap-button-NineSlice-Edge"..(key=="TopEdge" and "Top" or "Bottom"))
  end
  local t=Mock.Child(MinimapCluster,"Tracking")
  Mock.Child(t,"Background"):SetAtlas("ui-hud-minimap-button"); Mock.Child(t,"Button")
  local b=Mock.Native("TimeManagerClockButton",MinimapCluster)
  Mock.Native("TimeManagerClockTicker",b):SetText("19:42")
  b:SetScript("OnClick",function() end)
  Mock.Child(MinimapCluster,"IndicatorFrame")
end
function Mock.Pages()
  Mock.Character(); Mock.Inset(CharacterFrame,"Inset")
  for _,name in ipairs({"ReputationFrame","TokenFrame"}) do
    local p=Mock.Native(name,CharacterFrame); Mock.Child(p,"ScrollBox"); Mock.Child(p,"ScrollBar"); p:Hide()
  end
end
function Mock.Chat()
  local f=Mock.Native("ChatFrame1"); local b=Mock.Native("ChatFrame1EditBox",f); f.editBox=b
  for _,key in ipairs({"focusLeft","focusMid","focusRight"}) do Mock.Child(b,key):Hide() end
  b:SetText("unsent draft"); b:SetScript("OnEnterPressed",function() error("must not send") end)
  b:Hide()
end
Mock.MoreWindows(); Mock.Casts(); Mock.MicroArt(); Mock.Items(); Mock.MapDetails(); Mock.Pages(); Mock.Chat()
