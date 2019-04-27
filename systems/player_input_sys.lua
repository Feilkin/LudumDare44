local tiny = require "tiny"

local input_sys = tiny.processingSystem()
input_sys.filter = tiny.requireAll("player_controller", "position", "velocity")

function input_sys:process(e, dt)
	e.velocity.x, e.velocity.y = 0, 0
	-- keyboard + mouse
	if e.player_controller == 1 then
		if love.keyboard.isDown("w") then
			e.velocity.y = -e.speed.walk
		elseif love.keyboard.isDown("s") then
			e.velocity.y = e.speed.walk
		end
		if love.keyboard.isDown("a") then
			e.velocity.x = -e.speed.walk
		elseif love.keyboard.isDown("d") then
			e.velocity.x = e.speed.walk
		end
	end
end

return input_sys