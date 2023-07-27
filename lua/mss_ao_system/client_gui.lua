--------------------------------------------------------------
--					 MSS  AO  GUI							--
--					  By Alexell							--
--  https://steamcommunity.com/profiles/76561198210303223	--
--------------------------------------------------------------

AOSystem = AOSystem or {}
local function ShowEditMenu(data, edit, edit_id)
	local ao_types = {
		{type = "standard", name = "Стандарт"},
		{type = "zone_int", name = "Зонный в тупик"},
		{type = "zone_out", name = "Зонный из тупика"},
		{type = "by-block-sections", name = "По блок-секциям"},
		{type = "reset", name = "Сброс"},
	}
	local frame = vgui.Create("DFrame")
	local h = 85
	if data["aotype"] then
		if     data["aotype"] == "standard"          then h = 305
		elseif data["aotype"] == "zone_int"          then h = 515
		elseif data["aotype"] == "zone_out"          then h = 400
		elseif data["aotype"] == "by-block-sections" then h = 400
		elseif data["aotype"] == "reset"             then h = 305
		end
	end
	frame:SetSize(190,h)
	frame:Center()
	frame:SetTitle("Добавить маршрут АО")
	frame.btnMaxim:SetVisible(false)
	frame.btnMinim:SetVisible(false)
	frame:SetVisible(true)
	frame:SetSizable(false)
	frame:SetDeleteOnClose(true)
	frame:SetIcon("icon16/table_edit.png")
	frame:MakePopup()
	
	local stype_lb = frame:Add("DLabel")
	stype_lb:SetPos(10,33)
	stype_lb:SetText("Тип маршрута:")
	stype_lb:SizeToContents()
	local stype = frame:Add("DComboBox")
	stype:SetPos(10,48)
	stype:SetSize(170,25)
	if data["aotype"] == nil then stype:SetValue("Выберите тип") end
	for k,v in pairs(ao_types) do
		if data["aotype"] and data["aotype"] == v.type then
			stype:AddChoice(v.name, v.type, true)
		else
			stype:AddChoice(v.name, v.type)
		end
	end
	function stype:OnSelect()
		local _,st = stype:GetSelected()
		frame:Close()
		ShowEditMenu({aotype = st})
	end
	
	-- элементы в зависимости от типа маршрута
	if data["aotype"] then
		if data["aotype"] == "standard" then
			local ao_name_lb = frame:Add("DLabel")
			ao_name_lb:SetPos(10,80)
			ao_name_lb:SetText("Название маршрута:")
			ao_name_lb:SizeToContents()
			local ao_name = frame:Add("DTextEntry")
			ao_name:SetPos(10,95)
			ao_name:SetSize(170,25)
			if data["name"] then ao_name:SetValue(data["name"]) end

			local ao_trigger_lb = frame:Add("DLabel")
			ao_trigger_lb:SetPos(10,127)
			ao_trigger_lb:SetText("Триггер:")
			ao_trigger_lb:SizeToContents()
			local ao_trigger = frame:Add("DTextEntry")
			ao_trigger:SetPos(10,142)
			ao_trigger:SetSize(170,25)
			if data["trigger"] then ao_trigger:SetValue(data["trigger"]) end
			
			local ao_depsignals_lb = frame:Add("DLabel")
			ao_depsignals_lb:SetPos(10,174)
			ao_depsignals_lb:SetText("Сигналы для проверки:")
			ao_depsignals_lb:SizeToContents()
			local ao_depsignals = frame:Add("DTextEntry")
			ao_depsignals:SetPos(10,189)
			ao_depsignals:SetSize(170,25)
			if data["depsignals"] then ao_depsignals:SetValue(table.concat(data["depsignals"], ", " )) end
			
			local ao_route_lb = frame:Add("DLabel")
			ao_route_lb:SetPos(10,221)
			ao_route_lb:SetText("Маршрут для открытия:")
			ao_route_lb:SizeToContents()
			local ao_route = frame:Add("DTextEntry")
			ao_route:SetPos(10,236)
			ao_route:SetSize(170,25)
			if data["aoroute"] then ao_route:SetValue(data["aoroute"]) end
			
			local ao_save = frame:Add("DButton")
			ao_save:SetSize(170,25)
			ao_save:SetPos(10,270)
			ao_save:SetText("Сохранить")
			function ao_save:DoClick()
				if ao_name:GetText() == "" or ao_trigger:GetText() == "" or ao_depsignals:GetText() == "" or ao_route:GetText() == "" then
					ao_save:SetText("Не все поля заполнены!")
					timer.Simple(1.5, function() if IsValid(ao_save) then ao_save:SetText("Сохранить") end end)
					return
				end
				local _,st = stype:GetSelected()
				local signals = string.Replace(ao_depsignals:GetText(), " ", "")
				signals = string.Explode(",", signals)
				local s_enabled = true
				if data["enabled"] != nil then s_enabled = data["enabled"] end
				local save_data = {aotype = st, name = ao_name:GetText(), trigger = ao_trigger:GetText(), depsignals = signals, aoroute = ao_route:GetText(), opened = false, enabled = s_enabled}
				net.Start("AOSystem.Commands")
					if edit then
						net.WriteString("s-edit")
						net.WriteInt(edit_id, 10)
					else
						net.WriteString("s-add")
					end
					save_data = util.Compress(util.TableToJSON(save_data))
					local ln = #save_data
					net.WriteUInt(ln,32)
					net.WriteData(save_data,ln)
				net.SendToServer()
				frame:Close()
				AOSystem.Frame:Close()
			end
		elseif data["aotype"] == "zone_int" then
			local ao_name_lb = frame:Add("DLabel")
			ao_name_lb:SetPos(10,80)
			ao_name_lb:SetText("Название маршрута:")
			ao_name_lb:SizeToContents()
			local ao_name = frame:Add("DTextEntry")
			ao_name:SetPos(10,95)
			ao_name:SetSize(170,25)
			if data["name"] then ao_name:SetValue(data["name"]) end

			local ao_trigger_lb = frame:Add("DLabel")
			ao_trigger_lb:SetPos(10,127)
			ao_trigger_lb:SetText("Триггер:")
			ao_trigger_lb:SizeToContents()
			local ao_trigger = frame:Add("DTextEntry")
			ao_trigger:SetPos(10,142)
			ao_trigger:SetSize(170,25)
			if data["trigger"] then ao_trigger:SetValue(data["trigger"]) end
			
			local ao_depsignals_main_lb = frame:Add("DLabel")
			ao_depsignals_main_lb:SetPos(10,174)
			ao_depsignals_main_lb:SetText("Сигналы для проверки по прямой:")
			ao_depsignals_main_lb:SizeToContents()
			local ao_depsignals_main = frame:Add("DTextEntry")
			ao_depsignals_main:SetPos(10,189)
			ao_depsignals_main:SetSize(170,25)
			if data["depsignals_main"] then ao_depsignals_main:SetValue(table.concat(data["depsignals_main"], ", " )) end
			
			local ao_depsignals_alt_lb = frame:Add("DLabel")
			ao_depsignals_alt_lb:SetPos(10,221)
			ao_depsignals_alt_lb:SetText("Сигналы для проверки в тупик:")
			ao_depsignals_alt_lb:SizeToContents()
			local ao_depsignals_alt = frame:Add("DTextEntry")
			ao_depsignals_alt:SetPos(10,236)
			ao_depsignals_alt:SetSize(170,25)
			if data["depsignals_alt"] then ao_depsignals_alt:SetValue(table.concat(data["depsignals_alt"], ", " )) end
			
			local ao_route_main_lb = frame:Add("DLabel")
			ao_route_main_lb:SetPos(10,268)
			ao_route_main_lb:SetText("Маршрут по прямой:")
			ao_route_main_lb:SizeToContents()
			local ao_route_main = frame:Add("DTextEntry")
			ao_route_main:SetPos(10,283)
			ao_route_main:SetSize(170,25)
			if data["aoroute_main"] then ao_route_main:SetValue(data["aoroute_main"]) end
			
			local ao_route_alt_lb = frame:Add("DLabel")
			ao_route_alt_lb:SetPos(10,315)
			ao_route_alt_lb:SetText("Маршрут в тупик:")
			ao_route_alt_lb:SizeToContents()
			local ao_route_alt = frame:Add("DTextEntry")
			ao_route_alt:SetPos(10,330)
			ao_route_alt:SetSize(170,25)
			if data["aoroute_alt"] then ao_route_alt:SetValue(data["aoroute_alt"]) end
			
			local ao_checksignal_lb = frame:Add("DLabel")
			ao_checksignal_lb:SetPos(10,362)
			ao_checksignal_lb:SetText("Сигнал для проверки:")
			ao_checksignal_lb:SizeToContents()
			local ao_checksignal = frame:Add("DTextEntry")
			ao_checksignal:SetPos(10,377)
			ao_checksignal:SetSize(170,25)
			if data["checksignal"] then ao_checksignal:SetValue(data["checksignal"]) end
			
			local ao_blocksections_lb = frame:Add("DLabel")
			ao_blocksections_lb:SetPos(10,409)
			ao_blocksections_lb:SetText("Блок-секции:")
			ao_blocksections_lb:SizeToContents()
			local ao_blocksections = frame:Add("DTextEntry")
			ao_blocksections:SetPos(10,424)
			ao_blocksections:SetSize(170,25)
			if data["blocksections"] then ao_blocksections:SetValue(data["blocksections"]) end
			
			local ao_main_control = frame:Add("DCheckBoxLabel")
			ao_main_control:SetPos(10,456)
			ao_main_control:SetText("Контроль прибытия")
			ao_main_control:SizeToContents()
			if data["main_control"] then ao_main_control:SetChecked(data["main_control"]) end
			
			local ao_save = frame:Add("DButton")
			ao_save:SetSize(170,25)
			ao_save:SetPos(10,480)
			ao_save:SetText("Сохранить")
			function ao_save:DoClick()
				if ao_name:GetText() == "" or ao_trigger:GetText() == "" or ao_depsignals_main:GetText() == "" or ao_depsignals_alt:GetText() == "" or ao_route_main:GetText() == "" or ao_route_alt:GetText() == "" or ao_checksignal:GetText() == "" or ao_blocksections:GetText() == "" then
					ao_save:SetText("Не все поля заполнены!")
					timer.Simple(1.5, function() if IsValid(ao_save) then ao_save:SetText("Сохранить") end end)
					return
				end
				local _,st = stype:GetSelected()
				local signals_main = string.Replace(ao_depsignals_main:GetText(), " ", "")
				signals_main = string.Explode(",", signals_main)
				local signals_alt = string.Replace(ao_depsignals_alt:GetText(), " ", "")
				signals_alt = string.Explode(",", signals_alt)
				local s_enabled = true
				if data["enabled"] != nil then s_enabled = data["enabled"] end
				local save_data = {aotype = st, name = ao_name:GetText(), trigger = ao_trigger:GetText(), depsignals_main = signals_main, depsignals_alt = signals_alt, aoroute_main = ao_route_main:GetText(), aoroute_alt = ao_route_alt:GetText(), checksignal = ao_checksignal:GetText(), blocksections = tonumber(ao_blocksections:GetText()), main_control = ao_main_control:GetChecked(), opened = false, enabled = s_enabled}
				net.Start("AOSystem.Commands")
					if edit then
						net.WriteString("s-edit")
						net.WriteInt(edit_id, 10)
					else
						net.WriteString("s-add")
					end
					save_data = util.Compress(util.TableToJSON(save_data))
					local ln = #save_data
					net.WriteUInt(ln,32)
					net.WriteData(save_data,ln)
				net.SendToServer()
				frame:Close()
				AOSystem.Frame:Close()
			end
		elseif (data["aotype"] == "zone_out") then
			local ao_name_lb = frame:Add("DLabel")
			ao_name_lb:SetPos(10,80)
			ao_name_lb:SetText("Название маршрута:")
			ao_name_lb:SizeToContents()
			local ao_name = frame:Add("DTextEntry")
			ao_name:SetPos(10,95)
			ao_name:SetSize(170,25)
			if data["name"] then ao_name:SetValue(data["name"]) end

			local ao_trigger_lb = frame:Add("DLabel")
			ao_trigger_lb:SetPos(10,127)
			ao_trigger_lb:SetText("Триггер:")
			ao_trigger_lb:SizeToContents()
			local ao_trigger = frame:Add("DTextEntry")
			ao_trigger:SetPos(10,142)
			ao_trigger:SetSize(170,25)
			if data["trigger"] then ao_trigger:SetValue(data["trigger"]) end
			
			local ao_depsignals_lb = frame:Add("DLabel")
			ao_depsignals_lb:SetPos(10,174)
			ao_depsignals_lb:SetText("Сигналы для проверки:")
			ao_depsignals_lb:SizeToContents()
			local ao_depsignals = frame:Add("DTextEntry")
			ao_depsignals:SetPos(10,189)
			ao_depsignals:SetSize(170,25)
			if data["depsignals"] then ao_depsignals:SetValue(table.concat(data["depsignals"], ", " )) end
			
			local ao_route_lb = frame:Add("DLabel")
			ao_route_lb:SetPos(10,221)
			ao_route_lb:SetText("Маршрут для открытия:")
			ao_route_lb:SizeToContents()
			local ao_route = frame:Add("DTextEntry")
			ao_route:SetPos(10,236)
			ao_route:SetSize(170,25)
			if data["aoroute"] then ao_route:SetValue(data["aoroute"]) end
			
			local ao_checksignal_lb = frame:Add("DLabel")
			ao_checksignal_lb:SetPos(10,268)
			ao_checksignal_lb:SetText("Сигнал для проверки:")
			ao_checksignal_lb:SizeToContents()
			local ao_checksignal = frame:Add("DTextEntry")
			ao_checksignal:SetPos(10,283)
			ao_checksignal:SetSize(170,25)
			if data["checksignal"] then ao_checksignal:SetValue(data["checksignal"]) end
			
			local ao_blocksections_lb = frame:Add("DLabel")
			ao_blocksections_lb:SetPos(10,315)
			ao_blocksections_lb:SetText("Блок-секции:")
			ao_blocksections_lb:SizeToContents()
			local ao_blocksections = frame:Add("DTextEntry")
			ao_blocksections:SetPos(10,330)
			ao_blocksections:SetSize(170,25)
			if data["blocksections"] then ao_blocksections:SetValue(data["blocksections"]) end
			
			local ao_save = frame:Add("DButton")
			ao_save:SetSize(170,25)
			ao_save:SetPos(10,364)
			ao_save:SetText("Сохранить")
			function ao_save:DoClick()
				if ao_name:GetText() == "" or ao_trigger:GetText() == "" or ao_depsignals:GetText() == "" or ao_route:GetText() == "" or ao_checksignal:GetText() == "" or ao_blocksections:GetText() == ""then
					ao_save:SetText("Не все поля заполнены!")
					timer.Simple(1.5, function() if IsValid(ao_save) then ao_save:SetText("Сохранить") end end)
					return
				end
				local _,st = stype:GetSelected()
				local signals = string.Replace(ao_depsignals:GetText(), " ", "")
				signals = string.Explode(",", signals)
				local s_enabled = true
				if data["enabled"] != nil then s_enabled = data["enabled"] end
				local save_data = {aotype = st, name = ao_name:GetText(), trigger = ao_trigger:GetText(), depsignals = signals, aoroute = ao_route:GetText(), checksignal = ao_checksignal:GetText(), blocksections = tonumber(ao_blocksections:GetText()), opened = false, enabled = s_enabled}
				net.Start("AOSystem.Commands")
					if edit then
						net.WriteString("s-edit")
						net.WriteInt(edit_id, 10)
					else
						net.WriteString("s-add")
					end
					save_data = util.Compress(util.TableToJSON(save_data))
					local ln = #save_data
					net.WriteUInt(ln,32)
					net.WriteData(save_data,ln)
				net.SendToServer()
				frame:Close()
				AOSystem.Frame:Close()
			end
		elseif data["aotype"] == "by-block-sections" then
			local ao_name_lb = frame:Add("DLabel")
			ao_name_lb:SetPos(10,80)
			ao_name_lb:SetText("Название маршрута:")
			ao_name_lb:SizeToContents()
			local ao_name = frame:Add("DTextEntry")
			ao_name:SetPos(10,95)
			ao_name:SetSize(170,25)
			if data["name"] then ao_name:SetValue(data["name"]) end

			local ao_trigger_lb = frame:Add("DLabel")
			ao_trigger_lb:SetPos(10,127)
			ao_trigger_lb:SetText("Триггер:")
			ao_trigger_lb:SizeToContents()
			local ao_trigger = frame:Add("DTextEntry")
			ao_trigger:SetPos(10,142)
			ao_trigger:SetSize(170,25)
			if data["trigger"] then ao_trigger:SetValue(data["trigger"]) end
			
			local ao_depsignals_lb = frame:Add("DLabel")
			ao_depsignals_lb:SetPos(10,174)
			ao_depsignals_lb:SetText("Сигналы для проверки:")
			ao_depsignals_lb:SizeToContents()
			local ao_depsignals = frame:Add("DTextEntry")
			ao_depsignals:SetPos(10,189)
			ao_depsignals:SetSize(170,25)
			if data["depsignals"] then ao_depsignals:SetValue(table.concat(data["depsignals"], ", " )) end
			
			local ao_deproute_lb = frame:Add("DLabel")
			ao_deproute_lb:SetPos(10,221)
			ao_deproute_lb:SetText("Маршрут для проверки:")
			ao_deproute_lb:SizeToContents()
			local ao_deproute = frame:Add("DTextEntry")
			ao_deproute:SetPos(10,236)
			ao_deproute:SetSize(170,25)
			if data["deproute"] then ao_deproute:SetValue(data["deproute"]) end
			
			local ao_blocksections_lb = frame:Add("DLabel")
			ao_blocksections_lb:SetPos(10,268)
			ao_blocksections_lb:SetText("Блок-секции:")
			ao_blocksections_lb:SizeToContents()
			local ao_blocksections = frame:Add("DTextEntry")
			ao_blocksections:SetPos(10,283)
			ao_blocksections:SetSize(170,25)
			if data["blocksections"] then ao_blocksections:SetValue(data["blocksections"]) end
			
			local ao_route_lb = frame:Add("DLabel")
			ao_route_lb:SetPos(10,315)
			ao_route_lb:SetText("Маршрут для открытия:")
			ao_route_lb:SizeToContents()
			local ao_route = frame:Add("DTextEntry")
			ao_route:SetPos(10,330)
			ao_route:SetSize(170,25)
			if data["aoroute"] then ao_route:SetValue(data["aoroute"]) end
			
			local ao_save = frame:Add("DButton")
			ao_save:SetSize(170,25)
			ao_save:SetPos(10,364)
			ao_save:SetText("Сохранить")
			function ao_save:DoClick()
				if ao_name:GetText() == "" or ao_trigger:GetText() == "" or ao_depsignals:GetText() == "" or ao_deproute:GetText() == "" or ao_blocksections:GetText() == "" or ao_route:GetText() == ""then
					ao_save:SetText("Не все поля заполнены!")
					timer.Simple(1.5, function() if IsValid(ao_save) then ao_save:SetText("Сохранить") end end)
					return
				end
				local _,st = stype:GetSelected()
				local signals = string.Replace(ao_depsignals:GetText(), " ", "")
				signals = string.Explode(",", signals)
				local s_enabled = true
				if data["enabled"] != nil then s_enabled = data["enabled"] end
				local save_data = {aotype = st, name = ao_name:GetText(), trigger = ao_trigger:GetText(), depsignals = signals, deproute = ao_deproute:GetText(), blocksections = tonumber(ao_blocksections:GetText()), aoroute = ao_route:GetText(), opened = false, enabled = s_enabled}
				net.Start("AOSystem.Commands")
					if edit then
						net.WriteString("s-edit")
						net.WriteInt(edit_id, 10)
					else
						net.WriteString("s-add")
					end
					save_data = util.Compress(util.TableToJSON(save_data))
					local ln = #save_data
					net.WriteUInt(ln,32)
					net.WriteData(save_data,ln)
				net.SendToServer()
				frame:Close()
				AOSystem.Frame:Close()
			end
		elseif data["aotype"] == "reset" then
			local ao_name_lb = frame:Add("DLabel")
			ao_name_lb:SetPos(10,80)
			ao_name_lb:SetText("Название маршрута:")
			ao_name_lb:SizeToContents()
			local ao_name = frame:Add("DTextEntry")
			ao_name:SetPos(10,95)
			ao_name:SetSize(170,25)
			if data["name"] then ao_name:SetValue(data["name"]) end

			local ao_trigger_lb = frame:Add("DLabel")
			ao_trigger_lb:SetPos(10,127)
			ao_trigger_lb:SetText("Триггер:")
			ao_trigger_lb:SizeToContents()
			local ao_trigger = frame:Add("DTextEntry")
			ao_trigger:SetPos(10,142)
			ao_trigger:SetSize(170,25)
			if data["trigger"] then ao_trigger:SetValue(data["trigger"]) end
			
			local ao_deproute_lb = frame:Add("DLabel")
			ao_deproute_lb:SetPos(10,174)
			ao_deproute_lb:SetText("Маршрут для проверки:")
			ao_deproute_lb:SizeToContents()
			local ao_deproute = frame:Add("DTextEntry")
			ao_deproute:SetPos(10,189)
			ao_deproute:SetSize(170,25)
			if data["deproute"] then ao_deproute:SetValue(data["deproute"]) end
			
			local ao_route_lb = frame:Add("DLabel")
			ao_route_lb:SetPos(10,221)
			ao_route_lb:SetText("Маршрут для сброса:")
			ao_route_lb:SizeToContents()
			local ao_route = frame:Add("DTextEntry")
			ao_route:SetPos(10,236)
			ao_route:SetSize(170,25)
			if data["aoroute"] then ao_route:SetValue(data["aoroute"]) end
			
			local ao_save = frame:Add("DButton")
			ao_save:SetSize(170,25)
			ao_save:SetPos(10,270)
			ao_save:SetText("Сохранить")
			function ao_save:DoClick()
				if ao_name:GetText() == "" or ao_trigger:GetText() == "" or ao_deproute:GetText() == "" or ao_route:GetText() == "" then
					ao_save:SetText("Не все поля заполнены!")
					timer.Simple(1.5, function() if IsValid(ao_save) then ao_save:SetText("Сохранить") end end)
					return
				end
				local _,st = stype:GetSelected()
				local s_enabled = true
				if data["enabled"] != nil then s_enabled = data["enabled"] end
				local save_data = {aotype = st, name = ao_name:GetText(), trigger = ao_trigger:GetText(), deproute = ao_deproute:GetText(), aoroute = ao_route:GetText(), opened = false, enabled = s_enabled}
				net.Start("AOSystem.Commands")
					if edit then
						net.WriteString("s-edit")
						net.WriteInt(edit_id, 10)
					else
						net.WriteString("s-add")
					end
					save_data = util.Compress(util.TableToJSON(save_data))
					local ln = #save_data
					net.WriteUInt(ln,32)
					net.WriteData(save_data,ln)
				net.SendToServer()
				frame:Close()
				AOSystem.Frame:Close()
			end
		end
	end
