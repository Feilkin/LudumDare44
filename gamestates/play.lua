local pprint = require "pprint"
local sti = require "sti"
local tiny = require "tiny"
local Camera = require "hump.camera"
local bump = require "bump"
local Spritesheet = require "spritesheet"

-- entity classes
local entity_classes = {
    player = require "entities.player",
    zombie = require "entities.zombie",
}

local guns = require "guns"

local state = {}

function state:enter(previous)
    self:initWorld()
    self:loadMap()

    -- camera
    self.camera = Camera(0, 0)
    self.world.camera = self.camera

    self:spawnPlayer()

    self.spritesheets = {}
    self.spritebatches = {}
    self:loadSpritesheet("sprites")
    self.world.sheets = self.spritesheets
    self.world.batches = self.spritebatches
end

function state:initWorld()
    local world = tiny.world(
        require "systems.player_input_sys",
        require "systems.movement_sys",
        require "systems.bullet_sys",
        require "systems.animation_sys",
        require "systems.render_entities_sys"
    )
    
    self.world = world
end

function state:loadSpritesheet(name)
    local data = love.filesystem.load("res/sprites/" .. name ..".lua")
    local sheet = Spritesheet("res/sprites/" .. name ..".png", data())
    local batch = sheet:newSpritebatch( 2048, "stream")

    self.spritesheets[name] = sheet
    self.spritebatches[name] = batch
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

    local world = self.world
    function entityLayer:draw()
        world:update(1, tiny.requireAll("rendering"))
    end

    -- run spawners
    for _, spawner in ipairs(map:findAll("objects", "EntitySpawner")) do
        local entity = self:newEntity(spawner)
        self.world:addEntity(entity)
    end
end

function state:newEntity(spawner)
    local enemy_class = entity_classes[spawner.properties.EntityClass]
    local entity = setmetatable({}, { __index = enemy_class })

    entity.position = Vector(spawner.x, spawner.y)
    entity.velocity = Vector(0, 0)

    if spawner.properties.EntityClass == "player" then
        self.player = entity
    end

    return entity
end

function state:spawnPlayer()
    self.player.gun:pushAmmo(require "projectiles.buckshot")
    self.player.gun:pushAmmo(require "projectiles.buckshot")
    self.player.gun:pushAmmo(require "projectiles.buckshot")
end

function state:leave()
end

function state:update(dt)
    self.world:update(dt, tiny.rejectAll("rendering"))
    self.camera:lookAt(self.player.position.x, self.player.position.y)
    self.map:update(dt)
end

function state:draw()
    local cx, cy = self.camera:position()
    local gw, gh = love.graphics.getDimensions()
    self.map:draw(-cx + gw/2, -cy + gh/2, 1, 1)

    -- ammo count
    do
        local gun = self.player.gun
        local c = #gun.magazine
        local m = gun.mag_size
        love.graphics.print(string.format("%d / %d", c, m), 0, 0)
    end
end

return state
