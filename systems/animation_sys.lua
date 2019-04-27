local tiny = require "tiny"

local animationSystem = tiny.processingSystem()
animationSystem.filter = tiny.requireAll("animation")

function animationSystem:process(e, dt)
	e.animation:update(dt)

	if e.properties and (not e.sprite) then
		e.properties.sprite = e.animation:getFrame()
	else
		e.sprite = e.animation:getFrame()
	end

end

return animationSystem