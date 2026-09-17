local _, CF = ...
CF.FrameManifest = {
  { name="PlayerName", use="reversible alpha change", protected="runtime-probed" },
  { name="PlayerLevelText", use="reversible alpha change", protected="runtime-probed" },
  { name="MinimapBorder", use="optional reversible alpha change", protected="runtime-probed" },
  { name="UIParent", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="MainActionBar", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="ActionButton1", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="ActionButton12", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="MultiBarBottomLeft", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="MultiBarBottomRight", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="PlayerFrame", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="TargetFrame", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="MinimapCluster", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="Minimap", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="MinimapCompassTexture", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="MicroMenuContainer", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="MicroMenu", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="BagsBar", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="PlayerCastingBarFrame", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="MainStatusTrackingBarContainer", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="SecondaryStatusTrackingBarContainer", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
  { name="StatusTrackingBarManager", use="see Research/Implementation.md; no secure attribute, script or parent replacement", protected="runtime-probed" },
}
for i=2,11 do
  CF.FrameManifest[#CF.FrameManifest+1] = { name="ActionButton"..i,
    use="reversible position and size; passive border; native parent and secure attributes retained",
    protected="runtime-probed" }
end
