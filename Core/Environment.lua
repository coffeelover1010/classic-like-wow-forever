local _, CF = ...
CF.Environment = { IsForever = false, ForeverStatus = "FOREVER_VALIDATION_REQUIRED" }
function CF.Environment:Detect()
  self.ProjectID = _G.WOW_PROJECT_ID
  if type(GetBuildInfo) == "function" then
    self.Version, self.Build, self.BuildDate, self.Interface = GetBuildInfo()
  end
  self.Interface = tonumber(self.Interface)
  self.IsMainline, self.IsClassic = false, false
  self.Flavor = "Unknown"
  local projects = {
    { "WOW_PROJECT_MAINLINE", "Retail/Mainline" },
    { "WOW_PROJECT_CLASSIC", "Classic Era" },
    { "WOW_PROJECT_BURNING_CRUSADE_CLASSIC", "Burning Crusade Classic" },
    { "WOW_PROJECT_WRATH_CLASSIC", "Wrath Classic" },
    { "WOW_PROJECT_CATACLYSM_CLASSIC", "Cataclysm Classic" },
    { "WOW_PROJECT_MISTS_CLASSIC", "Mists Classic" },
  }
  for _, item in ipairs(projects) do
    local id = _G[item[1]]
    if id ~= nil and self.ProjectID ~= nil and self.ProjectID == id then
      self.Flavor = item[2]
      self.IsMainline = item[1] == "WOW_PROJECT_MAINLINE"
      self.IsClassic = not self.IsMainline
      break
    end
  end
  self.IsUnknown = not (self.IsMainline or self.IsClassic)
  -- A reused project ID cannot identify Forever or prove API compatibility.
  self.Channel = "Unknown (build metadata does not identify PTR/Beta reliably)"
end
function CF.Environment:Summary()
  return string.format("Project: %s | Interface: %s | Version: %s | Build: %s | Flavor: %s",
    tostring(self.ProjectID), tostring(self.Interface), tostring(self.Version), tostring(self.Build), self.Flavor or "Undetected")
end
