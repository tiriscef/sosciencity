local Climate = require("enums.climate")
local Humidity = require("enums.humidity")

local WeatherLocales = {}

WeatherLocales.weather = {
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

WeatherLocales.climate = {
    [Climate.cold] = {"climate.cold"},
    [Climate.temperate] = {"climate.temperate"},
    [Climate.hot] = {"climate.hot"}
}

WeatherLocales.humidity = {
    [Humidity.dry] = {"humidity.dry"},
    [Humidity.moderate] = {"humidity.moderate"},
    [Humidity.humid] = {"humidity.humid"}
}

return WeatherLocales
