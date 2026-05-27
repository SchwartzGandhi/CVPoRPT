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
function frog()
    return comcast() and has("frog")
end
function longspell()
    return comcast() and has("longspell")
end
function fast()
    return comcast() and has("fast")
end

-- Misc traversal
function biguppies()
    return has("zip") or (comcast() and has("birdie"))
end
function mediumuppies()
    return biguppies or has("djump")
end
function smalluppies()
    return mediumuppies() or (has("doubleup") and has("mario"))
end
function tinyuppies()
    return smalluppies or has("puppet")
end

function holes()
    return frog() or birdie() -- We don't put Puppet Master here since holes in Portrait are typically tinier than Dawn's
end
function smol()
    return has("slide") or holes()
end