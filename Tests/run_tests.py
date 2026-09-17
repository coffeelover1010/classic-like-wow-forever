"""Lua 5.1 syntax and behavioral regression checks. Requires lupa (test-only)."""
from pathlib import Path
import csv
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]
TOC = ROOT / "ClassicForeverUI.toc"
FILES = [ROOT / line.strip() for line in TOC.read_text().splitlines()
         if line.strip() and not line.startswith("#")]


def client(setup=""):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute((ROOT / "Tests/MockWoW.lua").read_text())
    lua.execute(setup)
    shared = lua.table()
    loader = lua.eval("function(code,name,shared) local f,e=loadstring(code,name); assert(f,e); f('ClassicForeverUI',shared) end")
    for file in FILES:
        assert file.is_file(), file
        loader(file.read_text(), "@" + file.relative_to(ROOT).as_posix(), shared)
    return lua


def run(name, body, setup=""):
    lua = client(setup)
    lua.execute(body)
    print("PASS:", name)


run("login applies available modules; deferred modules are honest", """
Mock.Event("PLAYER_LOGIN")
for _,name in ipairs({"ActionBars","PlayerFrame","TargetFrame","Minimap","ExperienceBar","ReputationBar","MicroMenu","Bags","CastBar","Buffs","Debuffs","Tooltips","QuestTracker"}) do
  assert(ClassicForeverUI.Modules[name].State=="APPLIED_UNVERIFIED", name .. ": " .. ClassicForeverUI.Modules[name].State)
end
assert(ClassicForeverUI.Modules.FocusFrame.State=="APPLIED_UNVERIFIED")
assert(TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer:GetAlpha()==1)
assert(ActionButton1.action==1 and ActionButton12.action==12)
assert(ActionButton1.secureToken=="unchanged")
assert(ActionButton1:GetParent()==MainActionBarButtonContainer1)
SlashCmdList.CLASSICFOREVERUI("report")
SlashCmdList.CLASSICFOREVERUI("gallery")
assert(ClassicForeverUI.DB.lastReport:find("VISUAL_UNVERIFIED"))
""")

run("combat queues off; protected geometry restores exactly after combat", """
Mock.Event("PLAYER_LOGIN")
Mock.combat=true
local writes=Mock.nativeWrites
SlashCmdList.CLASSICFOREVERUI("off"); Mock.Flush()
assert(Mock.nativeWrites==writes and ClassicForeverUI.Pending)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(MainActionBar:GetWidth()==232 and MainActionBar:GetScale()==1)
local p,relative,rp,x,y=MainActionBar:GetPoint(1)
assert(p=="CENTER" and x==7 and y==11)
assert(PlayerFrame.PlayerFrameContainer:GetAlpha()==1)
assert(ClassicForeverUI.Modules.ActionBars.State=="DISABLED")
""")

run("Edit Mode suspends before save and resumes without accumulating frames", """
Mock.Event("PLAYER_LOGIN")
local count=#Mock.frames
Mock.Callback("EditMode.Enter")
assert(MainActionBar:GetWidth()==232)
assert(ClassicForeverUI.Modules.ActionBars.State=="SUSPENDED_EDIT_MODE")
PlayerFrame:ClearAllPoints(); PlayerFrame:SetPoint("TOPLEFT",UIParent,"TOPLEFT",321,-123)
Mock.Callback("EditMode.Exit")
assert(ClassicForeverUI.Modules.ActionBars.Active)
SlashCmdList.CLASSICFOREVERUI("off"); Mock.Flush()
local p,r,rp,x,y=PlayerFrame:GetPoint(1); assert(x==321 and y==-123)
assert(#Mock.frames==count)
""")

run("nil constants and unknown IDs never impersonate Retail or Classic", """
Mock.Event("PLAYER_LOGIN")
local e=ClassicForeverUI.Environment
assert(e.IsUnknown and not e.IsMainline and not e.IsClassic and not e.IsForever)
assert(ClassicForeverUI.Modules.ActionBars.State=="CLIENT_NOT_ENABLED")
SlashCmdList.CLASSICFOREVERUI("enable"); Mock.Flush()
assert(ClassicForeverUI.Modules.ActionBars.Active)
""", "WOW_PROJECT_ID=nil; WOW_PROJECT_MAINLINE=nil; WOW_PROJECT_CLASSIC=nil")

