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
ScriptHost:LoadScript("scripts/logic/quests.lua")

-- Custom Items
ScriptHost:LoadScript("scripts/custom_items/class.lua")
ScriptHost:LoadScript("scripts/custom_items/progressiveTogglePlus.lua")
ScriptHost:LoadScript("scripts/custom_items/progressiveTogglePlusWrapper.lua")

-- Items
Tracker:AddItems("items/relics.jsonc")
Tracker:AddItems("items/items.jsonc")
Tracker:AddItems("items/quests.jsonc")
Tracker:AddItems("items/spells.jsonc")
Tracker:AddItems("items/subweapons.jsonc")

-- Settings
Tracker:AddItems("settings/settings.json")
Tracker:AddItems("settings/portraits.json")
Tracker:AddItems("settings/meta.json")

-- Link item codes and bestiary codes
for k, v in pairs(LINKED_SPELLS) do
    ScriptHost:AddWatchForCode(string.format("%s_watch", k), k, LinkSpells)
    ScriptHost:AddWatchForCode(string.format("%s_watch", v), v, LinkSpells)
end
ScriptHost:AddWatchForCode("meta_watch", "reach", MetaCheck)

if not IS_ITEMS_ONLY then
    -- Maps
    Tracker:AddMaps("maps/maps.jsonc")
    -- Locations
    Tracker:AddLocations("locations/regions.jsonc")
    Tracker:AddLocations("locations/locations.jsonc")
    Tracker:AddLocations("locations/portraits.jsonc")
    Tracker:AddLocations("locations/quests.jsonc")
end

-- Layout
if IS_HORIZONTAL then
    Tracker:AddLayouts("var_horizontal/layouts/broadcast.jsonc")
    Tracker:AddLayouts("var_horizontal/layouts/items.jsonc")
    Tracker:AddLayouts("var_horizontal/layouts/quests.jsonc")
    Tracker:AddLayouts("var_horizontal/layouts/spells.jsonc")
    Tracker:AddLayouts("var_horizontal/layouts/subweapons.jsonc")
    Tracker:AddLayouts("var_horizontal/layouts/tracker.jsonc")
else
    Tracker:AddLayouts("layouts/items.jsonc")
    Tracker:AddLayouts("layouts/quests.jsonc")
    Tracker:AddLayouts("layouts/spells.jsonc")
    Tracker:AddLayouts("layouts/subweapons.jsonc")
    Tracker:AddLayouts("layouts/tracker.jsonc")
    Tracker:AddLayouts("layouts/broadcast.jsonc")
end
Tracker:AddLayouts("layouts/popup.json")

-- AutoTracking for Poptracker
if PopVersion and PopVersion >= "0.18.0" then
    ScriptHost:LoadScript("scripts/autotracking.lua")
end
