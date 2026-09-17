local _, CF = ...
CF.Compat = {}
function CF.Compat:HasGlobal(name) return type(_G[name]) == "function" end
function CF.Compat:HasFrame(name) return _G[name] ~= nil end
function CF.Compat:IsSecureFrame(frame) return frame and frame.IsProtected and frame:IsProtected() or false end
function CF.Compat:Path(root, ...)
  for i = 1, select("#", ...) do
    if not root then return nil end
    root = root[select(i, ...)]
  end
  return root
end

-- Record only the properties we change. Never replace scripts, secure attributes,
-- unit tokens, action IDs, state drivers, or parents on Blizzard frames.
function CF.Compat:NewJournal()
  local journal = { entries = {}, seen = {} }
  function journal:Record(object, key, undo)
    assert(object, "Missing UI object for " .. key)
    self.seen[object] = self.seen[object] or {}
    if not self.seen[object][key] then
      self.seen[object][key] = true
      self.entries[#self.entries + 1] = undo
    end
  end
  function journal:Alpha(object, value)
    if not object then return end
    local before = object:GetAlpha()
    self:Record(object, "alpha", function() object:SetAlpha(before) end)
    object:SetAlpha(value)
  end
  function journal:Scale(object, value)
    local before = object:GetScale()
    self:Record(object, "scale", function() object:SetScale(before) end)
    object:SetScale(value)
  end
  function journal:Size(object, width, height)
    local w, h = object:GetSize()
    self:Record(object, "size", function() object:SetSize(w, h) end)
    object:SetSize(width, height)
  end
  function journal:Point(object, ...)
    local points = {}
    for i = 1, object:GetNumPoints() do points[i] = { object:GetPoint(i) } end
    self:Record(object, "points", function()
      object:ClearAllPoints()
      for _, p in ipairs(points) do object:SetPoint(unpack(p)) end
    end)
    object:ClearAllPoints()
    object:SetPoint(...)
  end
  function journal:Texture(object, id)
    local before = object:GetTexture()
    local atlas = object.GetAtlas and object:GetAtlas()
    local coords = {object:GetTexCoord()}
    self:Record(object, "texture", function()
      if atlas then object:SetAtlas(atlas) else object:SetTexture(before) end
      object:SetTexCoord(unpack(coords))
    end)
    if not CF.Assets:Apply(object,id) then error("Asset load rejected: " .. id) end
  end
  function journal:Restore()
    local errors = {}
    for i = #self.entries, 1, -1 do
      local ok, err = pcall(self.entries[i])
      if not ok then errors[#errors + 1] = CF.API.SafeText(err) end
    end
    if #errors > 0 then error(table.concat(errors, "; ")) end
    self.entries, self.seen = {}, {}
  end
  return journal
end
