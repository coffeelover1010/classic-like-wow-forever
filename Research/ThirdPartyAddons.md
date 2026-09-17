# Third-party addon research

Research updated 2026-09-17. No third-party code or artwork has been incorporated into the addon. See [OriginalArtworkFeasibility.md](OriginalArtworkFeasibility.md) for pinned source links, texture evidence, limitations, and the distinction between code licensing and Blizzard artwork rights.

| Project | Inspected revision | Declared license | Client/useful technique | Reuse status |
|---|---|---|---|---|
| [ClassicUI](https://github.com/millanzarreta/ClassicUI) | `037dcf3a58e23095c1ca183ec1fad85b7739bf7d` | GPLv3 | Retail; native legacy bar textures, mirrored endcaps, packaged microbutton resources; SetTexture/SetAtlas/SetTexCoord | Code subject to GPL requirements; underlying art rights separate |
| [Classic Frames](https://github.com/Daenarys/ClassicFrames) | `55b66cc4b45e0a581b1a8d388980620f59f4f491` | All Rights Reserved on CurseForge | Retail 12.1 TOC inspected; native player/target/cast-bar textures; SetTexture/SetStatusBarTexture | Read-only implementation research |
| [KeyUI](https://github.com/1onar/KeyUI) | `82a1af0657d5bfe7fd22452415f1d3fb8dd98c13` | MIT | Retail and Classic variants; documented extracted texture fallbacks; SetTexture/SetAtlas | Author-owned code under MIT with notices; underlying art rights separate |
| [DragonflightUI](https://github.com/Karl-HeinzSchneider/WoW-DragonflightUI) | `b8b35451d4621a8097e887385f72ec03e17765f1` | MIT | Retail-style UI for Classic; modular adaptation and packaged texture tree inspected | Author-owned code under MIT with notices; per-file art provenance unverified |

Client claims are author/source evidence, not in-game tests performed by this project. No author or Blizzard was contacted. Independent implementation concepts: central asset resolution, native-path-first rendering, explicit packaged fallbacks, mirrored texture coordinates and module separation.
