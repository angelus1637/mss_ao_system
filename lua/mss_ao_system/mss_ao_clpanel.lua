
--------------------------------------------------------------
--					MSS  AO  CPANEL							--
--					By Agent Smith							--
--  https://steamcommunity.com/profiles/76561197990364979	--
--------------------------------------------------------------

CreateClientConVar("ao_autoreset", 1, true)

-- Callback на изменение квары
cvars.AddChangeCallback("ao_autoreset", function(cvar, old, new)
	net.Start("ao_reset_sync")
		net.WriteString(new)
	net.SendToServer()
end)

-- Обмен данными
net.Receive("ao_reset_sync", function(ln,ply)
	local res = net.ReadString()
	LocalPlayer():ConCommand("ao_autoreset "..res)
end)

local function AddBox(panel,cmd,str)
    panel:AddControl("CheckBox",{Label=str, Command=cmd})
end

local function AOPanel(panel)
	AddBox(panel,"ao_autoreset", "Автовозврат АО")
	panel:Button("Включить АО", "aosystem_enable", true)
	panel:Button("Отключить АО", "aosystem_disable", true)
end

hook.Add("PopulateToolMenu", "AOSystemClientPanel", function()
    spawnmenu.AddToolMenuOption("Utilities", "MSS", "AOSystem", "MSS АО", "", "", AOPanel)
end)
