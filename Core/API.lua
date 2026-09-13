local _, CF = ...
CF.API = {}
function CF.API.GetUnitHealth(unit) return UnitHealth(unit) end
function CF.API.GetUnitPower(unit) return UnitPower(unit) end
function CF.API.GetUnitName(unit) return UnitName(unit) end
function CF.API.GetUnitLevel(unit) return UnitLevel(unit) end
function CF.API.RegisterEvent(frame, event) if frame and event then frame:RegisterEvent(event) end end
function CF.API.IsInCombatLockdown() return InCombatLockdown and InCombatLockdown() or false end
function CF.API.GetInterfaceVersion() return select(4, GetBuildInfo()) end
function CF.API.GetAtlasInfo(name)
  return C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(name) or nil
end
function CF.API.SetTexture(texture, assetID)
  local asset = CF.Assets:Get(assetID)
  if asset and asset.atlas then texture:SetAtlas(asset.atlas) elseif asset and asset.path then texture:SetTexture(asset.path) end
  return asset ~= nil
end
