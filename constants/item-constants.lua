--- Various item-related constants
local ItemConstants = {}

ItemConstants.garbage_items = {
    ["garbage"] = true,
    ["food-leftovers"] = true,
    ["leafage"] = true,
    ["slaughter-waste"] = true
}

ItemConstants.garbage_values = {
    ["garbage"] = 1,
    ["food-leftovers"] = 1,
    ["slaughter-waste"] = 1.5,
    ["sewage-sludge"] = 1.5
}

local wood_compost_value = 4
ItemConstants.compost_values = {
    ["agarose"] = 0.5,
    ["apple"] = 1,
    ["avocado"] = 1,
    ["avocado-wood"] = wood_compost_value,
    ["bell-pepper"] = 1,
    ["bird-meat"] = 0.5,
    ["blue-grapes"] = 1,
    ["brutal-pumpkin"] = 1,
    ["cherry"] = 1,
    ["cherry-wood"] = wood_compost_value,
    ["chickpea"] = 1,
    ["dried-solfaen"] = 0.1,
    ["eggplant"] = 1,
    ["fawoxylas"] = 0.5,
    ["feathers"] = 0.5,
    ["fish-meat"] = 0.5,
    ["food-leftovers"] = 0.5,
    ["hummus"] = 0.2,
    ["leafage"] = 1,
    ["lemon"] = 1,
    ["liontooth"] = 0.5,
    ["insect-meat"] = 0.5,
    ["mammal-meat"] = 0.5,
    ["manok"] = 1,
    ["molasses"] = 0.1,
    ["nan-egg"] = 0.5,
    ["offal"] = 0.5,
    ["olive"] = 1,
    ["olive-wood"] = wood_compost_value,
    ["orange"] = 1,
    ["ortrot"] = 1,
    ["ortrot-wood"] = wood_compost_value,
    ["phytofall-blossom"] = 1,
    ["plemnemm-cotton"] = 1,
    ["potato"] = 1,
    ["primal-egg"] = 0.5,
    ["razha-bean"] = 1,
    ["sesame"] = 1,
    ["sawdust"] = 0.5,
    ["sewage-sludge"] = 3,
    ["slaughter-waste"] = 0.5,
    ["sugar"] = 0.1,
    ["sugar-cane"] = 1,
    ["sugar-beet"] = 1,
    ["tello-fruit"] = 1,
    ["tiriscefing-willow-wood"] = wood_compost_value,
    ["tofu"] = 0.5,
    ["tomato"] = 1,
    ["unnamed-fruit"] = 1,
    ["weird-berry"] = 1,
    ["yuba"] = 0.1,
    ["zetorn"] = 1,
    ["zetorn-wood"] = wood_compost_value,
}

ItemConstants.mold_producers = {
    ["bell-pepper"] = true,
    ["blue-grapes"] = true,
    ["brutal-pumpkin"] = true,
    ["cherry"] = true,
    ["eggplant"] = true,
    ["ortrot"] = true,
    ["lemon"] = true,
    ["potato"] = true,
    ["sugar-beet"] = true,
    ["tofu"] = true,
    ["tomato"] = true,
    ["unnamed-fruit"] = true,
    ["weird-berry"] = true,
    ["zetorn"] = true
}

return ItemConstants
