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

local function has(item, amount)
    local count = Tracker:ProviderCountForCode(item)
    amount = tonumber(amount)
    if not amount then
        return count > 0
    else
        return count >= amount
    end
end

-- Move Macros
-- These cubes can be started with via yaml settings TODO maybe just give the player the item in slot_data
function doubleup()
    return has("doubleup") or false -- settings
end
function tag()
    return has("tag") or false -- settings
end
-- Moves that involve your partner need to do be able to summon them in the first place
function mario()
    return has("mario") and doubleup()
end
function stay()
    return has("stay") and doubleup()
end
function strongies()
    if has("titansmitt") then
        return (has("powerglove") and doubleup()) or false -- settings
    end
end

-- Every spell needs access to Charlotte to use
function comcast()
    return has("dlink") or tag()
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
    return froggy() or birdie() -- We don't put Puppet Master here since holes in Portrait are typically tinier than Dawn's
end
function smol()
    return has("slide") or holes()
end

-- Checks for portrait configuration and links the given portrait accordingly
function ConnectPortrait(area)
    local ports = {
        {code = "hubport", region = "@Entrance Regions/Hub Painting Room"},
        {code = "undergroundport", region = "@Great Stairway Regions/Underground Painting"},
        {code = "stairsport", region = "@Great Stairway Regions/Central Painting Area"},
        {code = "towerport", region = "@Tower of Death Regions/Painting Room"},
        {code = "brauner1port", region = "@Master's Keep Regions/Portrait Room"},
        {code = "brauner2port", region = "@Master's Keep Regions/Portrait Room"},
        {code = "brauner3port", region = "@Master's Keep Regions/Portrait Room"},
        {code = "brauner4port", region = "@Master's Keep Regions/Portrait Room"},
        {code = "passageport", region = "@Entrance Regions/Underground Passage"},
    }
    local area_idx = {
        {code = "coh", idx = 0},
        {code = "13s", idx = 1},
        {code = "sg", idx = 2},
        {code = "fc", idx = 3},
        {code = "nof", idx = 4},
        {code = "bp", idx = 5},
        {code = "fod", idx = 6},
        {code = "da", idx = 7},
        {code = "noe", idx = 8},
    }
    -- Turn the provided code into a number
    for _, idx in ipairs(area_idx) do
        if idx.code == area then
            index_to_use = idx.idx
        end
    end
    -- Find which portrait has the index and return the correlating region
    for _, port in ipairs(ports) do
        stage = Tracker:FindObjectForCode(port.code).CurrentStage
        if stage == index_to_use then
            return Tracker:FindObjectForCode(port.region).AccessibilityLevel
        end
    end
    -- If it hasn't returned yet, there's a duplicate portrait in the config
    return false
end

-- Returns the location of the given boss for quest logic
function QuestRequirement(boss)

end