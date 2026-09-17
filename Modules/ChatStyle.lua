local _, CF = ...
local P=CF.PassiveSkin
-- Native tabs, background and input already use older Blizzard files. Optional
-- exterior trim only; this module never reads or sends any chat text.
local M=P:New(function()
  local result={}
  for i=1,10 do
    local f=_G["ChatFrame"..i]; local b=f and f.editBox
    if f and b and b==_G["ChatFrame"..i.."EditBox"] and P:Owned(b,b.focusLeft,b.focusMid,b.focusRight) then
      for _,edge in ipairs({"TOP","BOTTOM"}) do
        result[#result+1]={key="chat"..i..edge,owner=b,anchor=b,edge=edge,
          asset="CLASSIC_MAXLEVEL",size=2,layer="BACKGROUND",sublevel=-2}
      end
    end
  end
  return result
end,{"CLASSIC_MAXLEVEL"},{"UPDATE_CHAT_WINDOWS"},
  "Optional Classic input trim for ten standard chat windows; native tabs, background, fading, focus, text and channels retained.")
M.DefaultEnabled=false
CF:RegisterModule("ChatStyle",M)
