--- Cosmetic "On Stage / Genre" flavor for the nightclub details view.
--- The current act is derived deterministically from the nightclub's unit number and the
--- current time bucket, so nothing needs to be stored: every player watching the same club
--- at the same tick sees the same artist, and it rotates on its own every change_interval.

local EK = require("enums.entry-key")
local Type = require("enums.type")
local Time = require("constants.time")

local Gui = Gui
local Datalist = Gui.Elements.Datalist
local Tabs = Gui.Elements.Tabs

local floor = math.floor
local mix_seeds = Tirislib.Utils.mix_seeds

-- how long a single act stays on stage before a new one is generated
local change_interval = 90 * Time.second

-- number of variations per wordlist
local artist_bases = 20
local artist_prefixes = 14
local artist_suffixes = 16
local genre_bases = 24
local genre_decorators = 30

--- @param rng LuaRandomGenerator
local function build_artist(rng)
    -- innermost is the base name; each decorator is a single-parameter locale wrapper.
    local name = {"nightclub-artist.base" .. rng(artist_bases)}

    -- at most one prefix and one suffix -> 0..2 decorators total
    if rng() < 0.5 then
        name = {"nightclub-artist.prefix" .. rng(artist_prefixes), name}
    end
    if rng() < 0.5 then
        name = {"nightclub-artist.suffix" .. rng(artist_suffixes), name}
    end

    return name
end

--- @param rng LuaRandomGenerator
local function build_genre(rng)
    local name = {"nightclub-genre.base" .. rng(genre_bases)}

    local decorator_count = rng(4) - 1 -- [0, 3]

    for _ = 1, decorator_count do
        name = {"nightclub-genre.deco" .. rng(genre_decorators), name}
    end

    return name
end

--- Returns the artist and genre currently on stage as localised strings, or nil when the
--- club isn't actually running (no power / no staff -> performance is 0).
local function get_current_act(entry)
    if (entry[EK.performance] or 0) <= 0 then
        return nil
    end

    local tick_bucket = floor(game.tick / change_interval)
    local seed = mix_seeds(entry[EK.unit_number], tick_bucket)
    local rng = game.create_random_generator(seed)

    return build_artist(rng), build_genre(rng)
end

local function apply_current_act(building_data, entry)
    local artist_name, genre_name = get_current_act(entry)
    local playing = artist_name ~= nil

    Datalist.set_kv_pair_visibility(building_data, "on-stage", playing)
    Datalist.set_kv_pair_visibility(building_data, "genre", playing)

    if playing then
        Datalist.set_kv_pair_value(building_data, "on-stage", artist_name)
        Datalist.set_kv_pair_value(building_data, "genre", genre_name)
    end
end

local function update_nightclub_details(container, entry, player_id)
    Gui.DetailsView.update_general(container, entry, player_id)
    apply_current_act(Tabs.get_content(container.tabpane, "general").building, entry)
end

local function create_nightclub_details(container, entry, player_id)
    local tabbed_pane = Gui.DetailsView.create_general(container, entry, player_id)
    local building_data = Tabs.get_content(tabbed_pane, "general").building

    Datalist.add_kv_pair(building_data, "on-stage", {"sosciencity.on-stage"})
    Datalist.add_kv_pair(building_data, "genre", {"sosciencity.genre"})
    apply_current_act(building_data, entry)

    return tabbed_pane
end

Gui.DetailsView.register_type(Type.nightclub, {
    creater = create_nightclub_details,
    updater = update_nightclub_details
})