run("missing texture degrades minimap alone and restores originals", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.Minimap.State=="UNAVAILABLE")
assert(ClassicForeverUI.Modules.ActionBars.Active)
assert(MinimapCompassTexture:GetAlpha()==1)
""", r'Mock.missingTexture="Interface\\Minimap\\UI-Minimap-Border"')

run("nil SetTexture result never becomes asset OK", """
Mock.Event("PLAYER_LOGIN")
local r=ClassicForeverUI.Diagnostics:Collect()
assert(r:find("REQUESTED_VISUAL_UNVERIFIED"))
assert(not r:find(": OK") and not r:find(": READY"))
""", "Mock.nilTextureReturn=true")

run("missing unit API keeps default units but action bars work", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.PlayerFrame.State=="UNAVAILABLE")
assert(ClassicForeverUI.Modules.TargetFrame.State=="UNAVAILABLE")
assert(ClassicForeverUI.Modules.ActionBars.Active)
assert(PlayerFrame.PlayerFrameContainer:GetAlpha()==1)
""", "UnitPower=nil")

run("initialization and partial enable failures remain isolated", """
ClassicForeverUI:RegisterModule("InitializeFailure",{Initialize=function() error("init failure") end})
ClassicForeverUI:RegisterModule("EnableFailure",{
  Enable=function(self) self.Journal:Alpha(BagsBar,0); error("enable failure") end,
  Disable=function() end})
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.InitializeFailure.State=="ERROR")
assert(ClassicForeverUI.Modules.EnableFailure.State=="ERROR")
assert(ClassicForeverUI.Modules.ActionBars.Active and BagsBar:GetAlpha()==1)
""")

run("opaque health, power, name, level and classification are display-only", """
Mock.Event("PLAYER_LOGIN")
local v=ClassicForeverUI.Modules.PlayerFrame.Visual
assert(v.Power.value==Mock.power and v.Name.text==Mock.unitName)
Mock.combat=true; Mock.Event("UNIT_HEALTH","player")
assert(ClassicForeverUI.Modules.PlayerFrame.State=="APPLIED_UNVERIFIED")
assert(v.Level.text=="")
""", """
Mock.health=Mock.Secret(); Mock.maxHealth=Mock.Secret(); Mock.power=Mock.Secret()
Mock.maxPower=Mock.Secret(); Mock.unitName=Mock.Secret(); Mock.unitLevel=Mock.Secret()
Mock.powerType=Mock.Secret(); Mock.classification=Mock.Secret()
""")

run("runtime update failure stops retry loop and restores default out of combat", """
Mock.Event("PLAYER_LOGIN"); Mock.combat=true
UnitPower=function() error("runtime API restriction") end
Mock.Event("UNIT_HEALTH","player")
assert(ClassicForeverUI.Modules.PlayerFrame.State=="UPDATE_FAILED")
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(not ClassicForeverUI.Modules.PlayerFrame.Active)
assert(PlayerFrame.PlayerFrameContainer:GetAlpha()==1)
assert(ClassicForeverUI.Modules.ActionBars.Active)
""")

run("unknown event rolls back the affected skin", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.PlayerFrame.State=="ERROR")
assert(PlayerFrame.PlayerFrameContainer:GetAlpha()==1)
assert(ClassicForeverUI.Modules.ActionBars.Active)
""", 'Mock.rejectedEvent="UNIT_HEALTH"')

run("missing combat API prevents all layout changes", """
local before=Mock.nativeWrites
Mock.Event("PLAYER_LOGIN")
assert(Mock.nativeWrites==before and ClassicForeverUI.Pending)
""", "InCombatLockdown=nil")

run("late-loaded minimap recovers; per-module toggle is reversible", """
local minimap=Minimap; Minimap=nil
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.Minimap.State=="UNAVAILABLE")
Minimap=minimap; Mock.Event("ADDON_LOADED","Blizzard_Minimap")
assert(ClassicForeverUI.Modules.Minimap.Active)
SlashCmdList.CLASSICFOREVERUI("module Minimap off"); Mock.Flush()
assert(not ClassicForeverUI.Modules.Minimap.Active and ClassicForeverUI.Modules.ActionBars.Active)
assert(MinimapCompassTexture:GetAlpha()==1)
""")

run("player skin follows native vehicle token without changing secure attributes", """
Mock.Event("PLAYER_LOGIN")
PlayerFrame.unit="vehicle"
Mock.combat=true; Mock.Event("UNIT_ENTERED_VEHICLE","player")
local v=ClassicForeverUI.Modules.PlayerFrame.Visual
assert(v.Portrait.portraitUnit=="vehicle")
assert(ClassicForeverUI.Modules.PlayerFrame.Active)
PlayerFrame.unit="player"; Mock.Event("UNIT_EXITED_VEHICLE","player")
assert(v.Portrait.portraitUnit=="player")
""")

run("rejected optional bootstrap event does not block login", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.ActionBars.Active)
assert(ClassicForeverUI.Diagnostics:Collect():find("ADDON_LOADED: REJECTED"))
""", 'Mock.rejectedEvent="ADDON_LOADED"')

