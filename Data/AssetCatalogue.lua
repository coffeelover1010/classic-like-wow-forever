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
}
