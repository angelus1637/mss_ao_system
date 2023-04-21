return
--[[if CLIENT then return end
local CATEGORY_NAME = "Metrostroi"

ULib.ucl.registerAccess("ao_system_settings", ULib.ACCESS_ADMIN, "AOSystem Settings", CATEGORY_NAME)
function AOSystem.AccessGranted(ply)
	if (IsValid(ply) and ULib.ucl.query(ply,"ao_system_settings")) then
		return true
	else
		return false
	end
end ]]