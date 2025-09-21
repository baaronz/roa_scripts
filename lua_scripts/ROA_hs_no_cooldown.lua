local hearthstone_spell_id = 8690
local reset_delay = 50

function OnHearthstoneCast(event, player, spell, cast)
    local spell_id = spell:GetEntry()
    
    if spell_id == hearthstone_spell_id then
        player:RegisterEvent(OnHearthstoneResetDelay, reset_delay, 0, player)
    end
end

function OnHearthstoneResetDelay(event_id, delay, repeats, player)
    player:ResetSpellCooldown(hearthstone_spell_id)
    player:RemoveEventById(event_id)
end

RegisterPlayerEvent(5, OnHearthstoneCast)