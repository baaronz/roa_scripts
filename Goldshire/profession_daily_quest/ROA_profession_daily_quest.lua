local AIO = AIO or require("AIO")

if not AIO.IsMainState() then
    return
end

if AIO.AddAddon() then
    print("ProfessionDailyQuest: Server side script loaded!")
    
    local function GetCallBoardQuests(player)
        local quests = {}
        local playerGuid = player:GetGUIDLow()
        local today = os.time()
        local todayStart = today - (today % 86400) -- Start of today in Unix time
        
        -- First, check how many daily quests the player has completed today
        local dailyCountResult = CharDBQuery("SELECT COUNT(*) FROM character_queststatus_daily WHERE guid = " .. playerGuid .. " AND time >= " .. todayStart)
        local dailyQuestsCompleted = 0
        if dailyCountResult then
            dailyQuestsCompleted = dailyCountResult:GetUInt32(0)
        end
        
        -- If player has already completed 2 daily quests, show message
        if dailyQuestsCompleted >= 2 then
            return {
                {
                    questId = 0,
                    title = "Daily Quests Completed",
                    description = "You have already completed your maximum of 2 daily profession quests today. Please return tomorrow for new opportunities!",
                    levelRequired = 1,
                    image = "Interface\\Icons\\INV_Misc_QuestionMark",
                    buttonText = "Check Tomorrow"
                }
            }
        end
        
        local result = WorldDBQuery("SELECT quest_id, quest_name, description, level_required, level_max, icon, background_image FROM roa_profession_daily_quests WHERE active = 1 ORDER BY sort_order ASC, quest_name ASC")
        
        if result then
            repeat
                local questId = result:GetUInt32(0)
                local levelRequired = result:GetUInt32(3)
                local levelMax = result:GetUInt32(4)
                local playerLevel = player:GetLevel()
                
                -- Check if player has already completed this daily quest today
                local questCompletedResult = CharDBQuery("SELECT quest FROM character_queststatus_daily WHERE guid = " .. playerGuid .. " AND quest = " .. questId .. " AND time >= " .. todayStart)
                local hasCompletedToday = questCompletedResult ~= nil
                
                -- Check if player already has this quest
                local hasQuest = player:HasQuest(questId)
                
                if not hasQuest and not hasCompletedToday and playerLevel >= levelRequired and playerLevel <= levelMax then
                    local questData = {
                        questId = questId,
                        title = result:GetString(1),
                        description = result:GetString(2),
                        levelRequired = levelRequired,
                        levelMax = levelMax,
                        image = result:GetString(5),
                        backgroundImage = result:GetString(6),
                        buttonText = "Accept Quest"
                    }
                
                    table.insert(quests, questData)
                end
            until not result:NextRow()
        end
        
        if #quests == 0 then
            quests = {
                {
                    questId = 0,
                    title = "No Quests Available",
                    description = "There are currently no quests available on the call board. Please check back later!",
                    levelRequired = 1,
                    image = "Interface\\Icons\\INV_Misc_QuestionMark",
                    buttonText = "Check Later"
                }
            }
        end
        
        return quests
    end
    
    local function OnCommand(event, player, command)
        if command == "acbtest" then
            local quests = GetCallBoardQuests(player)
            
            local callBoardData = {
                title = "Daily Profession Quests Available",
                options = quests
            }
            
            AIO.Msg():Add("HeroesCallBoard", "ShowCallBoard", callBoardData):Send(player)
            return false
        end
        return true
    end
    
    RegisterPlayerEvent(42, OnCommand)
    
    local function OnGossipHello(event, player, object)
        player:GossipClearMenu()
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\INV_Misc_QuestionMark:20:20|t View Call Board", 0, 1)
        player:GossipSendMenu(1, object, 1)
    end
    
    local function OnGossipSelect(event, player, object, sender, intid, code, menu_id)
        if intid == 1 then
            local quests = GetCallBoardQuests(player)
            
            local callBoardData = {
                title = "Daily Profession Quests Available",
                options = quests
            }
            
            AIO.Msg():Add("HeroesCallBoard", "ShowCallBoard", callBoardData):Send(player)
            
            player:GossipComplete()
        end
    end

    RegisterCreatureGossipEvent(60605, 1, OnGossipHello)
    RegisterCreatureGossipEvent(60605, 2, OnGossipSelect)

    RegisterCreatureGossipEvent(60705, 1, OnGossipHello)
    RegisterCreatureGossipEvent(60705, 2, OnGossipSelect)
    
    local function HandleCallBoardRequest(player, msgType, data)
        if not player or not player:IsInWorld() then
            return
        end
        
        if msgType == "ButtonClick" then
            local buttonId = data.buttonId
            
            local quests = GetCallBoardQuests(player)
            local selectedQuest = quests[buttonId]
            
            if selectedQuest and selectedQuest.questId > 0 then
                player:AddQuest(selectedQuest.questId)
                AIO.Msg():Add("HeroesCallBoard", "CloseWindow", {}):Send(player)
            end
        end
    end
    
    AIO.RegisterEvent("HeroesCallBoard", HandleCallBoardRequest)
    return
