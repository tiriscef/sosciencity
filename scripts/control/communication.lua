-- Static class for all the functions that tell the player something through various means.
-- Communication is very important in a relationship.
Communication = {}

function Communication.create_flying_text(entry, text)
    local entity = entry[ENTITY]

    entity.surface.create_entity {
        name = "flying-text",
        position = entity.position,
        text = text
    }
end

return Communication
