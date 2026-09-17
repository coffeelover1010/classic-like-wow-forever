local _, CF = ...
local W=CF.WindowTrim
-- ScrollingFlatPanelTemplate is not a ButtonFrameTemplate. Deliberately exclude
-- pooled item cards, selection/quality stripes, loot actions and animations.
CF:RegisterModule("LootWindow",W:New(function()
  local f=_G.LootFrame
  if f and f.layoutType=="ButtonFrameTemplateNoPortrait" and
      f.ScrollBox and f.ScrollBox:GetParent()==f and f.ScrollBar and
      f.ScrollBar:GetParent()==f and f.ClosePanelButton and f.ClosePanelButton:GetParent()==f and
      W:Valid(f,f.NineSlice,W.Edges) then return {{f.NineSlice,W.Edges,true}} end
  return {}
end,{"LOOT_OPENED","LOOT_CLOSED"},
  "Scrolling loot panel edge trim; native pooled item cards, quality, quest markers and auto-loot retained."))
