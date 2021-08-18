require("constants.food")

local function get_result_calories(recipe)
    local result = recipe:get_first_result()
    local food_values = Food.values[result]

    if food_values ~= nil then
        local count_normal, count_expensive = recipe:get_result_count(result)
        count_expensive = count_expensive or count_normal
        count_normal = count_normal * Food.values[result].calories
        count_expensive = count_expensive * Food.values[result].calories

        local time, expensive_time
        if recipe:has_difficulties() then
            time = recipe:get_field("energy_required", "normal")
            expensive_time = recipe:get_field("energy_required", "expensive")
        else
            time = recipe.energy_required
            expensive_time = time
        end

        return count_normal, count_expensive, count_normal / time, count_expensive / expensive_time
    else
        return 0, 0, 0, 0
    end
end

local results = {}
for _, recipe in Tirislib_Recipe.iterate() do
    if recipe.owner == "sosciencity" then
        if get_result_calories(recipe) > 0 then
            table.insert(
                results,
                string.format(
                    "%s produces %d or %d kcal per cycle, %d or %d kg per second",
                    recipe.name,
                    get_result_calories(recipe)
                )
            )
        end
    end
end

log(Tirislib_String.join("\n", "Food Producing Recipes:", results))

--[[
local function get_result_mass(recipe, difficulty)
    local ret = 0
    for _, result in pairs(recipe[difficulty].results) do
        ret = ret + (get_animal_size(result.name) or 0) * Tirislib_RecipeEntry.get_average_yield(result)
    end
    return ret
end

local results = {}
for _, recipe in pairs(fauna_producing_recipes) do
    local mass = get_result_mass(recipe, "normal")
    local mass_expensive = get_result_mass(recipe, "expensive")
    local time = recipe:get_field("energy_required", "normal")
    local time_expensive = recipe:get_field("energy_required", "expensive")
    table.insert(
        results,
        string.format(
            "%s produces %d or %d kg per cycle, %d or %d kg per second",
            recipe.name,
            mass,
            mass_expensive,
            mass / time,
            mass_expensive / time_expensive
        )
    )
end

log(Tirislib_String.join("\n", "Fauna Balancing Values:", results))
]]