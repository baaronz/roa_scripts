local npc_id = 500558

-- Array of buff spell IDs to apply to the party/raid
local BUFF_SPELLS = {
    1126,
    1127
}

local function OnHello(event, player, object)
    player:GossipClearMenu()
    player:GossipMenuAddItem(2, "Buff my party", 0, 1)
    player:GossipMenuAddItem(0, "Goodbye.", 0, 99)
    player:GossipSendMenu(1, object, 1)
end

local function GetGroupMembers(player)
    local groupMembers = {}
    
    -- Check if player is in a group or raid
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
        -- If not in group, just buff the player
        table.insert(groupMembers, player)
    end
    
    return groupMembers
end

local function ApplyBuffsToPlayer(targetPlayer, caster)
    local buffsApplied = 0
    
    for _, spellId in ipairs(BUFF_SPELLS) do
        -- Check if the spell exists and can be cast
        if GetSpellInfo(spellId) then
            -- Cast the buff on the target player
            caster:CastSpell(targetPlayer, spellId, true)
            buffsApplied = buffsApplied + 1
        end
    end
    
    return buffsApplied
end

local function OnSelect(event, player, object, sender, intid, code, menu_id)
    if intid == 1 then
        local groupMembers = GetGroupMembers(player)
        local totalBuffsApplied = 0
        local buffedPlayers = 0
        
        -- Apply buffs to all group members
        for _, member in ipairs(groupMembers) do
            if member and member:IsInWorld() then
                local buffsApplied = ApplyBuffsToPlayer(member, object)
                totalBuffsApplied = totalBuffsApplied + buffsApplied
                buffedPlayers = buffedPlayers + 1
            end
        end
        
        -- Send feedback message
        if buffedPlayers > 0 then
            player:SendBroadcastMessage("|cff00ff00Successfully applied " .. totalBuffsApplied .. " buffs to " .. buffedPlayers .. " group member(s)!|r")
        else
            player:SendBroadcastMessage("|cffff0000No group members found to buff!|r")
        end
        
    elseif intid == 99 then
        player:SendBroadcastMessage("Farewell!")
    end
    
    player:GossipComplete()
end

RegisterCreatureGossipEvent(npc_id, 1, OnHello)
RegisterCreatureGossipEvent(npc_id, 2, OnSelect)
