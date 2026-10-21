local Building = require("constants.buildings")

-- TODO: graphics are a blockout render for now

local GRAPHICS_PATH = "__sosciencity-graphics__/graphics/entity/cold-storage-warehouse/cold-storage-warehouse"

--- Roof band colour of the plain warehouse.
local NEUTRAL_TINT = {0.62, 0.64, 0.67}

--- Per logistic mode: the roof band colour (the tinted mask layer) and the techs that unlock the
--- matching vanilla chest.
local logistic_variants = {
    ["passive-provider"] = {
        tint = {0.86, 0.22, 0.16},
        unlock = {"construction-robotics", "logistic-robotics"},
        order = "dab"
    },
    ["active-provider"] = {
        tint = {0.62, 0.28, 0.80},
        unlock = "logistic-system",
        order = "dac"
    },
    ["storage"] = {
        tint = {0.95, 0.75, 0.18},
        unlock = {"construction-robotics", "logistic-robotics"},
        order = "dad",
        -- the engine allows a storage chest only its one filter slot
        max_logistic_slots = 1
    },
    ["buffer"] = {
        tint = {0.32, 0.72, 0.25},
        unlock = "logistic-system",
        order = "dae",
        trash_inventory_size = 20
    },
    ["requester"] = {
        tint = {0.25, 0.48, 0.92},
        unlock = "logistic-system",
        order = "daf",
        trash_inventory_size = 20
    }
}

local function create_item(name, order)
    return Tirislib.Item.create {
        type = "item",
        name = name,
        icon = Tirislib.Prototype.placeholder_icon,
        icon_size = 64,
        subgroup = "sosciencity-food-buildings",
        order = order,
        place_result = name,
        stack_size = Sosciencity.Config.building_stacksize,
        pictures = Sosciencity.Config.blueprint_on_belt
    }
end

--- The variants share everything but the entity type, the logistic fields and the roof colour.
local function create_entity(name, tint, fields)
    local prototype = {
        type = "container",
        name = name,
        flags = {"placeable-neutral", "player-creation"},
        minable = {mining_time = 0.5, result = name},
        max_health = 200,
        inventory_size = 80,
        fast_replaceable_group = "cold-storage-warehouse",
        corpse = "small-remnants",
        vehicle_impact_sound = {filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65},
        repair_sound = {filename = "__base__/sound/manual-repair-simple.ogg"},
        open_sound = {filename = "__base__/sound/machine-open.ogg", volume = 0.85},
        close_sound = {filename = "__base__/sound/machine-close.ogg", volume = 0.75},
        picture = Tirislib.Entity.create_standard_picture {
            path = GRAPHICS_PATH,
            width = 8,
            height = 8,
            shift = {0, 0},
            shadowmap = true,
            mask_tint = tint
        },
        circuit_wire_connection_point = circuit_connector_definitions["chest"].points, -- TODO think about something for them
        circuit_connector_sprites = circuit_connector_definitions["chest"].sprites,
        circuit_wire_max_distance = 13
    }
    for key, value in pairs(fields or {}) do
        prototype[key] = value
    end

    Tirislib.Entity.create(prototype):set_size(6, 6):copy_icon_from_item()
    Sosciencity.configure_building(name)
end

create_item("cold-storage-warehouse", "daa")

Tirislib.RecipeGenerator.create {
    results = {
        {type = "item", name = "cold-storage-warehouse", amount = 1}
    },
    ingredients = {
        {theme = "building", amount = 2},
        {theme = "machine", amount = 2}
    },
    unlock = "food-processing"
}

create_entity("cold-storage-warehouse", NEUTRAL_TINT)

for _, mode in pairs(Building.cold_storage_logistic_modes) do
    local variant = logistic_variants[mode]
    local name = mode .. "-cold-storage-warehouse"
    local chest = mode .. "-chest"

    create_item(name, variant.order):add_ingredient_layer(chest)

    Tirislib.RecipeGenerator.create {
        results = {
            {type = "item", name = name, amount = 1}
        },
        ingredients = {
            {type = "item", name = "cold-storage-warehouse", amount = 1},
            {type = "item", name = chest, amount = 1}
        },
        unlock = variant.unlock
    }

    create_entity(
        name,
        variant.tint,
        {
            type = "logistic-container",
            logistic_mode = mode,
            trash_inventory_size = variant.trash_inventory_size,
            max_logistic_slots = variant.max_logistic_slots,
            localised_description = {
                "",
                {"entity-description.cold-storage-warehouse"},
                "\n",
                {"entity-description." .. chest}
            }
        }
    )
end
