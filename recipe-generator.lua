---------------------------------------------------------------------------------------------------
-- << static class for recipe generation >>
--- Generator for generic recipes with configurable ingredients to facilitate integration/compatibility with other mods.
--- Assumes the result items already exist.
Tirislib_RecipeGenerator = {}

-- shorthand alias for more readability
local RG = Tirislib_RecipeGenerator

-- << definitions >>
--- Table with IngredientTheme -> table with (level, array of IngredientPrototypes) pairs\
--- Most of the time level is defined by the research stage at which the player should be able to use this recipe.\
--- **0:** Start of the game, nothing researched\
--- **1:** automation science\
--- **2:** logistic science\
--- **3:** chemical science\
--- **4:** production science\
--- **5:** utility science\
--- **6:** space science\
--- **7:** post space science
RG.ingredient_themes = {
    agriculture = {
        [0] = {
            {type = "fluid", name = "water", amount = 5}
        }
    },
    building = {
        [0] = {
            {type = "item", name = "lumber", amount = 2},
            {type = "item", name = "stone-brick", amount = 5}
        },
        [1] = {
            {type = "item", name = "lumber", amount = 2},
            {type = "item", name = "stone-brick", amount = 5}
        },
        [2] = {
            {type = "item", name = "lumber", amount = 2},
            {type = "item", name = "stone-wall", amount = 5}
        },
        [3] = {
            {type = "item", name = "lumber", amount = 2},
            {type = "item", name = "stone-wall", amount = 5}
        },
        [4] = {
            {type = "item", name = "steel-plate", amount = 6},
            {type = "item", name = "concrete", amount = 10},
            {type = "item", name = "mineral-wool", amount = 2}
        },
        [5] = {
            {type = "item", name = "steel-plate", amount = 6},
            {type = "item", name = "concrete", amount = 10},
            {type = "item", name = "mineral-wool", amount = 2}
        },
        [6] = {
            {type = "item", name = "steel-plate", amount = 8},
            {type = "item", name = "refined-concrete", amount = 10},
            {type = "item", name = "mineral-wool", amount = 2}
        },
        [7] = {
            {type = "item", name = "steel-plate", amount = 8},
            {type = "item", name = "refined-concrete", amount = 10},
            {type = "item", name = "mineral-wool", amount = 2}
        }
    },
    can = {
        [0] = {{type = "item", name = "iron-plate", amount = 1}}
    },
    electronics = {
        [0] = {{type = "item", name = "copper-cable", amount = 2}},
        [1] = {{type = "item", name = "electronic-circuit", amount = 1}},
        [2] = {{type = "item", name = "electronic-circuit", amount = 1}},
        [3] = {{type = "item", name = "electronic-circuit", amount = 1}},
        [4] = {{type = "item", name = "advanced-circuit", amount = 1}},
        [5] = {{type = "item", name = "advanced-circuit", amount = 1}},
        [6] = {{type = "item", name = "processing-unit ", amount = 1}},
        [7] = {{type = "item", name = "processing-unit ", amount = 1}}
    },
    fabric = {
        [0] = {
            {type = "item", name = "cloth", amount = 1},
            {type = "item", name = "yarn", amount = 0.1}
        }
    },
    fiber = {
        [0] = {
            {type = "item", name = "pemtenn-cotton", amount = 2}
        }
    },
    framework = {
        [0] = {
            {type = "item", name = "iron-plate", amount = 2}
        }
    },
    furnishing = {
        [0] = {},
        [1] = {
            {type = "item", name = "bed", amount = 1}
        },
        [2] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "chair", amount = 1},
            {type = "item", name = "table", amount = 1}
        },
        [3] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "chair", amount = 1.5},
            {type = "item", name = "table", amount = 1},
            {type = "item", name = "cupboard", amount = 1}
        },
        [4] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "chair", amount = 1.5},
            {type = "item", name = "table", amount = 1},
            {type = "item", name = "cupboard", amount = 1.5}
        },
        [5] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "chair", amount = 1.5},
            {type = "item", name = "table", amount = 1},
            {type = "item", name = "cupboard", amount = 2}
        },
        [6] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "chair", amount = 2},
            {type = "item", name = "table", amount = 1},
            {type = "item", name = "cupboard", amount = 2}
        },
        [7] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "chair", amount = 2},
            {type = "item", name = "table", amount = 1},
            {type = "item", name = "cupboard", amount = 2}
        },
        [8] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "chair", amount = 2},
            {type = "item", name = "table", amount = 1.5},
            {type = "item", name = "cupboard", amount = 2}
        },
        [9] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "chair", amount = 2.5},
            {type = "item", name = "table", amount = 2},
            {type = "item", name = "cupboard", amount = 3}
        },
        [10] = {
            {type = "item", name = "bed", amount = 3},
            {type = "item", name = "chair", amount = 5},
            {type = "item", name = "table", amount = 3},
            {type = "item", name = "cupboard", amount = 4}
        }
    },
    grating = {
        [0] = {{type = "item", name = "iron-stick", amount = 10}}
    },
    lamp = {
        [0] = {
            {type = "item", name = "small-lamp", amount = 1}
        }
    },
    machine = {
        [0] = {
            {type = "item", name = "copper-plate", amount = 10},
            {type = "item", name = "iron-plate", amount = 10},
            {type = "item", name = "iron-gear-wheel", amount = 5}
        },
        [1] = {
            {type = "item", name = "copper-plate", amount = 1},
            {type = "item", name = "iron-plate", amount = 1},
            {type = "item", name = "iron-gear-wheel", amount = 5}
        },
        [2] = {
            {type = "item", name = "copper-plate", amount = 10},
            {type = "item", name = "iron-plate", amount = 10},
            {type = "item", name = "iron-gear-wheel", amount = 10}
        },
        [3] = {
            {type = "item", name = "engine-unit", amount = 5},
            {type = "item", name = "steel-plate", amount = 10},
            {type = "item", name = "iron-gear-wheel", amount = 10}
        },
        [4] = {
            {type = "item", name = "engine-unit", amount = 5},
            {type = "item", name = "steel-plate", amount = 10},
            {type = "item", name = "iron-gear-wheel", amount = 10}
        },
        [5] = {
            {type = "item", name = "electric-engine-unit", amount = 5},
            {type = "item", name = "steel-plate", amount = 10},
            {type = "item", name = "iron-gear-wheel", amount = 10}
        },
        [6] = {
            {type = "item", name = "electric-engine-unit", amount = 5},
            {type = "item", name = "steel-plate", amount = 10},
            {type = "item", name = "iron-gear-wheel", amount = 10}
        },
        [7] = {
            {type = "item", name = "electric-engine-unit", amount = 5},
            {type = "item", name = "steel-plate", amount = 10},
            {type = "item", name = "iron-gear-wheel", amount = 10}
        }
    },
    mechanic = {
        [0] = {
            {type = "item", name = "iron-stick", amount = 1},
            {type = "item", name = "iron-gear-wheel", amount = 1}
        }
    },
    piping = {
        [0] = {
            {type = "item", name = "pipe", amount = 10}
        }
    },
    soil = {
        [0] = {
            {type = "item", name = "humus", amount = 1}
        }
    },
    tank = {
        [0] = {
            {type = "item", name = "iron-plate", amount = 5},
            {type = "item", name = "pipe", amount = 10}
        },
        [2] = {
            {type = "item", name = "storage-tank", amount = 1}
        }
    },
    windows = {
        [0] = {
            {type = "item", name = "iron-plate", amount = 1}
        }
    },
    wood = {
        [0] = {
            {type = "item", name = "wood", amount = 1}
        },
        [1] = {
            {type = "item", name = "tiricefing-willow-wood", amount = 1}
        },
        [2] = {
            {type = "item", name = "cherry-wood", amount = 1}
        }
    },
    woodwork = {
        [0] = {
            {type = "item", name = "lumber", amount = 1}
        }
    }
}

