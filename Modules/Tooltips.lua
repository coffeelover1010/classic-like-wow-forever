local _, CF = ...
local M = { Skins = {} }
local pieces = {"TopLeftCorner","TopRightCorner","BottomLeftCorner","BottomRightCorner",
  "TopEdge","BottomEdge","LeftEdge","RightEdge","Center"}
function M:Initialize()
  self.Tips = {}
  for _,name in ipairs({"GameTooltip","ItemRefTooltip","ShoppingTooltip1","ShoppingTooltip2",
      "ItemRefShoppingTooltip1","ItemRefShoppingTooltip2"}) do
    local tip = _G[name]
    if tip and tip.NineSlice and tip.NineSlice.Center then self.Tips[#self.Tips+1] = tip end
  end
  if #self.Tips == 0 then return false, "Native tooltip artwork unavailable" end
  return CF.Assets:Require({"CLASSIC_TOOLTIP_BACKGROUND","CLASSIC_TOOLTIP_BORDER"})
end
function M:Enable()
  for _,tip in ipairs(self.Tips) do
    local skin = self.Skins[tip]
    if not skin then
      skin = CreateFrame("Frame",nil,tip.NineSlice,"BackdropTemplate")
      self.Skins[tip] = skin
      skin:Hide(); skin:EnableMouse(false); skin:SetAllPoints(tip)
    end
    -- Below the tooltip's text, inserted frames and native overlay decorations.
    skin:SetFrameLevel(math.max(0,tip:GetFrameLevel()-1))
    if type(skin.SetBackdrop) ~= "function" then error("BackdropTemplate unavailable") end
    skin:SetBackdrop({bgFile=CF.Assets:Get("CLASSIC_TOOLTIP_BACKGROUND").path,
      edgeFile=CF.Assets:Get("CLASSIC_TOOLTIP_BORDER").path,
      tile=true,tileSize=16,edgeSize=16,insets={left=4,right=4,top=4,bottom=4}})
    skin:SetBackdropColor(0.08,0.08,0.10,0.96)
    skin:SetBackdropBorderColor(0.65,0.65,0.65,1)
    -- Inherit native hiding for embedded tooltips as well as owner visibility.
    -- Mask regions individually, leaving the NineSlice frame's alpha intact.
    for _,key in ipairs(pieces) do self.Journal:Alpha(tip.NineSlice[key],0) end
    skin:Show()
  end
  return true, "Classic gray border/background; native content, anchors and comparisons retained"
end
function M:Disable() for _,skin in pairs(self.Skins) do skin:Hide() end end
CF:RegisterModule("Tooltips",M)
