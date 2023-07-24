
hook.Add("InitPostEntity", "MSS.SignalsRewrite", function()
    local ENT = scripted_ents.GetStored("gmod_track_signal").t
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