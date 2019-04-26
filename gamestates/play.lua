local pprint = require "pprint"
local sti = require "sti"

local state = {}

function state:enter(previous, host, server)
end


function state:leave()
end

function state:getMousePos()
end

function state:update(dt)
end

function state:mousemoved(x, y, dx, dy, istouch)
end

function state:keypressed(key, code)
end

function state:draw()
end

return state
