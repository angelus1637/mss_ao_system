if CLIENT then return end

local Map = game.GetMap()

if Map:find("gm_metro_kalinin_v") then 	

	timer.Simple(11, function()
		print("-- Disabling default AO on map ...")
		local i = 0
		for k, v in pairs(ents.FindByClass("func_button")) do
			if not v:GetName():find("off") or v:GetName():find("kgu") then continue end
			v:Fire("Use")
			i = i + 1
		end
		print("-- "..i.." buttons pressed !")
	end)

end