local tiny = require "tiny"

local input_sys = tiny.processingSystem()
input_sys.filter = tiny.requireAll("player_controller", "position", "velocity")

function input_sys:process(e, dt)
	e.velocity.x, e.velocity.y = 0, 0
	
	if e.gun and e.gun.cooldown then
		e.gun.cooldown = e.gun.cooldown - dt
		if e.gun.cooldown < 0 then
			e.gun.cooldown = nil
		end
	end

	-- keyboard + mouse
	if e.player_controller == 1 then
		-- movement
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

		-- looking
		local mx, my = self.world.camera:mousePosition()
		e.direction = Vector(
			mx - (e.position.x + e.body.width/2),
			my - (e.position.y + e.body.height/2)):normalized()

		-- shooting
		if love.mouse.isDown(1) then
			if e.gun and e.gun:canShoot() then
				local pos = e.position + Vector(e.body.width / 2, e.body.height / 2)
				local bullets = e.gun:shoot(pos, e.direction)
				for _, b in ipairs(bullets) do
					self.world:addEntity(b)
				end
			end
		end

		-- reloading
		if love.keyboard.isDown("r") then
			for i = #e.gun.magazine + 1, e.gun.mag_size do
				e.gun:pushAmmo(require "projectiles.buckshot")
			end
		end
	end
end

return input_sys