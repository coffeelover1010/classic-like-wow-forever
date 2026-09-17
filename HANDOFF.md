# 0.10.0-alpha engineering handoff

## Baseline and release

The task began on clean `main` at `948938a05c5f02d2eeaa083e733479244f6e3a7d`, matching the remote. The original 91-case suite passed before edits. Both research checkouts were reverified:

- Retail: `4e3cbb8c5609e4bfc332c0aebbfa4d79731fab59`
- Classic: `ecadf9d3326fa87828cacca7f13c0ab5f41840a6`

Current implementation: **38 feature settings**, one deferred generic Panels module, **55 TOC Lua files**, **116 offline Lua 5.1 regression cases**, and a **60-file install ZIP**. Settings have two pages with three columns each, fitted from 1034x798. ChatStyle starts off unless the user already saved a choice.

Install artifact: `dist/ClassicForeverUI-0.10.0-alpha.zip`; checksum beside it. The install folder is `ClassicForeverUI`. `dist/` remains ignored. Rebuild with `Tools/package_addon.py`; it checks byte-for-byte payload equality, archive integrity and the TOC/document allowlist. No art or research dependencies are installed.

## Every requested area

| Requested area | Result | Details and remaining limits |
|---|---|---|
| 1. Mail, trade, inspect, trainer | Implemented within scoped inset skins | MailWindow covers shared inbox/send, send-money and opened-mail insets. TradeWindow selects six exact named insets, since the source repeats LeftInset parent keys. InspectWindow and TrainerWindow include inherited insets; trainer includes bottomInset. Stationery, rows, models and transactions remain native. |
| 2. Loot | Partially supported | LootWindow validates ScrollingFlatPanelTemplate fields and draws four outer strips. Pooled cards, quality/quest markers, clicks, animations and auto-loot are deliberately retained. |
| 3. Target/focus casts | Implemented as passive surrounds | TargetCastBar and FocusCastBar follow dynamically created spellbar children. They do not move bars, read durations/units/secret values, or hide native shields, sparks, text, flashes or empower pieces. Border changes reveal native art. |
| 4. Micro menu and bag artwork | Partially supported | MicroArtwork uses original quest and talent normal/pressed/disabled textures on two supported buttons. Native state selection, highlights and alerts remain. Newer controls and status-sensitive icons stay native. BagArtwork adds cropped slot surrounds to six buttons, retaining masks and reagent/expand behavior. |
| 5. Minimap details | Partially supported | MinimapDetails adds guarded header background/trim, a clock underline and original tracking ring. Native time, alarm, text, tracking menu, mail, calendar, addon compartment and expansion controls remain. Utility notification art is not replaced. |
| 6. Deeper windows | Partially supported | BagWindows now includes top-edge trim. MerchantWindow includes money/extra-currency insets. ItemSlots supports source-shaped bag items, active bank pool entries and merchant/buyback buttons. CharacterPages follows reputation/currency visibility and keeps pooled rows native. Color-driven bag backgrounds, curved portraits and legacy/guild banks remain deferred. |
| 7. Classic chat | Partially supported, optional | ChatStyle adds input-edge trim for ten standard windows and starts off. Native tabs, background, input art and focus states already use older assets. Text, channels, fading, docking and sending stay native. |
| 8. Unit/group investigation | Partially supported; group skins deferred | CompactFocus and FocusTarget add exterior trim. Pet and target-of-target keep their existing limited trim. Party pools/secure propagation, raid reservation flows/private auras, and boss widget/cast/aura layouts need real-client checks before replacement. No protected tree, prediction, bar, mask or layout was rebuilt. |

Fuller pet/target-of-target artwork, outer portrait replacement, party/raid/boss skins and generic Panels are not marked complete. Original small-frame/portrait sheets have different geometry from Retail's prediction and indicator trees; fitting them without hiding useful native information needs rendered evidence.

## Engineering behavior

Core/PassiveSkin.lua owns additive textures only, refreshes from exact selectors, hides old art before rediscovery, tracks textures before asset application, and follows the existing safe queue. Known atlas/alpha/tint changes hide its art immediately; creation waits for combat to end. WindowTrim honors native alpha and drops tinted/unknown borders. Neither helper overwrites native scripts, parents, secure attributes, item data or values.

MicroArtwork is the narrow exception to additive texture handling: it journals three native decorative state textures on two buttons. Rollback restores unchanged addon textures, preserves a newer native atlas, and restores partial asset/crop failures. Native state logic remains intact. It does not force artwork over later native updates; `/cf refresh` can retry supported default art.

ItemSlots post-hooks bag and bank slot generation to queue a fresh pass after native pool changes. Hidden/released items inherit native visibility; obsolete art is hidden, current textures reused, and new art waits through combat. No item, bank, merchant, loot, mail or trade action API is called.

Unavailable modules can register narrow discovery events. A wake requests the normal apply path; it cannot revive disabled or faulted modules. Blizzard ADDON_LOADED remains the general load-on-demand retry. Edit Mode suspension, main-switch rollback, independent saved choices and explicit session-only unknown-client trials remain.

## Validation and artifacts

- 116 offline regression cases (25 new), all 55 TOC Lua files compiled/executed by Lua 5.1.
- Coverage includes native state/controls, missing/changed parents, pool reuse/growth/release, secret sentinels, themes in combat, late discovery, partial crop/hook/texture faults, retry, stale callbacks, default-off persistence, settings pages and Edit Mode.
- Tests/FeatureFixtures.lua is shaped from pinned source, not a running client. All existing regressions still run.
- Both settings pages and dist/features-0.10.png crop composition were inspected. Fonts and native placeholders are approximate and labeled. Crop review corrected transparent padding in small cast and slot surrounds.
- Four new quest/talent Down/Disabled paths were read from Era 1.15.9.69722 and decoded. Existing art was re-read into local research storage. New hashes are in LocalAssetInventory.csv. No third-party implementation, generated artwork or extracted files entered the install payload.
- Tests/Validation-0.10-2026-09-17.md records final release checks. See the final task reply for commit and verified remote state.

## Required client session

**No running Retail, Classic or Forever client was tested.** Mocks and accepted texture paths do not establish rendering, event delivery, secret restrictions, taint or secure combat safety. Follow BETA-TEST.md and collect build/Interface/project ID, `/cf report`, screenshots and the first error.

Prioritize window layer overlap, cast shield/interrupt/empower visibility, item interactions and reused bank/bag rows, menu pressed/disabled states, chat drafts/focus, compact/full focus switching, accessibility/theme transitions, combat queues, Edit Mode, vehicles, reload persistence and small UI scales. Disable a feature if it hides a control or indicator.

The website's known deployment problem is separate: the reviewed workflow failed at actions/configure-pages and the public site returned 404. Website source is updated here; this task does not claim hosting was repaired.
