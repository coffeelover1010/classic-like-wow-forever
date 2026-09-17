local _, CF = ...
local O = { Rows = {} }
CF.Options = O

-- Only implemented features belong in the player-facing settings window.
O.Groups = {
  { title = "HUD & frames", items = {
    {"ActionBars", "Action bars", "Stone panels, gryphons and spell slots."},
    {"PlayerFrame", "Player frame", "Classic trim. Native health and shields."},
    {"TargetFrame", "Target frame", "Classic borders and target details."},
    {"FocusFrame", "Focus frame", "Classic skin for full-size focus."},
    {"PetFrame", "Pet frame", "Classic trim. Native bars stay."},
    {"Minimap", "Minimap", "The original round minimap border."},
    {"CastBar", "Cast bar", "Classic border and bar placement."},
    {"Buffs", "Buffs", "Classic borders around your buffs."},
    {"Debuffs", "Debuffs", "Classic borders. Dispel colors stay."},
  }},
  { title = "Bars & panels", items = {
    {"TargetOfTarget", "Target of target", "Classic trim. Native bars stay."},
    {"SpellBook", "Spellbook", "Parchment, metal trim and spell slots."},
    {"ExperienceBar", "Experience bar", "Classic fill and trim for the XP bar."},
    {"ReputationBar", "Reputation bar", "Classic fill for your tracked faction."},
    {"MicroMenu", "Menu buttons", "Move the menu into the bottom bar."},
    {"Bags", "Bag buttons", "Move bag buttons into the bottom bar."},
    {"Tooltips", "Tooltips", "Classic background and gray border."},
    {"QuestDialogue", "Quest windows", "Classic paper, trim and reward slots."},
    {"GossipDialogue", "NPC dialogue", "Classic paper and dialogue trim."},
    {"QuestTracker", "Quest tracker", "Classic trim for the tracker header."},
  }},
}
local colors = {
  text = {0.93,0.91,0.85}, muted = {0.64,0.64,0.60}, gold = {0.88,0.72,0.40},
  green = {0.57,0.78,0.58}, red = {0.94,0.54,0.46},
}

function CF:SetEnabled(value)
  if not self.DB then return false end
  self.DB.enabled = value == true
  self:RequestApply()
  return true
end
function CF:SetModuleEnabled(name, value)
  if not self.DB or not self.Modules[name] then return false end
  self.DB.modules[name] = value == true
  self:RequestApply()
  return true
end
function CF:EnableTrial()
  if not self.DB then return false end
  self.AllowUnverified = true
  return self:SetEnabled(true)
end
function CF:RetryModules()
  if not self.DB then return false end
  for _,module in ipairs(self.ModuleOrder) do module.Faulted = nil end
  self:RequestApply()
  return true
end

-- A settings-rendering failure must never interrupt layout application.
function CF:RefreshOptions()
  if not O.Frame or not O.Frame:IsShown() then return end
  local ok, err = pcall(O.Refresh, O)
  if not ok then O.LastError = CF.API.SafeText(err) end
end

local function fill(parent, r,g,b,a, layer)
  local t = parent:CreateTexture(nil, layer or "BACKGROUND")
  t:SetAllPoints(parent); t:SetColorTexture(r,g,b,a or 1)
  return t
end
local function label(parent, text, font, x,y,w,h, color)
  local t = parent:CreateFontString(nil,"OVERLAY",font or "GameFontHighlightSmall")
  t:SetPoint("TOPLEFT",parent,"TOPLEFT",x,-y); t:SetSize(w,h)
  t:SetJustifyH("LEFT"); t:SetTextColor(unpack(colors[color or "text"]))
  t:SetText(text)
  return t
end
local function button(parent, text, width, action)
  local b = CreateFrame("Button",nil,parent)
  b:SetSize(width,30)
  fill(b,0.19,0.17,0.13)
  local hover = fill(b,1,0.83,0.46,0.10,"HIGHLIGHT")
  b:SetHighlightTexture(hover)
  local title = label(b,text,"GameFontHighlightSmall",0,0,width,30)
  title:SetJustifyH("CENTER")
  b:SetScript("OnClick",action)
  return b
