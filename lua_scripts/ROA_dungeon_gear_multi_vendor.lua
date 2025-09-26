local npc_id = 100003

local function OnHello(event, player, object)
    player:GossipClearMenu()
    player:GossipMenuAddItem(2, "Warrior", 0, 1)
    player:GossipMenuAddItem(2, "Paladin", 0, 2)
    player:GossipMenuAddItem(2, "Hunter", 0, 3)
    player:GossipMenuAddItem(2, "Rogue", 0, 4)
    player:GossipMenuAddItem(2, "Shaman", 0, 5)
    player:GossipMenuAddItem(2, "Mage", 0, 6)
    player:GossipMenuAddItem(2, "Priest", 0, 7)
    player:GossipMenuAddItem(2, "Warlock", 0, 8)
    player:GossipMenuAddItem(2, "Druid", 0, 9)
    player:GossipMenuAddItem(2, "Weapons", 0, 10)
    player:GossipMenuAddItem(2, "Offsets", 0, 11)
    player:GossipMenuAddItem(2, "Dungeon Gear", 0, 12)
    player:GossipMenuAddItem(0, "Goodbye.", 0, 99)
    player:GossipSendMenu(1, object, 1)
end

local function OnSelect(event, player, object, sender, intid, code, menu_id)
    if intid == 1 then
        player:SendListInventory(100010)
    elseif intid == 2 then
        player:SendListInventory(100011)
    elseif intid == 3 then
        player:SendListInventory(100012)
    elseif intid == 4 then
        player:SendListInventory(100013)
    elseif intid == 5 then
        player:SendListInventory(100014)
    elseif intid == 6 then
        player:SendListInventory(100015)
    elseif intid == 7 then
        player:SendListInventory(100016)
    elseif intid == 8 then
        player:SendListInventory(100017)
    elseif intid == 9 then
        player:SendListInventory(100018)
    elseif intid == 10 then
        player:SendListInventory(100019)
    elseif intid == 11 then
        player:SendListInventory(100020)
    elseif intid == 12 then
        player:SendListInventory(100021)
    elseif intid == 99 then
        player:SendBroadcastMessage("Farewell!")
    end
    player:GossipComplete()
end

RegisterCreatureGossipEvent(npc_id, 1, OnHello)
RegisterCreatureGossipEvent(npc_id, 2, OnSelect)
