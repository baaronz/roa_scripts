local AIO = AIO or require("AIO")

if not AIO.IsMainState() then
    return
end

if AIO.AddAddon() then
    local MYTHIC_NPC_ID = 500565
    local GOSSIP_MENU_ID = 90003
    local TEXT_ID = 110001
    
    local ALLOWED_MAP_IDS = { 409 }
    local MYTHIC_SCAN_RADIUS = 500
    local DEAD_CREATURE_CHECK_RADIUS = 1000
    local TELEPORT_DELAY = 5
    local AURA_LOOP_INTERVAL = 20000
    
    local TELEPORT_LOCATIONS = {
        [409] = {
            map = 409,
            x = 1074.109,
            y = -486.803,
            z = -108.25,
            o = 5.403
        },
        [469] = {
            map = 469,
            x = -7643,
            y = -1086,
            z = 409,
            o = 0.6
        }
    }
    
    local FRIENDLY_FACTIONS = {
        [1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [6] = true, [14] = true, [31] = true, [35] = true,
        [114] = true, [115] = true, [116] = true, [188] = true, [190] = true, [1610] = true, [1629] = true,
        [1683] = true, [1718] = true, [1770] = true
    }
    
    local IGNORE_BUFF_ENTRIES = { [30172] = true, [30173] = true, [29630] = true, [28351] = true, [24137] = true, [37596] = true }
    
    local MYTHIC_TIERS = {
        [1] = {
            name = "Mythic Tier 1",
            auras = { 99001, 1, 1 },
            description = "Activate Mythic Tier 1"
        },
        [2] = {
            name = "Mythic Tier 2", 
            auras = { 99002, 1, 1 },
            description = "Activate Mythic Tier 2"
        },
        [3] = {
            name = "Mythic Tier 3",
            auras = { 99003, 1, 1 },
            description = "Activate Mythic Tier 3"
        }
    }
    
    local MAP_CONFIGS = {
        [409] = {
            final_boss_entry = 11502,
            final_boss_name = "Ragnaros",
            boss_entries = { 12118, 11982, 11502, 12259, 12057, 12264, 12056, 11988, 12098, 11502 },
            token_item_id = 60601,
            token_item_name = "Challengers Token I"
        },
        [469] = {
            final_boss_entry = 11583,
            final_boss_name = "Nefarian",
            boss_entries = { 12017 },
            token_item_id = 19019,
            token_item_name = "Mythic Token"
        }
    }
    
    local mythicState = {
        active = false,
        currentTier = 0,
        activatedBy = nil,
        activatedTime = 0
    }
    
    local MYTHIC_LOOP_HANDLERS = {}
    local MYTHIC_KILL_LOCK = {}
    
    local function IsMapAllowed(player)
        return true
    end
    
    local function IsRaidLeader(player)
        if not player then return false end
        
        local group = player:GetGroup()
        if not group then return false end
        
        return group:IsLeader(player:GetGUID())
    end
    
    local function CheckForDeadCreatures(player)
        if not player then return false, 0 end
        
        local creatures = player:GetCreaturesInRange(DEAD_CREATURE_CHECK_RADIUS)
        if not creatures then return false, 0 end
        
        local deadCount = 0
        for _, creature in pairs(creatures) do
            if creature and not creature:IsAlive() and not creature:IsPlayer() then
                local faction = creature:GetFaction()
                local entry = creature:GetEntry()
                
                -- Only count hostile creatures, ignore friendly ones
                if not FRIENDLY_FACTIONS[faction] and not IGNORE_BUFF_ENTRIES[entry] then
                    deadCount = deadCount + 1
                end
            end
        end
        
        return deadCount > 0, deadCount
    end
    
    local function CleanupDeadCreatures(player)
        if not player then return 0 end
        
        local creatures = player:GetCreaturesInRange(DEAD_CREATURE_CHECK_RADIUS)
        if not creatures then return 0 end
        
        local cleanedCount = 0
        for _, creature in pairs(creatures) do
            if creature and not creature:IsAlive() and not creature:IsPlayer() then
                local faction = creature:GetFaction()
                local entry = creature:GetEntry()
                
                -- Only clean up hostile creatures, ignore friendly ones
                if not FRIENDLY_FACTIONS[faction] and not IGNORE_BUFF_ENTRIES[entry] then
                    creature:DespawnOrUnsummon(0)
                    cleanedCount = cleanedCount + 1
                end
            end
        end
        
        return cleanedCount
    end
    
    local function TeleportEntireRaid(player)
        if not player then return end
        
        local group = player:GetGroup()
        local mapId = player:GetMapId()
        local teleportData = TELEPORT_LOCATIONS[mapId]
        
        if not teleportData then
            player:SendBroadcastMessage("|c979ABDFFNo teleport location configured for this map.|r")
            return
        end
        
        local teleportedCount = 0
        
        if not group then
            -- Single player teleport
            player:Teleport(teleportData.map, teleportData.x, teleportData.y, teleportData.z, teleportData.o)
            player:SendBroadcastMessage("|c979ABDFFYou have been teleported to the raid location!|r")
            teleportedCount = 1
        else
            -- Raid teleport
            local members = group:GetMembers()
            for _, member in pairs(members) do
                if member and member:IsInWorld() and member:IsAlive() then
                    member:Teleport(teleportData.map, teleportData.x, teleportData.y, teleportData.z, teleportData.o)
                    member:SendBroadcastMessage("|c979ABDFFYou have been teleported to the raid location!|r")
                    teleportedCount = teleportedCount + 1
                end
            end
            
            -- Send confirmation to raid leader
            if teleportedCount > 0 then
                player:SendBroadcastMessage("|c979ABDFFSuccessfully teleported " .. teleportedCount .. " raid members to the mythic location!|r")
            end
        end
    end
    
    local function RemoveAllMythicAuras(player)
        if not player then return end
        
        local creatures = player:GetCreaturesInRange(MYTHIC_SCAN_RADIUS)
        if not creatures then return end
        
        for _, creature in pairs(creatures) do
            if creature and creature:IsAlive() and not creature:IsPlayer() then
                for tier, tierData in pairs(MYTHIC_TIERS) do
                    for _, auraId in ipairs(tierData.auras) do
                        if creature:HasAura(auraId) then
                            creature:RemoveAura(auraId)
                        end
                    end
                end
            end
        end
    end
    
    local function CleanupMythicInstance()
        if MYTHIC_LOOP_HANDLERS[mythicState.currentTier] then
            RemoveEventById(MYTHIC_LOOP_HANDLERS[mythicState.currentTier])
            MYTHIC_LOOP_HANDLERS[mythicState.currentTier] = nil
        end
    end
    
    local function ApplyMythicAuras(tier, player)
        if not MYTHIC_TIERS[tier] or not player then return 0 end
        
        local aurasApplied = 0
        local seen = {}
        
        local creatures = player:GetCreaturesInRange(MYTHIC_SCAN_RADIUS)
        if not creatures then return 0 end
        
        for _, creature in pairs(creatures) do
            if creature and creature:IsAlive() and not creature:IsPlayer() then
                local guid = creature:GetGUIDLow()
                local faction = creature:GetFaction()
                local entry = creature:GetEntry()
                
                if not seen[guid] then
                    if not IGNORE_BUFF_ENTRIES[entry] and (not FRIENDLY_FACTIONS[faction] or entry == 26861 or creature:GetName() == "King Ymiron") then
                        seen[guid] = true
                        
                        for _, auraId in ipairs(MYTHIC_TIERS[tier].auras) do
                            if not creature:HasAura(auraId) then
                                creature:CastSpell(creature, auraId, true)
                                aurasApplied = aurasApplied + 1
                            end
                        end
                    end
                end
            end
        end
        
        return aurasApplied
    end
    
    local function StartAuraLoop(player, tier, mapId)
        if MYTHIC_LOOP_HANDLERS[tier] then
            RemoveEventById(MYTHIC_LOOP_HANDLERS[tier])
        end
        
        local guid = player:GetGUIDLow()
        
        local eventId = CreateLuaEvent(function()
            if mythicState.active and mythicState.currentTier == tier then
                local p = GetPlayerByGUID(guid)
                if p and p:GetMapId() == mapId then
                    ApplyMythicAuras(tier, p)
                end
            end
        end, AURA_LOOP_INTERVAL, 0)
        
        MYTHIC_LOOP_HANDLERS[tier] = eventId
    end
    
    local function ActivateMythicTier(player, tier, npc)
        if not IsMapAllowed(player) then
            player:SendBroadcastMessage("|c979ABDFFThis can only be used in specific instances.|r")
            return
        end
        
        if not IsRaidLeader(player) then
            player:SendBroadcastMessage("|c979ABDFFOnly the Raid Leader can start Mythic difficulties.|r")
            return
        end
        
        local map = player:GetMap()
        if not map then
            player:SendBroadcastMessage("|c979ABDFFNo map context.|r")
            return
        end
        
        local instanceId = map:GetInstanceId()
        
        if MYTHIC_KILL_LOCK[instanceId] then
            player:SendBroadcastMessage("|c979ABDFFCannot start Mythic difficulty because creatures have already been killed. Reset the dungeon to enable Mythic mode.|r")
            return
        end
        
        -- Check for dead creatures in the area and clean them up
        local hasDeadCreatures, deadCount = CheckForDeadCreatures(player)
        if hasDeadCreatures then
            player:SendBroadcastMessage("|c979ABDFFFound " .. deadCount .. " dead creatures in the area. Cleaning up...|r")
            local cleanedCount = CleanupDeadCreatures(player)
            if cleanedCount > 0 then
                player:SendBroadcastMessage("|c979ABDFFCleaned up " .. cleanedCount .. " dead creatures.|r")
            end
        end
        
        if mythicState.active then
            RemoveAllMythicAuras(player)
        end
        
        mythicState.active = true
        mythicState.currentTier = tier
        mythicState.activatedBy = player:GetName()
        mythicState.activatedTime = os.time()
        
        player:SendBroadcastMessage("|c979ABDFF" .. MYTHIC_TIERS[tier].name .. " will be activated in " .. TELEPORT_DELAY .. " seconds!|r")
        player:SendBroadcastMessage("|c979ABDFFActivated by: " .. player:GetName() .. "|r")
        player:SendBroadcastMessage("|c979ABDFFPreparing to teleport entire raid to mythic location...|r")
        
        local guid = player:GetGUIDLow()
        local mapId = player:GetMapId()
        
        CreateLuaEvent(function()
            local p = GetPlayerByGUID(guid)
            if p then
                TeleportEntireRaid(p)
                ApplyMythicAuras(tier, p)
                SendWorldMessage("|c979ABDFF" .. MYTHIC_TIERS[tier].name .. " has been activated!|r")
                StartAuraLoop(p, tier, mapId)
            end
        end, TELEPORT_DELAY * 1000, 1)
    end
    
    local function ResetMythicMode(player)
        if not IsRaidLeader(player) then
            player:SendBroadcastMessage("|c979ABDFFOnly the Raid Leader can return to normal mode.|r")
            return
        end
        
        if not mythicState.active then
            player:SendBroadcastMessage("|c979ABDFFNo mythic mode is currently active.|r")
            return
        end
        
        RemoveAllMythicAuras(player)
        CleanupMythicInstance()
        mythicState.active = false
        mythicState.currentTier = 0
        mythicState.activatedBy = nil
        mythicState.activatedTime = 0
        
        local map = player:GetMap()
        if map then
            local instanceId = map:GetInstanceId()
            MYTHIC_KILL_LOCK[instanceId] = nil
        end
        
        TeleportEntireRaid(player)
        player:SendBroadcastMessage("|c979ABDFFMythic mode has been reset to normal.|r")
    end
    
    local function OnHello(event, player, object)
        player:GossipClearMenu()
        
        if not IsMapAllowed(player) then
            player:GossipMenuAddItem(9, "This NPC can only be used in specific instances", 0, 99)
            player:GossipSendMenu(TEXT_ID, object, GOSSIP_MENU_ID)
            return
        end
        
        local map = player:GetMap()
        if map then
            local instanceId = map:GetInstanceId()
            if MYTHIC_KILL_LOCK[instanceId] then
                player:GossipMenuAddItem(9, "Mythic mode is locked. Reset the dungeon to enable Mythic difficulties.", 0, 99)
                player:GossipSendMenu(TEXT_ID, object, GOSSIP_MENU_ID)
                return
            end
        end
        
        if mythicState.active then
            player:GossipMenuAddItem(9, "Mythic " .. MYTHIC_TIERS[mythicState.currentTier].name .. " is currently active", 0, 99)
            player:GossipMenuAddItem(9, "Activated by: " .. mythicState.activatedBy, 0, 99)
        else
            for tier = 1, 3 do
                local tierData = MYTHIC_TIERS[tier]
                if tierData then
                    player:GossipMenuAddItem(2, tierData.description, 0, tier)
                end
            end
        end
        
        player:GossipMenuAddItem(1, "Reset to Normal Mode", 0, 0)
        player:GossipMenuAddItem(0, "Goodbye.", 0, 99)
        player:GossipSendMenu(TEXT_ID, object, GOSSIP_MENU_ID)
    end
    
    local function OnSelect(event, player, object, sender, intid, code, menu_id)
        if intid == 0 then
            if not IsRaidLeader(player) then
                player:SendBroadcastMessage("|c979ABDFFOnly the Raid Leader can return to normal mode.|r")
            else
                ResetMythicMode(player)
            end
        elseif intid == 99 then
            player:SendBroadcastMessage("Farewell!")
        elseif MYTHIC_TIERS[intid] then
            ActivateMythicTier(player, intid, object)
        end
        player:GossipComplete()
    end
    
    local function OnKillCreature(event, killer, killed)
        if not killer or not killer:IsPlayer() or not killed or killed:GetObjectType() ~= "Creature" then return end

        local map = killer:GetMap()
        if not map or not map:IsDungeon() or map:GetDifficulty() < 1 then return end

        local instanceId = map:GetInstanceId()
        local mapId = map:GetMapId()

        if killer:GetLevel() < 80 then return end
        if mythicState.active or MYTHIC_KILL_LOCK[instanceId] then return end

        local mapConfig = MAP_CONFIGS[mapId]
        if mapConfig then
            local finalBoss = mapConfig.final_boss_entry
            if finalBoss and killed:GetEntry() == finalBoss then return end
        end

        local faction = killed:GetFaction()
        if FRIENDLY_FACTIONS[faction] then return end

        MYTHIC_KILL_LOCK[instanceId] = true

        local msg = "|c979ABDFFMythic mode is now locked because a hostile enemy was slain. Reset the dungeon to enable Mythic mode.|r"
        for _, player in pairs(map:GetPlayers() or {}) do
            player:SendBroadcastMessage(msg)
        end
    end
    
    local function OnKillCreatureMythic(event, killer, killed)
        if not mythicState.active then 
            return 
        end
        
        if not killer or not killer:IsPlayer() then
            return
        end
        
        local entry = killed:GetEntry()
        local mapId = killer:GetMapId()
        local mapConfig = MAP_CONFIGS[mapId]
        
        if not mapConfig then 
            return 
        end
        
        local isBoss = false
        if mapConfig.boss_entries then
            for _, bossEntry in pairs(mapConfig.boss_entries) do
                if bossEntry == entry then
                    isBoss = true
                    break
                end
            end
        end
        
        if isBoss then
            local map = killer:GetMap()
            if map then
                local players = map:GetPlayers()
                if players then
                    for _, player in pairs(players) do
                        if player and player:IsAlive() and player:IsInWorld() then
                            player:AddItem(mapConfig.token_item_id, 1)
                        end
                    end
                end
            end
            SendWorldMessage("|c979ABDFF" .. killed:GetName() .. " has been defeated! All raid members received a " .. mapConfig.token_item_name .. "!|r")
        end
        
        if entry == mapConfig.final_boss_entry then
            SendWorldMessage("|c979ABDFF" .. mapConfig.final_boss_name .. " has been defeated! Mythic " .. MYTHIC_TIERS[mythicState.currentTier].name .. " completed!|r")
            SendWorldMessage("|c979ABDFFCongratulations to the raid for completing " .. MYTHIC_TIERS[mythicState.currentTier].name .. "!|r")
            
            RemoveAllMythicAuras(killer)
            CleanupMythicInstance()
            mythicState.active = false
            mythicState.currentTier = 0
            mythicState.activatedBy = nil
            mythicState.activatedTime = 0
        end
    end
    
    RegisterCreatureGossipEvent(MYTHIC_NPC_ID, 1, OnHello)
    RegisterCreatureGossipEvent(MYTHIC_NPC_ID, 2, OnSelect)
    
    RegisterPlayerEvent(7, OnKillCreature)
    RegisterPlayerEvent(7, OnKillCreatureMythic)
end
