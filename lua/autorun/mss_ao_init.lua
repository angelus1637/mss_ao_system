if game.SinglePlayer() then return end
if SERVER then
	include("mss_ao_system/mss_ao_main.lua")
	AddCSLuaFile("mss_ao_system/mss_ao_clpanel.lua") 
else
	include("mss_ao_system/mss_ao_clpanel.lua")
end