run("spellbook lazy loading, native controls and tab visibility", """
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.SpellBook
assert(m.State=="UNAVAILABLE" and m.Detail:find("Open the spellbook"))
local book=Mock.LoadSpellBook()
local button=book.items[1].Button
local click,drag=button:GetScript("OnClick"),button:GetScript("OnDragStart")
local parent,search,page=button:GetParent(),book.SearchBox,book.PagedSpellsFrame.PagingControls
Mock.Event("ADDON_LOADED","Blizzard_PlayerSpells")
assert(m.Active and m.Skin.mouse==false and m.Body.mouse==false)
assert(not m.Skin:IsVisible())
book:Show(); Mock.Callback("PlayerSpellsFrame.SpellBookFrame.Show")
assert(m.Skin:IsVisible() and book.TopBar:GetAlpha()==0)
assert(book.SearchBox==search and book.PagedSpellsFrame.PagingControls==page)
assert(button:GetScript("OnClick")==click and button:GetScript("OnDragStart")==drag)
assert(button:GetParent()==parent and button.secureToken=="spell-native")
assert(button.Icon:GetTexture()=="native-Icon" and button.Border:GetTexture()=="native-Border")
assert(button.AutoCastOverlay:GetAlpha()==1 and button.Cooldown:GetAlpha()==1)
assert(book.items[1].Backplate:GetAlpha()==0.25)
assert(PlayerSpellsFrame.TalentsFrame:GetAlpha()==1 and PlayerSpellsFrame:GetWidth()==232)
book:Hide()
assert(not m.Skin:IsVisible() and PlayerSpellsFrame.TalentsFrame:IsVisible())
""")

run("spellbook resize follows anchors and preserves latest native visibility on restore", """
Mock.Event("PLAYER_LOGIN")
local book=PlayerSpellsFrame.SpellBookFrame
local m=ClassicForeverUI.Modules.SpellBook
assert(m.Active and m.Skin.allPoints==book)
book:SetMinimized(false)
local before=Mock.nativeWrites
Mock.Callback("PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged")
assert(Mock.nativeWrites==before and book:GetWidth()==1612)
assert(book.BookBGLeft:IsShown() and not book.BookBGHalved:IsShown())
assert(book.BookBGLeft:GetAlpha()==0)
SlashCmdList.CLASSICFOREVERUI("module SpellBook off"); Mock.Flush()
assert(book:GetWidth()==1612 and book.BookBGLeft:IsShown() and not book.BookBGHalved:IsShown())
assert(book.BookBGLeft:GetAlpha()==1 and book.BookCornerFlipbook:GetAlpha()==0.7)
assert(book.TopBar:GetAtlas()=="native-TopBar")
local a,b,c,d=book.TopBar:GetTexCoord(); assert(a==0 and b==1 and c==0 and d==1)
assert(not m.Skin:IsShown() and ClassicForeverUI.Modules.ActionBars.Active)
local count=#Mock.frames
SlashCmdList.CLASSICFOREVERUI("module SpellBook on"); Mock.Flush()
assert(m.Active and #Mock.frames==count)
book:SetMinimized(true)
Mock.Callback("PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged")
assert(book:GetWidth()==806 and book.BookBGHalved:IsShown() and not book.BookBGLeft:IsShown())
""", "Mock.LoadSpellBook()")

