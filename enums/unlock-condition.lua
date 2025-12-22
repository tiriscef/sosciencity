--- Enum table for types of conditions that unlock technologies.
--- @enum UnlockCondition
local UnlockCondition = {}

--- Some custom condition that needs its own functions and locales. Currently not implemented.
UnlockCondition.custom = 0
--- Acquiring at least one of a specific item.
UnlockCondition.item_acquisition = 1
--- Having an amount of caste points.<br>
--- Fields:<br>
--- caste: Type<br>
--- count: number
UnlockCondition.caste_points = 2
--- Having a caste population of a given size.<br>
--- Fields:<br>
--- caste: Type<br>
--- count: number
UnlockCondition.caste_population = 3
--- Having a total population of a given size.<br>
--- Fields:<br>
--- count: number
UnlockCondition.population = 4

return UnlockCondition
