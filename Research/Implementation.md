# Implementation and source evidence: 0.8 alpha

## 0.8 character equipment page

Both pinned source HEADs below were rechecked. Retail source is under
Blizzard_UIPanels_Game/Mainline, not Blizzard_CharacterFrame/Mainline.
CharacterFrame.xml defines Background (character-panel-background), Inset from
ButtonFrameTemplate, InsetRight and CharacterStatsPane. PaperDollFrame.xml defines
PaperDollFrame under CharacterFrame and PaperDollItemsFrame directly under it.
The eighteen named item slots inherit the intrinsic ItemButton from
Blizzard_ItemButton/Shared/ItemButtonTemplate.xml: its icon key is lowercase
`icon`, its icon is BORDER, counts are ARTWORK and quality/context overlays are
OVERLAY. Slot cooldowns, popoutButton and SocketDisplay are separate children.

CharacterWindow only creates passive textures. It overwrites no native character
property, scripts, secure attributes, parents, hit rectangles or item values.
Background and inset overlays belong to PaperDollFrame and follow its visibility;
slot edges belong to each validated item button at ARTWORK sublevel -2, outside
the icon. The native Quickslot normal/pushed/highlight states and existing
Char-Paperdoll-Parts slot artwork stay in charge. Insets use existing anchors,
so native expand/collapse and other-page geometry remain Blizzard-owned.

Only the known character-panel-background atlas is covered. Secure post-hooks
on its SetAtlas/SetTexture/Show/Hide hide addon art immediately when it changes;
all creation/refresh still uses combat deferral and isolated error handling.
Unknown or restricted backgrounds get no overlays. No character accessibility
setting or CVar is changed. Missing roots fail closed; changed slots are skipped
and the detail reports the supported count. A changed hierarchy needs a fresh
source review; it is not automatically classified as supported.

CharacterFrame.lua defines ShowSubFrame and dynamic width/Inset placement.
The character overlays disappear with PaperDollFrame when reputation/currency
pages open. The outer portrait frame, class/stat background, model scene and
its race/background overlays, stats, titles, equipment sets/outfits, sockets,
flyouts, tab state and buttons are untouched. PaperDollFrame.xml's EquipSet and
SaveSet inherit UIPanelButtonTemplate. SecureUIPanelTemplates.xml/.lua retains
original UI-Panel-Button-Up/Down/Disabled art. Those button paths are source
evidence, not newly extracted evidence. No new button renderer is claimed.

Classic Blizzard_CharacterFrame/Vanilla/PaperDollFrame.xml references the four
UI-Character-CharacterTab sheets. All four were extracted from Era 1.15.9.69722,
decoded and inspected outside the repository. Catalogue crops use their dark
paper and metal inset edges. Anniversary was not extracted for this pass.
The ZIP includes only client paths, never extracted artwork or research tools.

Thirteen new regressions bring the suite to 77 cases and 36 TOC Lua files.
They cover native state preservation, page visibility, anchors and reuse, theme
changes during combat, missing/changed structures, late load, settings, Edit Mode,
partial creation/hooks, deferred failure, stale callbacks, missing art/APIs and
opaque atlas values. Twenty settings choices fit ten per column at 700x870.
The settings tree preview and character crop composition were inspected; the
latter omits native controls/model and uses approximate inset geometry. Neither
is a game screenshot. No running client is tested; Forever remains unverified.

## 0.7 standard quest and gossip pass

The pinned Retail and Classic revisions below were verified locally. Retail
Blizzard_UIPanels_Game/Mainline/QuestFrame.xml and QuestFrameTemplates.xml define
QuestFrame's four panels, Bg regions, separate BORDER material layers, buttons and
scroll frames. GossipFrame.xml defines Background, GreetingPanel.ScrollBox,
ScrollBar and GoodbyeButton. Mainline/SharedUIPanelTemplates.xml and
Mainline/NineSliceLayouts.lua under Blizzard_SharedXML define Inset.NineSlice and
its eight regions. We require that structure and parent ownership before writes.

