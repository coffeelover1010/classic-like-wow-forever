# Blizzard Classic UI research

Primary reference: [Gethe wow-ui-source, `classic` branch](https://github.com/Gethe/wow-ui-source/tree/classic). The branch is a source mirror; inspect the exact revision used and record it alongside generated manifests. Candidate areas include `Interface/FrameXML` and `Interface/AddOns/Blizzard_ActionBar` where present.

Initial feature map is intentionally unfilled. Generate it from a local source checkout before implementing visuals: action bars and endcaps; PlayerFrame, TargetFrame, FocusFrame and party/pet frames; Minimap; aura and cast frames; XP/reputation; micro menu/bags; panels, tooltip and quest tracker.

Source-provenance rule: each implemented feature must name its Lua/XML/TOC source, frames/templates, events/APIs, texture/atlas/font candidates, and secure-frame constraints in a committed research update.
