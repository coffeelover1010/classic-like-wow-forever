# Original Classic artwork: feasibility and permissions research

Research date: 17 September 2026. Scope: exact Blizzard UI artwork in a free WoW addon, with Retail as the development target and Forever still unverified.

**Later local inspection:** [LocalClientInspection.md](LocalClientInspection.md) records actual extraction and pixel inspection on this date. It corrects one candidate identification below: EndCap-Human is a lion; **EndCap-Dwarf is the original gryphon** and is used by 0.2.0-alpha. The historical research below is preserved; its no-extraction limitation describes the earlier investigation only.

## Finding

There is strong technical evidence that a substantial Classic UI can be built using original Blizzard artwork without AI-generated replacements. Current Retail addons reference original action-bar, gryphon, minimap, unit-frame and cast-bar textures through client paths. Some also distribute texture files. The earlier assertion that these addons only reference installed artwork was incorrect.

The separate legal finding is limited: this investigation did not locate an explicit blanket Blizzard grant to redistribute extracted Classic UI textures in a public addon package. Nor did it locate a specific official ruling prohibiting this exact Classic-to-Retail/Forever UI use. Existing distribution demonstrates practice and feasibility; it does not establish what private permissions authors have or guarantee Blizzard approval of another project.

Recommendation: proceed with exact-art development using verified legacy paths first. Evaluate any genuinely missing artwork individually. AI-generated replacements are not part of the proposed solution. Forever's actual asset set and API restrictions remain unknown.

## Method and confidence

Inspected actual Git repository trees, Lua texture calls, TOCs, licenses, author documentation, published addon listings, and Blizzard's addon policy. Research checkouts are outside the addon repository at `C:\dev\addons playground\cf-ui-research`. No third-party code or art was incorporated into ClassicForeverUI.

Evidence levels are deliberately distinct:

- **Source-confirmed:** a pinned file contains the reference or a repository contains the asset.
- **Author-supported:** a published release declares support for a client; this is not our runtime test.
- **Runtime-confirmed:** the texture has rendered in a named client build. No new runtime confirmations were obtained in this investigation.
- **Permission-confirmed:** a grant explicitly covers the proposed redistribution. No Blizzard texture-redistribution grant was located for this project.

Modern Classic source is not automatically identical to the original 2004/1.12 interface. Pre-BFA bars, pre-Dragonflight frames and original Vanilla layout are related but different targets. We must compare the final layout against the intended Vanilla reference rather than assume an existing addon is pixel-identical.

## 1. ClassicUI: the directly relevant Retail precedent

