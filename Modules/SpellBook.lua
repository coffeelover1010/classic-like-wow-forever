local _, CF = ...
local M = { Slots = {} }
local artKeys = {"TopBar", "BookBGHalved", "BookBGLeft", "BookBGRight", "BookCornerFlipbook", "Bookmark"}
local requiredArt = {"CLASSIC_BOOK_ICON", "CLASSIC_BOOK_HEADER", "CLASSIC_BOOK_PAPER",
  "CLASSIC_BOOK_TL", "CLASSIC_BOOK_TR", "CLASSIC_BOOK_BL", "CLASSIC_BOOK_BR",
  "CLASSIC_BOOK_TOP", "CLASSIC_BOOK_BOTTOM", "CLASSIC_BOOK_LEFT", "CLASSIC_BOOK_RIGHT", "CLASSIC_QUICKSLOT"}

function M:Initialize()
  local book = CF.Compat:Path(_G.PlayerSpellsFrame, "SpellBookFrame")
  if not book then return false, "Open the spellbook to load Blizzard_PlayerSpells" end
  if not book.PagedSpellsFrame or type(book.ForEachDisplayedSpell) ~= "function" or
      not book.TopBar or not book.BookBGLeft or not book.BookBGRight or not book.BookBGHalved then
    return false, "Retail spellbook structure missing; native book retained"
  end
  if not EventRegistry or type(EventRegistry.RegisterCallback) ~= "function" then
    return false, "Spellbook display callbacks unavailable; native book retained"
  end
  if self.Book and self.Book ~= book then return false, "Spellbook frame replaced; reload required" end
  self.Book = book
  return CF.Assets:Require(requiredArt)
end

local function texture(parent, id, p1, x1, y1, p2, x2, y2)
  local t = parent:CreateTexture(nil, "BACKGROUND")
  if not CF.Assets:Apply(t, id) then error("Asset load rejected: " .. id) end
  t:SetPoint("TOPLEFT", parent, p1, x1, y1)
  t:SetPoint("BOTTOMRIGHT", parent, p2, x2, y2)
  return t
end

function M:Build()
  -- All new regions are passive children of the spellbook tab. The shared
  -- PlayerSpellsFrame, talent panes, native hit targets and CVars stay untouched.
  local skin = CreateFrame("Frame", nil, self.Book)
  self.Skin = skin
  skin:Hide()
  skin:EnableMouse(false)
  skin:SetAllPoints(self.Book)
  skin:SetFrameLevel(self.Book:GetFrameLevel())
  texture(skin, "CLASSIC_BOOK_HEADER", "TOPLEFT", 0,0, "TOPRIGHT", 0,-51)
  CF.Visuals:Texture(skin, "CLASSIC_BOOK_ICON", "ARTWORK", 36,36, "TOPLEFT",skin,"TOPLEFT",18,-7)
  local body = CreateFrame("Frame", nil, skin)
  self.Body = body
  body:EnableMouse(false)
  body:SetFrameLevel(self.Book:GetFrameLevel())
  body:SetPoint("TOPLEFT", skin, "TOPLEFT", 0,-51)
  body:SetPoint("BOTTOMRIGHT", skin, "BOTTOMRIGHT", 0,0)
  -- Fixed-size corners retain the original trim; anchors follow both native
  -- widths without changing Blizzard's layout or installing resize hooks.
  texture(body, "CLASSIC_BOOK_PAPER", "TOPLEFT",32,-32, "BOTTOMRIGHT",-32,32)
  texture(body, "CLASSIC_BOOK_TL", "TOPLEFT",0,0, "TOPLEFT",32,-32)
  texture(body, "CLASSIC_BOOK_TR", "TOPRIGHT",-32,0, "TOPRIGHT",0,-32)
  texture(body, "CLASSIC_BOOK_BL", "BOTTOMLEFT",0,32, "BOTTOMLEFT",32,0)
  texture(body, "CLASSIC_BOOK_BR", "BOTTOMRIGHT",-32,32, "BOTTOMRIGHT",0,0)
  texture(body, "CLASSIC_BOOK_TOP", "TOPLEFT",32,0, "TOPRIGHT",-32,-32)
  texture(body, "CLASSIC_BOOK_BOTTOM", "BOTTOMLEFT",32,32, "BOTTOMRIGHT",-32,0)
  texture(body, "CLASSIC_BOOK_LEFT", "TOPLEFT",0,-32, "BOTTOMLEFT",32,32)
  texture(body, "CLASSIC_BOOK_RIGHT", "TOPRIGHT",-32,-32, "BOTTOMRIGHT",0,32)
  self.Built = true
end

function M:RefreshSlots()
  self.Book:ForEachDisplayedSpell(function(item)
    local button = item.Button
    if not button then return end
    local border = self.Slots[button]
    if not border then
      -- Below the icon and native state overlays: cooldowns, passive shapes,
      -- unlearned markers, glyphs and pet autocast still belong to Blizzard.
      border = button:CreateTexture(nil, "ARTWORK", nil, -2)
      self.Slots[button] = border
      border:Hide()
      border:SetSize(64,64)
      border:SetPoint("CENTER", button, "CENTER", 0,0)
    end
    if not CF.Assets:Apply(border, "CLASSIC_QUICKSLOT") then error("Spell slot artwork rejected") end
    border:Show()
  end)
end

function M:OnDisplayedSpellsChanged()
  if not self.Active or self.Faulted then return end
  if CF.API.IsInCombatLockdown() then CF.Pending = true; CF:RefreshOptions(); return end
  local ok = CF:Call(self, "RefreshSlots")
  if not ok then
    self.Faulted = true
    CF:StopModule(self)
    if self.State ~= "RESTORE_FAILED_RELOAD_REQUIRED" then self.State = "UPDATE_FAILED" end
    CF:Print("SpellBook stopped after an update error. /cf report; /cf refresh to retry.")
    CF:RefreshOptions()
  end
end

function M:Enable()
  if not self.Built then
    -- A failed build is hidden by Disable; discard its passive frame on retry.
    self:Build()
  end
  if not self.CallbacksRegistered then
    EventRegistry:RegisterCallback("PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged", self.OnDisplayedSpellsChanged, self)
    EventRegistry:RegisterCallback("PlayerSpellsFrame.SpellBookFrame.Show", self.OnDisplayedSpellsChanged, self)
    self.CallbacksRegistered = true
  end
  for _,key in ipairs(artKeys) do self.Journal:Alpha(self.Book[key], 0) end
  self:RefreshSlots()
  self.Skin:Show()
  return true, "Original parchment, metal trim, book icon and slot borders; native search, paging, pet spells and spell interactions retained"
end

function M:Disable()
  if self.Skin then self.Skin:Hide() end
  for _,border in pairs(self.Slots) do border:Hide() end
end
function M:Refresh() self:OnDisplayedSpellsChanged() end
CF:RegisterModule("SpellBook", M)
