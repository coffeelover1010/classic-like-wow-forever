local _, CF = ...
local W=CF.WindowTrim
local function borders()
  local result={}
  for i=1,7 do
    local f=i==7 and _G.ContainerFrameCombinedBags or _G["ContainerFrame"..i]
    -- Parent changes legitimately in fullscreen modes; require child ownership.
    if f and f.layoutType=="HeldBagLayout" and f.PortraitButton and
        f.PortraitButton:GetParent()==f and f.CloseButton and W:Valid(f,f.NineSlice,W.Bag) then
      result[#result+1]={f.NineSlice,W.Bag,true}
    end
  end
  return result
end
CF:RegisterModule("BagWindows",W:New(borders,{"BAG_UPDATE_DELAYED","CVAR_UPDATE","PLAYER_ENTERING_WORLD"},
  "Bag top/side/bottom trim (six individual bags and combined bags); native portrait corners, backgrounds and pooled items retained."))
