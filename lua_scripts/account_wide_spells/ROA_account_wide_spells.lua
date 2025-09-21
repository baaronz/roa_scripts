local ACCOUNT_WIDE_SPELLS = {
    33388,
    33391,
    34090,
    34091
}

local function IsAccountWideSpell(spellId)
    for _, id in ipairs(ACCOUNT_WIDE_SPELLS) do
        if id == spellId then
            return true
        end
    end
    return false
end

local function GetAccountCharacters(accountId)
    local query = CharDBQuery("SELECT guid, name FROM characters WHERE account = " .. accountId)
    local characters = {}
    
    if query then
        repeat
            local guid = query:GetUInt32(0)
            local name = query:GetString(1)
            table.insert(characters, {guid = guid, name = name})
        until not query:NextRow()
    end
    
    return characters
end

local function TeachSpellToAccountCharacters(accountId, spellId, learnedByCharacter)
    local characters = GetAccountCharacters(accountId)
    local taughtCount = 0
    
    for _, charData in ipairs(characters) do
        if charData.guid ~= learnedByCharacter then
            local spellQuery = CharDBQuery("SELECT 1 FROM character_spell WHERE guid = " .. charData.guid .. " AND spell = " .. spellId)
            
            if not spellQuery then
                CharDBExecute("INSERT INTO character_spell (guid, spell, active, disabled) VALUES (" .. charData.guid .. ", " .. spellId .. ", 1, 0)")
                taughtCount = taughtCount + 1
                
                local onlinePlayer = GetPlayerByGUID(charData.guid)
                if onlinePlayer then
                    onlinePlayer:SendBroadcastMessage("|c979ABDFFYou have learned a new spell from your account!|r")
                    onlinePlayer:SendBroadcastMessage("|c979ABDFFSpell ID: " .. spellId .. "|r")
                end
            end
        end
    end
    
    return taughtCount
end

local function OnPlayerLearnSpell(event, player, spellId)
    if not IsAccountWideSpell(spellId) then
        return
    end
    
    local accountId = player:GetAccountId()
    local characterGuid = player:GetGUIDLow()
    
    local checkQuery = CharDBQuery("SELECT 1 FROM account_wide_spells WHERE account_id = " .. accountId .. " AND spell_id = " .. spellId)
    
    if not checkQuery then
        CharDBExecute("INSERT INTO account_wide_spells (account_id, spell_id, learned_by_character, taught_to_all) VALUES (" .. accountId .. ", " .. spellId .. ", " .. characterGuid .. ", 0)")
        
        local taughtCount = TeachSpellToAccountCharacters(accountId, spellId, characterGuid)
        
        CharDBExecute("UPDATE account_wide_spells SET taught_to_all = 1 WHERE account_id = " .. accountId .. " AND spell_id = " .. spellId)
        
        if taughtCount > 0 then
            player:SendBroadcastMessage("|c979ABDFFThis spell has been taught to " .. taughtCount .. " other characters on your account!|r")
        else
            player:SendBroadcastMessage("|c979ABDFFThis spell is now account-wide!|r")
        end
    end
end

local function OnPlayerLogin(event, player)
    local accountId = player:GetAccountId()
    local characterGuid = player:GetGUIDLow()
    
    local query = CharDBQuery("SELECT spell_id FROM account_wide_spells WHERE account_id = " .. accountId)
    
    if query then
        repeat
            local spellId = query:GetUInt32(0)
            
            local spellQuery = CharDBQuery("SELECT 1 FROM character_spell WHERE guid = " .. characterGuid .. " AND spell = " .. spellId)
            
            if not spellQuery then
                CharDBExecute("INSERT INTO character_spell (guid, spell, active, disabled) VALUES (" .. characterGuid .. ", " .. spellId .. ", 1, 0)")
                player:SendBroadcastMessage("|c979ABDFFYou have learned an account-wide spell! (ID: " .. spellId .. ")|r")
            end
        until not query:NextRow()
    end
end

local function OnCommand(event, player, command)
    if command == "syncaccountspells" then
        if not player:IsGM() then
            player:SendBroadcastMessage("|cffff0000You don't have permission to use this command.|r")
            return false
        end
        
        local accountId = player:GetAccountId()
        local syncedCount = 0
        
        for _, spellId in ipairs(ACCOUNT_WIDE_SPELLS) do
            local checkQuery = CharDBQuery("SELECT 1 FROM account_wide_spells WHERE account_id = " .. accountId .. " AND spell_id = " .. spellId)
            
            if checkQuery then
                local taughtCount = TeachSpellToAccountCharacters(accountId, spellId, 0)
                syncedCount = syncedCount + taughtCount
            end
        end
        
        player:SendBroadcastMessage("|c979ABDFFSynced " .. syncedCount .. " account-wide spells.|r")
        return false
    end
    return true
end

RegisterPlayerEvent(44, OnPlayerLearnSpell)
RegisterPlayerEvent(3, OnPlayerLogin)
RegisterPlayerEvent(42, OnCommand)