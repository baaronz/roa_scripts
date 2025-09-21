local AIO = AIO or require("AIO")

if not AIO.IsMainState() then
    return
end

if AIO.AddAddon() then
    print("ProfessionDailyQuest: Server side script loaded!")
    
    local function GetCallBoardQuests(player)
        local quests = {}
        local playerGuid = player:GetGUIDLow()
        local playerLevel = player:GetLevel()
        
        -- Check if player is level 60
        if playerLevel < 60 then
            return {
                {
                    questId = 0,
                    title = "Level Requirement Not Met",
                    description = "You must be level 60 to access daily profession quests. Return when you have reached the maximum level!",
                    image = "Interface\\Icons\\INV_Misc_QuestionMark",
                    buttonText = "Return Later"
                }
            }
        end
        
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
        
        local result = CharDBQuery("SELECT quest_id, quest_name, description, level_required, level_max, icon, background_image FROM roa_profession_daily_quests WHERE active = 1 ORDER BY sort_order ASC, quest_name ASC")
        
        if result then
            repeat
                local questId = result:GetUInt32(0)
                
                -- Check if player has already completed this daily quest today
                local questCompletedResult = CharDBQuery("SELECT quest FROM character_queststatus_daily WHERE guid = " .. playerGuid .. " AND quest = " .. questId .. " AND time >= " .. todayStart)
                local hasCompletedToday = questCompletedResult ~= nil
                
                -- Check if player already has this quest
                local hasQuest = player:HasQuest(questId)
                
                if not hasQuest and not hasCompletedToday then
                    local questData = {
                        questId = questId,
                        title = result:GetString(1),
                        description = result:GetString(2),
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
    contentFrame:SetPoint("TOP", window, "TOP", 0, -70)
    contentFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    contentFrame:SetBackdropColor(0.06, 0.06, 0.1, 0.95)
    contentFrame:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.8)
    
    local contentTitle = contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    contentTitle:SetPoint("TOP", contentFrame, "TOP", 0, -10)
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
    
    -- Create scroll frame for quest container
    local scrollFrame = CreateFrame("ScrollFrame", nil, contentFrame)
    scrollFrame:SetSize(630, 460)
    scrollFrame:SetPoint("TOP", contentFrame, "TOP", 0, -25)
    
    -- Create scroll child frame (this will contain the actual quest frames)
    local questContainer = CreateFrame("Frame", nil, scrollFrame)
    questContainer:SetSize(630, 1) -- Height will be set dynamically based on content
    scrollFrame:SetScrollChild(questContainer)
    
    -- Create scroll bar
    local scrollBar = CreateFrame("Slider", nil, scrollFrame, "UIPanelScrollBarTemplate")
    scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 4, -16)
    scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 4, 16)
    scrollBar:SetMinMaxValues(1, 100)
    scrollBar:SetValueStep(1)
    scrollBar.scrollStep = 1
    scrollBar:SetValue(0)
    scrollBar:SetWidth(16)
    scrollBar:SetScript("OnValueChanged", function(self, value)
        self:GetParent():SetVerticalScroll(value)
    end)
    
    -- Enable mouse wheel scrolling
    scrollFrame:EnableMouseWheel(true)
    scrollFrame:SetScript("OnMouseWheel", function(self, delta)
        local newValue = scrollBar:GetValue() - (delta * 20)
        local minVal, maxVal = scrollBar:GetMinMaxValues()
        newValue = math.max(minVal, math.min(maxVal, newValue))
        scrollBar:SetValue(newValue)
    end)
    
    window.scrollFrame = scrollFrame
    window.scrollBar = scrollBar
    window.questContainer = questContainer
    window.optionFrames = {}
    
    -- Function to create quest frame
    local function CreateQuestFrame(parent, index)
        local optionFrame = CreateFrame("Frame", nil, parent)
        optionFrame:SetSize(300, 60)
        
        -- Calculate position in 2-column grid with proper spacing
        local col = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        local xOffset = 10 + (col * 315) -- 10px left margin + 300 width + 5 spacing
        local yOffset = -10 - (row * 70) -- 10px top margin + 60 height + 10 spacing
        
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
        
        local image = optionFrame:CreateTexture(nil, "ARTWORK")
        image:SetSize(36, 36)
        image:SetPoint("LEFT", optionFrame, "LEFT", 8, 0)
        optionFrame.image = image
        
        local title = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        title:SetPoint("TOPLEFT", image, "TOPRIGHT", 6, 8)
        title:SetPoint("TOPRIGHT", optionFrame, "TOPRIGHT", -80, 8)
        title:SetJustifyH("LEFT")
        title:SetTextColor(0.9, 0.8, 0.5, 1)
        title:SetHeight(14)
        optionFrame.title = title
        
        local description = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        description:SetPoint("TOPLEFT", image, "TOPRIGHT", 6, -8)
        description:SetPoint("BOTTOMRIGHT", optionFrame, "BOTTOMRIGHT", -80, 10)
        description:SetJustifyH("LEFT")
        description:SetJustifyV("TOP")
        description:SetTextColor(0.8, 0.8, 0.8, 1)
        description:SetHeight(32)
        optionFrame.description = description
        
        local button = CreateFrame("Button", nil, optionFrame)
        button:SetSize(65, 24)
        button:SetPoint("RIGHT", optionFrame, "RIGHT", -6, 0)
        
        button:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 32, edgeSize = 6,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        button:SetBackdropColor(0.15, 0.15, 0.2, 0.95)
        button:SetBackdropBorderColor(0.5, 0.5, 0.6, 1)
        
        button.text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
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
            if self.window.scrollFrame then
                self.window.scrollFrame:Show()
            end
            
            -- Clear existing frames
            self.window.optionFrames = {}
            
            -- Create new quest frames
            if data.options then
                local numQuests = #data.options
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
                    
                    optionFrame:Show()
                    table.insert(self.window.optionFrames, optionFrame)
                end
                
                -- Calculate required height for quest container
                local numRows = math.ceil(numQuests / 2)
                local requiredHeight = math.max(460, (numRows * 70) + 20) -- 70px per row + 20px padding
                self.window.questContainer:SetHeight(requiredHeight)
                
                -- Update scroll bar
                if self.window.scrollBar then
                    local maxScroll = math.max(0, requiredHeight - 460)
                    self.window.scrollBar:SetMinMaxValues(0, maxScroll)
                    self.window.scrollBar:SetValue(0)
                    
                    -- Show/hide scroll bar based on whether scrolling is needed
                    if maxScroll > 0 then
                        self.window.scrollBar:Show()
                    else
                        self.window.scrollBar:Hide()
                    end
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
            if self.window.scrollFrame then
                self.window.scrollFrame:Hide()
            end
            if self.window.scrollBar then
                self.window.scrollBar:Hide()
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