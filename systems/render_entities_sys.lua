local tiny = require "tiny"
local pprint = require "pprint"

local render_entities_sys = tiny.processingSystem()
render_entities_sys.filter = tiny.requireAll("position",
	tiny.requireAny("bullet",
		tiny.requireAll("sprite", "spritesheet", "body")))
render_entities_sys.rendering = true


function render_entities_sys:preWrap(dt)
	for name, b in pairs(self.world.batches) do
		b:clear()
	end
end

function render_entities_sys:postWrap(dt)
	for name, b in pairs(self.world.batches) do
		love.graphics.draw(b)
	end
end

function render_entities_sys:process(e, dt)
	if e.bullet then
		love.graphics.setColor(1, 0.86, 0.12)
		love.graphics.circle("fill", e.position.x, e.position.y, 2)
		local x1, y1 = (e.last_pos or e.position):unpack()
		local x2, y2 = e.position:unpack()
		love.graphics.line(x1, y1, x2, y2)
		love.graphics.setColor(1, 1, 1, 1)
	else
		local sheet = self.world.sheets[e.spritesheet]
		local batch = self.world.batches[e.spritesheet]
		local quad = assert(sheet:getQuad(e.sprite), "no quad ".. e.sprite)
		local x, y = e.position.x, e.position.y
		local w, h = e.body.width, e.body.height
		batch:add(quad.quad,
			x + (e.flip_x and w - 1 or 0) + 1 + quad.offset[1],
			y - 1 + quad.offset[2],
			e.direction and e.direction:angleTo() or 0,
			e.flip_x and -1 or 1,
			1,
			quad.offset[1],
			quad.offset[2]
			)


		if e.direction then -- lazor
			local x1, y1 = e.position:unpack()
			x1, y1 = x1 + e.body.width / 2, y1 + e.body.height / 2
			local mx, my = self.world.camera:mousePosition()
			local x2, y2 = mx, my

			-- cast ray
			local itemInfos, len = self.world.bump_world:querySegmentWithCoords(x1, y1, mx, my)

			for i = 1, len do
				local itemInfo = itemInfos[i]
				if itemInfo.item.layer and itemInfo.item.layer.name == "walls" then
					x2, y2 = itemInfo.x1, itemInfo.y1
					break
				end
			end

			love.graphics.setColor(1, 0, 0, 0.6)
			love.graphics.line(x1, y1, x2, y2)
			love.graphics.setColor(1, 1, 1, 1)
		end
	end
end

return render_entities_sys