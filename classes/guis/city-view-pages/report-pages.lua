local Castes = require("constants.castes")
local Color = require("constants.color")
local Types = require("constants.types")
local EK = require("enums.entry-key")
local Type = require("enums.type")

local HEALTHY = DiseaseGroup.HEALTHY
local floor = math.floor
local log = math.log

--- Rounds a number to 1-2 significant digits for an "estimate" display.
local function approximate(n)
    if n <= 0 then return 0 end
    if n < 10 then return n end
    local magnitude = 10 ^ floor(log(n, 10))
    return floor(n / magnitude + 0.5) * magnitude
end

--- Iterates all inhabited houses and returns aggregate stats.
local function compute_housing_stats()
    local sick = 0
    local employed = 0
    local striking = 0
    for _, caste in pairs(Castes.all) do
        for _, entry in Register.iterate_type(caste.type) do
            sick = sick + entry[EK.inhabitants] - entry[EK.diseases][HEALTHY]
            employed = employed + (entry[EK.employed] or 0)
            if entry[EK.strike_level] > 0 then
                striking = striking + 1
            end
        end
    end
    return sick, employed, striking
end

--- Returns a type count, or the sum of counts for multiple types.
local function type_count(...)
    local total = 0
    for i = 1, select("#", ...) do
        total = total + Register.get_type_count(select(i, ...))
    end
    return total
end

--- Adds a label with a trend indicator (▲/▼).
--- @param container LuaGuiElement the table to add the cell to
--- @param delta number the change value
--- @param style string? optional label style
local function add_population_cell_with_trend(container, population, delta, style)
    local caption = tostring(population)
    local color
    if delta > 0 then
        caption = "▲ " .. caption
        color = Color.green
    elseif delta < 0 then
        arrow = "▼ " .. caption
        color = Color.red
    end

    local label = container.add {
        type = "label",
        caption = caption,
        tooltip = {"city-view.trend-tooltip", delta},
        style = style
    }

    if color then
        label.style.font_color = color
    end
end

--- Adds a building count row to a datalist if the count is > 0.
local function add_building_row(datalist, key, type_id, count)
    if count > 0 then
        local def = Types.definitions[type_id]
        Gui.Elements.Datalist.add_kv_pair(
            datalist,
            key,
            def and def.localised_name or key,
            tostring(count)
        )
    end
end

Gui.CityView.add_category("statistics", {"city-view.statistics"})

