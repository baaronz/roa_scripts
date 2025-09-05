local function OnGossipHello(event, player, object)
    player:GossipClearMenu()
    player:GossipMenuAddItem(0, "(Place your palm on the stone)", 0, 1)
    player:GossipSendMenu(1, object, 1)
end

local function OnGossipSelect(event, player, object, sender, intid, code, menu_id)
    local gobjguid = object:GetGUIDLow()
    local gobjguid1 = tostring(gobjguid)
    if intid == 1 then
        player:SendBroadcastMessage("You have placed your palm on the stone")
        player:SendBroadcastMessage("Gobj GUID: " .. gobjguid1)
    end
    player:GossipComplete()
end

RegisterGameObjectGossipEvent(63000, 1, OnGossipHello)
RegisterGameObjectGossipEvent(63000, 2, OnGossipSelect)