end

local CallBoardAddon = {}
local isWindowVisible = false

    local function CreateCallBoardWindow()
        local window = CreateFrame("Frame", "CallBoardWindow", UIParent)
        window:SetSize(700, 600)
        window:SetPoint("CENTER", UIParent, "CENTER")
        window:SetMovable(false)
        window:EnableMouse(true)
        window:Hide()
        
        window:EnableKeyboard(true)
        window:SetScript("OnKeyDown", function(self, key)
            if key == "ESCAPE" then
                CallBoardAddon:HideWindow()
            end
        end)
        
        window:SetBackdrop({
            bgFile = "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })
        window:SetAlpha(1.0)
        
    local closeButton = CreateFrame("Button", nil, window)
    closeButton:SetSize(28, 28)
    closeButton:SetPoint("TOPRIGHT", window, "TOPRIGHT", -10, -10)
    
    closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    closeButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
    
    closeButton:SetScript("OnClick", function()
        CallBoardAddon:HideWindow()
    end)
    
    closeButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Close")
        GameTooltip:Show()
    end)
    closeButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    
    window.title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    window.title:SetPoint("TOP", window, "TOP", 0, -20)
    window.title:SetText("DAILY PROFESSION QUESTS")
    window.title:SetTextColor(0.9, 0.8, 0.5, 1)
    
    window.subtitle = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    window.subtitle:SetPoint("TOP", window.title, "BOTTOM", 0, -3)
    window.subtitle:SetText("Choose up to 2 daily profession quests")
    window.subtitle:SetTextColor(0.7, 0.7, 0.7, 0.8)
    window.titleText = window.subtitle
    
    local contentFrame = CreateFrame("Frame", nil, window)
    contentFrame:SetSize(650, 500)
    contentFrame:SetPoint("TOP", window, "TOP", 0, -50)
    contentFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    contentFrame:SetBackdropColor(0.06, 0.06, 0.1, 0.95)
    contentFrame:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.8)
    
    local contentTitle = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    contentTitle:SetPoint("TOP", contentFrame, "TOP", 0, -15)
    contentTitle:SetText("Available Quests")
    contentTitle:SetTextColor(0.9, 0.8, 0.5, 1)
    contentTitle:SetDrawLayer("OVERLAY", 1)
    contentTitle:Hide()
    window.contentTitle = contentTitle
    
    local noQuestsMessage = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    noQuestsMessage:SetPoint("CENTER", contentFrame, "CENTER", 0, 0)
    noQuestsMessage:SetText("No Quests Available")
    noQuestsMessage:SetTextColor(0.9, 0.8, 0.5, 1)
    noQuestsMessage:SetJustifyH("CENTER")
    window.noQuestsMessage = noQuestsMessage
    
    local noQuestsDescription = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    noQuestsDescription:SetPoint("TOP", noQuestsMessage, "BOTTOM", 0, -10)
    noQuestsDescription:SetText("There are currently no quests available on the call board.\nPlease check back later!")
    noQuestsDescription:SetTextColor(0.7, 0.7, 0.7, 0.8)
    noQuestsDescription:SetJustifyH("CENTER")
    window.noQuestsDescription = noQuestsDescription
    
    -- Create quest container frame
    local questContainer = CreateFrame("Frame", nil, contentFrame)
    questContainer:SetSize(620, 450)
    questContainer:SetPoint("TOP", contentFrame, "TOP", 0, -30)
    
    window.questContainer = questContainer
    window.optionFrames = {}
    
    -- Function to create quest frame
    local function CreateQuestFrame(parent, index)
        local optionFrame = CreateFrame("Frame", nil, parent)
        optionFrame:SetSize(300, 45)
        
        -- Calculate position in 2-column grid
        local col = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        local xOffset = col * 310 -- 300 width + 10 spacing
        local yOffset = -row * 50 -- 45 height + 5 spacing
        
        optionFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
        
        optionFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 32, edgeSize = 6,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        optionFrame:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
        optionFrame:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.8)
        
        local backgroundImage = optionFrame:CreateTexture(nil, "BACKGROUND")
        backgroundImage:SetAllPoints(optionFrame)
        backgroundImage:SetTexCoord(0, 1, 0, 1)
        backgroundImage:SetAlpha(0.7)
        backgroundImage:SetBlendMode("BLEND")
        optionFrame.backgroundImage = backgroundImage
        
        optionFrame:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.13, 0.13, 0.18, 0.95)
            self:SetBackdropBorderColor(0.6, 0.6, 0.7, 0.8)
        end)
        optionFrame:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
            self:SetBackdropBorderColor(0.4, 0.4, 0.5, 0.8)
        end)
        
        local title = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        title:SetPoint("TOPLEFT", optionFrame, "TOPLEFT", 8, -3)
        title:SetTextColor(0.9, 0.8, 0.5, 1)
        optionFrame.title = title
        
        local levelText = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        levelText:SetPoint("TOPRIGHT", optionFrame, "TOPRIGHT", -8, -3)
        levelText:SetTextColor(0.7, 0.7, 0.7, 0.8)
        optionFrame.levelText = levelText
        
        local image = optionFrame:CreateTexture(nil, "ARTWORK")
        image:SetSize(24, 24)
        image:SetPoint("TOPLEFT", optionFrame, "TOPLEFT", 8, -18)
        optionFrame.image = image
        
        local description = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        description:SetPoint("TOPLEFT", image, "TOPRIGHT", 6, 0)
        description:SetPoint("BOTTOMRIGHT", optionFrame, "BOTTOMRIGHT", -70, 6)
        description:SetJustifyH("LEFT")
        description:SetJustifyV("TOP")
        description:SetTextColor(0.8, 0.8, 0.8, 1)
        optionFrame.description = description
        
        local button = CreateFrame("Button", nil, optionFrame)
        button:SetSize(60, 20)
        button:SetPoint("BOTTOMRIGHT", optionFrame, "BOTTOMRIGHT", -8, 6)
        
        button:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 32, edgeSize = 6,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        button:SetBackdropColor(0.15, 0.15, 0.2, 0.95)
        button:SetBackdropBorderColor(0.5, 0.5, 0.6, 1)
        
        button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        button.text:SetPoint("CENTER", button, "CENTER", 0, 0)
        button.text:SetText("Accept")
        button.text:SetTextColor(0.9, 0.9, 0.9, 1)
        
        button:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.2, 0.2, 0.25, 0.95)
            self:SetBackdropBorderColor(0.7, 0.7, 0.8, 1)
            self.text:SetTextColor(1, 1, 1, 1)
        end)
        
        button:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.15, 0.15, 0.2, 0.95)
            self:SetBackdropBorderColor(0.5, 0.5, 0.6, 1)
            self.text:SetTextColor(0.9, 0.9, 0.9, 1)
        end)
        
        button:SetScript("OnMouseDown", function(self)
            self:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
            self.text:SetTextColor(0.8, 0.8, 0.8, 1)
        end)
        
        button:SetScript("OnMouseUp", function(self)
            self:SetBackdropColor(0.2, 0.2, 0.25, 0.95)
            self.text:SetTextColor(1, 1, 1, 1)
        end)
        
        button.optionId = index
        button:SetScript("OnClick", function(self)
            AIO.Msg():Add("HeroesCallBoard", "ButtonClick", {buttonId = self.optionId}):Send()
        end)
        optionFrame.button = button
        
        optionFrame:Hide()
        return optionFrame
    end
    
    window.CreateQuestFrame = CreateQuestFrame
    
    AIO.SavePosition(window)
    
    return window