end

local function ShowMenu(data)
	AOSystem.Frame = vgui.Create("DFrame")
	AOSystem.Frame:SetSize(400,286)
	AOSystem.Frame:Center()
	AOSystem.Frame:SetTitle("MSS: Система автооборотов")
	AOSystem.Frame.btnMaxim:SetVisible(false)
	AOSystem.Frame.btnMinim:SetVisible(false)
	AOSystem.Frame:SetVisible(true)
	AOSystem.Frame:SetSizable(false)
	AOSystem.Frame:SetDeleteOnClose(true)
	AOSystem.Frame:SetIcon("icon16/application_view_detail.png")
	AOSystem.Frame:MakePopup()
	
	local savebtn = AOSystem.Frame:Add("DButton")
	savebtn:SetSize(185,25)
	savebtn:SetPos((AOSystem.Frame:GetWide()-10)-185,215)
	savebtn:SetText("Сохранить в файл")
	function savebtn:DoClick()
		net.Start("AOSystem.Commands")
			net.WriteString("save")
			tbl = util.Compress(util.TableToJSON(data))
			local ln = #tbl
			net.WriteUInt(ln,32)
			net.WriteData(tbl,ln)
		net.SendToServer()
		savebtn:SetText("Сохранено")
		timer.Simple(1.5, function() if IsValid(savebtn) then savebtn:SetText("Сохранить в файл") end end)
	end
	
	local statebox = AOSystem.Frame:Add("DCheckBoxLabel")
	statebox:SetPos(10,33)
	statebox:SetText("Система АО включена")
	statebox:SizeToContents()	
	statebox:SetChecked(GetGlobalBool("AOSystemIsEnabled"))
	function statebox:OnChange(val)
		net.Start("AOSystem.Commands")
			net.WriteString("global-state")
			net.WriteBool(val)
		net.SendToServer()
	end
	
	local resetbox = AOSystem.Frame:Add("DCheckBoxLabel")
	resetbox:SetPos(170,33)
	resetbox:SetText("Автовозврат АО включен")
	resetbox:SizeToContents()	
	resetbox:SetChecked(GetGlobalBool("AOSystemAutoReset"))
	function resetbox:OnChange(val)
		net.Start("AOSystem.Commands")
			net.WriteString("reset-state")
			net.WriteBool(val)
		net.SendToServer()
	end
	
	local aolist = AOSystem.Frame:Add("DListView")
	aolist:SetMultiSelect(false)
	aolist:AddColumn("Название")
	aolist:AddColumn("Состояние")
	aolist:SetPos(10,55)
	aolist:SetSize(380,150)
	
	if #data > 0 then
		for k,v in pairs(data) do
			aolist:AddLine(v.name, v.enabled and 'вкл' or 'выкл')
		end
	end
	
	function aolist:OnRowRightClick(row_id,row)
		local menu = DermaMenu()
		if GetGlobalBool("AOSystemIsEnabled") then
			if row:GetColumnText(2) == 'вкл' then
				menu:AddOption("Выключить", function()
					if not row:IsValid() then return end
					net.Start("AOSystem.Commands")
						net.WriteString("s-state")
						net.WriteInt(row_id, 10)
						net.WriteBool(false)
					net.SendToServer()
					for k,v in pairs(data) do
						if k == row_id then v.enabled = false end
					end
					row:SetColumnText(2, "выкл")
				end):SetIcon("icon16/delete.png")
			else
				menu:AddOption("Включить", function()
					if not row:IsValid() then return end
					net.Start("AOSystem.Commands")
						net.WriteString("s-state")
						net.WriteInt(row_id, 10)
						net.WriteBool(true)
					net.SendToServer()
					for k,v in pairs(data) do
						if k == row_id then v.enabled = true end
					end
					row:SetColumnText(2, "вкл")
				end):SetIcon("icon16/accept.png")
			end
			menu:AddSpacer()
		end
		menu:AddOption("Редактировать", function()
			if not row:IsValid() then return end
			ShowEditMenu(data[row_id], true, row_id)
		end):SetIcon("icon16/pencil.png")
		menu:AddOption("Удалить", function()
			if not row:IsValid() then return end
			table.remove(data,row_id)
			aolist:RemoveLine(row_id)
			net.Start("AOSystem.Commands")
				net.WriteString("s-remove")
				net.WriteInt(row_id, 10)
			net.SendToServer()
		end):SetIcon("icon16/cross.png")
		menu:Open()
	end

	local addbtn = AOSystem.Frame:Add("DButton")
	addbtn:SetSize(185,25)
	addbtn:SetPos(10,215)
	addbtn:SetText("Добавить")
	function addbtn:DoClick()
		ShowEditMenu(data)
	end
	
	local reloadbtn = AOSystem.Frame:Add("DButton")
	reloadbtn:SetSize(170,25)
	reloadbtn:SetPos((AOSystem.Frame:GetWide()/2)-85,250)
	reloadbtn:SetText("Перезагрузить из файла")
	function reloadbtn:DoClick()
		net.Start("AOSystem.Commands")
			net.WriteString("reload")
		net.SendToServer()
		AOSystem.Frame:Close()
	end
end

net.Receive("AOSystem.Commands",function()
	local comm = net.ReadString()
	if comm == "menu" then
		local ln = net.ReadUInt(32)
		local data = util.JSONToTable(util.Decompress(net.ReadData(ln)))
		ShowMenu(data)
	-- elseif comm == "cr-add" then
		-- local cr_name = net.ReadString()
		-- local cr_pos = net.ReadVector()
		-- local cr_ang = net.ReadAngle()
		-- table.insert(MDispatcher.FillControlRooms,{Name = cr_name,Pos = cr_pos,Ang = cr_ang})
		-- FillDSCPMenu()
	-- elseif comm == "cr-save-ok" then
		-- Derma_Message("Блок-посты сохранены успешно! Чтобы увидеть изменения, пожалуйста перезайдите на сервер.", "Меню диспетчера", "OK")
	-- elseif comm == "sched-send-ok" then
		-- Derma_Message("Расписание успешно отправлено!", "Меню диспетчера", "OK")
	end
end)