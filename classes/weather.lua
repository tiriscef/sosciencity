--- Static class that handles the nauvis weather.
Weather = {}

--[[
    Data this class stores in global
    --------------------------------
    global.weather_index: integer

    global.next_weather_bump: tick

    global.current_climate: Climate enum

    global.current_humidity: Humidity enum
]]
local random = math.random

---------------------------------------------------------------------------------------------------
-- << constants >>

Weather.weather_locales = {
    [Humidity.dry] = {
        [Climate.cold] = {"weather.frost"},
        [Climate.temperate] = {"weather.sunny"},
        [Climate.hot] = {"weather.drought"}
    },
    [Humidity.moderate] = {
        [Climate.cold] = {"weather.dewy"},
        [Climate.temperate] = {"weather.mild"},
        [Climate.hot] = {"weather.fair-weather"}
    },
    [Humidity.humid] = {
        [Climate.cold] = {"weather.snowy"},
        [Climate.temperate] = {"weather.rainy"},
        [Climate.hot] = {"weather.muggy"}
    }
}

Weather.climate_locales = {
    [Climate.cold] = {"climate.cold"},
    [Climate.temperate] = {"climate.temperate"},
    [Climate.hot] = {"climate.hot"}
}

Weather.humidity_locales = {
    [Humidity.dry] = {"humidity.dry"},
    [Humidity.moderate] = {"humidity.moderate"},
    [Humidity.humid] = {"humidity.humid"}
}

local climate_pattern = {
    [0] = Climate.hot,
    Climate.temperate,
    Climate.cold,
    Climate.temperate,
    Climate.temperate
}
local climate_count = Tirislib_Tables.count(climate_pattern)

local humidity_pattern = {
    [0] = Humidity.humid,
    Humidity.moderate,
    Humidity.humid,
    Humidity.humid,
    Humidity.moderate,
    Humidity.moderate,
    Humidity.dry,
    Humidity.dry,
    Humidity.moderate,
    Humidity.humid,
    Humidity.moderate,
    Humidity.dry,
    Humidity.dry
}
local humidity_count = Tirislib_Tables.count(humidity_pattern)

local weather_pattern_length = Tirislib_Utils.lowest_common_multiple(humidity_count, climate_count)

local min_weather_duration = Time.nauvis_day
local max_weather_duration = Time.nauvis_day * 3

---------------------------------------------------------------------------------------------------
-- << weather cycle implementation >>

local function bump()
    global.next_weather_bump = global.next_weather_bump + random(min_weather_duration, max_weather_duration)

    local new_index = (global.weather_index + 1) % weather_pattern_length
    global.weather_index = new_index
    global.current_climate = climate_pattern[new_index % climate_count]
    global.current_humidity = humidity_pattern[new_index % humidity_count]
end

function Weather.init()
    global.weather_index = random(0, weather_pattern_length)
    global.next_weather_bump = game.tick
    bump()
end

function Weather.update(current_tick)
    if current_tick >= global.next_weather_bump then
        bump()
    end
end
