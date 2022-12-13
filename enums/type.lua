--- Enum table for registered entity types.
local Type = {}

-- housing types

Type.empty_house = 0
Type.clockwork = 1
Type.orchid = 2
Type.gunfire = 3
Type.ember = 4
Type.foundry = 5
Type.gleam = 6
Type.aurora = 7
Type.plasma = 8

-- civil types

Type.market = 101
Type.water_distributer = 102
Type.dumpster = 104
Type.immigration_port = 106
Type.transportation = 107
Type.nightclub = 108

Type.egg_collector = 197
Type.upbringing_station = 198
Type.pharmacy = 199
Type.hospital = 200
Type.psych_ward = 201
Type.intensive_care_unit = 202
Type.gene_clinic = 203
Type.improvised_hospital = 230

-- crafting machines

Type.assembling_machine = 1001
Type.furnace = 1002
Type.rocket_silo = 1003
Type.mining_drill = 1004

-- ..with custom behaviour

Type.manufactory = 1101
Type.fishery = 1102
Type.hunting_hut = 1103
Type.farm = 1104
Type.automatic_farm = 1105
Type.animal_farm = 1106
Type.waterwell = 1107
Type.salt_pond = 1108

-- misc container types

Type.composter = 1200
Type.composter_output = 1201
Type.plant_care_station = 1202
Type.cooling_warehouse = 1203
Type.waste_dump = 1204

Type.turret = 2000
Type.lab = 2001

Type.city_combinator = 3000

Type.null = 9999

return Type
