-- TODO: GRAB ALL APPEARENCE FROM EXTRA SQL INFO AND PUT INTO GOSSIP MENU
-- ONCE THEY CHANGE THEIR BOT, GRAB RACE AND GENDER, CHANGE GENDER IN APPEARENCE SQL AND RACE IN EXTRA SQL
-- MAKE APPEARENCE CHANGE IN THE APPEARENCE SQL



local function GetBotOwnerID(player)
    local target = player:GetSelection()
    local botid = target:GetEntry()
    local ownerid = CharDBQuery("SELECT owner FROM characters_npcbot WHERE entry = " .. botid)
    if ownerid then
        return ownerid:GetUInt32(0)
    end
    return ownerid
end

local function GetBotOwnerName(player)
    local ownerid = GetBotOwnerID(player)
    local ownername = CharDBQuery("SELECT name FROM characters WHERE guid = " .. ownerid)
    if ownername then
        return ownername:GetString(0)
    end
    return ownername
end

local function GetBotName(player)
    local target = player:GetSelection()
    local botid = target:GetEntry()
    local botname = WorldDBQuery("SELECT name FROM creature_template WHERE entry = " .. botid)
    if botname then
        return botname:GetString(0)
    end
    return botname
end

local function GetDisplayID(player)
    local target = player:GetSelection()
    local botid = target:GetEntry()
    local botdisplayid = WorldDBQuery("SELECT CreatureDisplayID FROM creature_template_model WHERE CreatureID = " .. botid)
    if botdisplayid then
        return botdisplayid:GetUInt32(0)
    end
    return botdisplayid
end

local function GetCDIModelID(player)
    local target = player:GetSelection()
    local botid = target:GetEntry()
    local displayID = GetDisplayID(player)
    local cdimodelid = WorldDBQuery("SELECT ModelID FROM creaturedisplayinfo WHERE ID = " .. displayID)
    if cdimodelid then
        return cdimodelid:GetUInt32(0)
    end
    return cdimodelid
end

local function GetCDIEDIID(player)
    local target = player:GetSelection()
    local botid = target:GetEntry()
    local displayID = GetDisplayID(player)
    local cdiediid = WorldDBQuery("SELECT ExtendedDisplayInfoID FROM creaturedisplayinfo WHERE ID = " .. displayID)
    if cdiediid then
        return cdiediid:GetUInt32(0)
    end
    return cdiediid
end

local function GetDisplayRaceID(player)
    local target = player:GetSelection()
    local botid = target:GetEntry()
    local cdiediid = GetCDIEDIID(player)
    local displayraceid = WorldDBQuery("SELECT DisplayRaceID FROM creaturedisplayinfoextra WHERE ID = " .. cdiediid)
    if displayraceid then
        return displayraceid:GetUInt32(0)
    end
    return displayraceid
end

local function GetDisplaySexID(player)
    local target = player:GetSelection()
    local botid = target:GetEntry()
    local cdiediid = GetCDIEDIID(player)
    local displaysexid = WorldDBQuery("SELECT DisplaySexID FROM creaturedisplayinfoextra WHERE ID = " .. cdiediid)
    if displaysexid then
        return displaysexid:GetUInt32(0)
    end
    return displaysexid
end

local function GetSkinID(player)
    local target = player:GetSelection()
    local botid = target:GetEntry()
    local cdiediid = GetCDIEDIID(player)
    local skinid = WorldDBQuery("SELECT SkinID FROM creaturedisplayinfoextra WHERE ID = " .. cdiediid)
    if skinid then
        return skinid:GetUInt32(0)
    end
    return skinid
end

local function GetFaceID(player)
    local target = player:GetSelection()
    local botid = target:GetEntry()
    local cdiediid = GetCDIEDIID(player)
    local faceid = WorldDBQuery("SELECT FaceID FROM creaturedisplayinfoextra WHERE ID = " .. cdiediid)
    if faceid then
        return faceid:GetUInt32(0)
    end
    return faceid
end

local function GetHairStyleID(player)
    local target = player:GetSelection()
    local botid = target:GetEntry()
    local cdiediid = GetCDIEDIID(player)
    local hairstyleid = WorldDBQuery("SELECT HairStyleID FROM creaturedisplayinfoextra WHERE ID = " .. cdiediid)
    if hairstyleid then
        return hairstyleid:GetUInt32(0)
    end
    return hairstyleid
end

local function GetHairColorID(player)
    local target = player:GetSelection()
    local botid = target:GetEntry()
    local cdiediid = GetCDIEDIID(player)
    local haircolorid = WorldDBQuery("SELECT HairColorID FROM creaturedisplayinfoextra WHERE ID = " .. cdiediid)
    if haircolorid then
        return haircolorid:GetUInt32(0)
    end
    return haircolorid
