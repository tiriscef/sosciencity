--- Constants related to time
local Time = {}

-- realtime related constants
--- length of a rl second in ticks
Time.second = 60
--- length of a rl minute in ticks
Time.minute = Time.second * 60
--- length of a rl hour in ticks
Time.hour = Time.minute * 60

--- a day has 25000 ticks according to the wiki
Time.nauvis_day = 25000
--- a week is 7 days, just like in real life
Time.nauvis_week = Time.nauvis_day * 7
--- a month is fixed to 4 weeks or 28 days because that's easier
Time.nauvis_month = Time.nauvis_week * 4

return Time
