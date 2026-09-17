local _, CF = ...
-- Explicitly selected window borders only; never traverse item pools or controls.
local W = {}
CF.WindowTrim = W
W.Inset = {
  TopLeftCorner={"TL","UI-Frame-InnerTopLeft"}, TopRightCorner={"TR","UI-Frame-InnerTopRight"},
  BottomLeftCorner={"BL","UI-Frame-InnerBotLeftCorner"}, BottomRightCorner={"BR","UI-Frame-InnerBotRight"},
  TopEdge={"TOP","_UI-Frame-InnerTopTile"}, BottomEdge={"BOTTOM","_UI-Frame-InnerBotTile"},
  LeftEdge={"LEFT","!UI-Frame-InnerLeftTile"}, RightEdge={"RIGHT","!UI-Frame-InnerRightTile"},
}
W.Bag = {
  TopEdge={"TOP","_UI-Frame-Metal-EdgeTop"},
  BottomEdge={"BOTTOM","_UI-Frame-Metal-EdgeBottom"},
  LeftEdge={"LEFT","!UI-Frame-Metal-EdgeLeft"}, RightEdge={"RIGHT","!UI-Frame-Metal-EdgeRight"},
}
W.Edges = {
  TopEdge={"TOP","_UI-Frame-Metal-EdgeTop"},
  BottomEdge=W.Bag.BottomEdge, LeftEdge=W.Bag.LeftEdge, RightEdge=W.Bag.RightEdge,
}

function W:AddInset(result, owner, inset)
  if owner and inset and inset:GetParent()==owner and inset.layoutType=="InsetFrameTemplate" and
      self:Valid(inset,inset.NineSlice,self.Inset) then
    result[#result+1]={inset.NineSlice,self.Inset}
  end
end

function W:Valid(owner, nine, pieces)
  if not owner or not nine or nine:GetParent() ~= owner then return false end
  for key in pairs(pieces) do
    if not nine[key] or nine[key]:GetParent() ~= nine then return false end
  end
  return true
end

function W:New(selectBorders, events, detail)
  local m = {Art={}, Hooks={}, SelectBorders=selectBorders,WakeEvents=events}
  function m:Initialize()
    if type(hooksecurefunc) ~= "function" then return false,"Secure texture hooks unavailable" end
    local borders=self:SelectBorders()
    if #borders == 0 then return false,"Supported window border missing; native window retained" end
    local ids,seen={},{}
    for _,entry in ipairs(borders) do
      for _,piece in pairs(entry[2]) do
        local id="CLASSIC_CHARACTER_"..piece[1]
        if not seen[id] then ids[#ids+1]=id; seen[id]=true end
      end
    end
    return CF.Assets:Require(ids)
  end
  function m:RefreshArt()
    for _,t in pairs(self.Art) do t:Hide() end
    local supported=0
    for _,entry in ipairs(self:SelectBorders()) do
      local nine,pieces,thin=entry[1],entry[2],entry[3]
      local ordinary=true
      for key,piece in pairs(pieces) do
        local native=nine[key]
        local hooks=self.Hooks[native] or {}; self.Hooks[native]=hooks
        for _,method in ipairs({"SetAtlas","SetTexture","Show","Hide","SetAlpha","SetVertexColor"}) do
          if type(native[method])=="function" and not hooks[method] then
            hooksecurefunc(native,method,function()
              -- Only hide our art here, even in combat. Recheck on the safe queue.
              for _,t in pairs(self.Art) do t:Hide() end
              CF.DialogueSkin:Queue(self)
            end)
            hooks[method]=true
          end
        end
        local atlas=native:GetAtlas()
        if CF.API.IsSecret(atlas) or atlas ~= piece[2] or not native:IsShown() then ordinary=false end
        if CF.API.IsSecret(native:GetAlpha()) then ordinary=false end
        if type(native.GetVertexColor)=="function" then
          local r,g,b,a=native:GetVertexColor()
          if CF.API.IsSecret(r) or CF.API.IsSecret(g) or CF.API.IsSecret(b) or CF.API.IsSecret(a) or
              r~=1 or g~=1 or b~=1 or a~=1 then ordinary=false end
        end
      end
      if ordinary then
        supported=supported+1
        for key,piece in pairs(pieces) do
          local native=nine[key]
          local t=self.Art[native]
          if not t or t:GetParent() ~= nine then
            t=nine:CreateTexture(nil,thin and "OVERLAY" or "BORDER",nil,thin and 1 or -4)
            self.Art[native]=t; t:Hide()
          end
          t:ClearAllPoints()
          if thin then
            -- Narrow strip centered on the existing edge; no portrait/header cover.
            if key=="BottomEdge" or key=="TopEdge" then
              t:SetPoint("LEFT",native,"LEFT",0,0); t:SetPoint("RIGHT",native,"RIGHT",0,0); t:SetHeight(4)
            else
              t:SetPoint("TOP",native,"TOP",0,0); t:SetPoint("BOTTOM",native,"BOTTOM",0,0); t:SetWidth(4)
            end
          else t:SetAllPoints(native) end
          if not CF.Assets:Apply(t,"CLASSIC_CHARACTER_"..piece[1]) then error("Window trim rejected") end
          t:SetAlpha(native:GetAlpha())
          t:Show()
        end
      end
    end
    self.Detail=detail.." Supported borders: "..supported..". Changed themes/structures stay native; client checks pending"
  end
  function m:Enable()
    self:RefreshArt()
    CF.Events:Bind(self,events,function(module) CF.DialogueSkin:Queue(module) end)
    return true,self.Detail
  end
  function m:Disable()
    CF.Events:Unbind(self)
    for _,t in pairs(self.Art) do t:Hide() end
  end
  return m
end
