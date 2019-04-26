-- my LD43 entry
--
-- (c) feilkin 2018
-- github.com/feilkin
-- twitter.com/feilkin

love.filesystem.setRequirePath("?.lua;?/init.lua;lib/?.lua;lib/?/init.lua")

-- lovebird for debugging
lovebird = require "lovebird"

-- some globals to speed things up
Gamestate = require "hump.gamestate"
Timer = require "hump.timer"
Signal = require "hump.signal"
Vector = require "hump.vector"

GAMESTATES = {
    play = require "gamestates.play",
}

function love.load(args)
    Gamestate.registerEvents()

    local state_name = args[1] or "play"
    Gamestate.switch(GAMESTATES[state_name])
end

function love.update(dt)
    lovebird.update()
end