end

function CallBoardAddon:Initialize()
    self.window = CreateCallBoardWindow()
end

function CallBoardAddon:ShowWindow(callBoardData)
    if self.window then
        self.window:Show()
        isWindowVisible = true
        
        if callBoardData then
            self:UpdateCallBoardData(callBoardData)
        end
        
        PlaySound("igMainMenuOpen")
    end
end

function CallBoardAddon:HideWindow()
    if self.window then
        self.window:Hide()
        isWindowVisible = false
        
        PlaySound("igMainMenuClose")
    end
end

function CallBoardAddon:UpdateCallBoardData(data)
    if self.window and data then
        if self.window.titleText then
            self.window.titleText:SetText(data.title or "Choose up to 2 daily profession quests")
        end
        
        local hasRealQuests = false
        if data.options and #data.options > 0 then
            for _, option in ipairs(data.options) do
                if option.questId and option.questId > 0 then
                    hasRealQuests = true
                    break
                end
            end
        end
        
        -- Hide all existing quest frames
        if self.window.optionFrames then
            for _, frame in ipairs(self.window.optionFrames) do
                frame:Hide()
            end
        end
        
        if hasRealQuests then
            if self.window.contentTitle then
                self.window.contentTitle:Show()
            end
            if self.window.noQuestsMessage then
                self.window.noQuestsMessage:Hide()
            end
            if self.window.noQuestsDescription then
                self.window.noQuestsDescription:Hide()
            end
            if self.window.questContainer then
                self.window.questContainer:Show()
            end
            
            -- Clear existing frames
            self.window.optionFrames = {}
            
            -- Create new quest frames
            if data.options then
                for i, option in ipairs(data.options) do
                    local optionFrame = self.window.CreateQuestFrame(self.window.questContainer, i)
                    optionFrame.title:SetText(option.title)
                    optionFrame.image:SetTexture(option.image)
                    optionFrame.description:SetText(option.description)
                    optionFrame.button.text:SetText(option.buttonText)
                    
                    if option.backgroundImage and option.backgroundImage ~= "" then
                        optionFrame.backgroundImage:SetTexture(option.backgroundImage)
                        optionFrame.backgroundImage:Show()
                    else
                        optionFrame.backgroundImage:Hide()
                    end
                    
                    if option.levelRequired then
                        if option.levelMax and option.levelMax > option.levelRequired then
                            optionFrame.levelText:SetText("Level " .. option.levelRequired .. "-" .. option.levelMax)
                        else
                            optionFrame.levelText:SetText("Level " .. option.levelRequired)
                        end
                    else
                        optionFrame.levelText:SetText("")
                    end
                    
                    optionFrame:Show()
                    table.insert(self.window.optionFrames, optionFrame)
                end
            end
        else
            if self.window.contentTitle then
                self.window.contentTitle:Hide()
            end
            if self.window.noQuestsMessage then
                self.window.noQuestsMessage:Show()
            end
            if self.window.noQuestsDescription then
                self.window.noQuestsDescription:Show()
            end
            if self.window.questContainer then
                self.window.questContainer:Hide()
            end
        end
    end
end

function CallBoardAddon:ToggleWindow()
    if isWindowVisible then
        self:HideWindow()
    else
        self:ShowWindow()
    end
end

local function HandleCallBoardMessage(player, msgType, data)
    if msgType == "ShowCallBoard" then
        CallBoardAddon:ShowWindow(data)
    elseif msgType == "PlaySound" then
        if data and data.soundId then
            PlaySound(data.soundId)
        end
    elseif msgType == "CloseWindow" then
        CallBoardAddon:HideWindow()
    end
end

AIO.RegisterEvent("HeroesCallBoard", HandleCallBoardMessage)

CallBoardAddon:Initialize() 