end

local function GetFacialHairID(player)
    local target = player:GetSelection()
    local botid = target:GetEntry()
    local cdiediid = GetCDIEDIID(player)
    local facialhairid = WorldDBQuery("SELECT FacialHairID FROM creaturedisplayinfoextra WHERE ID = " .. cdiediid)
    if facialhairid then
        return facialhairid:GetUInt32(0)
    end
    return facialhairid
end

local function SetRaceNpcBotExtra(entry, race)
    local resultID = WorldDBExecute("UPDATE creature_template_npcbot_extras SET race = " .. race .. " WHERE entry = " .. entry)
end

local function SetCreatureDisplayID(entry, displayid)
    local resultID = WorldDBExecute("UPDATE creature_template_model SET CreatureDisplayID = " .. displayid .. " WHERE CreatureID = " .. entry)
end

local function SetBotAppearence(entry, gender, skin, face, hair, haircolor, features)
    local resultID = WorldDBExecute("UPDATE creature_template_npcbot_appearance SET gender = " .. gender .. ", skin = " .. skin .. ", face = " .. face .. ", hair = " .. hair .. ", haircolor = " .. haircolor .. ", features = " .. features .. " WHERE entry = " .. entry)
end

local function OnCommand(event, player, command)
    local target = player:GetSelection()

    local args = {}
    for word in string.gmatch(command, "%S+") do
        table.insert(args, word)
    end

    if args[1] == "botc" then

        if target == nil then
            player:SendBroadcastMessage("|c979ABDFFSelect an NPCBot before using the command.|r")
            return false
        end

        local botid = target:GetEntry()

        local ownerid = GetBotOwnerID(player)

        if ownerid == nil then
            player:SendBroadcastMessage("|c979ABDFFThis NPCBot does not have an owner or is not an NPCBot.|r")
            return false
        end

        if #args < 8 then
            player:SendBroadcastMessage("|c979ABDFFWhen using this commmand, you have to input all 7 arguments otherwise the command will not work.|r")
            player:SendBroadcastMessage("|c979ABDFFWhen the command applies changes to your bot, they will not show until the server is restarted.|r")
            player:SendBroadcastMessage("|c979ABDFFUsage: .botc (race) (gender) (skin) (face) (hairstyle) (haircolor) (features)|r")
            player:SendBroadcastMessage("|c979ABDFFAcceptable ranges:|r")
            player:SendBroadcastMessage("|c979ABDFFHuman(1) Male(0): skin 0-9 face 0-11 hairstyle 0-16 haircolor 0-9 features 0-8|r")
            player:SendBroadcastMessage("|c979ABDFFHuman(1) Female(1): skin 0-9 face 0-14 hairstyle 0-23 haircolor 0-9 features 0-6|r")
            player:SendBroadcastMessage("|c979ABDFFDwarf(3) Male(0): skin 0-8 face 0-9 hairstyle 0-15 haircolor 0-9 features 0-10|r")
            player:SendBroadcastMessage("|c979ABDFFDwarf(3) Female(1): skin 0-8 face 0-9 hairstyle 0-18 haircolor 0-9 features 0-5|r")
            player:SendBroadcastMessage("|c979ABDFFNight Elf(4) Male(0): skin 0-8 face 0-8 hairstyle 0-11 haircolor 0-7 features 0-5|r")
            player:SendBroadcastMessage("|c979ABDFFNight Elf(4) Female(1): skin 0-8 face 0-8 hairstyle 0-11 haircolor 0-7 features 0-9|r")
            player:SendBroadcastMessage("|c979ABDFFGnome(7) Male(0): skin 0-4 face 0-6 hairstyle 0-11 haircolor 0-8 features 0-7|r")
            player:SendBroadcastMessage("|c979ABDFFGnome(7) Female(1): skin 0-4 face 0-6 hairstyle 0-11 haircolor 0-8 features 0-6|r")
            player:SendBroadcastMessage("|c979ABDFFDraenei(11) Male(0): skin 0-13 face 0-9 hairstyle 0-13 haircolor 0-6 features 0-7|r")
            player:SendBroadcastMessage("|c979ABDFFDraenei(11) Female(1): skin 0-13 face 0-9 hairstyle 0-15 haircolor 0-6 features 0-6|r")
            player:SendBroadcastMessage("|c979ABDFFOrc(2) Male(0): skin 0-8 face 0-8 hairstyle 0-11 haircolor 0-7 features 0-10|r")
            player:SendBroadcastMessage("|c979ABDFFOrc(2) Female(1): skin 0-8 face 0-8 hairstyle 0-12 haircolor 0-7 features 0-6|r")
            player:SendBroadcastMessage("|c979ABDFFUndead(5) Male(0): skin 0-5 face 0-9 hairstyle 0-14 haircolor 0-9 features 0-16|r")
            player:SendBroadcastMessage("|c979ABDFFUndead(5) Female(1): skin 0-5 face 0-9 hairstyle 0-14 haircolor 0-9 features 0-7|r")
            player:SendBroadcastMessage("|c979ABDFFTauren(6) Male(0): skin 0-18 face 0-4 hairstyle 0-12 haircolor 0-2 features 0-6|r")
            player:SendBroadcastMessage("|c979ABDFFTauren(6) Female(1): skin 0-10 face 0-3 hairstyle 0-11 haircolor 0-2 features 0-4|r")
            player:SendBroadcastMessage("|c979ABDFFTroll(8) Male(0): skin 0-5 face 0-4 hairstyle 0-9 haircolor 0-9 features 0-10|r")
            player:SendBroadcastMessage("|c979ABDFFTroll(8) Female(1): skin 0-5 face 0-5 hairstyle 0-9 haircolor 0-9 features 0-5|r")
            player:SendBroadcastMessage("|c979ABDFFBlood elf(10) Male(0): skin 0-9 face 0-9 hairstyle 0-15 haircolor 0-9 features 0-9|r")
            player:SendBroadcastMessage("|c979ABDFFBlood elf(10) Female(1): skin 0-9 face 0-9 hairstyle 0-18 haircolor 0-9 features 0-10|r")
            return false
        end

        local arg1 = args[2]
        local arg2 = args[3]
        local arg3 = args[4]
        local arg4 = args[5]
        local arg5 = args[6]
        local arg6 = args[7]
        local arg7 = args[8]

        local racearg = arg1
        local genderarg = arg2
        racearg = tonumber(racearg)
        genderarg = tonumber(genderarg)
        local dridtext
        local newmodelid

        if racearg == 1 then
            dridtext = "(Human)"
        elseif racearg == 2 then
            dridtext = "(Orc)"
        elseif racearg == 3 then
            dridtext = "(Dwarf)"
        elseif racearg == 4 then
            dridtext = "(Night elf)"
        elseif racearg == 5 then
            dridtext = "(Undead)"
        elseif racearg == 6 then
            dridtext = "(Tauren)"
        elseif racearg == 7 then
            dridtext = "(Gnome)"
        elseif racearg == 8 then
            dridtext = "(Troll)"
        elseif racearg == 10 then
            dridtext = "(Blood Elf)"
        elseif racearg == 11 then
            dridtext = "(Draenei)"
        end

        if racearg == 1 and genderarg == 0 then
            newmodelid = 1290
        elseif racearg == 1 and genderarg == 1 then
            newmodelid = 1296
        elseif racearg == 2 and genderarg == 0 then
            newmodelid = 1326
        elseif racearg == 2 and genderarg == 1 then
            newmodelid = 1868
        elseif racearg == 3 and genderarg == 0 then
            newmodelid = 1354
        elseif racearg == 3 and genderarg == 1 then
            newmodelid = 1407
        elseif racearg == 4 and genderarg == 0 then
            newmodelid = 1704
        elseif racearg == 4 and genderarg == 1 then
            newmodelid = 1682
        elseif racearg == 5 and genderarg == 0 then
            newmodelid = 1562
        elseif racearg == 5 and genderarg == 1 then
            newmodelid = 1593
        elseif racearg == 6 and genderarg == 0 then
            newmodelid = 2087
        elseif racearg == 6 and genderarg == 1 then
            newmodelid = 2112
        elseif racearg == 7 and genderarg == 0 then
            newmodelid = 4287
        elseif racearg == 7 and genderarg == 1 then
            newmodelid = 5378
        elseif racearg == 8 and genderarg == 0 then
            newmodelid = 4047
        elseif racearg == 8 and genderarg == 1 then 
            newmodelid = 4231
        elseif racearg == 10 and genderarg == 0 then
            newmodelid = 16700
        elseif racearg == 10 and genderarg == 1 then
            newmodelid = 15518
        elseif racearg == 11 and genderarg == 0 then
            newmodelid = 16589
        elseif racearg == 11 and genderarg == 1 then
            newmodelid = 16202
        end

        player:SendBroadcastMessage("|c979ABDFFArguments received: |r")
        player:SendBroadcastMessage("|c979ABDFFRace: |r" .. arg1 .. " " ..dridtext .. " |c979ABDFFGender: |r" .. arg2 .. " |c979ABDFFSkin: |r" .. arg3 .. " |c979ABDFFFace: |r" .. arg4 .. " |c979ABDFFHairStyle: |r" .. arg5 .. " |c979ABDFFHairColor: |r" .. arg6 .. " |c979ABDFFFeatures: |r" .. arg7)
        SetRaceNpcBotExtra(botid, racearg)
        player:SendBroadcastMessage("(creature_template_npcbot_extras) |c979ABDFFSetting race: |r" .. racearg .. " " .. dridtext)
        SetCreatureDisplayID(botid, newmodelid)
        player:SendBroadcastMessage("(creature_template_model) |c979ABDFFSetting ModelID for race/gender: |r" .. newmodelid)
        SetBotAppearence(botid, genderarg, arg3, arg4, arg5, arg6, arg7)
        player:SendBroadcastMessage("(creature_template_npcbot_appearence) |c979ABDFFSetting appearence for gender: |r" .. genderarg .. " |c979ABDFFskin: |r" .. arg3 .. " |c979ABDFFface: |r" .. arg4 .. " |c979ABDFFhairstyle: |r" .. arg5 .. " |c979ABDFFhaircolor: |r" .. arg6 .. " |c979ABDFFfeatures: |r" .. arg7)

        return false
    end

    if command == "botdebug" then
        player:GossipClearMenu()

        if target == nil then
            player:SendBroadcastMessage("|c979ABDFFSelect an NPCBot before using the command.|r")
            return false
        end

        local botid = target:GetEntry()

        local ownerid = GetBotOwnerID(player)

        if ownerid == nil then
            player:SendBroadcastMessage("|c979ABDFFThis NPCBot does not have an owner or is not an NPCBot.|r")
            return false
        end

        local ownername = GetBotOwnerName(player)
        local botname = GetBotName(player)
        local botdisplayid = GetDisplayID(player)
        local cdimodelid = GetCDIModelID(player)
        local cdiediid = GetCDIEDIID(player)
        local displayraceid = GetDisplayRaceID(player)
        local dridtext

        if displayraceid == 1 then
            dridtext = "(Human)"
        elseif displayraceid == 2 then
            dridtext = "(Orc)"
        elseif displayraceid == 3 then
            dridtext = "(Dwarf)"
        elseif displayraceid == 4 then
            dridtext = "(Night elf)"
        elseif displayraceid == 5 then
            dridtext = "(Undead)"
        elseif displayraceid == 6 then
            dridtext = "(Tauren)"
        elseif displayraceid == 7 then
            dridtext = "(Gnome)"
        elseif displayraceid == 8 then
            dridtext = "(Troll)"
        elseif displayraceid == 10 then
            dridtext = "(Blood Elf)"
        elseif displayraceid == 11 then
            dridtext = "(Draenei)"
        end

        local displaysexid = GetDisplaySexID(player)
        local dsitext

        if displaysexid == 0 then
            dsitext = "(Male)"
        elseif displaysexid == 1 then
            dsitext = "(Female)"
        end

        local skinid = GetSkinID(player)
        local faceid = GetFaceID(player)
        local hairstyleid = GetHairStyleID(player)
        local haircolorid = GetHairColorID(player)
        local facialhairid = GetFacialHairID(player)

        if target then
            player:GossipMenuAddItem(4, "Bot Entry ID: " .. botid, 1, 10)
            player:GossipMenuAddItem(4, "Bot Name: " .. botname, 1, 10)
            player:GossipMenuAddItem(4, "Owner ID: " .. ownerid, 1, 10)
            player:GossipMenuAddItem(4, "Owner Name: " .. ownername, 1, 10)
            player:GossipMenuAddItem(4, "Display ID: " .. botdisplayid, 1, 10)
            player:GossipMenuAddItem(4, "ModelID: " .. cdimodelid .. " (CDI)", 1, 10)
            player:GossipMenuAddItem(4, "ExtendedDisplayInfoID: " .. cdiediid, 1, 10)
            player:GossipMenuAddItem(4, "DisplayRaceID: " .. displayraceid .. " " .. dridtext .. " (CDIE)", 1, 10)
            player:GossipMenuAddItem(4, "DisplaySexID: " .. displaysexid .. " " .. dsitext, 1, 10)
            player:GossipMenuAddItem(4, "SkinID: " .. skinid, 1, 10)
            player:GossipMenuAddItem(4, "FaceID: " .. faceid, 1, 10)
            player:GossipMenuAddItem(4, "HairStyleID: " .. hairstyleid, 1, 10)
            player:GossipMenuAddItem(4, "HairColorID: " .. haircolorid, 1, 10)
            player:GossipMenuAddItem(4, "FacialHairID: " .. facialhairid, 1, 10)
            player:GossipSendMenu(1, player, 1)
        end

        return false
    end

    
end

local function OnSelect(event, player, object, sender, intid, code, menu_id)
    player:GossipClearMenu()
    if intid == 10 then
        player:SendBroadcastMessage("|c979ABDFFPoof.|r")
        player:GossipComplete()
    end
    return false
end

RegisterPlayerEvent(42, OnCommand)
RegisterPlayerGossipEvent(1, 2, OnSelect)