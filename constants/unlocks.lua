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
--- Crops that get identified follow the base game's pattern: the identification recipe comes with a research, the
--- trigger tech for the identified crop then unlocks what the player can do with it (farming, processing).
Unlocks.by_item_acquisition = {
    [get_tech_name("apple")] = {item = "apple", prerequisite = "ortrot-variations"},
    [get_tech_name("avocado")] = {item = "avocado", prerequisite = "genetic-neogenesis"},
    [get_tech_name("bell-pepper")] = {item = "bell-pepper", prerequisite = "nightshades"},
    [get_tech_name("bonesnake")] = {item = "bonesnake", prerequisite = "hunting-fishing"},
    [get_tech_name("boofish")] = {item = "boofish", prerequisite = "hunting-fishing", mined_from = "fishwhirl"},
    [get_tech_name("brutal-pumpkin")] = {item = "brutal-pumpkin", prerequisite = "explore-alien-flora-2"},
    [get_tech_name("cabar")] = {item = "cabar", prerequisite = "hunting-fishing"},
    [get_tech_name("caddle")] = {item = "caddle", prerequisite = "hunting-fishing"},
    [get_tech_name("cherry")] = {item = "cherry", prerequisite = "genetic-neogenesis"},
    [get_tech_name("chromafall")] = {item = "chromafall", prerequisite = "explore-alien-flora-1"},
    [get_tech_name("dodkopus")] = {item = "dodkopus", prerequisite = "advanced-fishing"},
    [get_tech_name("eggplant")] = {item = "eggplant", prerequisite = "nightshades"},
    [get_tech_name("fupper")] = {item = "fupper", prerequisite = "hunting-fishing", mined_from = "fishwhirl"},
    [get_tech_name("hardcorn-punk")] = {item = "hardcorn-punk", prerequisite = "food-processing"},
    [get_tech_name("heliofall")] = {item = "heliofall", prerequisite = "explore-alien-flora-1"},
    [get_tech_name("hellfin")] = {item = "hellfin", prerequisite = "advanced-fishing"},
    [get_tech_name("lemon")] = {item = "lemon", prerequisite = "zetorn-variations"},
    [get_tech_name("manok")] = {item = "manok", prerequisite = "explore-alien-flora-1"},
    [get_tech_name("nan-swan")] = {item = "nan-swan", prerequisite = "hunting-fishing"},
    [get_tech_name("necrofall")] = {item = "necrofall", prerequisite = "composting-silo", mined_from = "necrofall-circle"},
    [get_tech_name("olive")] = {item = "olive", prerequisite = "genetic-neogenesis"},
    [get_tech_name("orange")] = {item = "orange", prerequisite = "zetorn-variations"},
    [get_tech_name("ortrot")] = {item = "ortrot", prerequisite = "explore-alien-flora-2"},
    [get_tech_name("petunial")] = {item = "petunial", prerequisite = "advanced-fishing"},
    [get_tech_name("phytofall-blossom")] = {item = "phytofall-blossom", prerequisite = "orchid-caste"},
    [get_tech_name("potato")] = {item = "potato", prerequisite = "nightshades"},
    [get_tech_name("primal-quacker")] = {item = "primal-quacker", prerequisite = "hunting-fishing"},
    [get_tech_name("river-horse")] = {item = "river-horse", prerequisite = "hunting-fishing"},
    [get_tech_name("shellscript")] = {item = "shellscript", prerequisite = "advanced-fishing"},
    [get_tech_name("squibbel")] = {item = "miniscule-squibbel", prerequisite = "advanced-fishing"},
    [get_tech_name("sugar-beet")] = {item = "sugar-beet", prerequisite = "genetic-neogenesis"},
    [get_tech_name("sugar-cane")] = {item = "sugar-cane", prerequisite = "genetic-neogenesis"},
    [get_tech_name("tello-fruit")] = {item = "tello-fruit", prerequisite = "explore-alien-flora-1"},
    [get_tech_name("tomato")] = {item = "tomato", prerequisite = "nightshades"},
    [get_tech_name("warnal")] = {item = "warnal", prerequisite = "advanced-fishing"},
    [get_tech_name("weird-berry")] = {item = "weird-berry", prerequisite = "explore-alien-flora-1"},
    [get_tech_name("zetorn")] = {item = "zetorn", prerequisite = "explore-alien-flora-1"}
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

--- The research trigger of an item acquisition technology: crafting the item, or mining the entity it comes from.
--- @param details table entry of Unlocks.by_item_acquisition
--- @return table research_trigger
function Unlocks.get_research_trigger(details)
    if details.mined_from then
        return {type = "mine-entity", entities = {details.mined_from}}
    end
    return {type = "craft-item", item = details.item, count = 1}
end

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
