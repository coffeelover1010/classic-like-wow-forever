local _, CF = ...
-- Shared only by the two standard NPC windows. No catch-all panel scanning.
local D = {}
CF.DialogueSkin = D
local pieces = {TopLeftCorner="TL", TopRightCorner="TR", BottomLeftCorner="BL",
  BottomRightCorner="BR", TopEdge="TOP", BottomEdge="BOTTOM", LeftEdge="LEFT", RightEdge="RIGHT"}

function D:Validate(frame)
  local nine = CF.Compat:Path(frame,"Inset","NineSlice")
  if not frame or not frame.CloseButton or not nine then return false end
  if frame.Inset:GetParent() ~= frame or nine:GetParent() ~= frame.Inset then return false end
  for key in pairs(pieces) do
    if not nine[key] or nine[key]:GetParent() ~= nine then return false end
  end
  return true
end

function D:Require(rewards)
  local ids = {"CLASSIC_QUEST_PAPER"}
  if rewards then ids[#ids+1] = "CLASSIC_QUICKSLOT" end
  for _,suffix in pairs(pieces) do ids[#ids+1] = "CLASSIC_QUEST_"..suffix end
  if type(hooksecurefunc) ~= "function" then return false, "Secure texture hooks unavailable" end
  return CF.Assets:Require(ids)
end

function D:Border(module, frame)
  local nine = frame.Inset.NineSlice
  for key,suffix in pairs(pieces) do
    local native = nine[key]
    local t = module.Art[native]
    if not t then
      t = nine:CreateTexture(nil,"ARTWORK")
      module.Art[native] = t; t:Hide(); t:SetAllPoints(native)
    end
    if not CF.Assets:Apply(t,"CLASSIC_QUEST_"..suffix) then error("Quest border rejected") end
    module.Journal:Alpha(native,0)
    t:Show()
  end
end

function D:Paper(module, native)
  local t = module.Papers[native]
  if not t then
    -- Cover only ordinary parchment. Native texture, alpha, atlas and material
    -- overlays remain untouched and continue to receive accessibility/theme updates.
    t = native:GetParent():CreateTexture(nil,"BACKGROUND",nil,1)
    module.Papers[native] = t; t:Hide(); t:SetAllPoints(native)
  end
  module.PaperHooks = module.PaperHooks or {}
  local hooks = module.PaperHooks[native] or {}
  module.PaperHooks[native] = hooks
  for _,method in ipairs({"SetAtlas","SetTexture","Hide","Show"}) do
    if not hooks[method] then
      local function changed()
        -- A pure addon-owned texture may be hidden even during combat. Reveal the
        -- new native background immediately; defer all creation/native writes.
        t:Hide()
        if module.Active then D:Queue(module) end
      end
      hooksecurefunc(native,method,changed)
      hooks[method] = true
    end
  end
  if not CF.Assets:Apply(t,"CLASSIC_QUEST_PAPER") then error("Quest parchment rejected") end
  local atlas = native:GetAtlas()
  t:SetShown(not CF.API.IsSecret(atlas) and atlas == "QuestBG-Parchment" and native:IsShown())
end

function D:Queue(module)
  if not module.Active or module.Faulted or module.Queued then return end
  module.Queued = true
  CF.API.NextFrame(function()
    module.Queued = nil
    if not module.Active or module.Faulted then return end
    if CF.API.IsInCombatLockdown() then CF.Pending=true; CF:RefreshOptions(); return end
    local ok = CF:Call(module,"RefreshArt")
    if not ok then
      module.Faulted = true; CF:StopModule(module)
      if module.State ~= "RESTORE_FAILED_RELOAD_REQUIRED" then module.State="UPDATE_FAILED" end
      CF:RefreshOptions()
    end
  end)
end

function D:Disable(module)
  CF.Events:Unbind(module)
  for _,t in pairs(module.Art) do t:Hide() end
  for _,t in pairs(module.Papers) do t:Hide() end
end
