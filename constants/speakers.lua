Speakers = {}

Speakers["tiriscef."] = {
    useless_banter_count = 24,
    lines_with_followup = {
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        15,
        19,
        20,
        23
    },
    index = 0
}

Speakers["profanity."] = {
    useless_banter_count = 13,
    lines_with_followup = {1, 7, 9, 13},
    index = 10000
}

for _, speaker in pairs(Speakers) do
    speaker.lines_with_followup = Tirislib_Tables.to_lookup(speaker.lines_with_followup)
end
