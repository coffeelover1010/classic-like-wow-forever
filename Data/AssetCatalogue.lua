local _, CF = ...
-- Original Blizzard art. Local extraction proves Era storage availability only.
-- No modern-art substitutions. See Research/LocalClientInspection.md.
local function art(path, usage, coords, width, height)
  return { path = "Interface\\" .. path, source = "Blizzard Classic",
    usage = usage, coords = coords, width = width, height = height,
    classic = "EXTRACTED_1.15.9.69722", retail = "RENDER_UNVERIFIED",
    forever = "FOREVER_VALIDATION_REQUIRED", fallback = nil }
end
CF.AssetCatalogue = {
  CLASSIC_TOOLTIP_BACKGROUND = art("Tooltips\\UI-Tooltip-Background", "Classic tooltip background", nil,64,64),
  CLASSIC_TOOLTIP_BORDER = art("Tooltips\\UI-Tooltip-Border", "Classic tooltip edge sheet", nil,128,16),
  CLASSIC_MAINBAR_LEFT = art("MainMenuBar\\UI-MainMenuBar-Dwarf", "stone left quarter", {0,1,0.83203125,1},256,43),
  CLASSIC_MAINBAR_MIDDLE_LEFT = art("MainMenuBar\\UI-MainMenuBar-Dwarf", "stone second quarter", {0,1,0.58203125,0.75},256,43),
  CLASSIC_MAINBAR_MIDDLE_RIGHT = art("MainMenuBar\\UI-MainMenuBar-Dwarf", "micro menu background", {0,1,0.33203125,0.5},256,43),
  CLASSIC_MAINBAR_RIGHT = art("MainMenuBar\\UI-MainMenuBar-Dwarf", "bags quarter", {0,1,0.08203125,0.25},256,43),
  CLASSIC_KEYRING = art("MainMenuBar\\UI-MainMenuBar-KeyRing", "optional original keyring sheet", nil,256,128),
  CLASSIC_MAXLEVEL = art("MainMenuBar\\UI-MainMenuBar-MaxLevel", "thin metal trim", {0,1,0,0.21875},256,7),
  -- Dwarf is the gryphon; Human is a lion. Both were decoded and inspected.
  CLASSIC_GRYPHON_LEFT = art("MainMenuBar\\UI-MainMenuBar-EndCap-Dwarf", "original left gryphon", nil,128,128),
  CLASSIC_GRYPHON_RIGHT = art("MainMenuBar\\UI-MainMenuBar-EndCap-Dwarf", "mirrored right gryphon", {1,0,0,1},128,128),
  CLASSIC_PLAYERFRAME_BORDER = art("TargetingFrame\\UI-TargetingFrame", "mirrored player frame", {1,0,0,1},256,128),
  CLASSIC_TARGETFRAME_BORDER = art("TargetingFrame\\UI-TargetingFrame", "normal target frame", nil,256,128),
  CLASSIC_TARGET_ELITE = art("TargetingFrame\\UI-TargetingFrame-Elite", "elite target", nil,256,128),
  CLASSIC_TARGET_RARE = art("TargetingFrame\\UI-TargetingFrame-Rare", "rare target", nil,256,128),
  CLASSIC_TARGET_RARE_ELITE = art("TargetingFrame\\UI-TargetingFrame-Rare-Elite", "rare elite target", nil,256,128),
  CLASSIC_MINIMAP_BORDER = art("Minimap\\UI-Minimap-Border", "main minimap ring", {0.25,1,0.125,0.875},192,192),
  CLASSIC_STATUSBAR = art("TargetingFrame\\UI-StatusBar", "health, power and tracking fill", nil,128,12),
  CLASSIC_CAST_BORDER = art("CastingBar\\UI-CastingBar-Border", "original casting bar border", nil,256,64),
  CLASSIC_QUICKSLOT = art("Buttons\\UI-Quickslot2", "original occupied action slot", nil,64,64),
  CLASSIC_BOOK_ICON = art("SpellBook\\Spellbook-Icon", "original spellbook icon", nil,64,64),
  CLASSIC_BOOK_HEADER = art("SpellBook\\UI-SpellbookPanel-TopLeft", "dark book header", {78/256,240/256,38/256,68/256},240,44),
  CLASSIC_BOOK_PAPER = art("SpellBook\\UI-SpellbookPanel-TopLeft", "original warm parchment", {46/256,240/256,102/256,240/256},240,180),
  CLASSIC_BOOK_TL = art("SpellBook\\UI-SpellbookPanel-TopLeft", "book top left corner", {14/256,46/256,70/256,102/256},32,32),
  CLASSIC_BOOK_TR = art("SpellBook\\UI-SpellbookPanel-TopRight", "book top right corner", {62/128,94/128,70/256,102/256},32,32),
  CLASSIC_BOOK_BL = art("SpellBook\\UI-SpellbookPanel-BotLeft", "book bottom left corner", {14/256,46/256,150/256,182/256},32,32),
  CLASSIC_BOOK_BR = art("SpellBook\\UI-SpellbookPanel-BotRight", "book bottom right corner", {62/128,94/128,150/256,182/256},32,32),
  CLASSIC_BOOK_TOP = art("SpellBook\\UI-SpellbookPanel-TopLeft", "book top edge", {46/256,240/256,70/256,102/256},240,32),
  CLASSIC_BOOK_BOTTOM = art("SpellBook\\UI-SpellbookPanel-BotLeft", "book bottom edge", {46/256,240/256,150/256,182/256},240,32),
  CLASSIC_BOOK_LEFT = art("SpellBook\\UI-SpellbookPanel-TopLeft", "book left edge", {14/256,46/256,102/256,240/256},32,180),
  CLASSIC_BOOK_RIGHT = art("SpellBook\\UI-SpellbookPanel-TopRight", "book right edge", {62/128,94/128,102/256,240/256},32,180),
}
