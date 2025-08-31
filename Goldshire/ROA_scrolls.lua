local spell

local function onscrolluse(event, player, item, target)
    local players = GetPlayersInWorld()

    if item:GetEntry() == 91019 then
        spell = 98044
    elseif item:GetEntry() == 91020 then
        spell = 98045
    elseif item:GetEntry() == 91021 then
        spell = 98046
    elseif item:GetEntry() == 91022 then
        spell = 98047
    elseif item:GetEntry() == 91023 then
        spell = 98048
    elseif item:GetEntry() == 91024 then
        spell = 98049
    elseif item:GetEntry() == 91025 then
        spell = 98050
    elseif item:GetEntry() == 91026 then
        spell = 98051
    elseif item:GetEntry() == 91027 then
        spell = 98052
    elseif item:GetEntry() == 91028 then
        spell = 98053
    elseif item:GetEntry() == 91029 then
        spell = 98054
    elseif item:GetEntry() == 91030 then
        spell = 98055
    elseif item:GetEntry() == 91031 then
        spell = 98056
    elseif item:GetEntry() == 91032 then
        spell = 98057
    elseif item:GetEntry() == 91033 then
        spell = 98058
    elseif item:GetEntry() == 91034 then
        spell = 59843
    elseif item:GetEntry() == 91035 then
        spell = 27571
    elseif item:GetEntry() == 91036 then
        spell = 26272
    elseif item:GetEntry() == 91037 then
        spell = 75531
    elseif item:GetEntry() == 91038 then
        spell = 37809
    elseif item:GetEntry() == 91039 then
        spell = 24710
    elseif item:GetEntry() == 91040 then
        spell = 24710
    elseif item:GetEntry() == 91041 then
        spell = 42365
    elseif item:GetEntry() == 91042 then
        spell = 51926
    end

    for _, plr in pairs(players) do
        plr:CastSpell(plr, spell, true)
    end

end

RegisterItemEvent(91019, 2, onscrolluse)
RegisterItemEvent(91020, 2, onscrolluse)
RegisterItemEvent(91021, 2, onscrolluse)
RegisterItemEvent(91022, 2, onscrolluse)
RegisterItemEvent(91023, 2, onscrolluse)
RegisterItemEvent(91024, 2, onscrolluse)
RegisterItemEvent(91025, 2, onscrolluse)
RegisterItemEvent(91026, 2, onscrolluse)
RegisterItemEvent(91027, 2, onscrolluse)
RegisterItemEvent(91028, 2, onscrolluse)
RegisterItemEvent(91029, 2, onscrolluse)
RegisterItemEvent(91030, 2, onscrolluse)
RegisterItemEvent(91031, 2, onscrolluse)
RegisterItemEvent(91032, 2, onscrolluse)
RegisterItemEvent(91033, 2, onscrolluse)
RegisterItemEvent(91034, 2, onscrolluse)
RegisterItemEvent(91035, 2, onscrolluse)
RegisterItemEvent(91036, 2, onscrolluse)
RegisterItemEvent(91037, 2, onscrolluse)
RegisterItemEvent(91038, 2, onscrolluse)
RegisterItemEvent(91039, 2, onscrolluse)
RegisterItemEvent(91040, 2, onscrolluse)
RegisterItemEvent(91041, 2, onscrolluse)
RegisterItemEvent(91042, 2, onscrolluse)