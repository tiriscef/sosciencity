local EK = require("enums.entry-key")
local Type = require("enums.type")

local Helpers = require("tests.integration.helpers")
local Assert = Tirislib.Testing.Assert

local test_surface

-- test-market has Type.market with range 42, subscribes to all caste types bidirectionally
-- test-dumpster has Type.dumpster with range 42, subscribes to all caste types bidirectionally
-- test-water-distributer has Type.water_distributer with range 42, subscribes to all caste types (to_neighbor)
-- test-house has Type.empty_house, subscribes to market/water_distributer/dumpster/etc.
-- When both subscribe to each other bidirectionally, placing either one should establish the connection.

Tirislib.Testing.add_test_case(
    "Nearby entities with mutual subscriptions become neighbors",
    "integration|integration.neighborhood",
    function()
        -- test-house subscribes to market (bidirectional), market subscribes to all castes (bidirectional)
        -- test-house also subscribes to market bidirectionally
        local house = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        local market = Helpers.create_and_register(test_surface, "test-market", {5, 0})

        -- house should see market as a neighbor
        local house_market_count = Neighborhood.get_neighbor_count(house, Type.market)
        Assert.equals(house_market_count, 1, "house should have 1 market neighbor")

        -- market subscribes to caste types, not empty_house - so it won't see the house
        -- (empty_house is Type 0, market subscribes to clockwork/orchid/etc.)
        local market_house_count = Neighborhood.get_neighbor_count(market, Type.empty_house)
        Assert.equals(market_house_count, 0, "market does not subscribe to empty_house type")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Entities out of range do not become neighbors",
    "integration|integration.neighborhood",
    function()
        -- test-market has range 42, place house far away
        local house = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        local market = Helpers.create_and_register(test_surface, "test-market", {80, 0})

        local house_market_count = Neighborhood.get_neighbor_count(house, Type.market)
        Assert.equals(house_market_count, 0, "house should have no market neighbor when out of range")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Multiple neighbors of same type are all discovered",
    "integration|integration.neighborhood",
    function()
        local house = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        local market1 = Helpers.create_and_register(test_surface, "test-market", {5, 0})
        local market2 = Helpers.create_and_register(test_surface, "test-market", {-5, 0})

        local house_market_count = Neighborhood.get_neighbor_count(house, Type.market)
        Assert.equals(house_market_count, 2, "house should see both markets")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Removing a neighbor is reflected in neighbor count (lazy validation)",
    "integration|integration.neighborhood",
    function()
        local house = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        local market = Helpers.create_and_register(test_surface, "test-market", {5, 0})

        Assert.equals(Neighborhood.get_neighbor_count(house, Type.market), 1)

        Helpers.destroy_entry(market)

        -- Neighborhood uses lazy validation: the neighbor is cleaned up on next access
        Assert.equals(Neighborhood.get_neighbor_count(house, Type.market), 0,
            "neighbor count should be 0 after market is removed")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Entity placed after subscriber still gets discovered",
    "integration|integration.neighborhood",
    function()
        -- Place the house first, then the market
        -- The market's establish_new_neighbor should notify the house's subscription
        local house = Helpers.create_and_register(test_surface, "test-house", {0, 0})

        Assert.equals(Neighborhood.get_neighbor_count(house, Type.market), 0, "no markets yet")

        local market = Helpers.create_and_register(test_surface, "test-market", {5, 0})

        Assert.equals(Neighborhood.get_neighbor_count(house, Type.market), 1,
            "house should discover market placed after it")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Entities on different surfaces do not become neighbors",
    "integration|integration.neighborhood",
    function()
        local surface2 = Helpers.create_test_surface("sosciencity-integration-test-2")

        local house = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        local market = Helpers.create_and_register(surface2, "test-market", {5, 0})

        Assert.equals(Neighborhood.get_neighbor_count(house, Type.market), 0,
            "entities on different surfaces should not be neighbors")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "iterate_type returns all valid neighbors",
    "integration|integration.neighborhood",
    function()
        local house = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        local market1 = Helpers.create_and_register(test_surface, "test-market", {5, 0})
        local market2 = Helpers.create_and_register(test_surface, "test-market", {-5, 0})

        local found_units = {}
        for unit_number, entry in Neighborhood.iterate_type(house, Type.market) do
            found_units[unit_number] = true
        end

        Assert.is_true(found_units[market1[EK.unit_number]] == true, "should find market1")
        Assert.is_true(found_units[market2[EK.unit_number]] == true, "should find market2")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Neighborhood.get_by_type returns entry objects",
    "integration|integration.neighborhood",
    function()
        local house = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        local market = Helpers.create_and_register(test_surface, "test-market", {5, 0})

        local neighbors = Neighborhood.get_by_type(house, Type.market)
        Assert.equals(#neighbors, 1, "should return 1 neighbor")
        Assert.equals(neighbors[1][EK.unit_number], market[EK.unit_number], "should be the market")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)

Tirislib.Testing.add_test_case(
    "Multiple subscription types work independently",
    "integration|integration.neighborhood",
    function()
        -- houses subscribe to market, water_distributer, dumpster, etc.
        local house = Helpers.create_and_register(test_surface, "test-house", {0, 0})
        local market = Helpers.create_and_register(test_surface, "test-market", {5, 0})
        local dumpster = Helpers.create_and_register(test_surface, "test-dumpster", {-5, 0})

        Assert.equals(Neighborhood.get_neighbor_count(house, Type.market), 1, "should have 1 market")
        Assert.equals(Neighborhood.get_neighbor_count(house, Type.dumpster), 1, "should have 1 dumpster")

        -- removing market should not affect dumpster
        Helpers.destroy_entry(market)
        Assert.equals(Neighborhood.get_neighbor_count(house, Type.market), 0, "market gone")
        Assert.equals(Neighborhood.get_neighbor_count(house, Type.dumpster), 1, "dumpster still there")
    end,
    function()
        test_surface = Helpers.create_test_surface()
    end,
    function()
        Helpers.clean_up()
    end
)
