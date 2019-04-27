local tiny = require "tiny"
local pprint = require "pprint"

local bullet_sys = tiny.processingSystem()
bullet_sys.filter = tiny.requireAll("bullet", "position", "velocity")

function bullet_filter(i)
	return not i.player_controller
end

function bullet_sys:process(e, dt)
	local b_world = self.world.bump_world

	local x1, y1 = e.position:unpack()
	e.last_pos = e.position:clone()
	e.position = e.position + e.velocity * dt
	local x2, y2 = e.position:unpack()

	local itemInfos, len = b_world:querySegmentWithCoords(x1, y1, x2, y2, bullet_filter)

	for _, itemInfo in ipairs(itemInfos) do
		-- check if we hit a wall
		if itemInfo.item.layer and itemInfo.item.layer.name == "walls" then
			-- TOOD: ricochet
			self.world:removeEntity(e)

			e.position = Vector(itemInfo.x1, itemInfo.y1)
			return
		else
			if itemInfo.item.health then
				itemInfo.item.health = itemInfo.item.health - e.damage

				if itemInfo.item.health <= 0 then
					Signal.emit("entity_died", { entity = itemInfo.item, col = itemInfo })
					self.world:removeEntity(itemInfo.item)
				else
					Signal.emit("entity_hit", { bullet = e, col = itemInfo })
				end

				e.penetration = e.penetration - 1
				if e.penetration <= 0 then
					self.world:removeEntity(e)
				end
			end
		end
	end
end

return bullet_sys