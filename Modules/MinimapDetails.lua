local _, CF = ...
local P=CF.PassiveSkin
CF:RegisterModule("MinimapDetails",P:New(function()
  local result={}; local c=_G.MinimapCluster; local h=c and c.BorderTop
  if P:Owned(c,h) and h.layoutType=="UniqueCornersLayout" and h.layoutTextureKit=="ui-hud-minimap-button" and
      P:Owned(h,h.Center,h.TopEdge,h.BottomEdge) then
    local guards={{h.Center,"ui-hud-minimap-button-NineSlice-Center"},
      {h.TopEdge,"_ui-hud-minimap-button-NineSlice-EdgeTop"},{h.BottomEdge,"_ui-hud-minimap-button-NineSlice-EdgeBottom"}}
    result[#result+1]={owner=h,anchor=h.Center,asset="CLASSIC_CHARACTER_BACKGROUND",layer="BORDER",sublevel=1,guards=guards}
    for _,edge in ipairs({"TOP","BOTTOM"}) do
      result[#result+1]={key=edge,owner=h,anchor=h,edge=edge,asset="CLASSIC_MAXLEVEL",guards=guards}
    end
    local clock=_G.TimeManagerClockButton
    if P:Owned(c,clock) and P:Owned(clock,_G.TimeManagerClockTicker) then
      result[#result+1]={key=clock,owner=clock,anchor=clock,edge="BOTTOM",asset="CLASSIC_MAXLEVEL",guards=guards}
    end
  end
  local tracking=c and c.Tracking
  if P:Owned(c,tracking) and P:Owned(tracking,tracking.Background,tracking.Button) then
    result[#result+1]={owner=tracking,anchor=tracking.Button,asset="CLASSIC_TRACKING_RING",pad=4,
      guards={{tracking.Background,"ui-hud-minimap-button"}}}
  end
  return result
end,{"CLASSIC_CHARACTER_BACKGROUND","CLASSIC_MAXLEVEL","CLASSIC_TRACKING_RING"},{"CVAR_UPDATE"},
  "Classic header, clock underline and tracking ring; native zone text, clock/alarm, menus, mail and utility controls retained."))
