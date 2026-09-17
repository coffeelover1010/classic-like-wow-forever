local _, CF = ...
-- The paper-doll page only. No generic panel traversal or equipment API reads.
local M = {Art={}, Slots={}, Hooks={}}
local pieces = {TopLeftCorner="TL", TopRightCorner="TR", BottomLeftCorner="BL",
  BottomRightCorner="BR", TopEdge="TOP", BottomEdge="BOTTOM", LeftEdge="LEFT", RightEdge="RIGHT"}
local slots = {"Head","Neck","Shoulder","Back","Chest","Shirt","Tabard","Wrist",
  "Hands","Waist","Legs","Feet","Finger0","Finger1","Trinket0","Trinket1","MainHand","SecondaryHand"}

function M:Initialize()
  local f,p,items = _G.CharacterFrame,_G.PaperDollFrame,_G.PaperDollItemsFrame
  local nine = CF.Compat:Path(f,"Inset","NineSlice")
  if not f or not p or p:GetParent() ~= f or not items or items:GetParent() ~= p or
      not f.Background or f.Background:GetParent() ~= f or not f.CloseButton or
      not nine or f.Inset:GetParent() ~= f or nine:GetParent() ~= f.Inset then
    return false, "Standard character paper-doll hierarchy missing; native window retained"
  end
  for key in pairs(pieces) do
    if not nine[key] or nine[key]:GetParent() ~= nine then
      return false, "Character inset border changed; native window retained"
    end
  end
  self.Frame,self.Page,self.Items,self.Nine = f,p,items,nine
  local ids={"CLASSIC_CHARACTER_BACKGROUND"}
  for _,suffix in pairs(pieces) do ids[#ids+1]="CLASSIC_CHARACTER_"..suffix end
  if type(hooksecurefunc) ~= "function" then return false,"Secure texture hooks unavailable" end
  return CF.Assets:Require(ids)
end

function M:RefreshArt()
  self.Detail="Changed character structure or background; native artwork retained"
  -- Hide first: unexpected ownership or themes must reveal native artwork.
  for _,t in pairs(self.Art) do t:Hide() end
  for _,t in pairs(self.Slots) do t:Hide() end
  local f,p=self.Frame,self.Page
  if f ~= _G.CharacterFrame or p ~= _G.PaperDollFrame or p:GetParent() ~= f or
      self.Items ~= _G.PaperDollItemsFrame or self.Items:GetParent() ~= p then return end
  local native=f.Background
  if not native or native:GetParent() ~= f then return end
  local atlas=native:GetAtlas()
  if CF.API.IsSecret(atlas) or atlas ~= "character-panel-background" or not native:IsShown() then return end
  if not f.Inset or f.Inset:GetParent() ~= f or f.Inset.NineSlice ~= self.Nine or
      self.Nine:GetParent() ~= f.Inset then return end
  for key in pairs(pieces) do
    if not self.Nine[key] or self.Nine[key]:GetParent() ~= self.Nine then return end
  end
  local function overlay(key, anchor, asset, layer)
    local t=self.Art[key]
    if not t or t:GetParent() ~= p then
      t=p:CreateTexture(nil,layer,nil,1); self.Art[key]=t; t:Hide()
    end
    t:SetAllPoints(anchor)
    if not CF.Assets:Apply(t,asset) then error("Character artwork rejected") end
    t:Show()
  end
  overlay(native,native,"CLASSIC_CHARACTER_BACKGROUND","BACKGROUND")
  for key,suffix in pairs(pieces) do
    overlay(self.Nine[key],self.Nine[key],"CLASSIC_CHARACTER_"..suffix,"ARTWORK")
  end
  local supported=0
  for _,name in ipairs(slots) do
    local b=_G["Character"..name.."Slot"]
    if b and b:GetParent() == self.Items and b.icon and b.icon:GetParent() == b and
        b.IconBorder and b.Cooldown and b.popoutButton and b.SocketDisplay then
      supported=supported+1
      -- Thin metal outside the icon. Keep the native Quickslot normal/pushed art.
      for _,edge in ipairs({"TOP","BOTTOM","LEFT","RIGHT"}) do
        local key="Character"..name.."Slot"..edge
        local t=self.Slots[key]
        if not t or t:GetParent() ~= b then
          t=b:CreateTexture(nil,"ARTWORK",nil,-2); self.Slots[key]=t; t:Hide()
        end
        t:ClearAllPoints()
        if edge=="TOP" or edge=="BOTTOM" then
          local y=edge=="TOP" and 4 or 0
          t:SetPoint("TOPLEFT",b.icon,edge.."LEFT",-4,y)
          t:SetPoint("TOPRIGHT",b.icon,edge.."RIGHT",4,y); t:SetHeight(4)
        else
          local x=edge=="LEFT" and -4 or 0
          t:SetPoint("TOPLEFT",b.icon,"TOP"..edge,x,0)
          t:SetPoint("BOTTOMLEFT",b.icon,"BOTTOM"..edge,x,0); t:SetWidth(4)
        end
        if not CF.Assets:Apply(t,"CLASSIC_CHARACTER_"..edge) then error("Character slot trim rejected") end
        t:Show()
      end
    end
  end
  self.Detail="Paper-doll background/inset and "..supported.."/18 slot trims. Native buttons, model, stats, outfits and other pages retained; unsupported slots unchanged"
end

function M:Enable()
  local native=self.Frame.Background
  local hooks=self.Hooks[native] or {}; self.Hooks[native]=hooks
  for _,method in ipairs({"SetAtlas","SetTexture","Show","Hide"}) do
    if not hooks[method] then
      hooksecurefunc(native,method,function()
        -- Reveal changed themes immediately, including in combat. Only our art hides.
        for _,t in pairs(self.Art) do t:Hide() end
        for _,t in pairs(self.Slots) do t:Hide() end
        CF.DialogueSkin:Queue(self)
      end)
      hooks[method]=true
    end
  end
  self:RefreshArt()
  CF.Events:Bind(self,{"PLAYER_EQUIPMENT_CHANGED"},function(m) CF.DialogueSkin:Queue(m) end)
  return true,self.Detail
end

function M:Disable()
  CF.Events:Unbind(self)
  for _,t in pairs(self.Art) do t:Hide() end
  for _,t in pairs(self.Slots) do t:Hide() end
end
CF:RegisterModule("CharacterWindow",M)
