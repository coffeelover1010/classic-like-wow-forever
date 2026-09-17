# Local client and artwork inspection

## 0.7 quest artwork addition

Freshly extracted UI-QuestGreeting-TopLeft, TopRight, BotLeft and BotRight from
Era 1.15.9.69722. All four decoded and were inspected as a 384x512 sheet plus a
catalogue-crop composition. Exact sizes and SHA-256 hashes are appended to
LocalAssetInventory.csv. Outputs remain in cf-ui-research/local-art-era-69722/QuestFrame;
the addon package contains only native paths. Anniversary was not re-extracted
for this pass. Native red-button paths are source-confirmed, not newly extracted.

Date: 17 September 2026. This is fresh filesystem/archive evidence, not an in-game test.

## 0.10 artwork pass

On 17 September 2026, the read-only extractor rechecked local wow_classic_era
storage at build 1.15.9.69722. Quest and talent micro-button Down/Disabled paths
were added to the allowlist and decoded successfully. Their four size/hash rows
are appended to LocalAssetInventory.csv. Existing paths were also read into
`cf-ui-research/feature-art-era-69722` outside this repository.

The crop preview includes the original micro-button states, tracking ring,
small cast border and slot surround. Measured alpha bounds corrected padding in
the latter two crops. This proves local image content, not native rendering.
Anniversary and Retail were not extracted in this pass. No game was launched.

## Installed clients (earlier inspection)

The standard installation at `C:\Program Files (x86)\World of Warcraft` has these active products in `.build.info`:

| Product | Executable | File version |
|---|---|---|
| wow_classic_era | _classic_era_/WowClassic.exe | 1.15.9.69722 |
| wow_anniversary | _anniversary_/WowClassic.exe | 2.5.6.69795 |

The `_retail_` folder contains an Interface folder but no WoW executable. The `_classic_` and copied WoW installation do not provide another executable. Focused discovery in the standard Program Files locations, Downloads, Documents and C:/dev found no Retail executable or Forever/beta executable/build metadata. This does not prove there is no installation anywhere else.

No game process was launched. No account credentials were read. No archives were modified.

## Read-only extraction

Built [CascLib](https://github.com/ladislav-zezula/CascLib/tree/2a280f5a231966dc5d1b534978dd9f9f04a374cd) from its MIT source at `2a280f5a231966dc5d1b534978dd9f9f04a374cd`. It remains outside the addon repository. Used Visual Studio Build Tools with the v145 toolset; the resource include was changed from afxres.h to windows.h because MFC was not installed. No archive-reading code was changed.

[Tools/extract_local_assets.py](../Tools/extract_local_assets.py) opens local storage through CascOpenStorage, opens a fixed list of UI paths with strict data checking, reads their contents, and closes the handles. It does not use online storage or request downloads.

Checked 31 paths in each product. **28 BLP textures were extracted from each**. The initial 21 textures were decoded with Pillow and inspected in a local contact sheet. The seven spellbook additions were also decoded and inspected locally. [LocalAssetInventory.csv](LocalAssetInventory.csv) records exact paths, sizes, SHA-256 hashes and failed opens.

Outputs stay outside the repository:

- `C:/dev/addons playground/cf-ui-research/local-art-era-69722`
- `C:/dev/addons playground/cf-ui-research/local-art-anniversary-69795`

The two builds have different bytes and decoded pixels for the rare-elite target border and minimap border. Other extracted files have matching hashes. Thus a common path alone does not promise identical pixels across client versions.

## Important corrections from actual pixels

- **UI-MainMenuBar-EndCap-Dwarf is the original gryphon.**
- **UI-MainMenuBar-EndCap-Human is a lion.** The earlier candidate research misidentified it as a gryphon; this inspection supersedes that identification.
- UI-MainMenuBar-Dwarf is a four-section stone/background sheet.
- UI-Minimap-Border is the main ring/header sheet. MiniMap-TrackingBorder is only the small tracking-button ring.
- UI-TargetingFrame and the rare/elite variants contain original unit-frame artwork.
- UI-StatusBar and both inspected CastingBar border variants decoded successfully.
- The four UI-SpellbookPanel sheets, Spellbook-Icon, UI-Spellbook-SpellBackground and SpellBook-SkillLineTab decoded successfully in both builds. The spellbook module references the four panel sheets and icon; the last two are research candidates.
- UI-MainMenuBar, UI-MainMenuBar-Experience and UI-MicroButton-Character-Up were not extracted by those names. These failed lookups do not establish absence under every alias or in other clients.

Offline art-composition checks were also inspected to verify bar crops, mirrored endcaps, unit-bar placement, and spellbook crops/anchors at 806 and 1612 pixels wide. They are **not in-game screenshots**.

## Runtime boundary

The addon references native paths, including EndCap-Dwarf. It bundles no extracted images. Local extraction establishes availability in the two named Classic stores. Retail source and current-addon research support the development approach, but Retail and Forever rendering remain unverified.

The gallery and report must be run in the beta. A successful SetTexture result is recorded as LOAD_ACCEPTED_VISUAL_UNVERIFIED, never as proof of rendered pixels.

## Reproduce on this Windows host

```powershell
$py = 'C:\Users\Z68\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
& $py Tools/extract_local_assets.py --dll 'C:\dev\addons playground\cf-ui-research\CascLib\bin\CascLib_dll\x64\Release\CascLib.dll' --storage 'C:\Program Files (x86)\World of Warcraft' --product wow_classic_era --output 'C:\dev\addons playground\cf-ui-research\local-art-era-69722'
```

A new product/build needs its own metadata and output directory. This tool refuses to write extracted art inside the addon repository.

The 0.5 pass added two Era tooltip paths: UI-Tooltip-Background and UI-Tooltip-Border. Both extracted successfully and were decoded locally; their size/hash evidence is appended to LocalAssetInventory.csv. The Anniversary inventory remains the earlier 31-path run.

## 0.8 character extraction

On 17 September 2026, four UI-Character-CharacterTab sheets (L1, R1,
BottomLeft and BottomRight) were extracted from local wow_classic_era
1.15.9.69722 with the existing read-only tool. All decoded successfully and were
inspected as a combined sheet and catalogue-crop composition. L1/BottomLeft are
256x256; R1/BottomRight are 128x256. Their byte sizes and SHA-256 hashes are in
LocalAssetInventory.csv. Outputs are in cf-ui-research/character-art-era-69722,
outside the repository and ZIP. The tool also rechecked its previous allowlist;
no new Anniversary extraction is claimed. Native red-button paths remain
source-confirmed, not newly extracted. No running game was used.

## 0.9 window trim reuse

No new extraction was performed. Bag, bank and merchant borders reuse the existing
four Era 1.15.9.69722 character-sheet crops inventoried for 0.8. A new approximate
crop composition was inspected offline. This does not establish native Retail or
Forever rendering, nor extraction of original bag/bank/merchant sheets. No extracted
art is bundled. No game was launched and no game action was performed.
