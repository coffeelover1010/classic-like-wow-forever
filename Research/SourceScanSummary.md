# Initial source scan

Date: 2026-09-14

| Source | Branch | Revision | Files scanned |
|---|---|---|---|
| Gethe/wow-ui-source | classic | `ecadf9d3326fa87828cacca7f13c0ab5f41840a6` | sparse `Interface/AddOns` |
| Gethe/wow-ui-source | live | `4e3cbb8c5609e4bfc332c0aebbfa4d79731fab59` | sparse `Interface/AddOns` |

The shipped Python scanners compiled successfully with the bundled runtime and produced the compatibility counts in `CompatibilityMatrix.md`. Their output is intentionally conservative: pattern matching sees candidates, not runtime proof. Raw generated JSON/CSV is not committed; rerun the tools against a pinned checkout to reproduce it.

The next research slice is to extract per-feature manifests for action bars, Classic MainMenuBar/endcap art, and player/target/minimap XML templates, then update `Data/AssetCatalogue.lua` only with verified client availability.
