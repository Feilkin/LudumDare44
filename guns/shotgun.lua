-- semiauto tube fed shotgun
local Shotgun = {
	name = "shotgun",
	mag_size = 10,
	spread = 0.3,
	speed_variation = 0.1,
	firerate = 600,
	ammo_types = {
		buckshot = require "projectiles.buckshot"
	}
}

function Shotgun:shoot(pos, dir)
	-- get next round from the mag
	local ammo = self:popAmmo()
	local bullets = {}

	for i = 1, ammo.pellets do
		local spread_angle = love.math.random() * self.spread - self.spread / 2
		local direction = Vector.fromPolar(dir:angleTo() + spread_angle, 1)
		local position = pos:clone()
		local speed_spread = love.math.random() * self.speed_variation - self.speed_variation / 2

		local bullet = setmetatable({
			bullet = true,
			velocity = direction * (ammo.speed * (1 + speed_spread)),
			position = position,
		}, { __index = ammo })

		table.insert(bullets, bullet)
	end

	self.cooldown = 60/self.firerate

	return bullets
end

return Shotgun