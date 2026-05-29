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
-- Moves that involve your partner need to do be able to summon them in the first place
function mario()
    return has("mario") and has("doubleup")
end
function stay()
    return has("stay") and has("doubleup")
end
function strongies()
    if has("titansmitt") then
        return has("powerglove") and has("doubleup")
    end
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
    return froggy() or birdie() -- We don't put Puppet Master here since holes in Portrait are typically tinier than Dawn's
end
function smol()
    return has("slide") or holes()
end

-- Checks for portrait configuration and links the given portrait accordingly
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
    local area_idx = {
        "coh", "13s",
        "sg", "fc",
        "nof", "bp",
        "fod", "da",
        "noe",
    }
    -- Turn the provided code into a number
    for i, code in ipairs(area_idx) do
        if code == area then
            idx = i - 1
        end
    end
    -- Find which portrait has the index and return the correlating region
    for code, region in pairs(ports) do
        stage = Tracker:FindObjectForCode(code).CurrentStage
        if stage == idx then
            return Tracker:FindObjectForCode(region).AccessibilityLevel
        end
    end
    -- If it hasn't returned yet, there's a duplicate portrait in the config
    return false
end

-- Checks if the given portrait requirement is met based on settings
function GetPortraitAmount(code)
    local obj = Tracker:FindObjectForCode(code)
    -- TODO make boss locations
end

-- Returns the location of the given boss for quest logic
function QuestRequirement(boss)

end