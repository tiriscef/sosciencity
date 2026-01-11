Gui.CityView.add_category("caste", {"sosciencity.caste"})

local Castes = require("constants.castes")
local Time = require("constants.time")

local function add_caste_infos(container, caste_id)
    local caste = Castes.values[caste_id]

    local centered_flow = Gui.Elements.Flow.horizontal_center(container)
    Gui.Elements.Sprite.create_caste_sprite(centered_flow, caste_id, 256)

    Gui.Elements.Label.heading_1(container, caste.localised_name)
    Gui.Elements.Label.paragraph(container, {"technology-description." .. caste.name .. "-caste"})

    local caste_data = Gui.Elements.Datalist.create(container, "caste-infos")
    Gui.Elements.Datalist.add_kv_pair(
        caste_data,
        "taste",
        {"sosciencity.taste"},
        {
            "sosciencity.show-taste",
            Locale.taste_category(caste.favored_taste),
            Locale.taste_category(caste.least_favored_taste)
        }
    )
    Gui.Elements.Datalist.add_kv_pair(
        caste_data,
        "food-count",
        {"sosciencity.food-count"},
        {"sosciencity.show-food-count", caste.minimum_food_count}
    )
    Gui.Elements.Datalist.add_kv_pair(
        caste_data,
        "luxury",
        {"sosciencity.luxury"},
        {"sosciencity.show-luxury-needs", 100 * caste.desire_for_luxury, 100 * (1 - caste.desire_for_luxury)}
    )
    Gui.Elements.Datalist.add_kv_pair(
        caste_data,
        "room-count",
        {"sosciencity.room-needs"},
        {"sosciencity.show-room-needs", caste.required_room_count}
    )
    Gui.Elements.Datalist.add_kv_pair(
        caste_data,
        "power-demand",
        {"sosciencity.power-demand"},
        {"sosciencity.show-power-demand", caste.power_demand / 1000 * Time.second} -- convert from J / tick to kW
    )
    Gui.Elements.Datalist.add_kv_pair(
        caste_data,
        "water-demand",
        {"sosciencity.water"},
        {"sosciencity.show-water-demand", caste.water_demand * Time.minute}
    )

    local housing_flow = Gui.Elements.Datalist.add_kv_flow(caste_data, "housing-qualities", {"sosciencity.housing"})
    housing_flow.add {
            type = "label",
            name = "comfort",
            caption = {"sosciencity.show-comfort-needs", caste.minimum_comfort}
        }.style.single_line = false

    local prefered_flow =
        housing_flow.add {
        type = "flow",
        name = "prefered-qualities",
        direction = "vertical"
    }
    Gui.Elements.Datalist.add_key_label(prefered_flow, "header-prefered", {"sosciencity.prefered-qualities"})
    local disliked_flow =
        housing_flow.add {
        type = "flow",
        name = "disliked-qualities",
        direction = "vertical"
    }
    Gui.Elements.Datalist.add_key_label(disliked_flow, "header-disliked", {"sosciencity.disliked-qualities"})

    for quality, assessment in pairs(caste.housing_preferences) do
        local quality_flow
        if assessment > 0 then
            quality_flow = prefered_flow
        else
            quality_flow = disliked_flow
        end

        quality_flow.add {
            type = "label",
            name = quality,
            caption = {"", {"housing-quality." .. quality}, string.format(" (%+.1f)", assessment)},
            tooltip = {"housing-quality-description." .. quality}
        }
    end
end

for _, caste in pairs(Castes.all) do
    Gui.CityView.add_page {
        name = caste.name,
        category = "caste",
        localised_name = caste.localised_name_short,
        creator = function(container)
            add_caste_infos(container, caste.type)
        end,
        enabler = function()
            -- always show the first castes and the later ones once they are researched
            return (caste.tech_name == "upbringing") or (storage.technologies[caste.tech_name])
        end
    }
end
