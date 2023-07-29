if CLIENT then return end

local Map = game.GetMap()


if Map:find("gm_metro_jar_imagine_line_v4") then 	

	timer.Simple(11, function()
		print("-- Disabling default AO on map ...")
		local i = 0
		for k, v in pairs(ents.FindByClass("func_button")) do
			if v:GetName() == "pult_v" or v:GetName() == "pult_iz" or v:GetName() == "depot_button_iz(kast)" then v:Remove() end
			if v:GetName():find("s9_ob") and v:GetName():find("b_v") then v:Fire("Use") i = i + 1 end
			if v:GetName():find("kgy") and v:GetName():find("off") then v:Fire("Use") i = i + 1 end
			if not (v:GetName():find("avt") and v:GetName():find("vikl")) or v:GetName():find("kgy") then continue end
			v:Fire("Use")
			i = i + 1			
		end
		print("-- "..i.." buttons pressed !")
	end)	

end

