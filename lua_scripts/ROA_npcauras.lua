-- Configuration: Number of auras to apply to each NPC (change this value as needed)
local AURAS_TO_APPLY = 3

-- Array of NPC IDs that this script will work on
local TARGET_NPC_IDS = {
    11111,
    11111
}

-- Array of spell IDs for auras
local AURA_SPELLS = {
    11111,
    11111  
}

local function IsTargetNPC(npcId)
    for _, targetId in ipairs(TARGET_NPC_IDS) do
        if targetId == npcId then
            return true
        end
    end
    return false
end

local function GetRandomAuras(count)
    local selectedAuras = {}
    local availableAuras = {}
    
    for _, spellId in ipairs(AURA_SPELLS) do
        table.insert(availableAuras, spellId)
    end
    
    for i = 1, math.min(count, #availableAuras) do
        local randomIndex = math.random(1, #availableAuras)
        table.insert(selectedAuras, availableAuras[randomIndex])
        table.remove(availableAuras, randomIndex)
    end
    
    return selectedAuras
end

local function ApplyAurasToCreature(creature)
    if not creature or not creature:IsAlive() then
        return
    end
    
    local npcId = creature:GetEntry()
    if not IsTargetNPC(npcId) then
        return
    end
    
    local aurasToApply = GetRandomAuras(AURAS_TO_APPLY)
    
    for _, spellId in ipairs(aurasToApply) do
        creature:CastSpell(creature, spellId, true)
    end
    
    local players = creature:GetPlayersInRange(100)
    if players then
        for _, player in pairs(players) do
            player:SendBroadcastMessage("|cff00ff00NPC " .. creature:GetName() .. " has been granted " .. #aurasToApply .. " random auras!|r")
        end
    end
end

local function OnCreatureSpawn(event, creature)
    CreateLuaEvent(function()
        ApplyAurasToCreature(creature)
    end, 1000, 1)
end

local function RegisterNPCEvents()
    for _, npcId in ipairs(TARGET_NPC_IDS) do
        RegisterCreatureEvent(npcId, 5, OnCreatureSpawn)
    end
end

RegisterNPCEvents()

local function OnCommand(event, player, command)
    if command == "applyauras" then
        local target = player:GetSelection()
        if target and target:ToCreature() then
            local creature = target:ToCreature()
            ApplyAurasToCreature(creature)
            player:SendBroadcastMessage("|cff00ff00Applied auras to " .. creature:GetName() .. "|r")
        else
            player:SendBroadcastMessage("|cffff0000Please select a creature first!|r")
        end
        return false
    end
    return true
end

RegisterPlayerEvent(42, OnCommand)