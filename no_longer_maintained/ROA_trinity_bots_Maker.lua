--[[
Bot Maker Script
A script that allows players to create random NPC bots using the .createbot command.

Usage:
.createbot <number> - Creates the specified number of random bots

Features:
- Creates bots with random race and class combinations
- First number (race): 1-9 and 11
- Second number (class): 1-8, 10 and 11
- Uses the .npcbot createnew command internally
]]

-- Command handler for .createbot
local function OnCommand(event, player, command)
    -- Parse command arguments
    local args = {}
    for word in string.gmatch(command, "%S+") do
        table.insert(args, word)
    end
    
    if args[1] == "createbot" then
        -- Check if player has GM permissions
        if not player:IsGM() then
            player:SendBroadcastMessage("|c979ABDFFYou need GM permissions to use this command.|r")
            return false
        end
        
        -- Check if number argument is provided
        if not args[2] then
            player:SendBroadcastMessage("|c979ABDFFUsage: .createbot <number>|r")
            player:SendBroadcastMessage("|c979ABDFFExample: .createbot 5|r")
            return false
        end
        
        local numBots = tonumber(args[2])
        
        -- Validate the number
        if not numBots or numBots < 1 or numBots > 100 then
            player:SendBroadcastMessage("|c979ABDFFPlease provide a valid number between 1 and 100.|r")
            return false
        end
        
                 -- Valid race numbers: 1-8, 10 and 11
         local validRaces = {1, 2, 3, 4, 5, 6, 7, 8, 10, 11}
         
         -- Valid class numbers: 1-9 and 11
         local validClasses = {1, 2, 3, 4, 5, 6, 7, 8, 9, 11}
         
         -- Race names for display
         local raceNames = {
             [1] = "Human",
             [2] = "Orc", 
             [3] = "Dwarf",
             [4] = "Night Elf",
             [5] = "Undead",
             [6] = "Tauren",
             [7] = "Gnome",
             [8] = "Troll",
             [10] = "Blood Elf",
             [11] = "Draenei"
         }
        
        -- Class names for display
        local classNames = {
            [1] = "Warrior",
            [2] = "Paladin",
            [3] = "Hunter",
            [4] = "Rogue",
            [5] = "Priest",
            [6] = "Death Knight",
            [7] = "Shaman",
            [8] = "Mage",
            [9] = "Warlock",
            [11] = "Druid"
        }
        
        local botsCreated = 0
        
        -- Create the specified number of bots
        for i = 1, numBots do
            -- Generate random race and class
            local randomRace = validRaces[math.random(1, #validRaces)]
            local randomClass = validClasses[math.random(1, #validClasses)]
            
            -- Create the bot using the .npcbot createnew command
            local botName = "testbot" .. i
            local commandString = string.format(".npcbot createnew %s %d %d 0 0 0 0 0 0", botName, randomRace, randomClass)
            
                         -- Execute the command
             player:SendBroadcastMessage(string.format("|c979ABDFFCreating bot %d: %s %s|r", i, raceNames[randomRace], classNames[randomClass]))
            
                         -- Execute the command using RunCommand
             player:RunCommand(commandString)
             botsCreated = botsCreated + 1
        end
        
                 -- Send completion message
         if botsCreated > 0 then
             player:SendBroadcastMessage(string.format("|c979ABDFFSuccessfully created %d random bots!|r", botsCreated))
         else
             player:SendBroadcastMessage("|c979ABDFFFailed to create any bots.|r")
         end
        
        return false -- Prevent the command from being processed further
    end
    
    return true -- Allow other commands to be processed
end

-- Register the command handler
RegisterPlayerEvent(42, OnCommand) -- PLAYER_EVENT_ON_COMMAND = 42

print("BotMaker: Script loaded successfully!")
print("Use .createbot <number> to create random bots") 