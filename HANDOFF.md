# 0.9.0-alpha engineering handoff

## Repository and package

The Git repository is classic-like-wow-forever. The install folder is **ClassicForeverUI**.

```text
classic-like-wow-forever/
  ClassicForeverUI.toc
  Core/             lifecycle, environment, rollback, assets, visual helpers, settings, reports
  Modules/          23 implemented modules; one explicit deferred module
  Data/             asset/API/frame/event catalogues
  Research/         pinned sources, licensing, local asset inventory and implementation
  Tests/            Lua 5.1 mock regression suite and diagnostic expectations
  Tools/            source scanners, read-only asset extraction and packaging
  BETA-TEST.md       exact client test procedure
  README.md
  LICENSE / LICENSE-NOTES.md
  dist/             generated; ignored by Git
    ClassicForeverUI/
    ClassicForeverUI-0.9.0-alpha.zip
    ClassicForeverUI-0.9.0-alpha.zip.sha256
```

## Implemented

Original stone action bar, original mirrored gryphons, classic action-slot borders, player/target visual skins, original minimap border, native XP/reputation fill and trim, native micro menu/bag placement, original cast border, and original parchment/trim/icon/slot borders for the native spellbook. Full-size focus uses the target-style skin at its native position and scale. Pet and target-of-target have passive Classic metal trim outside their native bars; their modern artwork remains. Compact focus and focus-target are unchanged. Classic tooltip backdrops, buff/debuff slot borders and quest-tracker header trim are also implemented. Player/target/focus health stays native, including incoming heals, shields, masks and health text. The real action buttons, unit buttons, casting engine and tracking logic remain Blizzard-owned.

Module failures are isolated and partially applied changes roll back. Missing combat API blocks writes. Edit Mode temporarily suspends the layout. The /cf settings window has a main switch, 23 feature toggles, saved choices and live status. It shares the slash-command apply path and includes texture, report and retry buttons. An optional Blizzard Settings > AddOns entry opens the same window. Unknown-client trials remain explicit and session-only.

## What works versus what is untested

The implemented behaviors passed 91 offline Lua 5.1 regression cases, including fourteen new window cases and all previous regressions. All 40 packaged Lua files load in the mock, and the ZIP is checked against the exact TOC/document allowlist.

**Nothing is claimed tested in a running Retail, Classic or Forever client.** Original artwork was freshly extracted from Era 1.15.9.69722 and Anniversary 2.5.6.69795, decoded and inspected locally. The gryphon is EndCap-Dwarf; EndCap-Human is a lion.

Retail and beta executables were not found in the inspected locations. The user's first beta session remains necessary. Micro and bag button art, advanced class visuals and native tracking details retain Retail styling.

## 0.9 combined window pass

BagWindows, BankWindow and MerchantWindow are separate implemented modules using
Core/WindowTrim.lua. Six individual bags (including reagent) and combined bags get
four-pixel side/bottom strips. BankFrame.BankPanel's shared character/account inset
and MerchantFrame.Inset get eight original metal overlays. Exact source atlas and
ownership checks fail closed; theme changes immediately hide addon art, including
in combat. All creation/refresh defers as before. No native property is overwritten.
Items/pools, backgrounds, corners/portraits, tabs, sorting, search, tooltips,
comparisons, quality/count/cooldown/quest overlays and all transaction controls stay
native. No purchase, sale, repair or inventory move was performed.

Unsupported: guild banks, legacy bank/reagent layouts, custom hierarchies, changed
border themes, bag top/corners, item-slot reskins and full Vanilla window recreation.
Panels remains deferred. Original character-sheet crops are reused; there was no new
extraction and no bag/bank/merchant sheet extraction claim. See Implementation.md.

The 91-case Lua 5.1 suite loads 40 TOC files. Settings have 23 choices across three
columns (8/8/7) at 1034x758, fitted to the screen. Settings and approximate crop
previews were inspected offline. ZIP payload is 45 files (40 Lua, TOC, four documents),
checked byte-for-byte against the allowlist, with no extracted art or research tools.
No running client is tested. Next: BETA-TEST.md, especially layer overlap, actual
reagent/account behavior, item interactions, theme transitions, taint and UI scaling.

The sections below describe historical feature passes; 0.9 supersedes their settings
counts and their old statement that bag windows were deferred.

## 0.8 character scope

CharacterWindow is a separate implemented module. It adds passive original dark character background and inset overlays to PaperDollFrame and four thin metal strips outside each supported equipment icon. No native character property is overwritten; disabling hides addon-owned art. It follows paper-doll visibility and existing anchors. Eighteen fixed slot names are checked against PaperDollItemsFrame and the intrinsic lowercase icon field. Native Quickslot/button states, quality borders, sockets, cooldowns, model, stats, outfits, tabs and all health/prediction trees remain untouched.

Custom/restricted backgrounds hide all character art immediately through secure post-hooks, including during combat; reapplication waits until safe. Missing structures fail closed; unsupported slots are counted in the report. Reputation/currency pages, outer portrait border, model/class backgrounds, equipment flyouts, custom layouts and bag windows are not reskinned. Original red buttons remain native.

Four character sheets were freshly extracted and decoded from Era 1.15.9.69722 only. Evidence is in LocalAssetInventory.csv; extracts stay outside Git and the install ZIP. The 77-case suite loads 36 TOC Lua files. Character crop and twenty-choice settings previews were inspected offline. The settings geometry remains 700x870 with ten rows per column. No running client tested.

## 0.7 dialogue scope

QuestDialogue and GossipDialogue are independent modules; Core/DialogueSkin.lua shares only their passive visual helpers. Ordinary QuestBG-Parchment backgrounds receive a covering texture, without changing the native background. Secure post-hooks hide that texture when native backgrounds change, including in combat; all creation, native alpha writes and rollback defer as before. Original inner quest borders follow Inset.NineSlice. Outer portrait borders and the already-original red buttons stay native. Standard QuestInfoRewardsFrame item/currency buttons receive passive slot borders after quest events. Map rewards, spell rewards, popup details, custom dialogue and missing hierarchies remain unchanged.

Four QuestGreeting sheets were freshly extracted from Era 1.15.9.69722 and inspected. The new paths were not extracted from Anniversary. No extracted files enter Git or the ZIP. That release had nineteen choices; the current character pass has twenty in the same fitted 700x870 window.

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

Follow [BETA-TEST.md](BETA-TEST.md): install the correctly named folder, record build/Interface, run all five required diagnostic commands, inspect every gallery page, test settings and saved choices, clicks/bindings/targets/bags/casts and the spellbook in both sizes, exercise combat deferral and vehicles, test Edit Mode, reload, and copy /cf report. Allow 110 minutes, including the window checks. Disable the addon if it blocks controls.

## Next ten engineering tasks

1. Run the alpha on the actual beta and record its build, Interface and project ID.
2. Fix any loading or bootstrap errors before enabling visual modules.
3. Inspect each gallery asset in the beta and save screenshots.
4. Validate all action bindings, paging, forms, vehicles and override controls.
5. Check combat taint and exact default-layout restoration.
6. Validate player/target values under real secret restrictions and verify retained native absorb/heal prediction visuals.
7. Check multiple classes, UI scales, ultrawide screens and pet/target-of-target placement.
8. Verify minimap buttons, tracking, rotations and any missing texture aliases.
9. Refine the Vanilla XP/reputation strip and original micro/bag artwork where the client provides it.
10. Consider compact focus, focus-target, party, raid, boss and other panels after client checks.
