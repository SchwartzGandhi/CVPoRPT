-- put logic functions here using the Lua API: https://github.com/black-sliver/PopTracker/blob/master/doc/PACKS.md#lua-interface
-- don't be afraid to use custom logic functions. it will make many things a lot easier to maintain, for example by adding logging.
-- to see how this function gets called, check: locations/locations.json
-- example:
function has_more_then_n_consumable(n)
    local count = Tracker:ProviderCountForCode('consumable')
    local val = (count > tonumber(n))
    if ENABLE_DEBUG_LOG then
        print(string.format("called has_more_then_n_consumable: count: %s, n: %s, val: %s", count, n, val))
    end
    if val then
        return 1 -- 1 => access is in logic
    end
    return 0 -- 0 => no access
end

function has(item, amount)
    local count = Tracker:ProviderCountForCode(item)
    amount = tonumber(amount)
    if not amount then
        return count > 0
    else
        return count >= amount
    end
end

-- Move Macros
-- Moves that involve your partner need to do be able to summon them in the first place
function mario()
    return has("mario") and has("doubleup")
end
function stay()
    return has("stay") and has("doubleup")
end
function powerglove()
    return has("powerglove") and has("doubleup")
end
function strongies()
    return has("titansmitt") and (powerglove() or has("solomitt"))
end

-- Every spell needs access to Charlotte to use
function comcast()
    return has("dlink") or has("tag")
end
function birdie()
    return comcast() and has("birdie")
end
function froggy()
    return comcast() and has("froggy")
end
function fortress()
    return comcast() and has("fortress")
end
function fast()
    return comcast() and has("fast")
end

-- Misc traversal
function biguppies()
    return has("zip") or (comcast() and has("birdie"))
end
function mediumuppies()
    return biguppies() or has("djump")
end
function smalluppies()
    return mediumuppies() or (has("doubleup") and has("mario"))
end
function tinyuppies()
    return smalluppies() or has("puppet")
end

function holes()
    if has("doool") and has("puppet") then
        return AccessibilityLevel.SequenceBreak
    end
    return froggy() or birdie() -- We don't put Puppet Master here since holes in Portrait are typically tinier than Dawn's
end
function smol()
    return has("slide") or holes()
end

-- Checks portrait configuration and links the given portrait accordingly
function ConnectPortrait(area)
    local ports = {
        ["hubport"] = "@Entrance Regions/Hub Painting Room",
        ["undergroundport"] = "@Great Stairway Regions/Underground Painting",
        ["stairsport"] = "@Great Stairway Regions/Central Painting Area",
        ["towerport"] = "@Tower of Death Regions/Painting Room",
        ["brauner1port"] = "@Master's Keep Regions/Portrait Room",
        ["brauner2port"] = "@Master's Keep Regions/Portrait Room",
        ["brauner3port"] = "@Master's Keep Regions/Portrait Room",
        ["brauner4port"] = "@Master's Keep Regions/Portrait Room",
        ["passageport"] = "@Entrance Regions/Underground Passage",
    }
    local area_codes = {
        "coh", "13s",
        "sg", "fc",
        "nof", "bp",
        "fod", "da",
        "noe",
    }
    -- Turn the provided code into the index of the portrait stage it represents
    for i, code in ipairs(area_codes) do
        if code == area then
            idx = i - 1
        end
    end
    -- Find which portraits have the index
    local connected_regions = {}
    for code, _ in pairs(ports) do
        stage = Tracker:FindObjectForCode(code).CurrentStage
        -- print(string.format("Testing if portrait \"%s\" has index %s", code, idx))
        if stage == idx then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                print(string.format("Portrait \"%s\" connects to \"%s\"", code, area_codes[idx+1]))
            end
            table.insert(connected_regions, code)
        end
    end
    -- If there were no matches, there's a duplicate portrait in the config and this area isn't listed
    if not next(connected_regions) and AUTOTRACKER_ENABLE_DEBUG_LOGGING then
        print(string.format("Could not find a portrait that connects to \"%s\"", area))
    end

    -- Cycle through all of the results and find if one is in logic
    for _, code in ipairs(connected_regions) do
        local region = ports[code]
        local access = Tracker:FindObjectForCode(region).AccessibilityLevel
        -- print(string.format("Checking if \"%s\" is in logic for portrait \"%s\"", region, code))
        if access >= AccessibilityLevel.SequenceBreak then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING then
                print(string.format("\"%s\" tis indeed in logic for portrait \"%s\"", region, code))
            end
            -- The Portrait in Tower of Death specifically also needs Stella's Locket
            if code == "towerport" then
                return access and has("locket")
            end
            return access
        end
    end
