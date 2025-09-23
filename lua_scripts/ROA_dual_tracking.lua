local function onlogin(event, player)
    if player:HasSpell(91000) == false then
        player:LearnSpell(91000)
    end
end

RegisterPlayerEvent(3, onlogin)