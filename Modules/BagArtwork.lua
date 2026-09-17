local _, CF = ...
local P=CF.PassiveSkin
CF:RegisterModule("BagArtwork",P:New(function()
  local result={}
  for _,name in ipairs({"MainMenuBarBackpackButton","CharacterBag0Slot","CharacterBag1Slot",
      "CharacterBag2Slot","CharacterBag3Slot","CharacterReagentBag0Slot"}) do
    local b=_G[name]
    if P:Owned(_G.BagsBar,b) and P:Owned(b,b.icon,b.CircleMask,b.IconBorder,b.Count,b.SlotHighlightTexture) then
      result[#result+1]={owner=b,anchor=b,asset="CLASSIC_SLOT_TRIM",pad=3}
    end
  end
  return result
end,{"CLASSIC_SLOT_TRIM"},{"BAG_UPDATE_DELAYED"},
  "Original slot surrounds for bag buttons; native circular icons, masks, counts, reagent bag, expand toggle and states retained."))
