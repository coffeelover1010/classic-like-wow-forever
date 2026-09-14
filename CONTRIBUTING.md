# Contributing

Thank you for helping with ClassicForeverUI.

Before submitting code, keep client-specific behavior behind `Core/Environment.lua`, `Core/API.lua`, or `Core/Assets.lua`; do not add extracted Blizzard artwork; and document any verified source/client claim in `Research/` with the source revision and path.

Use small, focused commits. Test `/cf diagnostic` on each available client and include its relevant output with compatibility reports. Do not copy third-party addon code or assets unless its license is explicitly compatible and recorded in `Research/ThirdPartyAddons.md` and `LICENSE-NOTES.md`.
