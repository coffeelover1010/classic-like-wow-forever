# Client test checklist: 0.10.0-alpha

This is the first in-game test, not a confirmed compatible release. No running Retail, Classic or Forever client has been tested. Allow two to three hours, or split these checks across sessions. Keep screenshots and a pass/fail note for each section.

## 1. Install and record the build

1. Close the game. Extract the ZIP's ClassicForeverUI folder into the chosen client's Interface/AddOns folder.
2. Check that ClassicForeverUI.toc is directly inside that folder. Enable the addon at character selection. Disable other addons that move or skin the same frames.
3. Record the actual build, Interface and project ID:

```text
/run local v,b,d,i=GetBuildInfo(); print("Version",v,"Build",b,"Interface",i,"Project",WOW_PROJECT_ID)
/console scriptErrors 1
/cf environment
/cf diagnostic
/cf assets
/cf api
/cf frames
/cf report
```

Copy the report with Ctrl+A, Ctrl+C. Keep the actual build numbers; do not infer Forever's project ID. If modules say CLIENT_NOT_ENABLED, use `/cf enable` or **Try this session**. This trial is session-only. If the TOC is rejected, rebuild with `Tools/package_addon.py --interface OBSERVED_NUMBER --output dist-beta` using the observed number.

## 2. Settings and textures

- Open `/cf`. Inspect all **38 choices** on **Layout & windows** and **More features**. Switch pages, drag, close with Escape and reopen. Check text and bottom buttons at small and large UI scales.
- Toggle a feature on each page. Turn the main switch off/on; choices must stay saved. Use `/cf module MailWindow off` while settings is open; the checkbox must follow. Reload and verify saved choices.
- Chat input starts off. Enable it deliberately for the chat checks, then restore your preferred choice. A saved chat opt-in must survive reload.
- Try View textures, Open report and Retry changes. If available, Settings > AddOns > ClassicForeverUI must open the same window.
- In `/cf gallery`, inspect every page: bar, gryphons, unit art, minimap, cast surrounds, quest/talent Up/Down/Disabled states, slot crops, character/quest/spellbook paper and trim. Blank or green textures are failures even if LOAD_ACCEPTED appears. EndCap-Dwarf is the gryphon; EndCap-Human is a lion.

## 3. Mail, trade, inspect and trainer

- Open inbox, switch to Send, then open received mail. Check scrolling, long subjects, stationery, invoices, sender names, attachments, COD, money, tabs and close buttons. Trim must not cover content or the send/return/delete controls.
- In a controlled test with mail you are willing to send, verify sending, reply, attachment pickup and return behavior. Automated checks made no mail changes; these are user-run checks.
- Trade with a willing partner. Inspect both item lists, enchant slots, money and acceptance colors. Change an item after accepting and verify native acceptance resets. Cancel, reopen and complete only a trade you intend to make.
- Inspect another player. Switch supported tabs, examine item tooltips, rotate the model and close. Open a trainer with both available and unavailable skills; scroll and filter. Native rows, costs and train controls must remain readable.
- Toggle Mail, Trade, Inspect and Trainers separately. Test late first opening, close/reopen and reload. Record unsupported borders rather than forcing a custom window into the skin.

## 4. Loot and cast bars

- Loot one item, several items, money, currency and a quest item. Compare manual loot and auto-loot. Scroll a long list; watch removed/reused cards and closing animations. Quality/quest marks, highlights and click targets must stay native. Only outer strips should change.
- Target and focus units that cast and channel. Check interrupted and uninterruptible spells, shield, spark, flash, name and progress. Test empowered casts where exposed by the client. Native effects must remain visible above the surround.
- Change/clear target and focus during casts. Check bar placement with many auras, focus in both sizes, several UI scales and Edit Mode. Neither cast option should move its bar or read/change its duration.
- Toggle target and focus cast options independently, including in combat. Missing or changed cast structures must keep native art. Compare the player cast bar too.

## 5. Menu, bag and minimap details

- Open every menu panel and use keybindings. Quest and talent buttons get original normal, pressed and disabled art. Native hover/flash/tutorial states must remain visible. Newer menu controls and main-menu download status must keep their functions and state art.
- Toggle Menu artwork separately from menu placement. If Blizzard replaces an icon later, its update should win; `/cf refresh` can retry ordinary supported art.
- Open each bag including reagent. Check bag icons, circular masks, counts, quality, fly-in effects, expanded/collapsed states and the expand toggle. Bag artwork and bag placement must work independently.
- Check minimap zone text, clock, 12/24-hour and local/server time, alarm, tracking dropdown, zoom, mail, calendar, addon compartment and expansion button. Header and tracking trim must not cover glyphs or labels.
- Change available accessibility/theme settings. New guarded art should reveal custom native themes immediately, including during combat; all geometry/creation must wait until safe.

