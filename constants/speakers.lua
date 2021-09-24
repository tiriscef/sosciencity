local Speakers = {}

Speakers["tiriscef."] = {
    ["acquisition-unlock"] = 1,
    ["b"] = 65,
    ["roadkill"] = 6,
    ["report-begin"] = 2,
    ["report-end"] = 2,
    ["census-immigration"] = 2,
    ["census-emigration"] = 2,
    ["healthcare"] = 2,
    ["healthcare-recovery"] = 2,
    ["healthcare-infection-warning"] = 2,
    ["warning-no-food"] = 3,
    ["warning-no-water"] = 3,
    ["warning-garbage"] = 3,
    ["warning-insufficient-maintenance"] = 3,
    ["warning-emigration"] = 3,
    lines_with_followup = {
        "b2",
        "b3",
        "b4",
        "b5",
        "b6",
        "b7",
        "b8",
        "b9",
        "b15",
        "b19",
        "b20",
        "b23",
        "b24",
        "b27",
        "b28",
        "b35",
        "b38",
        "b39",
        "b39f",
        "b42",
        "b43",
        "b44",
        "b44f",
        "b48",
        "b48f",
        "b49",
        "b52",
        "b53",
        "b53f",
        "b54",
        "b56",
        "b56f",
        "b57",
        "b59",
        "b60",
        "b63",
        "b64"
    },
    index = 0
}

Speakers["profanity."] = {
    ["acquisition-unlock"] = 1,
    ["b"] = 28,
    ["roadkill"] = 5,
    ["report-begin"] = 3,
    ["report-end"] = 3,
    ["census-immigration"] = 2,
    ["census-emigration"] = 2,
    ["healthcare"] = 2,
    ["healthcare-recovery"] = 2,
    ["healthcare-infection-warning"] = 2,
    ["warning-no-food"] = 3,
    ["warning-no-water"] = 3,
    ["warning-garbage"] = 3,
    ["warning-insufficient-maintenance"] = 3,
    ["warning-emigration"] = 3,
    lines_with_followup = {
        "b1",
        "b7",
        "b9",
        "b13",
        "b14",
        "b15",
        "b18",
        "b19",
        "b21",
        "b21f",
        "b24"
    },
    index = 10000
}

for _, speaker in pairs(Speakers) do
    speaker.lines_with_followup = Tirislib_Tables.array_to_lookup(speaker.lines_with_followup)
end

return Speakers