run("spellbook pooled entries add one passive border and reuse it across pages", """
Mock.Event("PLAYER_LOGIN")
local book=PlayerSpellsFrame.SpellBookFrame
local m=ClassicForeverUI.Modules.SpellBook
local new=Mock.Spell(book,3)
local before=#Mock.frames
Mock.Callback("PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged")
assert(#Mock.frames==before+1 and m.Slots[new.Button]:IsShown())
local border=m.Slots[new.Button]
assert(border.layer=="ARTWORK" and border.sublevel==-2)
new.Button.spellID=999
for i=1,5 do Mock.Callback("PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged") end
assert(#Mock.frames==before+1 and m.Slots[new.Button]==border)
assert(new.Button.spellID==999 and new.TextContainer.text=="native localized spell name")
SlashCmdList.CLASSICFOREVERUI("off"); Mock.Flush()
for _,texture in pairs(m.Slots) do assert(not texture:IsShown()) end
local count=#Mock.frames
Mock.Callback("PlayerSpellsFrame.SpellBookFrame.Show")
assert(#Mock.frames==count and not border:IsShown())
""", "Mock.LoadSpellBook()")

run("spellbook page updates and disable defer during combat", """
Mock.Event("PLAYER_LOGIN")
local book=PlayerSpellsFrame.SpellBookFrame
local m=ClassicForeverUI.Modules.SpellBook
local new=Mock.Spell(book,3)
Mock.combat=true
local count,writes=#Mock.frames,Mock.nativeWrites
Mock.Callback("PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged")
assert(ClassicForeverUI.Pending and not m.Slots[new.Button])
assert(#Mock.frames==count and Mock.nativeWrites==writes)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(m.Slots[new.Button]:IsShown())
Mock.combat=true
SlashCmdList.CLASSICFOREVERUI("module SpellBook off"); Mock.Flush()
assert(m.Active and m.Skin:IsShown())
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(not m.Active and book.TopBar:GetAlpha()==1 and not m.Skin:IsShown())
""", "Mock.LoadSpellBook()")

run("missing spellbook art leaves stock book and other modules running", """
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.SpellBook
assert(m.State=="UNAVAILABLE" and not m.Skin)
assert(PlayerSpellsFrame.SpellBookFrame.BookBGHalved:GetAlpha()==1)
assert(ClassicForeverUI.Modules.ActionBars.Active)
""", r'Mock.LoadSpellBook(); Mock.missingTexture="Interface\\SpellBook\\UI-SpellbookPanel-TopLeft"')

run("spellbook update failure rolls back and stays stopped until explicit retry", """
Mock.Event("PLAYER_LOGIN")
local book=PlayerSpellsFrame.SpellBookFrame
local m=ClassicForeverUI.Modules.SpellBook
book.ForEachDisplayedSpell=function() error("pool changed") end
Mock.Callback("PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged")
assert(m.Faulted and not m.Active and m.State=="UPDATE_FAILED")
assert(book.TopBar:GetAlpha()==1 and not m.Skin:IsShown())
local count=#Mock.frames
Mock.Callback("PlayerSpellsFrame.SpellBookFrame.Show")
assert(#Mock.frames==count and ClassicForeverUI.Modules.ActionBars.Active)
book.ForEachDisplayedSpell=function(self,callback) for _,item in ipairs(self.items) do callback(item) end end
SlashCmdList.CLASSICFOREVERUI("refresh"); Mock.Flush()
assert(m.Active and not m.Faulted and #Mock.frames==count)
""", "Mock.LoadSpellBook()")

run("unexpected spellbook hierarchy remains untouched", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.SpellBook.State=="UNAVAILABLE")
assert(PlayerSpellsFrame.SpellBookFrame.TopBar:GetAlpha()==1)
""", "Mock.LoadSpellBook(); PlayerSpellsFrame.SpellBookFrame.ForEachDisplayedSpell=nil")

run("settings open through all aliases, show only supported controls and reuse the window", """
Mock.Event("PLAYER_LOGIN")
SlashCmdList.CLASSICFOREVERUI("")
local o=ClassicForeverUI.Options
assert(o.Frame:IsShown() and not o.LastError and o.Frame.clamped)
local count=0
for name,row in pairs(o.Rows) do
  count=count+1
  assert(not ClassicForeverUI.Modules[name].Deferred)
  assert(row:GetChecked()==(name~="ChatStyle"))