QuestDialogue and GossipDialogue are separate modules. Their passive textures
cover only ordinary QuestBG-Parchment; native backgrounds are never changed.
Secure post-hooks on each background's SetAtlas/SetTexture/Hide/Show immediately
hide the added paper and queue a next-frame refresh. Hooks remain installed but
are inert while disabled; registration is tracked per method, including retries
after partial failure. Hiding addon-owned paper in combat reveals the latest native
background without a native write. Creation, native inset alpha changes, restoration
and other updates still defer in combat. No native script or method is replaced.

Blizzard_AccessibilityTemplates/QuestTextContrast.lua lists ordinary parchment and
four contrast atlases. Unknown, themed and accessibility atlases receive no added
paper. QuestFrame_SetMaterial keeps special materials on BORDER above the added
BACKGROUND paper. Native text and colors, friendship UI, scrolling and selection
remain unchanged. Texture alpha is journaled only for the eight inset border
regions; their textures, theme state and anchors remain native. The outer portrait
border, title bar and close control remain unchanged.

QuestInfo.lua creates reusable RewardButtons on QuestInfoRewardsFrame; QuestInfo.xml
uses LargeQuestRewardItemButtonTemplate. Blizzard_ItemButton/Mainline/ItemButtonTemplate.xml
places Icon on BACKGROUND and quality/count/overlay art on OVERLAY. Added ARTWORK
slot borders anchor to Icon and remain below those native state overlays. Deferred
quest-event refresh discovers late buttons after native handlers finish. The map
reward frame, spell pools and custom reward layouts are excluded. Changed/missing
reward button structures are skipped. No quest values, IDs or reward APIs are read.

Retail Blizzard_SharedXML/SecureUIPanelTemplates.xml and .lua already use
UI-Panel-Button-Up/Down/Disabled with original cropped Left/Middle/Right textures
and native state scripts. Those buttons are deliberately retained, not presented
as a new button renderer. This is source evidence, not extraction evidence for
those button paths. Native fonts, hit rectangles and enabled states are untouched.

Classic Blizzard_UIPanels_Game/Vanilla/QuestFrameTemplates.xml references the four
UI-QuestGreeting sheets. All four were freshly extracted from local Era
1.15.9.69722, decoded and inspected. The catalogue crops their parchment and inset
metal edges. Their new entries truthfully use EXTRACTED_1.15.9.69722; no new
Anniversary extraction is claimed. Original UI-Quickslot2 supplies reward trim.

The 0.7 suite has 64 Lua 5.1 regression cases and 35 TOC Lua files. Twelve added
cases cover controls/rollback, themed and contrast transitions during combat,
late rewards, reuse, absent hierarchy, late discovery, Edit Mode/settings,
partial application, partial hook registration, update faults, missing art/APIs,
ownership changes and stale queued callbacks. The 700x870 settings preview has
nineteen rows across two columns and no measured text overflow. The artwork crop
composition uses catalogue coordinates and approximate inset geometry, not native
atlas dimensions. Both previews were inspected; neither is an in-game screenshot.

CustomGossipFrameBase, quest map/popups, spell-reward pools and bag
windows remain unsupported. Character support was added in 0.8 as described above. The generic Panels module stays deferred. Actual
client rendering, secure hook/taint behavior, reward event coverage and all
accessibility settings still need the beta checklist. Forever remains unverified.

All addon implementation is independently authored. No ClassicUI, Classic Frames, KeyUI or DragonflightUI code was copied.

## Source baseline

