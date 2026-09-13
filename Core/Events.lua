local _, CF = ...
CF.Events = {}
function CF.Events:Create(handler)
  local frame = CreateFrame("Frame")
  frame:SetScript("OnEvent", handler)
  return frame
end
