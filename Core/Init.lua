local addonName, CF = ...
CF.Name, CF.Version = addonName, "0.8.0-alpha"
CF.Modules, CF.ModuleOrder = {}, {}
_G.ClassicForeverUI = CF

function CF:Print(message)
  if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cffd9b15fClassicForeverUI|r " .. message) end
end

function CF:RegisterModule(name, module)
  assert(not self.Modules[name], "Duplicate module: " .. name)
  module.Name, module.State = name, "NOT_INITIALIZED"
  self.Modules[name] = module
  self.ModuleOrder[#self.ModuleOrder + 1] = module
end

function CF:Call(module, method, ...)
  if not module[method] then return true end
  local ok, result, detail = pcall(module[method], module, ...)
  if not ok then
    module.LastError = CF.API.SafeText(result)
    module.State = "ERROR"
    return false, module.LastError
  end
  return true, result, detail
end

function CF:StopModule(module)
  local ok = self:Call(module, "Disable")
  if module.Journal then
    local restored, err = pcall(module.Journal.Restore, module.Journal)
    if not restored then module.LastError = CF.API.SafeText(err); ok = false end
  end
  module.Active = false
  if not ok then module.State = "RESTORE_FAILED_RELOAD_REQUIRED" end
  return ok
end

function CF:Apply()
  if CF.API.IsInCombatLockdown() then self.Pending = true; self:RefreshOptions(); return end
  self.Pending = false
  local supported = self.Environment.IsMainline or self.AllowUnverified
  for _, module in ipairs(self.ModuleOrder) do
    if module.Active or module.Journal then self:StopModule(module) end
    if module.State ~= "RESTORE_FAILED_RELOAD_REQUIRED" then
      if not self.DB.enabled or self.DB.modules[module.Name] == false then
        module.State = "DISABLED"
      elseif self.EditMode then
        module.State = "SUSPENDED_EDIT_MODE"
      elseif not supported then
        module.State = "CLIENT_NOT_ENABLED"
      elseif module.Deferred then
        module.State, module.Detail = "NOT_IMPLEMENTED", module.Deferred
      elseif module.Faulted then
        module.State = "UPDATE_FAILED"
      else
        module.LastError, module.Detail = nil, nil
        local ok, ready, reason = self:Call(module, "Initialize")
        if ok and ready ~= false then
          module.Journal = CF.Compat:NewJournal()
          local applied, enabled, detail = self:Call(module, "Enable")
          if applied and enabled ~= false then
            module.Active, module.State = true, "APPLIED_UNVERIFIED"
            module.Detail = detail or "Visual and interaction checks pending in this client"
          else
            self:StopModule(module)
            if module.State ~= "RESTORE_FAILED_RELOAD_REQUIRED" then
              module.State = applied and "UNAVAILABLE" or "ERROR"
            end
            module.Detail = detail or enabled
          end
        else
          module.State = ok and "UNAVAILABLE" or "ERROR"
          module.Detail = reason or ready
        end
      end
    end
  end
  self:RefreshOptions()
  self.Options:TryRegister()
end

function CF:RequestApply()
  self.Pending = true
  self:RefreshOptions()
  if not self.Started or self.Scheduled then return end
  self.Scheduled = true
  CF.API.NextFrame(function()
    self.Scheduled = false
    self:Apply()
  end)
end

function CF:Start()
  if self.Started then return end
  local saved = type(ClassicForeverUIDB) == "table" and ClassicForeverUIDB or {}
  self.DB = saved
  ClassicForeverUIDB = saved
  if type(saved.enabled) ~= "boolean" then saved.enabled = true end
  if type(saved.modules) ~= "table" then saved.modules = {} end
  self.Environment:Detect()
  self.Started = true
  if EventRegistry and type(EventRegistry.RegisterCallback) == "function" then
    EventRegistry:RegisterCallback("EditMode.Enter", function()
      self.EditMode = true
      -- Restore immediately, before Edit Mode can save addon positions.
      self:Apply()
    end, self)
    EventRegistry:RegisterCallback("EditMode.Exit", function()
      self.EditMode = false
      self:RequestApply()
    end, self)
  end
  self:RequestApply()
  self:Print("0.8 alpha loaded. /cf opens settings. /cf off restores the default UI. In-game testing is pending.")
end

local bootstrap = CreateFrame("Frame")
CF.BootstrapEvents = {}
for _,event in ipairs({"PLAYER_LOGIN","PLAYER_REGEN_ENABLED","PLAYER_ENTERING_WORLD","ADDON_LOADED"}) do
  local ok = pcall(bootstrap.RegisterEvent,bootstrap,event)
  CF.BootstrapEvents[event] = ok and "REGISTERED (not proof of delivery)" or "REJECTED"
end
bootstrap:SetScript("OnEvent", function(_, event, name)
  if event == "PLAYER_LOGIN" then
    local ok, err = pcall(CF.Start, CF)
    if not ok then CF.BootError = CF.API.SafeText(err); CF:Print("Bootstrap failed: " .. CF.BootError) end
  elseif CF.Started and (event == "PLAYER_ENTERING_WORLD" or
      (event == "PLAYER_REGEN_ENABLED" and CF.Pending) or
      (event == "ADDON_LOADED" and type(name) == "string" and name:match("^Blizzard_"))) then
    CF:RequestApply()
  end
end)
CF.Bootstrap = bootstrap