end

function BraunerRequired()
    if Tracker:FindObjectForCode("brauner").Active then
        return Tracker:FindObjectForCode("@Master's Keep/Defeat Brauner/").AccessibilityLevel
    end
end

function NestRequired()
    local stage = Tracker:FindObjectForCode("neststate").CurrentStage
    if stage == 2 then
        return Tracker:FindObjectForCode("@Nest of Evil/Doppelganger Reward/").AccessibilityLevel
    end
    return true
end

function PortraitClear(n)
    local clear_reach = {
        "@City of Haze/Dullahan/",
        "@13th Street/Werewolf/",
        "@Sandy Grave/Astarte/",
        "@Forgotten City/Mummy Man/",
        "@Nation of Fools/Legion/",
        "@Burnt Paradise/Medusa/",
        "@Forest of Doom/Dagon/",
        "@Dark Academy/The Creature/",
        "@Nest of Evil/Doppelganger/",
    }

    local clearcount = 0
    for _, boss in ipairs(clear_reach) do
        if (has("collect") and Tracker:FindObjectForCode(boss).AvailableChestCount == 0) or (
        has("access") and Tracker:FindObjectForCode(boss).AccessibilityLevel >= AccessibilityLevel.Normal) then
            clearcount = clearcount + 1
        end
    end

    local checkcount
    if n == "brauner" then
        checkcount = Tracker:FindObjectForCode("braunercount").AcquiredCount
    elseif n == "dracula" then
        checkcount = Tracker:FindObjectForCode("countdracula").AcquiredCount
    elseif n == "nest" then
        checkcount = Tracker:FindObjectForCode("nestcount").AcquiredCount
    else
        checkcount = tonumber(n)
    end

    if clearcount >= checkcount then
        return true
    end
end

function Elevator()
    local elevator = Tracker:FindObjectForCode("@Tower of Death/Elevator Switch/")
    if elevator then
        if has("access") then
            return elevator.AccessibilityLevel
        elseif has("collect") then
            if elevator.AvailableChestCount == 0 then
                return true
            end
        end
    end
end

function BossKey(code)
    if has("bosskeys") then
        local code_keys = {
            ["ekey"] = "Colosseum Key",
            ["gskey"] = "Cavern Key",
            ["basekey"] = "Tower Base Key",
            ["todkey"] = "Clock Key",
            ["mkey"] = "Gallery Key",
            ["ttrkey"] = "Throne Key",
            ["cohkey"] = "City Key",
            ["13skey"] = "Street Key",
            ["sgkey"] = "Sandy Key",
            ["fckey"] = "Forgotten Key",
            ["nofkey"] = "Circus Arena Key",
            ["bpkey"] = "Burnt Key",
            ["fodkey"] = "Forest Key",
            ["dakey"] = "Adacemy Key",
            ["noekey"] = "Nest Key",
        }
        for _, key in ipairs(EXCLUDED_KEYS) do
            if key == code_keys[code] then
                return true
            end
        end
        return has(code)
    end
    return true
end

-- Settings Macros
function nestaccess()
    return not has("nonest")
end

function showportlocs()
    return has("limport") or has("showport")
end