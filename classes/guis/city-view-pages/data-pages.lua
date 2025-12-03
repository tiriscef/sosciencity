Gui.CityView.add_category("data", {"city-view.data"})

local Food = require("constants.food")

-- XXX: create the locales during on_load once 2.0 is out and makes that possible

local function create_food_locales()
    if Food.already_created_locales then
        return
    end
    Food.already_created_locales = true

    for name, values in pairs(Food.values) do
        local prototype = prototypes.item[name]
        if prototype then
            values.localised_name = prototype.localised_name
            values.localised_description = prototype.localised_description
        end
    end
end

Gui.Elements.SortableList.linked["food"] = {
    data = Food.values,
    categories = {
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
                return string.format("%.0f%%", 100 * entry.fat / (entry.fat + entry.carbohydrates + entry.proteins))
            end,
            order = function(entry)
                return entry.fat / (entry.fat + entry.carbohydrates + entry.proteins)
            end
        },
        {
            name = "carbohydrates",
            localised_name = {"sosciencity.carbohydrates"},
            content = function(entry)
                return string.format(
                    "%.0f%%",
                    100 * entry.carbohydrates / (entry.fat + entry.carbohydrates + entry.proteins)
                )
            end,
            order = function(entry)
                return entry.carbohydrates / (entry.fat + entry.carbohydrates + entry.proteins)
            end
        },
        {
            name = "proteins",
            localised_name = {"sosciencity.proteins"},
            content = function(entry)
                return string.format(
                    "%.0f%%",
                    100 * entry.proteins / (entry.fat + entry.carbohydrates + entry.proteins)
                )
            end,
            order = function(entry)
                return entry.proteins / (entry.fat + entry.carbohydrates + entry.proteins)
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
                return Locale.taste_category(entry.taste_category)
            end,
            order = function(entry)
                return entry.taste_category
            end
        }
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

local Diseases = require("constants.diseases")
local DiseaseCategory = require("enums.disease-category")

local function fill_disease_catalogue(container, filter)
    local filtered_content = Tirislib.Luaq.from(Diseases.values)
    if filter then
        filtered_content:where(filter)
    end

    local list = container.ichd
    list.clear()
    for _, disease in filtered_content:pairs() do
        list.add {
            type = "label",
            caption = disease.localised_description,
            style = "sosciencity_paragraph"
        }
    end
end

Gui.set_click_handler_tag(
    "filter_ichd",
    function(event)
        local button = event.element
        local tags = button.tags

        local is_checked = not button.toggled
        button.toggled = is_checked

        local flow = button.parent
        for name in pairs(DiseaseCategory) do
            if name ~= tags.category_name then
                flow[name].toggled = false
            end
        end

        local category = tags.category
        fill_disease_catalogue(
            flow.parent,
            is_checked and function(_, disease)
                    return Diseases.categories[category][disease.id] ~= nil
                end or nil
        )
    end
)

Gui.CityView.add_page {
    name = "diseases",
    category = "data",
    localised_name = {"city-view.diseases"},
    creator = function(container)
        Gui.Elements.Label.heading_1(container, {"city-view.ICHD"})
        Gui.Elements.Label.paragraph(container, {"city-view.ICHD-intro"})
        Gui.Elements.Label.heading_3(container, {"city-view.filter-by-category"})

        local filter_flow =
            container.add {
            type = "table",
            name = "filters",
            column_count = 7
        }

        for name, id in pairs(DiseaseCategory) do
            filter_flow.add {
                type = "button",
                name = name,
                caption = Locale.disease_category(id),
                tooltip = Locale.disease_category_description(id),
                tags = {
                    sosciencity_gui_event = "filter_ichd",
                    category = id,
                    category_name = name
                },
                style = "sosciencity_sortable_list_head"
            }
        end

        container.add {
            type = "table",
            name = "ichd",
            column_count = 1,
            style = "sosciencity_sortable_list"
        }

        fill_disease_catalogue(container)
    end
}

local ItemConstants = require("constants.item-constants")

Gui.Elements.SortableList.linked["compostables"] = {
    data = Tirislib.Luaq.from(ItemConstants.compost_values):select(
        function(name, humus)
            return {
                name = name,
                humus = humus,
                mold = ItemConstants.mold_producers[name]
            }
        end
    ):to_table(),
    categories = {
        {
            name = "name",
            localised_name = {"city-view.item"},
            content = function(entry)
                return {"", string.format("[item=%s] ", entry.name), prototypes.item[entry.name].localised_name}
            end,
            tooltip = function(entry)
                return prototypes.item[entry.name].localised_description
            end,
            order = function(entry)
                return entry.name
            end,
            constant_font = "default-bold"
        },
        {
            name = "compost",
            localised_name = {"item-name.humus"},
            content = function(entry)
                return entry.humus
            end,
            order = function(entry)
                return entry.humus
            end,
            alignment = "center"
        },
        {
            name = "mold",
            localised_name = {"city-view.produces-mold"},
            content = function(entry)
                return entry.mold and "✔" or ""
            end,
            order = function(entry)
                return entry.mold and 1 or 0
            end,
            alignment = "center"
        }
    }
}

Gui.CityView.add_page {
    name = "compost",
    category = "data",
    localised_name = {"city-view.composting-text1"},
    creator = function(container)
        Gui.Elements.Label.heading_1(container, {"city-view.compostables-head"})
        Gui.Elements.SortableList.create(container, "compostables")
    end
}
