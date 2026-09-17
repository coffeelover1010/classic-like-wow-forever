# Implementation and source evidence: 0.4 alpha

All addon implementation is independently authored. No ClassicUI, Classic Frames, KeyUI or DragonflightUI code was copied.

## Source baseline

Retail: [Gethe source 4e3cbb8](https://github.com/Gethe/wow-ui-source/tree/4e3cbb8c5609e4bfc332c0aebbfa4d79731fab59/Interface/AddOns).
Classic: [Gethe source ecadf9d](https://github.com/Gethe/wow-ui-source/tree/ecadf9d3326fa87828cacca7f13c0ab5f41840a6/Interface/AddOns).

Paths below are under Interface/AddOns in those snapshots.

| Area | Source files checked | Our adaptation |
|---|---|---|
| Action bars | Blizzard_ActionBar/Shared/ActionBar.lua; Mainline/MainActionBar.xml; Blizzard_ActionBarController/ActionBarController.lua | Move and size existing ActionButton1-12 outside combat; preserve their native containers, action IDs, scripts, paging and state controller |
| Original bar artwork | Classic Blizzard_ActionBar/Classic/MainMenuBar.xml | Independently lay out the four original sheet crops and mirror EndCap-Dwarf on the right |
| Player | Blizzard_UnitFrame/Mainline/PlayerFrame.xml | Passive skin on native button; alpha-mask the original main art and bar regions with reversible snapshots |
| Target | Blizzard_UnitFrame/Mainline/TargetFrame.xml | Use HealthBarsContainer (not an assumed direct HealthBar); keep native target visibility, menu, auras and cast frame |
| Unit values | Blizzard_APIDocumentationGenerated/UnitDocumentation.lua; SimpleStatusBarAPIDocumentation.lua; SimpleFontStringAPIDocumentation.lua | Pass values directly to permitted SetMinMaxValues, SetValue and SetText display sinks; never calculate health percentages |
| Minimap | Blizzard_Minimap/Mainline/Minimap.xml; Classic/Minimap.xml | Replace the compass/ring visually without altering the map, mask or click scripts |
| XP/reputation | Blizzard_ActionBar/Mainline/StatusTrackingManagerOverrides.lua; StatusTrackingBarTemplate.xml; ExpBar.xml | Use existing bar containers and their Experience/Reputation entries; reskin existing fills, keep native events and values |
| Micro menu | Blizzard_MicroMenu/Mainline/MicroMenuContainer.xml | Position/scale native MicroMenuContainer; retain Retail icons and panels |
| Bags | Blizzard_MainMenuBarBagButtons/Mainline/MainMenuBarBagButtons.xml | Position/scale BagsBar; keep reagent slot and expand toggle |
| Cast bar | Blizzard_UIPanels_Game/Mainline/CastingBarFrame.xml | Add original border around native PlayerCastingBarFrame, retaining cast/channel/empower logic |
| Spellbook | Blizzard_PlayerSpells/Blizzard_PlayerSpellsFrame.xml; SpellBook/Blizzard_SpellBookFrame.xml and .lua; Blizzard_SpellBookItem.xml and .lua; Blizzard_PagedContent/Blizzard_PagingControls.xml | Passive, anchored Classic backdrop inside SpellBookFrame only; native shared parent and all spell interactions remain unchanged; native page arrows already use original spellbook paths |
| Original spellbook art | Classic Blizzard_UIPanels_Game/Vanilla/SpellBookFrame.xml | Crop the four original panel sheets into fixed corners, stretched edges and parchment; use Spellbook-Icon and UI-Quickslot2 |
| Edit Mode | Blizzard_EditMode/Shared/EditModeManager.lua | Listen to EditMode.Enter/Exit callbacks; restore before editing, snapshot and reapply after exiting |
| Asset status | Blizzard_APIDocumentationGenerated/SimpleTextureBaseAPIDocumentation.lua | SetTexture returns a success boolean on this baseline; nil on another client stays REQUESTED, not verified |
| Settings window | Blizzard_APIDocumentationGenerated/SimpleCheckboxAPIDocumentation.lua; SimpleFrameAPIDocumentation.lua; SimpleRegionAPIDocumentation.lua; Blizzard_SharedXML/Shared/Button/CheckButtonTemplates.xml | Addon-owned frames, checkboxes, font strings and color fills; native checkbox mark; no third-party configuration library |
| Settings entry and Escape | Blizzard_Settings_Shared/Blizzard_Settings.lua and Blizzard_SettingsInbound.lua; Blizzard_UIParentPanelManager/Shared/UIParentPanelManager.lua | Optional canvas category with a launcher button; standalone window name in UISpecialFrames |

Frame geometry and crops are implementation choices. This alpha does not claim pixel parity with the 2004 or 1.12 UI.

## Lifecycle and rollback

Modules initialize in TOC registration order. Initialization, enable, update and disable calls are isolated with pcall. A partially failed enable rolls back captured properties and hides new art. Each mutation records the original points, dimensions, scale, alpha or texture only once per application.

All native layout writes and restoration wait until InCombatLockdown returns false. If that API is missing, the addon performs no layout writes. An update failure stops that module's event processing, reports an error, and restores the default skin after combat. Other modules continue. Use /cf refresh for an explicit retry. Reload is the recovery if a client rejects rollback.

The addon never overwrites a native script or method, never reparents a native frame, never writes a secure action/unit attribute, and never edits saved Edit Mode layouts or keybindings. Its passive child art inherits native visibility, including the main bar's vehicle/override transitions.

## Secret values

Health, maximum health, power, maximum power and names go directly into Blizzard's documented display methods. No health/power values are compared, formatted, cached or used in Lua arithmetic. Restricted level and classification values fall back to an empty level and normal original border. Restricted power tokens use a fixed blue fill. The current native unit token is used for vehicle display when readable.

This is a design based on the pinned Retail API documentation, not proof of beta behavior. The mock's opaque sentinel values test accidental arithmetic/string conversion but cannot emulate every engine restriction.

## Independent and limited modules

Ten modules have implementations. FocusFrame, Buffs, Debuffs, Tooltips, QuestTracker and Panels explicitly report NOT_IMPLEMENTED and leave native UI intact. Panels refers to other windows; SpellBook is separate.

The unit skin suppresses the native health prediction/absorb visuals and portrait combat flash along with the main bar regions. It does not replace those advanced visuals yet. Class-specific resources, target auras, target cast bars and the target-of-target frame remain native and need layout checks on multiple classes.

XP/reputation remain modern native tracking bars with original fills and trim; this is not a rebuilt 1024-pixel Vanilla XP system. Micro and bag buttons keep Retail art. The minimap header and utility buttons remain native. Cast effects and empower markers also remain native.

The spellbook keeps Retail's native spell grid, spell-state artwork, category tabs, search, settings and paging. It does not recreate Vanilla's twelve-spell layout. Its passive backdrop inherits the spellbook tab's visibility and width, so it cannot cover the talents or specialization pane. Six native background regions have their alpha journaled; their native textures, animation, show/hide state and size remain unchanged. This preserves the current minimized state when disabled.

The core's Blizzard ADDON_LOADED handling activates the module after Blizzard_PlayerSpells loads. The source-defined PlayerSpellsFrame.SpellBookFrame.Show and PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged callbacks refresh borders for displayed pooled entries via ForEachDisplayedSpell. Registration happens once and callbacks are gated by module state. There are no method or script replacements. Border textures sit below icons and native state overlays. In combat, new borders defer to the existing post-combat apply path. Callback errors stop and restore only this module until an explicit retry.

## Settings

Core/Options.lua presents only the ten implemented features. The whole row is a check button. The main switch, feature rows, session trial and retry button call the same controllers as slash commands. These update the existing SavedVariables table without replacing unrelated report data, then use RequestApply and its existing combat/Edit Mode rules. Opening the window does not enable the addon or opt into an unknown client trial.

Apply completion, queued requests and runtime faults refresh visible controls directly; there is no per-frame polling. Checkbox state shows saved intent, while the status label shows application state. Disabling the main switch preserves the selected features. The window uses addon-owned geometry only, supports dragging and UISpecialFrames/Escape, and shrinks to fit UIParent. Both missing Settings APIs and failed optional category registration leave the standalone `/cf` window usable. UI errors are isolated from layout restoration and included in `/cf report`.

Settings registration happens outside combat after application, so a Blizzard addon loaded later can provide the APIs. There is one registration per session. No Ace3 or other runtime dependency was added. Native checkbox marks are referenced by the same original path used in Blizzard's check button template.

## Test scope

Tests/run_tests.py compiles and executes all TOC Lua with Lua 5.1 via the test-only lupa runtime. It checks native-frame restoration, combat deferral, Edit Mode snapshots, module isolation, rejected assets/events, missing APIs, unknown clients, opaque values, late-loaded frames, reports and gallery creation.

The 0.4 suite has 32 cases and loads 30 Lua files. Spellbook cases cover lazy loading, untouched interaction scripts, tab visibility, both widths, restoration after native state changes, pooled-entry reuse, combat deferral, missing art, changed hierarchy and failure isolation/retry. Settings cases cover aliases, singleton lifetime, saved preferences, shared slash-command state, combat and Edit Mode, explicit trials, optional category registration, display fitting, tools and error isolation.

Tests/preview_options.py reads the actual mocked Lua frame tree to render an offline layout preview using test-only Pillow. Normal, trial and combat layouts were inspected without text-width overflow. Font metrics and checkbox marks are approximate. The previews and earlier spellbook compositions are not game screenshots or interaction tests and are excluded from install packages.

Mock behavior is deliberately labeled and cannot prove WoW's taint propagation, protected operations, rendered pixels, actual event delivery or SavedVariables persistence. The next required validation is the user's beta session in BETA-TEST.md.
