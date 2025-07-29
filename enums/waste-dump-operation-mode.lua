--- Enum table for the operation modes of waste dumps
--- @enum WasteDumpOperationMode
local WasteDumpOperationMode = {}

--- nothing will happen to the garbage inside the dump
WasteDumpOperationMode.neutral = 0
--- garbage will be stored inside the dump
WasteDumpOperationMode.store = 1
--- garbage will be removed from the dump
WasteDumpOperationMode.output = 2

return WasteDumpOperationMode
