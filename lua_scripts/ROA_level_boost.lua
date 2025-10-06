local command = "boost"

function OnCommand(event, player, message, type, language)
    if (message == command) then
        local currentLevel = player:GetLevel()
        local targetLevel = 60
        
        if currentLevel >= targetLevel then
            player:SendBroadcastMessage("|c979ABDFF You are already level 60.|r")
            return false
        end  
        player:SetLevel(targetLevel)     
        player:SendBroadcastMessage("|c979ABDFF You are now level 60.|r") 
        return false
    end
end

RegisterPlayerEvent(42, OnCommand)
