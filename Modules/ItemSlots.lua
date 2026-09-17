local _, CF = ...
local P=CF.PassiveSkin
local function add(result,owner,b,guards,decoration)
  if P:Owned(owner,b) and P:Owned(b,b.icon,b.IconBorder,b.Count,decoration or b.IconQuestTexture) then
    -- Keep native quality, search, cooldown and quest art in front. Pools still
    -- own visibility, item assignment and every click/drag action.
    result[#result+1]={owner=b,anchor=b.icon,asset="CLASSIC_SLOT_TRIM",pad=5,guards=guards}
  end
end
local M=P:New(function()
  local result={}
  for i=1,7 do
    local f=i==7 and _G.ContainerFrameCombinedBags or _G["ContainerFrame"..i]
    if f and f.layoutType=="HeldBagLayout" and P:Owned(f,f.PortraitButton,f.CloseButton) and type(f.Items)=="table" then
      for _,b in ipairs(f.Items) do
        if b.emptyBackgroundAtlas=="bags-item-slot64" then add(result,f,b) end
      end
    end
  end
  local bank=_G.BankFrame; local panel=bank and bank.BankPanel
  if P:Owned(bank,panel) and panel.layoutType=="InsetFrameTemplate" and
      P:Owned(panel,panel.AutoSortButton,panel.AutoDepositFrame) and
      type(panel.EnumerateValidItems)=="function" and type(panel.itemButtonPool)=="table" then
    for b in panel:EnumerateValidItems() do
      if P:Owned(b,b.Background,b.Cooldown) then add(result,panel,b,{{b.Background,"bags-item-slot64"}}) end
    end
  end
  local merchant=_G.MerchantFrame
  if merchant and merchant.CloseButton and merchant.FilterDropdown then
    for i=1,12 do
      local row=_G["MerchantItem"..i]
      if P:Owned(merchant,row) then add(result,row,_G["MerchantItem"..i.."ItemButton"]) end
    end
    if P:Owned(merchant,_G.MerchantBuyBackItem) then
      local b=_G.MerchantBuyBackItemItemButton
      if b and P:Owned(b,b.UndoFrame) and P:Owned(b.UndoFrame,b.UndoFrame.Arrow) then
        add(result,MerchantBuyBackItem,b,nil,b.UndoFrame)
      end
    end
  end
  return result
end,{"CLASSIC_SLOT_TRIM"},{"BAG_UPDATE_DELAYED","BANKFRAME_OPENED","BANK_TABS_CHANGED","MERCHANT_SHOW","MERCHANT_UPDATE"},
  "Original slot surrounds for supported bag, bank and merchant icons; native pooled item state and actions retained.")
local refresh=M.RefreshArt
M.PoolHooks={}
function M:RefreshArt()
  local function watch(owner,method)
    if not owner or type(owner[method])~="function" then return end
    local hooks=self.PoolHooks[owner] or {}; self.PoolHooks[owner]=hooks
    if not hooks[method] then
      hooksecurefunc(owner,method,function() self:HideArt(); CF.DialogueSkin:Queue(self) end)
      hooks[method]=true
    end
  end
  for i=1,7 do
    local f=i==7 and _G.ContainerFrameCombinedBags or _G["ContainerFrame"..i]
    if f and f.layoutType=="HeldBagLayout" and P:Owned(f,f.PortraitButton,f.CloseButton) then
      watch(f,"UpdateItemSlots")
    end
  end
  local bank=_G.BankFrame; local panel=bank and bank.BankPanel
  if P:Owned(bank,panel) and panel.layoutType=="InsetFrameTemplate" then
    watch(panel,"GenerateItemSlotsForSelectedTab")
  end
  return refresh(self)
end
local initialize=M.Initialize
function M:Initialize()
  local f=_G.ContainerFrameCombinedBags or _G.ContainerFrame1
  if type(hooksecurefunc)=="function" and f and f.layoutType=="HeldBagLayout" and
      P:Owned(f,f.PortraitButton,f.CloseButton) then return CF.Assets:Require({"CLASSIC_SLOT_TRIM"}) end
  return initialize(self)
end
CF:RegisterModule("ItemSlots",M)
