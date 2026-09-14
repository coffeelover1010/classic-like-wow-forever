# Compatibility matrix

Initial scan, 2026-09-14: Classic `ecadf9d3326fa87828cacca7f13c0ab5f41840a6` versus Retail `4e3cbb8c5609e4bfc332c0aebbfa4d79731fab59`. This is generated from conservative scanner candidates, so individual symbols require feature-level review.

| Category | Shared | Classic only | Retail only |
|---|---:|---:|---:|
| APIs | 10,659 | 2,273 | 4,964 |
| Atlases | 1,117 | 95 | 2,512 |
| Events | 770 | 193 | 296 |
| Frames | 4,318 | 2,094 | 1,858 |
| Textures | 1,236 | 472 | 338 |

The notably larger Retail atlas inventory makes asset resolution and fallbacks a core compatibility boundary.
