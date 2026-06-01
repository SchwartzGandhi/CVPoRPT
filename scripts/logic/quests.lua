-- Quests are locked by bosses, return true if the given boss is in logic
function QuestBossLocation(x)
    if has("allquests") then
        return true
    end
    local bossregions = {
        ["Keremet"] = "Great Stairway",
        ["Stella"] = "Tower of Death",
        ["Death"] = "Tower of Death",
        ["Stella & Loretta"] = "Master's Keep",
        ["Dullahan"] = "City of Haze",
        ["Werewolf"] = "13th Street",
        ["Astarte"] = "Sandy Grave",
        ["Mummy Man"] = "Forgotten City",
        ["Legion"] = "Nation of Fools",
        ["Medusa"] = "Burnt Paradise",
        ["Dagon"] = "Forest of Doom",
        ["The Creature"] = "Dark Academy",
    }
    if x == "Stella" then
        return Tracker:FindObjectForCode("@Tower of Death/Stella Item/").AccessibilityLevel
    end
    if x == "Stella & Loretta" then
        return Tracker:FindObjectForCode("@Master's Keep/Banquet Room/Stella & Loretta").AccessibilityLevel
    end
    for boss, region in pairs(bossregions) do
        if boss == x then
            return Tracker:FindObjectForCode(string.format("@%s/%s/", region, boss)).AccessibilityLevel
        end
    end
end

-- Some quests depend on other quests being completed, match the given code with its predecessor
function PrevQuest(code)
    if has("allquests") then
        return true
    end
    local quest
    if code == "zephyr" then
        quest = "The Spinning Art"
    elseif code == "m2" then
        quest = "Mental Training 1"
    elseif code == "m3" then
        quest = "Mental Training 2"
    elseif code == "m4" then
        quest = "Mental Training 3"
    elseif code == "s2" then
        quest = "Build Your Strength 1"
    elseif code == "s3" then
        quest = "Build Your Strength 2"
    elseif code == "s4" then
        quest = "Build Your Strength 3"
    elseif code == "s" then
        quest = "A Rank Hunter"
    end
    return Tracker:FindObjectForCode(string.format("@Wind's Quests/%s", quest)).AccessibilityLevel
end

function Cakes(mode)
    local cakes = {
        "akechi", "wheat", "vienna", "cheese",
        "french", "tart", "gasteau", "german",
        "kaafii", "gasteau2", "cat", "money", "hooray"
    }
    local notforsale = {
        "akechi", "tart", "gasteau", "german",
        "kaafii", "gasteau2", "cat", "money", "hooray"
    }
    if mode == "a" then
        local cakecount = 0
        for _, cake in ipairs(cakes) do
            if has(cake) then
                cakecount = cakecount + 1
            end
            if cakecount >= 5 then
                return true
            end
        end
    elseif mode == "n" then
        for _, cake in ipairs(notforsale) do
            if has(cake) then
                return true
            end
        end
    end
end

-- Search for if the quest is included or excluded
function ShowQuest(quest)
    for _, inc in ipairs(INCLUDED_QUESTS) do
        if inc == quest then
            return true
        end
    end
    for _, exc in ipairs(EXCLUDED_QUESTS) do
        if exc == quest then
            return false
        end
    end
    -- Should unrelated quests be shown? TODO make this a meta option
end