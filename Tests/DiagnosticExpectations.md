# Expected diagnostic behavior

- Missing/nil project IDs or missing constants never classify the client as Retail or Classic.
- IsForever=false means no reliable Forever identification has been implemented. It does not assert that the current client is not Forever.
- APPLIED_UNVERIFIED means the enable call completed. It is never a runtime certification.
- NOT_IMPLEMENTED means the native feature is left alone.
- CLIENT_NOT_ENABLED means this project ID needs an explicit session trial with /cf enable.
- UNAVAILABLE identifies a missing frame, API, asset or hierarchy.
- SpellBook can be UNAVAILABLE before its first opening loads Blizzard_PlayerSpells; ADDON_LOADED triggers a recheck. A changed hierarchy or rejected original asset leaves the native book intact.
- ERROR means a module call failed; the partial layout is rolled back.
- UPDATE_FAILED stops event retries and restores the default module outside combat.
- RESTORE_FAILED_RELOAD_REQUIRED needs an addon disable/reload.
- A missing InCombatLockdown API queues all geometry changes.
- LOAD_ACCEPTED_VISUAL_UNVERIFIED means SetTexture returned true.
- REQUESTED_VISUAL_UNVERIFIED means no boolean success was returned.
- LOAD_REJECTED means an error or false was returned.
- A registered event may never be delivered in a different client. The report must not call registration proof of behavior.
- /cf report contains no unit names, health values or account data. It saves only its latest report to the addon's SavedVariables.
- No asset automatically becomes visually verified. Check all gallery pages in the client.
- Settings checkboxes show saved choices, while labels show applied, queued, paused or unavailable state. No label is a compatibility certificate.
- Missing Blizzard Settings registration does not disable `/cf`. A caught settings error is included in the report without blocking layout restoration.

Offline runner: python Tests/run_tests.py (requires lupa with Lua 5.1).
Actual client procedure: BETA-TEST.md.

- Buffs, Debuffs, Tooltips and QuestTracker now report APPLIED_UNVERIFIED only when their native hierarchy and artwork are available. Missing parts leave that module unavailable; Panels remains NOT_IMPLEMENTED.
- Native health indicators remain owned by Blizzard. Their presence in the mock is not proof of correct rendering or secure behavior.

- FocusFrame applies only to the full-size pinned Retail hierarchy. CompactFocus is a separate passive-trim module; mode changes queue rediscovery. PetFrame, TargetOfTarget and FocusTarget report APPLIED_UNVERIFIED for passive trim only. Missing or changed small-frame structures report UNAVAILABLE.
# 0.8 character diagnostics

- CharacterWindow is independent of deferred Panels. Missing roots, inset ownership,
  artwork or secure hooks produce UNAVAILABLE without changing the native window.
- A supported hierarchy reports APPLIED_UNVERIFIED and its supported slot count
  out of eighteen. Changed or missing slots remain native. A custom/restricted
  background reports that native artwork is retained, even if the module is active.
- Applying artwork is not proof of rendered pixels. Four new character-sheet
  paths have Era 1.15.9.69722 extraction evidence only. Retail and Forever remain
  unverified. Buttons retain their native original art; no new button extraction
  or renderer is claimed.
- Character remains an independent settings choice. Combat changes queue;
  Edit Mode suspends; creation/update failures hide partial art independently.
- No equipment, stat, model, health or prediction values are read by this module.

# 0.7 dialogue diagnostics

QuestDialogue and GossipDialogue are independent implemented modules. Missing
standard window/inset structure or hooksecurefunc produces UNAVAILABLE before
native changes. APPLIED_UNVERIFIED does not certify client rendering or clicks.
The Detail text describes the limited standard-window scope. Panels remains
NOT_IMPLEMENTED. Custom dialogue, map/popups and spell rewards stay native.
Contrast/themed backgrounds may show native art while the module is applied.
Native red buttons are retained because the pinned source already uses original
paths. Four new quest sheet entries have Era extraction evidence only.

## 0.9 window diagnostics

BagWindows, BankWindow and MerchantWindow are independent of Bags (button placement)
and deferred Panels. Missing structures/hooks/art report UNAVAILABLE. Successful
application reports APPLIED_UNVERIFIED, with supported border counts up to 7/1/3.
A changed or opaque border theme reports zero supported borders and retains native art.
Reports do not certify item interactions, pixels, taint or Forever compatibility.

## 0.10 scoped feature diagnostics

- There are 38 saved feature choices on two settings pages. ChatStyle defaults
  off only when no saved choice exists. Panels remains NOT_IMPLEMENTED.
- MailWindow, TradeWindow, InspectWindow, TrainerWindow and LootWindow report
  supported border counts, up to 3/6/1/2/1. Loot cards remain native.
- TargetCastBar, FocusCastBar, BagArtwork, MinimapDetails, CharacterPages,
  CompactFocus, ItemSlots and ChatStyle report supported cosmetic piece counts.
  Counts can change as native windows load and pools grow or release items.
- MicroArtwork reports up to two quest/talent buttons. Native atlas changes win
  over applied art and rollback. Highlights, alerts and newer buttons stay native.
- Changed parents, missing parts, secret states, tinted/unknown guarded artwork
  or unavailable APIs retain native art. Zero supported pieces is not a visual
  certification. Guarded alpha/tint changes hide addon art before a safe refresh.
- Narrow wake events retry unavailable structures through the normal apply
  path; disabled or faulted modules stay off. Pool hooks never call transaction APIs.
- Every new feature shares combat queues, Edit Mode suspension and rollback.
  Offline tests cannot certify protected-frame behavior, taint or event delivery.
