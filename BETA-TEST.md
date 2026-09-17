# Forever beta test: 0.5.0-alpha

Allow about 65 minutes. This is the first in-game test, not a confirmed compatible release.

## 1. Install and collect the build (5 minutes)

1. Close the game.
2. Extract the ZIP's **ClassicForeverUI** folder into the **beta client's** `Interface/AddOns` folder.
3. Check that `ClassicForeverUI.toc` is directly inside that folder.
4. Start the beta. Enable ClassicForeverUI and temporarily disable other addons that move bars or unit frames.
5. Enable **Load out of date AddOns** if that option is available.

If the addon does not appear or load, record this from chat:

```text
/run local v,b,d,i=GetBuildInfo(); print("Version",v,"Build",b,"Interface",i,"Project",WOW_PROJECT_ID)
```

Keep the actual numbers. Do not infer Forever's project ID from Retail. A package can be rebuilt with that Interface number using `Tools/package_addon.py --interface NUMBER --output dist-beta`.

## 2. Collect a baseline (5 minutes)

After entering the world:

```text
/console scriptErrors 1
/cf environment
/cf diagnostic
/cf assets
/cf api
/cf frames
/cf report
```

Click inside the report, press **Ctrl+A**, then **Ctrl+C**. Paste it into a local text file or this Codex task. The latest report also saves in `ClassicForeverUIDB.lastReport` after logout or `/reload`. It contains build and compatibility data, not unit names or health values.

If modules say `CLIENT_NOT_ENABLED`, use:

```text
/cf enable
```

This opts into visual trials for the current session. Unknown and Classic clients return to diagnostic-only mode on the next login. Recognized Retail defaults to applying the layout.

## 3. Settings window (5 minutes)

1. Type `/cf`. Check the main switch and fourteen feature rows. Labels should be readable at your UI scale.
2. Turn the minimap off and on using its row. Check both the saved checkbox and the visible border. Turn another feature off, then turn the main switch off and on; your individual choices should stay saved.
3. Type `/cf module Minimap off` while settings is open. Its checkbox and status should update. Turn it back on in the window.
4. Drag the window, close it with Escape, and reopen it with `/cf config`. Check that it fits your screen.
5. Try **View textures**, **Open report**, and **Retry changes**. The report should support Ctrl+A, Ctrl+C.
6. If available, open **Settings > AddOns > ClassicForeverUI > Open settings**. It should open the same window.
7. Turn one feature off, `/reload`, and check that it is still off. Restore your preferred choice.
8. During the later combat test, change a checkbox. It should show **Queued** and apply after combat ends.

On an unrecognized client, changing the main switch does not start a trial. Use **Try this session** or `/cf enable` explicitly. A trial must be started again after `/reload`.

## 4. Check artwork (5 minutes)

```text
/cf gallery
```

Use **Next page** to inspect every texture. Check the original stone, both gryphons, unit borders, elite variants, minimap ring, cast border, and spellbook paper, trim and icon, plus the tooltip border and background. Blank or green areas are failures even if a texture says `LOAD_ACCEPTED`. Take screenshots of failures and note the asset name.

The gryphon path ends in **EndCap-Dwarf**. **EndCap-Human** is a lion. No modern gryphon atlas is used as a hidden fallback.

## 5. Test the main controls (10 minutes)

- Click each main action button and try its normal keybind. Check cooldowns, counts and hotkey labels.
- Drag a spell onto a slot outside combat. Change action pages with the arrows and keybinds.
- If your class has forms or stances, switch them and check the spells on the main bar.
- Target yourself, a friendly player and a hostile creature. Left-click targeting and right-click menus must work.
- Watch health and power change. Check the target portrait, name, level and elite border.
- Check the minimap: zoom, tracking, right/left clicks, mail and utility buttons.
- Open each micro menu panel and each bag, including the reagent bag if present.
- On a character that can gain XP, check rested XP and the XP tooltip. Track a faction and check its bar. Native tracking rules decide which bars are shown.
- Cast, interrupt and channel a spell. Test an empowered spell if your class has one.

