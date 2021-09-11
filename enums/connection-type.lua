--- Enum table for subscription connection types
local ConnectionType = {}

--- the connection is established when either one entity can reach the other
ConnectionType.bidirectional = 1
--- the connection is established when the entity can reach the neighbor
ConnectionType.to_neighbor = 2
--- the connection is established when the neighbor can reach the entity
ConnectionType.from_neighbor = 3

return ConnectionType
