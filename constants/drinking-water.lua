--- Things that people like (and need) to drink.
local DrinkingWater = {}

DrinkingWater.values = {
    ["clean-water"] = {
        health = 2
    },
    ["water"] = {
        health = -5
    },
    ["mechanically-cleaned-water"] = {
        health = -3
    },
    ["biologically-cleaned-water"] = {
        health = -1
    },
    ["ultra-pure-water"] = {
        health = 0
    }
}

return DrinkingWater
