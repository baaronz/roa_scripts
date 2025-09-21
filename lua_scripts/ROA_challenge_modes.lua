local npc_id = 250000
local gossip_menu_id = 90002
local text_id = 110000

local function OnHello(event, player, object, sender, intid, code, menu_id)
    player:GossipMenuAddItem(20, "|TInterface\\Icons\\Ability_Warrior_Rampage:40:40|t Hardcore Mode", 0, 1)
    player:GossipMenuAddItem(20, "|TInterface\\Icons\\inv_misc_fish_turtle_02:40:40|t Turtle Mode", 0, 2)
    player:GossipMenuAddItem(0, "Goodbye.", 0, 99)
    player:GossipSendMenu(text_id, object, gossip_menu_id)
end

local function OnSelect(event, player, object, sender, intid, code, menu_id)
    if intid == 1 then
        player:SendBroadcastMessage("Hardcore Mode is not available yet.")
    elseif intid == 99 then
        player:SendBroadcastMessage("Farewell!")
    end
    player:GossipComplete()
end

RegisterCreatureGossipEvent(npc_id, 1, OnHello)
RegisterCreatureGossipEvent(npc_id, 2, OnSelect)