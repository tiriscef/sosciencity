Gui.CityView.add_category("statistics", {"city-view.statistics"})

Gui.CityView.add_page {
    name = "overview",
    category = "statistics",
    localised_name = {"sosciencity.overview"},
    creator = function(container)
        -- TODO
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
        local emigration_sum = Tirislib.Tables.sum(storage.current_reports.emigration)
        local death_sum = Tirislib.Tables.sum(storage.current_reports.death)
        Gui.Elements.CalculationTable.create {
            container = container,
            groups = {
                {
                    values = {
                        immigration_sum,
                        emigration_sum,
                        death_sum
                    },
                    left_lookup = {
                        {"city-view.immigration"},
                        {"city-view.emigration"},
                        {"city-view.death"}
                    },
                    right_content = Tirislib.Utils.identity
                },
                {
                    values = {immigration_sum - emigration_sum - death_sum},
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

        Gui.Elements.Label.heading_3(container, {"city-view.emigration-by-cause"})
        if emigration_sum > 0 then
            Gui.Elements.CalculationTable.create {
                container = container,
                groups = {
                    {
                        values = storage.current_reports.emigration,
                        left_content = Locale.emigration_cause,
                        right_content = Tirislib.Utils.identity
                    }
                }
            }
        else
            Gui.Elements.Label.paragraph(container, {"city-view.no-reported-emigration"})
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
