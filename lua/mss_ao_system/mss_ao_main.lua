
--------------------------------------------------------------
--					MSS  AO  MAIN							--
--					By Agent Smith							--
--  https://steamcommunity.com/profiles/76561197990364979	--
--------------------------------------------------------------

-- Инициализация AOSystem
AOSystem = AOSystem or {}
AOSystem.Stations = {}
local cur_map = game.GetMap()

timer.Create("AOSystemInit", 2, 1, function()
	-- грузим данные
	if file.Exists("mss_ao_system/"..cur_map..".txt", "DATA") then		
		local fl = file.Read("mss_ao_system/"..cur_map..".txt", "DATA")
		local tbl = fl and util.JSONToTable(fl) or {}
		AOSystem.Stations = tbl
		if table.IsEmpty(AOSystem.Stations) then 
			MsgC(Color(0, 220, 0, 255), "MSS AO: Data file corrupted.\nLoad failed! \n")
			return
		else
			MsgC(Color(0, 220, 0, 255), "MSS AO: Data file detected.\nLoad successful! \n")
		end
	else
		MsgC(Color(220, 0, 0, 255), "MSS AO: No data file detected for current map\nLoad failed! \n")
		return
	end
	-- грузим логику
	if file.Exists("mss_ao_system/maps/sv_maps_logic.lua", "LUA") then
		include("mss_ao_system/maps/sv_maps_logic.lua")
		MsgC(Color(0, 220, 0, 255), "MSS AO: logic file detected.\nInit successful! \n")
	else
		MsgC(Color(220, 0, 0, 255), "MSS AO: No logic file detected\nInit failed! \n")
		return
	end
	-- грузим костыли
	if file.Exists("mss_ao_system/maps/sv_default_ao_fix.lua", "LUA") then
		include("mss_ao_system/maps/sv_default_ao_fix.lua")
		MsgC(Color(0, 220, 0, 255), "MSS AO: additional file detected.\nInit successful! \n")
	else
		MsgC(Color(220, 0, 0, 255), "MSS AO: No additional file detected\nInit failed! \n")
		return
	end
	SetGlobalBool("AOSystemIsDisabled", false)
	SetGlobalBool("AOSystemAutoReset", true)
end)

util.AddNetworkString("ao_reset_sync")

-- Обмен данных
net.Receive("ao_reset_sync", function(ln,ply)
	local reset_old = GetGlobalBool("AOSystemAutoReset")
	local reset_new = tobool(net.ReadString())
	if reset_new ~= reset_old then
		if ply:IsAdmin() then
			SetGlobalBool("AOSystemAutoReset", reset_new)
			if reset_new then
				ULib.tsayColor(nil,false,Color(0, 225, 0), "MSS АО: Автосброс включен")
			else
				ULib.tsayColor(nil,false,Color(0, 225, 0), "MSS АО: Автосброс отключен")
			end
			net.Start("ao_reset_sync")
			if reset_new then
				net.WriteString("1")
			else
				net.WriteString("0")
			end
			net.Broadcast()
		else
			if reset_old then
				ply:ConCommand("ao_autoreset 1")
			else
				ply:ConCommand("ao_autoreset 0")
			end
			ULib.tsayError(ply, "У вас нет доступа к этой команде!" )
		end
	end
end)

-- Синхронизация ao_autoreset у новых клиентов
hook.Add("PlayerInitialSpawn","AOSystemSetParams",function(ply)
	local res = GetGlobalBool("AOSystemAutoReset")
	if res then
		ply:ConCommand("ao_autoreset 1")
	else
		ply:ConCommand("ao_autoreset 0")
	end
end)

-- Автосброс состояния АО при отсутствии на сервере игроков с доступом к настройкам АО
hook.Add("PlayerDisconnected","AOSystemResert",function(ply)
	if GetGlobalBool("AOSystemAutoReset") then
		if GetGlobalBool("AOSystemIsDisabled") then
			local admins = false
			for k, v in pairs(player.GetHumans()) do
				if v == ply then continue end
				if v:IsAdmin() or v.DispPost then admins = true end
			end
			if not admins then
				SetGlobalBool("AOSystemIsDisabled", false)
				for k, v in pairs(AOSystem.Stations) do
					if v.enabled == false then v.enabled = true end
				end		
				ULib.tsayColor(nil,false,Color(0, 225, 0), "MSS АО: Включен")
			end
		end
	end
end)

-- Команды на вкл/выкл АО
concommand.Add("aosystem_disable", function(ply, _, args)
	if ply:IsAdmin() or ply.DispPost then
        SetGlobalBool("AOSystemIsDisabled", true)
		for k, v in pairs(AOSystem.Stations) do
			if v.enabled == true then v.enabled = false end
		end		
		ULib.tsayColor(nil,false,Color(0, 225, 0), "MSS АО: Отключен")
	else
		ULib.tsayError(ply, "У вас нет доступа к этой команде!" )
    end
end)

concommand.Add("aosystem_enable", function(ply, _, args)
	if ply:IsAdmin() or ply.DispPost then
        SetGlobalBool("AOSystemIsDisabled", false)
		for k, v in pairs(AOSystem.Stations) do
			if v.enabled == false then v.enabled = true end
		end		
		ULib.tsayColor(nil,false,Color(0, 225, 0), "MSS АО: Включен")
	else
		ULib.tsayError(ply, "У вас нет доступа к этой команде!" )
    end
end)

function AOSystem.CheckDependSignals(signals)
	if signals == nil or signals == {} then return false end
	local checked = true
	for k, v in pairs(signals) do
		if Metrostroi.SignalEntitiesByName[v].Occupied then
			checked = false
		end
	end
	return checked
end

