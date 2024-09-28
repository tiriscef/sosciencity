local Food = require("constants.food")

-- XXX: create the locales during on_load once 2.0 is out and makes that possible

local function create_food_locales()
    if Food.already_created_locales then
        return
    end
    Food.already_created_locales = true

    for name, values in pairs(Food.values) do
        local prototype = game.item_prototypes[name]
        if prototype then
            values.localised_name = prototype.localised_name
            values.localised_description = prototype.localised_description
        end
    end
end

Gui.Elements.SortableList.linked_data["food"] = Food.values
Gui.Elements.SortableList.linked_categories["food"] = {
    {
        name = "name",
        localised_name = {"city-view.food"},
        content = function(entry)
            return {"", string.format("[item=%s] ", entry.name), entry.localised_name}
        end,
        tooltip = function(entry)
            return entry.localised_description
        end,
        order = function(entry)
            return entry.name
        end,
        constant_font = "default-bold"
    },
    {
        name = "calories",
        localised_name = {"sosciencity.calories"},
        content = function(entry)
            return {"sosciencity.value-with-unit", math.floor(entry.calories), {"sosciencity.kcal"}}
        end,
        order = function(entry)
            return entry.calories
        end
    },
    {
        name = "fat",
        localised_name = {"sosciencity.fat"},
        content = function(entry)
            return string.format("%.0f%%", entry.fat / entry.calories * 1000)
        end,
        order = function(entry)
            return entry.fat
        end
    },
    {
        name = "carbohydrates",
        localised_name = {"sosciencity.carbohydrates"},
        content = function(entry)
            return string.format("%.0f%%", entry.carbohydrates / entry.calories * 1000)
        end,
        order = function(entry)
            return entry.carbohydrates
        end
    },
    {
        name = "proteins",
        localised_name = {"sosciencity.proteins"},
        content = function(entry)
            return string.format("%.0f%%", entry.proteins / entry.calories * 1000)
        end,
        order = function(entry)
            return entry.proteins
        end
    },
    {
        name = "healthiness",
        localised_name = {"sosciencity.health"},
        content = function(entry)
            return entry.healthiness
        end,
        order = function(entry)
            return entry.healthiness
        end
    },
    {
        name = "luxury",
        localised_name = {"sosciencity.luxury"},
        content = function(entry)
            return entry.luxury
        end,
        order = function(entry)
            return entry.luxury
        end
    },
    {
        name = "taste",
        localised_name = {"sosciencity.tastiness"},
        content = function(entry)
            return entry.taste_quality
        end,
        order = function(entry)
            return entry.taste_quality
        end
    },
    {
        name = "taste-category",
        localised_name = {"sosciencity.taste"},
        content = function(entry)
            return Food.taste_names[entry.taste_category]
        end,
        order = function(entry)
            return entry.taste_category
        end
    }
}

Gui.CityView.add_page {
    name = "food",
    category = "data",
    localised_name = {"city-view.food"},
    creator = function(container)
        create_food_locales()

        Gui.Elements.Label.heading_1(container, {"city-view.food-text-1"})
        Gui.Elements.SortableList.create(container, "food")
    end
}
