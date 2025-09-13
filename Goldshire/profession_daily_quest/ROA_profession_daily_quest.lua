local AIO = AIO or require("AIO")

if not AIO.IsMainState() then
    return
end

if AIO.AddAddon() then
    print("ProfessionDailyQuest: Server side script loaded!")
    
    -- Configuration
    local DAILY_QUEST_LIMIT = 2
    local NPC_ENTRY_ID = 1275 -- Change this to your NPC entry ID
    
    -- Helper function to get today's date string
    local function GetTodayDateString()
        return os.date("%Y-%m-%d")
    end
    
    -- Helper function to get player's daily quest progress
    local function GetPlayerDailyProgress(player)
        local playerGuid = player:GetGUIDLow()
        local today = GetTodayDateString()
        local result = WorldDBQuery("SELECT quest_id, status FROM player_daily_quest_progress WHERE player_guid = " .. playerGuid .. " AND date_taken = '" .. today .. "'")
        
        local takenQuests = {}
        local completedQuests = {}
        local totalTaken = 0
        
        if result then
            repeat
                local questId = result:GetUInt32(0)
                local status = result:GetString(1)
                totalTaken = totalTaken + 1
                
                if status == "taken" then
                    table.insert(takenQuests, questId)
                elseif status == "completed" then
                    table.insert(completedQuests, questId)
                end
            until not result:NextRow()
        end
        
        return takenQuests, completedQuests, totalTaken
    end
    
    -- Helper function to check if player can take more quests
    local function CanTakeMoreQuests(player)
        local _, _, totalTaken = GetPlayerDailyProgress(player)
        return totalTaken < DAILY_QUEST_LIMIT
    end
    
    -- Helper function to add quest progress to database
    local function AddQuestProgress(player, questId, status)
        local playerGuid = player:GetGUIDLow()
        local today = GetTodayDateString()
        
        local query = string.format([[
            INSERT INTO player_daily_quest_progress (player_guid, quest_id, date_taken, status) 
            VALUES (%d, %d, '%s', '%s') 
            ON DUPLICATE KEY UPDATE status = '%s'
        ]], playerGuid, questId, today, status, status)
        
        WorldDBExecute(query)
    end
    
    -- Main function to get available profession daily quests
    local function GetProfessionDailyQuests(player)
        local quests = {}
        local takenQuests, completedQuests, totalTaken = GetPlayerDailyProgress(player)
        local canTakeMore = CanTakeMoreQuests(player)
        
        -- Create lookup tables for faster checking
        local takenLookup = {}
        local completedLookup = {}
        
        for _, questId in ipairs(takenQuests) do
            takenLookup[questId] = true
        end
        
        for _, questId in ipairs(completedQuests) do
            completedLookup[questId] = true
        end
        
        local result = WorldDBQuery([[
            SELECT quest_id, quest_name, description, level_required, level_max, 
                   profession_type, icon, background_image, reward_gold, reward_xp 
            FROM profession_daily_quests 
            WHERE active = 1 
            ORDER BY sort_order ASC, quest_name ASC
        ]])
        
        if result then
            repeat
                local questId = result:GetUInt32(0)
                local levelRequired = result:GetUInt32(3)
                local levelMax = result:GetUInt32(4)
                local playerLevel = player:GetLevel()
                
                -- Check if player meets level requirements and doesn't already have the quest
                if playerLevel >= levelRequired and playerLevel <= levelMax and not player:HasQuest(questId) then
                    local status = "available"
                    local buttonText = "Accept Quest"
                    local canAccept = canTakeMore and not takenLookup[questId] and not completedLookup[questId]
                    
                    if completedLookup[questId] then
                        status = "completed"
                        buttonText = "Completed"
                    elseif takenLookup[questId] then
                        status = "taken"
                        buttonText = "In Progress"
                    elseif not canTakeMore then
                        status = "limit_reached"
                        buttonText = "Daily Limit Reached"
                    end
                    
                    local questData = {
                        questId = questId,
                        title = result:GetString(1),
                        description = result:GetString(2),
                        levelRequired = levelRequired,
                        levelMax = levelMax,
                        professionType = result:GetString(5),
                        image = result:GetString(6),
                        backgroundImage = result:GetString(7),
                        rewardGold = result:GetUInt32(8),
                        rewardXp = result:GetUInt32(9),
                        status = status,
                        buttonText = buttonText,
                        canAccept = canAccept
                    }
                
                    table.insert(quests, questData)
                end
            until not result:NextRow()
        end
        
        -- If no quests available, show appropriate message
        if #quests == 0 then
            quests = {
                {
                    questId = 0,
                    title = "No Quests Available",
                    description = "There are currently no profession daily quests available for your level range.",
                    levelRequired = 1,
                    professionType = "General",
                    image = "Interface\\Icons\\INV_Misc_QuestionMark",
                    buttonText = "Check Later",
                    canAccept = false
                }
            }
        end
        
        return quests, totalTaken, DAILY_QUEST_LIMIT
    end
    
    -- Gossip menu system
    local function OnGossipHello(event, player, object)
        player:GossipClearMenu()
        player:GossipMenuAddItem(0, "|TInterface\\Icons\\Trade_Engineering:20:20|t View Profession Daily Quests", 0, 1)
        player:GossipSendMenu(1, object, 1)
    end
    
    local function OnGossipSelect(event, player, object, sender, intid, code, menu_id)
        if intid == 1 then
            local quests, totalTaken, limit = GetProfessionDailyQuests(player)
            
            local professionData = {
                title = "Profession Daily Quests",
                subtitle = string.format("Complete up to %d quests per day (%d/%d taken today)", limit, totalTaken, limit),
                options = quests,
                totalTaken = totalTaken,
                limit = limit
            }
            
            AIO.Msg():Add("ProfessionDailyQuest", "ShowProfessionBoard", professionData):Send(player)
            
            player:GossipComplete()
        end
    end

    RegisterCreatureGossipEvent(NPC_ENTRY_ID, 1, OnGossipHello)
    RegisterCreatureGossipEvent(NPC_ENTRY_ID, 2, OnGossipSelect)
    
    -- Handle quest acceptance
    local function HandleProfessionQuestRequest(player, msgType, data)
        if not player or not player:IsInWorld() then
            return
        end
        
        if msgType == "AcceptQuest" then
            local questId = data.questId
            
            if questId and questId > 0 then
                -- Double-check if player can still take quests
                if CanTakeMoreQuests(player) then
                    local takenQuests, completedQuests, _ = GetPlayerDailyProgress(player)
                    
                    -- Check if quest is not already taken or completed today
                    local alreadyTaken = false
                    for _, takenId in ipairs(takenQuests) do
                        if takenId == questId then
                            alreadyTaken = true
                            break
                        end
                    end
                    
                    for _, completedId in ipairs(completedQuests) do
                        if completedId == questId then
                            alreadyTaken = true
                            break
                        end
                    end
                    
                    if not alreadyTaken and not player:HasQuest(questId) then
                        player:AddQuest(questId)
                        AddQuestProgress(player, questId, "taken")
                        
                        -- Send updated quest list
                        local quests, totalTaken, limit = GetProfessionDailyQuests(player)
                        local professionData = {
                            title = "Profession Daily Quests",
                            subtitle = string.format("Complete up to %d quests per day (%d/%d taken today)", limit, totalTaken, limit),
                            options = quests,
                            totalTaken = totalTaken,
                            limit = limit
                        }
                        
                        AIO.Msg():Add("ProfessionDailyQuest", "ShowProfessionBoard", professionData):Send(player)
                        
                        player:SendNotification("Quest accepted! You have taken " .. (totalTaken + 1) .. "/" .. limit .. " daily quests today.")
                    end
                end
            end
        elseif msgType == "CloseWindow" then
            AIO.Msg():Add("ProfessionDailyQuest", "CloseWindow", {}):Send(player)
        end
    end
    
    -- Handle quest completion tracking
    local function OnQuestComplete(event, player, questId)
        local takenQuests, _, _ = GetPlayerDailyProgress(player)
        
        -- Check if this was a daily quest we're tracking
        for _, takenId in ipairs(takenQuests) do
            if takenId == questId then
                AddQuestProgress(player, questId, "completed")
                player:SendNotification("Daily quest completed! Check back tomorrow for new quests.")
                break
            end
        end
    end
    
    RegisterPlayerEvent(8, OnQuestComplete) -- PLAYER_EVENT_ON_QUEST_COMPLETE
    
    AIO.RegisterEvent("ProfessionDailyQuest", HandleProfessionQuestRequest)
    return
