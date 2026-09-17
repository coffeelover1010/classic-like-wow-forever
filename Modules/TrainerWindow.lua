local _, CF = ...
local W=CF.WindowTrim
CF:RegisterModule("TrainerWindow",W:New(function()
  local result={}; local f=_G.ClassTrainerFrame
  if f and f.CloseButton then
    W:AddInset(result,f,f.Inset); W:AddInset(result,f,f.bottomInset)
  end
  return result
end,{"TRAINER_SHOW","TRAINER_UPDATE"},"Trainer inset trim; skill rows, costs, filters and training controls retained."))
