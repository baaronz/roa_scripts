local function OnPlayerLogin(event, player)
    if player:HasSpell(674) == true then
        return
    end

    local playerGUID = player:GetGUIDLow()
    local query = CharDBQuery("SELECT class FROM characters WHERE guid = " .. playerGUID)
    
    if query then
        local playerClass = query:GetUInt32(0)

        if playerClass == 4 then
            player:LearnSpell(674)
        end
    end
end

RegisterPlayerEvent(5, OnPlayerLogin)