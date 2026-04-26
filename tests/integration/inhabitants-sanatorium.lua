local EK = require("enums.entry-key")
local Type = require("enums.type")

local InhabitantsConstants = require("constants.inhabitants")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface
local HEALTHY = DiseaseGroup.HEALTHY

-- Disease 1: treatable, no special facility required
-- Disease 7: is_treatable = false
local TREATABLE_DISEASE = 1
local UNTREATABLE_DISEASE = 7
local THRESHOLD = InhabitantsConstants.transport_eligibility_threshold

local function setup()
    test_surface = Helpers.create_test_surface()
    Helpers.reset_inhabitants_state()
    storage.technologies["upbringing"] = 1
end

local function teardown()
    Helpers.clean_up()
end

local function create_house(position, count)
    local entry = Helpers.create_inhabited_house(test_surface, position, Type.clockwork, count)
    entry[EK.has_food] = true
    entry[EK.has_water] = true
    for category in pairs(entry[EK.disease_progress]) do
        entry[EK.disease_progress][category] = 0
    end
    return entry
end

local function make_sick(entry, disease_id, count)
    DiseaseGroup.make_sick(entry[EK.diseases], disease_id, count)
    entry[EK.inhabitants] = entry[EK.inhabitants]
end

---------------------------------------------------------------------------------------------------
-- << transport eligibility: unclaimed tick accumulation >>

