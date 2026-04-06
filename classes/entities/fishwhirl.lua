Events.set_on_init_handler(
    function()
        for _, surface in pairs(game.surfaces) do
            for _, entity in pairs(surface.find_entities_filtered {name = "fishwhirl"}) do
                entity.active = false
            end
        end
    end
)

Events.set_script_trigger_handler(
    "sosciencity-fishwhirl-creation",
    function(event)
        event.source_entity.active = false
    end
)
