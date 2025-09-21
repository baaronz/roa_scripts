local QUEST_ID = {64070, 64071, 64072, 64073, 64074, 64075, 64076, 64077, 64078, 64079, 64080, 64081, 64082, 64083, 64084, 64085, 64086, 64087, 64088, 64089, 64090, 64091, 64092, 64093, 64094, 64095, 64096, 64097, 64098}

local function KilledByCreature(event, killer, killed)
    for _, questId in ipairs(QUEST_ID) do
        if killed:HasQuest(questId) then
            killed:FailQuest(questId)
            killed:SendBroadcastMessage("|c979ABDFFYou have died and failed the quest |r")
        end
    end
end

RegisterPlayerEvent(8, KilledByCreature)