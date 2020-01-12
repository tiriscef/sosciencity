-- Static class for all the functions that tell the player something through various means.
-- Communication is very important in a relationship.
Communication = {}

local global
local item_statistics
local fluid_statistics

function Communication.create_flying_text(entry, text)
    local entity = entry[ENTITY]

    entity.surface.create_entity {
        name = "flying-text",
        position = entity.position,
        text = text
    }
end

function Communication.log_item(item, amount)
    item_statistics.on_flow(item, amount)
end

function Communication.log_fluid(fluid, amount)
    fluid_statistics.on_flow(fluid, amount)
end

local function set_locals()
    global = _ENV.global
    item_statistics = game.forces.player.item_production_statistics
    fluid_statistics = game.forces.player.fluid_production_statistics
end

function Communication.init()
    set_locals()
end

function Communication.load()
    set_locals()
end

return Communication
