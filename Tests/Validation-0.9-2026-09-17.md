# 0.9 offline validation — 17 September 2026

- Baseline main was clean at 032d1130c4a7e4d04d7d2dc3aee68a3b385f672a and matched origin/main after fetch.
- Rechecked pinned Retail 4e3cbb8c5609e4bfc332c0aebbfa4d79731fab59 and Classic ecadf9d3326fa87828cacca7f13c0ab5f41840a6.
- 91 Lua 5.1 regression cases passed using bundled Python and test-only lupa. All 40 TOC Lua files compiled and executed. All configured artwork paths match the local extraction inventory.
- Fourteen added cases cover native property/control preservation, untouched item-pool replacement, visibility/anchors, theme changes in combat, missing hierarchy/art/hooks, late loading, Edit Mode/settings, partial creation/hook failure, queued failures/retry, stale callbacks and replaced regions.
- Inspected three-column settings preview (1034x758; 23 choices), including trial state, and approximate window crop composition. No measured text overflow. Previews are excluded from ZIP.
- Original character-sheet crops are reused from the 0.8 Era extraction inventory. No new extraction and no original bag/bank/merchant-sheet extraction claim.
- Package builder verifies 45 files against exact source bytes and the TOC/document allowlist, archive integrity, install-root naming and no bundled art/native libraries.

Not tested: any running Retail, Classic or Forever client, actual pixels/overlap, secure hook behavior/taint, protected interactions, accessibility mode transitions, actual event coverage, native item operations or SavedVariables persistence. No game transaction or inventory action was performed. Forever compatibility remains unverified.
