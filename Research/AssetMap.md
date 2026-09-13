# Asset map

| Visual | Resolution strategy | Status |
|---|---|---|
| Classic action-bar/endcap candidates | Blizzard path through `CF.Assets` | FOREVER_VALIDATION_REQUIRED |
| Unit-frame borders | Blizzard path through `CF.Assets` | FOREVER_VALIDATION_REQUIRED |
| Minimap border | Blizzard path through `CF.Assets` | FOREVER_VALIDATION_REQUIRED |
| Addon-authored layout code | Lua frames/layout only | permitted |

`Data/AssetCatalogue.lua` is the machine-readable seed. Generated manifests should add client availability and source revision before an asset is used.
