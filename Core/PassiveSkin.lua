local _, CF = ...
-- Cosmetic textures only. Selectors enumerate source-checked structures; no unit,
-- inventory or transaction values are read. Every refresh starts by hiding old art.
local P={}
CF.PassiveSkin=P
function P:Owned(owner, ...)
  if not owner then return false end
  for i=1,select("#",...) do
    local child=select(i,...)
    if not child or type(child.GetParent)~="function" or child:GetParent()~=owner then return false end
  end
  return true
end
function P:New(selectEntries, assets, events, detail)
  local m={Art={},Hooks={},SelectEntries=selectEntries,WakeEvents=events}
  function m:Initialize()
    if type(hooksecurefunc)~="function" then return false,"Secure texture hooks unavailable" end
    if #self:SelectEntries()==0 then return false,"Supported cosmetic structure missing; native art retained" end
    return CF.Assets:Require(assets)
  end
  function m:HideArt() for _,t in pairs(self.Art) do t:Hide() end end
  function m:Watch(native)
    local hooks=self.Hooks[native] or {}; self.Hooks[native]=hooks
    for _,method in ipairs({"SetAtlas","SetTexture","Show","Hide","SetAlpha","SetVertexColor"}) do
      if type(native[method])=="function" and not hooks[method] then
        hooksecurefunc(native,method,function()
          self:HideArt(); CF.DialogueSkin:Queue(self)
        end)
        hooks[method]=true
      end
    end
  end
  function m:RefreshArt()
    self:HideArt()
    local count=0
    for _,e in ipairs(self:SelectEntries()) do
      local ordinary=true
      for _,guard in ipairs(e.guards or {}) do
        local n=guard[1]; self:Watch(n)
        local atlas,alpha=n:GetAtlas(),n:GetAlpha()
        if CF.API.IsSecret(atlas) or atlas~=guard[2] or CF.API.IsSecret(alpha) or alpha~=1 or not n:IsShown() then
          ordinary=false
        end
        if type(n.GetVertexColor)=="function" then
          local r,g,b,a=n:GetVertexColor()
          if CF.API.IsSecret(r) or CF.API.IsSecret(g) or CF.API.IsSecret(b) or CF.API.IsSecret(a) or
              r~=1 or g~=1 or b~=1 or a~=1 then ordinary=false end
        end
      end
      if ordinary then
        local key=e.key or e.anchor
        local t=self.Art[key]
        if not t or t:GetParent()~=e.owner then
          if t then t:Hide() end
          t=e.owner:CreateTexture(nil,e.layer or "BACKGROUND",nil,e.sublevel or -1)
          self.Art[key]=t; t:Hide()
        end
        t:ClearAllPoints()
        if e.edge then
          local edge=e.edge; local outside=e.outside or 0; local size=e.size or 2
          if edge=="TOP" or edge=="BOTTOM" then
            local y=edge=="TOP" and outside or -outside
            local attach=edge=="TOP" and "BOTTOM" or "TOP"
            t:SetPoint(attach.."LEFT",e.anchor,edge.."LEFT",0,y)
            t:SetPoint(attach.."RIGHT",e.anchor,edge.."RIGHT",0,y); t:SetHeight(size)
          else
            local x=edge=="LEFT" and -outside or outside
            local attach=edge=="LEFT" and "RIGHT" or "LEFT"
            t:SetPoint("TOP"..attach,e.anchor,"TOP"..edge,x,0)
            t:SetPoint("BOTTOM"..attach,e.anchor,"BOTTOM"..edge,x,0); t:SetWidth(size)
          end
        elseif e.pad then
          t:SetPoint("TOPLEFT",e.anchor,"TOPLEFT",-e.pad,e.pad)
          t:SetPoint("BOTTOMRIGHT",e.anchor,"BOTTOMRIGHT",e.pad,-e.pad)
        else t:SetAllPoints(e.anchor) end
        if not CF.Assets:Apply(t,e.asset) then error("Passive artwork rejected: "..e.asset) end
        t:Show(); count=count+1
      end
    end
    self.Detail=detail.." Supported pieces: "..count..". Client checks pending"
  end
  function m:Enable()
    self:RefreshArt()
    CF.Events:Bind(self,events or {},function(module) CF.DialogueSkin:Queue(module) end)
    return true,self.Detail
  end
  function m:Disable() CF.Events:Unbind(self); self:HideArt() end
  return m
end