end

-- Client-side addon
local ProfessionDailyQuestAddon = {}
local isWindowVisible = false

local function CreateProfessionBoardWindow()
    local window = CreateFrame("Frame", "ProfessionBoardWindow", UIParent)
    window:SetSize(700, 500) -- Smaller window for better fit
    window:SetPoint("CENTER", UIParent, "CENTER")
    window:SetMovable(false)
    window:EnableMouse(true)
    window:Hide()
    
    window:EnableKeyboard(true)
    window:SetScript("OnKeyDown", function(self, key)
        if key == "ESCAPE" then
            ProfessionDailyQuestAddon:HideWindow()
        end
    end)
    
    window:SetBackdrop({
        bgFile = "Interface\\AchievementFrame\\UI-Achievement-Parchment-Horizontal",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    window:SetAlpha(1.0)
    
    -- Close button
    local closeButton = CreateFrame("Button", nil, window)
    closeButton:SetSize(28, 28)
    closeButton:SetPoint("TOPRIGHT", window, "TOPRIGHT", -10, -10)
    
    closeButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    closeButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    closeButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
    
    closeButton:SetScript("OnClick", function()
        ProfessionDailyQuestAddon:HideWindow()
    end)
    
    window.title = window:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    window.title:SetPoint("TOP", window, "TOP", 0, -25)
    window.title:SetText("PROFESSION DAILY QUESTS")
    window.title:SetTextColor(0.9, 0.8, 0.5, 1)
    
    window.subtitle = window:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    window.subtitle:SetPoint("TOP", window.title, "BOTTOM", 0, -5)
    window.subtitle:SetText("Complete up to 2 quests per day")
    window.subtitle:SetTextColor(0.7, 0.7, 0.7, 0.8)
    window.titleText = window.subtitle
    
    -- Progress bar
    local progressFrame = CreateFrame("Frame", nil, window)
    progressFrame:SetSize(300, 20)
    progressFrame:SetPoint("TOP", window.subtitle, "BOTTOM", 0, -15)
    progressFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 6,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    progressFrame:SetBackdropColor(0.1, 0.1, 0.15, 0.95)
    
    local progressBar = CreateFrame("StatusBar", nil, progressFrame)
    progressBar:SetSize(290, 14)
    progressBar:SetPoint("CENTER", progressFrame, "CENTER")
    progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    progressBar:SetStatusBarColor(0.2, 0.8, 0.2, 1)
    progressBar:SetMinMaxValues(0, 2)
    progressBar:SetValue(0)
    
    local progressText = progressFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    progressText:SetPoint("CENTER", progressFrame, "CENTER")
    progressText:SetText("0/2 Quests Taken")
    progressText:SetTextColor(0.9, 0.9, 0.9, 1)
    window.progressText = progressText
    window.progressBar = progressBar
    
    -- Scrollable content frame
    local contentFrame = CreateFrame("Frame", nil, window)
    contentFrame:SetSize(660, 350) -- Reduced height for more compact design
    contentFrame:SetPoint("TOP", progressFrame, "BOTTOM", 0, -15)
    contentFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    contentFrame:SetBackdropColor(0.06, 0.06, 0.1, 0.95)
    contentFrame:SetBackdropBorderColor(0.5, 0.5, 0.6, 0.8)
    
    -- Create scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, contentFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetSize(620, 310)
    scrollFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", contentFrame, "BOTTOMRIGHT", -30, 10)
    
    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(600, 300)
    scrollFrame:SetScrollChild(scrollChild)
    
    window.scrollChild = scrollChild
    window.scrollFrame = scrollFrame
    
    -- Create compact quest frames (more can fit now)
    window.optionFrames = {}
    for i = 1, 20 do -- Increased from 3 to 20
        local optionFrame = CreateFrame("Frame", nil, scrollChild)
        optionFrame:SetSize(580, 70) -- Reduced height from 110 to 70 for more compact design
        
        if i == 1 then
            optionFrame:SetPoint("TOP", scrollChild, "TOP", 0, -10)
        else
            optionFrame:SetPoint("TOP", window.optionFrames[i-1], "BOTTOM", 0, -5)
        end
        
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
        
        -- Compact title and profession type
        local title = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", optionFrame, "TOPLEFT", 60, -8)
        title:SetTextColor(0.9, 0.8, 0.5, 1)
        optionFrame.title = title
        
        local professionType = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        professionType:SetPoint("TOPRIGHT", optionFrame, "TOPRIGHT", -80, -8)
        professionType:SetTextColor(0.7, 0.7, 0.7, 0.8)
        optionFrame.professionType = professionType
        
        local levelText = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        levelText:SetPoint("TOPRIGHT", optionFrame, "TOPRIGHT", -15, -8)
        levelText:SetTextColor(0.7, 0.7, 0.7, 0.8)
        optionFrame.levelText = levelText
        
        -- Smaller icon
        local image = optionFrame:CreateTexture(nil, "ARTWORK")
        image:SetSize(32, 32) -- Reduced from 48x48 to 32x32
        image:SetPoint("TOPLEFT", optionFrame, "TOPLEFT", 15, -19)
        optionFrame.image = image
        
        -- Compact description (shorter)
        local description = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        description:SetPoint("TOPLEFT", image, "TOPRIGHT", 10, 0)
        description:SetPoint("BOTTOMRIGHT", optionFrame, "BOTTOMRIGHT", -80, 25)
        description:SetJustifyH("LEFT")
        description:SetJustifyV("TOP")
        description:SetTextColor(0.8, 0.8, 0.8, 1)
        optionFrame.description = description
        
        -- Reward info
        local rewardText = optionFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        rewardText:SetPoint("BOTTOMLEFT", optionFrame, "BOTTOMLEFT", 60, 8)
        rewardText:SetTextColor(0.7, 0.9, 0.7, 1)
        optionFrame.rewardText = rewardText
        
        -- Compact button
        local button = CreateFrame("Button", nil, optionFrame)
        button:SetSize(100, 24) -- Smaller button
        button:SetPoint("BOTTOMRIGHT", optionFrame, "BOTTOMRIGHT", -15, 8)
        
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
        button.text:SetText("Action")
        button.text:SetTextColor(0.9, 0.9, 0.9, 1)
        
        button:SetScript("OnEnter", function(self)
            if self.canAccept then
                self:SetBackdropColor(0.2, 0.2, 0.25, 0.95)
                self:SetBackdropBorderColor(0.7, 0.7, 0.8, 1)
                self.text:SetTextColor(1, 1, 1, 1)
            end
        end)
        
        button:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0.15, 0.15, 0.2, 0.95)
            self:SetBackdropBorderColor(0.5, 0.5, 0.6, 1)
            self.text:SetTextColor(0.9, 0.9, 0.9, 1)
        end)
        
        button:SetScript("OnClick", function(self)
            if self.canAccept and self.questId > 0 then
                AIO.Msg():Add("ProfessionDailyQuest", "AcceptQuest", {questId = self.questId}):Send()
            end
        end)
        
        button.optionId = i
        optionFrame.button = button
        
        optionFrame:Hide()
        window.optionFrames[i] = optionFrame
    end
    
    return window
