local guns = {
	shotgun = require "guns.shotgun",
}

local gun_meta = {}
gun_meta.__index = gun_meta

function gun_meta:canShoot()
	return (#self.magazine > 0) and
	       ((not self.cooldown) or
	       (self.cooldown < 0))
end

function gun_meta:popAmmo()
	assert(#self.magazine > 0, "magazine is empty!")

	return table.remove(self.magazine, 1)
end

function gun_meta:pushAmmo(ammo)
	assert(#self.magazine < self.mag_size, "magazine is full!")

	table.insert(self.magazine, ammo)
end

for name, class in pairs(guns) do
	setmetatable(class, gun_meta)
end

function guns.new(name)
	local class = assert(guns[name], "invalid gun type")
	local gun = setmetatable({}, { __index = class })

	gun.magazine = {}

	return gun
end

return guns