local state = {}

function state:enter(previous, host)
	self.splash_img = love.graphics.newImage("res/Splash1.png")
	local timer = Timer.new()
	timer:after(1, function () Gamestate.switch(GAMESTATES.play) end)
	self.timer = timer
end

function state:leave()
	self.timer = nil
end

function state:update(dt)
	self.timer:update(dt)
end

function state:draw()
	local splash_img = self.splash_img
	local lg = love.graphics
	local gw, gh = lg.getDimensions()
	local iw, ih = splash_img:getDimensions()

	lg.draw(self.splash_img, 0, 0, 0, gw/iw, gh/ih)
end

return state