[ClassicUI's author page](https://www.curseforge.com/wow/addons/classicui) lists GPLv3 and Retail support. Its linked [source repository](https://github.com/millanzarreta/ClassicUI) was inspected at `037dcf3a58e23095c1ca183ec1fad85b7739bf7d`; its TOC declares version 3.0.2 and Interface 120100.

It mixes client paths with packaged textures. The `ClassicUI/Textures` folder contains 91 files, including `MiniMap-TrackingBorder.blp`, classic microbuttons and custom variants. These filenames alone do not establish which images are unmodified Blizzard originals.

Its stone bar uses `UI-MainMenuBar-Dwarf` and `UI-MainMenuBar-KeyRing`; its original endcaps use `UI-MainMenuBar-EndCap-Human`, with mirrored coordinates for the right side. Modern atlas artwork is a separate option, not evidence that it is visually identical to Vanilla.

Evidence: [bar texture calls](https://github.com/millanzarreta/ClassicUI/blob/037dcf3a58e23095c1ca183ec1fad85b7739bf7d/ClassicUI/ClassicUI.lua#L3570), [endcap choices](https://github.com/millanzarreta/ClassicUI/blob/037dcf3a58e23095c1ca183ec1fad85b7739bf7d/ClassicUI/ClassicUI.lua#L3703), [packaged tracking-border call](https://github.com/millanzarreta/ClassicUI/blob/037dcf3a58e23095c1ca183ec1fad85b7739bf7d/ClassicUI/ClassicUI.lua#L2920), [texture directory](https://github.com/millanzarreta/ClassicUI/tree/037dcf3a58e23095c1ca183ec1fad85b7739bf7d/ClassicUI/Textures), [GPLv3](https://github.com/millanzarreta/ClassicUI/blob/037dcf3a58e23095c1ca183ec1fad85b7739bf7d/LICENSE.txt).

Code reuse would require GPL compliance; copying it into our MIT project does not make the copied code MIT. The addon author's license also cannot independently settle Blizzard's underlying art rights.

## 2. Classic Frames: original unit-frame paths on current Retail

[Classic Frames](https://www.curseforge.com/wow/addons/classic-frames) declares All Rights Reserved and describes restoring pre-10.x UI frames. Its linked [repository](https://github.com/Daenarys/ClassicFrames) was inspected at `55b66cc4b45e0a581b1a8d388980620f59f4f491`. The TOC declares version 3.82 and Interface 120100.

The player skin loads `Interface\TargetingFrame\UI-TargetingFrame`; the target skin loads the normal, rare, elite and rare-elite variants from Blizzard paths. The cast-bar skin also references native legacy border and fill textures. Only two `.blp`/`.tga` files were listed in the complete Git tree: tracking-border and diamond-header textures. This is particularly useful evidence that the main legacy unit-frame artwork need not be supplied as a replacement image package.

Evidence: [player border](https://github.com/Daenarys/ClassicFrames/blob/55b66cc4b45e0a581b1a8d388980620f59f4f491/ClassicFrames/skins/unitframes/PlayerFrame.lua#L229), [target variants](https://github.com/Daenarys/ClassicFrames/blob/55b66cc4b45e0a581b1a8d388980620f59f4f491/ClassicFrames/skins/unitframes/TargetFrame.lua#L204), [cast-bar border](https://github.com/Daenarys/ClassicFrames/blob/55b66cc4b45e0a581b1a8d388980620f59f4f491/ClassicFrames/skins/unitframes/CastBar.lua#L23).

Its implementation remains read-only research under the published license; independently implement our adaptation.

## 3. Further cross-client packaging precedents

**KeyUI:** inspected at `82a1af0657d5bfe7fd22452415f1d3fb8dd98c13`, with an MIT license. Its [compatibility guide](https://github.com/1onar/KeyUI/blob/82a1af0657d5bfe7fd22452415f1d3fb8dd98c13/COMPATIBILITY.md#L147) explicitly describes extracting Retail textures and bundling them for Classic. The [Media/Atlas tree](https://github.com/1onar/KeyUI/tree/82a1af0657d5bfe7fd22452415f1d3fb8dd98c13/Media/Atlas) contains ten BLP files, including tutorial glow, dropdown and button textures. This is direct author evidence of the practice, not an inference from screenshots. Its client-detection advice was not independently validated or adopted.

**DragonflightUI:** inspected at `b8b35451d4621a8097e887385f72ec03e17765f1`. Its [README](https://github.com/Karl-HeinzSchneider/WoW-DragonflightUI) describes adapting Retail UI for Classic, its [license](https://github.com/Karl-HeinzSchneider/WoW-DragonflightUI/blob/b8b35451d4621a8097e887385f72ec03e17765f1/LICENSE) is MIT, and its [texture tree](https://github.com/Karl-HeinzSchneider/WoW-DragonflightUI/tree/b8b35451d4621a8097e887385f72ec03e17765f1/Textures) includes BLP interface resources. This supports technical feasibility in the reverse direction. No per-file Blizzard permission or byte-for-byte origin audit was established.

## 4. Original-art candidate map

These are source-confirmed candidates, not declarations that every current installation or Forever contains them. Paths are relative to the game's virtual filesystem, not another installed client's folder.

| Component | Original path candidate | Evidence |
|---|---|---|
| Gryphons | `Interface\MainMenuBar\UI-MainMenuBar-EndCap-Human` | ClassicUI lines 3708, 3744; right side mirrored |
| Stone bar | `Interface\MainMenuBar\UI-MainMenuBar-Dwarf` | ClassicUI 3570; Blizzard Classic MainMenuBar.xml 58 |
| Right bar/keyring section | `Interface\MainMenuBar\UI-MainMenuBar-KeyRing` | ClassicUI 3588 |
| Max-level trim | `Interface\MainMenuBar\UI-MainMenuBar-MaxLevel` | ClassicUI 3614 |
| Player/normal target border | `Interface\TargetingFrame\UI-TargetingFrame` | Classic Frames PlayerFrame.lua 229 and TargetFrame.lua 264; Blizzard Classic PlayerFrame.xml 54 |
| Elite/rare borders | `Interface\TargetingFrame\UI-TargetingFrame-Elite`, `-Rare`, `-Rare-Elite` | Classic Frames TargetFrame.lua 204, 216, 228 |
| Main minimap ring | `Interface\Minimap\UI-Minimap-Border` | ClassicUI 2644; Blizzard Classic Minimap.xml 216 |
| Health/power fill | `Interface\TargetingFrame\UI-StatusBar` | Classic Frames CastBar.lua 108 and PlayerFrame.lua 122 |
| Cast border | `Interface\CastingBar\UI-CastingBar-Border-Small` | Classic Frames CastBar.lua 23; verify desired Vanilla variant |
| Tracking-button border | `MiniMap-TrackingBorder.blp` in addon resources | Both ClassicUI and Classic Frames package this; investigate native availability separately |

Blizzard reference snapshot: [Classic source at ecadf9d](https://github.com/Gethe/wow-ui-source/tree/ecadf9d3326fa87828cacca7f13c0ab5f41840a6/Interface/AddOns). Relevant files: `Blizzard_ActionBar/Classic/MainMenuBar.xml`, `Blizzard_UnitFrame/Classic/PlayerFrame.xml`, `Blizzard_UnitFrame/Classic/TargetFrame.lua`, and `Blizzard_Minimap/Classic/Minimap.xml`.

The pinned [Retail MainActionBar.xml](https://github.com/Gethe/wow-ui-source/blob/4e3cbb8c5609e4bfc332c0aebbfa4d79731fab59/Interface/AddOns/Blizzard_ActionBar/Mainline/MainActionBar.xml#L98) uses `ui-hud-actionbar-gryphon-left` and `ui-hud-actionbar-gryphon-right`. Those are modern alternatives and must not silently replace the original gryphons when exact fidelity is required.

## 5. What the published policies establish

[Blizzard's WoW addon policy](https://eu.forums.blizzard.com/en/wow/t/wow-user-interface-add-on-development-policy/1642) governs free, visible addon distribution, requires compliance with its other terms, and gives Blizzard control over addon functionality. Its copyright warning specifically concerns music/audio redistribution. That is relevant context but is not a texture-specific ruling. The page lists `WoWUI@blizzard.com` for policy questions; this investigation did not verify whether that older contact is still monitored.

The [Blizzard EULA](https://www.blizzard.com/en-us/legal/08b946df-660a-40e4-a072-1fbde65173b1/blizzard-end-user-license-agreement) has broad copying/derivative-work restrictions; another indexed [official version](https://www.blizzard.com/en-us/legal/bfbbb648-bcc6-4b78-a5c7-e2fe20c135df/blizzard-end-user-license-agreement) identifies artwork among Blizzard-owned/licensed content. Direct legal-page retrieval returned HTTP 403; the clauses were available through indexed official excerpts. This is not a complete review of the agreement applicable to the user's region or Forever.

The indexed [Blizzard Legal FAQ](https://www.blizzard.com/tr-tr/legal/c1ae32ac-7ff9-4ac3-a03b-fc04b8697010/blizzard-legal-faq) discusses limited use/display of website downloads and fansite content. It does not establish that credit alone authorizes a publicly downloadable pack of extracted game UI files. Its age and scope limit its usefulness here.

[CurseForge moderation rules](https://support.curseforge.com/support/solutions/articles/9000197279) require adherence to game terms and appropriate rights for copyrighted content. Hosting of existing addons is practical evidence of distribution, not a published asset license from Blizzard.

Consequently: attribution is appropriate but does not itself grant redistribution rights. Public availability does not tell us whether an author has separate permission. Conversely, we should not label existing authors' work unlawful without the relevant facts. This report gives research findings, not a legal opinion on their packages.

## 6. Changes to the engineering approach

1. Make original-art fidelity an explicit acceptance criterion. Do not generate substitute artwork or silently select a modern design.
2. Build a small in-game asset gallery showing every candidate at its intended size, crop and orientation. Record client build and screenshots before marking it runtime-confirmed.
3. Correct diagnostics first: `Core/Assets.lua` currently returns any configured path, and `/cf assets` labels that `OK`. This checks configuration, not image availability. Use separate statuses for configured, reference-confirmed and runtime-verified; verify any probing API against client documentation.
4. Correct catalogue roles: the main-bar entries currently point to an endcap, and the main minimap entry points to a tracking-button border. Research has now identified the appropriate candidates above.
5. Implement the bar and gryphons, then player/target borders using these original texture references and independently authored layout logic. Preserve the client-required protected interaction and combat behavior.
6. For each unresolved visual, check alternate paths, FileDataIDs and atlas crops before concluding the image is absent. Source-reference absence does not prove a file is missing from game data.
7. For any asset that genuinely must be packaged, record original source/build, modification status and permissions separately from our MIT code. Retain the current no-unreviewed-art publishing rule until that particular question is resolved.
8. When Forever becomes inspectable, repeat the same gallery and interaction tests. Retail lineage improves the starting point but does not guarantee identical artwork or APIs.

If distribution permission remains necessary, the concrete question for Blizzard is: May a free, publicly distributed WoW addon include these specifically identified, unmodified Classic UI texture files solely for rendering a Classic interface inside official Retail/Forever clients, with Blizzard attribution and no claim that our code license covers the artwork? No message was sent as part of this research.

## Limitations and decision

No current Retail/Classic game was launched; no Forever files were inspected; no screenshots or decoded-pixel comparisons were made; and no bundled third-party texture was established to be byte-identical to a named Blizzard build. Research branches may move, so source conclusions above use pinned revisions.

There is enough evidence to proceed with an original-art prototype now. There is not enough evidence to promise every Vanilla visual is resident in Forever, or to claim unrestricted permission to redistribute all extracted textures. These are narrower open questions than the earlier claim that faithful reproduction would require replacement art.
