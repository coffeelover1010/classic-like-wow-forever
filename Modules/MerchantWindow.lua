local _, CF = ...
local W=CF.WindowTrim
local function borders()
  local f=_G.MerchantFrame
  local inset=f and f.Inset
  if f and f.CloseButton and f.FilterDropdown and inset and inset:GetParent()==f and
      inset.layoutType=="InsetFrameTemplate" and W:Valid(inset,inset.NineSlice,W.Inset) then
    return {{inset.NineSlice,W.Inset}}
  end
  return {}
end
CF:RegisterModule("MerchantWindow",W:New(borders,{"MERCHANT_SHOW","MERCHANT_UPDATE"},
  "Merchant inset trim; native items, buy/sell, buyback, currency, repair and filter controls retained."))