end
assert(count==38 and not o.Rows.Panels and o.Rows.Tooltips and o.Rows.CharacterWindow)
assert(o.Rows.SpellBook.Status.text=="Open book")
assert(o.Rows.Minimap.Status.text=="Applied")
local frames=#Mock.frames
Mock.Click(o.Frame.Close); assert(not o.Frame:IsShown())
SlashCmdList.CLASSICFOREVERUI("config"); assert(o.Frame:IsShown())
Mock.Escape(); assert(not o.Frame:IsShown())
SlashCmdList.CLASSICFOREVERUI("options")
assert(#Mock.frames==frames and #UISpecialFrames==1)
Mock.Escape(); SlashCmdList.CLASSICFOREVERUI("help")
assert(not o.Frame:IsShown())
""")

run("settings preserve saved choices and report data across master switches", """
Mock.Event("PLAYER_LOGIN"); SlashCmdList.CLASSICFOREVERUI("")
local cf=ClassicForeverUI; local o=cf.Options
assert(not o.Frame.Master:GetChecked() and not o.Rows.Minimap:GetChecked())
assert(o.Rows.ActionBars:GetChecked() and o.Rows.ActionBars.Status.text=="Paused")
Mock.Click(o.Rows.SpellBook)
assert(ClassicForeverUIDB.modules.SpellBook==false and not cf.Modules.ActionBars.Active)
Mock.Click(o.Frame.Master)
assert(cf.Modules.ActionBars.Active and not cf.Modules.Minimap.Active)
Mock.Click(o.Rows.Minimap)
assert(ClassicForeverUIDB.modules.Minimap and cf.Modules.Minimap.Active)
Mock.Click(o.Frame.Master); Mock.Click(o.Frame.Master)
assert(not cf.Modules.SpellBook.Active and ClassicForeverUIDB.modules.SpellBook==false)
assert(ClassicForeverUIDB.lastReport=="keep this report" and ClassicForeverUIDB.extra==42)
""", 'ClassicForeverUIDB={enabled=false,modules={Minimap=false},lastReport="keep this report",extra=42}')

run("settings queue combat changes and stay synchronized with slash controls", """
Mock.Event("PLAYER_LOGIN"); SlashCmdList.CLASSICFOREVERUI("")
local cf=ClassicForeverUI; local o=cf.Options
Mock.combat=true
local writes=Mock.nativeWrites
Mock.Click(o.Rows.Minimap)
assert(not o.Rows.Minimap:GetChecked() and cf.Modules.Minimap.Active)
assert(o.Rows.Minimap.Status.text=="Queued" and o.Frame.Notice.text:find("Waiting for combat"))
assert(Mock.nativeWrites==writes and cf.Pending)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
assert(not cf.Modules.Minimap.Active and o.Rows.Minimap.Status.text=="Off")
SlashCmdList.CLASSICFOREVERUI("module Minimap on"); Mock.Flush()
assert(o.Rows.Minimap:GetChecked() and o.Rows.Minimap.Status.text=="Applied")
SlashCmdList.CLASSICFOREVERUI("off"); Mock.Flush()
assert(not o.Frame.Master:GetChecked() and o.Rows.Minimap.Status.text=="Paused")
SlashCmdList.CLASSICFOREVERUI("on"); Mock.Flush()
Mock.Callback("EditMode.Enter")
assert(o.Rows.Minimap.Status.text=="Edit Mode" and o.Frame.Notice.text:find("Paused"))
Mock.Callback("EditMode.Exit")
assert(o.Rows.Minimap.Status.text=="Applied")
""")

run("settings retain explicit session-only opt-in on unknown clients", """
Mock.Event("PLAYER_LOGIN"); SlashCmdList.CLASSICFOREVERUI("")
local cf=ClassicForeverUI; local o=cf.Options
assert(o.Frame.Trial:IsShown() and o.Rows.ActionBars.Status.text=="Needs trial")
Mock.Click(o.Frame.Master); Mock.Click(o.Frame.Master)
assert(not cf.Modules.ActionBars.Active and not cf.AllowUnverified)
Mock.Click(o.Frame.Trial)
assert(cf.Modules.ActionBars.Active and not o.Frame.Trial:IsShown())
assert(not ClassicForeverUIDB.AllowUnverified and not ClassicForeverUIDB.allowUnverified)
""", 'WOW_PROJECT_ID=999')

run("settings launcher registers once when Blizzard Settings loads later", """
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI; local o=cf.Options
assert(not o.Category and cf.Modules.ActionBars.Active)
Mock.SettingsAPI(); Mock.Event("ADDON_LOADED","Blizzard_Settings")
assert(#Mock.categories==1 and Mock.categoryCalls==1)
local panel=o.Launcher; panel:Show(); Mock.Click(panel.Open)
assert(o.Frame:IsShown())
SlashCmdList.CLASSICFOREVERUI("refresh"); Mock.Flush()
assert(#Mock.categories==1 and Mock.categoryCalls==1)
""")

run("settings registration failure leaves standalone options and layout usable", """
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI; local o=cf.Options
assert(o.RegistrationFailed and cf.Modules.ActionBars.Active)
SlashCmdList.CLASSICFOREVERUI("")
assert(o.Frame:IsShown() and cf.Diagnostics:Collect():find("Settings error"))
Mock.Click(o.Rows.Minimap)
assert(not cf.Modules.Minimap.Active and Mock.categoryCalls==1)
""", 'Mock.SettingsAPI(); Settings.RegisterAddOnCategory=function() error("settings rejected") end')

run("settings fit a smaller display and tools open usable report and gallery", """
Mock.Event("PLAYER_LOGIN"); SlashCmdList.CLASSICFOREVERUI("")
local cf=ClassicForeverUI; local f=cf.Options.Frame
UIParent:SetSize(800,600); Mock.Event("DISPLAY_SIZE_CHANGED")
assert(f:GetWidth()*f:GetScale()<=768 and f:GetHeight()*f:GetScale()<=568)
Mock.Click(f.Report)
assert(cf.Diagnostics.ReportFrame:IsShown() and cf.Diagnostics.ReportFrame.Edit.text:find("ClassicForeverUI"))
cf.Diagnostics.ReportFrame:Hide()
Mock.Click(f.Gallery)
assert(cf.Diagnostics.GalleryFrame:IsShown())
""")

run("settings reflect runtime faults and Retry changes recovers the module", """
Mock.Event("PLAYER_LOGIN"); SlashCmdList.CLASSICFOREVERUI("")
local cf=ClassicForeverUI; local o=cf.Options
local original=UnitPower
UnitPower=function() error("temporary fault") end
Mock.Event("UNIT_HEALTH","player")
assert(o.Rows.PlayerFrame.Status.text=="Needs retry")
assert(not cf.Pending)
UnitPower=original; Mock.Click(o.Frame.Retry)
assert(cf.Modules.PlayerFrame.Active and o.Rows.PlayerFrame.Status.text=="Applied")
""")

run("settings refresh failures cannot block native restoration", """
Mock.Event("PLAYER_LOGIN"); SlashCmdList.CLASSICFOREVERUI("")
local cf=ClassicForeverUI
cf.Options.Refresh=function() error("options render error") end
SlashCmdList.CLASSICFOREVERUI("off"); Mock.Flush()
assert(not cf.Modules.ActionBars.Active and MainActionBar:GetWidth()==232)
assert(cf.Diagnostics:Collect():find("options render error"))
""")

run("settings remain usable when the client cannot report combat state", """
Mock.Event("PLAYER_LOGIN")
local before=Mock.nativeWrites
SlashCmdList.CLASSICFOREVERUI("")
local o=ClassicForeverUI.Options
assert(o.Frame:IsShown() and o.Frame.Notice.text:find("cannot apply"))
Mock.Click(o.Rows.Minimap)
assert(ClassicForeverUIDB.modules.Minimap==false and ClassicForeverUI.Pending)
assert(Mock.nativeWrites==before)
""", "InCombatLockdown=nil")

exec(compile((ROOT / "Tests/ui_pass_tests.py").read_text(), "ui_pass_tests.py", "exec"))
exec(compile((ROOT / "Tests/unit_pass_tests.py").read_text(), "unit_pass_tests.py", "exec"))
exec(compile((ROOT / "Tests/dialogue_tests.py").read_text(), "dialogue_tests.py", "exec"))
exec(compile((ROOT / "Tests/character_tests.py").read_text(), "character_tests.py", "exec"))
exec(compile((ROOT / "Tests/window_tests.py").read_text(), "window_tests.py", "exec"))
exec(compile((ROOT / "Tests/feature_tests.py").read_text(), "feature_tests.py", "exec"))
print(f"PASS: all {len(FILES)} TOC files compiled and executed by Lua 5.1")
with (ROOT / "Research/LocalAssetInventory.csv").open(newline="", encoding="utf-8") as f:
    extracted = {row["path"] for row in csv.DictReader(f) if row["status"] == "extracted"}
lua = client()
catalogue = lua.globals().ClassicForeverUI.AssetCatalogue
for asset in catalogue.values():
    assert asset.path + ".blp" in extracted, asset.path
print("PASS: every configured artwork path exists in the local extraction inventory")
