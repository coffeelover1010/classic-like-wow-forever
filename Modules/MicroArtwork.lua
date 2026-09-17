local _, CF = ...
local P=CF.PassiveSkin
local M={}
local buttons={{"QuestLogMicroButton","Questlog","QUEST"},{"PlayerSpellsMicroButton","SpecTalents","TALENTS"}}
local states={{"GetNormalTexture","Up"},{"GetPushedTexture","Down"},{"GetDisabledTexture","Disabled"}}
function M:Initialize()
  if not _G.MicroMenu then return false,"Native micro menu missing" end
  local found=false
  for _,b in ipairs(buttons) do if P:Owned(_G.MicroMenu,_G[b[1]]) then found=true end end
  if not found then return false,"Supported quest/talent buttons missing; native menu retained" end
  local ids={}
  for _,b in ipairs(buttons) do for _,s in ipairs(states) do ids[#ids+1]="CLASSIC_MICRO_"..b[3].."_"..s[2] end end
  return CF.Assets:Require(ids)
end
function M:Enable()
  local count=0
  for _,spec in ipairs(buttons) do
    local b=_G[spec[1]]; local textures={}; local ordinary=P:Owned(_G.MicroMenu,b)
    if ordinary then
      for _,s in ipairs(states) do
        local t=type(b[s[1]])=="function" and b[s[1]](b)
        local atlas=t and t:GetAtlas()
        if not P:Owned(b,t) or CF.API.IsSecret(atlas) or atlas~="UI-HUD-MicroMenu-"..spec[2].."-"..s[2] then ordinary=false end
        textures[#textures+1]=t
      end
    end
    if ordinary then
      for i,s in ipairs(states) do
        local t=textures[i]; local before=t:GetAtlas(); local coords={t:GetTexCoord()}
        local applied,finished
        -- A later native theme/texture update wins, including updates in combat.
        -- Restore only an unchanged texture that this application still owns.
        self.Journal:Record(t,"micro-art",function()
          local current,atlas=t:GetTexture(),t:GetAtlas()
          if not finished or (not CF.API.IsSecret(current) and not CF.API.IsSecret(atlas) and
              applied and current==applied and not atlas) then
            t:SetAtlas(before); t:SetTexCoord(unpack(coords))
          end
        end)
        local ok=CF.Assets:Apply(t,"CLASSIC_MICRO_"..spec[3].."_"..s[2])
        local value=t:GetTexture()
        if not CF.API.IsSecret(value) then applied=value end
        finished=true
        if not ok then error("Micro button artwork rejected") end
      end
      count=count+1
    end
  end
  return true,"Original quest/talent normal, pressed and disabled art: "..count.."/2 buttons. Native highlights, alerts and newer functions retained"
end
function M:Disable() end
CF:RegisterModule("MicroArtwork",M)
