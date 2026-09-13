local addonName, CF = ...
CF = CF or {}
CF.Name, CF.Version = addonName, "0.1.0-dev"
CF.Modules = {}

function CF:RegisterModule(name, module)
  module.Name = name
  self.Modules[name] = module
end

local bootstrap = CreateFrame("Frame")
bootstrap:RegisterEvent("PLAYER_LOGIN")
bootstrap:SetScript("OnEvent", function()
  CF.Environment:Detect()
  for _, module in pairs(CF.Modules) do
    if module.Initialize then module:Initialize() end
    if module.Enable then module:Enable() end
  end
end)

_G.ClassicForeverUI = CF
