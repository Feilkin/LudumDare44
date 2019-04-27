local class = require "middleclass"

local Spritesheet = class("Spritesheet")

function Spritesheet:initialize(filename, sprite_data)
	self.image = love.graphics.newImage(filename)
	self.sprite_data = sprite_data
	self:prepareQuads()
end

function Spritesheet:prepareQuads()
	local quads = {}
	local sw, sh = self.image:getDimensions()

	for name, q in pairs(self.sprite_data) do
		local quad = love.graphics.newQuad(q[1], q[2], q[3], q[4], sw, sh)
		quads[name] = { quad = quad, offset = { q[5] or 0, q[6] or 0 }}
	end

	self.quads = quads
end

function Spritesheet:getQuad(name)
	return self.quads[name]
end

function Spritesheet:newSpritebatch(...)
	return love.graphics.newSpriteBatch(self.image, ...)
end

return Spritesheet