# Asset map: 0.2 alpha

All visible artwork below is referenced from the client. No extracted texture or third-party artwork is packaged.

| Visual | Logical IDs / native path suffix | Evidence |
|---|---|---|
| Stone bar | CLASSIC_MAINBAR_* / MainMenuBar/UI-MainMenuBar-Dwarf | Source crops and local Classic extraction |
| Gryphons | CLASSIC_GRYPHON_* / MainMenuBar/UI-MainMenuBar-EndCap-Dwarf | Local pixels inspected; right mirrored |
| Player/target | CLASSIC_PLAYERFRAME_BORDER, CLASSIC_TARGETFRAME_BORDER / TargetingFrame/UI-TargetingFrame | Local extraction and source references |
| Elite/rare | CLASSIC_TARGET_ELITE, CLASSIC_TARGET_RARE, CLASSIC_TARGET_RARE_ELITE | Local extraction; guarded runtime classification |
| Main minimap ring | CLASSIC_MINIMAP_BORDER / Minimap/UI-Minimap-Border | Local extraction; not the tracking-button ring |
| Unit/tracking fill | CLASSIC_STATUSBAR / TargetingFrame/UI-StatusBar | Local extraction |
| Tracking trim | CLASSIC_MAXLEVEL / MainMenuBar/UI-MainMenuBar-MaxLevel | Local extraction |
| Cast border | CLASSIC_CAST_BORDER / CastingBar/UI-CastingBar-Border | Local extraction |
| Action slots | CLASSIC_QUICKSLOT / Buttons/UI-Quickslot2 | Local extraction |
| Micro/bag buttons | Existing Retail button art | Retained from the native UI; not a Vanilla restoration |
| Gallery/report backgrounds | Solid colors made by addon code | No bitmap artwork |

Data/AssetCatalogue.lua centralizes paths, dimensions and crops. LocalAssetInventory.csv records the extracted file hashes. Local archive availability applies only to the named Classic builds; Retail/Forever rendering stays unverified until the gallery is inspected there.

The earlier EndCap-Human candidate is a lion, not a gryphon. Its pixels were inspected and it is not used for CLASSIC_GRYPHON_*.

No FileDataID fallback was needed for the locally extracted candidates. The addon does not assume that a configured path or a returned success boolean proves correct rendered pixels.
