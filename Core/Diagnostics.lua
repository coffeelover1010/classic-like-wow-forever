local _, CF = ...
CF.Diagnostics = {}
local function say(message) DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99ClassicForeverUI|r " .. message) end
local function availability(value) return value and "OK" or "MISSING" end

function CF.Diagnostics:Environment() say(CF.Environment:Summary()) end
function CF.Diagnostics:Assets()
  for id, asset in pairs(CF.AssetCatalogue) do
    local found = CF.Assets:Get(id)
    say(string.format("%s: %s (%s)", id, availability(found), asset.source))
  end
end
function CF.Diagnostics:API()
  for _, item in ipairs(CF.APIManifest) do
    local root, member = item.name:match("^([%w_]+)%.([%w_]+)$")
    local available = member and _G[root] and type(_G[root][member]) == "function" or type(_G[item.name]) == "function"
    say(item.name .. ": " .. availability(available))
  end
end
function CF.Diagnostics:Frames()
  for _, item in ipairs(CF.FrameManifest) do
    local frame = _G[item.name]
    say(string.format("%s: %s%s", item.name, availability(frame), frame and CF.Compat:IsSecureFrame(frame) and " (protected)" or ""))
  end
end
function CF.Diagnostics:Full()
  say("Diagnostics")
  self:Environment(); self:Assets(); self:API(); self:Frames()
  for name, module in pairs(CF.Modules) do say(name .. ": " .. (module.Ready == false and "NEEDS ADAPTATION" or "READY")) end
end

SLASH_CLASSICFOREVERUI1 = "/cf"
SlashCmdList.CLASSICFOREVERUI = function(message)
  local command = (message or "diagnostic"):lower():match("%S+") or "diagnostic"
  local actions = { diagnostic="Full", assets="Assets", api="API", frames="Frames", environment="Environment" }
  if actions[command] then CF.Diagnostics[actions[command]](CF.Diagnostics) else say("Commands: diagnostic, assets, api, frames, environment") end
end
