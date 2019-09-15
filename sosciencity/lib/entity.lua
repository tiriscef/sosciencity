Entity = {}

function Entity:get(name)
    local entity_types = {
        'container',
        'assembling-machine',
        'accumulator',
        'ammo-turret',
        'arithmetic-combinator',
        'arrow',
        'artillery-flare',
        'artillery-projectile',
        'artillery-turret',
        'artillery-wagon',
        'beacon',
        'beam',
        'boiler',
        'car',
        'cargo-wagon',
        'character-corpse',
        'cliff',
        'combat-robot',
        'constant-combinator',
        'construction-robot',
        'corpse',
        'curved-rail',
        'decider-combinator',
        'deconstructible-tile-proxy',
        'decorative',
        'electric-energy-interface',
        'electric-pole',
        'electric-turret',
        'entity-ghost',
        'explosion',
        'fire',
        'fish',
        'flame-thrower-explosion',
        'fluid-turret',
        'fluid-wagon',
        'flying-text',
        'furnace',
        'gate',
        'generator',
        'god-controller',
        'heat-pipe',
        'infinity-container',
        'inserter',
        'item-entity',
        'item-request-proxy',
        'lab',
        'lamp',
        'land-mine',
        'leaf-particle',
        'loader',
        'locomotive',
        'logistic-container',
        'logistic-robot',
        'mining-drill',
        'offshore-pump',
        'particle',
        'particle-source',
        'pipe',
        'pipe-to-ground',
        'player',
        'player-port',
        'power-switch',
        'programmable-speaker',
        'projectile',
        'pump',
        'radar',
        'rail-chain-signal',
        'rail-remnants',
        'rail-signal',
        'reactor',
        'resource',
        'roboport',
        'rocket-silo',
        'rocket-silo-rocket',
        'rocket-silo-rocket-shadow',
        'simple-entity',
        'simple-entity-with-force',
        'simple-entity-with-owner',
        'smoke',
        'smoke-with-trigger',
        'solar-panel',
        'splitter',
        'sticker',
        'storage-tank',
        'straight-rail',
        'stream',
        'tile-ghost',
        'train-stop',
        'transport-belt',
        'tree',
        'turret',
        'underground-belt',
        'unit',
        'unit-spawner',
        'wall'
    }
    new = Prototype:get(item_types, name)
    setmetatable(new, self)
    return new
end

function Entity:__call(name)
    return self:get(name)
end

function Entity:create(prototype)
    data:extend {prototype}
    return self.get(prototype.name)
end