end
local function choice(parent, title, description, width)
  local row = CreateFrame("CheckButton",nil,parent)
  row:SetSize(width,52)
  row.Background = fill(row,0.105,0.10,0.088)
  local square = row:CreateTexture(nil,"ARTWORK")
  square:SetSize(18,18); square:SetPoint("TOPLEFT",row,"TOPLEFT",12,-9)
  square:SetColorTexture(0.34,0.30,0.22,1)
  local inset = row:CreateTexture(nil,"ARTWORK",nil,1)
  inset:SetSize(16,16); inset:SetPoint("CENTER",square,"CENTER",0,0)
  inset:SetColorTexture(0.055,0.05,0.04,1)
  row:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
  local check = row:GetCheckedTexture()
  check:SetDrawLayer("OVERLAY",1)
  check:ClearAllPoints(); check:SetSize(26,26)
  check:SetPoint("CENTER",square,"CENTER",0,0)
  row:SetHighlightTexture(fill(row,1,0.83,0.46,0.045,"HIGHLIGHT"))
  row.Title = label(row,title,"GameFontHighlight",42,8,width-142,18)
  row.Description = label(row,description,"GameFontHighlightSmall",42,29,width-52,16,"muted")
  row.Status = label(row,"","GameFontHighlightSmall",width-102,9,90,16,"muted")
  row.Status:SetJustifyH("RIGHT")
  return row
end

function O:RowStatus(module, selected)
  if CF.Pending then return "Queued", "gold" end
  if not selected then return "Off", "muted" end
  if not CF.DB.enabled then return "Paused", "muted" end
  if CF.EditMode then return "Edit Mode", "gold" end
  if not CF.Environment.IsMainline and not CF.AllowUnverified then return "Needs trial", "gold" end
  local state = module.State
  if state == "APPLIED_UNVERIFIED" then return "Applied", "green" end
  if state == "RESTORE_FAILED_RELOAD_REQUIRED" then return "Reload needed", "red" end
  if module.Faulted or state == "ERROR" or state == "UPDATE_FAILED" then return "Needs retry", "red" end
  if state == "UNAVAILABLE" then
    if module.Name == "SpellBook" and not CF.Compat:Path(_G.PlayerSpellsFrame,"SpellBookFrame") then
      return "Open book", "gold"
    end
    return "Unavailable", "gold"
  end
  return "Waiting", "muted"
end

function O:Refresh()
  local f = self.Frame
  if not f or not CF.DB then return end
  f.Master:SetChecked(CF.DB.enabled)
  f.Master.Status:SetText(CF.DB.enabled and "On" or "Off")
  f.Master.Status:SetTextColor(unpack(colors[CF.DB.enabled and "green" or "muted"]))
  local trial = not CF.Environment.IsMainline and not CF.AllowUnverified
  f.Trial:SetShown(trial)
  local message
  if CF.Pending then
    if type(InCombatLockdown) ~= "function" then
      message = "Changes saved. This client cannot apply them yet."
    else
      message = CF.API.IsInCombatLockdown() and "Changes saved. Waiting for combat to end." or "Applying your choices..."
    end
  elseif not CF.DB.enabled then message = "Off. Your feature choices are saved."
  elseif trial then message = "This client needs a trial before the layout can apply."
  elseif CF.EditMode then message = "Paused while you use Edit Mode."
  else message = "Choose the parts of the Classic look you want." end
  f.Notice:SetText(message)
  for name, row in pairs(self.Rows) do
    local selected = CF.DB.modules[name] ~= false
    row:SetChecked(selected)
    local text, color = self:RowStatus(CF.Modules[name], selected)
    row.Status:SetText(text); row.Status:SetTextColor(unpack(colors[color]))
  end
end

function O:Fit()
  self.Frame:SetScale(math.max(0.1,math.min(1,(UIParent:GetWidth()-32)/700,(UIParent:GetHeight()-32)/870)))
end

