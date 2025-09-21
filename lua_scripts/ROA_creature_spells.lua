local AIO = AIO or require("AIO")

if not AIO.IsMainState() then
    return
end

if AIO.AddAddon() then

    -- interval is in milliseconds, and make sure that you put a , after every line you add
    -- make sure the last line doesent have a , otherwise it will error out
    local CREATURE_SPELLS_CONFIG = {
        {npcid = 11502, spellid = 19703, interval = 5000, target = "self"}, --Ragnaros
        {npcid = 11502, spellid = 19704, interval = 8000, target = "target"}, --Ragnaros
        {npcid = 12118, spellid = 100057, interval = 2000, target = "self"}, --Lucifron
        {npcid = 12118, spellid = 100059, interval = 11000, target = "self"}, --Lucifron
        {npcid = 11982, spellid = 100060, interval = 11000, target = "self"} -- Magmadar
    }

    local activeSpellTimers = {}

    local function GetCreatureSpells(npcId)
        local spells = {}
        for _, config in pairs(CREATURE_SPELLS_CONFIG) do
            if config.npcid == npcId then
                table.insert(spells, config)
            end
        end
        return spells
    end

    local function CastSpellForCreature(creature, spellConfig)
        if not creature or not creature:IsAlive() then
            return
        end

        if not creature:IsInCombat() then
            return
        end

        local target = nil
        if spellConfig.target == "self" then
            target = creature
        elseif spellConfig.target == "target" then
            target = creature:GetVictim()
            if not target then
                return
            end
        end

        if target then
            creature:CastSpell(target, spellConfig.spellid, false)
        end
    end

    local function StartSpellTimer(creature, spellConfig)
        local creatureGuid = creature:GetGUIDLow()
        local timerKey = creatureGuid .. "_" .. spellConfig.spellid

        if activeSpellTimers[timerKey] then
            RemoveEventById(activeSpellTimers[timerKey])
        end

        local eventId = CreateLuaEvent(function()
            local currentCreature = GetCreatureByGUID(creatureGuid)
            if currentCreature and currentCreature:IsAlive() and currentCreature:IsInCombat() then
                CastSpellForCreature(currentCreature, spellConfig)
            else
                if activeSpellTimers[timerKey] then
                    RemoveEventById(activeSpellTimers[timerKey])
                    activeSpellTimers[timerKey] = nil
                end
            end
        end, spellConfig.interval, 0)

        activeSpellTimers[timerKey] = eventId
    end

    local function StopSpellTimers(creature)
        local creatureGuid = creature:GetGUIDLow()
        local timersToRemove = {}

        for timerKey, eventId in pairs(activeSpellTimers) do
            if string.find(timerKey, tostring(creatureGuid)) then
                table.insert(timersToRemove, timerKey)
            end
        end

        for _, timerKey in pairs(timersToRemove) do
            if activeSpellTimers[timerKey] then
                RemoveEventById(activeSpellTimers[timerKey])
                activeSpellTimers[timerKey] = nil
            end
        end
    end

    local function OnCreatureSpawn(event, creature)
        local npcId = creature:GetEntry()
        local spells = GetCreatureSpells(npcId)

        if #spells > 0 then
            for _, spellConfig in pairs(spells) do
                StartSpellTimer(creature, spellConfig)
            end
        end
    end

    local function OnCreatureDeath(event, creature)
        StopSpellTimers(creature)
    end

    local function OnCreatureDespawn(event, creature)
        StopSpellTimers(creature)
    end

    local function RegisterCreatureEvents()
        local registeredNpcs = {}
        
        for _, config in pairs(CREATURE_SPELLS_CONFIG) do
            local npcId = config.npcid
            if not registeredNpcs[npcId] then
                RegisterCreatureEvent(npcId, 5, OnCreatureSpawn)
                RegisterCreatureEvent(npcId, 4, OnCreatureDeath)
                RegisterCreatureEvent(npcId, 37, OnCreatureDespawn)
                registeredNpcs[npcId] = true
            end
        end
    end

    RegisterCreatureEvents()
end
