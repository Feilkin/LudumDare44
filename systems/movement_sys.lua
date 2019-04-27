local tiny = require "tiny"

local movement_sys = tiny.processingSystem()
movement_sys.filter = tiny.requireAll("position", "velocity", "body")

function movement_sys:onAdd(e)
	local x, y = e.position:unpack()
	local w, h = e.body.width, e.body.height
	self.world.bump_world:add(e, x, y, w, h)
end

function movement_sys:onRemove(e)
	self.world.bump_world:remove(e)
end

function movement_sys:process(e, dt)
	local b_world = self.world.bump_world
	local target_position = e.position + e.velocity * dt
	local actual_x, actual_y = b_world:move(e, target_position.x, target_position.y)
	e.position.x, e.position.y = actual_x, actual_y
end

return movement_sys