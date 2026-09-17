local _, CF = ...
CF.Events = { Registration = {} }
function CF.Events:Bind(module, events, handler)
  if module.EventFrame then module.EventFrame:UnregisterAllEvents() else module.EventFrame = CreateFrame("Frame") end
  local frame = module.EventFrame
  frame:SetScript("OnEvent", function(_, event, ...)
    if not module.Active or module.UpdateFailed then return end
    local ok, err = pcall(handler, module, event, ...)
    if not ok then
      module.Faulted, module.UpdateFailed, module.LastError, module.State = true, true, CF.API.SafeText(err), "UPDATE_FAILED"
      CF.Pending = true
      if not CF.API.IsInCombatLockdown() then
        CF:StopModule(module)
        module.State = "UPDATE_FAILED"
      end
      CF:Print(module.Name .. " update failed; default layout restores out of combat. /cf report")
    end
  end)
  for _, event in ipairs(events) do
    local ok, err = CF.API.RegisterEvent(frame, event)
    self.Registration[event] = ok and "REGISTERED (not proof of delivery)" or "REJECTED"
    if not ok then error("Event " .. event .. " rejected: " .. CF.API.SafeText(err)) end
  end
end
function CF.Events:Unbind(module)
  if module.EventFrame then module.EventFrame:UnregisterAllEvents() end
  module.UpdateFailed = nil
end
