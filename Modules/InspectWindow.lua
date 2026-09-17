local _, CF = ...
local W=CF.WindowTrim
CF:RegisterModule("InspectWindow",W:New(function()
  local result={}; local f=_G.InspectFrame
  if f and f.CloseButton then W:AddInset(result,f,f.Inset) end
  return result
end,{"INSPECT_READY"},"Inspect inset trim; equipment, model, stats and tabs retained."))
