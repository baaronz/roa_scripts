local CREATURE_ID = 9000011 -- Reanu Keeves
local RESET_TEXT = "Reset all my instance locks."
local RESET_POPUP = "Do you want to reset all your instance locks?"
local RESET_MSG = "Your instance locks were reset!"
local RESET_COST = 4000000 -- 4000000 Copper = 400 Gold

local function OnGossipHello(event, player, unit)
    player:GossipMenuAddItem(6, RESET_TEXT, 1, 1, false, RESET_POPUP, RESET_COST)
    player:GossipSendMenu(1, unit)
end

local function OnGossipSelect(event, player, object, sender, intid, code, menu_id)
    if (intid == 1) then
        player:ModifyMoney(-RESET_COST)
        player:UnbindAllInstances()
        object:SendChatMessageToPlayer(0, 0, RESET_MSG, player)
    end

    player:GossipComplete()
end

RegisterCreatureGossipEvent(CREATURE_ID, 1, OnGossipHello)
RegisterCreatureGossipEvent(CREATURE_ID, 2, OnGossipSelect)