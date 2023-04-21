timer.Simple(0.5, function()
    local ENT = scripted_ents.GetStored("gmod_track_signal").t
    local check_occ = ENT.CheckOccupation
    function ENT:CheckOccupation()
        check_occ(self)
        hook.Run("AOSystemTrigger",self,self.OccupiedByNow)
    end
end)
