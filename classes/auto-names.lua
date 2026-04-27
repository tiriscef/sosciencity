local EK = require("enums.entry-key")

AutoNames = {}

local generators = {}

--- Generates and stores an auto-name for the given entry using the named scheme.
--- @param scheme string
--- @param entry Entry
function AutoNames.generate(scheme, entry)
    local generator = generators[scheme]
    if generator then
        entry[EK.custom_name] = generator(entry)
    end
end

---------------------------------------------------------------------------------------------------
-- << nightclub >>

local nightclub_names = {
    "The Accumulator",
    "Neon Smelter",
    "The Productivity Module",
    "The Bass Module",
    "Club Inserter",
    "The Electric Furnace",
    "Steam Works",
    "The Blue Belt",
    "Midnight Assembly",
    "The Void",
    "The Signal Loss",
    "Coal & Cocktails",
    "Hot Metal",
    "The Fuel Cell",
    "Bass & Bottleneck",
    "The Science Pack",
    "The Oil Drum",
    "The Late Shift",
    "Zero Productivity",
    "The Research Break",
    "The Crash Landing",
    "Planet B",
    "The Desolation Lounge",
    "The Lag Spike",
    "Pollution & Chill",
    "Club Penguin",
    "Club Automation",
    "Club Overflow",
    "The Gas Leak",
    "Productivity Zero",
    "Nuclear Dance Floor",
    "Antimatter Explosion",
    "Critical Mass",
    "The Megabase",
    "Maximum Throughput",
    "The Gigawatt",
    "Reactor Core",
    "The Shockwave",
    "Ground Zero",
    "The Cascade",
    "Fusion Ignition",
    "The Power Surge",
    "Infinite Fusion",
    "The Sabotage"
}

generators["nightclub"] = function(_entry)
    return nightclub_names[math.random(#nightclub_names)]
end

---------------------------------------------------------------------------------------------------
-- << ember HQ >>

local ember_hq_names = {
    "The Ember Collective",
    "The Ember Exchange",
    "The Ember Academy",
    "The Cultural Forge",
    "The Grand Ember Hall",
    "Cinder Studios",
    "The Institute of Ember Arts",
    "The Ministry of Culture",
    "Flameworks Studio",
    "The Shack",
    "The Tin Can",
    "The Leaky Roof",
    "The Fire Hazard",
    "Our Spot",
    "The Good Enough",
    "The Corner",
    "Ember HQ (Temporary)",
    "Still Going",
    "The Extended Break",
    "Conference Room B to C",
    "The Team Building",
    "The Brainstorm",
    "The Clocked-Out Collective",
}

generators["ember-hq"] = function(_entry)
    return ember_hq_names[math.random(#ember_hq_names)]
end

---------------------------------------------------------------------------------------------------
-- << kitchen for all >>

local kitchen_for_all_names = {
    "Progreszive Diner",
    "The Food Produkzion",
    "Masz Produkzion Kitchen",
    "The Mesz",
    "Publik Diner",
    "Klasz Struggle Kitchen",
    "Sozial Eating",
    "The Komunal Pot",
    "Zolidarity Soup",
    "Kalorie Throughput",
    "Cooked with Love",
    "Nutrizion Stazion",
    "Komunity Mealz",
    "The Graszroots Grill",
    "Paszionate Cooking",
    "Sustainable Eatz",
    "Masz Appeal Diner",
    "Folx Kitchen",
    "The Worxshop",
    "Nutrizion Basix",
    "Snax for All",
    "Legume Lagoon",
    "The Burrowed Stove",
    "Lost and Found Ingredienz",
    "The Konsensus Kitchen",
    "Still in Diskuszion",
    "Chickpea Zentral",
    "Tofu Towerz",
    "Rice and Shine",
    "The Open Diner",
}

generators["kitchen-for-all"] = function(_entry)
    return kitchen_for_all_names[math.random(#kitchen_for_all_names)]
end

return AutoNames
