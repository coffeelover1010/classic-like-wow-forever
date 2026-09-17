local _, CF = ...
CF.FrameManifest = {
  { name="FocusFrame", use="full-size skin or optional passive compact trim; native focus-target trim and cast surround", protected="runtime-probed" },
  { name="PetFrame", use="passive metal trim; all native bar descendants retained", protected="runtime-probed" },
  { name="PetFrameHealthBar", use="anchor only; native health and prediction engine", protected="runtime-probed" },
  { name="BuffFrame", use="passive borders on native auraFrames; private anchors untouched", protected="runtime-probed" },
  { name="DebuffFrame", use="passive borders; native dispel colors and durations", protected="runtime-probed" },
  { name="GameTooltip", use="Classic backdrop beneath native content", protected="runtime-probed" },
  { name="ItemRefTooltip", use="Classic backdrop; native links retained", protected="runtime-probed" },
  { name="ShoppingTooltip1", use="Classic comparison backdrop", protected="runtime-probed" },
  { name="ShoppingTooltip2", use="Classic comparison backdrop", protected="runtime-probed" },
  { name="ObjectiveTrackerFrame", use="header artwork only; native tracking and controls retained", protected="runtime-probed" },
  { name="PlayerSpellsFrame", use="spellbook-only passive artwork; loaded on demand", protected="runtime-probed" },
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
for _,name in ipairs({"MailFrame","OpenMailFrame","TradeFrame","InspectFrame","ClassTrainerFrame",
    "LootFrame","ReputationFrame","TokenFrame","QuestLogMicroButton","PlayerSpellsMicroButton",
    "TimeManagerClockButton","ChatFrame1EditBox"}) do
  CF.FrameManifest[#CF.FrameManifest+1]={name=name,use="scoped cosmetics; native controls and data retained",protected="runtime-probed"}
end
for i=2,11 do
  CF.FrameManifest[#CF.FrameManifest+1] = { name="ActionButton"..i,
    use="reversible position and size; passive border; native parent and secure attributes retained",
    protected="runtime-probed" }
end

for _,name in ipairs({"QuestFrame","QuestFrameDetailPanel","QuestFrameProgressPanel","QuestFrameRewardPanel","QuestFrameGreetingPanel","QuestInfoRewardsFrame","GossipFrame"}) do
  CF.FrameManifest[#CF.FrameManifest+1] = {name=name, use="scoped NPC parchment/inset/reward art; native controls retained", protected="runtime-probed"}
end

for _,name in ipairs({"CharacterFrame","PaperDollFrame","PaperDollItemsFrame"}) do
  CF.FrameManifest[#CF.FrameManifest+1] = {name=name, use="paper-doll-only passive background and trim; native controls retained", protected="runtime-probed"}
end

for _,name in ipairs({"ContainerFrame1","ContainerFrame2","ContainerFrame3","ContainerFrame4","ContainerFrame5","ContainerFrame6","ContainerFrameCombinedBags","BankFrame","MerchantFrame"}) do
  CF.FrameManifest[#CF.FrameManifest+1] = {name=name, use="scoped passive window border trim; native items and controls retained", protected="runtime-probed"}
end
