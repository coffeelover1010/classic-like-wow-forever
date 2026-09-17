# Changelog

## 0.7.0-alpha - 17 September 2026

- Added separate standard quest and NPC dialogue skins: original parchment, inset borders and quest item/currency reward-slot trim. Native buttons already use original red-button artwork and remain unchanged.
- Preserved native text, selection, scrolling, tooltips, themes, material overlays and accessibility backgrounds. Outer portrait frames, map/popups, custom dialogue and spell-reward pools remain native.
- Added two settings choices, bringing the fitted window to nineteen. Kept combat deferral, Edit Mode suspension, rollback and isolated failures.
- Freshly extracted and inspected four original quest sheets from Era 1.15.9.69722, outside the repository. No artwork is bundled.
- Passed 64 offline Lua 5.1 cases and all 35 TOC files; inspected settings and art previews. No running client tested. Forever remains unverified.

## 0.6.0-alpha — 17 September 2026

- Added a full-size focus skin with native health/predictions and native position/scale. Compact focus remains unchanged and reports unavailable.
- Added Classic metal trim outside native pet and target-of-target bars. Modern small-frame artwork and all native controls remain.
- Added three settings rows; expanded the fitted window to seventeen choices.
- Passed 52 offline Lua 5.1 cases and all 32 TOC files. Inspected the settings preview and verified the install ZIP allowlist.
- No running client tested. Forever compatibility remains unverified. Focus-target, party, raid, boss and other panels remain later work.

## 0.5.0-alpha — 17 September 2026

- Added original Classic tooltip backgrounds and gray borders, buff/debuff slot borders and quest-tracker header trim.
- Restored native player/target health, incoming healing, shields and heal-absorb indicators. Removed the duplicate health bar; kept native masks, values and full health-bar size.
- Added four simple settings rows. Only focus and other panels remain unimplemented.
- Preserved native aura timers/clicks, tooltip content and tracker controls. New changes share combat deferral, Edit Mode suspension, rollback and isolated failure handling.
- Passed 44 offline Lua 5.1 cases and all 30 TOC files. Reviewed the expanded settings preview. No running client was tested; Forever remains unverified.

## 0.4.0-alpha â€” 17 September 2026

- Added a compact settings window with a main switch, ten feature toggles and automatic saving. Open it with `/cf`, `/cf config` or `/cf options`.
- Added live status labels, combat queue feedback and buttons for textures, reports and retrying changes.
- Added a Settings > AddOns launcher when Blizzard's Settings API is available. The window also supports dragging, Escape and scaling to fit smaller screens.
- Kept non-Retail trials explicit and limited to the current session. GUI and slash commands share the same saved choices and apply path.
- Fixed a stale pending flag after a module had already recovered to the default UI outside combat.
- Passed 32 offline regression cases and loaded all 30 Lua files. Reviewed normal, trial and combat layout previews. Actual in-game rendering and interaction remain untested.

## 0.3.0-alpha â€” 17 September 2026

- Added a separate SpellBook module with original Classic parchment, metal trim, book icon and spell-slot borders.
- Kept native small/large views, search, categories, paging, spell dragging and pet controls. Talents and specialization remain unchanged.
- Added spellbook load-on-demand handling, pooled-button refresh, combat deferral and reversible module controls.
- Extracted and inspected seven more Classic spellbook textures from both local builds. No artwork is bundled.
- Passed 22 offline Lua 5.1 regression cases, including seven spellbook cases. All 29 addon Lua files load in the mock.
- Added spellbook steps to the beta checklist. In-game rendering, interaction and Forever compatibility remain unverified.

## 0.2.0-alpha â€” 17 September 2026

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
