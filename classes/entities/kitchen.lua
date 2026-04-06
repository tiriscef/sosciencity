local EK = require("enums.entry-key")
local Type = require("enums.type")

local Buildings = require("constants.buildings")
local Castes = require("constants.castes")

local get_building_details = Buildings.get
local set_active = Entity.set_active

local function update_kitchen_for_all(entry)
    local definition = get_building_details(entry)

    local inhabitants =
        Tirislib.LazyLuaq.from(Castes.all)
        :select_many(
            function(caste)
                return Neighborhood.get_by_type(entry, caste.type)
            end
        )
        :select_key(EK.inhabitants)
        :sum()

    local other_kitchens =
        Tirislib.LazyLuaq.from(Neighborhood.get_by_type(entry, Type.kitchen_for_all))
        :where_key(EK.active)
        :count()

    local participating_inhabitants = inhabitants / (other_kitchens + 1)
    local enough_inhabitants = participating_inhabitants > definition.inhabitant_count
    set_active(
        entry,
        enough_inhabitants,
        {diode = defines.entity_status_diode.red, label = {"sosciencity.not-enough-people"}}
    )

    entry[EK.participating_inhabitants] = participating_inhabitants
    entry[EK.active] = enough_inhabitants and entry[EK.entity].status == defines.entity_status.working
end
Register.set_entity_updater(Type.kitchen_for_all, update_kitchen_for_all)

Register.set_entity_creation_handler(
    Type.kitchen_for_all,
    function(entry)
        entry[EK.participating_inhabitants] = 0
    end
)
