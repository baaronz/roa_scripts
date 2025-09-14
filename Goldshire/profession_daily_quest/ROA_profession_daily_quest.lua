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
        
        local result = CharDBQuery("SELECT quest_id, quest_name, description, level_required, level_max, icon, background_image FROM roa_profession_daily_quests WHERE active = 1 ORDER BY sort_order ASC, quest_name ASC")
        
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
        
        -- Enhanced main window backdrop
        window:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 11, right = 12, top = 12, bottom = 11 }
        })
        window:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
        window:SetBackdropBorderColor(0.8, 0.7, 0.4, 1.0)
        window:SetAlpha(1.0)
        
        -- Add decorative corner elements
        local topLeftCorner = window:CreateTexture(nil, "ARTWORK")
        topLeftCorner:SetSize(32, 32)
        topLeftCorner:SetPoint("TOPLEFT", window, "TOPLEFT", -5, 5)
        topLeftCorner:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner-TopLeft")
        topLeftCorner:SetVertexColor(0.8, 0.7, 0.4, 1)
        
        local topRightCorner = window:CreateTexture(nil, "ARTWORK")
        topRightCorner:SetSize(32, 32)
        topRightCorner:SetPoint("TOPRIGHT", window, "TOPRIGHT", 5, 5)
        topRightCorner:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner-TopRight")
        topRightCorner:SetVertexColor(0.8, 0.7, 0.4, 1)
        
        local bottomLeftCorner = window:CreateTexture(nil, "ARTWORK")
        bottomLeftCorner:SetSize(32, 32)
        bottomLeftCorner:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT", -5, -5)
        bottomLeftCorner:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner-BottomLeft")
        bottomLeftCorner:SetVertexColor(0.8, 0.7, 0.4, 1)
        
        local bottomRightCorner = window:CreateTexture(nil, "ARTWORK")
        bottomRightCorner:SetSize(32, 32)
        bottomRightCorner:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", 5, -5)
        bottomRightCorner:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Corner-BottomRight")
        bottomRightCorner:SetVertexColor(0.8, 0.7, 0.4, 1)
        
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
    
    -- Enhanced title with decorative elements
    local titleBackground = window:CreateTexture(nil, "BACKGROUND")
    titleBackground:SetSize(600, 50)
    titleBackground:SetPoint("TOP", window, "TOP", 0, -15)
    titleBackground:SetColorTexture(0.1, 0.08, 0.05, 0.6)
    titleBackground:SetGradientAlpha("VERTICAL", 0.15, 0.12, 0.08, 0.8, 0.05, 0.04, 0.02, 0.4)
    
    window.title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    window.title:SetPoint("TOP", window, "TOP", 0, -20)
    window.title:SetText("DAILY PROFESSION QUESTS")
    window.title:SetTextColor(1.0, 0.9, 0.6, 1)
    window.title:SetShadowOffset(2, -2)
    window.title:SetShadowColor(0, 0, 0, 0.8)
    
    -- Add decorative lines
    local leftLine = window:CreateTexture(nil, "ARTWORK")
    leftLine:SetSize(100, 2)
    leftLine:SetPoint("RIGHT", window.title, "LEFT", -10, 0)
    leftLine:SetColorTexture(0.8, 0.7, 0.4, 0.8)
    
    local rightLine = window:CreateTexture(nil, "ARTWORK")
    rightLine:SetSize(100, 2)
    rightLine:SetPoint("LEFT", window.title, "RIGHT", 10, 0)
    rightLine:SetColorTexture(0.8, 0.7, 0.4, 0.8)
    
    window.subtitle = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    window.subtitle:SetPoint("TOP", window.title, "BOTTOM", 0, -5)
    window.subtitle:SetText("Choose up to 2 daily profession quests")
    window.subtitle:SetTextColor(0.9, 0.8, 0.6, 1)
    window.subtitle:SetShadowOffset(1, -1)
    window.subtitle:SetShadowColor(0, 0, 0, 0.6)
    window.titleText = window.subtitle
    
    local contentFrame = CreateFrame("Frame", nil, window)
    contentFrame:SetSize(650, 500)
    contentFrame:SetPoint("TOP", window, "TOP", 0, -50)
    -- Enhanced content frame styling
    contentFrame:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 8, right = 8, top = 8, bottom = 8 }
    })
    contentFrame:SetBackdropColor(0.03, 0.03, 0.06, 0.9)
    contentFrame:SetBackdropBorderColor(0.6, 0.5, 0.3, 0.9)
    
    -- Add inner glow effect
    local innerGlow = contentFrame:CreateTexture(nil, "BACKGROUND")
    innerGlow:SetAllPoints(contentFrame)
    innerGlow:SetColorTexture(0.1, 0.08, 0.05, 0.3)
    innerGlow:SetGradientAlpha("VERTICAL", 0.08, 0.06, 0.04, 0.4, 0.02, 0.02, 0.03, 0.2)
    
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
        optionFrame:SetSize(290, 55)
        
        -- Calculate position in 2-column grid with proper spacing
        local col = (index - 1) % 2
        local row = math.floor((index - 1) / 2)
        local xOffset = 15 + (col * 305) -- 15px left margin + 290 width + 15 spacing
        local yOffset = -15 - (row * 65) -- 15px top margin + 55 height + 10 spacing
        
        optionFrame:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
        
        -- Enhanced backdrop with better styling
        optionFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 12,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })
        optionFrame:SetBackdropColor(0.08, 0.08, 0.12, 0.9)
        optionFrame:SetBackdropBorderColor(0.6, 0.5, 0.3, 0.8)
        
        -- Add subtle gradient effect
        local gradientTexture = optionFrame:CreateTexture(nil, "BACKGROUND")
        gradientTexture:SetAllPoints(optionFrame)
        gradientTexture:SetColorTexture(0.15, 0.12, 0.08, 0.3)
        gradientTexture:SetGradientAlpha("VERTICAL", 0.2, 0.15, 0.1, 0.3, 0.05, 0.05, 0.05, 0.1)
        
        local backgroundImage = optionFrame:CreateTexture(nil, "BACKGROUND")
        backgroundImage:SetAllPoints(optionFrame)
        backgroundImage:SetTexCoord(0, 1, 0, 1)
        backgroundImage:SetAlpha(0.4)
        backgroundImage:SetBlendMode("BLEND")
        optionFrame.backgroundImage = backgroundImage
        
        -- Enhanced hover effects
        optionFrame:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.12, 0.12, 0.16, 0.95)
            self:SetBackdropBorderColor(0.8, 0.7, 0.4, 1.0)
            gradientTexture:SetGradientAlpha("VERTICAL", 0.25, 0.2, 0.12, 0.4, 0.08, 0.08, 0.08, 0.2)
        end)
        optionFrame:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.08, 0.08, 0.12, 0.9)
            self:SetBackdropBorderColor(0.6, 0.5, 0.3, 0.8)
            gradientTexture:SetGradientAlpha("VERTICAL", 0.2, 0.15, 0.1, 0.3, 0.05, 0.05, 0.05, 0.1)
        end)
        
        -- Quest icon with border
        local iconBorder = optionFrame:CreateTexture(nil, "ARTWORK")
        iconBorder:SetSize(34, 34)
        iconBorder:SetPoint("LEFT", optionFrame, "LEFT", 12, 0)
        iconBorder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        iconBorder:SetVertexColor(0.6, 0.5, 0.3, 0.8)
        
        local image = optionFrame:CreateTexture(nil, "ARTWORK")
        image:SetSize(30, 30)
        image:SetPoint("CENTER", iconBorder, "CENTER", 0, 0)
        optionFrame.image = image
        
        -- Title with better positioning
        local title = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", iconBorder, "TOPRIGHT", 8, 0)
        title:SetPoint("TOPRIGHT", optionFrame, "TOPRIGHT", -85, 0)
        title:SetJustifyH("LEFT")
        title:SetTextColor(1.0, 0.9, 0.6, 1)
        title:SetMaxLines(1)
        optionFrame.title = title
        
        -- Level text with better styling
        local levelText = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        levelText:SetPoint("TOPRIGHT", optionFrame, "TOPRIGHT", -12, -8)
        levelText:SetTextColor(0.8, 0.8, 0.9, 1)
        optionFrame.levelText = levelText
        
        -- Description with proper text wrapping
        local description = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        description:SetPoint("TOPLEFT", iconBorder, "TOPRIGHT", 8, -18)
        description:SetPoint("BOTTOMRIGHT", optionFrame, "BOTTOMRIGHT", -85, 8)
        description:SetJustifyH("LEFT")
        description:SetJustifyV("TOP")
        description:SetTextColor(0.85, 0.85, 0.85, 1)
        description:SetMaxLines(2)
        optionFrame.description = description
        
        -- Enhanced button styling
        local button = CreateFrame("Button", nil, optionFrame)
        button:SetSize(70, 25)
        button:SetPoint("RIGHT", optionFrame, "RIGHT", -10, 0)
        
        -- Professional button styling
        button:SetBackdrop({
            bgFile = "Interface\\Buttons\\UI-Panel-Button-Up",
            edgeFile = "Interface\\Buttons\\UI-Panel-Button-Border",
            tile = false, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        button:SetBackdropColor(0.2, 0.35, 0.6, 0.8)
        button:SetBackdropBorderColor(0.8, 0.7, 0.4, 1)
        
        -- Button gradient effect
        local buttonGradient = button:CreateTexture(nil, "BACKGROUND")
        buttonGradient:SetAllPoints(button)
        buttonGradient:SetColorTexture(0.3, 0.5, 0.8, 0.4)
        buttonGradient:SetGradientAlpha("VERTICAL", 0.4, 0.6, 0.9, 0.6, 0.2, 0.3, 0.5, 0.3)
        
        button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        button.text:SetPoint("CENTER", button, "CENTER", 0, 0)
        button.text:SetText("Accept")
        button.text:SetTextColor(1, 1, 1, 1)
        button.text:SetShadowOffset(1, -1)
        button.text:SetShadowColor(0, 0, 0, 0.8)
        
        button:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.25, 0.4, 0.7, 1.0)
            self:SetBackdropBorderColor(1.0, 0.8, 0.5, 1)
            buttonGradient:SetGradientAlpha("VERTICAL", 0.5, 0.7, 1.0, 0.8, 0.25, 0.4, 0.6, 0.5)
            self.text:SetTextColor(1, 1, 1, 1)
        end)
        
        button:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.2, 0.35, 0.6, 0.8)
            self:SetBackdropBorderColor(0.8, 0.7, 0.4, 1)
            buttonGradient:SetGradientAlpha("VERTICAL", 0.4, 0.6, 0.9, 0.6, 0.2, 0.3, 0.5, 0.3)
            self.text:SetTextColor(1, 1, 1, 1)
        end)
        
        button:SetScript("OnMouseDown", function(self)
            self:SetBackdropColor(0.15, 0.25, 0.45, 0.9)
            buttonGradient:SetGradientAlpha("VERTICAL", 0.2, 0.3, 0.5, 0.4, 0.4, 0.6, 0.9, 0.7)
            self.text:SetTextColor(0.9, 0.9, 0.9, 1)
        end)
        
        button:SetScript("OnMouseUp", function(self)
            self:SetBackdropColor(0.25, 0.4, 0.7, 1.0)
            buttonGradient:SetGradientAlpha("VERTICAL", 0.5, 0.7, 1.0, 0.8, 0.25, 0.4, 0.6, 0.5)
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