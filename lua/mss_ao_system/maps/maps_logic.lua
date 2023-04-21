
--------------------------------------------------------------
--					MSS  AO  MAPSCRIPT						--
--					By Agent Smith							--
--  https://steamcommunity.com/profiles/76561197990364979	--
--------------------------------------------------------------

if SERVER then 

hook.Add("AOSystemTrigger", "MSS.AOTriggersNew", function(Signal,Train)

	if AOSystem.IsDisabled() then 
		for k, v in pairs(AOSystem.Stations) do
			v.enabled = false
		end
		return 
	else
		for k, v in pairs(AOSystem.Stations) do
			v.enabled = true
		end
	end
	
	local checksignals
	local station
	local tbl
	local ply

	for k, v in pairs(AOSystem.Stations) do
		if v.enabled == false then continue end
		if v.aotype == "standard" then
			if Signal.Name == v.trigger then
				checksignals = v.depsignals
				if Signal.Occupied then 
					if not AOSystem.CheckDependSignals(checksignals) then return end
					if v.opened == false then
						AOSystem.OpenRoute(v.aoroute)
						v.opened = true
					end
				else
					v.opened = false
				end
			end
		end
		if v.aotype == "by-block-sections" then
			if Signal.Name == v.trigger then
				checksignals = v.depsignals
				if AOSystem.GetSignalFreeBS(v.trigger) < v.blocksections and AOSystem.RouteIsOpened(v.deproute) then 
					if not AOSystem.CheckDependSignals(checksignals) then return end
					if v.opened == false then
						AOSystem.OpenRoute(v.aoroute)
						v.opened = true
					end
				else
					v.opened = false
				end
			end
		end
		if v.aotype == "zone_int" then
			if Signal.Name == v.trigger then
				if Signal.Occupied then 
					if IsValid(Train) then 
						station = Train:ReadCell(49160)
						tbl = AOSystem.GetLastStationID(Train)
						ply = AOSystem.GetTrainDriver(Train)
					end
					if station == tbl or AOSystem.GetSignalFreeBS(v.checksignal) < v.blocksections then
						checksignals = v.depsignals_alt
						if not AOSystem.CheckDependSignals(checksignals) then return end
						if v.opened == false then
							AOSystem.OpenRoute(v.aoroute_alt)
							v.opened = true
							ply:ChatPrint("Высаживайте пассажиров и следуйте под оборот.")
						end
					elseif station != tbl then
						checksignals = v.depsignals_main
						if not AOSystem.CheckDependSignals(checksignals) then return end
						if v.opened == false then
							AOSystem.OpenRoute(v.aoroute_main)
							v.opened = true
							ply:ChatPrint("Следите за сигналом! Отправляйтесь по готовности.")
						end
					end
				else
					v.opened = false
				end
			end
		end
		if v.aotype == "zone_out" then
			if Signal.Name == v.trigger then
				checksignals = v.depsignals
				if IsValid(Train) then
					ply = AOSystem.GetTrainDriver(Train)
				end
				if Signal.Occupied and AOSystem.GetSignalFreeBS(v.checksignal) > v.blocksections then 
					if not AOSystem.CheckDependSignals(checksignals) then return end
					if v.opened == false then
						AOSystem.OpenRoute(v.aoroute)
						v.opened = true
						timer.Simple(5, function() ply:ChatPrint("Отправляйтесь по готовности \nили закройте маршрут "..v.aoroute) end)
					end
				else
					v.opened = false
				end
			end
		end
		if v.aotype == "reset" then
			if Signal.Name == v.trigger then
				if Signal.Occupied and AOSystem.RouteIsOpened(v.deproute) then 
					if v.opened == false then
						timer.Simple(5, function() AOSystem.CloseRoute(v.aoroute) end)
						v.opened = true
					end
				else
					v.opened = false
				end
			end
		end
	end
end)
end