# WoW Forever unknowns and Day One checklist

No Forever API or client behaviour is assumed. Validate: project ID, interface/build number, addon-folder and TOC rules, Lua/XML support, API lineage, secure/combat restrictions, client texture/atlas availability, Blizzard frame names and UI implementation, SavedVariables, addon manager, addon communication, and slash commands.

## Day One checklist (under one hour)

1. Install ClassicForeverUI and launch Forever.
2. Record game version, build, interface, and `WOW_PROJECT_ID` from `/cf environment`.
3. Run `/cf diagnostic`, `/cf assets`, `/cf api`, and `/cf frames`; save chat output.
4. Check addon loading, TOC parsing, Lua/XML support, and SavedVariables.
5. Obtain an authorized Forever UI-source snapshot if available.
6. Run `scan_lua_api_usage.py` on Forever, Retail, and Classic sources.
7. Run `compare_ui_sources.py` for Forever-v-Retail and Forever-v-Classic.
8. Generate `Research/CompatibilityMatrix.md`.
9. Add official environment detection only after a stable identifier is known.
10. Add verified asset aliases and API shims; update the TOC if required.
11. Test ActionBars, PlayerFrame, TargetFrame, and Minimap in that order.
12. Validate protected-frame and combat behaviour before any layout mutation.
13. Package an alpha only after diagnostics and core-frame tests pass.
