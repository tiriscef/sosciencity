local Condition = require("enums.condition")
local Type = require("enums.type")

--- Returns an array with (technology_name, item_name)-pairs.
--- The technologies are hidden and get enabled when the player aquired the given item.
local Unlocks = {}

local function get_tech_name(item_name)
    return string.format("sosciencity-unlock-%s", item_name)
end

Unlocks.by_item_aquisition = {
    [get_tech_name("apple")] = "apple",
    [get_tech_name("avocado")] = "avocado",
    [get_tech_name("bell-pepper")] = "bell-pepper",
    [get_tech_name("birdsnake")] = "birdsnake",
    [get_tech_name("bonesnake")] = "bonesnake",
    [get_tech_name("boofish")] = "boofish",
    [get_tech_name("cabar")] = "cabar",
    [get_tech_name("caddle")] = "caddle",
    [get_tech_name("cherry")] = "cherry",
    [get_tech_name("dodkopus")] = "dodkopus",
    [get_tech_name("eggplant")] = "eggplant",
    [get_tech_name("fupper")] = "fupper",
    [get_tech_name("hellfin")] = "hellfin",
    [get_tech_name("lemon")] = "lemon",
    [get_tech_name("necrofall")] = "necrofall",
    [get_tech_name("nan-swan")] = "nan-swan",
    [get_tech_name("olive")] = "olive",
    [get_tech_name("orange")] = "orange",
    [get_tech_name("petunial")] = "petunial",
    [get_tech_name("phytofall-blossom")] = "phytofall-blossom",
    [get_tech_name("potato")] = "potato",
    [get_tech_name("primal-quacker")] = "primal-quacker",
    [get_tech_name("river-horse")] = "river-horse",
    [get_tech_name("sugar-beet")] = "sugar-beet",
    [get_tech_name("sugar-cane")] = "sugar-cane",
    [get_tech_name("shellscript")] = "shellscript",
    [get_tech_name("squibbel")] = "miniscule-squibbel",
    [get_tech_name("tomato")] = "tomato",
    [get_tech_name("warnal")] = "warnal"
}

Unlocks.gated_technologies = {
    ["explore-alien-flora-1"] = {
        {
            type = Condition.caste_points,
            count = 30,
            caste = Type.orchid
        }
    },
    ["explore-alien-flora-2"] = {
        {
            type = Condition.caste_points,
            count = 150,
            caste = Type.orchid
        }
    }
}

--- Name getter function for the data stage. Checks if the name is registered for the control stage.
--- (Registering it automatically doesn't work, as the Lua state will reset before entering the control stage.)
--- @param item_name string
--- @return string
function Unlocks.get_tech_name(item_name)
    local name = get_tech_name(item_name)

    if not Unlocks.by_item_aquisition[name] then
        log("Unregistered unlocking technology name: " .. item_name)
    end

    return name
end

return Unlocks
