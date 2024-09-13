
hook.Add("Initialize", "MSS.SignalsRewrite", function()
    local defaultClass = "gmod_track_signal"
	local realClass = defaultClass
	for k, v in pairs(scripted_ents.GetList()) do
		if v.t.ClassName:find(defaultClass) and not v.t.ClassName:find("controller") then
			if v.t.ClassName ~= defaultClass then
				realClass = v.t.ClassName
				break
			end
		end
	end
	MsgC(Color(0, 220, 0, 255), "MSS AO: Selected signal class: "..realClass.."\n")
	local ENT = scripted_ents.GetStored(realClass).t
    local check_occ = ENT.CheckOccupation
    function ENT:CheckOccupation()
        check_occ(self)
        hook.Run("AOSystemTrigger", self, self.OccupiedByNow)
    end
    local cls_route = ENT.CloseRoute
    -- function ENT:CloseRoute()
        -- cls_route(self)
        -- self.LastOpenedRoute = nil
    -- end
end)