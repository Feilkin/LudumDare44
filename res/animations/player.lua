return {
	idle = { "player_idle_1", "player_idle_2", "player_idle_1", framerate = 3, loop = true },
	walk = { "player_walk_1", "player_walk_2", "player_walk_1", "player_idle_1", "player_walk_3",
		"player_walk_4", "player_walk_3", "player_idle_1",
		framerate = 12, loop = true, per_frame = function(frame)
			if frame == 2 or frame == 6 then
				Signal.emit("play_sound", "effects", "walk")
			end
		end,
	},
}