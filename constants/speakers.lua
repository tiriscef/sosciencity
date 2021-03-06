Speakers = {}

Speakers["tiriscef."] = {
    ["b"] = 50,
    ["roadkill"] = 6,
    ["report-begin"] = 2,
    ["report-end"] = 2,
    ["census-immigration"] = 2,
    ["census-emigration"] = 2,
    ["healthcare"] = 2,
    ["healthcare-recovery"] = 2,
    ["healthcare-infection-warning"] = 2,
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
        "b38",
        "b39",
        "b39f",
        "b42",
        "b43",
        "b44",
        "b44f",
        "b48",
        "b48f",
        "b49"
    },
    index = 0
}

Speakers["profanity."] = {
    ["b"] = 26,
    ["roadkill"] = 5,
    ["report-begin"] = 3,
    ["report-end"] = 3,
    ["census-immigration"] = 2,
    ["census-emigration"] = 2,
    ["healthcare"] = 2,
    ["healthcare-recovery"] = 2,
    ["healthcare-infection-warning"] = 2,
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
