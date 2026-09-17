# ClassicForeverUI

A Retail addon that puts original Blizzard Classic artwork around a Classic-style layout. **0.10.0-alpha** adds more window skins, cast surrounds, button artwork and small details. **No running WoW client has been tested. Forever support is unverified.**

## Install

Extract the release ZIP's **ClassicForeverUI** folder into your client's **Interface/AddOns** folder:

```text
Interface/AddOns/ClassicForeverUI/ClassicForeverUI.toc
```

Restart the game and enable the addon at character selection. Do not install a folder named `classic-like-wow-forever` or nest one ClassicForeverUI folder inside another.

Start with `/cf diagnostic`, `/cf gallery` and `/cf report`. Follow [BETA-TEST.md](BETA-TEST.md). Use `/cf off` to restore the default UI; changes made in combat wait until combat ends.

## What it changes

- Original stone action-bar panels, mirrored gryphons and slot borders surround Blizzard's action buttons.
- Player, target and full-size focus get Classic borders and power displays around native health, healing and shield indicators. Full-size focus keeps its position and scale.
- Pet, target-of-target and focus-target get thin metal trim. Compact focus has a separate trim option. Their native bars, portraits, auras and controls remain.
- Player casts get a Classic border and position. Target and focus casts get separate Classic surrounds at their native position and size. Native cast, channel, interrupt and empower behavior stays in charge.
- The minimap gets its original round border. A separate option adds a dark header, clock underline and tracking ring. Native clock text, alarms, tracking, mail, calendar and utility controls stay in place.
- Native XP and tracked reputation bars get original fill and trim. Blizzard still selects and updates them.
- Menu and bag buttons can move into the bottom layout. Separate artwork options add original quest/talent button states and bag-slot surrounds. Newer menu functions, alerts, bag masks, the reagent bag and expand toggle remain.
- Spellbook, quest and NPC dialogue windows get original parchment and trim. Native searches, pages, spell controls, choices and rewards remain.
- The character equipment page gets a dark background, inset and gear trim. A separate option styles the reputation and currency pages while keeping their rows and controls.
- Bag windows get top, side and bottom strips. Bank, merchant, mail, trade, inspect and trainer windows get scoped inset trim. Loot gets outer panel trim; its scrolling item cards remain native.
- A separate item-slot option adds original surrounds to supported bag, bank and merchant icons. Quality colors, counts, search shading, quest marks, cooldowns and item actions remain native.
- Buffs and debuffs get slot borders. Tooltips get Classic dark backdrops and gray borders. The quest tracker gets header trim.
- Optional chat input trim starts **off**. Native chat tabs, backgrounds and input borders already use older Blizzard artwork, so they are retained.

The addon keeps native scripts, secure attributes, parents, keybindings and transaction controls under Blizzard ownership. It does not rebuild the Vanilla UI pixel for pixel. Tooltips use a fixed gray border; item names keep their native quality colors. The existing player/target/full-focus skin omits portrait combat flash.

## Limits of this pass

| Area | Supported scope | Retained or deferred |
|---|---|---|
| Mail, trade, inspect, trainers | Known native insets; inbox/send/opened mail | Stationery, item rows, outer portraits, models and all actions |
| Loot | Four outer edge strips | Pooled cards, quality/quest markers, animations and auto-loot |
| Target/focus casts | Passive original surrounds | Native indicators and cast engine; changed border themes |
| Menu/bag artwork | Quest and talent up/down/disabled textures; six bag surrounds | Other menu icons, highlights/alerts, circular masks and newer functions |
| Minimap details | Header, clock underline and tracking ring | Native utility buttons and changing notification art |
| Deeper windows | Bag top edges; bag/bank/shop slot trim; merchant money insets; reputation/currency pages | Color-driven bag backgrounds, curved outer portraits, legacy/guild banks and custom layouts |
| Chat | Optional exterior input trim | Native old-art tabs/backgrounds, focus highlights and chat behavior |
| Unit/group frames | Compact focus and focus-target trim; existing pet/target-of-target trim | Fuller small-frame replacements and party/raid/boss skins need client layout and indicator checks |

