# ClassicForeverUI

A Retail addon that puts original Blizzard Classic artwork around a Classic-style layout. Version **0.6.0-alpha** adds a full-size focus skin and Classic metal trim for pet and target-of-target frames. It has **not been tested inside WoW**. Forever support is unverified.

## Install

Download or build the release ZIP. Extract the **ClassicForeverUI** folder into the chosen client's **Interface/AddOns** folder. The result must be:

```text
Interface/AddOns/ClassicForeverUI/ClassicForeverUI.toc
```

Do not install a folder called `classic-like-wow-forever` or nest one ClassicForeverUI folder inside another. Restart the game after installing a new addon. Enable it at character selection.

Read [BETA-TEST.md](BETA-TEST.md) for the test session. Start with `/cf diagnostic`, `/cf gallery`, and `/cf report`. Use `/cf off` to restore the default UI. Changes made during combat wait until combat ends.

## What it changes

- The bottom bar uses original stone panels, gryphons and button borders. The right gryphon is mirrored.
- Player and target frames use original borders, portraits and power bars around native health displays. Target rarity selects the matching original border when classification is readable.
- Full-size focus uses the target-style skin while keeping its native position and scale. Compact focus stays native and reports unavailable.
- Pet and target-of-target get thin Classic metal trim above health and below power. Their native borders, portraits, bars, masks, text, prediction indicators and positions stay in place. This is a limited trim pass.
- Buffs and debuffs get original slot borders. Native timers, counts, dispel colors, enchant borders and right-click controls stay in place. Private aura anchors remain unchanged.
- Tooltips use the original dark background and a gray border. Links, comparisons and native content stay in place. The border is gray even for rare items; item names keep their native colors.
- The quest tracker gets a Classic header and metal trim. Its rows, quest items, filters and collapse controls stay native.
- The minimap uses the original round border.
- Native XP and reputation bars get original fill and metal trim. Blizzard still handles their values, selection, rested XP and tooltips.
- The native micro menu and bags move into the bottom layout. Their Retail button artwork remains.
- The native player cast bar gets an original border and a Classic-style position. Blizzard still handles casting, channeling and empowered spells.
- The spellbook uses original parchment, metal trim, a book icon and spell-slot borders. It follows the small and large views. Search, categories, page arrows, pet spells and dragging spells stay native. The talents and specialization tabs keep their own artwork.

The addon keeps Blizzard's action buttons, secure paging, unit buttons, right-click menus and aura controls. It does not change their parents, scripts or secure attributes. Compact focus, focus-target, party, raid, boss frames and other panels remain unchanged. Buffs, debuffs and the tracker keep their native positions. This is a recognizable Classic layout, not full Vanilla pixel parity.

Open the spellbook once to load its skin. Before that, its module can report `UNAVAILABLE` with an instruction to open it. Use `/cf module SpellBook off` to restore only the spellbook. Native spell-state markers, passive shapes, cooldowns and pet autocast overlays are retained above the added borders.

## Controls

Type **`/cf`** to open settings. There is one main switch and seventeen feature checkboxes. Click anywhere on a feature row to change it. Choices save automatically and apply outside combat. Turning the main switch off keeps your feature choices for next time.

The window shows which features have applied, which are off, and which need attention. **Open book** means the spellbook must be opened once to load. **View textures**, **Open report**, and **Retry changes** give quick access to troubleshooting. The report provides text to copy with Ctrl+A, Ctrl+C.

Drag the window to move it. Close it with **Close** or **Escape**. It scales down to fit smaller screens. On clients with Blizzard's Settings API, **Settings > AddOns > ClassicForeverUI** also has an **Open settings** button. `/cf` works without that API.

