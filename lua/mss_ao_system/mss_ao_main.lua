
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
	SetGlobalBool("AOSystemIsEnabled", true)
	SetGlobalBool("AOSystemAutoReset", true)
	util.AddNetworkString("AOSystem.Commands")
	-- грузим данные
	if file.Exists("mss_ao_system/"..cur_map..".txt", "DATA") then
		local fl = file.Read("mss_ao_system/"..cur_map..".txt", "DATA")
		local tbl = fl and util.JSONToTable(fl) or {}
		AOSystem.Stations = tbl
		if table.IsEmpty(AOSystem.Stations) then 
			MsgC(Color(220, 0, 0, 255), "MSS AO: Data file corrupted.\nLoad failed! \n")
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
		MsgC(Color(0, 220, 0, 255), "MSS AO: logic file detected.\nLoad successful! \n")
	else
		MsgC(Color(220, 0, 0, 255), "MSS AO: No logic file detected\nLoad failed! \n")
		return
	end
	-- грузим костыли
	if file.Exists("mss_ao_system/maps/fix_"..cur_map..".lua", "LUA") then
		include("mss_ao_system/maps/fix_"..cur_map..".lua")
		MsgC(Color(0, 220, 0, 255), "MSS AO: additional file detected.\nInit successful! \n")
	else
		MsgC(Color(220, 0, 0, 255), "MSS AO: No additional file detected.\nNothing to fix! \n")
	end
	hook.Add("AOSystemTrigger", "MSS.AOTriggers", AOSystem.MapLogic)
end)

-- Автосброс состояния АО при отсутствии на сервере игроков с доступом к настройкам АО
hook.Add("PlayerDisconnected","AOSystemReset",function(ply)
	if not GetGlobalBool("AOSystemAutoReset") then return end
	if GetGlobalBool("AOSystemIsEnabled") then return end
	local admins = false
	for k, v in pairs(player.GetHumans()) do
		if v == ply then continue end
		if AOSystem.AccessGranted(v) then admins = true end
	end
	if admins then return end
	SetGlobalBool("AOSystemIsEnabled", false)
	for k, v in pairs(AOSystem.Stations) do
		if v.enabled == false then v.enabled = true end
	end		
	ULib.tsayColor(nil,false,Color(0, 225, 0), "MSS АО: Включен")
end)

-- Синхронизация команд
net.Receive("AOSystem.Commands",function(ln,ply)
	if not IsValid(ply) then return end
	local comm = net.ReadString()
	if comm == "global-state" then
		local state_old = GetGlobalBool("AOSystemIsEnabled")
		local state_new = net.ReadBool()
		if state_new == state_old then return end
		if AOSystem.AccessGranted(ply) then
			SetGlobalBool("AOSystemIsEnabled", state_new)
			if state_new then
				hook.Add("AOSystemTrigger", "MSS.AOTriggers", AOSystem.MapLogic)
				ULib.tsayColor(nil,false,Color(0, 225, 0), "MSS АО: Включен")
			else
				hook.Remove("AOSystemTrigger", "MSS.AOTriggers")
				ULib.tsayColor(nil,false,Color(0, 225, 0), "MSS АО: Отключен")
			end
		end
	elseif comm == "s-state" then
		id = net.ReadInt(10)
		state = net.ReadBool()
		AOSystem.Stations[id].enabled = state
	end
	if not ply:IsAdmin() then return end
	if comm == "reset-state" then
		local reset_old = GetGlobalBool("AOSystemAutoReset")
		local reset_new = net.ReadBool()
		if AOSystem.AccessGranted(ply) then
			SetGlobalBool("AOSystemAutoReset", reset_new)
			if reset_new then
				ULib.tsayColor(nil,false,Color(0, 225, 0), "MSS АО: Автосброс включен")
			else
				ULib.tsayColor(nil,false,Color(0, 225, 0), "MSS АО: Автосброс отключен")
			end
		end
	elseif comm == "s-add" then
		local ln = net.ReadUInt(32)
		local data = util.JSONToTable(util.Decompress(net.ReadData(ln)))
		table.insert(AOSystem.Stations, data)
		AOSystem.ShowMenu(ply)
	elseif comm == "s-remove" then
		id = net.ReadInt(10)
		table.remove(AOSystem.Stations,id)
	elseif comm == "s-edit" then
		id = net.ReadInt(10)
		local ln = net.ReadUInt(32)
		local data = util.JSONToTable(util.Decompress(net.ReadData(ln)))
		AOSystem.Stations[id] = data
		AOSystem.ShowMenu(ply)
	elseif comm == "reload" then
		if file.Exists("mss_ao_system/"..cur_map..".txt", "DATA") then
			local fl = file.Read("mss_ao_system/"..cur_map..".txt", "DATA")
			local tbl = fl and util.JSONToTable(fl) or {}
			AOSystem.Stations = tbl
			AOSystem.ShowMenu(ply)
		end
	elseif comm == "save" then
		local ln = net.ReadUInt(32)
		local data = util.JSONToTable(util.Decompress(net.ReadData(ln)))
		AOSystem.Stations = data
		if not file.Exists("mss_ao_system", "DATA") then
			file.CreateDir("mss_ao_system")
		end
		file.Write("mss_ao_system/"..cur_map..".txt",util.TableToJSON(AOSystem.Stations,true))
	end
end)