Missing or changed hierarchies fail safely. Scoped borders and new guarded backgrounds reveal native art for changed, tinted or restricted themes. Some windows load only when first opened. Use `/cf refresh` if a supported frame appears later without its skin. Pool and load-on-demand event coverage still need real-client checks.

## Controls

Type **`/cf`** for the main switch and **38 feature choices** on two pages: **Layout & windows** and **More features**. Each row is clickable. Choices save automatically. Turning off the main switch keeps your feature choices.

The settings window has three columns per page and a 1034x798 base size that scales down to fit the screen. Drag it to move it; close with **Close** or **Escape**. **View textures**, **Open report** and **Retry changes** help with testing. The report supports Ctrl+A, Ctrl+C. An optional **Settings > AddOns > ClassicForeverUI** entry opens the same window.

| Command | Use |
|---|---|
| `/cf`, `/cf config`, `/cf options` | Open settings |
| `/cf help` | List commands |
| `/cf off` / `/cf on` | Restore default / apply addon layout |
| `/cf module MailWindow off` | Disable one feature; use `on` to enable it |
| `/cf refresh` | Recheck and retry modules outside combat |
| `/cf gallery` | Inspect every configured texture and crop |
| `/cf report` | Open a report to copy |
| `/cf diagnostic` | Print the full report to chat |
| `/cf environment`, `assets`, `api`, `frames` | Print one report section |
| `/cf enable` | Try the layout on an unknown or Classic client for this session |

Recognized Retail applies the layout at login. Other project IDs start with diagnostics until **Try this session** or `/cf enable`. That trial is not saved. A Retail project ID does not establish future-client compatibility. Edit Mode restores the stock layout temporarily and reapplies the addon after closing.

## Test status

**116 offline Lua 5.1 regression cases pass; all 55 TOC Lua files compile and execute in the mock.** Settings and original-art crop previews were inspected offline. Extraction records establish local Classic archive availability only. Four new micro-button state textures were extracted and decoded from Era 1.15.9.69722 for this pass; Anniversary was not re-extracted.

`APPLIED_UNVERIFIED` means a module ran without a caught error. `LOAD_ACCEPTED_VISUAL_UNVERIFIED` means the texture API accepted a request. Neither proves pixels, event delivery, combat safety, taint behavior or Forever compatibility. See [diagnostic expectations](https://github.com/coffeelover1010/classic-like-wow-forever/blob/main/Tests/DiagnosticExpectations.md). Test with other UI addons disabled.

## Build and test

Python and the test-only `lupa` package run offline checks. The installed addon needs only WoW.

```text
python -m pip install lupa
python Tests/run_tests.py
python Tools/package_addon.py
```

Output: `dist/ClassicForeverUI/` and `dist/ClassicForeverUI-0.10.0-alpha.zip`. The builder verifies the exact 60-file payload: 55 Lua files, the TOC and four documents. Research, tests, previews, extracted art and native libraries are excluded.

If a client rejects the TOC, first record its actual Interface number, then build a separate package:

```text
python Tools/package_addon.py --interface OBSERVED_NUMBER --output dist-beta
```

Changing the TOC only permits a loading attempt; it does not establish compatibility.

## Architecture and rights

`Core/` handles lifecycle, rollback, combat/Edit Mode rules, settings, assets and reports. Independent modules live in `Modules/`. Errors are isolated. Missing combat support blocks writes. The generic `Panels` module remains explicitly deferred.

See [implementation and source evidence](https://github.com/coffeelover1010/classic-like-wow-forever/blob/main/Research/Implementation.md), [local artwork evidence](https://github.com/coffeelover1010/classic-like-wow-forever/blob/main/Research/LocalClientInspection.md), and [engineering handoff](https://github.com/coffeelover1010/classic-like-wow-forever/blob/main/HANDOFF.md).

Our code is MIT licensed. Blizzard owns the referenced artwork. The ZIP contains **no extracted textures**, copied third-party addon code or AI artwork. Read [LICENSE-NOTES.md](LICENSE-NOTES.md). This is an unofficial community project.
