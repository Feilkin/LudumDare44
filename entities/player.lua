local Animation = require "animation"
local guns = require "guns"

return {
    sprite = "player_idle_1",
    spritesheet = "sprites",
    animation = Animation("res/animations/player.lua", "idle"),
    body = {
        width = 60,
        height = 60,
    },
    position = Vector(0, 0),
    player_controller = 1,
    velocity = Vector(0, 0),
    speed = {
        walk = 300,
        run = 600,
    },
    gun = guns.new("shotgun")
}