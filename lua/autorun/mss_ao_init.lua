if game.SinglePlayer() then return end
if SERVER then
	include("mss_ao_system/mss_ao_main.lua")
	AddCSLuaFile("mss_ao_system/client_gui.lua")
else
	include("mss_ao_system/client_gui.lua")
end