## 6. Bags, bank, merchant and character pages

- Open all individual bags, reagent and combined bags. Change bag sizes/modes, move windows and try fullscreen panels. Check four edge strips, titles, portrait corners and native backgrounds. Backgrounds and curved portrait art are intentionally retained.
- With Item slots enabled, test empty/filled slots, search/filter shading, sorting, drag/drop, split stacks, shift-click links, quality, counts, cooldowns, quest marks, junk/upgrade/new-item glows and comparisons. New/reused pool entries must have one border, never duplicate art.
- Switch character/account bank tabs, including locked/purchase tabs. Test sorting, deposit rules, money and prompts only as intended. Changing tabs must hide old item trim and discover new slots. Guild/legacy banks stay native.
- Switch merchant pages and buyback. Check money/extra-currency insets and item borders. Buy, sell, repair and buy back only items you intend to use for the test; automated checks made no transactions.
- Open the character equipment page. Check every gear slot, empty slots, weapons, quality, cooldowns, sockets, flyouts, outfits, model, stats and titles. Equip/drag items and inspect tooltips.
- Switch reputation/currency tabs and expand rows. Scroll and inspect standing colors, progress, watched currencies and transfer controls. CharacterPages art must follow the active page and not cover pooled rows. Toggle Character and Other pages separately.

## 7. Focus, pet, target-of-target and groups

- Set/change/clear focus and its target. Test full-size and compact focus, their independent choices, scale/position changes and right-click menus. Compact mode uses thin trim; full-size focus uses the existing skin. Neither should leak art into the other mode.
- Summon/dismiss/revive/change pets; change targets with and without their own targets. Check native health, power, portraits, names, auras, click targeting and predictions. Fuller pet/target-of-target replacements are deferred.
- Take damage and receive heals/shields on player, target and focus. Inspect incoming healing, absorb/over-absorb, heal absorbs, temporary health loss and text. Repeat in a vehicle where possible.
- Party, raid and boss skins remain deferred. Verify their native health, prediction, aura, private-aura, selection/aggro, role and encounter indicators remain unchanged with the addon enabled. Do not treat exterior focus trim as a group-frame implementation.

## 8. Chat and earlier features

- Enable Chat input. Type an unsent draft; switch channels/windows, focus/blur, dock/undock and resize. Text must not change or send by itself. Test Enter/Escape and native focused border states. Disable trim and confirm draft/state preservation. Native tabs/backgrounds remain.
- Test all action buttons, keybindings, paging, forms, stances, vehicles, override bars and pet battles where relevant. Compare default restoration.
- Open the spellbook in small/large views; search, change categories/pages, drag spells and inspect passives, cooldowns, pet autocast and flyouts. Talents/spec panes stay native.
- Open quest offers, progress and turn-ins; scroll long text, inspect/select item rewards and test dialogue choices. Quest material and contrast changes must reveal the correct native background. Maps, spell rewards and custom dialogue stay native.
- Gain/lose buffs and debuffs; check timers, counts, dispel colors, enchant overlays and right-click removal. Private anchors stay native. Test tooltip comparisons, item links and long/embedded content. Tracker rows, quest items, filters and collapse controls must work.
- Check XP/rested XP and watched faction bars. Native tracking rules still decide which bars appear.

## 9. Combat, Edit Mode and recovery

- During combat toggle a new window/item feature and `/cf off`. Status must show Queued. Native layout/restoration and new textures wait until combat ends. Native theme changes can hide addon art immediately.
- Leave combat and verify the requested state. Open Edit Mode: stock layout should return before saving. Move/scale frames, save/cancel, exit and check addon reapplication. Disable the addon again and verify your saved native layout.
- Reload and check saved choices, open windows and all new features. Repeat after vehicle/override transitions and at more than one UI scale.
- Capture `/cf report`, build numbers, the first Lua/blocked-action error and screenshots with other UI addons disabled. Mock tests cannot prove taint, protected operations or rendered layers.

Restore with `/cf off`, then `/reload`. If commands fail, disable ClassicForeverUI at the AddOns screen. No game archives, bindings, CVars or saved Edit Mode layouts are written by the addon. Restore your previous script-error setting after collecting errors.
