local EK = require("enums.entry-key")

local Castes = require("constants.castes")
local Diseases = require("constants.diseases")
local Housing = require("constants.housing")
local InhabitantsConstants = require("constants.inhabitants")
local Type = require("enums.type")

local get_housing_details = Housing.get
local get_free_capacity = Housing.get_free_capacity
local try_get = Register.try_get
local floor = math.floor
local max = math.max
local min = math.min
local HEALTHY = DiseaseGroup.HEALTHY
local disease_values = Diseases.values
local transport_eligibility_threshold = InhabitantsConstants.transport_eligibility_threshold
local hospital_types = {Type.hospital, Type.improvised_hospital}

-- Entity is loaded after Inhabitants, so this is resolved lazily at call time
local function hospital_can_treat(hospital, disease_id)
    return Entity.hospital_can_treat(hospital, disease_id)
end

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
    storage.transport_eligible_houses = Tirislib.LazyLuaq.from(Castes.all)
        :select(function(caste) return {}, caste.type end)
        :to_table()
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
    ):order_by(
        function(house)
            return house[EK.is_sanatorium] and 1 or 0
        end
    ):then_by_descending(
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

---------------------------------------------------------------------------------------------------
-- << transport eligibility >>

--- Updates whether this house is in storage.transport_eligible_houses.
--- A house is eligible when it has at least one treatable unclaimed disease over the threshold.
--- @param entry Entry
local function update_transport_eligible_status(entry)
    local unit_number = entry[EK.unit_number]
    local caste_id = entry[EK.type]
    local ticks = entry[EK.unclaimed_disease_ticks]

    local eligible = false
    if ticks then
        for _, tick_count in pairs(ticks) do
            if tick_count >= transport_eligibility_threshold then
                eligible = true
                break
            end
        end
    end

    storage.transport_eligible_houses[caste_id][unit_number] = eligible or nil
end
Inhabitants.update_transport_eligible_status = update_transport_eligible_status

--- Updates the unclaimed disease tick counters for a housing entry and refreshes transport eligibility.
--- Call this once per disease update cycle.
--- @param entry Entry
--- @param delta_ticks integer
local function update_unclaimed_disease_ticks(entry, delta_ticks)
    local diseases = entry[EK.diseases]
    if diseases[HEALTHY] == entry[EK.inhabitants] then
        -- fully healthy - clear timer and eligibility
        entry[EK.unclaimed_disease_ticks] = nil
        storage.transport_eligible_houses[entry[EK.type]][entry[EK.unit_number]] = nil
        return
    end

    local claims = entry[EK.treatment_claims]
    local ticks = entry[EK.unclaimed_disease_ticks] or {}
    local changed = false

    for disease_id, count in pairs(diseases) do
        if disease_id ~= HEALTHY and count > 0 and disease_values[disease_id].is_treatable then
            local is_claimed = claims and claims[disease_id] and #claims[disease_id] > 0
            if is_claimed then
                if ticks[disease_id] then
                    ticks[disease_id] = nil
                    changed = true
                end
            else
                ticks[disease_id] = (ticks[disease_id] or 0) + delta_ticks
                changed = true
            end
        else
            if ticks[disease_id] then
                ticks[disease_id] = nil
                changed = true
            end
        end
    end

    -- remove ticks for diseases that are no longer present
    for disease_id in pairs(ticks) do
        if not diseases[disease_id] or diseases[disease_id] == 0 then
            ticks[disease_id] = nil
            changed = true
        end
    end

    entry[EK.unclaimed_disease_ticks] = next(ticks) and ticks or nil

    if changed then
        update_transport_eligible_status(entry)
    end
end
Inhabitants.update_unclaimed_disease_ticks = update_unclaimed_disease_ticks

---------------------------------------------------------------------------------------------------
-- << sanatorium behavior >>

--- Returns whether any hospital neighbor of this sanatorium can treat the given disease.
--- @param sanatorium Entry
--- @param disease_id integer
--- @return boolean
local function sanatorium_can_treat_disease(sanatorium, disease_id)
    for _, hospital_type in pairs(hospital_types) do
        for _, hospital in Neighborhood.iterate_type(sanatorium, hospital_type) do
            if hospital_can_treat(hospital, disease_id) then
                return true
            end
        end
    end
    return false
end

--- Evicts all healthy inhabitants from a sanatorium to non-sanatorium free houses.
--- Healthy inhabitants that cannot be placed stay in the sanatorium.
--- @param entry Entry
local function evict_healthy_from_sanatorium(entry)
    local healthy = entry[EK.diseases][HEALTHY]
    if healthy == 0 then return end

    local caste_id = entry[EK.type]

    local query = Tirislib.LazyLuaq.from(storage.free_houses[false][caste_id]):choose(
        function(unit_number)
            local house = try_get(unit_number)
            return house ~= nil, house
        end
    ):order_by(
        function(house)
            return house[EK.is_sanatorium] and 1 or 0
        end
    ):then_by_descending(
        function(house)
            return house[EK.housing_priority]
        end
    )

    for _, house in query:iterate() do
        if house[EK.is_sanatorium] then break end
        if healthy == 0 then break end

        local capacity = get_free_capacity(house)
        if capacity == 0 then goto next_house end

        local to_move = min(healthy, capacity)
        local specific_diseases = {[HEALTHY] = to_move}
        local taken = InhabitantGroup.take_specific(entry, to_move, specific_diseases)
        InhabitantGroup.merge(house, taken)
        update_free_space_status(house)
        update_free_space_status(entry)
        Communication.create_flying_text(house, {"sosciencity.inhabitants-moved-in", to_move})
        healthy = healthy - to_move

        ::next_house::
    end
end

--- Pulls sick, transport-eligible inhabitants from anywhere in the city to fill this sanatorium.
--- Only pulls diseases that hospital neighbors of this sanatorium can treat.
--- @param entry Entry
local function pull_sick_to_sanatorium(entry)
    local free_capacity = get_free_capacity(entry)
    if free_capacity == 0 then return end

    local caste_id = entry[EK.type]
    local eligible_houses = storage.transport_eligible_houses[caste_id]

    for unit_number in pairs(eligible_houses) do
        if free_capacity == 0 then break end

        local source = try_get(unit_number)
        if not source then
            eligible_houses[unit_number] = nil
            goto next_house
        end

        -- collect diseases this sanatorium can actually treat
        local treatable_diseases = {}
        local treatable_count = 0
        for disease_id, count in pairs(source[EK.diseases]) do
            if disease_id ~= HEALTHY and count > 0 then
                if sanatorium_can_treat_disease(entry, disease_id) then
                    treatable_diseases[disease_id] = count
                    treatable_count = treatable_count + count
                end
            end
        end

        if treatable_count == 0 then goto next_house end

        local to_pull = min(treatable_count, free_capacity)

        if to_pull < treatable_count then
            local scale = to_pull / treatable_count
            local adjusted_count = 0
            for disease_id, count in pairs(treatable_diseases) do
                local adjusted = max(1, floor(count * scale))
                treatable_diseases[disease_id] = adjusted
                adjusted_count = adjusted_count + adjusted
            end
            to_pull = adjusted_count
        end

        local taken = InhabitantGroup.take_specific(source, to_pull, treatable_diseases)
        InhabitantGroup.merge(entry, taken)
        update_free_space_status(source)
        update_free_space_status(entry)
        Communication.create_flying_text(entry, {"sosciencity.inhabitants-moved-in", to_pull})

        update_transport_eligible_status(source)
        free_capacity = free_capacity - to_pull

        ::next_house::
    end
end

--- Runs sanatorium-specific behavior: evict healthy inhabitants, then pull transport-eligible sick ones.
--- Must be called at the beginning of update_house for sanatorium-flagged houses.
--- @param entry Entry
function Inhabitants.update_sanatorium(entry)
    evict_healthy_from_sanatorium(entry)
    pull_sick_to_sanatorium(entry)
end