RG.expensive_multiplier = 2

-- << generation >>
--- Returns the entry in the theme definition that is the closest to the given level.
--- It doesn't return a definition with a higher level to avoid creating progression deadlocks.
local function get_nearest_level(theme_definition, level)
    local ret
    local distance = math.huge

    for defined_level, defined_ingredients in pairs(theme_definition) do
        local current_distance = level - defined_level

        if current_distance >= 0 and current_distance < distance then
            ret = defined_ingredients
            distance = current_distance
        end
    end

    return ret
end

local function get_theme_definition(name, level)
    local ret

    local theme_definition = RG.ingredient_themes[name]
    if theme_definition then
        ret = get_nearest_level(theme_definition, level)
    else
        log("Tirislib RecipeGenerator was told to generate a recipe with an undefined theme: " .. name)
    end

    return ret and Tirislib_Tables.recursive_copy(ret)
end

function RG.add_ingredient_theme(recipe, theme, default_level)
    local name = theme[1]
    local amount = theme[2]
    local level = theme[3] or default_level or 0

    local theme_definition = get_theme_definition(name, level)
    if not theme_definition then
        return
    end

    for _, entry in pairs(theme_definition) do
        entry.amount = entry.amount * amount
    end

    recipe:add_ingredient_range(theme_definition)
