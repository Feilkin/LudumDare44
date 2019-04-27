local pprint = require "pprint"
local sti = require "sti"
local tiny = require "tiny"
local Camera = require "hump.camera"
local bump = require "bump"

-- entity classes
local entity_classes = {
    zombie = require "entities.zombie",
}

local state = {}

function state:enter(previous)
    self:initWorld()
    self:loadMap()

    -- camera
    self.camera = Camera(0, 0)

    self:spawnPlayer()
end

function state:initWorld()
    local world = tiny.world(
        require "systems.player_input_sys",
        require "systems.movement_sys"
    )

    -- make player
    local player = self:newPlayer(1)
    world:addEntity(player)
    self.player = player
    
    self.world = world
end

function state:newPlayer(id)
    return {
        position = Vector(0, 0),
        player_controller = id,
        velocity = Vector(0, 0),
        speed = {
            walk = 300,
            run = 600,
        }
    }
end

function state:loadMap()
    local map = sti("res/maps/map01.lua", { "bump" })
    self.map = map

    -- initialize bump.lua
    local bump_world = bump.newWorld(256)
    map:bump_init(bump_world)
    self.bump_world = bump_world
    self.world.bump_world = bump_world

    -- monkeypatch STI
    self.map.findObject = function (self, layername, name)
        for _, v in ipairs(self.layers[layername].objects) do
            if v.name == name then return v end
        end
    end

    self.map.findAll = function (self, layername, type)
        local ret = {}
        for _, v in ipairs(self.layers[layername].objects) do
            if v.type == type then table.insert(ret, v) end
        end

        return ret
    end

    -- set up entity layer for rendering
    map:addCustomLayer("Entity Layer", 3)

    local entityLayer = map.layers["Entity Layer"]

    function entityLayer:draw()
        for _, entity in ipairs(self.entities) do
            if entity.color then
                love.graphics.setColor(entity.color)
            end
            love.graphics.circle("fill", entity.position.x + 32, entity.position.y + 32, 32)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    entityLayer.entities = { self.player }

    -- run spawners
    for _, spawner in ipairs(map:findAll("objects", "EntitySpawner")) do
        local entity = self:newEntity(spawner)
        table.insert(entityLayer.entities, entity)
        self.world:addEntity(entity)
    end
end

function state:newEntity(spawner)
    local enemy_class = entity_classes[spawner.properties.EntityClass]
    local entity = {}

    entity.position = Vector(spawner.x, spawner.y)
    entity.velocity = Vector(0, 0)
    entity.ai = enemy_class.ai

    return entity
end

function state:spawnPlayer()
    local spawn = self.map:findObject("objects", "spawn_01")
    self.player.position.x, self.player.position.y = spawn.x, spawn.y
end

function state:leave()
end

function state:update(dt)
    self.world:update(dt)
    self.camera:lookAt(self.player.position.x, self.player.position.y)
    self.map:update(dt)
end

function state:draw()
    local cx, cy = self.camera:position()
    local gw, gh = love.graphics.getDimensions()
    self.map:draw(-cx + gw/2, -cy + gh/2, 1, 1)
end

return state
