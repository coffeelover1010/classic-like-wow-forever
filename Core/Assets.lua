local _, CF = ...
CF.Assets = { Results = {}, Missing = {} }
function CF.Assets:Get(id) return CF.AssetCatalogue[id] end
function CF.Assets:Apply(texture, id)
  local asset = self:Get(id)
  if not asset then self.Missing[id] = true; return false end
  local ok, result
  if asset.atlas then
    if not CF.API.GetAtlasInfo(asset.atlas) then
      self.Results[id] = "ATLAS_NOT_FOUND"; return false
    end
    ok, result = pcall(texture.SetAtlas, texture, asset.atlas)
  else
    ok, result = pcall(texture.SetTexture, texture, asset.path)
  end
  if not ok or result == false then
    self.Results[id] = "LOAD_REJECTED"; self.Missing[id] = true
    return false
  end
  self.Results[id] = result == true and "LOAD_ACCEPTED_VISUAL_UNVERIFIED" or "REQUESTED_VISUAL_UNVERIFIED"
  self.Missing[id] = nil
  texture:SetTexCoord(unpack(asset.coords or {0, 1, 0, 1}))
  return true
end
function CF.Assets:Probe(id)
  if not self.ProbeTexture then
    self.ProbeFrame = CreateFrame("Frame")
    self.ProbeFrame:Hide()
    self.ProbeTexture = self.ProbeFrame:CreateTexture()
  end
  self:Apply(self.ProbeTexture, id)
  return self.Results[id] or "NOT_CONFIGURED"
end
function CF.Assets:Require(ids)
  for _, id in ipairs(ids) do
    if not self:Get(id) then return false, "Unconfigured asset: " .. id end
    local status = self:Probe(id)
    if status == "LOAD_REJECTED" or status == "ATLAS_NOT_FOUND" then
      return false, "Missing client art: " .. id .. "; /cf gallery"
    end
  end
  return true
end
