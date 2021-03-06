--- Generator for generic recipes with configurable ingredients to facilitate integration/compatibility with other mods.
--- Assumes the result items already exist.
Tirislib_RecipeGenerator = {}

-- shorthand alias for more readability
local RG = Tirislib_RecipeGenerator

---------------------------------------------------------------------------------------------------
-- << definitions >>

--- Table with Theme -> table with (level, array of IngredientPrototypes) pairs\
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
            {type = "fluid", name = "water", amount = 500}
        },
        [1] = {
            {type = "item", name = "humus", amount = 10},
            {type = "fluid", name = "water", amount = 500}
        }
    },
    boring = {
        [0] = {
            {type = "item", name = "burner-mining-drill", amount = 1}
        },
        [2] = {
            {type = "item", name = "electric-mining-drill", amount = 1}
        }
    },
    breed_birds = {
        [0] = {
            {type = "item", name = "bird-food", amount = 1},
            {type = "fluid", name = "water", amount = 10}
        }
    },
    breed_carnivores = {
        [0] = {
            {type = "item", name = "carnivore-food", amount = 1},
            {type = "fluid", name = "water", amount = 10}
        }
    },
    breed_fish = {
        [0] = {
            {type = "item", name = "fish-food", amount = 1},
            {type = "fluid", name = "water", amount = 50}
        }
    },
    breed_herbivores = {
        [0] = {
            {type = "item", name = "herbivore-food", amount = 1},
            {type = "fluid", name = "water", amount = 10}
        }
    },
    breed_omnivores = {
        [0] = {
            {type = "item", name = "herbivore-food", amount = 2. / 3},
            {type = "item", name = "carnivore-food", amount = 1. / 3},
            {type = "fluid", name = "water", amount = 10}
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
    casing = {
        [0] = {{type = "item", name = "iron-plate", amount = 2}}
    },
    cooling_fluid = {
        [0] = {{type = "fluid", name = "petroleum-gas", amount = 1}}
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
        },
        [1] = {
            {type = "item", name = "steel-plate", amount = 2}
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
            {type = "item", name = "table", amount = 0.5}
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
            {type = "item", name = "cupboard", amount = 2},
            {type = "item", name = "air-conditioner", amount = 1 / 3}
        },
        [7] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "chair", amount = 2},
            {type = "item", name = "table", amount = 1},
            {type = "item", name = "cupboard", amount = 2},
            {type = "item", name = "air-conditioner", amount = 1 / 3}
        },
        [8] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "chair", amount = 2},
            {type = "item", name = "table", amount = 1.5},
            {type = "item", name = "cupboard", amount = 2},
            {type = "item", name = "air-conditioner", amount = 0.5}
        },
        [9] = {
            {type = "item", name = "bed", amount = 1},
            {type = "item", name = "chair", amount = 2.5},
            {type = "item", name = "table", amount = 2},
            {type = "item", name = "cupboard", amount = 3},
            {type = "item", name = "air-conditioner", amount = 2 / 3}
        },
        [10] = {
            {type = "item", name = "bed", amount = 3},
            {type = "item", name = "chair", amount = 5},
            {type = "item", name = "table", amount = 3},
            {type = "item", name = "cupboard", amount = 4},
            {type = "item", name = "air-conditioner", amount = 1}
        }
    },
    furnishing_decorated = {
        [0] = {
            {type = "item", name = "painting", amount = 1}
        }
    },
    grating = {
        [0] = {{type = "item", name = "iron-stick", amount = 10}}
    },
    in_vitro_reproduction = {
        [0] = {} -- TODO: in-vitro ingredients
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
            {type = "item", name = "copper-plate", amount = 10},
            {type = "item", name = "iron-plate", amount = 10},
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
    paper_production = {
        [0] = {
            {type = "fluid", name = "steam", amount = 200}
        }
    },
    piping = {
        [0] = {
            {type = "item", name = "pipe", amount = 1}
        }
    },
    plating = {
        [0] = {
            {type = "item", name = "iron-plate", amount = 1}
        }
    },
    screw_material = {
        [0] = {
            {type = "item", name = "iron-plate", amount = 2}
        },
        [1] = {
            {type = "item", name = "copper-plate", amount = 2}
        },
        [70] = {
            {type = "item", name = "steel-plate", amount = 2}
        }
    },
    soil = {
        [0] = {
            {type = "item", name = "humus", amount = 1}
        }
    },
    structure = {
        [0] = {
            {type = "item", name = "iron-plate", amount = 1}
        }
    },
    tablet_ingredients = {
        [0] = {
            {type = "item", name = "amylum", amount = 1}
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
    wiring = {
        [0] = {
            {type = "item", name = "copper-cable", amount = 2}
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

--- Table with Theme -> table with (level, array of ResultPrototypes) pairs\
--- These are separate from the ingredient themes, because ResultPrototypes aren't valid IngredientPrototypes.
RG.result_themes = {
    sediment = {
        [0] = {
            {type = "item", name = "leafage", amount = 1, probability = 0.2},
            {type = "item", name = "stone", amount = 1, probability = 0.3},
            {type = "item", name = "wood", amount = 1, probability = 0.2}
        }
    }
}

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

local function get_theme_definition(name, level, for_result)
    local ret

    local theme_definition = (for_result and RG.result_themes[name]) or RG.ingredient_themes[name]
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
    local level = theme[3] or default_level or 1

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

    local results = get_theme_definition(name, level, true)
    if not results then
        return
    end

    for _, entry in pairs(results) do
        entry.amount = entry.amount * amount
    end

    recipe:add_result_range(results)
end

function RG.add_result_theme_range(recipe, themes, default_level)
    if themes then
        for _, theme in pairs(themes) do
            RG.add_result_theme(recipe, theme, default_level)
        end

        recipe:floor_results()
    end
end

local function get_product_prototype(details)
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

local function has_fluid_ingredient(recipe_data)
    for _, ingredient in pairs(recipe_data.ingredients) do
        if Tirislib_RecipeEntry.yields_fluid(ingredient) then
            return true
        end
    end

    return false
end

local function get_standard_category(recipe)
    local normal, expensive = recipe:call_on_recipe_data(has_fluid_ingredient)
    return (normal or expensive) and "crafting-with-fluid" or "crafting"
end

--- Creates a dynamic recipe.\
--- **product:** name of the main product\
--- **product_type:** type of the main product (defaults to "item")\
--- **product_amount:** amount of the main product (defaults to 1)\
--- **product_min:** minimal amount of the main product (if the recipe should use a range)\
--- **product_max:** maximal amount of the main product (if the recipe should use a range)\
--- **product_probability:** probability of the main product\
--- **name:** name of the recipe (defaults to the name of the product)\
--- **byproducts:** array of ResultPrototypes\
--- **expensive_byproducts:** array of ResultPrototypes (defaults to the byproducts field)\
--- **category:** RecipeCategory of the recipe (defaults to "crafting")\
--- **themes:** array of themes\
--- **result_themes:** array of themes\
--- **default_theme_level:** number\
--- **ingredients:** array of IngredientPrototypes\
--- **expensive_ingredients:** array of IngredientPrototypes (defaults to the ingredient field)\
--- **expensive_multiplier:** ingredient multiplier for expensive mode\
--- **energy_required:** energy_required field for the recipe (defaults to 0.5)\
--- **expensive_energy_required:** energy_required field for the expensive recipe (defaults to energy_required)\
--- **unlock:** technology that unlocks the recipe\
--- **additional_fields:** other fields that should be set for the recipe\
--- **allow_productivity:** bool
--- **set_main_product:** bool (defaults to true)
function RG.create(details)
    local product = get_product_prototype(details)
    local main_product = get_main_product_entry(product, details)

    local recipe =
        Tirislib_Recipe.create {
        name = Tirislib_Prototype.get_unique_name(details.name or product.name, "recipe"),
        enabled = true,
        energy_required = details.energy_required or 0.5,
        results = {main_product},
        subgroup = product.subgroup,
        order = product.order,
        always_show_products = true
    }

    if details.set_main_product or details.set_main_product == nil then
        recipe.main_product = product.name
    else
        recipe.localised_name = details.localised_name or product.localised_name or {"item-name." .. product.name}
        recipe.localised_description =
            details.localised_description or product.localised_description or {"item-description." .. product.name}
        recipe.icon = details.icon or product.icon
        recipe.icon_size = details.icon_size or product.icon_size or 64
    end

    recipe:create_difficulties()

    -- theme defined
    RG.add_ingredient_theme_range(recipe, details.themes, details.default_theme_level)
    RG.add_result_theme_range(recipe, details.result_themes, details.default_theme_level)

    -- explicit defined
    recipe:add_ingredient_range(details.ingredients, details.expensive_ingredients)
    recipe:add_result_range(details.byproducts, details.expensive_byproducts)

    recipe:multiply_expensive_ingredients(details.expensive_multiplier)
    recipe:set_expensive_field("energy_required", details.expensive_energy_required or details.energy_required or 0.5)

    recipe:add_unlock(details.unlock)

    recipe:set_fields(details.additional_fields)

    recipe:set_field("category", details.category or get_standard_category(recipe))

    if details.allow_productivity then
        recipe:allow_productivity_modules()
    end

    return recipe
end

--- Creates a dynamic recipe for every level of a given ingredient theme.\
--- Additional fields:\
--- **followed_theme:** name\
--- **followed_theme_amount:** number or function\
--- **dynamic_fields:** table with (detail field, fn) pairs. The functions will be called with the theme level as the argument.\
function RG.create_per_theme_level(details)
    local theme_name = details.followed_theme
    local theme_definition = RG.ingredient_themes[theme_name]
    local theme_amount = details.followed_theme_amount or 1
    local dynamic = details.dynamic_fields or {}

    local created_recipes = {}
    setmetatable(created_recipes, Tirislib_RecipeArray)

    if not theme_definition then
        log("Tirislib RecipeGenerator was told to follow an undefined theme: " .. details.followed_theme)
        theme_definition = {}
    end

    for level in pairs(theme_definition) do
        local current_details = Tirislib_Tables.copy(details)

        -- set dynamic fields
        for field, fn in pairs(dynamic) do
            current_details[field] = fn(level)
        end

        -- set the current followed theme
        local themes = Tirislib_Tables.get_subtbl(current_details, "themes")
        themes[#themes + 1] = {
            theme_name,
            type(theme_amount) == "function" and theme_amount(level) or theme_amount,
            level
        }

        created_recipes[#created_recipes + 1] = RG.create(current_details)
    end

    return created_recipes
end