Retail: [Gethe source 4e3cbb8](https://github.com/Gethe/wow-ui-source/tree/4e3cbb8c5609e4bfc332c0aebbfa4d79731fab59/Interface/AddOns).
Classic: [Gethe source ecadf9d](https://github.com/Gethe/wow-ui-source/tree/ecadf9d3326fa87828cacca7f13c0ab5f41840a6/Interface/AddOns).

Paths below are under Interface/AddOns in those snapshots.

| Area | Source files checked | Our adaptation |
|---|---|---|
| Action bars | Blizzard_ActionBar/Shared/ActionBar.lua; Mainline/MainActionBar.xml; Blizzard_ActionBarController/ActionBarController.lua | Move and size existing ActionButton1-12 outside combat; preserve their native containers, action IDs, scripts, paging and state controller |
| Original bar artwork | Classic Blizzard_ActionBar/Classic/MainMenuBar.xml | Independently lay out the four original sheet crops and mirror EndCap-Dwarf on the right |
| Player | Blizzard_UnitFrame/Mainline/PlayerFrame.xml | Passive skin on native button; alpha-mask main artwork and power only; preserve the full native health subtree |
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

Modules initialize in TOC registration order. Initialization, enable, update and disable calls are isolated with pcall. A partially failed enable rolls back captured properties and hides new art. Each mutation records the original points, dimensions, scale, frame level, alpha or texture only once per application.

All native layout writes and restoration wait until InCombatLockdown returns false. If that API is missing, the addon performs no layout writes. An update failure stops that module's event processing, reports an error, and restores the default skin after combat. Other modules continue. Use /cf refresh for an explicit retry. Reload is the recovery if a client rejects rollback.

The addon never overwrites a native script or method, never reparents a native frame, never writes a secure action/unit attribute, and never edits saved Edit Mode layouts or keybindings. Its passive child art inherits native visibility, including the main bar's vehicle/override transitions.

## Secret values

Power, maximum power and names go directly into Blizzard's documented display methods. Health and prediction values stay entirely with the native health engine. No health/power values are compared, formatted, cached or used in Lua arithmetic. Restricted level and classification values fall back to an empty level and normal original border. Restricted power tokens use a fixed blue fill. The current native unit token is used for vehicle display when readable.

This is a design based on the pinned Retail API documentation, not proof of beta behavior. The mock's opaque sentinel values test accidental arithmetic/string conversion but cannot emulate every engine restriction.

## Independent and limited modules

Nineteen modules have implementations. Panels explicitly reports NOT_IMPLEMENTED and leave native UI intact. Panels refers to other windows; SpellBook, QuestDialogue and GossipDialogue are separate.

The unit skin keeps the entire native HealthBarsContainer visible, moves it as one unit and raises its frame level above the passive border. Its native HealthBar remains at the container level so native OVERLAY health text stays above the BACKGROUND fill. Dimensions, masks, prediction segments, losses, text, scripts and values remain native. A journal restores its points and frame levels. There is no duplicate health fill or health API read in the skin. Native health retains its full modern height; the custom power display moves down to clear it. Portrait combat flash is still omitted. Class-specific resources, target auras, target cast bars and the focus-target frame remain native and need layout checks on multiple classes.

XP/reputation remain modern native tracking bars with original fills and trim; this is not a rebuilt 1024-pixel Vanilla XP system. Micro and bag buttons keep Retail art. The minimap header and utility buttons remain native. Cast effects and empower markers also remain native.

The spellbook keeps Retail's native spell grid, spell-state artwork, category tabs, search, settings and paging. It does not recreate Vanilla's twelve-spell layout. Its passive backdrop inherits the spellbook tab's visibility and width, so it cannot cover the talents or specialization pane. Six native background regions have their alpha journaled; their native textures, animation, show/hide state and size remain unchanged. This preserves the current minimized state when disabled.

The core's Blizzard ADDON_LOADED handling activates the module after Blizzard_PlayerSpells loads. The source-defined PlayerSpellsFrame.SpellBookFrame.Show and PlayerSpellsFrame.SpellBookFrame.DisplayedSpellsChanged callbacks refresh borders for displayed pooled entries via ForEachDisplayedSpell. Registration happens once and callbacks are gated by module state. There are no method or script replacements. Border textures sit below icons and native state overlays. In combat, new borders defer to the existing post-combat apply path. Callback errors stop and restore only this module until an explicit retry.

## Settings

Core/Options.lua presents only the nineteen implemented features. The whole row is a check button. The main switch, feature rows, session trial and retry button call the same controllers as slash commands. These update the existing SavedVariables table without replacing unrelated report data, then use RequestApply and its existing combat/Edit Mode rules. Opening the window does not enable the addon or opt into an unknown client trial.

Apply completion, queued requests and runtime faults refresh visible controls directly; there is no per-frame polling. Checkbox state shows saved intent, while the status label shows application state. Disabling the main switch preserves the selected features. The window uses addon-owned geometry only, supports dragging and UISpecialFrames/Escape, and shrinks to fit UIParent. Both missing Settings APIs and failed optional category registration leave the standalone `/cf` window usable. UI errors are isolated from layout restoration and included in `/cf report`.

Settings registration happens outside combat after application, so a Blizzard addon loaded later can provide the APIs. There is one registration per session. No Ace3 or other runtime dependency was added. Native checkbox marks are referenced by the same original path used in Blizzard's check button template.

## Test scope

Tests/run_tests.py compiles and executes all TOC Lua with Lua 5.1 via the test-only lupa runtime. It checks native-frame restoration, combat deferral, Edit Mode snapshots, module isolation, rejected assets/events, missing APIs, unknown clients, opaque values, late-loaded frames, reports and gallery creation.

The 0.6 suite has 52 cases and loads 32 Lua files. Spellbook cases cover lazy loading, untouched interaction scripts, tab visibility, both widths, restoration after native state changes, pooled-entry reuse, combat deferral, missing art, changed hierarchy and failure isolation/retry. Settings cases cover aliases, singleton lifetime, saved preferences, shared slash-command state, combat and Edit Mode, explicit trials, optional category registration, display fitting, tools and error isolation.

Tests/preview_options.py reads the actual mocked Lua frame tree to render an offline layout preview using test-only Pillow. Normal, trial and combat layouts were inspected without text-width overflow. Font metrics and checkbox marks are approximate. The previews and earlier spellbook compositions are not game screenshots or interaction tests and are excluded from install packages.

Mock behavior is deliberately labeled and cannot prove WoW's taint propagation, protected operations, rendered pixels, actual event delivery or SavedVariables persistence. The next required validation is the user's beta session in BETA-TEST.md.

## 0.5 source checks and scope

The pinned revisions above were verified locally for this pass. Source paths below are under Interface/AddOns.

- Retail Blizzard_UnitFrame/Mainline/PlayerFrame.xml and TargetFrame.xml define HealthBarsContainer.HealthBar, its heal/absorb children and mask. Player health is 124x20; target health is 126x20. Native prediction sizing and restricted-value calculations stay in Blizzard code. Raising/repositioning the intact subtree needs client checks, especially over-absorb glows, text layering, temporary maximum-health loss and vehicle changes.
- Retail Blizzard_BuffFrame/BuffFrame.lua creates auraFrames at load time. BuffFrameTemplates.xml puts Icon on BACKGROUND, duration below it and dispel/enchant/count regions on OVERLAY. Our anchored ARTWORK slot borders inherit native button visibility and scale. Private aura Icon frames are excluded. UNIT_AURA only refreshes player button identities; no aura values are inspected. New art waits for combat to end; failures use the existing isolated event wrapper.
- Classic Blizzard_BuffFrame/Classic/BuffFrame.lua uses native debuff overlays. We retain Retail's dispel and enchant art rather than replacing their state handling. UI-Quickslot2 is the original Classic action-slot border reused for this skin; this is not a claim of exact Vanilla aura artwork.
- Retail Blizzard_SharedXML/SharedTooltipTemplates.xml, SharedTooltipTemplates.lua, NineSlice.lua and Backdrop.lua define tooltip art, its embedded visibility, region names and BackdropTemplate support. Addon-owned backdrops are children of native NineSlice frames, below tooltip text. Only original region alpha is journaled; native style textures, vertex colors, scripts, owners, anchors and visibility are untouched. GameTooltip, ItemRefTooltip and available comparison tooltips are supported. Specialty/embedded tooltip content is not rebuilt. The new border is fixed gray, so native item-quality border tint is not displayed; item names and overlay decorations remain native.
- Classic Blizzard_SharedXML/Backdrop.lua references UI-Tooltip-Background and UI-Tooltip-Border. Both were extracted from local Era storage and decoded outside the repository. The install ZIP contains paths only.
- Retail Blizzard_ObjectiveTracker/Blizzard_ObjectiveTracker.xml and Blizzard_ObjectiveTrackerContainer.xml define Header.Background and separate text/minimize/filter controls. Only the top header texture and an anchored trim change. Quest rows, pooled items, progress bars, navigation and module headers retain native artwork and behavior.

The twelve additional cases cover native health ownership/rollback, absent hierarchy, aura reuse/private anchors/combat/faults, tooltip visibility and partial failure, tracker restoration, late frames and all four new settings choices. The expanded 0.5 settings preview had seven rows per column and scales to the display. Offline preview and mocks do not establish rendered pixels or engine behavior.

## 0.6 unit-frame pass

The Retail and Classic pinned revisions above were rechecked locally. Retail
Blizzard_UnitFrame/Mainline/TargetFrame.xml defines FocusFrame using the same
TargetFrameTemplate and HealthBarsContainer as target. TargetFrame.lua defines
FocusFrameMixin:SetSmallSize, CreateTargetofTarget and the native totFrame field.
The full-size focus skin reuses the target skin, including classification borders,
with PLAYER_FOCUS_CHANGED refreshing portrait and display values. Focus position
and scale are not changed. Compact or restricted smallSize is unsupported and
reports UNAVAILABLE before writes. Edit Mode exit rechecks that condition; focus
updates also request a deferred recheck if compact mode appears while active.

Retail Mainline/PetFrame.xml defines global PetFrameHealthBar and PetFrameManaBar
as direct PetFrame children, with prediction frames and masks inside health.
TargetFrame.xml defines the direct HealthBar/ManaBar children of totFrame.
Both receive only two passive BACKGROUND textures anchored just outside the bar
pair. They use the already inventoried Classic UI-MainMenuBar-MaxLevel metal trim.
No native region is hidden or mutated, and there are no unit-value reads or new
unit-update handlers in these two modules. All native bar descendants, modern
border art, portrait, flashes, name, auras, scripts, click targets, scale and
placement remain owned by Blizzard. Trim inherits unit visibility and bar width.
Classic Blizzard_UnitFrame/Classic/PetFrame.xml instead uses UI-SmallTargetingFrame;
its different geometry is not imposed on Retail's native health and power bars.
This is deliberately a limited trim skin, not a rebuilt Classic small frame.

Missing frame/bar/portrait/border structures and bars with unexpected parents
leave that module unavailable. Late frames can be retried with /cf refresh;
ADDON_LOADED also rechecks modules. New textures are retained by native frame
identity, hidden on disable or partial failure and reused on subsequent applies.
The existing lifecycle supplies combat deferral, Edit Mode suspension and isolated
failure handling. Focus-target, party, raid, boss and other panels remain unchanged.

Eight new offline cases cover focus refresh/native health/position/rollback,
compact fallback, small-frame preservation, missing hierarchy, late discovery,
settings combat deferral, Edit Mode and partial trim failure/retry. The settings
preview now has nine/eight rows, seventeen feature choices and a 700x856 window
that scales to the display. Its normal layout was inspected with approximate
fonts. No in-game result is implied by this preview or the 52 mock cases.