## 6. Spellbook (5 minutes)

1. Open the spellbook. Its module may report `UNAVAILABLE` until this loads Blizzard's spellbook addon.
2. Check the parchment, metal edges, book icon and spell-slot borders. Try both small and large views and check text at your normal UI scale.
3. Switch class, general and pet categories where available. Search for a spell, clear the search, and turn pages. Check that new entries receive borders.
4. Hover spells, drag one to an action slot and try a spell flyout. Check passive and unlearned spells, cooldowns and pet autocast indicators. Native state markers should remain visible.
5. Switch to talents and specialization. Their artwork should remain unchanged.
6. Run `/cf module SpellBook off`. The original book should return at its current size. Run `/cf module SpellBook on` to restore the skin.
7. If the client permits opening the book in combat, change a category or page. Any new borders should wait until combat ends. Record any blocked-action error.

The skin keeps Retail's spell layout and controls. It does not rebuild Vanilla's twelve-spell pages.

## 6a. Health indicators, auras, tooltips and tracker (10 minutes)

1. With player and target skins on, take damage and receive a cast heal and a shield. Check incoming healing, absorbs, over-absorb glow, heal absorbs, temporary health loss and health text where available. Compare with each skin off. Native full-height health must remain readable above the Classic border; power must not cover it. Repeat on a friendly target and in a vehicle.
2. Gain and lose buffs and debuffs. Check timers, counts, dispel colors, enchant borders, fading and right-click cancellation. Fill more than one row, collapse/expand buffs, and change aura size/direction in Edit Mode. Private auras must remain native.
3. Hover units, spells and bag items. Open a chat item link and comparison tooltips. Check long text, inserted item content, screen-edge positioning and embedded tooltips. The new border is gray; item names should retain their native colors.
4. Track and untrack quests. Collapse/expand and filter the tracker. Click a quest and use its quest item, including during combat. Resize/move it in Edit Mode. Only the top header should look different.
5. Toggle Buffs, Debuffs, Tooltips and Quest tracker separately in settings. Check native art returns. Repeat a toggle during combat; it should apply after combat. Reload and verify each saved choice.

## 7. Combat, vehicles and Edit Mode (10 minutes)

1. Enter a short fight. Use action keybinds, change target, and watch both unit bars.
2. During combat run `/cf off`. It should queue restoration without moving protected frames.
3. Leave combat. The original UI should return. Run `/cf on` outside combat.
4. If available, enter and leave a vehicle or override-action quest. Check action paging and exit controls. Test a pet battle if relevant.
5. Open Edit Mode. The stock layout should return while it is open.
6. Move a frame, save or cancel, then close Edit Mode. The addon layout should return.
7. Run `/cf off` again. Your saved Blizzard layout should be restored.
8. Run `/cf on`, then `/reload`. Repeat one action and one target interaction.

Combat taint cannot be proved by offline mocks. If a protected action is blocked, keep the exact error, activity and client build. Test again with only this addon enabled.

## 8. Report and recover (5 minutes)

```text
/cf report
```

Send the copied report, the first Lua error if any, screenshots of visual problems, and which steps passed or failed. Reports use honest states: `APPLIED_UNVERIFIED` is not a compatibility certificate.

To isolate a problem:

```text
/cf module PlayerFrame off
/cf module TargetFrame off
/cf module ActionBars off
/cf refresh
```

Use only the module command needed. `refresh` retries failed modules; it waits until combat ends.

To restore everything:

```text
/cf off
/reload
```

If slash commands fail, disable ClassicForeverUI in the AddOns screen and reload or restart. Removing the ClassicForeverUI folder also removes all its UI changes on restart. No game archives, bindings, Edit Mode saved layout data or CVars are changed by the addon.

After collecting errors you can restore your previous script-error setting, usually:

```text
/console scriptErrors 0
```
