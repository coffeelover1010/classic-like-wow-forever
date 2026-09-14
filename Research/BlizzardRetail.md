# Blizzard Retail/Mainline UI research

Primary reference: [Gethe wow-ui-source, `live` branch](https://github.com/Gethe/wow-ui-source/tree/live). The initial pinned scan used revision `4e3cbb8c5609e4bfc332c0aebbfa4d79731fab59`. For example, the [Blizzard UIPanels Mainline TOC](https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_UIPanels_Game/Blizzard_UIPanels_Game_Mainline.toc) lists mainline-only and shared casting-bar resources.

Verified module entry points from that revision:

- `Blizzard_ActionBar/Blizzard_ActionBar_Mainline.toc` loads shared action-button, bar, multi-bar, XP, reputation, vehicle, possess, pet-action, stance, and status-tracking resources, with Mainline overrides and templates.
- `Blizzard_UnitFrame/Blizzard_UnitFrame_Mainline.toc` loads shared/Mainline PlayerFrame, TargetFrame, party, pet, compact raid/party, class-power, and aura-container resources. Its target-aura container/button Lua files are marked for the secure environment.
- `Blizzard_Minimap/Blizzard_Minimap_Mainline.toc` is the minimap entry point.

The scanner found 15,623 potential global/C-namespace calls, 1,066 registered-event candidates, 6,176 frame-name candidates, 1,574 texture candidates, and 3,629 atlas candidates. These broad counts are inventory signals, not a confirmed API contract.

Retail is the development target only. Its APIs/assets are not evidence of WoW Forever compatibility.
