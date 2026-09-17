local _, CF = ...
local M=CF.Visuals:SmallUnitModule(function()
  local frame=_G.FocusFrame and _G.FocusFrame.totFrame
  if frame and frame:GetParent()~=_G.FocusFrame then return end
  return frame,frame and frame.HealthBar,frame and frame.ManaBar,
    frame and frame.Portrait,frame and frame.FrameTexture
end)
M.WakeEvents={"PLAYER_FOCUS_CHANGED"}
CF:RegisterModule("FocusTarget",M)
