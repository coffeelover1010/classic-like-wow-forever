# 0.5.0-alpha engineering handoff

## Repository and package

The Git repository is classic-like-wow-forever. The install folder is **ClassicForeverUI**.

```text
classic-like-wow-forever/
  ClassicForeverUI.toc
  Core/             lifecycle, environment, rollback, assets, visual helpers, settings, reports
  Modules/          fourteen implemented modules; two explicit deferred modules
  Data/             asset/API/frame/event catalogues
  Research/         pinned sources, licensing, local asset inventory and implementation
  Tests/            Lua 5.1 mock regression suite and diagnostic expectations
  Tools/            source scanners, read-only asset extraction and packaging
  BETA-TEST.md       exact client test procedure
  README.md
  LICENSE / LICENSE-NOTES.md
  dist/             generated; ignored by Git
    ClassicForeverUI/
    ClassicForeverUI-0.5.0-alpha.zip
    ClassicForeverUI-0.5.0-alpha.zip.sha256
```

## Implemented

Original stone action bar, original mirrored gryphons, classic action-slot borders, player/target visual skins, original minimap border, native XP/reputation fill and trim, native micro menu/bag placement, original cast border, and original parchment/trim/icon/slot borders for the native spellbook. Classic tooltip backdrops, buff/debuff slot borders and quest-tracker header trim are also implemented. Player/target health stays native, including incoming heals, shields, masks and health text. The real action buttons, unit buttons, casting engine and tracking logic remain Blizzard-owned.

Module failures are isolated and partially applied changes roll back. Missing combat API blocks writes. Edit Mode temporarily suspends the layout. The /cf settings window has a main switch, fourteen feature toggles, saved choices and live status. It shares the slash-command apply path and includes texture, report and retry buttons. An optional Blizzard Settings > AddOns entry opens the same window. Unknown-client trials remain explicit and session-only.

## What works versus what is untested

The implemented behaviors passed 44 offline Lua 5.1 regression cases, including twelve new UI-pass cases, seven spellbook cases and ten settings cases. All 30 packaged Lua files load in the mock, and the ZIP is checked against the exact TOC/document allowlist.

**Nothing is claimed tested in a running Retail, Classic or Forever client.** Original artwork was freshly extracted from Era 1.15.9.69722 and Anniversary 2.5.6.69795, decoded and inspected locally. The gryphon is EndCap-Dwarf; EndCap-Human is a lion.

Retail and beta executables were not found in the inspected locations. The user's first beta session remains necessary. Micro and bag button art, advanced class visuals and native tracking details retain Retail styling.

## Forever blockers

The real build/Interface number, loading rules, API lineage, frame hierarchy, event delivery, secret-value restrictions, combat taint, vehicle transitions, native texture presence, Edit Mode behavior and SavedVariables persistence need client checks. No official Forever identifier is fabricated.

## Main APIs and frames

APIs: CreateFrame, GetBuildInfo, InCombatLockdown, issecretvalue, UnitHealth/UnitHealthMax, UnitPower/UnitPowerMax, UnitName, UnitLevel, UnitPowerType, UnitClassification, SetPortraitTexture, C_Timer.After, EventRegistry callbacks and optional Settings.RegisterCanvasLayoutCategory/RegisterAddOnCategory.

Frames: MainActionBar, ActionButton1-12 and their native containers, PlayerFrame, TargetFrame, Minimap/MinimapCluster, MicroMenuContainer, BagsBar, PlayerCastingBarFrame, MainStatusTrackingBarContainer, SecondaryStatusTrackingBarContainer, and PlayerSpellsFrame.SpellBookFrame (loaded on demand).

Paths: Interface\MainMenuBar\UI-MainMenuBar-Dwarf; UI-MainMenuBar-EndCap-Dwarf; UI-MainMenuBar-MaxLevel; Interface\TargetingFrame\UI-TargetingFrame and elite/rare variants; UI-StatusBar; Interface\Minimap\UI-Minimap-Border; Interface\CastingBar\UI-CastingBar-Border; Interface\Buttons\UI-Quickslot2; Interface\SpellBook\UI-SpellbookPanel-TopLeft/TopRight/BotLeft/BotRight and Spellbook-Icon.

## Third-party and rights review

ClassicUI: GPLv3. Classic Frames: All Rights Reserved. KeyUI and DragonflightUI: MIT code. All remained research references; none of their code or bundled artwork was copied.

Project code is MIT. Blizzard artwork rights are separate. No blanket redistribution grant was established, and no blanket prohibition of exact in-client artwork is asserted. This ZIP contains no extracted artwork. Local research dependencies and extracts are excluded.

## Exact Day One procedure

Follow [BETA-TEST.md](BETA-TEST.md): install the correctly named folder, record build/Interface, run all five required diagnostic commands, inspect every gallery page, test settings and saved choices, clicks/bindings/targets/bags/casts and the spellbook in both sizes, exercise combat deferral and vehicles, test Edit Mode, reload, and copy /cf report. Allow 65 minutes. Disable the addon if it blocks controls.

## Next ten engineering tasks

1. Run the alpha on the actual beta and record its build, Interface and project ID.
2. Fix any loading or bootstrap errors before enabling visual modules.
3. Inspect each gallery asset in the beta and save screenshots.
4. Validate all action bindings, paging, forms, vehicles and override controls.
5. Check combat taint and exact default-layout restoration.
6. Validate player/target values under real secret restrictions and verify retained native absorb/heal prediction visuals.
7. Check multiple classes, UI scales, ultrawide screens and target-of-target placement.
8. Verify minimap buttons, tracking, rotations and any missing texture aliases.
9. Refine the Vanilla XP/reputation strip and original micro/bag artwork where the client provides it.
10. Refine focus and other-panel skins after the core beta checks pass.
