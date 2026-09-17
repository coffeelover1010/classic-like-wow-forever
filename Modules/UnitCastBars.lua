local _, CF = ...
local P=CF.PassiveSkin
for _,name in ipairs({"Target","Focus"}) do
  local frameName=name.."Frame"
  CF:RegisterModule(name.."CastBar",P:New(function()
    local owner=_G[frameName]; local f=owner and owner.spellbar
    if P:Owned(owner,f) and P:Owned(f,f.Border,f.BorderShield,f.Icon,f.Text,f.Spark,f.Flash) then
      return {{owner=f,anchor=f.Border,asset="CLASSIC_CAST_SMALL",pad=4,
        guards={{f.Border,"ui-castingbar-frame"}}}}
    end
    return {}
  end,{"CLASSIC_CAST_SMALL"},{"PLAYER_TARGET_CHANGED","PLAYER_FOCUS_CHANGED"},
    "Original cast surround at native size/position; native fill, shield, text, flash, channel and empower behavior retained."))
end
