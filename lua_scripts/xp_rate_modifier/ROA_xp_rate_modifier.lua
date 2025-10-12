local AIO = AIO or require("AIO")

if not AIO.IsMainState() then
    return
end

if AIO.AddAddon() then
    local TABLE_NAME = "custom_xp_rates"
    local DEFAULT_XP_RATE = 1.0
    local MAX_XP_RATE_UNDER_60 = 10.0
    local MAX_XP_RATE_LEVEL_60 = 100.0
    
    local function GetMaxXPRate(player)
        if player:GetLevel() < 60 then
            return MAX_XP_RATE_UNDER_60
        else
            return MAX_XP_RATE_LEVEL_60
        end
    end

    local function OnLogin(event, player)
        local guid = player:GetGUIDLow()
        local result = CharDBQuery("SELECT guid FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if not result then
            -- Check if there's an existing XP rate for this account
            local accountId = player:GetAccountId()
            local accountResult = CharDBQuery("SELECT xp_rate FROM " .. TABLE_NAME .. " WHERE guid IN (SELECT guid FROM characters WHERE account = " .. accountId .. ") LIMIT 1")
            
            local xpRate = DEFAULT_XP_RATE
            if accountResult then
                xpRate = accountResult:GetFloat(0)
            end
            
            CharDBExecute("INSERT INTO " .. TABLE_NAME .. " (guid, xp_rate, override, enabler) VALUES (" .. guid .. ", " .. xpRate .. ", 1, 1)")
        end

        if player:HasSpell(98122) == false then
            player:LearnSpell(98122)
        end
        if player:HasSpell(98123) == false then
            player:LearnSpell(98123)
        end
    end

    local function SetXPRate(player, rate)
        local accountId = player:GetAccountId()
        
        -- Get all characters for this account
        local result = CharDBQuery("SELECT guid FROM characters WHERE account = " .. accountId)
        
        if result then
            repeat
                local charGuid = result:GetUInt32(0)
                -- Apply XP rate to each character
                CharDBExecute("INSERT INTO " .. TABLE_NAME .. " (guid, xp_rate) VALUES (" .. charGuid .. ", " .. rate .. ") ON DUPLICATE KEY UPDATE xp_rate = " .. rate)
            until not result:NextRow()
        end
        
        -- Also update the current character's rate
        local guid = player:GetGUIDLow()
        CharDBExecute("INSERT INTO " .. TABLE_NAME .. " (guid, xp_rate) VALUES (" .. guid .. ", " .. rate .. ") ON DUPLICATE KEY UPDATE xp_rate = " .. rate)
    end

    local function GetXPRate(player)
        local guid = player:GetGUIDLow()
        local result = CharDBQuery("SELECT xp_rate FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetFloat(0)
        end
        return DEFAULT_XP_RATE
    end

    local function GetOverride(player)
        local guid = player:GetGUIDLow()
        local result = CharDBQuery("SELECT override FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return result
    end

    local function GetEnabler(player)
        local guid = player:GetGUIDLow()
        local result = CharDBQuery("SELECT enabler FROM " .. TABLE_NAME .. " WHERE guid = " .. guid)
        if result then
            return result:GetUInt32(0)
        end
        return result
    end

    local function SetEnabler(player, enabler)
        local accountId = player:GetAccountId()
        
        -- Get all characters for this account
        local result = CharDBQuery("SELECT guid FROM characters WHERE account = " .. accountId)
        
        if result then
            repeat
                local charGuid = result:GetUInt32(0)
                -- Apply enabler to each character
                CharDBExecute("UPDATE " .. TABLE_NAME .. " SET enabler = " .. enabler .. " WHERE guid = " .. charGuid)
            until not result:NextRow()
        end
    end

    local function GetAccountCharacterCount(player)
        local accountId = player:GetAccountId()
        local result = CharDBQuery("SELECT COUNT(*) FROM characters WHERE account = " .. accountId)
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end

    local function GetAccountAffectedCharacterCount(player)
        local accountId = player:GetAccountId()
        local result = CharDBQuery("SELECT COUNT(*) FROM " .. TABLE_NAME .. " t INNER JOIN characters c ON t.guid = c.guid WHERE c.account = " .. accountId .. " AND t.enabler = 1")
        if result then
            return result:GetUInt32(0)
        end
        return 0
    end

    local function OnGiveXp(event, player, amount, victim)
        local override = GetOverride(player)
        if override == 0 then
            return 0
        end

        local enabler = GetEnabler(player)
        if enabler == 0 then
            return 0
        end

        if enabler == 1 then
            local xp_rate = GetXPRate(player)
            return amount * xp_rate
        end
    end


    local function OnSpellCast(event, player, spell, skipCheck)
        local guid = player:GetGUIDLow()
        if spell:GetEntry() == 98123 then
            local currentEnabler = GetEnabler(player)
            local newEnabler = currentEnabler == 0 and 1 or 0
            
            SetEnabler(player, newEnabler)
            
            local totalChars = GetAccountCharacterCount(player)
            local affectedChars = GetAccountAffectedCharacterCount(player)
            
            if newEnabler == 1 then
                player:SendBroadcastMessage("|c979ABDFFXP gain is now enabled for all characters on your account.|r")
            else
                player:SendBroadcastMessage("|c979ABDFFXP gain is now disabled for all characters on your account.|r")
            end
            return false
        end

        if spell:GetEntry() == 98122 then
            if GetEnabler(player) == 0 then
                player:SendBroadcastMessage("|c979ABDFFYou can not access the XP rate window while XP gain is toggled off.|r")
                return false
            end
            
            local currentRate = GetXPRate(player)
            
            local xpData = {
                currentRate = currentRate,
                playerName = player:GetName()
            }
            AIO.Msg():Add("XPRateModifier", "ShowXPRateWindow", xpData):Send(player)
        end
    end

    local function HandleXPRateRequest(player, msgType, data)
        if not player or not player:IsInWorld() then
            return
        end
        
        if msgType == "SetXPRate" then
            local newRate = data.rate
            
            if not newRate or type(newRate) ~= "number" then
                player:SendBroadcastMessage("|c979ABDFFERROR: Invalid XP rate provided. Please enter a valid number.|r")
                return
            end
            
            if newRate < 0.1 then
                player:SendBroadcastMessage("|c979ABDFFERROR: XP rate cannot be set below 0.1. Minimum allowed rate is 0.1.|r")
                return
            end
            
            local maxRate = GetMaxXPRate(player)
            if newRate > maxRate then
                player:SendBroadcastMessage("|c979ABDFFERROR: XP rate cannot exceed " .. maxRate .. ". Maximum allowed rate is " .. maxRate .. ".|r")
                return
            end
            
            if GetEnabler(player) == 0 then
                player:SendBroadcastMessage("|c979ABDFFERROR: You cannot change your XP rate while XP gain is toggled off.|r")
                return
            end
            
            SetXPRate(player, newRate)
            
            local totalChars = GetAccountCharacterCount(player)
            local affectedChars = GetAccountAffectedCharacterCount(player)
            
            player:SendBroadcastMessage("|c979ABDFFYour XP rate has been set to " .. newRate .. " for all characters on your account.|r")
            
            AIO.Msg():Add("XPRateModifier", "RateUpdated", {success = true, rate = newRate}):Send(player)
        end
    end
    
    AIO.RegisterEvent("XPRateModifier", HandleXPRateRequest)

    RegisterPlayerEvent(12, OnGiveXp) 
    RegisterPlayerEvent(3, OnLogin) 
    RegisterPlayerEvent(5, OnSpellCast)
    
    return
end

local XPRateModifierAddon = {}
local isWindowVisible = false
local MAX_XP_RATE_UNDER_60 = 10.0
local MAX_XP_RATE_LEVEL_60 = 100.0

local function GetMaxXPRate()
    local player = UnitName("player")
    if player then
        local level = UnitLevel("player")
        if level < 60 then
            return MAX_XP_RATE_UNDER_60
        else
            return MAX_XP_RATE_LEVEL_60
        end
    end
    return MAX_XP_RATE_UNDER_60
end

local function CreateXPRateWindow()
    local window = CreateFrame("Frame", "XPRateModifierWindow", UIParent)
    window:SetSize(280, 160)
    window:SetPoint("TOP", UIParent, "TOP", 0, -50)
    window:EnableMouse(true)
    window:Hide()
    
    window:EnableKeyboard(true)
    window:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            XPRateModifierAddon:HideWindow()
        end
    end)
    
    window:SetBackdrop({
        bgFile = "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = false, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    window:SetAlpha(1.0)
    
    window.title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    window.title:SetPoint("TOP", window, "TOP", 0, -15)
    window.title:SetText("XP Rate Modifier")
    window.title:SetTextColor(1.0, 0.82, 0.0, 1)
    
    window.currentRateText = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    window.currentRateText:SetPoint("TOP", window.title, "BOTTOM", 0, -10)
    window.currentRateText:SetText("Current Rate: 1.0")
    window.currentRateText:SetTextColor(0.9, 0.9, 0.9, 1)
    
    window.instructionText = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    window.instructionText:SetPoint("TOP", window.currentRateText, "BOTTOM", 0, -8)
    window.instructionText:SetText("Enter new rate (0.1 - " .. GetMaxXPRate() .. "):")
    window.instructionText:SetTextColor(0.8, 0.8, 0.8, 1)
    
    window.editBox = CreateFrame("EditBox", nil, window)
    window.editBox:SetSize(120, 24)
    window.editBox:SetPoint("TOP", window.instructionText, "BOTTOM", 0, -8)
    window.editBox:SetAutoFocus(false)
    window.editBox:SetNumeric(false)
    window.editBox:SetMaxLetters(6)
    
    window.editBox:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    window.editBox:SetBackdropColor(0.0, 0.0, 0.0, 0.5)
    window.editBox:SetBackdropBorderColor(0.4, 0.4, 0.4, 1.0)
    
    window.editBox:SetFont("Fonts\\FRIZQT__.TTF", 12)
    window.editBox:SetTextColor(1, 1, 1, 1)
    window.editBox:SetTextInsets(5, 5, 0, 0)
    
    window.editBox:SetScript("OnEnterPressed", function(self)
        XPRateModifierAddon:ApplyRate()
    end)
    
    window.editBox:SetScript("OnEscapePressed", function(self)
        XPRateModifierAddon:HideWindow()
    end)
    
    window.applyButton = CreateFrame("Button", nil, window)
    window.applyButton:SetSize(100, 28)
    window.applyButton:SetPoint("BOTTOM", window, "BOTTOM", 0, 15)
    
    window.applyButton:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 8,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    window.applyButton:SetBackdropColor(0.2, 0.2, 0.25, 0.95)
    window.applyButton:SetBackdropBorderColor(0.6, 0.6, 0.7, 1)
    
    window.applyButton.text = window.applyButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    window.applyButton.text:SetPoint("CENTER", window.applyButton, "CENTER", 0, 0)
    window.applyButton.text:SetText("Apply")
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
    
    window.applyButton:SetScript("OnClick", function()
        XPRateModifierAddon:ApplyRate()
    end)
    
    return window
end

function XPRateModifierAddon:Initialize()
    self.window = CreateXPRateWindow()
end

function XPRateModifierAddon:ShowWindow(xpData)
    if self.window then
        self.window:Show()
        isWindowVisible = true
        
        if xpData then
            self:UpdateXPData(xpData)
        end
        
        self.window.editBox:SetFocus()
        PlaySound("igMainMenuOpen")
    end
end

function XPRateModifierAddon:HideWindow()
    if self.window then
        self.window:Hide()
        isWindowVisible = false
        self.window.editBox:ClearFocus()
        PlaySound("igMainMenuClose")
    end
end

function XPRateModifierAddon:UpdateXPData(data)
    if self.window and data then
        if self.window.currentRateText then
            self.window.currentRateText:SetText("Current Rate: " .. (data.currentRate or 1.0))
        end
        
        if self.window.editBox then
            self.window.editBox:SetText("")
        end
        
        self.currentData = data
    end
end

function XPRateModifierAddon:ApplyRate()
    if not self.window or not self.window.editBox then
        return
    end
    
    local rateText = self.window.editBox:GetText()
    local rate = tonumber(rateText)
    
    if not rate then
        print("|c979ABDFFInvalid XP rate. Please enter a valid number.|r")
        return
    end
    
    if rate < 0.1 then
        print("|c979ABDFFXP rate cannot be set below 0.1. Minimum allowed rate is 0.1.|r")
        return
    end
    
    local maxRate = GetMaxXPRate()
    if rate > maxRate then
        print("|c979ABDFFXP rate cannot exceed " .. maxRate .. ". Maximum allowed rate is " .. maxRate .. ".|r")
        return
    end
    
    AIO.Msg():Add("XPRateModifier", "SetXPRate", {rate = rate}):Send()
    self:HideWindow()
end

local function HandleXPRateMessage(player, msgType, data)
    if msgType == "ShowXPRateWindow" then
        XPRateModifierAddon:ShowWindow(data)
    elseif msgType == "RateUpdated" then
    end
end

AIO.RegisterEvent("XPRateModifier", HandleXPRateMessage)

XPRateModifierAddon:Initialize()