end

function RG.add_ingredient_theme_range(recipe, themes, default_level)
    if themes then
        for _, theme in pairs(themes) do
            RG.add_ingredient_theme(recipe, theme, default_level)
        end

        recipe:floor_ingredients()
    end
end

function RG.add_result_theme(recipe, theme, default_level)
    local name = theme[1]
    local amount = theme[2]
    local level = theme[3] or default_level or 1

    local ingredients = get_theme_definition(name, level)
    if not ingredients then
        return
    end

    for _, entry in pairs(ingredients) do
        entry.amount = entry.amount * amount
    end

    recipe:add_result_range(ingredients)
end

function RG.add_result_theme_range(recipe, themes, default_level)
    if themes then
        for _, theme in pairs(themes) do
            RG.add_result_theme(recipe, theme, default_level)
        end

        recipe:floor_results()
    end
end

local function get_product(details)
    local product =
        (details.product_type == "fluid") and Tirislib_Fluid.get_by_name(details.product) or
        Tirislib_Item.get_by_name(details.product)

    if Tirislib_Prototype.is_dummy(product) then
        error(
            "Tirislib RecipeGenerator was told to create a recipe for a non-existant item. A task it's unable to complete. The item's name is " ..
                details.product
        )
    end

    return product
end

local function get_main_product_entry(product, details)
    local main_product = {
        type = details.product_type or "item",
        name = product.name,
        probability = details.product_probability
    }

    if details.product_amount then
        main_product.amount = details.product_amount
    elseif details.product_min then
        main_product.amount_min = details.product_min
        main_product.amount_max = details.product_max
    else
        main_product.amount = 1
    end

    return main_product
end

--- Creates a dynamic recipe.\
--- **product:** name of the main product\
--- **product_type:** type of the main product (defaults to "item")\
--- **product_amount:** amount of the main product (defaults to 1)\
--- **product_min:** minimal amount of the main product (if the recipe should use a range)\
--- **product_max:** maximal amount of the main product (if the recipe should use a range)\
--- **product_probability:** probability of the main product\
--- **byproducts:** array of ResultPrototypes\
--- **expensive_byproducts:** array of ResultPrototypes (defaults to the byproducts field)\
--- **category:** RecipeCategory of the recipe (defaults to "crafting")\
--- **themes:** array of themes\
--- **result_themes:** array of themes\
--- **default_theme_level:** number\
--- **ingredients:** array of IngredientPrototypes\
--- **expensive_ingredients:** array of IngredientPrototypes (defaults to the ingredient field)\
--- **expensive_multiplier:** ingredient multiplier for expensive mode (defaults to a global value)\
--- **energy_required:** energy_required field for the recipe (defaults to 0.5)\
--- **expensive_energy_required:** energy_required field for the expensive recipe (defaults to energy_required)\
--- **unlock:** technology that unlocks the recipe\
--- **additional_fields:** other fields that should be set for the recipe\
--- **allow_productivity:** bool
function RG.create(details)
    local product_prototype = get_product(details)
    local main_product = get_main_product_entry(product_prototype, details)

    local recipe =
        Tirislib_Recipe.create {
        name = Tirislib_Prototype.get_unique_name(product_prototype.name, "recipe"),
        category = details.category or "crafting",
        enabled = true,
        energy_required = details.energy_required or 0.5,
        results = {main_product},
        subgroup = product_prototype.subgroup,
        order = product_prototype.order,
        main_product = product_prototype.name,
        always_show_products = true
    }:create_difficulties()

    -- theme defined
    RG.add_ingredient_theme_range(recipe, details.themes, details.default_theme_level)
    RG.add_result_theme_range(recipe, details.result_themes, details.default_theme_level)

    -- explicit defined
    recipe:add_ingredient_range(details.ingredients, details.expensive_ingredients)
    recipe:add_result_range(details.byproducts, details.expensive_byproducts)

    recipe:multiply_expensive_ingredients(details.expensive_multiplier or RG.expensive_multiplier)
    recipe:set_expensive_field("energy_required", details.expensive_energy_required or details.energy_required or 0.5)

    recipe:add_unlock(details.unlock)

    recipe:set_fields(details.additional_fields)

    if details.allow_productivity then
        recipe:allow_productivity_modules()
    end

    return recipe
end
