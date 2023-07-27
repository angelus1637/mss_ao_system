local CATEGORY_NAME = "Metrostroi"

AOSystem = AOSystem or {}
function AOSystem.AccessGranted(ply)
	if not IsValid(ply) then return false end
	if (ply:IsAdmin() or ply:GetNW2Bool("MDispatcher") or ULib.ucl.query(ply, "ulx disp") or ULib.ucl.query(ply, "ulx mssao")) then
		return true
	else
		return false
	end
end

function ulx.mssao(calling_ply)
	AOSystem.ShowMenu(calling_ply)
end
local mssao = ulx.command(CATEGORY_NAME,"ulx mssao",ulx.mssao,"!mssao")
mssao:defaultAccess(ULib.ACCESS_ADMIN)
mssao:help("Меню автооборотов")