local _, CF = ...
local M = { Trim = {} }
function M:Initialize()
  self.Header = CF.Compat:Path(_G.ObjectiveTrackerFrame,"Header")
  if not self.Header or not self.Header.Background then return false, "Native tracker header unavailable" end
  return CF.Assets:Require({"CLASSIC_BOOK_HEADER","CLASSIC_MAXLEVEL"})
end
function M:Enable()
  local header = self.Header
  -- Only the top header changes. Leave pooled quest rows, item buttons, progress
  -- bars, filtering, collapsing, height and Edit Mode positioning to Blizzard.
  self.Journal:Texture(header.Background,"CLASSIC_BOOK_HEADER")
  local trim = self.Trim[header]
  if not trim then
    trim = header:CreateTexture(nil,"BORDER")
    self.Trim[header] = trim
    trim:Hide()
    trim:SetPoint("TOPLEFT",header,"BOTTOMLEFT",0,2)
    trim:SetPoint("TOPRIGHT",header,"BOTTOMRIGHT",0,2)
    trim:SetHeight(3)
  end
  if not CF.Assets:Apply(trim,"CLASSIC_MAXLEVEL") then error("Tracker trim rejected") end
  trim:Show()
  return true, "Classic header/trim; native quest rows, item buttons and layout retained"
end
function M:Disable() for _,trim in pairs(self.Trim) do trim:Hide() end end
CF:RegisterModule("QuestTracker",M)
