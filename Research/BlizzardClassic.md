# Blizzard Classic UI research

Primary reference: [Gethe wow-ui-source, `classic` branch](https://github.com/Gethe/wow-ui-source/tree/classic). The initial pinned scan used revision `ecadf9d3326fa87828cacca7f13c0ab5f41840a6`.

Verified module entry points from that revision:

- `Blizzard_ActionBar/Blizzard_ActionBar_Classic.toc` loads shared action-button, bar, multi-bar, XP, reputation, vehicle, possess, pet-action, stance, and status-tracking files plus `Classic/MainMenuBar.lua` and `.xml`.
- `Blizzard_UnitFrame/Blizzard_UnitFrame_Classic.toc` loads shared and Classic PlayerFrame, TargetFrame, PetFrame, PartyFrame, unit-frame, compact group, and status-bar resources. It has conditional game-family files; `Vanilla/TargetFrameOverrides.lua` is explicitly vanilla-only.
- `Blizzard_Minimap/Blizzard_Minimap_Classic.toc` is the minimap entry point.

The scanner found 12,932 potential global/C-namespace calls, 963 registered-event candidates, 6,412 frame-name candidates, 1,708 texture candidates, and 1,212 atlas candidates. These broad counts are inventory signals, not a confirmed API contract.

Source-provenance rule: each implemented feature must name its Lua/XML/TOC source, frames/templates, events/APIs, texture/atlas/font candidates, and secure-frame constraints in a committed research update.
