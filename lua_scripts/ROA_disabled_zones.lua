local function SendMessage(player)
    player:SendBroadcastMessage("|c979ABDFFYou tried to enter a restricted zone.|r")
    player:SendBroadcastMessage("|c979ABDFFYou've been teleported to a faction neutral zone.|r")
    player:SendAreaTriggerMessage("|c979ABDFFYou've been teleported to a faction neutral zone.|r")
    player:SendAreaTriggerMessage("|c979ABDFFYou tried to enter a restricted zone.|r") 
    player:Teleport(1, -7161.2, -3808.1, 9.2, 0.67) -- Tanaris tp
end

local function OnMapChange(event, player)
    if player:IsGM() == true then
        return
    end

    if player:GetZoneId() == 3483 then
        SendMessage(player)
    end

    if player:GetZoneId() == 3521 then
        SendMessage(player)
    end

    if player:GetZoneId() == 3522 then
        SendMessage(player)
    end

    if player:GetZoneId() == 3523 then 
        SendMessage(player)
    end

    if player:GetZoneId() == 3518 then
        SendMessage(player)
    end

    if player:GetZoneId() == 3519 then
        SendMessage(player)
    end

    if player:GetZoneId() == 3520 then
        SendMessage(player)
    end

    if player:GetZoneId() == 3537 then
        SendMessage(player)
    end

    if player:GetZoneId() == 3711 then
        SendMessage(player)
    end

    if player:GetZoneId() == 210 then
        SendMessage(player)
    end

    if player:GetZoneId() == 67 then
        SendMessage(player)
    end

    if player:GetZoneId() == 66 then
        SendMessage(player)
    end

    if player:GetZoneId() == 394 then
        SendMessage(player)
    end

    if player:GetZoneId() == 495 then
        SendMessage(player)
    end

    if player:GetZoneId() == 3703 then
        SendMessage(player)
    end

    if player:GetZoneId() == 4395 then
        SendMessage(player)
    end
end

RegisterPlayerEvent(28, OnMapChange)