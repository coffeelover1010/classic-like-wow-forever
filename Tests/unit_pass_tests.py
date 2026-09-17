"""0.6 unit frame cases, executed by run_tests.py."""
run("focus retains native health and native placement; refreshes portrait on focus change", """
local frame=FocusFrame
local health=frame.TargetFrameContent.TargetFrameContentMain.HealthBarsContainer
local script=health.HealthBar:GetScript("OnValueChanged")
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.FocusFrame
assert(m.Active and not m.Visual.Health)
local _,_,_,x,y=frame:GetPoint(1); assert(x==7 and y==11)
assert(health:GetAlpha()==1 and health.HealthBar:GetAlpha()==1)
assert(health.HealthBar:GetScript("OnValueChanged")==script)
assert(health.HealthBar.TotalAbsorbBar:GetAlpha()==1)
m.Visual.Portrait.portraitUnit=nil
Mock.Event("PLAYER_FOCUS_CHANGED")
assert(m.Visual.Portrait.portraitUnit=="focus")
SlashCmdList.CLASSICFOREVERUI("off"); Mock.Flush()
assert(frame.TargetFrameContainer:GetAlpha()==1 and not m.Visual:IsShown())
local _,_,_,hx,hy=health:GetPoint(1); assert(hx==7 and hy==11)
""")

run("compact focus stays native; other modules apply", """
Mock.Event("PLAYER_LOGIN")
local m=ClassicForeverUI.Modules.FocusFrame
assert(m.State=="UNAVAILABLE" and m.Detail:find("Compact"))
assert(FocusFrame.TargetFrameContainer:GetAlpha()==1)
assert(ClassicForeverUI.Modules.PetFrame.Active)
""", "FocusFrame.smallSize=true")

run("small unit trim leaves all native bars and controls untouched", """
local bar=PetFrameHealthBar
local script=bar:GetScript("OnValueChanged")
Mock.Event("PLAYER_LOGIN")
for _,name in ipairs({"PetFrame","TargetOfTarget"}) do
  local m=ClassicForeverUI.Modules[name]
  assert(m.Active)
  assert(m.Trims[m.Frame][1]:IsShown())
  assert(m.Health:GetAlpha()==1 and m.Power:GetAlpha()==1)
  assert(m.Health:GetWidth()==70 and m.Health:GetHeight()==10)
  assert(m.Health.TotalAbsorbBar:GetAlpha()==1 and m.Health.Mask:GetAlpha()==1)
end
assert(bar:GetScript("OnValueChanged")==script)
assert(PetFrameTexture:GetAlpha()==1)
SlashCmdList.CLASSICFOREVERUI("off"); Mock.Flush()
for _,name in ipairs({"PetFrame","TargetOfTarget"}) do
  local m=ClassicForeverUI.Modules[name]
  assert(not m.Trims[m.Frame][1]:IsShown())
end
""")

run("missing small hierarchy leaves native frame unchanged", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.PetFrame.State=="UNAVAILABLE")
assert(ClassicForeverUI.Modules.TargetOfTarget.State=="UNAVAILABLE")
assert(ClassicForeverUI.Modules.FocusFrame.Active)
assert(PetFrameTexture:GetAlpha()==1)
""", "PetFrameManaBar=nil; TargetFrame.totFrame.HealthBar=nil")

run("late small frame is discovered on refresh", """
Mock.Event("PLAYER_LOGIN")
assert(ClassicForeverUI.Modules.TargetOfTarget.State=="UNAVAILABLE")
TargetFrame.totFrame=savedTot
SlashCmdList.CLASSICFOREVERUI("refresh"); Mock.Flush()
assert(ClassicForeverUI.Modules.TargetOfTarget.Active)
""", "savedTot=TargetFrame.totFrame; TargetFrame.totFrame=nil")

run("unit settings defer in combat and preserve saved choices", """
Mock.Event("PLAYER_LOGIN"); SlashCmdList.CLASSICFOREVERUI("")
local cf=ClassicForeverUI
Mock.combat=true
local writes=Mock.nativeWrites
for _,name in ipairs({"FocusFrame","PetFrame","TargetOfTarget"}) do Mock.Click(cf.Options.Rows[name]) end
assert(Mock.nativeWrites==writes and cf.Pending)
Mock.combat=false; Mock.Event("PLAYER_REGEN_ENABLED")
for _,name in ipairs({"FocusFrame","PetFrame","TargetOfTarget"}) do
  assert(not cf.Modules[name].Active and cf.DB.modules[name]==false)
end
""")

run("Edit Mode rechecks compact focus and restores small trim", """
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI
Mock.Callback("EditMode.Enter")
assert(FocusFrame.TargetFrameContainer:GetAlpha()==1)
assert(not cf.Modules.PetFrame.Trims[PetFrame][1]:IsShown())
FocusFrame.smallSize=true
Mock.Callback("EditMode.Exit")
assert(cf.Modules.FocusFrame.State=="UNAVAILABLE")
assert(cf.Modules.PetFrame.Active)
FocusFrame.smallSize=false
SlashCmdList.CLASSICFOREVERUI("refresh"); Mock.Flush()
assert(cf.Modules.FocusFrame.Active)
""")

run("partial small trim failure is isolated and reusable", """
Mock.Event("PLAYER_LOGIN")
local cf=ClassicForeverUI
local m=cf.Modules.PetFrame
local trim=m.Trims[PetFrame][2]
local original=trim.SetTexture
trim.SetTexture=function() error("trim failure") end
SlashCmdList.CLASSICFOREVERUI("refresh"); Mock.Flush()
assert(not m.Active and not m.Trims[PetFrame][1]:IsShown())
assert(cf.Modules.TargetOfTarget.Active and cf.Modules.FocusFrame.Active)
trim.SetTexture=original
SlashCmdList.CLASSICFOREVERUI("refresh"); Mock.Flush()
assert(m.Active)
""")
