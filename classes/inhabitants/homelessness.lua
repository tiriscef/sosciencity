local EK = require("enums.entry-key")
local LossCause = require("enums.loss-cause")
local Type = require("enums.type")
local WarningType = require("enums.warning-type")

local Buildings = require("constants.buildings")
local Castes = require("constants.castes")
local Housing = require("constants.housing")

local castes = Castes.values
local get_building_details = Buildings.get
local get_housing_details = Housing.get
local try_get = Register.try_get
local Utils = Tirislib.Utils
local ceil = math.ceil
local random = math.random

local try_add_to_house -- set during load

---------------------------------------------------------------------------------------------------
-- << lifecycle >>

function Inhabitants.init_homelessness()
    storage.homeless = {}
    for _, caste in pairs(Castes.all) do
        storage.homeless[caste.type] = InhabitantGroup.new(caste.type)
    end
end

function Inhabitants.load_homelessness()
    try_add_to_house = Inhabitants.try_add_to_house
end

---------------------------------------------------------------------------------------------------
-- << homeless inhabitants >>

--- Tries to distribute all homeless inhabitants to official (non-improvised) free houses.
local function distribute_inhabitants(group)
    return Inhabitants.distribute(group, false)
end

--- Tries to move all homeless inhabitants into existing free caste houses.
local function try_house_homeless()
    for _, group in pairs(storage.homeless) do
        distribute_inhabitants(group)
    end
end
Inhabitants.try_house_homeless = try_house_homeless

--- Tries to convert empty (unassigned) houses to caste houses and move homeless inhabitants in.
--- Picks the best-quality houses first.
local function try_occupy_empty_housing()
    for caste_id, group in pairs(storage.homeless) do
        if group[EK.inhabitants] == 0 then
            goto continue
        end

        -- find and sort the empty houses
        local empty_houses = {}

        for _, empty_house in Register.iterate_type(Type.empty_house) do
            if empty_house[EK.is_liveable] and Housing.allowes_caste(get_housing_details(empty_house), caste_id) then
                empty_houses[#empty_houses + 1] = empty_house
            end
        end

        if #empty_houses == 0 then
            goto continue
        end

        table.sort(
            empty_houses,
            function(house1, house2)
                local housing_details1 = get_housing_details(house1)
                local housing_details2 = get_housing_details(house2)

                return Inhabitants.evaluate_housing_traits(housing_details1, castes[caste_id]) +
                    housing_details1.comfort >
                    Inhabitants.evaluate_housing_traits(housing_details2, castes[caste_id]) +
                        housing_details2.comfort
            end
        )

        -- try to distribute the inhabitants
        for _, current_house in pairs(empty_houses) do
            local new_entry = Inhabitants.try_allow_for_caste(current_house, caste_id, true)
            if new_entry then
                try_add_to_house(new_entry, group)
            end

            if group[EK.inhabitants] == 0 then
                break
            end
        end

        ::continue::
    end
end
Inhabitants.try_occupy_empty_housing = try_occupy_empty_housing

--- Creates improvised huts near markets with food for homeless inhabitants.
local function create_improvised_huts()
    for caste_id, group in pairs(storage.homeless) do
        for _, market in Register.iterate_type(Type.market) do
            if not Entity.market_has_food(market) then
                goto continue
            end

            local entity = market[EK.entity]
            local position = entity.position
            local surface = entity.surface
            local range = get_building_details(market).range

            local bounding_box = Utils.get_range_bounding_box(position, range)

            while group[EK.inhabitants] > 0 do
                -- improvised huts are 4x4 entities
                -- we look for positions of composting-silo, because it is a 6x6 entity, so there will be a
                -- 1 tile margin for a random offset
                local pos = surface.find_non_colliding_position_in_box("composting-silo", bounding_box, 1, true)
                if not pos then
                    break
                end
                Utils.add_random_offset(pos, 1)

                local hut_to_create = Housing.huts[random(#Housing.huts)]
                local new_hut =
                    surface.create_entity {
                    name = hut_to_create.name,
                    position = pos,
                    force = "player",
                    create_build_effect_smoke = false
                }
                local entry = Register.add(new_hut, caste_id)

                try_add_to_house(entry, group)
            end

            ::continue::
        end
    end
end

--- Adds the given InhabitantGroup to the global homeless pool and immediately tries to house them.
--- @param group InhabitantGroup
local function add_to_homeless_pool(group)
    local caste_id = group[EK.type]
    InhabitantGroup.merge(storage.homeless[caste_id], group)
    try_house_homeless()
end
Inhabitants.add_to_homeless_pool = add_to_homeless_pool

--- Main homelessness update: tries to house homeless, occupy empty houses, create improvised huts.
--- Applies negative effects (happiness/health/sanity decay, disappearance) to remaining homeless.
local function update_homelessness()
    -- try to house the homeless people
    try_house_homeless()
    try_occupy_empty_housing()
    create_improvised_huts()

    -- apply effects to the remaining guys
    for caste_id, homeless_group in pairs(storage.homeless) do
        local count = homeless_group[EK.inhabitants]

        if count > 0 then
            Communication.warning(WarningType.homelessness, caste_id)
        end

        -- converge happiness/health/sanity toward 0 for homeless
        local current_happiness = homeless_group[EK.happiness]
        homeless_group[EK.happiness] = current_happiness + (0 - current_happiness) * (1 - 0.9995 ^ 1800)

        local current_health = homeless_group[EK.health]
        homeless_group[EK.health] = current_health + (0 - current_health) * (1 - 0.9999 ^ 1800)

        local current_sanity = homeless_group[EK.sanity]
        homeless_group[EK.sanity] = current_sanity + (0 - current_sanity) * (1 - 0.99995 ^ 1800)

        local disappearing = ceil(count * 0.05)
        if disappearing > 0 then
            local lost = InhabitantGroup.take(homeless_group, disappearing)
            Communication.report_loss(lost[EK.inhabitants], LossCause.homeless)
        end
    end
end
Inhabitants.update_homelessness = update_homelessness
