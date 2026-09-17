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

- Buffs, Debuffs, Tooltips and QuestTracker now report APPLIED_UNVERIFIED only when their native hierarchy and artwork are available. Missing parts leave that module unavailable; FocusFrame and Panels remain NOT_IMPLEMENTED.
- Native health indicators remain owned by Blizzard. Their presence in the mock is not proof of correct rendering or secure behavior.