function O:Build()
  local f = CreateFrame("Frame","ClassicForeverUIOptions",UIParent)
  self.Frame = f
  f:Hide(); f:SetSize(700,870); f:SetPoint("CENTER",UIParent,"CENTER",0,0)
  f:SetFrameStrata("DIALOG"); f:SetClampedToScreen(true)
  f:EnableMouse(true); f:SetMovable(true); f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart",f.StartMoving); f:SetScript("OnDragStop",f.StopMovingOrSizing)
  f:SetScript("OnHide",f.StopMovingOrSizing)
  fill(f,0.060,0.057,0.049,0.99)
  local accent = f:CreateTexture(nil,"ARTWORK")
  accent:SetPoint("TOPLEFT",f,"TOPLEFT",0,0); accent:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,0)
  accent:SetHeight(2); accent:SetColorTexture(unpack(colors.gold))
  label(f,"ClassicForeverUI","GameFontNormalLarge",24,19,460,26,"gold")
  label(f,"A familiar look. Your choice.",nil,24,50,520,18,"muted")
  f.Close = button(f,"Close",64,function() f:Hide() end)
  f.Close:SetPoint("TOPRIGHT",f,"TOPRIGHT",-24,-20)
  f.Master = choice(f,"Enable ClassicForeverUI","Turn off to restore Blizzard's layout. Your choices stay saved.",652)
  f.Master:SetPoint("TOPLEFT",f,"TOPLEFT",24,-84)
  f.Master:SetScript("OnClick",function(b) CF:SetEnabled(b:GetChecked()) end)
  f.Notice = label(f,"",nil,24,154,490,36,"muted")
  f.Trial = button(f,"Try this session",132,function() CF:EnableTrial() end)
  f.Trial:SetPoint("TOPRIGHT",f,"TOPRIGHT",-24,-156)
  for column, group in ipairs(self.Groups) do
    local x = 24+(column-1)*334
    label(f,group.title,"GameFontNormal",x,185,318,20,"gold")
    for index, item in ipairs(group.items) do
      local name = item[1]
      local row = choice(f,item[2],item[3],318)
      self.Rows[name] = row
      row:SetPoint("TOPLEFT",f,"TOPLEFT",x,-212-(index-1)*56)
      row:SetScript("OnClick",function(b) CF:SetModuleEnabled(name,b:GetChecked()) end)
    end
  end
  f.Gallery = button(f,"View textures",144,function() CF.Diagnostics:Gallery() end)
  f.Report = button(f,"Open report",144,function() CF.Diagnostics:Report() end)
  f.Retry = button(f,"Retry changes",144,function() CF:RetryModules() end)
  for index,b in ipairs({f.Gallery,f.Report,f.Retry}) do
    b:SetPoint("TOPLEFT",f,"TOPLEFT",24+(index-1)*158,-804)
  end
  label(f,"Saved automatically. Alpha: in-game checks are still needed.",nil,24,846,560,16,"muted")
  label(f,CF.Version,nil,575,846,101,16,"muted"):SetJustifyH("RIGHT")
  if type(UISpecialFrames) == "table" then UISpecialFrames[#UISpecialFrames+1] = "ClassicForeverUIOptions" end
  f:SetScript("OnShow",function() self:Fit(); CF:RefreshOptions() end)
  f:SetScript("OnEvent",function() self:Fit() end)
  pcall(f.RegisterEvent,f,"DISPLAY_SIZE_CHANGED")
  pcall(f.RegisterEvent,f,"UI_SCALE_CHANGED")
end

function O:Show()
  if not CF.DB then CF:Print("Settings are available after login."); return end
  local ok, err = pcall(function()
    if not self.Frame then self:Build() end
    self:Fit(); self:Refresh(); self.Frame:Show()
  end)
  if not ok then
    self.LastError = CF.API.SafeText(err)
    if self.Frame then self.Frame:Hide() end
    CF:Print("Settings could not open. /cf help still works; /cf report has the error.")
  end
end

function O:TryRegister()
  if self.Category or self.RegistrationFailed or CF.API.IsInCombatLockdown() then return end
  if not Settings or type(Settings.RegisterCanvasLayoutCategory) ~= "function" or
      type(Settings.RegisterAddOnCategory) ~= "function" then return end
  local ok, err = pcall(function()
    local panel = CreateFrame("Frame",nil,UIParent)
    self.Launcher = panel
    panel:Hide()
    label(panel,"ClassicForeverUI","GameFontNormalLarge",16,16,500,30,"gold")
    label(panel,"Choose your Classic UI features. Changes save automatically.",nil,16,60,560,24,"muted")
    panel.Open = button(panel,"Open settings",160,function() self:Show() end)
    panel.Open:SetPoint("TOPLEFT",panel,"TOPLEFT",16,-104)
    local category = Settings.RegisterCanvasLayoutCategory(panel,"ClassicForeverUI")
    Settings.RegisterAddOnCategory(category)
    self.Category = category
  end)
  if not ok then self.RegistrationFailed = true; self.LastError = CF.API.SafeText(err) end
end
