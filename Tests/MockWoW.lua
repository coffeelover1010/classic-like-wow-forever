-- Intentionally small Retail-shaped model. It cannot certify WoW taint/rendering.
Mock = {frames={}, timers={}, messages={}, combat=false, nativeWrites=0, callbacks={}}
local Methods = {}
local function geometry(self)
  if self.native then
    if Mock.combat then error("protected layout write during combat") end
    Mock.nativeWrites = Mock.nativeWrites + 1
  end
end
function Methods:SetSize(w,h) geometry(self); self.width,self.height=w,h end
function Methods:GetSize() return self.width,self.height end
function Methods:GetWidth() return self.width end
function Methods:GetHeight() return self.height end
function Methods:SetWidth(w) geometry(self); self.width=w end
function Methods:SetHeight(h) geometry(self); self.height=h end
function Methods:SetPoint(...) geometry(self); self.points[#self.points+1]={...} end
function Methods:GetPoint(i) return unpack(self.points[i]) end
function Methods:GetNumPoints() return #self.points end
function Methods:ClearAllPoints() geometry(self); self.points={} end
function Methods:SetAllPoints(relative) geometry(self); self.allPoints=relative or self.parent end
function Methods:SetScale(s) geometry(self); self.scale=s end
function Methods:GetScale() return self.scale end
function Methods:SetAlpha(a) geometry(self); self.alpha=a end
function Methods:GetAlpha() return self.alpha end
function Methods:SetFrameLevel(n) geometry(self); self.level=n end
function Methods:GetFrameLevel() return self.level end
function Methods:SetFrameStrata(s) self.strata=s end
function Methods:IsProtected() return self.native or false end
function Methods:GetParent() return self.parent end
function Methods:Show()
  local changed=not self.shown; self.shown=true
  if changed and self.scripts.OnShow then self.scripts.OnShow(self) end
end
function Methods:Hide()
  local changed=self.shown; self.shown=false
  if changed and self.scripts.OnHide then self.scripts.OnHide(self) end
end
function Methods:IsShown() return self.shown end
function Methods:IsVisible() return self.shown and (not self.parent or self.parent:IsVisible()) end
function Methods:SetShown(value) if value then self:Show() else self:Hide() end end
function Methods:SetClampedToScreen(value) self.clamped=value end
function Methods:SetJustifyH(value) self.justify=value end
function Methods:SetTextColor(...) self.textColor={...} end
function Methods:SetDrawLayer(layer, sublevel) self.layer=layer; self.sublevel=sublevel or 0 end
function Methods:SetChecked(value)
  self.checked=value==true
  if self.checkedTexture then self.checkedTexture:SetShown(self.checked) end
end
function Methods:GetChecked() return self.checked==true end
function Methods:SetCheckedTexture(path)
  self.checkedTexture=self.checkedTexture or self:CreateTexture(nil,"OVERLAY")
  self.checkedTexture:SetTexture(path); self.checkedTexture:SetShown(self.checked==true)
end
function Methods:GetCheckedTexture() return self.checkedTexture end
function Methods:SetHighlightTexture(texture) self.highlight=texture; texture:Hide() end
function Methods:EnableMouse(value) self.mouse=value end
function Methods:SetMovable(value) self.movable=value end
function Methods:RegisterForDrag(...) end
function Methods:StartMoving() end
function Methods:StopMovingOrSizing() end
function Methods:RegisterEvent(event)
  if Mock.rejectedEvent == event then error("unknown event") end
  self.events[event]=true
end
function Methods:UnregisterAllEvents() self.events={} end
function Methods:SetScript(name,func) self.scripts[name]=func end
function Methods:GetScript(name) return self.scripts[name] end
function Methods:SetColorTexture(...) self.color={...} end
function Methods:SetBackdrop(data) self.backdrop=data end
function Methods:SetBackdropColor(...) self.backdropColor={...} end
function Methods:SetBackdropBorderColor(...) self.backdropBorderColor={...} end
function Methods:SetTexture(path)
  self.texture,self.atlas=path,nil
  if path == Mock.missingTexture then return false end
  if Mock.nilTextureReturn then return end
  return true
end
function Methods:GetTexture() return self.texture end
function Methods:SetAtlas(atlas) self.atlas=atlas end
function Methods:GetAtlas() return self.atlas end
function Methods:SetTexCoord(...) self.coords={...} end
function Methods:GetTexCoord() return unpack(self.coords) end
function Methods:SetText(value) self.text=value end -- accepts opaque secrets
function Methods:SetFontObject(value) self.font=value end
function Methods:SetFocus() end
function Methods:HighlightText() end
function Methods:SetMultiLine(value) end
function Methods:SetAutoFocus(value) end
function Methods:SetMaxLetters(value) end
function Methods:SetScrollChild(value) self.scrollChild=value end
function Methods:SetMinMaxValues(low,high) self.low,self.high=low,high end
function Methods:SetValue(value) self.value=value end
function Methods:SetStatusBarColor(...) self.barColor={...} end
function Methods:SetStatusBarTexture(path)
  self.barTexture=self.barTexture or self:CreateTexture()
  self.barTexture:SetTexture(path)
end
function Methods:GetStatusBarTexture() return self.barTexture end
function CreateFrame(kind,name,parent,template)
  local f=setmetatable({kind=kind,name=name,parent=parent,template=template,points={},width=232,height=100,
    scale=1,alpha=1,level=50,shown=true,events={},scripts={},coords={0,1,0,1}}, {__index=Methods})
  Mock.frames[#Mock.frames+1]=f
  if name then _G[name]=f end
  return f
end
function Methods:CreateTexture(name,layer,template,sublevel)
  local t=CreateFrame("Texture",name,self); t.layer=layer; t.sublevel=sublevel or 0; return t
end
function Methods:CreateFontString(name,layer,font)
  local f=CreateFrame("FontString",name,self); f.font=font; f.layer=layer; return f
end
function Mock.Click(button)
  assert(button:IsVisible(),"clicked hidden button")
  if button.kind=="CheckButton" then button:SetChecked(not button:GetChecked()) end
  if button.scripts.OnClick then button.scripts.OnClick(button,"LeftButton") end
  Mock.Flush()
end
function Mock.Escape()
  for _,name in ipairs(UISpecialFrames) do if _G[name] then _G[name]:Hide() end end
end
function Mock.SettingsAPI()
  Mock.categories={}; Mock.categoryCalls=0
  Settings={
    RegisterCanvasLayoutCategory=function(frame,name)
      Mock.categoryCalls=Mock.categoryCalls+1
      return {frame=frame,name=name}
    end,
    RegisterAddOnCategory=function(category) Mock.categories[#Mock.categories+1]=category end,
  }
end
function Mock.Native(name,parent)
  local f=CreateFrame("Frame",name,parent or UIParent)
  f.native=true
  f.points={{"CENTER",parent or UIParent,"CENTER",7,11}}
  return f
end
function Mock.Child(parent,key) local f=Mock.Native(nil,parent); parent[key]=f; return f end
function Mock.Character()
  local f=Mock.Native("CharacterFrame"); f:SetSize(540,424)
  Mock.Child(f,"CloseButton"); Mock.Child(f,"Background"):SetAtlas("character-panel-background")
  local nine=Mock.Child(Mock.Child(f,"Inset"),"NineSlice")
  for _,key in ipairs({"TopLeftCorner","TopRightCorner","BottomLeftCorner","BottomRightCorner",
      "TopEdge","BottomEdge","LeftEdge","RightEdge"}) do
    Mock.Child(nine,key):SetAlpha(.7)
  end
  local p=Mock.Native("PaperDollFrame",f)
  local items=Mock.Native("PaperDollItemsFrame",p)
  for _,name in ipairs({"Head","Neck","Shoulder","Back","Chest","Shirt","Tabard","Wrist",
      "Hands","Waist","Legs","Feet","Finger0","Finger1","Trinket0","Trinket1","MainHand","SecondaryHand"}) do
    local b=Mock.Native("Character"..name.."Slot",items)
    for _,key in ipairs({"icon","IconBorder","Cooldown","popoutButton","SocketDisplay","NormalTexture"}) do
      Mock.Child(b,key):SetTexture("native-"..key)
    end
    b.secureToken="native"
    b:SetScript("OnClick",function() Mock.equipped=b end)
    b:SetScript("OnEnter",function() Mock.tooltip=b end)
    b:SetScript("OnDragStart",function() Mock.dragged=b end)
  end
  for _,name in ipairs({"CharacterModelScene","CharacterStatsPane","PaperDollEquipmentManagerPane","CharacterFrameTab1"}) do
    local b=Mock.Native(name,p); b:SetScript("OnClick",function() end)
    Mock.Child(b,"Background"):SetTexture("native-content")
  end
end
function hooksecurefunc(object, method, callback)
  local original=object[method]
  object[method]=function(self,...)
    local result=original(self,...); callback(self,...); return result
  end
end
function Mock.Dialogues()
  local function window(name)
    local f=Mock.Native(name)
    Mock.Child(f,"CloseButton"); local inset=Mock.Child(f,"Inset")
    local nine=Mock.Child(inset,"NineSlice")
    for _,key in ipairs({"TopLeftCorner","TopRightCorner","BottomLeftCorner","BottomRightCorner",
        "TopEdge","BottomEdge","LeftEdge","RightEdge"}) do
      local t=Mock.Child(nine,key); t:SetAtlas("native-"..key); t:SetAlpha(.7)
    end
    f:SetSize(338,496); return f
  end
  local quest=window("QuestFrame")
  for _,suffix in ipairs({"Detail","Progress","Reward","Greeting"}) do
    local panel=Mock.Native("QuestFrame"..suffix.."Panel",quest)
    Mock.Child(panel,"Bg"):SetAtlas("QuestBG-Parchment")
    Mock.Child(panel,"MaterialTopLeft"):SetTexture("native-material")
    panel:SetScript("OnShow",function() end)
  end
  for _,name in ipairs({"QuestFrameAcceptButton","QuestFrameDeclineButton","QuestFrameCompleteButton",
      "QuestFrameCompleteQuestButton","QuestFrameGoodbyeButton","QuestFrameGreetingGoodbyeButton"}) do
    local b=Mock.Native(name,QuestFrameDetailPanel)
    b:SetScript("OnClick",function() Mock.questClicks=(Mock.questClicks or 0)+1 end)
    Mock.Child(b,"Left"):SetTexture("Interface\\Buttons\\UI-Panel-Button-Up")
  end
  QuestInfoRewardsFrame=Mock.Native("QuestInfoRewardsFrame",QuestFrameRewardPanel)
  QuestInfoRewardsFrame.RewardButtons={}
  function Mock.Reward()
    local b=Mock.Native(nil,QuestInfoRewardsFrame)
    Mock.Child(b,"Icon"):SetTexture("reward-icon"); Mock.Child(b,"NameFrame")
    Mock.Child(b,"IconBorder"):SetTexture("quality-border")
    b:SetScript("OnClick",function() Mock.selected=b end)
    b:SetScript("OnEnter",function() Mock.tooltip=b end)
    table.insert(QuestInfoRewardsFrame.RewardButtons,b); return b
  end
  Mock.Reward()
  local gossip=window("GossipFrame")
  Mock.Child(gossip,"Background"):SetAtlas("QuestBG-Parchment")
  local panel=Mock.Child(gossip,"GreetingPanel")
  Mock.Child(panel,"ScrollBox"); Mock.Child(panel,"ScrollBar")
  Mock.Child(panel,"GoodbyeButton"):SetScript("OnClick",function() gossip:Hide() end)
  Mock.Child(gossip,"FriendshipStatusBar")
end
function Mock.Spell(book, id)
  local item=Mock.Native(nil,book.PagedSpellsFrame)
  local button=Mock.Child(item,"Button")
  button.spellID=id; button:SetSize(40,40); button.secureToken="spell-native"
  button:SetScript("OnClick",function() end); button:SetScript("OnDragStart",function() end)
  for _,key in ipairs({"Icon","Border","IconHighlight","AutoCastOverlay","Cooldown"}) do
    Mock.Child(button,key):SetTexture("native-"..key)
  end
  Mock.Child(item,"Backplate"):SetAlpha(0.25)
  Mock.Child(item,"TextContainer").text="native localized spell name"
  book.items[#book.items+1]=item
  return item
end
function Mock.LoadSpellBook()
  local parent=Mock.Native("PlayerSpellsFrame")
  Mock.Child(parent,"TalentsFrame"); Mock.Child(parent,"SpecFrame")
  local book=Mock.Child(parent,"SpellBookFrame"); book:SetSize(806,856)
  for _,key in ipairs({"TopBar","BookBGHalved","BookBGLeft","BookBGRight","BookCornerFlipbook","Bookmark"}) do
    Mock.Child(book,key):SetAtlas("native-"..key)
  end
  book.BookBGLeft:Hide(); book.BookBGRight:Hide(); book.Bookmark:Hide()
  book.BookCornerFlipbook:SetAlpha(0.7)
  for _,key in ipairs({"SearchBox","CategoryTabSystem","SettingsDropdown","PagedSpellsFrame"}) do Mock.Child(book,key) end
  Mock.Child(book.PagedSpellsFrame,"PagingControls")
  book.items={}
  function book:ForEachDisplayedSpell(callback)
    for _,item in ipairs(self.items) do callback(item) end
  end
  function book:SetMinimized(value)
    self.isMinimized=value; self:SetWidth(value and 806 or 1612)
    self.BookBGHalved:SetShown(value)
    self.BookBGLeft:SetShown(not value); self.BookBGRight:SetShown(not value)
    self.Bookmark:SetShown(not value)
    self.TopBar:SetTexCoord(0,value and 0.5 or 1,0,1)
  end
  Mock.Spell(book,1); Mock.Spell(book,2)
  book:Hide()
  return book
end
function Mock.Flush()
  while #Mock.timers > 0 do local list=Mock.timers; Mock.timers={}; for _,f in ipairs(list) do f() end end
end
function Mock.Event(event,...)
  local frames={unpack(Mock.frames)}
  for _,f in ipairs(frames) do if f.events[event] and f.scripts.OnEvent then f.scripts.OnEvent(f,event,...) end end
  Mock.Flush()
end
function Mock.Callback(name)
  local c=Mock.callbacks[name]
  if c then c.func(c.owner) end
  Mock.Flush()
end
function Mock.Secret()
  local function reject() error("restricted value used outside display sink") end
  return setmetatable({secret=true},{__tostring=reject,__add=reject,__sub=reject,__mul=reject,
    __div=reject,__lt=reject,__le=reject,__concat=reject})
end
function issecretvalue(value) return type(value)=="table" and rawget(value,"secret")==true end
function InCombatLockdown() return Mock.combat end
function GetBuildInfo() return "12.1.0","mock-build","mock-date",120100 end
function UnitHealth() return Mock.health or 75 end
function UnitHealthMax() return Mock.maxHealth or 100 end
function UnitPower() return Mock.power or 50 end
function UnitPowerMax() return Mock.maxPower or 100 end
function UnitName() return Mock.unitName or "Test unit" end
function UnitLevel() return Mock.unitLevel or 80 end
function UnitPowerType() return 0, Mock.powerType or "MANA" end
function UnitClassification() return Mock.classification or "normal" end
function SetPortraitTexture(texture,unit) texture.portraitUnit=unit end
PowerBarColor={MANA={r=0.1,g=0.3,b=0.9}}
C_Timer={After=function(_,func) Mock.timers[#Mock.timers+1]=func end}
C_Texture={GetAtlasInfo=function() return {} end}
EventRegistry={RegisterCallback=function(_,name,func,owner) Mock.callbacks[name]={func=func,owner=owner} end}
DEFAULT_CHAT_FRAME={AddMessage=function(_,text) Mock.messages[#Mock.messages+1]=text end}
SlashCmdList={}
UISpecialFrames={}
WOW_PROJECT_ID,WOW_PROJECT_MAINLINE,WOW_PROJECT_CLASSIC=1,1,2
UIParent=CreateFrame("Frame","UIParent"); UIParent:SetSize(1920,1080)
MainActionBar=Mock.Native("MainActionBar")
Mock.Child(MainActionBar,"BorderArt")
Mock.Child(MainActionBar,"EndCaps")
Mock.Child(MainActionBar,"ActionBarPageNumber")
for i=1,12 do
  local container=Mock.Native("MainActionBarButtonContainer"..i,MainActionBar)
  local f=Mock.Native("ActionButton"..i,container)
  f.container=container
  f.action=i; f.secureToken="unchanged"
  Mock.Child(f,"SlotBackground"); Mock.Child(f,"SlotArt")
  Mock.Child(f,"NormalTexture")
end
Mock.Native("MultiBarBottomLeft"); Mock.Native("MultiBarBottomRight")
PlayerFrame=Mock.Native("PlayerFrame"); PlayerFrame.unit="player"
Mock.Child(PlayerFrame,"PlayerFrameContainer")
local pm=Mock.Child(Mock.Child(PlayerFrame,"PlayerFrameContent"),"PlayerFrameContentMain")
for _,key in ipairs({"HealthBarsContainer","ManaBarArea","StatusTexture","HitIndicator"}) do Mock.Child(pm,key) end
Mock.Native("PlayerName",pm); Mock.Native("PlayerLevelText",pm)
TargetFrame=Mock.Native("TargetFrame"); TargetFrame.unit="target"
Mock.Child(TargetFrame,"TargetFrameContainer")
local tm=Mock.Child(Mock.Child(TargetFrame,"TargetFrameContent"),"TargetFrameContentMain")
for _,key in ipairs({"HealthBarsContainer","ManaBar","Name","LevelText","ReputationColor"}) do Mock.Child(tm,key) end
FocusFrame=Mock.Native("FocusFrame"); FocusFrame.unit="focus"
Mock.Child(FocusFrame,"TargetFrameContainer")
local fm=Mock.Child(Mock.Child(FocusFrame,"TargetFrameContent"),"TargetFrameContentMain")
for _,key in ipairs({"HealthBarsContainer","ManaBar","Name","LevelText","ReputationColor"}) do Mock.Child(fm,key) end
for _,main in ipairs({pm,tm,fm}) do
  local container=main.HealthBarsContainer
  local width=main==tm and 126 or 124
  container:SetSize(width,20)
  local bar=Mock.Child(container,"HealthBar")
  bar:SetSize(width,20); bar:SetStatusBarTexture("native-health")
  bar.value=37; bar:SetScript("OnValueChanged",function() end)
  for _,key in ipairs({"MyHealPredictionBar","OtherHealPredictionBar","TotalAbsorbBar","HealAbsorbBar",
      "OverAbsorbGlow","OverHealAbsorbGlow"}) do Mock.Child(bar,key) end
  Mock.Child(container,"HealthBarMask"); Mock.Child(container,"HealthBarText")
end
function Mock.Aura(frame)
  local button=Mock.Native(nil,frame)
  for _,key in ipairs({"Icon","Duration","Count","DebuffBorder","TempEnchantBorder"}) do
    Mock.Child(button,key):SetTexture("native-"..key)
  end
  button:SetScript("OnClick",function() end)
  button:SetScript("OnUpdate",function() end)
  frame.auraFrames[#frame.auraFrames+1]=button
  return button
end
for _,name in ipairs({"BuffFrame","DebuffFrame"}) do
  local frame=Mock.Native(name); frame.auraFrames={}
  Mock.Aura(frame); Mock.Aura(frame)
end
for _,name in ipairs({"GameTooltip","ItemRefTooltip","ShoppingTooltip1","ShoppingTooltip2"}) do
  local tip=Mock.Native(name)
  local nine=Mock.Child(tip,"NineSlice")
  for _,key in ipairs({"TopLeftCorner","TopRightCorner","BottomLeftCorner","BottomRightCorner",
      "TopEdge","BottomEdge","LeftEdge","RightEdge","Center"}) do
    Mock.Child(nine,key):SetAlpha(0.8)
  end
  tip:SetScript("OnShow",function() end)
  tip:SetScript("OnTooltipCleared",function() end)
  tip:Hide()
end
ObjectiveTrackerFrame=Mock.Native("ObjectiveTrackerFrame")
local header=Mock.Child(ObjectiveTrackerFrame,"Header")
Mock.Child(header,"Background"):SetAtlas("native-tracker")
Mock.Child(header,"MinimizeButton"):SetScript("OnClick",function() end)
Mock.Child(header,"FilterButton"); Mock.Child(header,"Text")
MinimapCluster=Mock.Native("MinimapCluster")
Minimap=Mock.Native("Minimap",MinimapCluster); Minimap:SetSize(198,198)
Mock.Native("MinimapCompassTexture",Minimap)
Mock.Native("MicroMenuContainer"); Mock.Native("MicroMenu",MicroMenuContainer)
Mock.Native("BagsBar")
PlayerCastingBarFrame=Mock.Native("PlayerCastingBarFrame")
Mock.Child(PlayerCastingBarFrame,"Border")
StatusTrackingBarInfo={BarsEnum={Experience=4,Reputation=1}}
StatusTrackingBarManager=Mock.Native("StatusTrackingBarManager")
for _,name in ipairs({"MainStatusTrackingBarContainer","SecondaryStatusTrackingBarContainer"}) do
  local f=Mock.Native(name,StatusTrackingBarManager); f.bars={}
  for _,i in ipairs({1,4}) do
    local bar=Mock.Native(nil,f); bar:SetSize(565,11); f.bars[i]=bar
    bar.StatusBar=Mock.Native(nil,bar); bar.StatusBar:SetStatusBarTexture("native-fill")
  end
end

PetFrame=Mock.Native("PetFrame",PlayerFrame)
Mock.Child(PetFrame,"Portrait")
PetFrameTexture=Mock.Child(PetFrame,"FrameTexture")
PetFrameHealthBar=Mock.Native("PetFrameHealthBar",PetFrame)
PetFrameManaBar=Mock.Native("PetFrameManaBar",PetFrame)
TargetFrame.totFrame=Mock.Native(nil,TargetFrame)
local tot=TargetFrame.totFrame
for _,key in ipairs({"Portrait","FrameTexture","HealthBar","ManaBar"}) do Mock.Child(tot,key) end
for _,bar in ipairs({PetFrameHealthBar,PetFrameManaBar,tot.HealthBar,tot.ManaBar}) do
  bar:SetSize(70,10); bar:SetStatusBarTexture("native-small-bar")
  bar:SetScript("OnValueChanged",function() end)
  for _,key in ipairs({"MyHealPredictionBar","TotalAbsorbBar","HealAbsorbBar","Mask","Text"}) do Mock.Child(bar,key) end
end