function AOSystem.GetSignalFreeBS(signal_name)
	return Metrostroi.SignalEntitiesByName[signal_name].FreeBS
end

function AOSystem.CloseRoute(RouteName)
	local closed = false
	local found = false
	for _, ent in pairs(ents.FindByClass("gmod_track_signal")) do
		if ent.Routes then
			for RouteID, RouteInfo in pairs(ent.Routes) do
				if RouteInfo.RouteName and RouteInfo.RouteName:upper() == RouteName then
					found = true
					if ent.LastOpenedRoute and ent.LastOpenedRoute == RouteID then
						ent:CloseRoute(RouteID)
						ent.LastOpenedRoute = -1
						closed = true	
					end
				end
			end
		end
	end	
	if found and closed then
		ULib.tsayColor(nil,false,Color(0, 225, 0), "MSS АО: Сброс маршрута "..RouteName.."")
	end
end

function AOSystem.OpenRoute(RouteName)
	local opened = false
	local found = false
	
	for _, ent in pairs(ents.FindByClass("gmod_track_signal")) do
		if ent.Routes then
			for RouteID, RouteInfo in pairs(ent.Routes) do
				if RouteInfo.RouteName and RouteInfo.RouteName:upper() == RouteName then
					found = true
					if ent.Route != RouteID or not RouteInfo.IsOpened then
						AOSystem.SetSwitchesToRoute(RouteInfo.Switches)
						if RouteInfo.Manual then
							timer.Create("OpenDelayTimer", 6, 1, function()
								ent:OpenRoute(RouteID)
							end)
						end
						opened = true
					end
				end
			end
		end
	end
	if found and opened then
		ULib.tsayColor(nil,false,Color(0, 225, 0), "MSS АО: Готовится маршрут "..RouteName.."")
	end	
end

function AOSystem.SetSwitchState(switch,state) --switch = entity, state ="alt" or "main"}
	if IsValid(switch) then 
		switch:SendSignal(state, nil, true)
	end
end

-- ent:GetInternalVariable("m_eDoorState") or -1
-- m_eDoorState: 0 - закрыта, 1 - открывается, 2 - открыта, 3 - закрывается.
function AOSystem.SetSwitchesToRoute(switches)
	if switches == nil then return end
	switches = string.Explode(",",switches)
	for k, v in pairs(switches) do
		local statedesired = v:sub(-1,-1)
		local switchname = v:sub(1,-2)
		local switchent = Metrostroi.GetSwitchByName(switchname)
		if not IsValid(switchent) then continue end
		local statereal = switchent:GetInternalVariable("m_eDoorState") or -1
		if statedesired == "+" and statereal != 0 then
			AOSystem.SetSwitchState(switchent, "main")
		end
		if statedesired == "-" and statereal != 2 then
			AOSystem.SetSwitchState(switchent, "alt")
		end
	end
end

function AOSystem.RouteIsOpened(RouteName)
	local Opened = false
	for _, signal in pairs(ents.FindByClass("gmod_track_signal")) do
		if signal.Routes then
			for RouteID, RouteInfo in pairs(signal.Routes) do
				if RouteInfo.RouteName and RouteInfo.RouteName:upper() == RouteName then
					if (RouteInfo.Switches and AOSystem.CheckSwitchesStates(RouteInfo.Switches)) or (signal.LastOpenedRoute and signal.LastOpenedRoute == RouteID) or signal.Route == RouteID then
						Opened = true
					end
				end
			end
		end
	end
	return Opened
end

function AOSystem.CheckSwitchesStates(switches)
	local checked = true
	if switches == nil then return end
	switches = string.Explode(",",switches)
	for k, v in pairs(switches) do
		local switchname = v:sub(1,-2)
		local statedesired = v:sub(-1,-1)
		local switchent = Metrostroi.GetSwitchByName(switchname)
		if not IsValid(switchent) then continue end
		local statereal = switchent:GetInternalVariable("m_eDoorState") or -1
		if statedesired == "+" and statereal != 0 then
			checked = false
		end
		if statedesired == "-" and statereal != 2 then
			checked = false
		end
	end
	return checked
end

function AOSystem.GetTrainDriver(train)
	local driver
	for k, v in ipairs(train.WagonList) do
		driver = v:GetDriverPly()
		if IsValid(driver) then
			return driver
		end
	end	
end

function AOSystem.GetLastStationID(train)
	local driver
	local id = 1111
	if IsValid(train) then  
		for k, v in ipairs(train.WagonList) do
			driver = v:GetDriver()
			if IsValid(driver) then
				-- трафарет
				if train.LastStation and train.LastStation.ID and train.LastStation.TableName then
					id = table.KeyFromValue(Metrostroi.Skins[train.LastStation.TableName],train.LastStation.ID)
				end

				-- табло 81-722 не работает, ваще неясно почему...
				if train.SarmatUPO and train.SarmatUPO.LastStationName then
					id = MSS.StationIDByName(tostring(train.SarmatUPO.LastStationName)) 
				end

				-- табло 81-760 не работает, когда строка с табло, не совпадает с названием станции в StationConfigurations
				if train.BMCIS and train.RouteNumber.CurrentLastStation then
					id = MSS.StationIDByName(train.RouteNumber.CurrentLastStation) 
				end
				--ULib.tsayColor(nil,false,Color(0, 225, 0), "MSS АО: Конечная станция - "..id.."") 	-- отладочная строка!!!
			end
		end	
	end
	return id 
end 

concommand.Add("metrostroi_cleanup_arsboxes", function(ply, _, args)
    if ply:IsAdmin() then
		for _, ent in pairs(ents.FindByClass("gmod_track_signal")) do
			if ent.ARSOnly then ent:Remove() end
		end
    end
end)