-- Запуск меню
function AOSystem.ShowMenu(ply)
	if not AOSystem.AccessGranted(ply) then return end
	net.Start("AOSystem.Commands")
		net.WriteString("menu")
		data = util.Compress(util.TableToJSON(AOSystem.Stations))
		local ln = #data
		net.WriteUInt(ln,32)
		net.WriteData(data,ln)
	net.Send(ply)
end

function AOSystem.CheckDependSignals(signals)
	local checked = true
	for k, v in pairs(signals) do
		if not IsValid(Metrostroi.SignalEntitiesByName[v]) or Metrostroi.SignalEntitiesByName[v].Occupied then
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
						closed = true
						ent.LastOpenedRoute = nil
					end
				end
			end
		end
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
						if RouteInfo.Switches and RouteInfo.Switches != "" then AOSystem.SetSwitchesToRoute(RouteInfo.Switches) end
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
end

function AOSystem.SetSwitchState(switch, state) --switch = entity, state ="alt" or "main"}
	if IsValid(switch) then 
		switch:SendSignal(state, nil, true)
	end
end

-- ent:GetInternalVariable("m_eDoorState") or -1
-- m_eDoorState: 0 - закрыта, 1 - открывается, 2 - открыта, 3 - закрывается.
function AOSystem.SetSwitchesToRoute(switches)
	if not switches or switches == "" then return end
	switches = string.Explode(",",switches)
	for k, v in pairs(switches) do
		local statedesired = v:sub(-1,-1)
		local switchname = v:sub(1,-2)
		if switchname == "" then continue end
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
					--if (RouteInfo.Switches and AOSystem.CheckSwitchesStates(RouteInfo.Switches) and signal.LastOpenedRoute and signal.LastOpenedRoute == RouteID)) or signal.Route == RouteID then
					if (RouteInfo.Switches != "" and AOSystem.CheckSwitchesStates(RouteInfo.Switches)) or (signal.LastOpenedRoute and signal.LastOpenedRoute == RouteID) or signal.Route == RouteID then
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
	if not switches or switches == "" then return end
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

local function StationIDbyName(name)
	if not Metrostroi.StationConfigurations then return 1111 end
	for k, v in pairs(Metrostroi.StationConfigurations) do
		if name == v.names[1] then return tonumber(k) or 1111 end
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
					id = StationIDbyName(tostring(train.SarmatUPO.LastStationName)) 
				end

				-- табло 81-760 не работает, когда строка с табло, не совпадает с названием станции в StationConfigurations
				if train.BMCIS and train.RouteNumber.CurrentLastStation then
					id = StationIDbyName(train.RouteNumber.CurrentLastStation)
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