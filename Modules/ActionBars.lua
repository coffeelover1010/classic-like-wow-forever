local _, CF = ...
local M = { Ready = true }
function M:Initialize() self.Bar = _G.MainMenuBar end
function M:Enable() end -- visual mutations await source-verified, combat-safe implementation
function M:Disable() end
function M:Refresh() end
function M:RunDiagnostics() return self.Bar ~= nil end
CF:RegisterModule("ActionBars", M)
