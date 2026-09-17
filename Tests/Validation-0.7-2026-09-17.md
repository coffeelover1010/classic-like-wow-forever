# 0.7.0-alpha offline validation

- Baseline main was clean at 54a5f2ceca0cf1847236d3dc26a4f787ea85da32.
- Pinned Retail 4e3cbb8c5609e4bfc332c0aebbfa4d79731fab59 and Classic
  ecadf9d3326fa87828cacca7f13c0ab5f41840a6 verified locally.
- 64 isolated Lua 5.1 regression cases; all 35 TOC Lua files compile/load.
- Tests use bundled Python with test-only lupa through cf-ui-research/python-tools.
- Four Era quest sheets freshly extracted, hashed, decoded and inspected outside
  the repository. Catalogue asset inventory checks pass. No new Anniversary or
  button-path extraction is claimed.
- Settings preview (700x870, nineteen choices) and quest/gossip crop composition
  inspected. Font metrics and dialogue geometry are approximate.
- Versioned ZIP uses the TOC/document allowlist: 40 files, no artwork or research
  dependencies. Packaging checks archive integrity and every member's bytes.
- No Retail, Classic or Forever client was run. Beta rendering, accessibility,
  secure interactions, taint, reward updates and reload persistence remain pending.
