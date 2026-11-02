local UnlockCondition = require("enums.unlock-condition")
local Type = require("enums.type")

--- Custom technology enabling/researching methods.
local Unlocks = {}

local function get_tech_name(item_name)
    return string.format("sosciencity-unlock-%s", item_name)
end

--- Technologies that are researched by aquiring a given item.
--- The prerequisite is the technology that first makes the item obtainable, so that the trigger technology
--- doesn't show up in the tech tree before the player can do anything about it.
--- Items that the player only gets by mining an entity name it as `mined_from`, because mining doesn't count as crafting.
Unlocks.by_item_acquisition = {
    [get_tech_name("apple")] = {item = "apple", prerequisite = "ortrot-variations"},
    [get_tech_name("avocado")] = {item = "avocado", prerequisite = "genetic-neogenesis"},
    [get_tech_name("bell-pepper")] = {item = "bell-pepper", prerequisite = "nightshades"},
    [get_tech_name("birdsnake")] = {item = "birdsnake", prerequisite = "mushroom-farming"},
    [get_tech_name("bonesnake")] = {item = "bonesnake", prerequisite = "hunting-fishing"},
    [get_tech_name("boofish")] = {item = "boofish", prerequisite = "hunting-fishing", mined_from = "fishwhirl"},
    [get_tech_name("cabar")] = {item = "cabar", prerequisite = "hunting-fishing"},
    [get_tech_name("caddle")] = {item = "caddle", prerequisite = "hunting-fishing"},
    [get_tech_name("cherry")] = {item = "cherry", prerequisite = "genetic-neogenesis"},
    [get_tech_name("dodkopus")] = {item = "dodkopus", prerequisite = "advanced-fishing"},
    [get_tech_name("eggplant")] = {item = "eggplant", prerequisite = "nightshades"},
    [get_tech_name("fupper")] = {item = "fupper", prerequisite = "hunting-fishing", mined_from = "fishwhirl"},
    [get_tech_name("hellfin")] = {item = "hellfin", prerequisite = "advanced-fishing"},
    [get_tech_name("lemon")] = {item = "lemon", prerequisite = "zetorn-variations"},
    [get_tech_name("necrofall")] = {item = "necrofall", prerequisite = "composting-silo", mined_from = "necrofall-circle"},
    [get_tech_name("nan-swan")] = {item = "nan-swan", prerequisite = "hunting-fishing"},
    [get_tech_name("olive")] = {item = "olive", prerequisite = "genetic-neogenesis"},
    [get_tech_name("orange")] = {item = "orange", prerequisite = "zetorn-variations"},
    [get_tech_name("petunial")] = {item = "petunial", prerequisite = "advanced-fishing"},
    [get_tech_name("phytofall-blossom")] = {item = "phytofall-blossom", prerequisite = "orchid-caste"},
    [get_tech_name("potato")] = {item = "potato", prerequisite = "nightshades"},
    [get_tech_name("primal-quacker")] = {item = "primal-quacker", prerequisite = "hunting-fishing"},
    [get_tech_name("river-horse")] = {item = "river-horse", prerequisite = "hunting-fishing"},
    [get_tech_name("sugar-beet")] = {item = "sugar-beet", prerequisite = "genetic-neogenesis"},
    [get_tech_name("sugar-cane")] = {item = "sugar-cane", prerequisite = "genetic-neogenesis"},
    [get_tech_name("shellscript")] = {item = "shellscript", prerequisite = "advanced-fishing"},
    [get_tech_name("squibbel")] = {item = "miniscule-squibbel", prerequisite = "advanced-fishing"},
    [get_tech_name("tomato")] = {item = "tomato", prerequisite = "nightshades"},
    [get_tech_name("warnal")] = {item = "warnal", prerequisite = "advanced-fishing"}
}

--- Technologies that are gated by one or more conditions.
Unlocks.gated_technologies = {
    ["explore-alien-flora-1"] = {
        {
            type = UnlockCondition.caste_points,
            count = 30,
            caste = Type.orchid
        }
    },
    ["explore-alien-flora-2"] = {
        {
            type = UnlockCondition.caste_points,
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

    if not Unlocks.by_item_acquisition[name] then
        log("Unregistered unlocking technology name: " .. item_name)
    end

    return name
end

return Unlocks
