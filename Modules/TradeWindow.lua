local _, CF = ...
local W=CF.WindowTrim
local function borders()
  local result={}
  local f=_G.TradeFrame
  if f and f.CloseButton then
    -- Source reuses LeftInset for six different children; use their exact globals.
    for _,name in ipairs({"TradeRecipientItemsInset","TradeRecipientEnchantInset",
        "TradePlayerItemsInset","TradePlayerEnchantInset","TradePlayerInputMoneyInset","TradeRecipientMoneyInset"}) do
      W:AddInset(result,f,_G[name])
    end
  end
  return result
end
CF:RegisterModule("TradeWindow",W:New(borders,{"TRADE_SHOW"},
  "Trade item, enchant and money inset trim; acceptance colors, item slots and transaction controls retained."))
