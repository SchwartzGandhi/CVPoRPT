-- from https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
-- dumps a table in a readable string
function dump_table(o, depth)
    if depth == nil then
        depth = 0
    end
    if type(o) == 'table' then
        local tabs = ('\t'):rep(depth)
        local tabs2 = ('\t'):rep(depth + 1)
        local s = '{\n'
        for k, v in pairs(o) do
            local kc = k
            if type(k) ~= 'number' then
                kc = '"' .. k .. '"'
            end
            s = s .. tabs2 .. '[' .. kc .. '] = ' .. dump_table(v, depth + 1) .. ',\n'
        end
        return s .. tabs .. '}'
    else
        return tostring(o)
    end
end

LINKED_SPELLS = {
    ["froggy"] = "questfrog",
    ["birdie"] = "questowl", 
    ["fortress"] = "questsanc",
    ["fast"] = "questfast"
}
-- Enable/Disable a linked item's partner
function LinkSpells(item_code)
    local code_obj = Tracker:FindObjectForCode(item_code)
    if code_obj then
        local link_obj
        for quest_spell, prog_spell in pairs(LINKED_SPELLS) do
            if item_code == quest_spell then
                link_obj = Tracker:FindObjectForCode(prog_spell)
            elseif item_code == prog_spell then
                link_obj = Tracker:FindObjectForCode(quest_spell)
            end
        end
        link_obj.Active = code_obj.Active
    end
end

-- If logic updates upon collecting an event, the event must be shown
function MetaCheck()
    if has("collect") then
        Tracker:FindObjectForCode("events").CurrentStage = 1
    end
end