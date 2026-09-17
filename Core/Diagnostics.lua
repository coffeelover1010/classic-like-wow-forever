local _, CF = ...
CF.Diagnostics = {}
local function sortedKeys(t)
  local keys = {}
  for key in pairs(t) do keys[#keys+1] = key end
  table.sort(keys)
  return keys
end
local function say(text) CF:Print(text) end
function CF.Diagnostics:Environment()
  if not CF.Started then CF.Environment:Detect() end
  say(CF.Environment:Summary())
  say("Channel: " .. (CF.Environment.Channel or "Unknown") .. " | Forever: UNVERIFIED")
  say("Combat/missing combat API: " .. tostring(CF.API.IsInCombatLockdown()) ..
    " | Deferred layout: " .. tostring(CF.Pending) .. " | Edit Mode: " .. tostring(CF.EditMode == true))
end
function CF.Diagnostics:AssetLines()
  local lines = {}
  for _, id in ipairs(sortedKeys(CF.AssetCatalogue)) do
    local asset = CF.AssetCatalogue[id]
    lines[#lines+1] = id .. ": " .. CF.Assets:Probe(id)
    lines[#lines+1] = "  " .. (asset.path or asset.atlas) .. " | Era extracted; Retail/Forever rendering unverified"
  end
  return lines
end
function CF.Diagnostics:Assets() for _, line in ipairs(self:AssetLines()) do say(line) end end
function CF.Diagnostics:APILines()
  local lines = {}
  for _, item in ipairs(CF.APIManifest) do
    local root = _G
    for part in item.name:gmatch("[^%.]+") do root = root and root[part] end
    lines[#lines+1] = item.name .. ": " .. (type(root) == "function" and "PRESENT" or "MISSING") .. " [" .. item.module .. "]"
  end
  return lines
end
function CF.Diagnostics:API() for _, line in ipairs(self:APILines()) do say(line) end end
function CF.Diagnostics:FrameLines()
  local lines = {}
  for _, item in ipairs(CF.FrameManifest) do
    local f = _G[item.name]
    local status = f and "PRESENT" or "MISSING"
    if f then
      local ok,protected = pcall(CF.Compat.IsSecureFrame,CF.Compat,f)
      if ok and protected then status = status .. " (protected)" end
    end
    lines[#lines+1] = item.name .. ": " .. status
  end
  return lines
end
function CF.Diagnostics:Frames() for _, line in ipairs(self:FrameLines()) do say(line) end end
function CF.Diagnostics:ModuleLines()
  local lines = {}
  for _,m in ipairs(CF.ModuleOrder) do
    lines[#lines+1] = m.Name .. ": " .. m.State .. (m.Detail and " | " .. CF.API.SafeText(m.Detail) or "")
    if m.LastError then lines[#lines+1] = "  Error: " .. m.LastError end
  end
  return lines
end
function CF.Diagnostics:Collect()
  if not CF.Started then CF.Environment:Detect() end
  local lines = {"ClassicForeverUI " .. CF.Version, CF.Environment:Summary(),
    "Forever API lineage: FOREVER_VALIDATION_REQUIRED",
    "No automatic status certifies in-game rendering, combat safety, or compatibility.",
    "Combat/missing API: " .. tostring(CF.API.IsInCombatLockdown()) .. "; Pending: " .. tostring(CF.Pending),
    "Edit Mode: " .. tostring(CF.EditMode == true)}
  if CF.BootError then lines[#lines+1] = "Bootstrap error: " .. CF.BootError end
  if CF.Options.LastError then lines[#lines+1] = "Settings error: " .. CF.Options.LastError end
  for _,section in ipairs({{"MODULES",self:ModuleLines()},{"ASSETS",self:AssetLines()},
    {"APIS",self:APILines()},{"FRAMES",self:FrameLines()}}) do
    lines[#lines+1] = section[1]
    for _,line in ipairs(section[2]) do lines[#lines+1] = line end
  end
  lines[#lines+1] = "EVENTS"
  for _,event in ipairs(sortedKeys(CF.EventManifest)) do
    lines[#lines+1] = event .. ": " .. (CF.Events.Registration[event] or CF.BootstrapEvents[event] or "NOT REGISTERED")
  end
  local report = table.concat(lines,"\n")
  if CF.DB then CF.DB.lastReport = report end
  return report
end
function CF.Diagnostics:Full()
  for line in self:Collect():gmatch("[^\n]+") do say(line) end
end

local function panel(title,width,height)
  local frame = CreateFrame("Frame",nil,UIParent)
  frame:SetSize(width,height)
  frame:SetPoint("CENTER")
  frame:SetFrameStrata("DIALOG")
  frame:EnableMouse(true)
  frame:SetMovable(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart",frame.StartMoving)
  frame:SetScript("OnDragStop",frame.StopMovingOrSizing)
  local background = frame:CreateTexture(nil,"BACKGROUND")
  background:SetAllPoints()
  background:SetColorTexture(0.04,0.04,0.05,0.98)
  local label = frame:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
  label:SetPoint("TOPLEFT",16,-14); label:SetText(title)
  local close = CreateFrame("Button",nil,frame,"UIPanelCloseButton")
  close:SetPoint("TOPRIGHT"); close:SetScript("OnClick",function() frame:Hide() end)
  return frame
end
function CF.Diagnostics:Report()
  if not self.ReportFrame then
    local f = panel("ClassicForeverUI: Ctrl+A, Ctrl+C to copy",780,530)
    self.ReportFrame = f
    local scroll = CreateFrame("ScrollFrame",nil,f,"UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",16,-45); scroll:SetPoint("BOTTOMRIGHT",-32,16)
    local edit = CreateFrame("EditBox",nil,scroll)
    edit:SetMultiLine(true); edit:SetAutoFocus(false); edit:SetFontObject(ChatFontNormal)
    edit:SetWidth(710); edit:SetHeight(440); edit:SetMaxLetters(0)
    edit:SetScript("OnEscapePressed",function() f:Hide() end)
    scroll:SetScrollChild(edit)
    f.Edit = edit
  end
  self.ReportFrame.Edit:SetText(self:Collect())
  self.ReportFrame:Show()
  self.ReportFrame.Edit:SetFocus()
  self.ReportFrame.Edit:HighlightText()
end
function CF.Diagnostics:Gallery()
  if not self.GalleryFrame then
    local f = panel("Original Blizzard artwork: visual check required",880,575)
    self.GalleryFrame = f
    f.Page = 1
    f.Cells = {}
    for i=1,6 do
      local cell = CreateFrame("Frame",nil,f)
      cell:SetSize(270,220)
      cell:SetPoint("TOPLEFT",f,"TOPLEFT",15+((i-1)%3)*285,-44-math.floor((i-1)/3)*230)
      cell.Label = cell:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
      cell.Label:SetPoint("TOPLEFT"); cell.Label:SetWidth(270)
      cell.Texture = cell:CreateTexture(nil,"ARTWORK")
      cell.Texture:SetPoint("CENTER",cell,"CENTER",0,12)
      cell.Status = cell:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
      cell.Status:SetPoint("BOTTOMLEFT",0,20); cell.Status:SetWidth(270)
      f.Cells[i] = cell
    end
    local nextButton = CreateFrame("Button",nil,f,"UIPanelButtonTemplate")
    nextButton:SetSize(110,24); nextButton:SetPoint("BOTTOMRIGHT",-16,14); nextButton:SetText("Next page")
    nextButton:SetScript("OnClick",function()
      f.Page = f.Page % math.ceil(#sortedKeys(CF.AssetCatalogue)/6)+1
      self:UpdateGallery()
    end)
    f.Note = f:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
    f.Note:SetPoint("BOTTOMLEFT",16,20)
  end
  self:UpdateGallery()
  self.GalleryFrame:Show()
end
function CF.Diagnostics:UpdateGallery()
  local f,keys = self.GalleryFrame,sortedKeys(CF.AssetCatalogue)
  for i,cell in ipairs(f.Cells) do
    local id = keys[(f.Page-1)*6+i]
    if id then
      local a = CF.AssetCatalogue[id]
      cell.Label:SetText(id)
      cell.Texture:SetSize(a.width or 256,a.height or 128)
      local accepted = CF.Assets:Apply(cell.Texture,id)
      cell.Texture:SetShown(accepted)
      cell.Status:SetText(CF.Assets.Results[id] or "UNTESTED")
      cell:Show()
    else cell:Hide() end
  end
  f.Note:SetText("Page " .. f.Page .. " | Check for blank/green art. /cf report copies build and results.")
end

SLASH_CLASSICFOREVERUI1 = "/cf"
SlashCmdList.CLASSICFOREVERUI = function(message)
  local cmd,arg,setting = (message or ""):match("^%s*(%S*)%s*(%S*)%s*(%S*)")
  cmd = (cmd or ""):lower()
  local actions = {diagnostic="Full",assets="Assets",api="API",frames="Frames",environment="Environment",report="Report",gallery="Gallery"}
  if cmd == "" or cmd == "config" or cmd == "options" then
    CF.Options:Show()
  elseif actions[cmd] then
    local ok,err = pcall(CF.Diagnostics[actions[cmd]],CF.Diagnostics)
    if not ok then say("Diagnostic failed: " .. CF.API.SafeText(err)) end
  elseif cmd == "off" or cmd == "on" or cmd == "enable" then
    if not CF.DB then say("Wait until PLAYER_LOGIN."); return end
    if cmd == "enable" then CF:EnableTrial() else CF:SetEnabled(cmd ~= "off") end
    say(cmd == "off" and "Default UI restoration requested." or "Layout requested; /cf diagnostic for results.")
    if CF.API.IsInCombatLockdown() then say("Queued until combat ends (or the combat API is available).") end
    if CF.Environment.IsUnknown and cmd == "on" then say("Unknown client: /cf enable opts into layout trials for this session.") end
  elseif cmd == "module" then
    if not CF.DB then say("Wait until PLAYER_LOGIN."); return end
    local found
    for name in pairs(CF.Modules) do if name:lower() == arg:lower() then found = name end end
    if not found or (setting ~= "on" and setting ~= "off") then
      say("Usage: /cf module ActionBars off (or on); names in /cf diagnostic"); return
    end
    CF:SetModuleEnabled(found,setting == "on")
    say(found .. " set " .. setting .. ". Changes wait for combat to end.")
  elseif cmd == "refresh" then
    CF:RetryModules()
  else
    say("/cf | config | options opens settings. Choices save automatically.")
    say("/cf on | off | enable (trial on unknown/Classic client) | refresh")
    say("/cf diagnostic | environment | assets | api | frames | gallery | report")
    say("/cf module <name> on|off. Edit Mode temporarily restores the default layout.")
  end
end
