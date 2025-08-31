local npc_id = 500556

local function OnHello(event, player, object)
    player:GossipClearMenu()

    local lucifron = object:GetNearestCreature(10000, 12118, 0, 0)
    local barongeddon = object:GetNearestCreature(10000, 12056, 0, 0)
    local ragnaros = object:GetNearestCreature(100000, 11502, 0, 0)

    player:GossipMenuAddItem(2, "Teleport to the entrance of Molten Core", 0, 98)

    if lucifron:IsDead() == true then
        player:GossipMenuAddItem(2, "Teleport to Lucifron", 0, 1)
    else
        player:GossipMenuAddItem(9, "Lucifron is alive", 0, 2)
    end

    if barongeddon:IsDead() == true then
        player:GossipMenuAddItem(2, "Teleport to Baron Geddon", 0, 3)
    else
        player:GossipMenuAddItem(9, "Baron Geddon is alive", 0, 4)
    end

    if barongeddon:IsDead() == true then
        player:GossipMenuAddItem(2, "Teleport to Ragnaros", 0, 5)
    else
        player:GossipMenuAddItem(9, "Baron Geddon is alive", 0, 6)
    end

    player:GossipMenuAddItem(0, "Goodbye.", 0, 99)
    player:GossipSendMenu(1, object, 1)
end

local function OnSelect(event, player, object, sender, intid, code, menu_id)
    if intid == 1 then
        player:SendBroadcastMessage("You've been teleported to Lucifron")
        player:Teleport(409, 965, -920, -175, 5)
    elseif intid == 3 then
        player:SendBroadcastMessage("You've been teleported to Baron Geddon")
        player:Teleport(409, 700, -720, -207, 5)
    elseif intid == 5 then
        player:SendBroadcastMessage("You've been teleported to Ragnaros")
        player:Teleport(409, 750, -730, -207, 5)
    elseif intid == 98 then
        player:SendBroadcastMessage("You've been teleported to the entrance of Molten Core")
        player:Teleport(409, 1070, -493, -106, 3.8)
    elseif intid == 99 then
        player:SendBroadcastMessage("Farewell!")
    end
    player:GossipComplete()
end

RegisterCreatureGossipEvent(npc_id, 1, OnHello)
RegisterCreatureGossipEvent(npc_id, 2, OnSelect)