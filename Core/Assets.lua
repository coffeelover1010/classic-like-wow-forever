local _, CF = ...
CF.Assets = { Missing = {} }
function CF.Assets:Get(id)
  local asset = CF.AssetCatalogue[id]
  if not asset then self.Missing[id] = true; return nil end
  if asset.atlas and not CF.API.GetAtlasInfo(asset.atlas) then self.Missing[id] = true; return asset.fallback end
  return asset
end
