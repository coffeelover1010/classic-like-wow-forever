local _, CF = ...
CF:RegisterModule("TargetOfTarget",CF.Visuals:SmallUnitModule(function()
  local frame = _G.TargetFrame and _G.TargetFrame.totFrame
  return frame, frame and frame.HealthBar, frame and frame.ManaBar,
    frame and frame.Portrait, frame and frame.FrameTexture
end))