Tirislib.Testing.add_test_case(
    "Treatable unclaimed disease accumulates unclaimed ticks",
    "integration|integration.sanatorium",
    function()
        local entry = create_house({0, 0}, 10)
        make_sick(entry, TREATABLE_DISEASE, 3)

        Inhabitants.update_unclaimed_disease_ticks(entry, 100)

        local ticks = entry[EK.unclaimed_disease_ticks]
        Assert.not_nil(ticks, "unclaimed_disease_ticks should be set")
        Assert.not_nil(ticks[TREATABLE_DISEASE], "treatable disease should accumulate ticks")
        Assert.equals(ticks[TREATABLE_DISEASE], 100, "tick count should equal delta_ticks passed")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Untreatable disease does not accumulate unclaimed ticks",
    "integration|integration.sanatorium",
    function()
        local entry = create_house({0, 0}, 10)
        make_sick(entry, UNTREATABLE_DISEASE, 3)

        Inhabitants.update_unclaimed_disease_ticks(entry, THRESHOLD + 1)

        local ticks = entry[EK.unclaimed_disease_ticks]
        local unit_number = entry[EK.unit_number]
        local caste_id = entry[EK.type]

        Assert.is_nil(ticks, "untreatable disease should not create unclaimed_disease_ticks")
        Assert.is_nil(storage.transport_eligible_houses[caste_id][unit_number], "untreatable disease should not enter registry")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "House enters transport eligible registry after threshold",
    "integration|integration.sanatorium",
    function()
        local entry = create_house({0, 0}, 10)
        make_sick(entry, TREATABLE_DISEASE, 3)

        Inhabitants.update_unclaimed_disease_ticks(entry, THRESHOLD + 1)

        local unit_number = entry[EK.unit_number]
        local caste_id = entry[EK.type]
        Assert.not_nil(storage.transport_eligible_houses[caste_id][unit_number], "house should be in transport_eligible_houses after threshold")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "House does not enter transport eligible registry before threshold",
    "integration|integration.sanatorium",
    function()
        local entry = create_house({0, 0}, 10)
        make_sick(entry, TREATABLE_DISEASE, 3)

        Inhabitants.update_unclaimed_disease_ticks(entry, THRESHOLD - 1)

        local unit_number = entry[EK.unit_number]
        local caste_id = entry[EK.type]
        Assert.is_nil(storage.transport_eligible_houses[caste_id][unit_number], "house should not be in transport_eligible_houses before threshold")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Fully healthy house clears transport eligible registry entry",
    "integration|integration.sanatorium",
    function()
        local entry = create_house({0, 0}, 10)
        make_sick(entry, TREATABLE_DISEASE, 3)
        Inhabitants.update_unclaimed_disease_ticks(entry, THRESHOLD + 1)

        -- cure all disease
        DiseaseGroup.cure(entry[EK.diseases], TREATABLE_DISEASE, 3)
        Inhabitants.update_unclaimed_disease_ticks(entry, 1)

        local unit_number = entry[EK.unit_number]
        local caste_id = entry[EK.type]
        Assert.is_nil(storage.transport_eligible_houses[caste_id][unit_number], "fully healthy house should be removed from transport_eligible_houses")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << sanatorium: healthy inhabitant eviction >>

Tirislib.Testing.add_test_case(
    "Sanatorium evicts healthy inhabitants to non-sanatorium houses",
    "integration|integration.sanatorium",
    function()
        local destination = create_house({0, 0}, 10)
        local sanatorium = create_house({5, 0}, 10)
        sanatorium[EK.is_sanatorium] = true

        -- give sanatorium 5 healthy + 5 sick
        make_sick(sanatorium, TREATABLE_DISEASE, 5)
        local healthy_before = sanatorium[EK.diseases][HEALTHY]
        local dest_inhabitants_before = destination[EK.inhabitants]

        Inhabitants.update_sanatorium(sanatorium)

        Assert.less_than(sanatorium[EK.diseases][HEALTHY], healthy_before, "sanatorium should have fewer healthy inhabitants after eviction")
        Assert.greater_than(destination[EK.inhabitants], dest_inhabitants_before, "destination house should have received evicted inhabitants")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Sanatorium healthy inhabitants stay when no non-sanatorium space is available",
    "integration|integration.sanatorium",
    function()
        local full_house = create_house({0, 0}, 200) -- create_house uses test-house with 200 rooms, fill it
        -- fill it completely by adding more inhabitants
        full_house[EK.inhabitants] = 200
        full_house[EK.diseases][HEALTHY] = 200
        Inhabitants.update_free_space_status(full_house)

        local sanatorium = create_house({5, 0}, 5)
        sanatorium[EK.is_sanatorium] = true
        local healthy_before = sanatorium[EK.diseases][HEALTHY]

        Inhabitants.update_sanatorium(sanatorium)

        Assert.equals(sanatorium[EK.diseases][HEALTHY], healthy_before, "healthy inhabitants should stay when no non-sanatorium house has free space")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Sanatorium does not evict healthy inhabitants to other sanatoriums",
    "integration|integration.sanatorium",
    function()
        local other_sanatorium = create_house({0, 0}, 10)
        other_sanatorium[EK.is_sanatorium] = true
        local other_inhabitants_before = other_sanatorium[EK.inhabitants]

        local sanatorium = create_house({5, 0}, 10)
        sanatorium[EK.is_sanatorium] = true
        make_sick(sanatorium, TREATABLE_DISEASE, 5)

        Inhabitants.update_sanatorium(sanatorium)

        Assert.equals(other_sanatorium[EK.inhabitants], other_inhabitants_before, "sanatorium should not evict to other sanatoriums")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << sanatorium: pulling transport-eligible sick inhabitants >>

Tirislib.Testing.add_test_case(
    "Sanatorium pulls transport-eligible sick inhabitants when hospital neighbor can treat",
    "integration|integration.sanatorium",
    function()
        -- hospital at center, sanatorium and outpost nearby
        local hospital_entity = Helpers.create_and_register(test_surface, "test-hospital", {0, 0})
        hospital_entity[EK.treatment_permissions] = {}
        hospital_entity[EK.active] = true

        local sanatorium = create_house({3, 0}, 0)
        sanatorium[EK.is_sanatorium] = true

        local outpost = create_house({6, 0}, 10)
        make_sick(outpost, TREATABLE_DISEASE, 5)

        -- manually make outpost transport-eligible
        local caste_id = outpost[EK.type]
        outpost[EK.unclaimed_disease_ticks] = {[TREATABLE_DISEASE] = THRESHOLD + 1}
        storage.transport_eligible_houses[caste_id][outpost[EK.unit_number]] = true

        local sanatorium_inhabitants_before = sanatorium[EK.inhabitants]
        local outpost_sick_before = outpost[EK.diseases][TREATABLE_DISEASE]

        Inhabitants.update_sanatorium(sanatorium)

        Assert.greater_than(sanatorium[EK.inhabitants], sanatorium_inhabitants_before, "sanatorium should have gained sick inhabitants")
        Assert.less_than(outpost[EK.diseases][TREATABLE_DISEASE] or 0, outpost_sick_before, "outpost should have fewer sick inhabitants after pull")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Sanatorium does not pull when no hospital neighbor is present",
    "integration|integration.sanatorium",
    function()
        local sanatorium = create_house({0, 0}, 0)
        sanatorium[EK.is_sanatorium] = true

        local outpost = create_house({5, 0}, 10)
        make_sick(outpost, TREATABLE_DISEASE, 5)

        local caste_id = outpost[EK.type]
        outpost[EK.unclaimed_disease_ticks] = {[TREATABLE_DISEASE] = THRESHOLD + 1}
        storage.transport_eligible_houses[caste_id][outpost[EK.unit_number]] = true

        Inhabitants.update_sanatorium(sanatorium)

        Assert.equals(sanatorium[EK.inhabitants], 0, "sanatorium without hospital neighbor should not pull sick inhabitants")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << distribution sort: sanatoriums last >>

Tirislib.Testing.add_test_case(
    "Normal distribution fills non-sanatorium houses before sanatoriums",
    "integration|integration.sanatorium",
    function()
        -- sanatorium has higher priority but should receive inhabitants last
        local normal_house = create_house({0, 0}, 0)
        normal_house[EK.housing_priority] = 1

        local sanatorium = create_house({5, 0}, 0)
        sanatorium[EK.is_sanatorium] = true
        sanatorium[EK.housing_priority] = 100

        Inhabitants.update_free_space_status(normal_house)
        Inhabitants.update_free_space_status(sanatorium)

        local immigrants = InhabitantGroup.new_immigrant_group(Type.clockwork, 5)
        Inhabitants.distribute(immigrants, false)

        Assert.greater_than(normal_house[EK.inhabitants], 0, "normal house should receive inhabitants despite lower priority than sanatorium")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Normal distribution fills sanatorium as last resort when no other space",
    "integration|integration.sanatorium",
    function()
        local sanatorium = create_house({0, 0}, 0)
        sanatorium[EK.is_sanatorium] = true
        Inhabitants.update_free_space_status(sanatorium)

        local immigrants = InhabitantGroup.new_immigrant_group(Type.clockwork, 5)
        Inhabitants.distribute(immigrants, false)

        Assert.greater_than(sanatorium[EK.inhabitants], 0, "sanatorium should accept inhabitants when it is the only available house")
    end,
    setup,
    teardown
)
