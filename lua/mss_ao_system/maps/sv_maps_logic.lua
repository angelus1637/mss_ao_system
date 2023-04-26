
--------------------------------------------------------------
--					MSS  AO  MAPSCRIPT						--
--					By Agent Smith							--
--  https://steamcommunity.com/profiles/76561197990364979	--
--------------------------------------------------------------

if CLIENT then return end

hook.Add("AOSystemTrigger", "MSS.AOTriggersNew", function(Signal,Train)

	local checksignals
	local station
	local tbl
	local ply

	for k, v in pairs(AOSystem.Stations) do
		if v.enabled == false then continue end
		if v.aotype == "standard" then
			if Signal.Name == v.trigger then
				if Signal.Occupied then 
					if not v.aoroute or v.aoroute == "" then return end
					checksignals = v.depsignals
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
				if AOSystem.GetSignalFreeBS(v.trigger) < v.blocksections and AOSystem.RouteIsOpened(v.deproute) then 
					if not v.aoroute or v.aoroute == "" then return end
					checksignals = v.depsignals
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
						if not v.aoroute_alt or v.aoroute_alt == "" then return end
						checksignals = v.depsignals_alt
						if not AOSystem.CheckDependSignals(checksignals) then return end
						if v.opened == false then
							AOSystem.OpenRoute(v.aoroute_alt)
							v.opened = true
							timer.Simple(5, function() ply:ChatPrint("Высаживайте пассажиров и следуйте под оборот.") end)
						end
					elseif station != tbl then
						if not v.aoroute_main or v.aoroute_main == "" then return end
						checksignals = v.depsignals_main
						if not AOSystem.CheckDependSignals(checksignals) then return end
						if v.opened == false then
							AOSystem.OpenRoute(v.aoroute_main)
							v.opened = true
							timer.Simple(5, function() ply:ChatPrint("Следите за сигналом! Отправляйтесь по готовности.") end)
						end
					end
				else
					v.opened = false
				end
			end
		end
		if v.aotype == "zone_out" then
			if Signal.Name == v.trigger then
				if IsValid(Train) then
					ply = AOSystem.GetTrainDriver(Train)
				end
				if Signal.Occupied and AOSystem.GetSignalFreeBS(v.checksignal) > v.blocksections then 
					if not v.aoroute or v.aoroute == "" then return end
					checksignals = v.depsignals
					if not AOSystem.CheckDependSignals(checksignals) then return end
					if v.opened == false then
						AOSystem.OpenRoute(v.aoroute)
						v.opened = true
						timer.Simple(5, function() ply:ChatPrint("Отправляйтесь по готовности или \nзакройте маршрут "..v.aoroute) end)
					end
				else
					v.opened = false
				end
			end
		end
		if v.aotype == "reset" then
			if Signal.Name == v.trigger then
				if Signal.Occupied and AOSystem.RouteIsOpened(v.deproute) then 
					if not v.aoroute or v.aoroute == "" then return end
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