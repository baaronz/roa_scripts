local AIO = AIO or require("AIO")

if not AIO.IsMainState() then
    return
end

if AIO.AddAddon() then
    local TABLE_NAME = "prestige"
    
    local function GetPrestigeLevel(guid)
        local result = CharDBQuery("SELECT level FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetPrestigePoints(guid)
        local result = CharDBQuery("SELECT points FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetStaminaLevel(guid)
        local result = CharDBQuery("SELECT stamina FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetIntellectLevel(guid)
        local result = CharDBQuery("SELECT intellect FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetAgilityLevel(guid)
        local result = CharDBQuery("SELECT agility FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetSpiritLevel(guid)
        local result = CharDBQuery("SELECT spirit FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetStrengthLevel(guid)
        local result = CharDBQuery("SELECT strength FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetAttackPowerLevel(guid)
        local result = CharDBQuery("SELECT attackpower FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetSpellPowerLevel(guid)
        local result = CharDBQuery("SELECT spellpower FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetCritRatingLevel(guid)
        local result = CharDBQuery("SELECT critrating FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetHitRatingLevel(guid)
        local result = CharDBQuery("SELECT hitrating FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetHasteRatingLevel(guid)
        local result = CharDBQuery("SELECT hasterating FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetResistFireLevel(guid)
        local result = CharDBQuery("SELECT resistfire FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetResistFrostLevel(guid)
        local result = CharDBQuery("SELECT resistfrost FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetResistNatureLevel(guid)
        local result = CharDBQuery("SELECT resistnature FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetResistShadowLevel(guid)
        local result = CharDBQuery("SELECT resistshadow FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function GetResistArcaneLevel(guid)
        local result = CharDBQuery("SELECT resistarcane FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end
    
    local function SetPrestigeLevel(guid, level)
        local result = CharDBExecute("UPDATE " .. TABLE_NAME .. " SET level = " .. level .. " WHERE guid = " .. guid)
        if not result then
            CharDBExecute("INSERT IGNORE INTO " .. TABLE_NAME .. " (guid, level, points, stamina, intellect, agility, spirit, strength) VALUES (" .. guid .. ", " .. level .. ", 0, 0, 0, 0, 0, 0)")
        end
    end
    
    local function GrantPrestigePoints(guid, points)
        local currentPoints = GetPrestigePoints(guid)
        local newPoints = currentPoints + points
        local result = CharDBExecute("UPDATE " .. TABLE_NAME .. " SET points = " .. newPoints .. " WHERE guid = " .. guid)
        if not result then
            CharDBExecute("INSERT IGNORE INTO " .. TABLE_NAME .. " (guid, level, points, stamina, intellect, agility, spirit, strength) VALUES (" .. guid .. ", 0, " .. newPoints .. ", 0, 0, 0, 0, 0)")
        end
    end
    
    local function OnSpellCast(event, player, spell, skipCheck)
        if spell:GetEntry() == 89001 then
            local guid = player:GetGUIDLow()
            local level = GetPrestigeLevel(guid)
            local points = GetPrestigePoints(guid)
            local stamina = GetStaminaLevel(guid)
            local intellect = GetIntellectLevel(guid)
            local agility = GetAgilityLevel(guid)
            local spirit = GetSpiritLevel(guid)
            local strength = GetStrengthLevel(guid)
            local attackpower = GetAttackPowerLevel(guid)
            local spellpower = GetSpellPowerLevel(guid)
            local critrating = GetCritRatingLevel(guid)
            local hitrating = GetHitRatingLevel(guid)
            local hasterating = GetHasteRatingLevel(guid)
            local resistfire = GetResistFireLevel(guid)
            local resistfrost = GetResistFrostLevel(guid)
            local resistnature = GetResistNatureLevel(guid)
            local resistshadow = GetResistShadowLevel(guid)
            local resistarcane = GetResistArcaneLevel(guid)
            
            local prestigeData = {
                level = level,
                points = points,
                playerName = player:GetName(),
                stamina = stamina,
                intellect = intellect,
                agility = agility,
                spirit = spirit,
                strength = strength,
                attackpower = attackpower,
                spellpower = spellpower,
                critrating = critrating,
                hitrating = hitrating,
                hasterating = hasterating,
                resistfire = resistfire,
                resistfrost = resistfrost,
                resistnature = resistnature,
                resistshadow = resistshadow,
                resistarcane = resistarcane
            }
            
            AIO.Msg():Add("PrestigeMenu", "ShowPrestigeWindow", prestigeData):Send(player)
        end
    end
    
    local function OnCommand(event, player, command)
        if command == "prestige" then
            local guid = player:GetGUIDLow()
            local level = GetPrestigeLevel(guid)
            local points = GetPrestigePoints(guid)
            local stamina = GetStaminaLevel(guid)
            local intellect = GetIntellectLevel(guid)
            local agility = GetAgilityLevel(guid)
            local spirit = GetSpiritLevel(guid)
            local strength = GetStrengthLevel(guid)
            local attackpower = GetAttackPowerLevel(guid)
            local spellpower = GetSpellPowerLevel(guid)
            local critrating = GetCritRatingLevel(guid)
            local hitrating = GetHitRatingLevel(guid)
            local hasterating = GetHasteRatingLevel(guid)
            local resistfire = GetResistFireLevel(guid)
            local resistfrost = GetResistFrostLevel(guid)
            local resistnature = GetResistNatureLevel(guid)
            local resistshadow = GetResistShadowLevel(guid)
            local resistarcane = GetResistArcaneLevel(guid)
            
            local prestigeData = {
                level = level,
                points = points,
                playerName = player:GetName(),
                stamina = stamina,
                intellect = intellect,
                agility = agility,
                spirit = spirit,
                strength = strength,
                attackpower = attackpower,
                spellpower = spellpower,
                critrating = critrating,
                hitrating = hitrating,
                hasterating = hasterating,
                resistfire = resistfire,
                resistfrost = resistfrost,
                resistnature = resistnature,
                resistshadow = resistshadow,
                resistarcane = resistarcane
            }
            
            AIO.Msg():Add("PrestigeMenu", "ShowPrestigeWindow", prestigeData):Send(player)
            return false
        end
    end
    
    RegisterPlayerEvent(5, OnSpellCast)
    RegisterPlayerEvent(42, OnCommand)
    
    local function OnLevelChange(event, player, oldLevel)
        if player:GetLevel() == 61 then
            player:SetLevel(60)
            local guid = player:GetGUIDLow()
            local level = GetPrestigeLevel(guid)
            local newlevel = math.floor(level+1)
            SetPrestigeLevel(guid, newlevel)
            GrantPrestigePoints(guid, 1)
            
            player:SendBroadcastMessage("|c979ABDFFYou've been granted a Prestige Point!|r")
            player:SendBroadcastMessage("|c979ABDFFYou can allocate your points by using the command .prestige|r")
        end
    end
    
    RegisterPlayerEvent(13, OnLevelChange)
    
    local function OnLogin(event, player)
        local guid = player:GetGUIDLow()
        CharDBExecute("INSERT IGNORE INTO " .. TABLE_NAME .. " (guid, level, points, stamina, intellect, agility, spirit, strength) VALUES (" .. guid .. ", 0, 0, 0, 0, 0, 0, 0)")
        
        if player:HasSpell(89001) == false then
            player:LearnSpell(89001)
        end
        
        if player:GetLevel() == 61 then
            player:SetLevel(60)
        end
    end
    
    RegisterPlayerEvent(3, OnLogin)
    
    local function ApplyPrestigeAuras(player)
        local guid = player:GetGUIDLow()
        local stamina = GetStaminaLevel(guid)
        local intellect = GetIntellectLevel(guid)
        local agility = GetAgilityLevel(guid)
        local spirit = GetSpiritLevel(guid)
        local strength = GetStrengthLevel(guid)
        local attackpower = GetAttackPowerLevel(guid)
        local spellpower = GetSpellPowerLevel(guid)
        local critrating = GetCritRatingLevel(guid)
        local hitrating = GetHitRatingLevel(guid)
        local hasterating = GetHasteRatingLevel(guid)
        local resistfire = GetResistFireLevel(guid)
        local resistfrost = GetResistFrostLevel(guid)
        local resistnature = GetResistNatureLevel(guid)
        local resistshadow = GetResistShadowLevel(guid)
        local resistarcane = GetResistArcaneLevel(guid)
        
        for i = 1, stamina do
            player:AddAura(100016, player)
        end
        
        for i = 1, intellect do
            player:AddAura(100003, player)
        end
        
        for i = 1, agility do
            player:AddAura(100002, player)
        end
        
        for i = 1, spirit do
            player:AddAura(100005, player)
        end
        
        for i = 1, strength do
            player:AddAura(100004, player)
        end
        
        for i = 1, attackpower do
            player:AddAura(100006, player)
        end
        
        for i = 1, spellpower do
            player:AddAura(100007, player)
        end
        
        for i = 1, critrating do
            player:AddAura(100008, player)
        end
        
        for i = 1, hitrating do
            player:AddAura(100009, player)
        end
        
        for i = 1, hasterating do
            player:AddAura(100010, player)
        end
        
        for i = 1, resistfire do
            player:AddAura(100011, player)
        end
        
        for i = 1, resistfrost do
            player:AddAura(100012, player)
        end
        
        for i = 1, resistnature do
            player:AddAura(100013, player)
        end
        
        for i = 1, resistshadow do
            player:AddAura(100014, player)
        end
        
        for i = 1, resistarcane do
            player:AddAura(100015, player)
        end
    end
    
    local function OnRepop(event, player)
        ApplyPrestigeAuras(player)
    end
    
    local function OnResurrect(event, player)
        ApplyPrestigeAuras(player)
    end
    
    RegisterPlayerEvent(35, OnRepop)
    RegisterPlayerEvent(36, OnResurrect)
    
    local function HandlePrestigeRequest(player, msgType, data)
        if not player or not player:IsInWorld() then
            return
        end
        
        if msgType == "RequestData" then
            local guid = player:GetGUIDLow()
            local level = GetPrestigeLevel(guid)
            local points = GetPrestigePoints(guid)
            local stamina = GetStaminaLevel(guid)
            local intellect = GetIntellectLevel(guid)
            local agility = GetAgilityLevel(guid)
            local spirit = GetSpiritLevel(guid)
            local strength = GetStrengthLevel(guid)
            local attackpower = GetAttackPowerLevel(guid)
            local spellpower = GetSpellPowerLevel(guid)
            local critrating = GetCritRatingLevel(guid)
            local hitrating = GetHitRatingLevel(guid)
            local hasterating = GetHasteRatingLevel(guid)
            local resistfire = GetResistFireLevel(guid)
            local resistfrost = GetResistFrostLevel(guid)
            local resistnature = GetResistNatureLevel(guid)
            local resistshadow = GetResistShadowLevel(guid)
            local resistarcane = GetResistArcaneLevel(guid)
            
            local prestigeData = {
                level = level,
                points = points,
                playerName = player:GetName(),
                stamina = stamina,
                intellect = intellect,
                agility = agility,
                spirit = spirit,
                strength = strength,
                attackpower = attackpower,
                spellpower = spellpower,
                critrating = critrating,
                hitrating = hitrating,
                hasterating = hasterating,
                resistfire = resistfire,
                resistfrost = resistfrost,
                resistnature = resistnature,
                resistshadow = resistshadow,
                resistarcane = resistarcane
            }
            
            AIO.Msg():Add("PrestigeMenu", "ReceiveData", prestigeData):Send(player)
        elseif msgType == "UpdateStat" then
            local statType = data.statType
            local newValue = data.value
            local guid = player:GetGUIDLow()
            
            local result = CharDBExecute("UPDATE " .. TABLE_NAME .. " SET " .. statType .. " = " .. newValue .. " WHERE guid = " .. guid)
            
            if result then
                AIO.Msg():Add("PrestigeMenu", "StatUpdated", {statType = statType, value = newValue}):Send(player)
            end
        elseif msgType == "ApplyChanges" then
            local guid = player:GetGUIDLow()
            
            local oldStamina = GetStaminaLevel(guid)
            local oldIntellect = GetIntellectLevel(guid)
            local oldAgility = GetAgilityLevel(guid)
            local oldSpirit = GetSpiritLevel(guid)
            local oldStrength = GetStrengthLevel(guid)
            local oldAttackPower = GetAttackPowerLevel(guid)
            local oldSpellPower = GetSpellPowerLevel(guid)
            local oldCritRating = GetCritRatingLevel(guid)
            local oldHitRating = GetHitRatingLevel(guid)
            local oldHasteRating = GetHasteRatingLevel(guid)
            local oldResistFire = GetResistFireLevel(guid)
            local oldResistFrost = GetResistFrostLevel(guid)
            local oldResistNature = GetResistNatureLevel(guid)
            local oldResistShadow = GetResistShadowLevel(guid)
            local oldResistArcane = GetResistArcaneLevel(guid)
            
            local totalPointsSpent = 0
            
            if data and data.changes then
                for statType, newValue in pairs(data.changes) do
                    local oldValue = 0
                    if statType == "stamina" then
                        oldValue = oldStamina
                    elseif statType == "intellect" then
                        oldValue = oldIntellect
                    elseif statType == "agility" then
                        oldValue = oldAgility
                    elseif statType == "spirit" then
                        oldValue = oldSpirit
                    elseif statType == "strength" then
                        oldValue = oldStrength
                    elseif statType == "attackpower" then
                        oldValue = oldAttackPower
                    elseif statType == "spellpower" then
                        oldValue = oldSpellPower
                    elseif statType == "critrating" then
                        oldValue = oldCritRating
                    elseif statType == "hitrating" then
                        oldValue = oldHitRating
                    elseif statType == "hasterating" then
                        oldValue = oldHasteRating
                    elseif statType == "resistfire" then
                        oldValue = oldResistFire
                    elseif statType == "resistfrost" then
                        oldValue = oldResistFrost
                    elseif statType == "resistnature" then
                        oldValue = oldResistNature
                    elseif statType == "resistshadow" then
                        oldValue = oldResistShadow
                    elseif statType == "resistarcane" then
                        oldValue = oldResistArcane
                    end
                    
                    local pointsSpent = newValue - oldValue
                    if pointsSpent > 0 then
                        totalPointsSpent = totalPointsSpent + pointsSpent
                    elseif pointsSpent < 0 then
                        local pointsRefunded = math.abs(pointsSpent)
                        totalPointsSpent = totalPointsSpent - pointsRefunded
                    end
                    
                    if statType == "attackpower" or statType == "spellpower" or statType == "critrating" or statType == "hitrating" or statType == "hasterating" or statType == "resistfire" or statType == "resistfrost" or statType == "resistnature" or statType == "resistshadow" or statType == "resistarcane" then
                        if newValue > 40 then
                            newValue = 40
                        end
                    else
                        if newValue > 100 then
                            newValue = 100
                        end
                    end
                     
                    local result = CharDBExecute("UPDATE " .. TABLE_NAME .. " SET " .. statType .. " = " .. newValue .. " WHERE guid = " .. guid)
                end
            end
            
            local updatedPoints = 0
            local currentPoints = GetPrestigePoints(guid)
             
            if totalPointsSpent > 0 and totalPointsSpent > currentPoints then
                player:SendBroadcastMessage("|cFF0000FFYou don't have enough prestige points for this change!|r")
                AIO.Msg():Add("PrestigeMenu", "ChangesApplied", {success = false, error = "insufficient_points"}):Send(player)
                return
            end
             
            if totalPointsSpent ~= 0 then
                local newPoints = currentPoints - totalPointsSpent
                if newPoints < 0 then
                    newPoints = 0
                end
                
                local result = CharDBExecute("UPDATE " .. TABLE_NAME .. " SET points = " .. newPoints .. " WHERE guid = " .. guid)
                if result then
                    if totalPointsSpent > 0 then
                        player:SendBroadcastMessage("|c979ABDFFSpent " .. totalPointsSpent .. " prestige points.|r")
                    else
                        local pointsRefunded = math.abs(totalPointsSpent)
                        player:SendBroadcastMessage("|c979ABDFFRefunded " .. pointsRefunded .. " prestige points.|r")
                    end
                    updatedPoints = newPoints
                else
                    updatedPoints = newPoints
                    if totalPointsSpent > 0 then
                        player:SendBroadcastMessage("|c979ABDFFSpent " .. totalPointsSpent .. " prestige points.|r")
                    else
                        local pointsRefunded = math.abs(totalPointsSpent)
                        player:SendBroadcastMessage("|c979ABDFFRefunded " .. pointsRefunded .. " prestige points.|r")
                    end
                end
            else
                updatedPoints = currentPoints
            end
            
            player:RemoveAura(100016)
            player:RemoveAura(100002)
            player:RemoveAura(100003)
            player:RemoveAura(100004)
            player:RemoveAura(100005)
            player:RemoveAura(100006)
            player:RemoveAura(100007)
            player:RemoveAura(100008)
            player:RemoveAura(100009)
            player:RemoveAura(100010)
            player:RemoveAura(100011)
            player:RemoveAura(100012)
            player:RemoveAura(100013)
            player:RemoveAura(100014)
            player:RemoveAura(100015)
            
            local newStamina = oldStamina
            local newIntellect = oldIntellect
            local newAgility = oldAgility
            local newSpirit = oldSpirit
            local newStrength = oldStrength
            local newAttackPower = oldAttackPower
            local newSpellPower = oldSpellPower
            local newCritRating = oldCritRating
            local newHitRating = oldHitRating
            local newHasteRating = oldHasteRating
            local newResistFire = oldResistFire
            local newResistFrost = oldResistFrost
            local newResistNature = oldResistNature
            local newResistShadow = oldResistShadow
            local newResistArcane = oldResistArcane
            
            if data and data.changes then
                for statType, newValue in pairs(data.changes) do
                    if statType == "attackpower" or statType == "spellpower" or statType == "critrating" or statType == "hitrating" or statType == "hasterating" or statType == "resistfire" or statType == "resistfrost" or statType == "resistnature" or statType == "resistshadow" or statType == "resistarcane" then
                        if newValue > 40 then
                            newValue = 40
                        end
                    else
                        if newValue > 100 then
                            newValue = 100
                        end
                    end
                     
                    if statType == "stamina" then
                        newStamina = newValue
                    elseif statType == "intellect" then
                        newIntellect = newValue
                    elseif statType == "agility" then
                        newAgility = newValue
                    elseif statType == "spirit" then
                        newSpirit = newValue
                    elseif statType == "strength" then
                        newStrength = newValue
                    elseif statType == "attackpower" then
                        newAttackPower = newValue
                    elseif statType == "spellpower" then
                        newSpellPower = newValue
                    elseif statType == "critrating" then
                        newCritRating = newValue
                    elseif statType == "hitrating" then
                        newHitRating = newValue
                    elseif statType == "hasterating" then
                        newHasteRating = newValue
                    elseif statType == "resistfire" then
                        newResistFire = newValue
                    elseif statType == "resistfrost" then
                        newResistFrost = newValue
                    elseif statType == "resistnature" then
                        newResistNature = newValue
                    elseif statType == "resistshadow" then
                        newResistShadow = newValue
                    elseif statType == "resistarcane" then
                        newResistArcane = newValue
                    end
                end
            end
            
            for i = 1, newStamina do
                player:AddAura(100016, player)
            end
            
            for i = 1, newIntellect do
                player:AddAura(100003, player)
            end
            
            for i = 1, newAgility do
                player:AddAura(100002, player)
            end
            
            for i = 1, newSpirit do
                player:AddAura(100005, player)
            end
            
            for i = 1, newStrength do
                player:AddAura(100004, player)
            end
            
            for i = 1, newAttackPower do
                player:AddAura(100006, player)
            end
            
            for i = 1, newSpellPower do
                player:AddAura(100007, player)
            end
            
            for i = 1, newCritRating do
                player:AddAura(100008, player)
            end
            
            for i = 1, newHitRating do
                player:AddAura(100009, player)
            end
            
            for i = 1, newHasteRating do
                player:AddAura(100010, player)
            end
            
            for i = 1, newResistFire do
                player:AddAura(100011, player)
            end
            
            for i = 1, newResistFrost do
                player:AddAura(100012, player)
            end
            
            for i = 1, newResistNature do
                player:AddAura(100013, player)
            end
            
            for i = 1, newResistShadow do
                player:AddAura(100014, player)
            end
            
            for i = 1, newResistArcane do
                player:AddAura(100015, player)
            end
            
            player:SendBroadcastMessage("|c979ABDFFPrestige stats applied successfully!|r")
             
            AIO.Msg():Add("PrestigeMenu", "ChangesApplied", {success = true, points = updatedPoints}):Send(player)
        elseif msgType == "ResetStats" then
            local guid = player:GetGUIDLow()
            local level = data.level or 0
            
            player:RemoveAura(100016)
            player:RemoveAura(100002)
            player:RemoveAura(100003)
            player:RemoveAura(100004)
            player:RemoveAura(100005)
            player:RemoveAura(100006)
            player:RemoveAura(100007)
            player:RemoveAura(100008)
            player:RemoveAura(100009)
            player:RemoveAura(100010)
            player:RemoveAura(100011)
            player:RemoveAura(100012)
            player:RemoveAura(100013)
            player:RemoveAura(100014)
            player:RemoveAura(100015)
            
            local query = "UPDATE " .. TABLE_NAME .. " SET stamina = 0, intellect = 0, agility = 0, spirit = 0, strength = 0, attackpower = 0, spellpower = 0, critrating = 0, hitrating = 0, hasterating = 0, resistfire = 0, resistfrost = 0, resistnature = 0, resistshadow = 0, resistarcane = 0, points = " .. level .. " WHERE guid = " .. guid
            
            CharDBExecute(query)
            
            player:SendBroadcastMessage("|c979ABDFFAll prestige stats have been reset! You now have " .. level .. " points to spend.|r")
             
            AIO.Msg():Add("PrestigeMenu", "StatsReset", {success = true, points = level}):Send(player)
        end
    end
    
    AIO.RegisterEvent("PrestigeMenu", HandlePrestigeRequest)
    
    return
end

local PrestigeMenuAddon = {}
local isWindowVisible = false

local function CreatePrestigeWindow()
    local window = CreateFrame("Frame", "PrestigeMenuWindow", UIParent)
    window:SetSize(650, 565)
    window:SetPoint("CENTER", UIParent, "CENTER")
    window:SetMovable(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:Hide()
    
    window:EnableKeyboard(true)
    window:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            PrestigeMenuAddon:HideWindow()
        end
    end)
    
    window:SetBackdrop({
        bgFile = "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = false, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    window:SetAlpha(1.0)
    
    window:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    
    window:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    
    window.title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    window.title:SetPoint("TOP", window, "TOP", 0, -25)
    window.title:SetText("PRESTIGE SYSTEM")
    window.title:SetTextColor(0.9, 0.8, 0.5, 1)
    
    window.subtitle = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    window.subtitle:SetPoint("TOP", window.title, "BOTTOM", 0, -5)
    window.subtitle:SetText("Enhance your character's power")
    window.subtitle:SetTextColor(0.7, 0.7, 0.7, 0.8)
    
    window.infoPanel = CreateFrame("Frame", nil, window)
    window.infoPanel:SetSize(580, 50)
    window.infoPanel:SetPoint("TOP", window, "TOP", 0, -70)
    window.infoPanel:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    window.infoPanel:SetBackdropColor(0.08, 0.08, 0.12, 0.9)
    window.infoPanel:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.8)
    
    window.levelIcon = window.infoPanel:CreateTexture(nil, "OVERLAY")
    window.levelIcon:SetSize(24, 24)
    window.levelIcon:SetPoint("LEFT", window.infoPanel, "LEFT", 20, 0)
    window.levelIcon:SetTexture("Interface\\Icons\\Spell_Holy_ChampionsBond")
    
    window.levelText = window.infoPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    window.levelText:SetPoint("LEFT", window.levelIcon, "RIGHT", 8, 0)
    window.levelText:SetText("Level: 0")
    window.levelText:SetTextColor(0.9, 0.8, 0.5, 1)
    
    window.resetButton = CreateFrame("Button", nil, window.infoPanel)
    window.resetButton:SetSize(80, 28)
    window.resetButton:SetPoint("CENTER", window.infoPanel, "CENTER", 0, 0)
    
    window.resetButton:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 6,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    window.resetButton:SetBackdropColor(0.2, 0.2, 0.25, 0.95)
    window.resetButton:SetBackdropBorderColor(0.6, 0.6, 0.7, 1)
    
    window.resetButton.text = window.resetButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    window.resetButton.text:SetPoint("CENTER", window.resetButton, "CENTER", 0, 0)
    window.resetButton.text:SetText("Reset")
    window.resetButton.text:SetTextColor(0.9, 0.9, 0.9, 1)
    
    window.resetButton:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.25, 0.25, 0.3, 0.95)
        self:SetBackdropBorderColor(1.0, 0.5, 0.5, 1)
        self.text:SetTextColor(1, 1, 1, 1)
    end)
    
    window.resetButton:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.2, 0.2, 0.25, 0.95)
        self:SetBackdropBorderColor(0.8, 0.4, 0.4, 1)
        self.text:SetTextColor(0.9, 0.9, 0.9, 1)
    end)
    
    window.resetButton:SetScript("OnMouseDown", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.2, 0.95)
        self.text:SetTextColor(0.8, 0.8, 0.8, 1)
    end)
    
    window.resetButton:SetScript("OnMouseUp", function(self)
        self:SetBackdropColor(0.25, 0.25, 0.3, 0.95)
        self.text:SetTextColor(1, 1, 1, 1)
    end)
    
    window.resetButton:SetScript("OnClick", function()
        PrestigeMenuAddon:ShowResetConfirmation()
    end)
    
    window.pointsIcon = window.infoPanel:CreateTexture(nil, "OVERLAY")
    window.pointsIcon:SetSize(24, 24)
    window.pointsIcon:SetPoint("RIGHT", window.infoPanel, "RIGHT", -20, 0)
    window.pointsIcon:SetTexture("Interface\\Icons\\Spell_Holy_ChampionsGrace")
    
    window.pointsText = window.infoPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    window.pointsText:SetPoint("RIGHT", window.pointsIcon, "LEFT", -8, 0)
    window.pointsText:SetText("Points: 0")
    window.pointsText:SetTextColor(0.9, 0.8, 0.5, 1)
    
    window.closeButton = CreateFrame("Button", nil, window)
    window.closeButton:SetSize(28, 28)
    window.closeButton:SetPoint("TOPRIGHT", window, "TOPRIGHT", -10, -10)
    
    window.closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    window.closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    window.closeButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
    
    window.closeButton:SetScript("OnClick", function()
        PrestigeMenuAddon:HideWindow()
    end)
    
    window.closeButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Close")
        GameTooltip:Show()
    end)
    window.closeButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    window.contentFrame = CreateFrame("Frame", nil, window)
    window.contentFrame:SetSize(580, 390)
    window.contentFrame:SetPoint("TOP", window, "TOP", 0, -140)
    window.contentFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    window.contentFrame:SetBackdropColor(0.06, 0.06, 0.1, 0.95)
    window.contentFrame:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.8)
    
    window.contentTitle = window.contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    window.contentTitle:SetPoint("TOP", window.contentFrame, "TOP", 0, -15)
    window.contentTitle:SetText("Stat Allocation")
    window.contentTitle:SetTextColor(0.9, 0.8, 0.5, 1)
    
    window.statGrid = {}
    local gridStartX = 50
    local gridStartY = -60
    local gridSpacingX = 100
    local gridSpacingY = 85
    
    local stats = {
        {name = "Stamina", icon = "Interface\\Icons\\Ability_Warrior_InnerRage", color = {0.9, 0.3, 0.3}, hoverColor = {1.0, 0.4, 0.4}},
        {name = "Intellect", icon = "Interface\\Icons\\Spell_Holy_ArcaneIntellect", color = {0.3, 0.3, 0.9}, hoverColor = {0.4, 0.4, 1.0}},
        {name = "Agility", icon = "Interface\\Icons\\Spell_Holy_BlessingOfAgility", color = {0.3, 0.9, 0.3}, hoverColor = {0.4, 1.0, 0.4}},
        {name = "Spirit", icon = "Interface\\Icons\\Spell_Holy_DivineSpirit", color = {0.9, 0.9, 0.3}, hoverColor = {1.0, 1.0, 0.4}},
        {name = "Strength", icon = "Interface\\Icons\\Spell_Nature_Strength", color = {0.9, 0.5, 0.3}, hoverColor = {1.0, 0.6, 0.4}},
        {name = "Attack Power", icon = "Interface\\Icons\\INV_Sword_04", color = {0.8, 0.4, 0.2}, hoverColor = {0.9, 0.5, 0.3}},
        {name = "Spell Power", icon = "Interface\\Icons\\Spell_Fire_FlameBolt", color = {0.6, 0.3, 0.9}, hoverColor = {0.7, 0.4, 1.0}},
        {name = "Crit Rating", icon = "Interface\\Icons\\Ability_CriticalStrike", color = {0.9, 0.2, 0.2}, hoverColor = {1.0, 0.3, 0.3}},
        {name = "Hit Rating", icon = "Interface\\Icons\\INV_Sword_11", color = {0.2, 0.7, 0.9}, hoverColor = {0.3, 0.8, 1.0}},
        {name = "Haste Rating", icon = "Interface\\Icons\\Spell_Nature_Invisibilty", color = {0.9, 0.7, 0.2}, hoverColor = {1.0, 0.8, 0.3}},
        {name = "Resist Fire", icon = "Interface\\Icons\\Spell_Fire_Fire", color = {0.9, 0.3, 0.1}, hoverColor = {1.0, 0.4, 0.2}},
        {name = "Resist Frost", icon = "Interface\\Icons\\Spell_Frost_Frost", color = {0.3, 0.7, 0.9}, hoverColor = {0.4, 0.8, 1.0}},
        {name = "Resist Nature", icon = "Interface\\Icons\\Spell_Nature_ProtectionformNature", color = {0.3, 0.8, 0.3}, hoverColor = {0.4, 0.9, 0.4}},
        {name = "Resist Shadow", icon = "Interface\\Icons\\Spell_Shadow_BlackPlague", color = {0.5, 0.2, 0.7}, hoverColor = {0.6, 0.3, 0.8}},
        {name = "Resist Arcane", icon = "Interface\\Icons\\Spell_Arcane_Blink", color = {0.8, 0.3, 0.8}, hoverColor = {0.9, 0.4, 0.9}}
    }
    
    for row = 1, 3 do
        window.statGrid[row] = {}
        for col = 1, 5 do
            local statIndex = (row - 1) * 5 + col
            if statIndex <= 15 then
                local stat = stats[statIndex]
                local cell = CreateFrame("Frame", nil, window.contentFrame)
                cell:SetSize(95, 75)
                cell:SetPoint("TOPLEFT", window.contentFrame, "TOPLEFT", 
                    gridStartX + (col - 1) * gridSpacingX, 
                    gridStartY - (row - 1) * gridSpacingY)
                
                cell:SetBackdrop({
                    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    tile = true, tileSize = 32, edgeSize = 6,
                    insets = { left = 3, right = 3, top = 3, bottom = 3 }
                })
                cell:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
                cell:SetBackdropBorderColor(unpack(stat.color))
                
                cell:SetScript("OnEnter", function(self)
                    self:SetBackdropBorderColor(unpack(stat.hoverColor))
                    self:SetBackdropColor(0.13, 0.13, 0.18, 0.95)
                end)
                cell:SetScript("OnLeave", function(self)
                    self:SetBackdropBorderColor(unpack(stat.color))
                    self:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
                end)
                
                cell.icon = cell:CreateTexture(nil, "OVERLAY")
                cell.icon:SetSize(32, 32)
                cell.icon:SetPoint("TOP", cell, "TOP", 0, -6)
                cell.icon:SetTexture(stat.icon)
                
                cell.iconGlow = cell:CreateTexture(nil, "BACKGROUND")
                cell.iconGlow:SetSize(40, 36)
                cell.iconGlow:SetPoint("CENTER", cell.icon, "CENTER")
                cell.iconGlow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
                cell.iconGlow:SetBlendMode("ADD")
                cell.iconGlow:SetVertexColor(unpack(stat.color))
                cell.iconGlow:SetAlpha(0.25)
                
                cell.value = cell:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                cell.value:SetPoint("TOP", cell.icon, "BOTTOM", 0, -2)
                cell.value:SetText("0")
                cell.value:SetTextColor(1, 1, 1, 1)
                
                cell.name = cell:CreateFontString(nil, "OVERLAY", "SystemFont_Tiny")
                cell.name:SetPoint("BOTTOM", cell, "BOTTOM", 0, 8)
                cell.name:SetText(stat.name)
                cell.name:SetTextColor(unpack(stat.color))
                
                cell.minusBtn = CreateFrame("Button", nil, cell)
                cell.minusBtn:SetSize(15, 15)
                cell.minusBtn:SetPoint("LEFT", cell, "LEFT", 8, -10)
                
                cell.minusBtn:SetBackdrop({
                    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    tile = true, tileSize = 32, edgeSize = 6,
                    insets = { left = 2, right = 2, top = 2, bottom = 2 }
                })
                cell.minusBtn:SetBackdropColor(0.15, 0.15, 0.2, 0.95)
                cell.minusBtn:SetBackdropBorderColor(0.5, 0.5, 0.6, 1)
                
                cell.minusBtn.text = cell.minusBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                cell.minusBtn.text:SetPoint("CENTER", cell.minusBtn, "CENTER", 0, 0)
                cell.minusBtn.text:SetText("-")
                cell.minusBtn.text:SetTextColor(0.9, 0.9, 0.9, 1)
                
                cell.minusBtn:SetScript("OnEnter", function(self)
                    self:SetBackdropColor(0.2, 0.2, 0.25, 0.95)
                    self:SetBackdropBorderColor(0.7, 0.7, 0.8, 1)
                    self.text:SetTextColor(1, 1, 1, 1)
                end)
                
                cell.minusBtn:SetScript("OnLeave", function(self)
                    self:SetBackdropColor(0.15, 0.15, 0.2, 0.95)
                    self:SetBackdropBorderColor(0.5, 0.5, 0.6, 1)
                    self.text:SetTextColor(0.9, 0.9, 0.9, 1)
                end)
                
                cell.minusBtn.statType = string.lower(stat.name)
                cell.minusBtn.cell = cell
                
                cell.minusBtn:SetScript("OnClick", function(self)
                    local currentValue = tonumber(self.cell.value:GetText()) or 0
                    if currentValue > 0 then
                        self.cell.value:SetText(tostring(currentValue - 1))
                        if PrestigeMenuAddon.currentData then
                            PrestigeMenuAddon.currentData.points = PrestigeMenuAddon.currentData.points + 1
                            if PrestigeMenuAddon.window and PrestigeMenuAddon.window.pointsText then
                                PrestigeMenuAddon.window.pointsText:SetText("Points: " .. PrestigeMenuAddon.currentData.points)
                            end
                        end
                    end
                end)
                
                cell.plusBtn = CreateFrame("Button", nil, cell)
                cell.plusBtn:SetSize(15, 15)
                cell.plusBtn:SetPoint("RIGHT", cell, "RIGHT", -8, -10)
                
                cell.plusBtn:SetBackdrop({
                    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    tile = true, tileSize = 32, edgeSize = 6,
                    insets = { left = 2, right = 2, top = 2, bottom = 2 }
                })
                cell.plusBtn:SetBackdropColor(0.15, 0.15, 0.2, 0.95)
                cell.plusBtn:SetBackdropBorderColor(0.5, 0.5, 0.6, 1)
                
                cell.plusBtn.text = cell.plusBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
                cell.plusBtn.text:SetPoint("CENTER", cell.plusBtn, "CENTER", 0, 0)
                cell.plusBtn.text:SetText("+")
                cell.plusBtn.text:SetTextColor(0.9, 0.9, 0.9, 1)
                
                cell.plusBtn:SetScript("OnEnter", function(self)
                    self:SetBackdropColor(0.2, 0.2, 0.25, 0.95)
                    self:SetBackdropBorderColor(0.7, 0.7, 0.8, 1)
                    self.text:SetTextColor(1, 1, 1, 1)
                end)
                
                cell.plusBtn:SetScript("OnLeave", function(self)
                    self:SetBackdropColor(0.15, 0.15, 0.2, 0.95)
                    self:SetBackdropBorderColor(0.5, 0.5, 0.6, 1)
                    self.text:SetTextColor(0.9, 0.9, 0.9, 1)
                end)
                
                cell.plusBtn.statType = string.lower(stat.name)
                if cell.plusBtn.statType == "attack power" then
                    cell.plusBtn.statType = "attackpower"
                elseif cell.plusBtn.statType == "spell power" then
                    cell.plusBtn.statType = "spellpower"
                elseif cell.plusBtn.statType == "crit rating" then
                    cell.plusBtn.statType = "critrating"
                elseif cell.plusBtn.statType == "hit rating" then
                    cell.plusBtn.statType = "hitrating"
                elseif cell.plusBtn.statType == "haste rating" then
                    cell.plusBtn.statType = "hasterating"
                elseif cell.plusBtn.statType == "resist fire" then
                    cell.plusBtn.statType = "resistfire"
                elseif cell.plusBtn.statType == "resist frost" then
                    cell.plusBtn.statType = "resistfrost"
                elseif cell.plusBtn.statType == "resist nature" then
                    cell.plusBtn.statType = "resistnature"
                elseif cell.plusBtn.statType == "resist shadow" then
                    cell.plusBtn.statType = "resistshadow"
                elseif cell.plusBtn.statType == "resist arcane" then
                    cell.plusBtn.statType = "resistarcane"
                end
                cell.plusBtn.cell = cell
                
                cell.plusBtn:SetScript("OnClick", function(self)
                    local currentValue = tonumber(self.cell.value:GetText()) or 0
                    local availablePoints = PrestigeMenuAddon.currentData and PrestigeMenuAddon.currentData.points or 0
                    
                    local maxValue = 100
                    if self.statType == "attackpower" or self.statType == "spellpower" or self.statType == "critrating" or self.statType == "hitrating" or self.statType == "hasterating" or self.statType == "resistfire" or self.statType == "resistfrost" or self.statType == "resistnature" or self.statType == "resistshadow" or self.statType == "resistarcane" then
                        maxValue = 40
                    end
                    
                    local pointsToAdd = 1
                    if IsShiftKeyDown() then
                        pointsToAdd = 10
                    end
                    
                    local maxPointsCanAdd = math.min(maxValue - currentValue, availablePoints, pointsToAdd)
                    
                    if maxPointsCanAdd > 0 then
                        local newValue = currentValue + maxPointsCanAdd
                        self.cell.value:SetText(tostring(newValue))
                        if PrestigeMenuAddon.currentData then
                            PrestigeMenuAddon.currentData.points = PrestigeMenuAddon.currentData.points - maxPointsCanAdd
                            if PrestigeMenuAddon.window and PrestigeMenuAddon.window.pointsText then
                                PrestigeMenuAddon.window.pointsText:SetText("Points: " .. PrestigeMenuAddon.currentData.points)
                            end
                        end
                    end
                end)
                
                window.statGrid[row][col] = cell
                cell.statType = string.lower(stat.name)
                if cell.statType == "attack power" then
                    cell.statType = "attackpower"
                elseif cell.statType == "spell power" then
                    cell.statType = "spellpower"
                elseif cell.statType == "crit rating" then
                    cell.statType = "critrating"
                elseif cell.statType == "hit rating" then
                    cell.statType = "hitrating"
                elseif cell.statType == "haste rating" then
                    cell.statType = "hasterating"
                elseif cell.statType == "resist fire" then
                    cell.statType = "resistfire"
                elseif cell.statType == "resist frost" then
                    cell.statType = "resistfrost"
                elseif cell.statType == "resist nature" then
                    cell.statType = "resistnature"
                elseif cell.statType == "resist shadow" then
                    cell.statType = "resistshadow"
                elseif cell.statType == "resist arcane" then
                    cell.statType = "resistarcane"
                end
            end
        end
    end
    
    window.instructionsText = window.contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    window.instructionsText:SetPoint("BOTTOM", window.contentFrame, "BOTTOM", 0, 55)
    window.instructionsText:SetText("Click to add one point\nShift + click to add 10 points")
    window.instructionsText:SetTextColor(0.7, 0.7, 0.7, 0.8)
    window.instructionsText:SetJustifyH("CENTER")
    
    window.applyButton = CreateFrame("Button", nil, window.contentFrame)
    window.applyButton:SetSize(160, 36)
    window.applyButton:SetPoint("BOTTOM", window.contentFrame, "BOTTOM", 0, 15)
    
    window.applyButton:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    window.applyButton:SetBackdropColor(0.2, 0.2, 0.25, 0.95)
    window.applyButton:SetBackdropBorderColor(0.6, 0.6, 0.7, 1)
    
    window.applyButton.text = window.applyButton:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    window.applyButton.text:SetPoint("CENTER", window.applyButton, "CENTER", 0, 0)
    window.applyButton.text:SetText("Apply Changes")
    window.applyButton.text:SetTextColor(0.9, 0.9, 0.9, 1)
    
    window.applyButton:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.25, 0.25, 0.3, 0.95)
        self:SetBackdropBorderColor(0.8, 0.8, 0.9, 1)
        self.text:SetTextColor(1, 1, 1, 1)
    end)
    
    window.applyButton:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.2, 0.2, 0.25, 0.95)
        self:SetBackdropBorderColor(0.6, 0.6, 0.7, 1)
        self.text:SetTextColor(0.9, 0.9, 0.9, 1)
    end)
    
    window.applyButton:SetScript("OnMouseDown", function(self)
        self:SetBackdropColor(0.15, 0.15, 0.2, 0.95)
        self.text:SetTextColor(0.8, 0.8, 0.8, 1)
    end)
    
    window.applyButton:SetScript("OnMouseUp", function(self)
        self:SetBackdropColor(0.25, 0.25, 0.3, 0.95)
        self.text:SetTextColor(1, 1, 1, 1)
    end)
    
    window.applyButton:SetScript("OnClick", function()
        PrestigeMenuAddon:ApplyChanges()
    end)
    
    AIO.SavePosition(window)
    
    return window
end

function PrestigeMenuAddon:Initialize()
    self.window = CreatePrestigeWindow()
end

function PrestigeMenuAddon:ShowWindow(prestigeData)
    if self.window then
        self.window:Show()
        isWindowVisible = true
        
        if prestigeData then
            self:UpdatePrestigeData(prestigeData)
        end
        
        PlaySound("igMainMenuOpen")
    end
end

function PrestigeMenuAddon:HideWindow()
    if self.window then
        self.window:Hide()
        isWindowVisible = false
        
        PlaySound("igMainMenuClose")
    end
end

function PrestigeMenuAddon:UpdatePrestigeData(data)
    if self.window and data then
        if self.window.levelText then
            self.window.levelText:SetText("Level: " .. (data.level or 0))
        end
        
        if self.window.pointsText then
            self.window.pointsText:SetText("Points: " .. (data.points or 0))
        end
        
        if self.window.statGrid then
            for row = 1, 3 do
                for col = 1, 5 do
                    local cell = self.window.statGrid[row][col]
                    if cell and cell.statType then
                        local statValue = data[cell.statType] or 0
                        cell.value:SetText(tostring(statValue))
                        cell.currentValue = statValue
                    end
                end
            end
        end
        
        self.currentData = data
    end
end

function PrestigeMenuAddon:ApplyChanges()
    if not self.window or not self.currentData then
        return
    end
    
    local changes = {}
    local hasChanges = false
    
    for row = 1, 3 do
        for col = 1, 5 do
            local cell = self.window.statGrid[row][col]
            if cell and cell.statType then
                local currentValue = cell.currentValue or 0
                local newValue = tonumber(cell.value:GetText()) or 0
                
                if newValue ~= currentValue then
                    changes[cell.statType] = newValue
                    hasChanges = true
                end
            end
        end
    end
    
    if hasChanges then
        for statType, newValue in pairs(changes) do
            self.currentData[statType] = newValue
        end
        
        AIO.Msg():Add("PrestigeMenu", "ApplyChanges", {changes = changes}):Send()
    end
end

function PrestigeMenuAddon:ToggleWindow()
    if isWindowVisible then
        self:HideWindow()
    else
        self:ShowWindow()
    end
end

function PrestigeMenuAddon:ShowResetConfirmation()
    StaticPopup_Show("PRESTIGE_RESET_CONFIRMATION")
end

function PrestigeMenuAddon:ResetStats()
    if not self.currentData then
        return
    end
    
    AIO.Msg():Add("PrestigeMenu", "ResetStats", {level = self.currentData.level}):Send()
end

local function HandlePrestigeMessage(player, msgType, data)
    if msgType == "ShowPrestigeWindow" then
        PrestigeMenuAddon:ShowWindow(data)
    elseif msgType == "ReceiveData" then
        if data then
            PrestigeMenuAddon:UpdatePrestigeData(data)
        end
    elseif msgType == "StatUpdated" then
    elseif msgType == "ChangesApplied" then
        if data and data.success then
            if data.points and PrestigeMenuAddon.window and PrestigeMenuAddon.window.pointsText then
                PrestigeMenuAddon.window.pointsText:SetText("Points: " .. data.points)
                if PrestigeMenuAddon.currentData then
                    PrestigeMenuAddon.currentData.points = data.points
                end
            end
            
            if PrestigeMenuAddon.window and PrestigeMenuAddon.window.statGrid then
                for row = 1, 3 do
                    for col = 1, 5 do
                        local cell = PrestigeMenuAddon.window.statGrid[row][col]
                        if cell and cell.statType then
                            local newValue = tonumber(cell.value:GetText()) or 0
                            cell.currentValue = newValue
                        end
                    end
                end
            end
        elseif data and not data.success then
            if data.error == "insufficient_points" then
                PrestigeMenuAddon:UpdatePrestigeData(PrestigeMenuAddon.currentData)
            end
        end
    elseif msgType == "StatsReset" then
        if data and data.success then
            if PrestigeMenuAddon.window then
                if data.points and PrestigeMenuAddon.window.pointsText then
                    PrestigeMenuAddon.window.pointsText:SetText("Points: " .. data.points)
                end
                
                if PrestigeMenuAddon.window.statGrid then
                    for row = 1, 3 do
                        for col = 1, 5 do
                            local cell = PrestigeMenuAddon.window.statGrid[row][col]
                            if cell and cell.statType then
                                cell.value:SetText("0")
                                cell.currentValue = 0
                            end
                        end
                    end
                end
            end
            
            if PrestigeMenuAddon.currentData then
                PrestigeMenuAddon.currentData.points = data.points
                PrestigeMenuAddon.currentData.stamina = 0
                PrestigeMenuAddon.currentData.intellect = 0
                PrestigeMenuAddon.currentData.agility = 0
                PrestigeMenuAddon.currentData.spirit = 0
                PrestigeMenuAddon.currentData.strength = 0
                PrestigeMenuAddon.currentData.attackpower = 0
                PrestigeMenuAddon.currentData.spellpower = 0
                PrestigeMenuAddon.currentData.critrating = 0
                PrestigeMenuAddon.currentData.hitrating = 0
                PrestigeMenuAddon.currentData.hasterating = 0
                PrestigeMenuAddon.currentData.resistfire = 0
                PrestigeMenuAddon.currentData.resistfrost = 0
                PrestigeMenuAddon.currentData.resistnature = 0
                PrestigeMenuAddon.currentData.resistshadow = 0
                PrestigeMenuAddon.currentData.resistarcane = 0
            end
        end
    end
end

AIO.RegisterEvent("PrestigeMenu", HandlePrestigeMessage)

StaticPopupDialogs["PRESTIGE_RESET_CONFIRMATION"] = {
    text = "Are you sure you want to reset all your prestige stats?\n\nThis will set all stats to 0 and give you points equal to your level.",
    button1 = "Yes, Reset",
    button2 = "Cancel",
    OnAccept = function()
        PrestigeMenuAddon:ResetStats()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

PrestigeMenuAddon:Initialize()