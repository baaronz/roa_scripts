local function OnQuestReward1(event, player, creature, quest, opt) --merchants guild
    if quest:GetId() == 64112 then
        player:SetReputation(93, 0)
    end
end

local function OnQuestReward2(event, player, creature, quest, opt) -- adventurers guild
    if quest:GetId() == 64111 then
        player:SetReputation(92, 0)
    end
end

RegisterCreatureEvent(60603, 34, OnQuestReward1)
RegisterCreatureEvent(60601, 34, OnQuestReward2)
RegisterCreatureEvent(60703, 34, OnQuestReward1)
RegisterCreatureEvent(60701, 34, OnQuestReward2)