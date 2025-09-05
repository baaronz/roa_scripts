local function OnGossipHello(event, player, object)
    player:GossipClearMenu()
    player:GossipMenuAddItem(0, "(Place your palm on the stone)", 0, 1)
    player:GossipSendMenu(1, object, 1)
end

local function OnGossipSelect(event, player, object, sender, intid, code, menu_id)
    local gobjguid = object:GetEntry()
    local gobjguid1 = tostring(gobjguid)

    local posx = WorldDBQuery("SELECT position_x FROM gameobject WHERE guid = " .. gobjguid1)
    local posy = WorldDBQuery("SELECT position_y FROM gameobject WHERE guid = " .. gobjguid1)
    local posz = WorldDBQuery("SELECT position_z FROM gameobject WHERE guid = " .. gobjguid1)
    local poso = WorldDBQuery("SELECT orientation FROM gameobject WHERE guid = " .. gobjguid1)

    local posxnum = posx:GetFloat(0)
    local posynum = posy:GetFloat(0)
    local posznum = posz:GetFloat(0)
    local posonum = poso:GetFloat(0)
    
    local posx1 = math.floor(posxnum + 0.01)

    if intid == 1 then
        player:SendBroadcastMessage("You have placed your palm on the stone")
        player:SendBroadcastMessage("Gobj GUID: " .. gobjguid1)
        player:SendBroadcastMessage("PosX: " .. posx .. "PosY: " .. posy .. "PosZ: " .. posz .. "PosO: " .. poso)
        player:SendBroadcastMessage("PosX1: " .. posx1)
        object:SpawnCreature(63003, posx1, posy, posz, poso, 6, 20)
    end
    player:GossipComplete()
end

RegisterGameObjectGossipEvent(63000, 1, OnGossipHello)
RegisterGameObjectGossipEvent(63000, 2, OnGossipSelect)