local Climate = require("enums.climate")
local Humidity = require("enums.humidity")

local Time = require("constants.time")

--- Static class that handles the nauvis weather.
Weather = {}

--[[
    Data this class stores in storage
    --------------------------------
    storage.weather_index: integer

    storage.next_weather_bump: tick

    storage.current_climate: Climate enum

    storage.current_humidity: Humidity enum
]]
local random = math.random

---------------------------------------------------------------------------------------------------
-- << constants >>

local climate_pattern = {
    [0] = Climate.hot,
    Climate.temperate,
    Climate.cold,
    Climate.temperate,
    Climate.temperate
}
local climate_count = Tirislib.Tables.count(climate_pattern)

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
local humidity_count = Tirislib.Tables.count(humidity_pattern)

local weather_pattern_length = Tirislib.Utils.lowest_common_multiple(humidity_count, climate_count)

local min_weather_duration = Time.nauvis_day
local max_weather_duration = Time.nauvis_day * 3

---------------------------------------------------------------------------------------------------
-- << weather cycle implementation >>

local function bump()
    storage.next_weather_bump = storage.next_weather_bump + random(min_weather_duration, max_weather_duration)

    local new_index = (storage.weather_index + 1) % weather_pattern_length
    storage.weather_index = new_index
    storage.current_climate = climate_pattern[new_index % climate_count]
    storage.current_humidity = humidity_pattern[new_index % humidity_count]
end

function Weather.init()
    storage.weather_index = random(0, weather_pattern_length)
    storage.next_weather_bump = game.tick
    bump()
end

function Weather.update(current_tick)
    if current_tick >= storage.next_weather_bump then
        bump()
    end
end
