local npc_id = 100006

-- Array of buff spell IDs to apply to the party/raid
local BUFF_SPELLS = {
    16609, -- Warchiefs Blessing
    22888, -- Rallying Cry
    24425  -- Spirit of Zandalar
}

local function OnHello(event, player, object)
    player:GossipClearMenu()
    player:GossipMenuAddItem(2, "Buff my party (50 gold)", 0, 1)
    player:GossipMenuAddItem(0, "Goodbye.", 0, 99)
    player:GossipSendMenu(1, object, 1)
end

local function GetGroupMembers(player)
    local groupMembers = {}
    
    if player:IsInGroup() then
        local group = player:GetGroup()
        if group then
            local members = group:GetMembers()
            for _, member in pairs(members) do
                if member and member:IsInWorld() then
                    table.insert(groupMembers, member)
                end
            end
        end
    else
        table.insert(groupMembers, player)
    end
    
    return groupMembers
end

local function ApplyBuffsToPlayer(targetPlayer, caster)
    local buffsApplied = 0
    
    for _, spellId in ipairs(BUFF_SPELLS) do
        if GetSpellInfo(spellId) then
            caster:CastSpell(targetPlayer, spellId, true)
            buffsApplied = buffsApplied + 1
        end
    end
    
    return buffsApplied
end

local function OnSelect(event, player, object, sender, intid, code, menu_id)
    if intid == 1 then
		local money = player:GetCoinage()
        local groupMembers = GetGroupMembers(player)
        local totalBuffsApplied = 0
        local buffedPlayers = 0
		
		if money < 500000 then
            player:SendBroadcastMessage("|c979ABDFFNot enough coins to buff your party.|r")
			return
		end
		
        player:ModifyMoney(-500000)
		
        for _, member in ipairs(groupMembers) do
            if member and member:IsInWorld() then
                local buffsApplied = ApplyBuffsToPlayer(member, object)
                totalBuffsApplied = totalBuffsApplied + buffsApplied
                buffedPlayers = buffedPlayers + 1
            end
        end
        
        if buffedPlayers > 0 then
            player:SendBroadcastMessage("|c979ABDFFAdded " .. totalBuffsApplied .. " buffs to " .. buffedPlayers .. " players.|r")
        else
            player:SendBroadcastMessage("|c979ABDFFNo group members found to buff!|r")
        end
        
    elseif intid == 99 then
        player:SendBroadcastMessage("Farewell!")
    end
    
    player:GossipComplete()
end

RegisterCreatureGossipEvent(npc_id, 1, OnHello)
RegisterCreatureGossipEvent(npc_id, 2, OnSelect)
