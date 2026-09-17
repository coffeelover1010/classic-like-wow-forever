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


run("login applies 9 implemented modules; deferred modules are honest", """
Mock.Event("PLAYER_LOGIN")
for _,name in ipairs({"ActionBars","PlayerFrame","TargetFrame","Minimap","ExperienceBar","ReputationBar","MicroMenu","Bags","CastBar"}) do
  assert(ClassicForeverUI.Modules[name].State=="APPLIED_UNVERIFIED", name .. ": " .. ClassicForeverUI.Modules[name].State)
end
assert(ClassicForeverUI.Modules.FocusFrame.State=="NOT_IMPLEMENTED")
assert(TargetFrame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer:GetAlpha()==0)
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
""", "UnitHealth=nil")

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
assert(v.Health.value==Mock.health and v.Name.text==Mock.unitName)
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
UnitHealth=function() error("runtime API restriction") end
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

print(f"PASS: all {len(FILES)} TOC files compiled and executed by Lua 5.1")
with (ROOT / "Research/LocalAssetInventory.csv").open(newline="", encoding="utf-8") as f:
    extracted = {row["path"] for row in csv.DictReader(f) if row["status"] == "extracted"}
lua = client()
catalogue = lua.globals().ClassicForeverUI.AssetCatalogue
for asset in catalogue.values():
    assert asset.path + ".blp" in extracted, asset.path
print("PASS: every configured artwork path exists in the local extraction inventory")
