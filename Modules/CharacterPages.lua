local _, CF = ...
local P=CF.PassiveSkin
local W=CF.WindowTrim
CF:RegisterModule("CharacterPages",P:New(function()
  local result={}; local f=_G.CharacterFrame
  if not f or not P:Owned(f,f.Background,f.Inset) or not W:Valid(f.Inset,f.Inset.NineSlice,W.Inset) then return result end
  for _,name in ipairs({"ReputationFrame","TokenFrame"}) do
    local p=_G[name]
    if P:Owned(f,p) and P:Owned(p,p.ScrollBox,p.ScrollBar) then
      local guards={{f.Background,"character-panel-background"}}
      result[#result+1]={key=p,owner=p,anchor=f.Background,asset="CLASSIC_CHARACTER_BACKGROUND",guards=guards}
      for key,piece in pairs(W.Inset) do
        local n=f.Inset.NineSlice[key]
        result[#result+1]={key=name..key,owner=p,anchor=n,asset="CLASSIC_CHARACTER_"..piece[1],
          layer="ARTWORK",guards={{f.Background,"character-panel-background"},{n,piece[2]}}}
      end
    end
  end
  return result
end,{"CLASSIC_CHARACTER_BACKGROUND","CLASSIC_CHARACTER_TL","CLASSIC_CHARACTER_TR","CLASSIC_CHARACTER_BL",
  "CLASSIC_CHARACTER_BR","CLASSIC_CHARACTER_TOP","CLASSIC_CHARACTER_BOTTOM","CLASSIC_CHARACTER_LEFT","CLASSIC_CHARACTER_RIGHT"},
  {"UPDATE_FACTION","CURRENCY_DISPLAY_UPDATE"},
  "Reputation/currency page background and inset; native scrolling rows, standing colors, bars and transfer controls retained."))