| Command | Use |
|---|---|
| `/cf`, `/cf config`, `/cf options` | Open the settings window |
| `/cf help` | List commands |
| `/cf off` / `/cf on` | Restore default / apply addon layout |
| `/cf module Minimap off` | Disable one module; use `on` to enable it |
| `/cf refresh` | Recheck and retry modules, outside combat |
| `/cf gallery` | View original textures at their configured crop and orientation |
| `/cf report` | Open a report you can copy with Ctrl+A, Ctrl+C |
| `/cf diagnostic` | Print the full report to chat |
| `/cf environment`, `assets`, `api`, `frames` | Print one report section |
| `/cf enable` | Try the layout on an unknown or Classic client for this session |

On recognized Retail, the layout applies at login. Other project IDs default to diagnostics until `/cf enable` or **Try this session** in settings. That trial is not saved between sessions. A Retail ID is not proof that a future client has the same API. Edit Mode temporarily restores the stock layout and reapplies the addon after closing.

## Test status and limits

Lua 5.1 checks and mocked regression tests pass. Original textures were read from installed Classic Era and Anniversary archives and inspected locally. There was no installed Retail executable or Forever beta found in the inspected locations. No in-game rendering, secure combat behavior, Edit Mode persistence, vehicle controls or compatibility is certified.

`APPLIED_UNVERIFIED` means the module's Lua ran without a caught error. `LOAD_ACCEPTED_VISUAL_UNVERIFIED` means the texture API accepted the request. Neither means the image rendered correctly. See [Tests/DiagnosticExpectations.md](https://github.com/coffeelover1010/classic-like-wow-forever/blob/main/Tests/DiagnosticExpectations.md).

Unit skins retain full-size native health bars, incoming healing, shields, heal absorbs, losses and native health text. Their modern health artwork remains; portrait combat flash is still omitted. Other Retail class resources remain native. Minimap utility buttons and newer micro menu features also remain native. Other UI addons can move these same frames; test this alpha with them disabled.

## Build and test

Python 3.12 and the test-only `lupa` package are used for local checks. The installed addon needs only WoW.

```text
python -m pip install lupa
python Tests/run_tests.py
python Tools/package_addon.py
```

Output: `dist/ClassicForeverUI/` and `dist/ClassicForeverUI-0.6.0-alpha.zip`. Packaging uses the TOC and a small document allowlist. It excludes research checkouts, test tools, previews, extracted images and native libraries.

If the beta rejects the TOC, first read its actual Interface number. Then build a separate package:

```text
python Tools/package_addon.py --interface OBSERVED_NUMBER --output dist-beta
```

Changing a TOC number only permits a loading attempt. It does not establish compatibility.

## Architecture and research

`Core/` handles lifecycle, rollback, environment checks, assets and reports. Independent modules live in `Modules/`. `Data/` lists assets, APIs, frames and events. A failed module leaves the others running. An unknown combat API prevents layout writes.

See [Research/Implementation.md](https://github.com/coffeelover1010/classic-like-wow-forever/blob/main/Research/Implementation.md), [Research/LocalClientInspection.md](https://github.com/coffeelover1010/classic-like-wow-forever/blob/main/Research/LocalClientInspection.md), and [Research/OriginalArtworkFeasibility.md](https://github.com/coffeelover1010/classic-like-wow-forever/blob/main/Research/OriginalArtworkFeasibility.md).

The existing source comparison tools remain available:

```text
python Tools/scan_lua_api_usage.py SOURCE --output scan.json
python Tools/generate_asset_manifest.py SOURCE --out generated-assets
python Tools/compare_ui_sources.py CLASSIC RETAIL --output comparison.md
python Tools/generate_compat_report.py classic.json retail.json
```

Add new client rules only after checking its actual source and behavior. Keep Forever differences in the compatibility layer.

## Artwork and license

Our code is MIT licensed. Blizzard owns the referenced artwork. The install package contains **no extracted textures** and no copied third-party addon code. No AI artwork is used. Read [LICENSE-NOTES.md](LICENSE-NOTES.md) for the distinction between source-code licenses and artwork rights.
