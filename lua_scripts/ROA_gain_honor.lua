local function OnCreatureKill(event, killer, killed)
    if not killer or not killed then
        return
    end
    
    if killer:IsPlayer() then
        local creature = killed:ToCreature()
        local honorAmount = 100
        if creature then
            if killed:IsElite() == true then
                local group = killer:GetGroup()
                if group then
                    local groupMembers = group:GetMembers()
                    for i = 1, #groupMembers do
                        local member = groupMembers[i]
                        if member and member:IsPlayer() then
                            member:ModifyHonorPoints(honorAmount)
                            member:SendBroadcastMessage("|c979ABDFFGained " .. honorAmount .. " honor points for defeating an elite creature!|r")
                        end
                    end
                else
                    killer:ModifyHonorPoints(honorAmount)
                    killer:SendBroadcastMessage("|c979ABDFFGained " .. honorAmount .. " honor points for defeating an elite creature!|r")
                end
            end

            if killed:IsGuard() == true then
                local group = killer:GetGroup()
                if group then
                    local groupMembers = group:GetMembers()
                    for i = 1, #groupMembers do
                        local member = groupMembers[i]
                        if member and member:IsPlayer() then
                            member:ModifyHonorPoints(honorAmount)
                            member:SendBroadcastMessage("|c979ABDFFGained " .. honorAmount .. " honor points for defeating a guard!|r")
                        end
                    end
                else
                    killer:ModifyHonorPoints(honorAmount)
                    killer:SendBroadcastMessage("|c979ABDFFGained " .. honorAmount .. " honor points for defeating a guard!|r")
                end
            end
        end
    end
end

RegisterPlayerEvent(7, OnCreatureKill)
