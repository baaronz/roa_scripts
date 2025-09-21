local TABLE_NAME = "xp_bonus_enable"
local DEFAULT_NUM = 1

local function SetEnabled(player, num)
    local guid = player:GetGUIDLow()
    CharDBExecute("INSERT INTO " .. TABLE_NAME .. " (guid, num) VALUES (" .. guid .. ", " .. num .. ") ON DUPLICATE KEY UPDATE num = " .. num)
    --player:SendBroadcastMessage("DB WAS UPDATED " .. num )
end

local function GetState(player)
    local guid = player:GetGUIDLow()
    local result = CharDBQuery("SELECT num FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
    if result then
        return result:GetFloat(0)
    end
    return DEFAULT_NUM
end

local function OnCommand(event, player, command)
    local cmd, arg = command:match("^(%S+)%s*(%S*)$")

    if cmd == "xpbonus" then
        local num = tonumber(arg)
        
        if num == 0 then 
            SetEnabled(player,num)
            player:SendBroadcastMessage("|c979ABDFFYou have disabled gathering and crafting bonus xp.|r")
            return false
        end

        if num == 1 then 
            SetEnabled(player,num)
            player:SendBroadcastMessage("|c979ABDFFYou have enabled gathering and crafting bonus xp.|r")
            return false
        end

        if num == nil then
            player:SendBroadcastMessage("|c979ABDFFThis command will enable/disable your gathering and crafting bonus.|r")
            player:SendBroadcastMessage("|c979ABDFFUsage: .xpbonus (number)|r")
            player:SendBroadcastMessage("|c979ABDFFEnabled: 1 Disabled: 0|r")
            return false
        end
    end
end

local blacklistedItemIDs = {
    [34722] = true, [8545] = true, [34721] = true, [8544] = true, [14530] = true, [6450] = true,
    [6451] = true, [20235] = true, [44646] = true, [21991] = true, [1251] = true, [21990] = true,
    [2581] = true, [3531] = true, [20067] = true, [3530] = true, [19066] = true, [20066] = true,
    [20234] = true, [20244] = true, [38643] = true, [19067] = true, [19307] = true, [20065] = true,
    [20232] = true, [20237] = true, [20243] = true, [38640] = true, [14529] = true, [19068] = true,
    [6265] = true, [22103] = true, [36890] = true, [36892] = true, [19005] = true, [36894] = true,
    [22105] = true, [19011] = true,[19007] = true, [5510] = true, [5511] = true, [19008] = true,
    [36889] = true, [36891] = true,[19009] = true, [22104] = true, [19006] = true, [19010] = true,
    [19013] = true, [36893] = true, [5509] = true, [5512] = true, [9421] = true, [19004] = true,
    [19012] = true, [36895] = true, [16893] = true, [16892] = true, [16895] = true, [22116] = true,
    [16896] = true, [5232] = true, [5514] = true, [5513] = true, [8007] = true, [8008] = true,
    [22044] = true, [33312] = true, [42955] = true, [43523] = true, [41170] = true, [41169] = true,
    [41171] = true, [41172] = true, [40773] = true, [41173] = true, [41174] = true, [41191] = true,
    [41192] = true, [41193] = true, [41194] = true, [41195] = true, [41196] = true, [34497] = true,
    [18640] = true, [5350] = true, [2288] = true, [34062] = true, [43518] = true, [8079] = true,
    [1113] = true, [2136] = true, [8077] = true, [8075] = true, [22018] = true, [22019] = true,
    [30703] = true, [22895] = true, [5349] = true, [1114] = true, [8078] = true, [8076] = true,
    [3772] = true, [1487] = true, [10938] = true, [10939] = true, [11082] = true, [10998] = true,
    [11135] = true, [11134] = true, [11175] = true, [11174] = true, [16203] = true, [16202] = true,
    [22446] = true, [22447] = true, [34055] = true, [34056] = true,
    [8690] = true, 
    [54318] = true,
    [00000] = true, 
}

local multiplier = 10

local function OnCreateItem(event, player, item, count)
    local level = player:GetLevel()
    local enabled = GetState(player)
    if level >= 10 and level < 20 then multiplier = 20 end   
    if level >= 20 and level < 30 then multiplier = 25 end
    if level >= 30 and level < 40 then multiplier = 31 end
    if level >= 40 and level < 50 then multiplier = 35 end
    if level >= 50 and level < 59 then multiplier = 37 end
    if level == 60 then multiplier = 75 end
    local xp = math.floor(level * multiplier)
    if blacklistedItemIDs[item:GetEntry()] then
        return
    else
        if enabled == 1 then
            player:GiveXP(xp)
            player:SendBroadcastMessage("|c979ABDFFYou gained|r " .. xp .. " |c979ABDFFbonus XP for crafting!|r")
        end
    end
end

local gatheringItemIDs = {
    [2770] = true, [36909] = true, [36910] = true, [10620] = true, [36912] = true, [23424] = true, 
    [23425] = true, [23427] = true, [2775] = true, [3858] = true, [2772] = true, [2771] = true, 
    [2776] = true, [23426] = true, [11370] = true, [7911] = true, [18562] = true, [2798] = true, 
    [32464] = true, [5833] = true, [19726] = true, [765] = true, [22789] = true, [13467] = true, 
    [22787] = true, [22785] = true, [22794] = true, [13465] = true, [13463] = true, [3355] = true, 
    [22786] = true, [3819] = true, [785] = true, [22793] = true, [13466] = true, [3369] = true, 
    [2447] = true, [3358] = true, [2452] = true, [36906] = true, [22791] = true, [4625] = true, 
    [2453] = true, [8845] = true, [13464] = true, [13468] = true, [36904] = true, [22790] = true, 
    [22792] = true, [8846] = true, [3821] = true, [2449] = true, [8153] = true, [2450] = true,
    [8836] = true, [8831] = true, [8839] = true, [3818] = true, [3357] = true, [37921] = true,
    [3820] = true, [36907] = true, [3356] = true, [36905] = true, [36901] = true, [8838] = true,
    [36903] = true, [22788] = true, [36908] = true,
}

local function OnLootItem(event, player, item, count)
    local level = player:GetLevel()

    if player:GetLevel() >= 60 then
        return false
    end

    local enabled = GetState(player)
    if level >= 10 and level < 20 then multiplier = 20 end   
    if level >= 20 and level < 30 then multiplier = 25 end
    if level >= 30 and level < 40 then multiplier = 31 end
    if level >= 40 and level < 50 then multiplier = 35 end
    if level >= 50 and level < 59 then multiplier = 37 end
    if level == 60 then multiplier = 75 end
    local xp = math.floor(level * multiplier)
    if gatheringItemIDs[item:GetEntry()] then
        if enabled == 1 then
            player:GiveXP(xp)
            player:SendBroadcastMessage("|c979ABDFFYou gained|r " .. xp .. " |c979ABDFFbonus XP for gathering!|r")
        end
    else
        return
    end
end

RegisterPlayerEvent(52, OnCreateItem)
RegisterPlayerEvent(32, OnLootItem)
RegisterPlayerEvent(42, OnCommand)