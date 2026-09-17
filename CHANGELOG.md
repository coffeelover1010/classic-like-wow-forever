# Changelog

## 0.3.0-alpha — 17 September 2026

- Added a separate SpellBook module with original Classic parchment, metal trim, book icon and spell-slot borders.
- Kept native small/large views, search, categories, paging, spell dragging and pet controls. Talents and specialization remain unchanged.
- Added spellbook load-on-demand handling, pooled-button refresh, combat deferral and reversible module controls.
- Extracted and inspected seven more Classic spellbook textures from both local builds. No artwork is bundled.
- Passed 22 offline Lua 5.1 regression cases, including seven spellbook cases. All 29 addon Lua files load in the mock.
- Added spellbook steps to the beta checklist. In-game rendering, interaction and Forever compatibility remain unverified.

## 0.2.0-alpha — 17 September 2026

- Implemented original Classic stone bar, gryphons, action-slot borders, player/target skins and minimap ring.
- Added native XP/reputation styling, micro menu/bag placement and original cast border.
- Preserved native protected buttons, unit interactions, bar paging and casting logic.
- Added rollback, combat deferral, Edit Mode suspension, module controls, copyable reports and a paged asset gallery.
- Replaced fabricated READY/OK statuses with measured, explicitly unverified states.
- Fixed nil/unknown project detection and the mainbar/minimap asset catalogue.
- Extracted 21 original textures from each of two local Classic builds for private inspection. Corrected the gryphon to EndCap-Dwarf; EndCap-Human is a lion.
- Added Lua 5.1 regression tests and allowlisted, correctly named install packaging.
- No bundled art and no in-game verification yet. Retail development target; Forever remains unverified.

## 0.1.0-dev

- Established the compatibility scaffold, diagnostics and source comparison tools.
- Recorded a pinned Retail/Classic source scan.
