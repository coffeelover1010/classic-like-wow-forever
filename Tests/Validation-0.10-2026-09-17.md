# 0.10.0-alpha validation record

Date: 17 September 2026. This records offline engineering checks. **No running
Retail, Classic or Forever client was tested.**

## Baseline and scope

- Started from clean main at `948938a05c5f02d2eeaa083e733479244f6e3a7d`, matching
  origin/main. All 91 existing regression cases passed before editing.
- Reverified Retail source `4e3cbb8c5609e4bfc332c0aebbfa4d79731fab59` and Classic
  source `ecadf9d3326fa87828cacca7f13c0ab5f41840a6` in local research checkouts.
- Every requested area has a result in HANDOFF.md. Research/Implementation.md
  records exact frame/template contracts and source-based deferrals.
- Added 15 independently configurable features, bringing settings to 38 choices
  across two pages. Generic Panels remains deferred. ChatStyle starts off.

## Automated checks

`Tests/run_tests.py` passed all **116 regression cases** using test-only lupa's
Lua 5.1 runtime. The runner also compiled/executed all **55 TOC Lua files** and
confirmed every configured original-art path appears in the local inventory.
The final run includes the source-shaped merchant money and buyback fixtures.

The 25 new cases cover:

- Native transaction, click, drag, cast, chat and pooled-row state preservation.
- Exact owners, missing parts, load-on-demand discovery and narrow wake events.
- Secret sentinels, changed atlas/tint/alpha, combat deferral and Edit Mode.
- Cast shield/spark/flash ownership and native size/position preservation.
- Quest/talent normal/pressed/disabled rollback, newer native themes and partial
  crop failures. Native highlight/alert state is unchanged.
- Bag masks and state art, minimap utility/clock state, page visibility and
  compact/full focus transitions.
- Bag/bank pool growth, reuse/release, stale callbacks and safe delayed creation.
- Saved default-off chat choices, both settings pages, partial hook registration,
  missing hooks/art and isolated failure recovery.

Existing cases still cover earlier bars, native health predictions, unit frames,
spellbook, dialogues, character sheet, windows, settings and restoration.
`git diff --check` passed. Test fixtures model pinned sources; they cannot prove
taint, protected behavior, secret restrictions or actual event delivery.

## Visual and local asset checks

Rendered and inspected:

- `dist/settings-0.10-layout.png` and `dist/settings-0.10-more.png`: labels,
  checkboxes, page selection and bottom controls fit the window. The previews
  intentionally show unavailable modules absent from the base mock.
- `dist/features-0.10.png`: original micro state art, tracking ring, cast/slot
  crops and header/chat strips. Native fill/icons are labeled placeholders.
- `dist/windows-0.10.png`: four bag edges and standard inset crop composition.

These are offline compositions with approximate geometry/fonts, not game
screenshots. Crop inspection corrected transparent padding in the cast and slot
surrounds. Native layering, scale, overlap and state transitions need client tests.

Read-only extraction from local Era **1.15.9.69722** added four Quest/Talents
Down/Disabled paths. All decoded, and size/hash rows were appended to
Research/LocalAssetInventory.csv. Existing paths were re-read outside the repo.
No Anniversary or Retail extraction claim is made for these new states.

## Install package

`Tools/package_addon.py` built and reopened:

`dist/ClassicForeverUI-0.10.0-alpha.zip`

It verified archive integrity and byte-for-byte equality for the complete
allowlist: **60 files**, comprising 55 Lua files, the TOC and four documents.
Every member is below `ClassicForeverUI/`. No extracted images, native libraries,
tests, research files or previews are installed.

SHA-256:

```text
504eb5f4b0cc5887ff6a124c202dadd238c501cc1a8f9bc22c702c3ce3faf72b
```

The checksum sidecar is beside the ZIP. Dist artifacts are intentionally ignored
by Git. The final task response records the resulting commit and remote check.

## Remaining validation

Follow BETA-TEST.md in the actual client. Prioritize visibility and layering,
native input/actions, shield and prediction indicators, pooled items, focus size
changes, chat drafts, combat/Edit Mode, accessibility themes and reloads.
`APPLIED_UNVERIFIED` and accepted texture paths remain unverified statuses.
Full party/raid/boss skins, curved portrait replacements, fuller small-unit skins
and generic Panels are deferred. Website source was updated; hosting repair is
not part of this pass and is not claimed.
