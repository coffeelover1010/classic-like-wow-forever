# Implementation and source evidence: 0.10 alpha

## Current scope

38 feature modules have settings; Panels is explicitly deferred. The TOC contains 55 Lua files. The offline Lua 5.1 suite has 116 cases. Settings use two three-column pages at 1034x798 with screen fitting. Historical release counts remain in CHANGELOG.md and versioned validation notes.

All code is independently authored. No ClassicUI, Classic Frames, KeyUI or DragonflightUI implementation was copied. Original Blizzard artwork uses in-client paths; research extracts stay outside the repository and ZIP. No AI images were used.

## Pinned source baseline

Reverified before this pass:

- [Retail 4e3cbb8](https://github.com/Gethe/wow-ui-source/tree/4e3cbb8c5609e4bfc332c0aebbfa4d79731fab59/Interface/AddOns)
- [Classic ecadf9d](https://github.com/Gethe/wow-ui-source/tree/ecadf9d3326fa87828cacca7f13c0ab5f41840a6/Interface/AddOns)

Paths below are relative to Interface/AddOns. Source and mocks support implementation choices; they do not establish a running-client result.

## 0.10 source contracts

| Area | Source | Implemented boundary |
|---|---|---|
| Mail | Blizzard_MailFrame/MailFrame.xml | MailFrame and OpenMailFrame inherit ButtonFrameTemplate. InboxFrame and SendMailFrame are MailFrame children. Shared Inset, SendMailMoneyInset and opened-mail Inset get overlays. Stationery, attachments, COD and all actions are excluded. |
| Trade | Blizzard_UIPanels_Game/Mainline/TradeFrame.xml | Six named recipient/player item, enchant and money insets. The source repeats parentKey LeftInset, so exact globals and parents are checked. Acceptance highlights and item rows remain native. |
| Inspect/trainer | Blizzard_InspectUI/Mainline/Blizzard_InspectUI.xml; Blizzard_TrainerUI/Mainline/Blizzard_TrainerUI.xml | Inherited inset skin; ClassTrainerFrame.bottomInset included. Models, rows, costs, filters and controls remain native. |
| Loot | Blizzard_UIPanels_Game/Mainline/LootFrame.xml and .lua; ScrollingFlatPanel.xml and .lua | ScrollingFlatPanelTemplate has ClosePanelButton, ScrollBox and ScrollBar, with ButtonFrameTemplateNoPortrait layout. Only four outer strips are added. Pooled card backgrounds/borders, quality stripe, quest mark, animation and item hit rectangles remain untouched. |
| Borders | Blizzard_SharedXML/Mainline/SharedUIPanelTemplates.xml; NineSliceLayouts.lua; Blizzard_SharedXML/NineSlice.lua | Known HeldBagLayout, InsetFrameTemplate and no-portrait atlases. Native inset is BORDER -5; overlay is BORDER -4. Outer strips use OVERLAY 1. Minimap Center defaults to BORDER; covering art uses BORDER 1. |
| Target/focus casts | Blizzard_UnitFrame/Mainline/TargetFrame.lua and .xml; Blizzard_UIPanels_Game/Mainline/CastingBarFrame.xml; Shared/CastingBarFrame.lua | CreateSpellbar creates a native child and assigns self.spellbar. SmallCastingBarFrameTemplate supplies Border, BorderShield, Icon, Text, Spark and Flash. UNITFRAME look sets 150x10 at runtime. Surround follows Border anchors, beneath native indicators. No cast-value reads or cast events are added. |
| Menu artwork | Blizzard_MicroMenu/Mainline/MainMenuBarMicroButtons.xml and .lua; Classic/MainMenuBarMicroButtons.lua | Questlog and SpecTalents use native Up/Down/Disabled state textures. The addon sets original Quest/Talents equivalents once per apply. Highlights, FlashBorder, tutorials and state/click logic remain native. Download status and newer functional icons are excluded. |
| Bag buttons | Blizzard_MainMenuBarBagButtons/Mainline/MainMenuBarBagButtons.xml; Blizzard_ItemButton/Mainline/ItemButtonTemplate.xml | Six named BagsBar children including reagent. Original surround stays below native icons, CircleMask, counts and state/fly-in effects. Expand toggle is excluded. |
| Minimap | Blizzard_Minimap/Mainline/Minimap.xml; Blizzard_TimeManager/Mainline/Blizzard_TimeManager.xml | BorderTop UniqueCornersLayout and texture kit checked. Header center/edges, clock underline and Tracking.Background-guarded ring only. Native zone text, clock/alarm, tracking and utility actions remain. |
| Items | Blizzard_UIPanels_Game/Mainline/ContainerFrame.xml and .lua; BankFrame.xml and .lua; MerchantFrame.xml; Blizzard_ItemButton/Shared/ItemButtonTemplate.xml | Bag Items arrays, active bank EnumerateValidItems iterator and twelve merchant buttons plus supported buyback. Native icon key is lowercase icon. Trim is BACKGROUND, below icon, search, quality, cooldown, context and quest overlays. Bank Background atlas is guarded. UpdateItemSlots and GenerateItemSlotsForSelectedTab post-hooks queue rediscovery. No item IDs, prices or contents are read. |
| Character pages | Blizzard_UIPanels_Game/Mainline/CharacterFrame.xml and ReputationFrame.xml; Blizzard_TokenUI/Blizzard_TokenUI.xml | ReputationFrame and TokenFrame are CharacterFrame children with their own ScrollBox/ScrollBar. Art belongs to each page and follows its visibility; background/inset anchors are shared. Faction/currency rows, colored bars and transfer controls stay native. |
| Chat | Blizzard_ChatFrameBase/Mainline/FloatingChatFrame.xml; ChatFrameEditBox.xml | Ten exact ChatFrameN.editBox globals with source focus regions. Exterior input strips only. Tabs/background/input already use older ChatFrame paths. ChatStyle defaults off and never reads/sends text. |
| Compact focus | Blizzard_UnitFrame/Mainline/TargetFrame.lua, FocusFrameMixin:SetSmallSize | Compact mode retains TargetFrameContentMain.HealthBarsContainer and ManaBar. Two exterior strips only. A secure post-hook hides trim and requests safe reapplication on size changes. Restricted smallSize fails closed. |
| Focus target | Blizzard_UnitFrame/Mainline/TargetFrame.xml and .lua | Native totFrame is a focus child. SmallUnitModule adds exterior health/power strips, preserving portrait, predictions, masks and native scale. |

## Deferred after source investigation

- Flat bag backgrounds use FlatPanelBackgroundTemplate and PANEL_BACKGROUND_COLOR. They are color-driven, not a stable original-art region. Replacing them before validating color/accessibility changes risks hiding native theme intent. Bag top edges are now supported.
- Portrait corners combine a high-level PortraitContainer, circular mask and native NineSlice corner. Original fixed-size character/quest sheets are not a proven fit. Keep native curved corners until screenshots and overlap tests support a crop.
- Full pet/target-of-target replacements use original UI-SmallTargetingFrame geometry that differs from modern health, masks and predictions. Existing exterior trim stays; no replacement is forced.
- Shared/PartyFrame.lua creates PartyMemberFramePool and MemberFrame keys dynamically. Mainline/PartyFrameTemplates.xml uses SecureFrameParentPropagationTemplate and HealthBarContainer predictions. Raid-style party uses CompactPartyFrame and another layout path. Both modes need client checks.
- Shared/CompactUnitFrame.xml combines private auras, heal/absorb textures, target/aggro highlights and protected clicks. Blizzard_CompactRaidFrames/Blizzard_CompactRaidFrameContainer.lua uses reservation managers and normal/mini/group flows rebuilt after Edit Mode. Decorative borders have no validated fit around those indicators.
- Boss1-5TargetFrame use BossTargetFrameContainer and specialized cast/widget/aura positioning in Mainline/TargetFrame.lua. Blanket target-skin reuse would alter health/layout assumptions. Boss skins need encounter checks.
- Guild/legacy banks, custom windows, generic Panels, newer menu icons and minimap notification art remain native. Full Vanilla pixel parity is not claimed.

## Lifecycle, themes and rollback

Modules initialize in TOC order with isolated Initialize, Enable, Disable and refresh calls. Partial failures hide tracked art and restore journaled properties. Runtime faults stop one module until explicit retry. Native mutations and restoration wait until InCombatLockdown returns false; missing combat support blocks changes. Edit Mode restores the native layout before editing and reapplies after exit.

PassiveSkin creates addon textures on exact owners, hides old art before selection, and reuses regions by identity. Known atlas, visibility, alpha and vertex-color changes are securely post-hooked; hooks only hide addon art immediately and queue a safe refresh. Restricted values are checked before comparison. WindowTrim follows readable native alpha and rejects tinted/changed borders. These helpers do not change native parents, scripts, hit rectangles, secure attributes or data.

MicroArtwork journals decorative texture/coordinates for two buttons. Native states select visibility. Rollback restores unchanged addon art, including partial failures, without overwriting later native atlas updates. It leaves newer native art in place until a normal apply/retry.

Unavailable modules can wake on narrow discovery events through RequestApply. Disabled/faulted modules cannot revive from discovery. Blizzard ADDON_LOADED remains the general retry. Item-generation hooks register once per owner/method and callbacks obey module state. No busy polling or frame-update loop was added.

## Retained earlier architecture

Action bars retain Blizzard buttons, secure paging and containers. Unit skins preserve full HealthBarsContainer, values, masks, incoming heals, shields, losses and text. Supported geometry and decorative alpha changes are journaled. Power/name values go directly to documented display sinks; no restricted health calculations exist. Class resources stay native.

Spellbook, quest and gossip helpers target known panels. Spellbook pools use source callbacks. Dialogue paper respects material/accessibility changes. CharacterWindow follows PaperDollFrame with passive backgrounds, inset and gear edges. Private aura anchors stay excluded. Tooltips use gray Classic backdrops below native content. XP/reputation selection and values remain native.

Options share slash controllers and saved preferences. ChatStyle's default-off value is filled only when no choice exists. Both pages separate checkbox intent from runtime status. Optional Blizzard Settings registration failures do not block the standalone window.

## Asset and test evidence

Four new quest/talent Down/Disabled paths were read from Era 1.15.9.69722 after checking build metadata. Existing art was re-read into cf-ui-research/feature-art-era-69722 outside the addon. LocalAssetInventory.csv records the new hashes. No Anniversary extraction claim is made for these states.

Small cast surrounds use measured alpha bounds (28,22)-(228,44) of the 256x64 sheet. Slot surrounds crop (12,12)-(51,51) of UI-Quickslot2, removing padding that would shrink trim under native icons. The tracking ring uses its occupied 40x40 area. Micro art crops transparent upper padding. These are implementation crops, not assertions of Vanilla geometry.

116 Lua 5.1 cases compile/execute 55 TOC files and cover failure isolation, native controls, pools, late discovery, opaque sentinels, themes, combat, Edit Mode, rollback, settings and retry. Both settings pages and original-art composition were inspected offline. Package verification compares 60 files against the source allowlist. See Tests/Validation-0.10-2026-09-17.md.

**No running client was tested.** Mocks, texture acceptance and extraction do not prove pixels, event delivery, protected behavior, taint, secret restrictions or Forever compatibility. BETA-TEST.md is the required next validation.
