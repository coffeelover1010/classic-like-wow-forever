# Frame map

`Data/FrameManifest.lua` tracks the initial inspected frames: `PlayerFrame`, `TargetFrame`, `FocusFrame`, `MainMenuBar`, `Minimap`, and `MicroButtonAndBagsBar`. Modules currently inspect only; protected frames must not be mutated in combat and should prefer overlays/hooks over replacement.
