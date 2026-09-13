local _, CF = ...
CF.Compat = {}

function CF.Compat:HasGlobal(name) return type(_G[name]) == "function" end
function CF.Compat:HasFrame(name) return _G[name] ~= nil end
function CF.Compat:IsSecureFrame(frame) return frame and frame.IsProtected and frame:IsProtected() or false end
