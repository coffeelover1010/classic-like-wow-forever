local _, CF = ...
CF.Environment = { IsForever = false }

function CF.Environment:Detect()
  self.ProjectID = _G.WOW_PROJECT_ID
  self.Interface = tonumber((select(4, GetBuildInfo())))
  self.Version, self.Build = GetBuildInfo()
  self.IsMainline = self.ProjectID == _G.WOW_PROJECT_MAINLINE
  self.IsClassic = self.ProjectID == _G.WOW_PROJECT_CLASSIC
    or self.ProjectID == _G.WOW_PROJECT_BURNING_CRUSADE_CLASSIC
    or self.ProjectID == _G.WOW_PROJECT_WRATH_CLASSIC
    or self.ProjectID == _G.WOW_PROJECT_CATACLYSM_CLASSIC
  self.Flavor = self.IsMainline and "Retail/Mainline" or self.IsClassic and "Classic" or "Unknown"
  self.IsUnknown = not self.IsMainline and not self.IsClassic
end

function CF.Environment:Summary()
  return string.format("Project ID: %s | Interface: %s | Build: %s | Flavor: %s",
    tostring(self.ProjectID), tostring(self.Interface), tostring(self.Build), self.Flavor or "Undetected")
end