end

function ProfessionDailyQuestAddon:Initialize()
    self.window = CreateProfessionBoardWindow()
end

function ProfessionDailyQuestAddon:ShowWindow(professionData)
    if self.window then
        self.window:Show()
        isWindowVisible = true
        
        if professionData then
            self:UpdateProfessionData(professionData)
        end
        
        PlaySound("igMainMenuOpen")
    end
end

function ProfessionDailyQuestAddon:HideWindow()
    if self.window then
        self.window:Hide()
        isWindowVisible = false
        
        PlaySound("igMainMenuClose")
    end
end

function ProfessionDailyQuestAddon:UpdateProfessionData(data)
    if self.window and data then
        -- Update title and subtitle
        if self.window.titleText then
            self.window.titleText:SetText(data.subtitle or "Complete up to 2 quests per day")
        end
        
        -- Update progress bar
        if self.window.progressBar and self.window.progressText then
            local totalTaken = data.totalTaken or 0
            local limit = data.limit or 2
            self.window.progressBar:SetValue(totalTaken)
            self.window.progressText:SetText(totalTaken .. "/" .. limit .. " Quests Taken")
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
        
        if hasRealQuests then
            -- Hide no quests message
            if self.window.noQuestsMessage then
                self.window.noQuestsMessage:Hide()
            end
            if self.window.noQuestsDescription then
                self.window.noQuestsDescription:Hide()
            end
            
            -- Update quest frames
            if self.window.optionFrames and data.options then
                for i, option in ipairs(data.options) do
                    local optionFrame = self.window.optionFrames[i]
                    if optionFrame then
                        optionFrame.title:SetText(option.title)
                        optionFrame.professionType:SetText("[" .. option.professionType .. "]")
                        optionFrame.image:SetTexture(option.image)
                        
                        -- Truncate description for compact display
                        local desc = option.description
                        if string.len(desc) > 80 then
                            desc = string.sub(desc, 1, 77) .. "..."
                        end
                        optionFrame.description:SetText(desc)
                        
                        -- Set button text and state
                        optionFrame.button.text:SetText(option.buttonText)
                        optionFrame.button.questId = option.questId
                        optionFrame.button.canAccept = option.canAccept
                        
                        -- Update button appearance based on status
                        if option.status == "completed" then
                            optionFrame.button:SetBackdropColor(0.1, 0.4, 0.1, 0.95)
                            optionFrame.button.text:SetTextColor(0.7, 0.9, 0.7, 1)
                        elseif option.status == "taken" then
                            optionFrame.button:SetBackdropColor(0.4, 0.4, 0.1, 0.95)
                            optionFrame.button.text:SetTextColor(0.9, 0.9, 0.7, 1)
                        elseif option.status == "limit_reached" then
                            optionFrame.button:SetBackdropColor(0.4, 0.1, 0.1, 0.95)
                            optionFrame.button.text:SetTextColor(0.9, 0.7, 0.7, 1)
                        else
                            optionFrame.button:SetBackdropColor(0.15, 0.15, 0.2, 0.95)
                            optionFrame.button.text:SetTextColor(0.9, 0.9, 0.9, 1)
                        end
                        
                        -- Level requirement
                        if option.levelRequired then
                            if option.levelMax and option.levelMax > option.levelRequired then
                                optionFrame.levelText:SetText("Level " .. option.levelRequired .. "-" .. option.levelMax)
                            else
                                optionFrame.levelText:SetText("Level " .. option.levelRequired)
                            end
                        else
                            optionFrame.levelText:SetText("")
                        end
                        
                        -- Reward info
                        local rewardInfo = ""
                        if option.rewardGold > 0 then
                            rewardInfo = rewardInfo .. option.rewardGold .. " Gold"
                        end
                        if option.rewardXp > 0 then
                            if rewardInfo ~= "" then
                                rewardInfo = rewardInfo .. ", "
                            end
                            rewardInfo = rewardInfo .. option.rewardXp .. " XP"
                        end
                        optionFrame.rewardText:SetText(rewardInfo)
                        
                        -- Background image
                        if option.backgroundImage and option.backgroundImage ~= "" then
                            optionFrame.backgroundImage:SetTexture(option.backgroundImage)
                            optionFrame.backgroundImage:Show()
                        else
                            optionFrame.backgroundImage:Hide()
                        end
                        
                        optionFrame:Show()
                    end
                end
                
                -- Hide unused frames
                for i = #data.options + 1, #self.window.optionFrames do
                    if self.window.optionFrames[i] then
                        self.window.optionFrames[i]:Hide()
                    end
                end
            end
        else
            -- Show no quests message
            if self.window.noQuestsMessage then
                self.window.noQuestsMessage:Show()
            end
            if self.window.noQuestsDescription then
                self.window.noQuestsDescription:Show()
            end
            
            -- Hide all quest frames
            if self.window.optionFrames then
                for _, optionFrame in ipairs(self.window.optionFrames) do
                    optionFrame:Hide()
                end
            end
        end
        
        -- Update scroll child height based on number of visible quests
        local visibleQuests = math.min(#data.options or 0, 20)
        local newHeight = math.max(visibleQuests * 75, 100) -- 75 pixels per quest (70 height + 5 margin)
        self.window.scrollChild:SetHeight(newHeight)
    end
end

function ProfessionDailyQuestAddon:ToggleWindow()
    if isWindowVisible then
        self:HideWindow()
    else
        self:ShowWindow()
    end
end

local function HandleProfessionQuestMessage(player, msgType, data)
    if msgType == "ShowProfessionBoard" then
        ProfessionDailyQuestAddon:ShowWindow(data)
    elseif msgType == "CloseWindow" then
        ProfessionDailyQuestAddon:HideWindow()
    end
end

AIO.RegisterEvent("ProfessionDailyQuest", HandleProfessionQuestMessage)

ProfessionDailyQuestAddon:Initialize()