Gui.CityView.add_page {
    name = "overview",
    category = "statistics",
    localised_name = {"city-view.overview"},
    creator = function(container)
        Gui.Elements.Label.heading_1(container, {"city-view.overview"})
        Gui.Elements.Label.paragraph(container, {"city-view.overview-intro"})

        -- collect researched castes
        local researched_castes = {}
        for _, caste in pairs(Castes.all) do
            if Inhabitants.caste_is_researched(caste.type) then
                researched_castes[#researched_castes + 1] = caste
            end
        end

        -----------------------------------------------------------------------
        -- Section 1: Population & Housing
        -----------------------------------------------------------------------
        Gui.Elements.Label.heading_2(container, {"city-view.population-and-housing"})

        -- population snapshot from ~1 hour ago for trend indicators
        local snapshot = Statistics.get_population_snapshot("fine", 60)

        local pop_table = container.add {
            type = "table",
            column_count = 4,
            style = "sosciencity_calculation_table"
        }

        -- header row
        local function add_head_cell(caption)
            pop_table.add {
                type = "label",
                caption = caption,
                style = "sosciencity_calculation_table_left_head"
            }
        end
        add_head_cell("")
        add_head_cell({"sosciencity.population"})
        add_head_cell({"sosciencity.capacity"})
        add_head_cell({"city-view.homeless"})

        local total_pop = 0
        local total_housing = 0
        local total_improvised = 0
        local total_homeless = 0
        local total_old_pop = 0
        local has_snapshot = snapshot ~= nil

        for _, caste in pairs(researched_castes) do
            local caste_id = caste.type
            local pop = storage.population[caste_id]
            local official = storage.housing_capacity[caste_id][false]
            local improvised = storage.housing_capacity[caste_id][true]
            local capacity = official + improvised
            local homeless_raw = storage.homeless[caste_id] and storage.homeless[caste_id][EK.inhabitants] or 0

            pop_table.add {type = "label", caption = Locale.caste(caste_id), style = "sosciencity_calculation_table_left"}

            -- trend indicator
            if has_snapshot then
                local old_pop = snapshot[caste_id] or 0
                add_population_cell_with_trend(pop_table, pop, pop - old_pop)
                total_old_pop = total_old_pop + old_pop
            else
                add_population_cell_with_trend(pop_table, pop, 0)
            end

            pop_table.add {type = "label", caption = {"city-view.housing-display", capacity, improvised}}
            pop_table.add {type = "label", caption = {"city-view.homeless-estimate", approximate(homeless_raw)}}

            total_pop = total_pop + pop
            total_housing = total_housing + capacity
            total_improvised = total_improvised + improvised
            total_homeless = total_homeless + homeless_raw
        end

        -- total row
        pop_table.add {type = "label", caption = {"city-view.total"}, style = "sosciencity_calculation_table_left_head"}

        if has_snapshot and #researched_castes > 0 then
            add_population_cell_with_trend(pop_table, total_pop, total_pop - total_old_pop, "sosciencity_calculation_table_right_head")
        else
            add_population_cell_with_trend(pop_table, total_pop, 0, "sosciencity_calculation_table_right_head")
        end

        pop_table.add {type = "label", caption = {"city-view.housing-display", total_housing, total_improvised}, style = "sosciencity_calculation_table_right_head"}
        pop_table.add {type = "label", caption = {"city-view.homeless-estimate", approximate(total_homeless)}, style = "sosciencity_calculation_table_right_head"}

        if #researched_castes == 0 then
            Gui.Elements.Label.paragraph(container, {"city-view.no-castes-researched"})
            Gui.Elements.Button.technology_link(container, "upbringing")
        end

        -----------------------------------------------------------------------
        -- Section 2: Caste Bonuses
        -----------------------------------------------------------------------
        if #researched_castes > 0 then
            Gui.Elements.Label.heading_2(container, {"city-view.caste-bonuses"})

            local bonus_table = container.add {
                type = "table",
                column_count = 3,
                style = "sosciencity_calculation_table"
            }

            -- header row
            bonus_table.add {type = "label", caption = "", style = "sosciencity_calculation_table_left_head"}
            bonus_table.add {type = "label", caption = {"city-view.bonus"}, style = "sosciencity_calculation_table_left_head"}
            bonus_table.add {type = "label", caption = {"city-view.points"}, style = "sosciencity_calculation_table_left_head"}

            for _, caste in pairs(researched_castes) do
                local caste_id = caste.type
                local bonus_value = storage.caste_bonuses[caste_id]
                local points = storage.caste_points[caste_id]

                bonus_table.add {
                    type = "label",
                    caption = {"caste-bonus." .. caste.name},
                    style = "sosciencity_calculation_table_left"
                }

                local bonus_label = bonus_table.add {
                    type = "label",
                    caption = {"caste-bonus.show-" .. caste.name, bonus_value}
                }
                bonus_label.style.font_color =
                    (bonus_value > 0 and Color.green) or (bonus_value < 0 and Color.red) or Color.white

                bonus_table.add {
                    type = "label",
                    caption = tostring(floor(points))
                }
            end
        end

        -----------------------------------------------------------------------
        -- Section 3: City Health
        -----------------------------------------------------------------------
        local sick, employed, striking = compute_housing_stats()

        local health_content = Gui.Elements.CollapsibleSection.heading_2(
            container,
            {"city-view.city-health"}
        )

        local health_data = Gui.Elements.Datalist.create(health_content)
        Gui.Elements.Datalist.add_kv_pair(
            health_data, "fear",
            {"city-view.fear-level"},
            {"city-view.display-fear", string.format("%.1f", storage.fear)}
        )
        Gui.Elements.Datalist.add_kv_pair(
            health_data, "sick",
            {"city-view.sick-inhabitants"},
            tostring(sick)
        )
        Gui.Elements.Datalist.add_kv_pair(
            health_data, "striking",
            {"city-view.striking-houses"},
            tostring(striking)
        )

        Gui.Elements.Button.page_link(health_content, "statistics", "census-report")
        Gui.Elements.Button.page_link(health_content, "statistics", "healthcare-report")

        -----------------------------------------------------------------------
        -- Section 4: Workforce
        -----------------------------------------------------------------------
        local workforce_content = Gui.Elements.CollapsibleSection.heading_2(
            container,
            {"city-view.workforce"}
        )

        local workforce_data = Gui.Elements.Datalist.create(workforce_content)
        Gui.Elements.Datalist.add_kv_pair(
            workforce_data,
            "employed",
            {"city-view.employed"},
            tostring(employed)
        )
        Gui.Elements.Datalist.add_kv_pair(
            workforce_data,
            "manufactories",
            Types.definitions[Type.manufactory].localised_name,
            tostring(Register.get_type_count(Type.manufactory))
        )

        -----------------------------------------------------------------------
        -- Section 5: Infrastructure
        -----------------------------------------------------------------------
        local infra_content = Gui.Elements.CollapsibleSection.heading_2(
            container,
            {"city-view.infrastructure"},
            {collapsed = true}
        )

        -- Factories
        Gui.Elements.Label.heading_3(infra_content, {"city-view.factories"})
        local factory_data = Gui.Elements.Datalist.create(infra_content, "factories")
        Gui.Elements.Datalist.add_kv_pair(
            factory_data, "machines",
            {"sosciencity.machines"},
            {"city-view.active-of-total", storage.active_machine_count, Register.get_machine_count()}
        )
        local lab_count = Register.get_type_count(Type.lab)
        if lab_count > 0 then
            add_building_row(factory_data, "labs", Type.lab, lab_count)
        end
        local turret_count = Register.get_type_count(Type.turret)
        if turret_count > 0 then
            add_building_row(factory_data, "turrets", Type.turret, turret_count)
        end

        -- Healthcare
        local healthcare_types = {
            Type.hospital, Type.improvised_hospital, Type.pharmacy,
            Type.psych_ward, Type.intensive_care_unit, Type.gene_clinic
        }
        local has_healthcare = false
        for _, t in pairs(healthcare_types) do
            if Register.get_type_count(t) > 0 then
                has_healthcare = true
                break
            end
        end
        if has_healthcare then
            Gui.Elements.Label.heading_3(infra_content, {"city-view.healthcare-buildings"})
            local hc_data = Gui.Elements.Datalist.create(infra_content, "healthcare")
            for _, t in pairs(healthcare_types) do
                add_building_row(hc_data, "hc-" .. t, t, Register.get_type_count(t))
            end
        end

        -- Civil
        local civil_types = {
            Type.market,
            Type.water_distributer,
            Type.dumpster,
            Type.kitchen_for_all,
            Type.nightclub
        }
        local has_civil = false
        for _, t in pairs(civil_types) do
            if Register.get_type_count(t) > 0 then
                has_civil = true
                break
            end
        end
        if has_civil then
            Gui.Elements.Label.heading_3(infra_content, {"city-view.civil-buildings"})
            local civil_data = Gui.Elements.Datalist.create(infra_content, "civil")
            for _, t in pairs(civil_types) do
                add_building_row(civil_data, "civil-" .. t, t, Register.get_type_count(t))
            end
        end

        -- Production
        local farm_count = type_count(Type.farm, Type.automatic_farm)
        local production_entries = {
            {key = "manufactory", type_id = Type.manufactory, count = Register.get_type_count(Type.manufactory)},
            {key = "farms", type_id = Type.farm, count = farm_count, label = {"city-view.farms"}},
            {key = "animal-farm", type_id = Type.animal_farm, count = Register.get_type_count(Type.animal_farm)},
            {key = "fishery", type_id = Type.fishery, count = Register.get_type_count(Type.fishery)},
            {key = "hunting-hut", type_id = Type.hunting_hut, count = Register.get_type_count(Type.hunting_hut)},
            {key = "waterwell", type_id = Type.waterwell, count = Register.get_type_count(Type.waterwell)},
            {key = "salt-pond", type_id = Type.salt_pond, count = Register.get_type_count(Type.salt_pond)}
        }
        local has_production = false
        for _, entry in pairs(production_entries) do
            if entry.count > 0 then
                has_production = true
                break
            end
        end
        if has_production then
            Gui.Elements.Label.heading_3(infra_content, {"city-view.production-buildings"})
            local prod_data = Gui.Elements.Datalist.create(infra_content, "production")
            for _, entry in pairs(production_entries) do
                if entry.count > 0 then
                    local label = entry.label or Types.definitions[entry.type_id].localised_name
                    Gui.Elements.Datalist.add_kv_pair(prod_data, entry.key, label, tostring(entry.count))
                end
            end
        end

        -- Other
        local other_types = {
            Type.composter,
            Type.cold_storage,
            Type.waste_dump
        }
        local has_other = false
        for _, t in pairs(other_types) do
            if Register.get_type_count(t) > 0 then
                has_other = true
                break
            end
        end
        if has_other then
            Gui.Elements.Label.heading_3(infra_content, {"city-view.other-buildings"})
            local other_data = Gui.Elements.Datalist.create(infra_content, "other")
            for _, t in pairs(other_types) do
                add_building_row(other_data, "other-" .. t, t, Register.get_type_count(t))
            end
        end
    end
}

Gui.CityView.add_page {
    name = "census-report",
    category = "statistics",
    localised_name = {"report-name.census"},
    creator = function(container)
        if not storage.current_reports.immigration then
            Gui.Elements.Label.paragraph(container, {"city-view.no-report", {"report-name.census"}})
            return
        end

        Gui.Elements.Label.heading_1(container, {"report-name.census"})
        Gui.Elements.Label.paragraph(container, {"city-view.census-report-intro"})

        Gui.Elements.Label.heading_3(container, {"city-view.overview"})

        local immigration_sum = Tirislib.Tables.sum(storage.current_reports.immigration)
        local loss_sum = Tirislib.Tables.sum(storage.current_reports.loss)
        local death_sum = Tirislib.Tables.sum(storage.current_reports.death)
        Gui.Elements.CalculationTable.create {
            container = container,
            groups = {
                {
                    values = {
                        immigration_sum,
                        loss_sum,
                        death_sum
                    },
                    left_lookup = {
                        {"city-view.immigration"},
                        {"city-view.loss"},
                        {"city-view.death"}
                    },
                    right_content = Tirislib.Utils.identity
                },
                {
                    values = {immigration_sum - loss_sum - death_sum},
                    left_lookup = {{"city-view.sum"}},
                    right_content = Tirislib.Utils.identity,
                    left_style = "sosciencity_calculation_table_left_head",
                    right_style = "sosciencity_calculation_table_right_head"
                }
            }
        }

        Gui.Elements.Label.heading_3(container, {"city-view.immigration-by-cause"})
        if immigration_sum > 0 then
            Gui.Elements.CalculationTable.create {
                container = container,
                groups = {
                    {
                        values = storage.current_reports.immigration,
                        left_content = Locale.immigration_cause,
                        right_content = Tirislib.Utils.identity
                    }
                }
            }
        else
            Gui.Elements.Label.paragraph(container, {"city-view.no-reported-immigration"})
        end

        Gui.Elements.Label.heading_3(container, {"city-view.loss-by-cause"})
        if loss_sum > 0 then
            Gui.Elements.CalculationTable.create {
                container = container,
                groups = {
                    {
                        values = storage.current_reports.loss,
                        left_content = Locale.loss_cause,
                        right_content = Tirislib.Utils.identity
                    }
                }
            }
        else
            Gui.Elements.Label.paragraph(container, {"city-view.no-reported-loss"})
        end

        Gui.Elements.Label.heading_3(container, {"city-view.deaths-by-cause"})
        if death_sum > 0 then
            Gui.Elements.CalculationTable.create {
                container = container,
                groups = {
                    {
                        values = storage.current_reports.death,
                        left_content = Locale.death_cause,
                        right_content = Tirislib.Utils.identity
                    }
                }
            }
        else
            Gui.Elements.Label.paragraph(container, {"city-view.no-reported-deaths"})
        end
    end
}

local Diseases = require("constants.diseases")

Gui.CityView.add_page {
    name = "healthcare-report",
    category = "statistics",
    localised_name = {"report-name.healthcare"},
    creator = function(container)
        if not storage.current_reports.diseases then
            Gui.Elements.Label.paragraph(container, {"city-view.no-report", {"report-name.healthcare"}})
            return
        end

        Gui.Elements.Label.heading_1(container, {"report-name.healthcare"})
        Gui.Elements.Label.paragraph(container, {"city-view.healthcare-report-intro"})

        Gui.Elements.Label.heading_3(container, {"city-view.overview"})
        local new_diseases_sum = Tirislib.Tables.sum(storage.current_reports["disease-cause"])
        local treated_diseases_sum = Tirislib.Tables.sum(storage.current_reports["disease-recovery"][true])
        local recovered_diseases_sum = Tirislib.Tables.sum(storage.current_reports["disease-recovery"][false])
        local disease_death_sum = Tirislib.Tables.sum(storage.current_reports["disease-death"])
        Gui.Elements.CalculationTable.create {
            container = container,
            groups = {
                {
                    values = {
                        new_diseases_sum,
                        treated_diseases_sum,
                        recovered_diseases_sum,
                        disease_death_sum
                    },
                    left_lookup = {
                        {"city-view.new-diseases"},
                        {"city-view.treated-diseases"},
                        {"city-view.recovered-diseases"},
                        {"city-view.disease-deaths"}
                    },
                    right_content = Tirislib.Utils.identity
                },
                {
                    values = {new_diseases_sum - treated_diseases_sum - recovered_diseases_sum - disease_death_sum},
                    left_lookup = {{"city-view.sum"}},
                    right_content = Tirislib.Utils.identity,
                    left_style = "sosciencity_calculation_table_left_head",
                    right_style = "sosciencity_calculation_table_right_head"
                }
            }
        }

        Gui.Elements.Label.heading_3(container, {"city-view.overview-by-disease"})
        local disease_overview = Tirislib.Tables.copy(storage.current_reports.diseases)
        Tirislib.Tables.subtract(disease_overview, storage.current_reports["disease-recovery"][true])
        Tirislib.Tables.subtract(disease_overview, storage.current_reports["disease-recovery"][false])
        Tirislib.Tables.subtract(disease_overview, storage.current_reports["disease-death"])
        Gui.Elements.CalculationTable.create {
            container = container,
            groups = {
                {
                    values = disease_overview,
                    left_content = function(disease_id)
                        return Diseases.values[disease_id].localised_name
                    end,
                    left_tooltip = function(disease_id)
                        return Diseases.values[disease_id].localised_description
                    end,
                    right_content = function(value)
                        if value > 0 then
                            return "+ " .. value
                        elseif value < 0 then
                            return "- " .. (-value)
                        else
                            return "± 0"
                        end
                    end
                }
            }
        }

        Gui.Elements.Label.heading_3(container, {"city-view.new-diseases"})
        if Tirislib.Tables.any(storage.current_reports.diseases) then
            Gui.Elements.CalculationTable.create {
                container = container,
                groups = {
                    {
                        values = storage.current_reports.diseases,
                        left_content = function(disease_id)
                            return Diseases.values[disease_id].localised_name
                        end,
                        left_tooltip = function(disease_id)
                            return Diseases.values[disease_id].localised_description
                        end,
                        right_content = Tirislib.Utils.identity
                    }
                }
            }
        else
            Gui.Elements.Label.paragraph(container, {"city-view.no-reported-new-diseases"})
        end

        Gui.Elements.Label.heading_3(container, {"city-view.new-diseases-by-cause"})
        if Tirislib.Tables.any(storage.current_reports["disease-cause"]) then
            Gui.Elements.CalculationTable.create {
                container = container,
                groups = {
                    {
                        values = storage.current_reports["disease-cause"],
                        left_content = Locale.disease_cause,
                        right_content = Tirislib.Utils.identity
                    }
                }
            }
        else
            Gui.Elements.Label.paragraph(container, {"city-view.no-reported-new-diseases"})
        end

        Gui.Elements.Label.heading_3(container, {"city-view.treated-diseases"})
        if Tirislib.Tables.any(storage.current_reports["disease-recovery"][true]) then
            Gui.Elements.CalculationTable.create {
                container = container,
                groups = {
                    {
                        values = storage.current_reports["disease-recovery"][true],
                        left_content = function(disease_id)
                            return Diseases.values[disease_id].localised_name
                        end,
                        left_tooltip = function(disease_id)
                            return Diseases.values[disease_id].localised_description
                        end,
                        right_content = Tirislib.Utils.identity
                    }
                }
            }
        else
            Gui.Elements.Label.paragraph(container, {"city-view.no-reported-treatments"})
        end

        Gui.Elements.Label.heading_3(container, {"city-view.recovered-diseases"})
        if Tirislib.Tables.any(storage.current_reports["disease-recovery"][false]) then
            Gui.Elements.CalculationTable.create {
                container = container,
                groups = {
                    {
                        values = storage.current_reports["disease-recovery"][false],
                        left_content = function(disease_id)
                            return Diseases.values[disease_id].localised_name
                        end,
                        left_tooltip = function(disease_id)
                            return Diseases.values[disease_id].localised_description
                        end,
                        right_content = Tirislib.Utils.identity
                    }
                }
            }
        else
            Gui.Elements.Label.paragraph(container, {"city-view.no-reported-recoveries"})
        end

        Gui.Elements.Label.heading_3(container, {"city-view.disease-deaths"})
        if Tirislib.Tables.any(storage.current_reports["disease-death"]) then
            Gui.Elements.CalculationTable.create {
                container = container,
                groups = {
                    {
                        values = storage.current_reports["disease-death"],
                        left_content = function(disease_id)
                            return Diseases.values[disease_id].localised_name
                        end,
                        left_tooltip = function(disease_id)
                            return Diseases.values[disease_id].localised_description
                        end,
                        right_content = Tirislib.Utils.identity
                    }
                }
            }
        else
            Gui.Elements.Label.paragraph(container, {"city-view.no-reported-disease-deaths"})
        end
    end
}
