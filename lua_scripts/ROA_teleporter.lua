local npc_id = 100007

local LOCATIONS = {
    {name = "Molten Core", map = 0, x = -7515.48, y = -1045.84, z = 182.30, o = 0.68},
    {name = "Onyxia's Lair", map = 1, x = -4706.43, y = -3727.33, z = 54.76, o = 3.64},
}

local function OnHello(event, player, object)
    player:GossipClearMenu()
    
    for i, location in ipairs(LOCATIONS) do
        player:GossipMenuAddItem(2, location.name, 0, i)
    end
    
    player:GossipMenuAddItem(0, "Nevermind", 0, 99)
    player:GossipSendMenu(1, object, 1)
end

local function OnSelect(event, player, object, sender, intid, code, menu_id)
    if intid >= 1 and intid <= #LOCATIONS then
        local loc = LOCATIONS[intid]
        player:Teleport(loc.map, loc.x, loc.y, loc.z, loc.o)
        player:SendBroadcastMessage("|c979ABDFFTeleported to " .. loc.name .. "!|r")
    end
    
    player:GossipComplete()
end

RegisterCreatureGossipEvent(npc_id, 1, OnHello)
RegisterCreatureGossipEvent(npc_id, 2, OnSelect)

