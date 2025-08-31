local npc_id = 500557

local function OnHello(event, player, object)
    player:GossipClearMenu()

    local broodlord = object:GetNearestCreature(10000, 12017, 0, 0)
    local flamegor = object:GetNearestCreature(10000, 11981, 0, 0)

    player:GossipMenuAddItem(2, "Teleport to the entrance of Blackwing Lair", 0, 98)

    if broodlord:IsDead() == true then
        player:GossipMenuAddItem(2, "Teleport to Broodlord Lashlayer", 0, 1)
    else
        player:GossipMenuAddItem(9, "Broodlord Lashlayer is alive", 0, 2)
    end

    if flamegor:IsDead() == true then
        player:GossipMenuAddItem(2, "Teleport to Flamegor", 0, 3)
    else
        player:GossipMenuAddItem(9, "Flamegor is alive", 0, 4)
    end

    player:GossipMenuAddItem(0, "Goodbye.", 0, 99)
    player:GossipSendMenu(1, object, 1)
end

local function OnSelect(event, player, object, sender, intid, code, menu_id)
    if intid == 1 then
        player:SendBroadcastMessage("You've been teleported to Broodlord Lashlayer")
        player:Teleport(469, -7585, -1016, 451, 5.1)
    elseif intid == 3 then
        player:SendBroadcastMessage("You've been teleported to Flamegor")
        player:Teleport(469, -7443, -1050, 477, 3.4)
    elseif intid == 98 then
        player:SendBroadcastMessage("You've been teleported to the entrance of Blackwing Lair")
        player:Teleport(469, -7643, -1086, 409, 0.6)
    elseif intid == 99 then
        player:SendBroadcastMessage("Farewell!")
    end
    player:GossipComplete()
end

RegisterCreatureGossipEvent(npc_id, 1, OnHello)
RegisterCreatureGossipEvent(npc_id, 2, OnSelect)