local DiseaseCategory = require("enums.disease-category")
local EK = require("enums.entry-key")
local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface
local HEALTHY = DiseaseGroup.HEALTHY

local function setup()
    test_surface = Helpers.create_test_surface()
    Helpers.reset_inhabitants_state()
    storage.technologies["upbringing"] = 1
end

local function teardown()
    Helpers.clean_up()
end

--- Returns the total number of sick inhabitants in the disease group.
local function count_sick(disease_group)
    local sick = 0
    for id, count in pairs(disease_group) do
        if id ~= HEALTHY then
            sick = sick + count
        end
    end
    return sick
end

--- Creates a house with default good conditions and zeroed disease progress.
--- @param position table
--- @param count integer
--- @return Entry
local function create_healthy_house(position, count)
    local entry = Helpers.create_inhabited_house(test_surface, position, Type.clockwork, count)
    entry[EK.has_food] = true
    entry[EK.has_water] = true
    entry[EK.health] = 10
    entry[EK.sanity] = 10
    for category in pairs(entry[EK.disease_progress]) do
        entry[EK.disease_progress][category] = 0
    end
    return entry
end

---------------------------------------------------------------------------------------------------
-- << disease progress: malnutrition and dehydration >>

Tirislib.Testing.add_test_case(
    "Lacking food increases malnutrition disease progress",
    "integration|integration.healthcare",
    function()
        local entry = create_healthy_house({0, 0}, 10)
        entry[EK.has_food] = false

        local progress_before = entry[EK.disease_progress][DiseaseCategory.malnutrition]
        Inhabitants.update_diseases(entry, 100)
        local progress_after = entry[EK.disease_progress][DiseaseCategory.malnutrition]

        Assert.greater_than(progress_after, progress_before, "malnutrition progress should increase when food is lacking")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Having food does not increase malnutrition disease progress",
    "integration|integration.healthcare",
    function()
        local entry = create_healthy_house({0, 0}, 10)

        Inhabitants.update_diseases(entry, 100)

        Assert.equals(entry[EK.disease_progress][DiseaseCategory.malnutrition], 0, "malnutrition progress should stay 0 when food is available")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Lacking water increases dehydration disease progress",
    "integration|integration.healthcare",
    function()
        local entry = create_healthy_house({0, 0}, 10)
        entry[EK.has_water] = false

        local progress_before = entry[EK.disease_progress][DiseaseCategory.dehydration]
        Inhabitants.update_diseases(entry, 100)
        local progress_after = entry[EK.disease_progress][DiseaseCategory.dehydration]

        Assert.greater_than(progress_after, progress_before, "dehydration progress should increase when water is lacking")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Having water does not increase dehydration disease progress",
    "integration|integration.healthcare",
    function()
        local entry = create_healthy_house({0, 0}, 10)

        Inhabitants.update_diseases(entry, 100)

        Assert.equals(entry[EK.disease_progress][DiseaseCategory.dehydration], 0, "dehydration progress should stay 0 when water is available")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << disease progress: health and sanity >>

Tirislib.Testing.add_test_case(
    "Low health increases health disease progress",
    "integration|integration.healthcare",
    function()
        local entry = create_healthy_house({0, 0}, 10)
        entry[EK.health] = 0

        local progress_before = entry[EK.disease_progress][DiseaseCategory.health]
        Inhabitants.update_diseases(entry, 100)
        local progress_after = entry[EK.disease_progress][DiseaseCategory.health]

        Assert.greater_than(progress_after, progress_before, "health disease progress should increase when health is low")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Low sanity increases sanity disease progress",
    "integration|integration.healthcare",
    function()
        local entry = create_healthy_house({0, 0}, 10)
        entry[EK.sanity] = 0

        local progress_before = entry[EK.disease_progress][DiseaseCategory.sanity]
        Inhabitants.update_diseases(entry, 100)
        local progress_after = entry[EK.disease_progress][DiseaseCategory.sanity]

        Assert.greater_than(progress_after, progress_before, "sanity disease progress should increase when sanity is low")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << disease progress: accidents >>

Tirislib.Testing.add_test_case(
    "Low health and sanity increase accident disease progress",
    "integration|integration.healthcare",
    function()
        local entry = create_healthy_house({0, 0}, 10)
        entry[EK.health] = 0
        entry[EK.sanity] = 0

        local progress_before = entry[EK.disease_progress][DiseaseCategory.accident]
        Inhabitants.update_diseases(entry, 100)
        local progress_after = entry[EK.disease_progress][DiseaseCategory.accident]

        Assert.greater_than(progress_after, progress_before, "accident disease progress should increase when health and sanity are low")
    end,
    setup,
    teardown
)

---------------------------------------------------------------------------------------------------
-- << disease creation with large delta_ticks >>

Tirislib.Testing.add_test_case(
    "Bad conditions eventually cause diseases",
    "integration|integration.healthcare",
    function()
        local entry = create_healthy_house({0, 0}, 50)
        entry[EK.has_food] = false
        entry[EK.has_water] = false
        entry[EK.health] = 0
        entry[EK.sanity] = 0

        Inhabitants.update_diseases(entry, 100000)

        Assert.greater_than(count_sick(entry[EK.diseases]), 0, "bad conditions should eventually cause diseases")
    end,
    setup,
    teardown
)

Tirislib.Testing.add_test_case(
    "Good conditions produce fewer diseases than bad conditions",
    "integration|integration.healthcare",
    function()
        local bad_entry = create_healthy_house({0, 0}, 50)
        bad_entry[EK.has_food] = false
        bad_entry[EK.has_water] = false
        bad_entry[EK.health] = 0
        bad_entry[EK.sanity] = 0

        local good_entry = create_healthy_house({10, 0}, 50)

        Inhabitants.update_diseases(bad_entry, 100000)
        Inhabitants.update_diseases(good_entry, 100000)

        local bad_sick = count_sick(bad_entry[EK.diseases])
        local good_sick = count_sick(good_entry[EK.diseases])

        Assert.greater_than(bad_sick, good_sick, "bad conditions should produce more disease cases than good conditions")
    end,
    setup,
    teardown
)
