local EK = require("enums.entry-key")

local Castes = require("constants.castes")
local Housing = require("constants.housing")

local get_housing_details = Housing.get
local get_free_capacity = Housing.get_free_capacity
local try_get = Register.try_get
local min = math.min

---------------------------------------------------------------------------------------------------
-- << lifecycle >>

function Inhabitants.init_housing_management()
    storage.free_houses = {
        [true] = Tirislib.LazyLuaq.from(Castes.all)
            :select(function(caste) return {}, caste.type end)
            :to_table(),
        [false] = Tirislib.LazyLuaq.from(Castes.all)
            :select(function(caste) return {}, caste.type end)
            :to_table()
    }
end

---------------------------------------------------------------------------------------------------
-- << housing space management >>

--- Updates whether this house is tracked as having free capacity.
--- @param entry Entry
local function update_free_space_status(entry)
    local caste_id = entry[EK.type]
    local unit_number = entry[EK.unit_number]
    local is_improvised = get_housing_details(entry).is_improvised

    if get_free_capacity(entry) > 0 then
        storage.free_houses[is_improvised][caste_id][unit_number] = unit_number
    else
        storage.free_houses[is_improvised][caste_id][unit_number] = nil
    end
end
Inhabitants.update_free_space_status = update_free_space_status

--- Tries to add the specified amount of inhabitants to the house-entry.
--- Returns the number of inhabitants that were added.
--- @param entry Entry
--- @param group InhabitantGroup
--- @param silent boolean?
--- @return integer count of inhabitants added
local function try_add_to_house(entry, group, silent)
    local count_moving_in = min(group[EK.inhabitants], get_free_capacity(entry))

    if count_moving_in == 0 then
        return 0
    end

    InhabitantGroup.merge_partially(entry, group, count_moving_in)
    update_free_space_status(entry)

    if not silent then
        Communication.create_flying_text(entry, {"sosciencity.inhabitants-moved-in", count_moving_in})
    end

    return count_moving_in
end
Inhabitants.try_add_to_house = try_add_to_house

--- Distributes the given group to free houses, sorted by descending housing priority.
--- @param group InhabitantGroup
--- @param to_improvised boolean whether to distribute to improvised houses
--- @return integer count of inhabitants distributed
local function distribute(group, to_improvised)
    local count_before = group[EK.inhabitants]
    local caste_id = group[EK.type]

    local query =
        Tirislib.LazyLuaq.from(storage.free_houses[to_improvised][caste_id]):choose(
        function(unit_number)
            local entry = try_get(unit_number)
            return entry ~= nil, entry
        end
    ):order_by_descending(
        function(house)
            return house[EK.housing_priority]
        end
    )

    local to_distribute = count_before
    for _, house in query:iterate() do
        to_distribute = to_distribute - try_add_to_house(house, group)

        if to_distribute == 0 then
            break
        end
    end

    return count_before - to_distribute
end
Inhabitants.distribute = distribute
