local _, CF = ...
CF:RegisterModule("PetFrame",CF.Visuals:SmallUnitModule(function()
  local frame = _G.PetFrame
  return frame, _G.PetFrameHealthBar, _G.PetFrameManaBar,
    frame and frame.Portrait, _G.PetFrameTexture
end))
