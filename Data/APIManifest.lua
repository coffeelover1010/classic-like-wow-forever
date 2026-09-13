local _, CF = ...
CF.APIManifest = {
  { name="UnitHealth", module="API", purpose="unit health", retail="expected", classic="expected", secure=false, forever="validate", fallback="disable dependent visual" },
  { name="UnitPower", module="API", purpose="unit power", retail="expected", classic="expected", secure=false, forever="validate", fallback="disable dependent visual" },
  { name="UnitName", module="API", purpose="unit name", retail="expected", classic="expected", secure=false, forever="validate", fallback="empty label" },
  { name="UnitLevel", module="API", purpose="unit level", retail="expected", classic="expected", secure=false, forever="validate", fallback="hide level" },
  { name="C_Texture.GetAtlasInfo", module="Assets", purpose="atlas probing", retail="expected", classic="validate", secure=false, forever="validate", fallback="texture path or nil" },
  { name="InCombatLockdown", module="API", purpose="protected-frame guard", retail="expected", classic="expected", secure=true, forever="validate", fallback="defer mutation" },
}
