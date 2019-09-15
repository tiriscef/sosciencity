local energy_density_fat = 900 -- kcal per g
local energy_density_carbohydrates = 400
local energy_density_proteins = 370

--[[
    fat, carbohydrates and proteins are in g
]]
food_values = {
    ["potato"] = {
        fat = 1,
        carbohydrates = 1500,
        proteins = 190,
        healthiness = 1,
        food_category = "organic",
        taste_category = "umami",
        taste_quality = 1,
        luxority = 0
    }
}

for _, value in pairs(food_values) do
    value.fat = value.fat * energy_density_fat
    value.carbohydrates = value.carbohydrates * energy_density_carbohydrates
    value.proteins = value.proteins * energy_density_proteins
end
