if CLIENT then return end

local Map = game.GetMap()

if Map:find("kalinin") then 	

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

if Map:find("nekrasovskaya") then 	

	timer.Simple(11, function()
		print("-- Disabling default AO on map ...")
		local i = 0
		for k, v in pairs(ents.FindByClass("func_button")) do
			if not (v:GetName():find("ob") and v:GetName():find("v_b")) or v:GetName():find("kgu") then continue end
			v:Fire("Use")
			i = i + 1
		end
		print("-- "..i.." buttons pressed !")
	end)

end

if Map:find("virus") then 	

	timer.Simple(11, function()
		print("-- Disabling default AO on map ...")
		local i = 0
		for k, v in pairs(ents.FindByClass("func_button")) do
			if not (v:GetName():find("ad") and v:GetName():find("off")) or v:GetName():find("kgu") then continue end
			v:Fire("Use")
			i = i + 1
		end
		print("-- "..i.." buttons pressed !")
	end)

end


if Map:find("imagine") then 	

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
	
	function SetSwitchState(switch,state) --switch = entity, state ="alt" or "main"}
		if IsValid(switch) then 
			switch:SendSignal(state, nil, true)
			print("-- Switch "..switch.Name.." is set to "..state)
		end
	end
	
	timer.Simple(10, function()
		print("-- Fixing switches' states ...")
		for k, v in pairs(ents.FindByClass("gmod_track_switch")) do
			SetSwitchState(v, "main")
		end
		print("-- All switches are set to main !")
	end)	

end

if Map:find("neocrimson_line_a") then 
	timer.Simple(5, function()
		for k, v in pairs(ents.FindInSphere(Vector(-14447, -9811, -1434), 64)) do
			if v:GetClass() == "func_button" then v:Remove() end
		end
	end)
end

if Map:find("chapaevskaya_line_a") then 
	function SetSwitchState(switch,state) --switch = entity, state ="alt" or "main"}
		if IsValid(switch) then 
			switch:SendSignal(state, nil, true)
			print("-- Switch "..switch.Name.." is set to "..state)
		end
	end

	timer.Simple(10, function()
		print("-- Fixing switches' states ...")
		for k, v in pairs(ents.FindByClass("gmod_track_switch")) do
			if v.Name == "d1" or v.Name == "d2" then SetSwitchState(v, "main") end
		end
		print("-- All switches are set to main !")
	end)
end
