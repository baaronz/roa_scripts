local function OnCreatureKill(event, killer, killed)
    if not killer or not killed then
        return
    end
    
    if killer:IsPlayer() then
        local creature = killed:ToCreature()
        if creature then
            local creatureRank = creature:GetRank()
            if creatureRank > 0 then
                local honorAmount = 100
                
                local group = killer:GetGroup()
                if group then
                    local groupMembers = group:GetMembers()
                    for i = 1, #groupMembers do
                        local member = groupMembers[i]
                        if member and member:IsPlayer() then
                            member:ModifyHonorPoints(honorAmount)
                            member:SendBroadcastMessage("Gained " .. honorAmount .. " honor points for defeating a ranked creature!")
                        end
                    end
                else
                    killer:ModifyHonorPoints(honorAmount)
                    killer:SendBroadcastMessage("Gained " .. honorAmount .. " honor points for defeating a ranked creature!")
                end
            end
        end
    end
end

RegisterPlayerEvent(6, OnCreatureKill)
