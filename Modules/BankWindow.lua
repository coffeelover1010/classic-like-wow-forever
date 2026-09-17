local _, CF = ...
local W=CF.WindowTrim
local function borders()
  local f=_G.BankFrame
  local p=f and f.BankPanel
  if f and f.CloseButton and f.TabSystem and f.BankItemSearchBox and p and p:GetParent()==f and
      p.layoutType=="InsetFrameTemplate" and p.AutoDepositFrame and p.AutoSortButton and
      W:Valid(p,p.NineSlice,W.Inset) then return {{p.NineSlice,W.Inset}} end
  return {}
end
CF:RegisterModule("BankWindow",W:New(borders,{"BANKFRAME_OPENED","BAG_UPDATE_DELAYED"},
  "Shared character/account bank inset trim; native tabs, items, reagent rules, prompts and controls retained."))
