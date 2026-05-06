local TechEffects = require("constants.tech-effects")

local factors = TechEffects.moving_efficiency_factors
local fractions = TechEffects.redistribution_budget_fractions
local floor = math.floor

local function moving_pct(level)
    return tostring(floor((1 - factors[level]) * 100))
end

local function budget_pct(level)
    return tostring(floor(fractions[level] * 100))
end

Tirislib.Technology.create {
    name = "moving-efficiency-1",
    icon = "__sosciencity-graphics__/graphics/icon/infrastructure.png",
    icon_size = 128,
    prerequisites = {"logistic-science-pack", "infrastructure-2"},
    localised_description = {"technology-description.moving-efficiency", moving_pct(1)},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.moving-efficiency", moving_pct(1)}
        }
    },
    unit = {
        count = 75,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1}
        },
        time = 20
    }
}

Tirislib.Technology.create {
    name = "moving-efficiency-2",
    icon = "__sosciencity-graphics__/graphics/icon/infrastructure.png",
    icon_size = 128,
    prerequisites = {"moving-efficiency-1", "production-science-pack"},
    localised_description = {"technology-description.moving-efficiency", moving_pct(2)},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.moving-efficiency", moving_pct(2)}
        }
    },
    unit = {
        count = 200,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1}
        },
        time = 45
    }
}

Tirislib.Technology.create {
    name = "moving-efficiency-3",
    icon = "__sosciencity-graphics__/graphics/icon/infrastructure.png",
    icon_size = 128,
    prerequisites = {"moving-efficiency-2", "utility-science-pack"},
    localised_description = {"technology-description.moving-efficiency", moving_pct(3)},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.moving-efficiency", moving_pct(3)}
        }
    },
    unit = {
        count = 300,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1}
        },
        time = 60
    }
}

Tirislib.Technology.create {
    name = "passive-redistribution",
    icon = "__sosciencity-graphics__/graphics/icon/infrastructure.png",
    icon_size = 128,
    prerequisites = {"moving-efficiency-1", "infrastructure-3", "chemical-science-pack"},
    localised_description = {"technology-description.passive-redistribution", budget_pct(0)},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.passive-redistribution", budget_pct(0)}
        }
    },
    unit = {
        count = 200,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1}
        },
        time = 30
    }
}

Tirislib.Technology.create {
    name = "redistribution-efficiency-1",
    icon = "__sosciencity-graphics__/graphics/icon/infrastructure.png",
    icon_size = 128,
    prerequisites = {"passive-redistribution", "production-science-pack"},
    localised_description = {"technology-description.redistribution-efficiency", budget_pct(1)},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.redistribution-efficiency", budget_pct(1)}
        }
    },
    unit = {
        count = 250,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1}
        },
        time = 45
    }
}

Tirislib.Technology.create {
    name = "redistribution-efficiency-2",
    icon = "__sosciencity-graphics__/graphics/icon/infrastructure.png",
    icon_size = 128,
    prerequisites = {"redistribution-efficiency-1", "utility-science-pack"},
    localised_description = {"technology-description.redistribution-efficiency", budget_pct(2)},
    effects = {
        {
            type = "nothing",
            effect_description = {"description.redistribution-efficiency", budget_pct(2)}
        }
    },
    unit = {
        count = 350,
        ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack", 1},
            {"chemical-science-pack", 1},
            {"production-science-pack", 1},
            {"utility-science-pack", 1}
        },
        time = 60
    }
}
