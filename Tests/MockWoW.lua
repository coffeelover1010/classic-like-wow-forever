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
function Methods:Show() self.shown=true end
function Methods:Hide() self.shown=false end
function Methods:IsShown() return self.shown end
function Methods:IsVisible() return self.shown and (not self.parent or self.parent:IsVisible()) end
function Methods:SetShown(value) self.shown=value end
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
function Methods:CreateFontString(name,layer,font) return CreateFrame("FontString",name,self) end
function Mock.Native(name,parent)
  local f=CreateFrame("Frame",name,parent or UIParent)
  f.native=true
  f.points={{"CENTER",parent or UIParent,"CENTER",7,11}}
  return f
end
function Mock.Child(parent,key) local f=Mock.Native(nil,parent); parent[key]=f; return f end
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
