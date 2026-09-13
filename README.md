# ClassicForeverUI

ClassicForeverUI is a clean-room, Classic-inspired UI addon and future-client diagnostic harness. Development targets Retail/Mainline first; WoW Forever is deliberately treated as unknown until it can be inspected.

## Install and test

Copy this folder into a Retail `Interface/AddOns` directory and enable it in the AddOns panel. Use `/cf diagnostic`, `/cf environment`, `/cf assets`, `/cf api`, or `/cf frames` after login. The current modules are non-destructive probes: no protected Blizzard frame is replaced or moved yet.

## Architecture

`Core/Environment.lua` identifies known development clients without claiming a Forever project ID. `Core/API.lua` routes variable API access, `Core/Assets.lua` resolves logical asset IDs, and `Core/Diagnostics.lua` reports assumptions. Modules expose `Initialize`, `Enable`, `Disable`, `Refresh`, and `RunDiagnostics`, allowing one missing client feature to degrade independently.

The project references client-resident texture paths and atlas names only. Do not add extracted Blizzard artwork. Every proposed path in `Data/AssetCatalogue.lua` is a validation candidate until confirmed by a client/source scan.

## Research tools

```text
python Tools/scan_lua_api_usage.py <source> --output retail.json
python Tools/generate_asset_manifest.py <source> --out generated-assets
python Tools/compare_ui_sources.py <classic-source> <retail-source> --output Research/Classic-v-Retail.md
python Tools/generate_compat_report.py classic.json retail.json
```

`compare_ui_sources.py` inventories Lua, XML, and TOC files plus conservative API/event/frame/asset candidates. Review output before treating candidates as facts. Primary source starting points are Gethe's current [UI-source mirror](https://github.com/Gethe/wow-ui-source) and its branch-specific source trees.

## Adding a client flavour

Add a verified project/build rule in `Core/Environment.lua`; add only verified asset aliases to `Data/AssetCatalogue.lua`; then record differences in the manifests and `Research/CompatibilityMatrix.md`. Never infer Forever behaviour from a Retail or Classic identifier.

See `Research/ForeverUnknowns.md` for the Day One procedure and `LICENSE-NOTES.md` for asset and third-party rules.
