if CLIENT then return end
local CATEGORY_NAME = "Metrostroi"

AOSystem = AOSystem or {}
function AOSystem.AccessGranted(ply)
	if not IsValid(ply) then return false end
	if (ply:IsAdmin() or ply:GetNW2Bool("MDispatcher") or ULib.ucl.query(ply, "ulx disp")) then
		return true
	else
		return false
	end
end