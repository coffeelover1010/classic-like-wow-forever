# Compatibility matrix

## 0.2 alpha implementation status, 17 September 2026

| Client | Source/API basis | Local archive check | In-game test |
|---|---|---|---|
| Retail | Pinned source; nine modules implemented and Lua 5.1 mock-tested | No installed executable/build found | Not performed |
| Classic Era 1.15.9.69722 | Original art/source reference; default diagnostics-only | 21 of 24 selected paths extracted | Not performed |
| Anniversary 2.5.6.69795 | Original art reference; default diagnostics-only | 21 of 24 selected paths extracted | Not performed |
| Forever | No assumed API lineage or official identifier | No beta install found in inspected locations | Required |

See [Implementation.md](Implementation.md), [LocalClientInspection.md](LocalClientInspection.md) and [../BETA-TEST.md](../BETA-TEST.md). Source matches and mock results are not runtime compatibility claims.

## Historical source inventory

Initial scan, 2026-09-14: Classic `ecadf9d3326fa87828cacca7f13c0ab5f41840a6` versus Retail `4e3cbb8c5609e4bfc332c0aebbfa4d79731fab59`. This is generated from conservative scanner candidates, so individual symbols require feature-level review.

| Category | Shared | Classic only | Retail only |
|---|---:|---:|---:|
| APIs | 10,659 | 2,273 | 4,964 |
| Atlases | 1,117 | 95 | 2,512 |
| Events | 770 | 193 | 296 |
| Frames | 4,318 | 2,094 | 1,858 |
| Textures | 1,236 | 472 | 338 |

The notably larger Retail atlas inventory makes asset resolution and fallbacks a core compatibility boundary.
