-- entry point for all lua code of the pack
-- more info on the lua API: https://github.com/black-sliver/PopTracker/blob/master/doc/PACKS.md#lua-interface
ENABLE_DEBUG_LOG = true
local variant = Tracker.ActiveVariantUID
IS_ITEMS_ONLY = variant:find("itemsonly")
IS_HORIZONTAL = variant:find("horizontal")

print("-- Example Tracker --")
print("Loaded variant: ", variant)
if ENABLE_DEBUG_LOG then
    print("Debug logging is enabled!")
end

ScriptHost:LoadScript("scripts/utils.lua")

-- Logic
ScriptHost:LoadScript("scripts/logic/logic.lua")

-- Custom Items
ScriptHost:LoadScript("scripts/custom_items/class.lua")
ScriptHost:LoadScript("scripts/custom_items/progressiveTogglePlus.lua")
ScriptHost:LoadScript("scripts/custom_items/progressiveTogglePlusWrapper.lua")

-- Items
Tracker:AddItems("items/relics.jsonc")
Tracker:AddItems("items/items.jsonc")
Tracker:AddItems("items/spells.jsonc")
Tracker:AddItems("items/subweapons.jsonc")

if not IS_ITEMS_ONLY then
    -- Maps
    Tracker:AddMaps("maps/maps.jsonc")
    -- Locations
    Tracker:AddLocations("locations/regions.jsonc")
    Tracker:AddLocations("locations/locations.jsonc")
end

-- Layout
if IS_HORIZONTAL then
    Tracker:AddLayouts("var_horizontal/layouts/items.jsonc")
    Tracker:AddLayouts("var_horizontal/layouts/tracker.jsonc")
    Tracker:AddLayouts("var_horizontal/layouts/broadcast.jsonc")
else
    Tracker:AddLayouts("layouts/items.jsonc")
    Tracker:AddLayouts("layouts/tracker.jsonc")
    Tracker:AddLayouts("layouts/broadcast.jsonc")
end

-- AutoTracking for Poptracker
if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end
