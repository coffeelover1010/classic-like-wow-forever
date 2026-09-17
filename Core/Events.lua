local _, CF = ...
CF.Events = { Registration = {} }
-- Missing load-on-demand frames can appear on their normal open/update event.
-- Discovery never creates art itself and cannot restart a faulted module.
function CF.Events:WatchUnavailable(module)
  if not module.WakeEvents or module.WakeFrame then return end
  local f=CreateFrame("Frame"); module.WakeFrame=f
  f:SetScript("OnEvent",function()
    if module.State=="UNAVAILABLE" and not module.Faulted then CF:RequestApply() end
  end)
  for _,event in ipairs(module.WakeEvents) do
    local ok=CF.API.RegisterEvent(f,event)
    self.Registration[event]=ok and "REGISTERED (not proof of delivery)" or "REJECTED"
  end
end
function CF.Events:Bind(module, events, handler)
  if module.EventFrame then module.EventFrame:UnregisterAllEvents() else module.EventFrame = CreateFrame("Frame") end
  local frame = module.EventFrame
  frame:SetScript("OnEvent", function(_, event, ...)
    if not module.Active or module.UpdateFailed then return end
    local ok, err = pcall(handler, module, event, ...)
    if not ok then
      module.Faulted, module.UpdateFailed, module.LastError, module.State = true, true, CF.API.SafeText(err), "UPDATE_FAILED"
      if CF.API.IsInCombatLockdown() then
        CF.Pending = true
      else
        CF:StopModule(module)
        module.State = "UPDATE_FAILED"
      end
      CF:Print(module.Name .. " update failed; default layout restores out of combat. /cf report")
      CF:RefreshOptions()
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
