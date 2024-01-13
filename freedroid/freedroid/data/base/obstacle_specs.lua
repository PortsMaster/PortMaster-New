--[[
							Obstacle Flags:

	IS_WALL					 (Not in use? Can we remove this?)

	Flags for walls so that the wall-drawing function of the editor knows what to do:
	IS_HORIZONTAL
	IS_VERTICAL
	CORNER_NE
	CORNER_NW
	CORNER_SE
	CORNER_SW

	BLOCKS_VISION_TOO		 Light will not pass through this obstacle, it will cast realtime-"shadow"
	IS_SMASHABLE			 Obstacle can be destroyed (barrels/chests/glasswalls)
	DROPS_RANDOM_TREASURE	 Obstacle drops items on destruction (barrels/chests)
	NEEDS_PRE_PUT			 Obstacle will be displayed underneath of most other obstacles (useful for blood/droidnests etc which should not render partly on top of nearby walls)
	GROUND_LEVEL			 Obstacle does not block bullets
	IS_WALKABLE				 Obstacle can be walked through although it has a collision rectangle ("closed"-frames of animated doors etc)
	IS_CLICKABLE   			 Obstacle can be clicked on
	IS_VOLATILE 			 Obstacle vanishes after vanish_delay and when level respawns (blood/oil...)
]]--

function borders(left, right, upper, lower)
	if upper == nil then
		return { -left / 2, left / 2, -right / 2, right / 2 }
	end
	return { left, right, upper, lower }
end

-- #0
obstacle {
	image_filenames = "iso_tree_stump.png",
	borders = borders(0.60, 0.60),
	transparency = NO_TRANSPARENCY,
}

-- #1
obstacle {
	image_filenames = "iso_wall_grey_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL, BLOCKS_VISION },
}

-- #2
obstacle {
	image_filenames = "iso_wall_grey_ew.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
}

-- #3
obstacle {
	image_filenames = "iso_wall_grey_handle_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL, BLOCKS_VISION },
}

-- #4
obstacle {
	image_filenames = "iso_wall_grey_handle_ew.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
}

-- #5
obstacle {
	image_filenames = "iso_tree_big.png",
	borders = borders(1.30, 1.30),
	transparency = NO_TRANSPARENCY,
}

-- #6
obstacle {
	image_filenames = "iso_door_unlocked_closed_we_1.png",
	borders = borders(1.00, 0.40),
	flags = { IS_HORIZONTAL, IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
	groups = "blue doors"
}

-- #7
obstacle {
	image_filenames = "iso_door_unlocked_opened_we_2.png",
	borders = borders(1.00, 0.40),
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #8
obstacle {
	image_filenames = "iso_door_unlocked_opened_we_3.png",
	borders = borders(1.00, 0.40),
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #9
obstacle {
	image_filenames = "iso_door_unlocked_opened_we_4.png",
	borders = borders(1.00, 0.40),
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #10
obstacle {
	image_filenames = "iso_door_unlocked_opened_we_5.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #11
obstacle {
	image_filenames = "iso_door_unlocked_closed_ns_1.png",
	borders = borders(0.40, 1.00),
	flags = { IS_VERTICAL, IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
	groups = "blue doors"
}

-- #12
obstacle {
	image_filenames = "iso_door_unlocked_opened_ns_2.png",
	borders = borders(0.40, 1.00),
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #13
obstacle {
	image_filenames = "iso_door_unlocked_opened_ns_3.png",
	borders = borders(0.40, 1.00),
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #14
obstacle {
	image_filenames = "iso_door_unlocked_opened_ns_4.png",
	borders = borders(0.40, 1.00),
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #15
obstacle {
	image_filenames = "iso_door_unlocked_opened_ns_5.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #16
obstacle {
	image_filenames = { "iso_purplecloud_3.png", "iso_purplecloud_4.png", "iso_purplecloud_5.png", "iso_purplecloud_1.png", "iso_purplecloud_2.png" },
	emitted_light_strength = { 20, 19, 18, 19, 20 },
	transparency = NO_TRANSPARENCY,
	animation_fps = 10
}

-- #17
obstacle {
	image_filenames = { "iso_teleport_1.png", "iso_teleport_2.png", "iso_teleport_3.png", "iso_teleport_4.png", "iso_teleport_5.png" },
	emitted_light_strength = { 20, 19, 18, 19, 20 },
	transparency = NO_TRANSPARENCY,
	animation_fps = 10
}

-- #18
obstacle {
	image_filenames = { "iso_droidnest_red_1.png", "iso_droidnest_red_2.png", "iso_droidnest_red_3.png", "iso_droidnest_red_4.png", "iso_droidnest_red_5.png" },
	flags = { NEEDS_PRE_PUT },
	emitted_light_strength = 10,
	transparency = NO_TRANSPARENCY,
	animation_fps = 5
}

-- #19
obstacle {
	image_filenames = { "iso_droidnest_blue_1.png", "iso_droidnest_blue_2.png", "iso_droidnest_blue_3.png", "iso_droidnest_blue_4.png", "iso_droidnest_blue_5.png" },
	flags = { NEEDS_PRE_PUT },
	emitted_light_strength = 10,
	transparency = NO_TRANSPARENCY,
	animation_fps = 1
}

-- #20
obstacle {
	image_filenames = { "iso_droidnest_yellow_1.png", "iso_droidnest_yellow_2.png", "iso_droidnest_yellow_3.png", "iso_droidnest_yellow_4.png", "iso_droidnest_yellow_5.png" },
	flags = { NEEDS_PRE_PUT },
	emitted_light_strength = 10,
	transparency = NO_TRANSPARENCY,
	animation_fps = 14
}
-- #21
obstacle {
	image_filenames = { "iso_droidnest_green_1.png", "iso_droidnest_green_2.png", "iso_droidnest_green_3.png", "iso_droidnest_green_4.png", "iso_droidnest_green_5.png" },
	flags = { NEEDS_PRE_PUT },
	emitted_light_strength = 10,
	transparency = NO_TRANSPARENCY,
	animation_fps = 3
}

-- #22
obstacle {
	image_filenames = "floor_tiles/iso_collapsingfloor_visible.png",
	borders = borders(0.00, 0.00),
	flags = { GROUND_LEVEL, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
}

-- #23
obstacle {
	image_filenames = "iso_trapdoor_w.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #24
obstacle {
	image_filenames = "iso_trapdoor_n.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #25
obstacle {
	image_filenames = "DUMMY OBSTACLE"
}

-- #26
obstacle {
	image_filenames = "iso_door_locked_we.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL },
	transparency = NO_TRANSPARENCY,
	groups = "red door"
}

-- #27
obstacle {
	image_filenames = "iso_door_locked_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL },
	transparency = NO_TRANSPARENCY,
	groups = "red door"
}

-- #28
obstacle {
	image_filenames = "iso_chest_grey_closed_n.png",
	label = _"Chest",
	borders = borders(0.80, 0.60),
	flags = { GROUND_LEVEL, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "chest",
	after_looting = 30,
}

-- #29
obstacle {
	image_filenames = "iso_chest_grey_closed_w.png",
	label = _"Chest",
	borders = borders(0.60, 0.80),
	flags = { GROUND_LEVEL, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "chest",
	after_looting = 31,
}

-- #30
obstacle {
	image_filenames = "iso_chest_grey_opened_n.png",
	borders = borders(0.80, 0.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #31
obstacle {
	image_filenames = "iso_chest_grey_opened_w.png",
	borders = borders(0.60, 0.80),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #32
obstacle {
	image_filenames = "iso_autogun_on_w.png",
	borders = borders(0.70, 0.70),
	transparency = NO_TRANSPARENCY,
	animation = "autogun",
}

-- #33
obstacle {
	image_filenames = "iso_autogun_on_n.png",
	borders = borders(0.70, 0.70),
	transparency = NO_TRANSPARENCY,
	animation = "autogun",
}

-- #34
obstacle {
	image_filenames = "iso_autogun_on_e.png",
	borders = borders(0.70, 0.70),
	transparency = NO_TRANSPARENCY,
	animation = "autogun",
}

-- #35
obstacle {
	image_filenames = "iso_autogun_on_s.png",
	borders = borders(0.70, 0.70),
	transparency = NO_TRANSPARENCY,
	animation = "autogun",
}

-- #36
obstacle {
	image_filenames = "iso_wall_cave_we.png",
	borders = borders(1.50, 1.00),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
	groups = "cave wall"
}

-- #37
obstacle {
	image_filenames = "iso_wall_cave_ns.png",
	borders = borders(1.00, 1.50),
	flags = { IS_VERTICAL, BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
	groups = "cave wall"
}

-- #38
obstacle {
	image_filenames = "iso_wall_cave_curve_ws.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION, CORNER_NE },
	transparency = NO_TRANSPARENCY,
	groups = "cave wall"
}

-- #39
obstacle {
	image_filenames = "iso_wall_cave_curve_nw.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION, CORNER_SE },
	transparency = NO_TRANSPARENCY,
	groups = "cave wall"
}

-- #40
obstacle {
	image_filenames = "iso_wall_cave_curve_es.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION, CORNER_NW },
	transparency = NO_TRANSPARENCY,
	groups = "cave wall"
}

-- #41
obstacle {
	image_filenames = "iso_wall_cave_curve_ne.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION, CORNER_SW },
	transparency = NO_TRANSPARENCY,
	groups = "cave wall"
}

-- #42
obstacle {
	image_filenames = "iso_pot.png",
	borders = borders(0.50, 0.50),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #43
obstacle {
	image_filenames = "iso_terminal_s.png",
	label = _"Terminal",
	borders = borders(0.80, 0.80),
	flags = { IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #44
obstacle {
	image_filenames = "iso_terminal_e.png",
	label = _"Terminal",
	borders = borders(0.80, 0.80),
	flags = { IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #45
obstacle {
	image_filenames = "iso_terminal_n.png",
	label = _"Terminal",
	borders = borders(0.80, 0.80),
	flags = { IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #46
obstacle {
	image_filenames = "iso_terminal_w.png",
	label = _"Terminal",
	borders = borders(0.80, 0.80),
	flags = { IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #47
obstacle {
	image_filenames = "iso_pillar_high.png",
	borders = borders(-0.50, 0.25, -0.50, 0.25),
	transparency = NO_TRANSPARENCY,
}

-- #48
obstacle {
	image_filenames = "iso_pillar_short.png",
	borders = borders(-0.50, 0.25, -0.50, 0.25),
	transparency = NO_TRANSPARENCY,
}

-- #49
obstacle {
	image_filenames = "iso_computerpillar_e.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #50
obstacle {
	image_filenames = "iso_barrel.png",
	label = _"Barrel",
	borders = borders(0.70, 0.70),
	flags = { BLOCKS_VISION, IS_SMASHABLE, DROPS_RANDOM_TREASURE, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "barrel",
}

-- #51
obstacle {
	image_filenames = "iso_barrel_rusty.png",
	label = _"Barrel",
	borders = borders(0.70, 0.70),
	flags = { BLOCKS_VISION, IS_SMASHABLE, DROPS_RANDOM_TREASURE, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "barrel",
}

-- #52
obstacle {
	image_filenames = "iso_crate_ns.png",
	label = _"Crate",
	borders = borders(0.80, 0.95),
	flags = { BLOCKS_VISION, IS_SMASHABLE, DROPS_RANDOM_TREASURE, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "barrel",
}

-- #53
obstacle {
	image_filenames = "iso_crate_we.png",
	label = _"Crate",
	borders = borders(0.80, 0.75),
	flags = { BLOCKS_VISION, IS_SMASHABLE, DROPS_RANDOM_TREASURE, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "barrel",
}

-- #54
obstacle {
	image_filenames = "iso_lamp_s.png",
	borders = borders(0.50, 0.50),
	flags = { GROUND_LEVEL },
	emitted_light_strength = 24,
	transparency = NO_TRANSPARENCY,
}

-- #55
obstacle {
	image_filenames = "iso_raylamp_right.png",
	borders = borders(-0.60, 0.55, -0.60, 0.50),
	transparency = NO_TRANSPARENCY,
}

-- #56
obstacle {
	image_filenames = "iso_raylamp_down.png",
	borders = borders(-0.60, 0.55, -0.60, 0.55),
	transparency = NO_TRANSPARENCY,
}

-- #57
obstacle {
	image_filenames = "iso_raylamp_left.png",
	borders = borders(-0.60, 0.50, -0.60, 0.55),
	transparency = NO_TRANSPARENCY,
}

-- #58
obstacle {
	image_filenames = "iso_raylamp_up.png",
	borders = borders(-0.60, 0.50, -0.60, 0.50),
	transparency = NO_TRANSPARENCY,
}

-- #59
obstacle {
	image_filenames = "iso_fence_white_ns.png",
	borders = borders(1.10, 2.20),
	transparency = NO_TRANSPARENCY,
}

-- #60
obstacle {
	image_filenames = "iso_fence_white_we.png",
	borders = borders(2.20, 1.10),
	transparency = NO_TRANSPARENCY,
}

-- #61
obstacle {
	image_filenames = "iso_trapdoor_closed_n.png",
	borders = borders(1.00, 1.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #62
obstacle {
	image_filenames = "iso_trapdoor_closed_w.png",
	borders = borders(1.00, 1.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #63
obstacle {
	image_filenames = "iso_fence_wire_red_ns.png",
	borders = borders(0.80, 2.20),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #64
obstacle {
	image_filenames = "iso_fence_wire_red_we.png",
	borders = borders(2.20, 0.80),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #65
obstacle {
	image_filenames = "iso_fence_wire_green_ns.png",
	borders = borders(0.80, 2.20),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #66
obstacle {
	image_filenames = "iso_fence_wire_green_we.png",
	borders = borders(2.20, 0.80),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #67
obstacle {
	image_filenames = "iso_urinal_w.png",
	borders = borders(0.40, 0.40),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #68
obstacle {
	image_filenames = "iso_urinal_s.png",
	borders = borders(0.40, 0.40),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #69
obstacle {
	image_filenames = "iso_toilet_white_s.png",
	borders = borders(0.40, 0.40),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #70
obstacle {
	image_filenames = "iso_toilet_white_e.png",
	borders = borders(0.40, 0.40),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #71
obstacle {
	image_filenames = "iso_toilet_beige_w.png",
	borders = borders(0.68, 0.50),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #72
obstacle {
	image_filenames = "iso_toilet_beige_n.png",
	borders = borders(0.50, 0.68),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #73
obstacle {
	image_filenames = "iso_toilet_beige_e.png",
	borders = borders(0.68, 0.50),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #74
obstacle {
	image_filenames = "iso_toilet_beige_s.png",
	borders = borders(0.50, 0.68),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #75
obstacle {
	image_filenames = "iso_chair_brown_w.png",
	borders = borders(0.40, 0.40),
	flags = { IS_SMASHABLE },
	transparency = NO_TRANSPARENCY,
}

-- #76
obstacle {
	image_filenames = "iso_chair_brown_n.png",
	borders = borders(0.40, 0.40),
	flags = { IS_SMASHABLE },
	transparency = NO_TRANSPARENCY,
}

-- #77
obstacle {
	image_filenames = "iso_chair_brown_e.png",
	borders = borders(0.40, 0.40),
	flags = { IS_SMASHABLE },
	transparency = NO_TRANSPARENCY,
}

-- #78
obstacle {
	image_filenames = "iso_chair_brown_s.png",
	borders = borders(0.40, 0.40),
	flags = { IS_SMASHABLE },
	transparency = NO_TRANSPARENCY,
}

-- #79
obstacle {
	image_filenames = "iso_workdesk_w.png",
	borders = borders(0.40, 1.00),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #80
obstacle {
	image_filenames = "iso_workdesk_n.png",
	borders = borders(1.00, 0.40),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #81
obstacle {
	image_filenames = "iso_workdesk_e.png",
	borders = borders(0.40, 1.00),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #82
obstacle {
	image_filenames = "iso_workdesk_s.png",
	borders = borders(1.00, 0.40),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #83
obstacle {
	image_filenames = "iso_chair_white_w.png",
	borders = borders(0.40, 0.40),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #84
obstacle {
	image_filenames = "iso_chair_white_n.png",
	borders = borders(0.40, 0.40),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #85
obstacle {
	image_filenames = "iso_chair_white_s.png",
	borders = borders(0.40, 0.40),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #86
obstacle {
	image_filenames = "iso_chair_white_e.png",
	borders = borders(0.40, 0.40),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #87
obstacle {
	image_filenames = "iso_bed_white_w.png",
	borders = borders(1.10, 0.70),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #88
obstacle {
	image_filenames = "iso_bed_white_n.png",
	borders = borders(0.70, 1.10),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #89
obstacle {
	image_filenames = "iso_bed_white_e.png",
	borders = borders(1.10, 0.70),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #90
obstacle {
	image_filenames = "iso_bed_white_s.png",
	borders = borders(0.70, 1.10),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #91
obstacle {
	image_filenames = "iso_bookshelf_long_w.png",
	borders = borders(0.60, 2.20),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #92
obstacle {
	image_filenames = "iso_bookshelf_long_s.png",
	borders = borders(2.20, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #93
obstacle {
	image_filenames = "iso_bookshelf_long_e.png",
	borders = borders(0.60, 2.20),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #94
obstacle {
	image_filenames = "iso_bookshelf_long_n.png",
	borders = borders(2.20, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #95
obstacle {
	image_filenames = "iso_bookshelf_s.png",
	borders = borders(1.10, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #96
obstacle {
	image_filenames = "iso_bookshelf_e.png",
	borders = borders(0.60, 1.10),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #97
obstacle {
	image_filenames = "iso_bookshelf_w.png",
	borders = borders(0.60, 1.10),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #98
obstacle {
	image_filenames = "iso_bookshelf_n.png",
	borders = borders(1.10, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #99
obstacle {
	image_filenames = "iso_bench_white_w.png",
	borders = borders(0.70, 1.30),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #100
obstacle {
	image_filenames = "iso_bench_white_s.png",
	borders = borders(1.30, 0.70),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #101
obstacle {
	image_filenames = "iso_bench_white_n.png",
	borders = borders(1.30, 0.70),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #102
obstacle {
	image_filenames = "iso_bench_white_e.png",
	borders = borders(0.70, 1.30),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #103
obstacle {
	image_filenames = "iso_bathtub_w.png",
	borders = borders(1.50, 1.00),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #104
obstacle {
	image_filenames = "iso_bathtub_n.png",
	borders = borders(1.00, 1.50),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #105
obstacle {
	image_filenames = "iso_tub_ns.png",
	borders = borders(0.40, 0.50),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #106
obstacle {
	image_filenames = "iso_tub_we.png",
	borders = borders(0.50, 0.40),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #107
obstacle {
	image_filenames = "iso_curtain_ns.png",
	flags = { IS_VERTICAL, BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #108
obstacle {
	image_filenames = "iso_curtain_we.png",
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #109
obstacle {
	image_filenames = "iso_sofa_white_w.png",
	borders = borders(0.50, 1.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #110
obstacle {
	image_filenames = "iso_sofa_white_s.png",
	borders = borders(1.00, 0.50),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #111
obstacle {
	image_filenames = "iso_sofa_white_e.png",
	borders = borders(0.50, 1.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #112
obstacle {
	image_filenames = "iso_sofa_white_n.png",
	borders = borders(1.00, 0.50),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #113
obstacle {
	image_filenames = "iso_tree_1.png",
	borders = borders(0.60, 0.60),
	transparency = NO_TRANSPARENCY,
}

-- #114
obstacle {
	image_filenames = "iso_tree_2.png",
	borders = borders(0.60, 0.60),
	transparency = NO_TRANSPARENCY,
}

-- #115
obstacle {
	image_filenames = "iso_tree_3.png",
	borders = borders(0.60, 0.80),
	transparency = NO_TRANSPARENCY,
}

-- #116
obstacle {
	image_filenames = "iso_wall_purple_we.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
	groups = "thick wall"
}

-- #117
obstacle {
	image_filenames = "iso_wall_purple_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL, BLOCKS_VISION },
	groups = "thick wall"
}

-- #118
obstacle {
	image_filenames = "iso_wall_purple_curve_ws.png",
	borders = borders(-0.55, 0.20, -0.20, 0.55),
	flags = { BLOCKS_VISION, CORNER_NE },
	groups = "thick wall"
}

-- #119
obstacle {
	image_filenames = "iso_wall_purple_nw.png",
	borders = borders(-0.55, 0.20, -0.55, 0.20),
	flags = { BLOCKS_VISION, CORNER_SE },
	groups = "thick wall"
}

-- #120
obstacle {
	image_filenames = "iso_wall_purple_es.png",
	borders = borders(-0.20, 0.55, -0.20, 0.55),
	flags = { BLOCKS_VISION, CORNER_NW },
	groups = "thick wall"
}

-- #121
obstacle {
	image_filenames = "iso_wall_purple_ne.png",
	borders = borders(-0.20, 0.55, -0.55, 0.20),
	flags = { BLOCKS_VISION, CORNER_SW },
	groups = "thick wall"
}

-- #122
obstacle {
	image_filenames = "iso_wall_purple_T_nwe.png",
	borders = borders(-0.55, 0.55, -0.55, 0.20),
	flags = { BLOCKS_VISION },
}

-- #123
obstacle {
	image_filenames = "iso_wall_purple_T_nws.png",
	borders = borders(-0.20, 0.55, -0.55, 0.55),
	flags = { BLOCKS_VISION },
}

-- #124
obstacle {
	image_filenames = "iso_wall_purple_T_wes.png",
	borders = borders(-0.55, 0.55, -0.20, 0.55),
	flags = { BLOCKS_VISION },
}

-- #125
obstacle {
	image_filenames = "iso_wall_purple_T_ess.png",
	borders = borders(-0.55, 0.20, -0.55, 0.55),
	flags = { BLOCKS_VISION },
}

-- #126
obstacle {
	image_filenames = "iso_wall_cave_end_w.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #127
obstacle {
	image_filenames = "iso_wall_cave_end_n.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #128
obstacle {
	image_filenames = "iso_wall_cave_end_e.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #129
obstacle {
	image_filenames = "iso_wall_cave_end_s.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #130
obstacle {
	image_filenames = "iso_wall_grey_window_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL },
}

-- #131
obstacle {
	image_filenames = "iso_wall_grey_window_ew.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL },
}

-- #132
obstacle {
	image_filenames = "iso_wall_grey_striation_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL, BLOCKS_VISION },
}

-- #133
obstacle {
	image_filenames = "iso_wall_grey_striation_ew.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
}

-- #134
obstacle {
	image_filenames = "iso_wall_brick_we.png",
	borders = borders(1.20, 0.80),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
	after_smashing = 235,
	groups = "brick wall"
}

-- #135
obstacle {
	image_filenames = "iso_wall_brick_ns.png",
	borders = borders(0.80, 1.20),
	flags = { IS_VERTICAL, BLOCKS_VISION },
	after_smashing = 236,
	groups = "brick wall"
}

-- #136
obstacle {
	image_filenames = "iso_wall_brick_end_w.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION },
}

-- #137
obstacle {
	image_filenames = "iso_wall_brick_edge_ws.png",
	borders = borders(-0.60, 0.30, -0.60, 0.60),
	flags = { BLOCKS_VISION, CORNER_NE },
	groups = { "brick wall", "brick wall 2" }
}

-- #138
obstacle {
	image_filenames = "iso_wall_brick_edge_ne.png",
	borders = borders(-0.60, 0.65, -0.60, 0.30),
	flags = { BLOCKS_VISION, CORNER_SW },
	groups = { "brick wall", "brick wall 2" }
}

-- #139
obstacle {
	image_filenames = "iso_wall_brick_edge_es.png",
	borders = borders(-0.30, 0.60, -0.30, 0.60),
	flags = { BLOCKS_VISION, CORNER_NW },
	groups = { "brick wall", "brick wall 2" }
}

-- #140
obstacle {
	image_filenames = "iso_wall_brick_edge_nw.png",
	borders = borders(-0.60, 0.30, -0.60, 0.30),
	flags = { BLOCKS_VISION, CORNER_SE },
	groups = { "brick wall", "brick wall 2" }
}

-- #141
obstacle {
	image_filenames = "iso_blood_1.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "blood"
}

-- #142
obstacle {
	image_filenames = "iso_blood_3_1.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "blood"
}

-- #143
obstacle {
	image_filenames = "iso_blood_3_2.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "blood"
}

-- #144
obstacle {
	image_filenames = "iso_blood_3_3.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "blood"
}

-- #145
obstacle {
	image_filenames = "iso_blood_8.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "blood"
}

-- #146
obstacle {
	image_filenames = "iso_blood_4.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "blood"
}

-- #147
obstacle {
	image_filenames = "iso_blood_5.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "blood"
}

-- #148
obstacle {
	image_filenames = "iso_blood_10.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "blood"
}

-- #149
obstacle {
	image_filenames = "iso_trapdoor_s.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #150
obstacle {
	image_filenames = "iso_trapdoor_e.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #151
obstacle {
	image_filenames = "iso_shroom_white_1.png",
	borders = borders(0.40, 0.40),
	flags = { GROUND_LEVEL },
	emitted_light_strength = 10,
	transparency = NO_TRANSPARENCY,
}

-- #152
obstacle {
	image_filenames = "iso_rock_big.png",
	borders = borders(1.50, 1.50),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #153
obstacle {
	image_filenames = "iso_rock_small.png",
	flags = { BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
}

-- #154
obstacle {
	image_filenames = "iso_rock_pillar.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #155
obstacle {
	image_filenames = "iso_wall_red_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL, BLOCKS_VISION },
}

-- #156
obstacle {
	image_filenames = "iso_wall_red_we.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
}

-- #157
obstacle {
	image_filenames = "iso_wall_turqois_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL, BLOCKS_VISION },
}

-- #158
obstacle {
	image_filenames = "iso_wall_turqois_we.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
}

-- #159
obstacle {
	image_filenames = "iso_shop_counter_s.png",
	borders = borders(3.50, 1.50),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #160
obstacle {
	image_filenames = "iso_shop_counter_w.png",
	borders = borders(1.50, 3.50),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #161
obstacle {
	image_filenames = "iso_shelf_s.png",
	borders = borders(2.20, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #162
obstacle {
	image_filenames = "iso_shelf_e.png",
	borders = borders(0.60, 2.20),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #163
obstacle {
	image_filenames = "iso_shelf_n.png",
	borders = borders(2.20, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #164
obstacle {
	image_filenames = "iso_shelf_w.png",
	borders = borders(0.60, 2.20),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #165
obstacle {
	image_filenames = "iso_wall_yellow_ellipsis_we.png",
	borders = borders(-0.55, 0.55, -0.05, 0.60),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
	groups = "outer wall 1"
}

-- #166
obstacle {
	image_filenames = "iso_wall_yellow_ellipsis_dots_pipes_we.png",
	borders = borders(-0.55, 0.55, -0.05, 0.60),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
	groups = "outer wall 2"
}

-- #167
obstacle {
	image_filenames = "iso_wall_yellow_ellipsis_dots_we.png",
	borders = borders(-0.55, 0.55, -0.05, 0.60),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
	groups = "outer wall 3"
}

-- #168
obstacle {
	image_filenames = "iso_walls_yellow_we.png",
	borders = borders(-0.55, 0.55, -0.05, 0.60),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
	groups = "outer wall 4"
}

-- #169
obstacle {
	image_filenames = "iso_wall_yellow_dots_pipes_we.png",
	borders = borders(-0.55, 0.55, -0.05, 0.60),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
	groups = "outer wall 5"
}

-- #170
obstacle {
	image_filenames = "iso_wall_yellow_dots_we.png",
	borders = borders(-0.55, 0.55, -0.05, 0.60),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
	groups = "outer wall 6"
}

-- #171
obstacle {
	image_filenames = "iso_walls_yellow_ns.png",
	borders = borders(-0.05, 0.60, -0.55, 0.55),
	flags = { IS_VERTICAL, BLOCKS_VISION },
	groups = "outer wall 4"
}

-- #172
obstacle {
	image_filenames = "iso_wall_yellow_dots_pipes_ns.png",
	borders = borders(-0.05, 0.60, -0.55, 0.55),
	flags = { IS_VERTICAL, BLOCKS_VISION },
	groups = "outer wall 5"
}

-- #173
obstacle {
	image_filenames = "iso_wall_yellow_dots_ns.png",
	borders = borders(-0.05, 0.60, -0.55, 0.55),
	flags = { IS_VERTICAL, BLOCKS_VISION },
	groups = "outer wall 6"
}

-- #174
obstacle {
	image_filenames = "iso_wall_yellow_ellipsis_ns.png",
	borders = borders(-0.05, 0.60, -0.55, 0.55),
	flags = { IS_VERTICAL, BLOCKS_VISION },
	groups = "outer wall 1"
}

-- #175
obstacle {
	image_filenames = "iso_wall_yellow_ellipsis_dots_pipes_ns.png",
	borders = borders(-0.05, 0.60, -0.55, 0.55),
	flags = { IS_VERTICAL, BLOCKS_VISION },
	groups = "outer wall 2"
}

-- #176
obstacle {
	image_filenames = "iso_wall_yellow_ellipsis_dots_ns.png",
	borders = borders(-0.05, 0.60, -0.55, 0.55),
	flags = { IS_VERTICAL, BLOCKS_VISION },
	groups = "outer wall 3"
}

-- #177
obstacle {
	image_filenames = "iso_wall_yellow_curve_long_es.png",
	borders = borders(1.10, 1.10),
	flags = { BLOCKS_VISION, CORNER_NW },
	groups = { "outer wall 1", "outer wall 2", "outer wall 3", "outer wall 4", "outer wall 5", "outer wall 6" }
}

-- #178
obstacle {
	image_filenames = "iso_wall_yellow_curve_long_ne.png",
	borders = borders(1.10, 1.10),
	flags = { BLOCKS_VISION, CORNER_SW },
	groups = { "outer wall 1", "outer wall 2", "outer wall 3", "outer wall 4", "outer wall 5", "outer wall 6" }
}

-- #179
obstacle {
	image_filenames = "iso_wall_yellow_curve_long_nw.png",
	borders = borders(1.10, 1.10),
	flags = { BLOCKS_VISION, CORNER_SE },
	groups = { "outer wall 1", "outer wall 2", "outer wall 3", "outer wall 4", "outer wall 5", "outer wall 6" }
}

-- #180
obstacle {
	image_filenames = "iso_wall_yellow_curve_long_ws.png",
	borders = borders(1.10, 1.10),
	flags = { BLOCKS_VISION, CORNER_NE },
	groups = { "outer wall 1", "outer wall 2", "outer wall 3", "outer wall 4", "outer wall 5", "outer wall 6" }
}

-- #181
obstacle {
	image_filenames = "iso_gate_unlocked_closed_ns_1.png",
	borders = borders(-0.05, 0.60, -1.55, 0.55),
	flags = { IS_WALKABLE },
	animation = "door",
}

-- #182
obstacle {
	image_filenames = "iso_gate_unlocked_opened_ns_2.png",
	borders = borders(1.20, 1.20),
	flags = { IS_WALKABLE },
	animation = "door",
}

-- #183
obstacle {
	image_filenames = "iso_gate_unlocked_opened_ns_3.png",
	borders = borders(1.20, 1.20),
	flags = { IS_WALKABLE },
	animation = "door",
}

-- #184
obstacle {
	image_filenames = "iso_gate_unlocked_opened_ns_4.png",
	borders = borders(1.20, 1.20),
	flags = { IS_WALKABLE },
	animation = "door",
}

-- #185
obstacle {
	image_filenames = "iso_gate_unlocked_opened_ns_5.png",
	flags = { BLOCKS_VISION },
	animation = "door",
}

-- #186
obstacle {
	image_filenames = "iso_gate_unlocked_closed_we_1.png",
	borders = borders(-1.55, 0.55, -0.05, 0.60),
	flags = { IS_WALKABLE },
	animation = "door",
}

-- #187
obstacle {
	image_filenames = "iso_gate_unlocked_opened_we_2.png",
	borders = borders(1.20, 1.20),
	flags = { IS_WALKABLE },
	animation = "door",
}

-- #188
obstacle {
	image_filenames = "iso_gate_unlocked_opened_we_3.png",
	borders = borders(1.20, 1.20),
	flags = { IS_WALKABLE },
	animation = "door",
}

-- #189
obstacle {
	image_filenames = "iso_gate_unlocked_opened_we_4.png",
	borders = borders(1.20, 1.20),
	flags = { IS_WALKABLE },
	animation = "door",
}

-- #190
obstacle {
	image_filenames = "iso_gate_unlocked_opened_we_5.png",
	flags = { BLOCKS_VISION },
	animation = "door",
}

-- #191
obstacle {
	image_filenames = "iso_gate_locked_ns.png",
	borders = borders(-0.05, 0.60, -1.55, 0.55),
}

-- #192
obstacle {
	image_filenames = "iso_gate_locked_we.png",
	borders = borders(-1.55, 0.55, -0.05, 0.60),
}

-- #193
obstacle {
	image_filenames = "iso_computerpillar_n.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #194
obstacle {
	image_filenames = "iso_computerpillar_w.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #195
obstacle {
	image_filenames = "iso_computerpillar_s.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #196
obstacle {
	image_filenames = "iso_chairs_ball_s.png",
	borders = borders(0.80, 0.80),
	transparency = NO_TRANSPARENCY,
}

-- #197
obstacle {
	image_filenames = "iso_chairs_ball_w.png",
	borders = borders(0.80, 0.80),
	transparency = NO_TRANSPARENCY,
}

-- #198
obstacle {
	image_filenames = "iso_chairs_ball_n.png",
	borders = borders(0.80, 0.80),
	transparency = NO_TRANSPARENCY,
}

-- #199
obstacle {
	image_filenames = "iso_chairs_ball_e.png",
	borders = borders(0.80, 0.80),
	transparency = NO_TRANSPARENCY,
}

-- #200
obstacle {
	image_filenames = "iso_sofa_red_s.png",
	borders = borders(1.60, 0.80),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #201
obstacle {
	image_filenames = "iso_sofa_red_w.png",
	borders = borders(0.80, 1.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #202
obstacle {
	image_filenames = "iso_sofa_red_n.png",
	borders = borders(1.60, 0.80),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #203
obstacle {
	image_filenames = "iso_sofa_red_e.png",
	borders = borders(0.80, 1.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #204
obstacle {
	image_filenames = "iso_body_redguard_1.png",
	flags = { BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
}

-- #205
obstacle {
	image_filenames = "iso_body_redguard_2.png",
	flags = { BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
}

-- #206
obstacle {
	image_filenames = "iso_body_redguard_4.png",
	flags = { BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
}

-- #207
obstacle {
	image_filenames = "iso_body_redguard_3.png",
	flags = { BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
}

-- #208
obstacle {
	image_filenames = "iso_conference_table_nw.png",
	borders = borders(2.00, 2.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #209
obstacle {
	image_filenames = "iso_conference_table_ne.png",
	borders = borders(2.00, 2.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #210
obstacle {
	image_filenames = "iso_conference_table_es.png",
	borders = borders(2.00, 2.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #211
obstacle {
	image_filenames = "iso_conference_table_ws.png",
	borders = borders(2.00, 2.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #212
obstacle {
	image_filenames = "iso_wall_redbrownspiked_ns.png",
	borders = borders(0.80, 2.30),
}

-- #213
obstacle {
	image_filenames = "iso_wall_redbrownspiked_we.png",
	borders = borders(2.30, 0.80),
}

-- #214
obstacle {
	image_filenames = "iso_sleepingcapsule_n.png",
	borders = borders(1.20, 2.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #215
obstacle {
	image_filenames = "iso_sleepingcapsule_w.png",
	borders = borders(2.00, 1.20),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #216
obstacle {
	image_filenames = "iso_sleepingcapsule_s.png",
	borders = borders(1.20, 2.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #217
obstacle {
	image_filenames = "iso_sleepingcapsule_e.png",
	borders = borders(2.00, 1.20),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #218
obstacle {
	image_filenames = "iso_sleepingcapsule_double_n.png",
	borders = borders(1.20, 2.00),
	transparency = NO_TRANSPARENCY,
}

-- #219
obstacle {
	image_filenames = "iso_sleepingcapsule_double_e.png",
	borders = borders(2.00, 1.20),
	transparency = NO_TRANSPARENCY,
}

-- #220
obstacle {
	image_filenames = "iso_sleepingcapsule_double_s.png",
	borders = borders(1.20, 2.00),
	transparency = NO_TRANSPARENCY,
}

-- #221
obstacle {
	image_filenames = "iso_sleepingcapsule_double_w.png",
	borders = borders(2.00, 1.20),
	transparency = NO_TRANSPARENCY,
}

-- #222
obstacle {
	image_filenames = "iso_cinematograph_e.png",
	borders = borders(0.50, 0.50),
	transparency = NO_TRANSPARENCY,
}

-- #223
obstacle {
	image_filenames = "iso_cinematograph_w.png",
	borders = borders(0.50, 0.50),
	transparency = NO_TRANSPARENCY,
}

-- #224
obstacle {
	image_filenames = "iso_lamp_n.png",
	borders = borders(0.50, 0.50),
	flags = { GROUND_LEVEL },
	emitted_light_strength = 24,
	transparency = NO_TRANSPARENCY,
}

-- #225
obstacle {
	image_filenames = "iso_lamp_e.png",
	borders = borders(0.50, 0.50),
	flags = { GROUND_LEVEL },
	emitted_light_strength = 24,
	transparency = NO_TRANSPARENCY,
}

-- #226
obstacle {
	image_filenames = "iso_lamp_w.png",
	borders = borders(0.50, 0.50),
	flags = { GROUND_LEVEL },
	emitted_light_strength = 24,
	transparency = NO_TRANSPARENCY,
}

-- #227
obstacle {
	image_filenames = "iso_shroom_blue_1.png",
	borders = borders(1.00, 1.00),
	flags = { GROUND_LEVEL },
	emitted_light_strength = 7,
	transparency = NO_TRANSPARENCY,
}

-- #228
obstacle {
	image_filenames = "iso_shroom_blue_2.png",
	borders = borders(1.00, 1.00),
	flags = { GROUND_LEVEL },
	emitted_light_strength = 9,
	transparency = NO_TRANSPARENCY,
}

-- #229
obstacle {
	image_filenames = "iso_shroom_blue_3.png",
	borders = borders(0.90, 0.90),
	flags = { GROUND_LEVEL },
	emitted_light_strength = 8,
	transparency = NO_TRANSPARENCY,
}

-- #230
obstacle {
	image_filenames = "iso_shroom_white_2.png",
	borders = borders(0.90, 0.90),
	flags = { GROUND_LEVEL },
	emitted_light_strength = 11,
	transparency = NO_TRANSPARENCY,
}

-- #231
obstacle {
	image_filenames = "iso_wall_brick_T_nwe.png",
	borders = borders(1.20, 1.20),
	flags = { BLOCKS_VISION },
}

-- #232
obstacle {
	image_filenames = "iso_wall_brick_T_nes.png",
	borders = borders(1.20, 1.20),
	flags = { BLOCKS_VISION },
}

-- #233
obstacle {
	image_filenames = "iso_wall_brick_T_wes.png",
	borders = borders(1.20, 1.20),
	flags = { BLOCKS_VISION },
}

-- #234
obstacle {
	image_filenames = "iso_wall_brick_T_nws.png",
	borders = borders(1.20, 1.20),
	flags = { BLOCKS_VISION },
}

-- #235
obstacle {
	image_filenames = "iso_wall_brick_cracked_ns.png",
	label = "",
	borders = borders(0.50, 1.20),
	flags = { IS_VERTICAL, BLOCKS_VISION, IS_SMASHABLE, IS_CLICKABLE },
	after_smashing = 237,
	action = "barrel",
}

-- #236
obstacle {
	image_filenames = "iso_wall_brick_cracked_we.png",
	label = "",
	borders = borders(1.20, 0.50),
	flags = { IS_HORIZONTAL, BLOCKS_VISION, IS_SMASHABLE, IS_CLICKABLE },
	after_smashing = 238,
	action = "barrel",
}

-- #237
obstacle {
	image_filenames = "iso_wall_brick_smashed_ns.png",
	flags = { IS_VERTICAL, BLOCKS_VISION },
}

-- #238
obstacle {
	image_filenames = "iso_wall_brick_smashed_we.png",
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
}

-- #239
obstacle {
	image_filenames = "iso_projectionscreen_s.png",
	borders = borders(2.20, 1.00),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #240
obstacle {
	image_filenames = "iso_projectionscreen_w.png",
	borders = borders(1.00, 2.20),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #241
obstacle {
	image_filenames = "iso_projectionscreen_n.png",
	borders = borders(2.00, 1.00),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #242
obstacle {
	image_filenames = "iso_projectionscreen_e.png",
	borders = borders(1.00, 2.20),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #243
obstacle {
	image_filenames = "iso_cinematograph_n.png",
	borders = borders(0.50, 0.50),
	transparency = NO_TRANSPARENCY,
}

-- #244
obstacle {
	image_filenames = "iso_cinematograph_s.png",
	borders = borders(0.50, 0.50),
	transparency = NO_TRANSPARENCY,
}

-- #245
obstacle {
	image_filenames = "iso_sign_questionmark.png",
	label = _"Sign",
	borders = borders(0.50, 0.60),
	emitted_light_strength = 5,
	flags = { GROUND_LEVEL, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "sign",
}

-- #246
obstacle {
	image_filenames = "iso_sign_exclamationmark.png",
	label = _"Sign",
	borders = borders(0.60, 0.50),
	emitted_light_strength = 5,
	flags = { GROUND_LEVEL, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "sign",
}

-- #247
obstacle {
	image_filenames = "iso_sign_lessthenmark.png",
	label = _"Sign",
	borders = borders(0.50, 0.60),
	emitted_light_strength = 5,
	flags = { GROUND_LEVEL, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "sign",
}

-- #248
obstacle {
	image_filenames = "iso_wall_green_wallpaper_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL, BLOCKS_VISION },
}

-- #249
obstacle {
	image_filenames = "iso_wall_green_wallpaper_we.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
}

-- #250
obstacle {
	image_filenames = "iso_wall_green_brown_manyspots_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL, BLOCKS_VISION },
}

-- #251
obstacle {
	image_filenames = "iso_wall_green_brown_manyspots_we.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
}

-- #252
obstacle {
	image_filenames = "iso_wall_green_brown_fewspots_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL, BLOCKS_VISION },
}

-- #253
obstacle {
	image_filenames = "iso_wall_green_brown_fewspots_ew.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
}

-- #254
obstacle {
	image_filenames = "iso_counter_small_w.png",
	borders = borders(0.80, 1.05),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #255
obstacle {
	image_filenames = "iso_counter_small_n.png",
	borders = borders(1.05, 0.80),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #256
obstacle {
	image_filenames = "iso_counter_small_e.png",
	borders = borders(0.80, 1.05),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #257
obstacle {
	image_filenames = "iso_counter_small_s.png",
	borders = borders(1.05, 0.80),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #258
obstacle {
	image_filenames = "iso_counter_small_curve_nw.png",
	borders = borders(1.10, 1.10),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #259
obstacle {
	image_filenames = "iso_counter_small_curve_ne.png",
	borders = borders(1.10, 1.10),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #260
obstacle {
	image_filenames = "iso_counter_small_curve_es.png",
	borders = borders(1.10, 1.10),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #261
obstacle {
	image_filenames = "iso_counter_small_curve_ws.png",
	borders = borders(1.10, 1.10),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #262
obstacle {
	image_filenames = "iso_counter_small_edge_ws.png",
	borders = borders(1.10, 1.10),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #263
obstacle {
	image_filenames = "iso_counter_small_edge_nw.png",
	borders = borders(1.10, 1.10),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #264
obstacle {
	image_filenames = "iso_counter_small_edge_ne.png",
	borders = borders(1.10, 1.10),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #265
obstacle {
	image_filenames = "iso_counter_small_edge_es.png",
	borders = borders(1.10, 1.10),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #266
obstacle {
	image_filenames = "iso_library_counter_we.png",
	borders = borders(3.50, 1.50),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #267
obstacle {
	image_filenames = "iso_library_counter_ns.png",
	borders = borders(1.50, 3.50),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #268
obstacle {
	image_filenames = "iso_bathtub_e.png",
	borders = borders(1.50, 1.00),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #269
obstacle {
	image_filenames = "iso_bathtub_s.png",
	borders = borders(1.00, 1.50),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #270
obstacle {
	image_filenames = "iso_table_round_yellow.png",
	borders = borders(0.80, 0.80),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #271
obstacle {
	image_filenames = "iso_ladderring_n.png",
	flags = { BLOCKS_VISION },
	emitted_light_strength = 29,
	transparency = NO_TRANSPARENCY,
}

-- #272
obstacle {
	image_filenames = "iso_ladderring_w.png",
	flags = { BLOCKS_VISION },
	emitted_light_strength = 29,
	transparency = NO_TRANSPARENCY,
}

-- #273
obstacle {
	image_filenames = "iso_wall_yellow_curve_short_es.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION },
}

-- #274
obstacle {
	image_filenames = "iso_wall_yellow_curve_short_ne.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION },
}

-- #275
obstacle {
	image_filenames = "iso_wall_yellow_curve_short_nw.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION },
}

-- #276
obstacle {
	image_filenames = "iso_wall_yellow_curve_short_ws.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION },
}

-- #277
obstacle {
	image_filenames = "iso_table_elliptic_yellow_ns.png",
	borders = borders(0.85, 1.50),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #278
obstacle {
	image_filenames = "iso_table_elliptic_yellow_ew.png",
	borders = borders(1.50, 0.85),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #279
obstacle {
	image_filenames = "iso_table_glass_ns.png",
	borders = borders(1.00, 1.20),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #280
obstacle {
	image_filenames = "iso_table_glass_we.png",
	borders = borders(1.20, 1.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #281
obstacle {
	image_filenames = "iso_wall_glass_ns.png",
	label = "",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL, IS_SMASHABLE, IS_CLICKABLE },
	after_smashing = 348,
	transparency = NO_TRANSPARENCY,
	action = "barrel",
	smashed_sound = "Glass_Break.ogg",
}

-- #282
obstacle {
	image_filenames = "iso_wall_glass_we.png",
	label = "",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL, IS_SMASHABLE, IS_CLICKABLE },
	after_smashing = 446,
	transparency = NO_TRANSPARENCY,
	action = "barrel",
	smashed_sound = "Glass_Break.ogg",
}

-- #283
obstacle {
	image_filenames = "iso_wall_turquois_window_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL },
}

-- #284
obstacle {
	image_filenames = "iso_wall_turquois_window_we.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL },
}

-- #285
obstacle {
	image_filenames = "iso_wall_red_window_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL },
}

-- #286
obstacle {
	image_filenames = "iso_wall_red_window_we.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL },
}

-- #287
obstacle {
	image_filenames = "iso_wall_green_wallpaper_window_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL },
}

-- #288
obstacle {
	image_filenames = "iso_wall_green_wallpaper_window_we.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL },
}

-- #289
obstacle {
	image_filenames = "iso_wall_green_brown_manyspots_window_ns.png",
	borders = borders(0.40, 1.10),
	flags = { IS_VERTICAL },
}

-- #290
obstacle {
	image_filenames = "iso_wall_green_brown_manyspots_window_we.png",
	borders = borders(1.10, 0.40),
	flags = { IS_HORIZONTAL },
}

-- #291
obstacle {
	image_filenames = "iso_barshelf_middle_we.png",
	borders = borders(0.60, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #292
obstacle {
	image_filenames = "iso_barshelf_middle_ns.png",
	borders = borders(0.60, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #293
obstacle {
	image_filenames = "iso_barshelf_left_ns.png",
	borders = borders(0.60, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #294
obstacle {
	image_filenames = "iso_barshelf_left_we.png",
	borders = borders(0.60, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #295
obstacle {
	image_filenames = "iso_barshelf_right_we.png",
	borders = borders(0.60, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #296
obstacle {
	image_filenames = "iso_barshelf_left_ew.png",
	borders = borders(0.60, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #297
obstacle {
	image_filenames = "iso_barshelf_rightouter_ew.png",
	borders = borders(0.60, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #298
obstacle {
	image_filenames = "iso_barshelf_rightouter_we.png",
	borders = borders(0.60, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #299
obstacle {
	image_filenames = "iso_barshelf_rightouter_ns.png",
	borders = borders(0.60, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #300
obstacle {
	image_filenames = "iso_barshelf_leftouter_we.png",
	borders = borders(0.60, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #301
obstacle {
	image_filenames = "iso_bench_red_w.png",
	borders = borders(0.60, 1.20),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #302
obstacle {
	image_filenames = "iso_bench_red_n.png",
	borders = borders(1.20, 0.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #303
obstacle {
	image_filenames = "iso_bench_red_e.png",
	borders = borders(0.60, 1.20),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #304
obstacle {
	image_filenames = "iso_bench_red_s.png",
	borders = borders(1.20, 0.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #305
obstacle {
	image_filenames = "iso_stool_brown_w.png",
	borders = borders(0.60, 0.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #306
obstacle {
	image_filenames = "iso_stool_brown_n.png",
	borders = borders(0.60, 0.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #307
obstacle {
	image_filenames = "iso_stool_brown_e.png",
	borders = borders(0.60, 0.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #308
obstacle {
	image_filenames = "iso_stool_brown_s.png",
	borders = borders(0.60, 0.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #309
obstacle {
	image_filenames = "iso_stool_plant_brown_w.png",
	borders = borders(0.60, 0.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #310
obstacle {
	image_filenames = "iso_stool_plant_brown_n.png",
	borders = borders(0.60, 0.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #311
obstacle {
	image_filenames = "iso_stool_plant_brown_e.png",
	borders = borders(0.60, 0.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #312
obstacle {
	image_filenames = "iso_stool_plant_brown_s.png",
	borders = borders(0.60, 0.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #313
obstacle {
	image_filenames = "iso_oil_1.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "oil stains"
}

-- #314
obstacle {
	image_filenames = "iso_oil_5_1.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "oil stains"
}

-- #315
obstacle {
	image_filenames = "iso_oil_4_1.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "oil stains"
}

-- #316
obstacle {
	image_filenames = "iso_oil_4_2.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "oil stains"
}

-- #317
obstacle {
	image_filenames = "iso_oil_10.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "oil stains"
}

-- #318
obstacle {
	image_filenames = "iso_oil_7.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "oil stains"
}

-- #319
obstacle {
	image_filenames = "iso_oil_5_2.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "oil stains"
}

-- #320
obstacle {
	image_filenames = "iso_oil_11.png",
	flags = { IS_VOLATILE, BLOCKS_VISION, NEEDS_PRE_PUT },
	transparency = NO_TRANSPARENCY,
	groups = "oil stains"
}

-- #321
obstacle {
	image_filenames = "iso_pathblocker_1x1.png",
	borders = borders(1.00, 1.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #322
obstacle {
	image_filenames = "iso_wall_brick_longend_we.png",
	borders = borders(1.20, 0.80),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
	after_smashing = 235,
	groups = "brick wall 2"
}

-- #323
obstacle {
	image_filenames = "iso_wall_brick_longend_ns.png",
	borders = borders(0.80, 1.20),
	flags = { IS_VERTICAL, BLOCKS_VISION },
	after_smashing = 236,
	groups = "brick wall 2"
}

-- #324
obstacle {
	image_filenames = "iso_autogun_w.png",
	borders = borders(0.70, 0.70),
	transparency = NO_TRANSPARENCY,
}

-- #325
obstacle {
	image_filenames = "iso_autogun_n.png",
	borders = borders(0.70, 0.70),
	transparency = NO_TRANSPARENCY,
}

-- #326
obstacle {
	image_filenames = "iso_autogun_e.png",
	borders = borders(0.70, 0.70),
	transparency = NO_TRANSPARENCY,
}

-- #327
obstacle {
	image_filenames = "iso_autogun_s.png",
	borders = borders(0.70, 0.70),
	transparency = NO_TRANSPARENCY,
}

-- #328
obstacle {
	image_filenames = "iso_wall_brick_cable_we.png",
	borders = borders(1.20, 0.80),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
	groups = "brick wall cables"
}

-- #329
obstacle {
	image_filenames = "iso_wall_brick_cable_ns.png",
	borders = borders(0.80, 1.20),
	flags = { IS_VERTICAL, BLOCKS_VISION },
	groups = "brick wall cables"
}

-- #330
obstacle {
	image_filenames = "iso_wall_brick_cable_edge_ws.png",
	borders = borders(-0.60, 0.30, -0.60, 0.60),
	flags = { BLOCKS_VISION, CORNER_NE },
	groups = "brick wall cables"
}

-- #331
obstacle {
	image_filenames = "iso_wall_brick_cable_edge_ne.png",
	borders = borders(-0.60, 0.65, -0.60, 0.30),
	flags = { BLOCKS_VISION, CORNER_SW },
	groups = "brick wall cables"
}

-- #332
obstacle {
	image_filenames = "iso_wall_brick_cable_edge_es.png",
	borders = borders(-0.30, 0.60, -0.30, 0.60),
	flags = { BLOCKS_VISION, CORNER_NW },
	groups = "brick wall cables"
}

-- #333
obstacle {
	image_filenames = "iso_wall_brick_cable_edge_nw.png",
	borders = borders(-0.60, 0.30, -0.60, 0.30),
	flags = { BLOCKS_VISION, CORNER_SE },
	groups = "brick wall cables"
}

-- #334
obstacle {
	image_filenames = "iso_restaurant_counter_w.png",
	borders = borders(1.50, 5.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #335
obstacle {
	image_filenames = "iso_restaurant_counter_n.png",
	borders = borders(5.00, 1.50),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #336
obstacle {
	image_filenames = "iso_bar_counter_w.png",
	borders = borders(0.65, 5.50),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #337
obstacle {
	image_filenames = "iso_bar_counter_s.png",
	borders = borders(5.50, 0.65),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #338
obstacle {
	image_filenames = "iso_crystal_pillar_1.png",
	borders = borders(0.50, 0.50),
	transparency = NO_TRANSPARENCY,
}

-- #339
obstacle {
	image_filenames = "iso_crystal_pillar_2.png",
	borders = borders(1.15, 1.15),
	transparency = NO_TRANSPARENCY,
}

-- #340
obstacle {
	image_filenames = "iso_crystal_stump_1.png",
	borders = borders(0.95, 0.95),
	transparency = NO_TRANSPARENCY,
}

-- #341
obstacle {
	image_filenames = "iso_crystal_stump_2.png",
	borders = borders(1.25, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #342
obstacle {
	image_filenames = "iso_crystal_pillar_3.png",
	borders = borders(1.20, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #343
obstacle {
	image_filenames = "iso_crystal_stump_3.png",
	borders = borders(1.10, 1.10),
	transparency = NO_TRANSPARENCY,
}

-- #344
obstacle {
	image_filenames = "iso_wall_corners_es.png",
	borders = borders(1.10, 1.00),
	flags = { BLOCKS_VISION },
}

-- #345
obstacle {
	image_filenames = "iso_wall_corners_ws.png",
	borders = borders(1.10, 1.00),
	flags = { BLOCKS_VISION },
}

-- #346
obstacle {
	image_filenames = "iso_wall_corners_nw.png",
	borders = borders(1.10, 1.00),
	flags = { BLOCKS_VISION },
}

-- #347
obstacle {
	image_filenames = "iso_wall_corners_ne.png",
	borders = borders(1.10, 1.00),
	flags = { BLOCKS_VISION },
}

-- #348
obstacle {
	image_filenames = "iso_wall_glass_broken_ns.png",
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
}

-- #349
obstacle {
	image_filenames = "iso_gate_unlocked_opened_ns_5_blocked.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #350
obstacle {
	image_filenames = "iso_gate_unlocked_opened_we_5_blocked.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #351
obstacle {
	image_filenames = "iso_doubledoor_locked_we.png",
	borders = borders(-0.55, 1.55, -0.80, 0.20),
	transparency = NO_TRANSPARENCY,
}

-- #352
obstacle {
	image_filenames = "iso_doubledoor_locked_ns.png",
	borders = borders(-0.80, 0.20, -0.55, 1.55),
	transparency = NO_TRANSPARENCY,
}

-- #353
obstacle {
	image_filenames = "iso_doubledoor_unlocked_opened_we_1.png",
	borders = borders(-0.55, 1.55, -0.20, 0.20),
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #354
obstacle {
	image_filenames = "iso_doubledoor_unlocked_opened_we_2.png",
	borders = borders(-0.55, 1.55, -0.20, 0.20),
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #355
obstacle {
	image_filenames = "iso_doubledoor_unlocked_opened_we_3.png",
	borders = borders(-0.55, 1.55, -0.20, 0.20),
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #356
obstacle {
	image_filenames = "iso_doubledoor_unlocked_opened_we_4.png",
	borders = borders(-0.55, 1.55, -0.20, 0.20),
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #357
obstacle {
	image_filenames = "iso_doubledoor_unlocked_opened_we_5.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #358
obstacle {
	image_filenames = "iso_doubledoor_unlocked_opened_ns_1.png",
	borders = borders(-0.20, 0.20, -0.55, 1.55),
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #359
obstacle {
	image_filenames = "iso_doubledoor_unlocked_opened_ns_2.png",
	borders = borders(-0.20, 0.20, -0.55, 1.55),
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #360
obstacle {
	image_filenames = "iso_doubledoor_unlocked_opened_ns_3.png",
	borders = borders(-0.20, 0.20, -0.55, 1.55),
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #361
obstacle {
	image_filenames = "iso_doubledoor_unlocked_opened_ns_4.png",
	borders = borders(-0.20, 0.20, -0.55, 1.55),
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #362
obstacle {
	image_filenames = "iso_doubledoor_unlocked_opened_ns_5.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
	animation = "door",
}

-- #363
obstacle {
	image_filenames = "iso_basin_n.png",
	borders = borders(1.05, 0.95),
	transparency = NO_TRANSPARENCY,
}

-- #364
obstacle {
	image_filenames = "iso_basin_e.png",
	borders = borders(0.95, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #365
obstacle {
	image_filenames = "iso_basin_s.png",
	borders = borders(1.05, 0.95),
	transparency = NO_TRANSPARENCY,
}

-- #366
obstacle {
	image_filenames = "iso_basin_w.png",
	borders = borders(0.95, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #367
obstacle {
	image_filenames = "iso_deskchair_w.png",
	borders = borders(0.90, 0.90),
	transparency = NO_TRANSPARENCY,
}

-- #368
obstacle {
	image_filenames = "iso_deskchair_n.png",
	borders = borders(0.90, 0.90),
	transparency = NO_TRANSPARENCY,
}

-- #369
obstacle {
	image_filenames = "iso_deskchair_e.png",
	borders = borders(0.90, 0.90),
	transparency = NO_TRANSPARENCY,
}

-- #370
obstacle {
	image_filenames = "iso_ladder_w.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #371
obstacle {
	image_filenames = "iso_ladder_n.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #372
obstacle {
	image_filenames = "iso_chest_greyrusty_closed_w.png",
	label = _"Chest",
	borders = borders(0.60, 0.80),
	flags = { GROUND_LEVEL, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "chest",
	after_looting = 374,
}

-- #373
obstacle {
	image_filenames = "iso_chest_greyrusty_closed_n.png",
	label = _"Chest",
	borders = borders(0.80, 0.60),
	flags = { GROUND_LEVEL, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "chest",
	after_looting = 375,
}

-- #374
obstacle {
	image_filenames = "iso_chest_greyrusty_opened_w.png",
	borders = borders(0.60, 0.80),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #375
obstacle {
	image_filenames = "iso_chest_greyrusty_opened_n.png",
	borders = borders(0.80, 0.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #376
obstacle {
	image_filenames = "iso_chest_greyrusty_closed_s.png",
	label = _"Chest",
	borders = borders(0.80, 0.60),
	flags = { GROUND_LEVEL, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "chest",
	after_looting = 378,
}

-- #377
obstacle {
	image_filenames = "iso_chest_greyrusty_closed_e.png",
	label = _"Chest",
	borders = borders(0.60, 0.80),
	flags = { GROUND_LEVEL, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "chest",
	after_looting = 379,
}

-- #378
obstacle {
	image_filenames = "iso_chest_greyrusty_opened_s.png",
	borders = borders(0.80, 0.60),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #379
obstacle {
	image_filenames = "iso_chest_greyrusty_opened_e.png",
	borders = borders(0.60, 0.80),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #380
obstacle {
	image_filenames = "iso_security_gate_opened_w.png",
	borders = borders(0.95, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #381
obstacle {
	image_filenames = "iso_security_gate_opened_n.png",
	borders = borders(0.95, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #382
obstacle {
	image_filenames = "iso_security_gate_closed_w.png",
	borders = borders(0.95, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #383
obstacle {
	image_filenames = "iso_security_gate_closed_n.png",
	borders = borders(0.95, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #384
obstacle {
	image_filenames = "iso_security_gate_opened_e.png",
	borders = borders(0.95, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #385
obstacle {
	image_filenames = "iso_security_gate_opened_s.png",
	borders = borders(0.95, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #386
obstacle {
	image_filenames = "iso_security_gate_closed_e.png",
	borders = borders(0.95, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #387
obstacle {
	image_filenames = "iso_security_gate_closed_s.png",
	borders = borders(0.95, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #388
obstacle {
	image_filenames = "iso_solarpanel.png",
	label = _"Solar Panel",
	borders = borders(0.95, 1.05),
	flags = { IS_SMASHABLE, IS_CLICKABLE },
	after_smashing = 407,
	transparency = NO_TRANSPARENCY,
	action = "barrel",
}

-- #389
obstacle {
	image_filenames = "iso_conveyor_ns.png",
	borders = borders(3.00, 2.00),
	transparency = NO_TRANSPARENCY,
}

-- #390
obstacle {
	image_filenames = "iso_conveyor_we.png",
	borders = borders(2.00, 3.00),
	transparency = NO_TRANSPARENCY,
}

-- #391
obstacle {
	image_filenames = "iso_ramp_w.png",
	borders = borders(2.46, 1.94),
	transparency = NO_TRANSPARENCY,
}

-- #392
obstacle {
	image_filenames = "iso_ramp_s.png",
	borders = borders(1.94, 2.46),
	transparency = NO_TRANSPARENCY,
}

-- #393
obstacle {
	image_filenames = "iso_ramp_e.png",
	borders = borders(2.46, 1.94),
	transparency = NO_TRANSPARENCY,
}

-- #394
obstacle {
	image_filenames = "iso_ramp_n.png",
	borders = borders(1.94, 2.46),
	transparency = NO_TRANSPARENCY,
}

-- #395
obstacle {
	image_filenames = "iso_tesla_n.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #396
obstacle {
	image_filenames = "iso_tesla_w.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #397
obstacle {
	image_filenames = "iso_tesla_s.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #398
obstacle {
	image_filenames = "iso_tesla_e.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #399
obstacle {
	image_filenames = "iso_roboarm_1_n.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #400
obstacle {
	image_filenames = "iso_roboarm_1_w.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #401
obstacle {
	image_filenames = "iso_freighter_railway_ns.png",
	borders = borders(3.00, 3.00),
	transparency = NO_TRANSPARENCY,
}

-- #402
obstacle {
	image_filenames = "iso_freighter_railway_we.png",
	borders = borders(3.00, 3.00),
	transparency = NO_TRANSPARENCY,
}

-- #403
obstacle {
	image_filenames = "iso_freighter_railway_end_s.png",
	borders = borders(3.00, 3.00),
	transparency = NO_TRANSPARENCY,
}

-- #404
obstacle {
	image_filenames = "iso_freighter_railway_end_e.png",
	borders = borders(3.00, 3.00),
	transparency = NO_TRANSPARENCY,
}

-- #405
obstacle {
	image_filenames = "iso_freighter_railway_end_n.png",
	borders = borders(3.00, 3.00),
	transparency = NO_TRANSPARENCY,
}

-- #406
obstacle {
	image_filenames = "iso_freighter_railway_end_w.png",
	borders = borders(3.00, 3.00),
	transparency = NO_TRANSPARENCY,
}

-- #407
obstacle {
	image_filenames = "iso_solarpanel_pillar.png",
	borders = borders(0.95, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #408
obstacle {
	image_filenames = "iso_crate_ns_megasys.png",
	label = _"Crate",
	borders = borders(0.80, 0.95),
	flags = { BLOCKS_VISION, IS_SMASHABLE, DROPS_RANDOM_TREASURE, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "barrel",
}

-- #409
obstacle {
	image_filenames = "iso_reactor_w.png",
	borders = borders(4.50, 4.00),
	transparency = NO_TRANSPARENCY,
}

-- #410
obstacle {
	image_filenames = "iso_reactor_s.png",
	borders = borders(4.00, 4.50),
	transparency = NO_TRANSPARENCY,
}

-- #411
obstacle {
	image_filenames = "iso_reactor_e.png",
	borders = borders(4.50, 4.00),
	transparency = NO_TRANSPARENCY,
}

-- #412
obstacle {
	image_filenames = "iso_reactor_n.png",
	borders = borders(4.00, 4.50),
	transparency = NO_TRANSPARENCY,
}

-- #413
obstacle {
	image_filenames = "iso_wallterminal_n.png",
	label = _"Terminal",
	borders = borders(0.60, 0.40),
	flags = { IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #414
obstacle {
	image_filenames = "iso_wallterminal_w.png",
	label = _"Terminal",
	borders = borders(0.40, 0.60),
	flags = { IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #415
obstacle {
	image_filenames = "iso_wallterminal_s.png",
	label = _"Terminal",
	borders = borders(0.60, 0.40),
	flags = { IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #416
obstacle {
	image_filenames = "iso_wallterminal_e.png",
	label = _"Terminal",
	borders = borders(0.40, 0.60),
	flags = { IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #417
obstacle {
	image_filenames = "iso_turbines_n.png",
	borders = borders(1.10, 1.80),
	transparency = NO_TRANSPARENCY,
}

-- #418
obstacle {
	image_filenames = "iso_turbines_w.png",
	borders = borders(1.80, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #419
obstacle {
	image_filenames = "iso_turbines_s.png",
	borders = borders(1.10, 1.80),
	transparency = NO_TRANSPARENCY,
}

-- #420
obstacle {
	image_filenames = "iso_turbines_e.png",
	borders = borders(1.80, 1.05),
	transparency = NO_TRANSPARENCY,
}

-- #421
obstacle {
	image_filenames = "iso_weapon_crate.png",
	label = _"Weapon Crate",
	borders = borders(1.30, 1.30),
	flags = { BLOCKS_VISION, IS_SMASHABLE, DROPS_RANDOM_TREASURE, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "barrel",
}

-- #422
obstacle {
	image_filenames = "iso_electronicscrap_1.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #423
obstacle {
	image_filenames = "iso_electronicscrap_2.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #424
obstacle {
	image_filenames = "iso_electronicscrap_3.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #425
obstacle {
	image_filenames = "iso_electronicscrap_4.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #426
obstacle {
	image_filenames = "iso_electronicscrap_5.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #427
obstacle {
	image_filenames = "iso_electronicscrap_6.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #428
obstacle {
	image_filenames = "iso_electronicscrap_7.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #429
obstacle {
	image_filenames = "iso_electronicscrap_8.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #430
obstacle {
	image_filenames = "iso_body_human.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #431
obstacle {
	image_filenames = "iso_ladder_short_n.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #432
obstacle {
	image_filenames = "iso_ladder_short_w.png",
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #433
obstacle {
	image_filenames = "iso_wrecked_car_w.png",
	borders = borders(1.40, 2.80),
	transparency = NO_TRANSPARENCY,
}

-- #434
obstacle {
	image_filenames = "iso_wrecked_car_s.png",
	borders = borders(2.80, 1.40),
	transparency = NO_TRANSPARENCY,
}

-- #435
obstacle {
	image_filenames = "iso_wrecked_car_e.png",
	borders = borders(1.40, 2.80),
	transparency = NO_TRANSPARENCY,
}

-- #436
obstacle {
	image_filenames = "iso_wrecked_car_n.png",
	borders = borders(2.80, 1.40),
	transparency = NO_TRANSPARENCY,
}

-- #437
obstacle {
	image_filenames = "iso_toilet_white_n.png",
	borders = borders(0.40, 0.40),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #438
obstacle {
	image_filenames = "iso_toilet_white_w.png",
	borders = borders(0.40, 0.40),
	flags = { IS_SMASHABLE, GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #439
obstacle {
	image_filenames = "iso_roboarm_1_s.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #440
obstacle {
	image_filenames = "iso_roboarm_1_e.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #441
obstacle {
	image_filenames = "iso_roboarm_2_n.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #442
obstacle {
	image_filenames = "iso_roboarm_2_w.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #443
obstacle {
	image_filenames = "iso_roboarm_2_s.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #444
obstacle {
	image_filenames = "iso_roboarm_2_e.png",
	borders = borders(1.00, 1.00),
	transparency = NO_TRANSPARENCY,
}

-- #445
obstacle {
	image_filenames = "iso_crushed_476.png",
	borders = borders(2.10, 2.60),
	transparency = NO_TRANSPARENCY,
}

-- #446
obstacle {
	image_filenames = "iso_wall_glass_broken_we.png",
	flags = { IS_WALKABLE },
	transparency = NO_TRANSPARENCY,
}

-- #447
obstacle {
	image_filenames = { "iso_sign_questionmark_anim_dark.png", "iso_sign_questionmark_anim_bright.png" },
	label = _"Sign",
	borders = borders(0.50, 0.60),
	emitted_light_strength = { 0, 5 },
	flags = { GROUND_LEVEL, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "sign",
	animation_fps = 0.44
}

-- #448
obstacle {
	image_filenames = { "iso_sign_exclamationmark_anim_dark.png", "iso_sign_exclamationmark_anim_bright.png" },
	label = _"Sign",
	borders = borders(0.60, 0.50),
	emitted_light_strength = { 0, 5 },
	flags = { GROUND_LEVEL, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "sign",
	animation_fps = 0.4
}
-- #449
obstacle {
	image_filenames = { "iso_sign_lessthenmark_anim_dark.png", "iso_sign_lessthenmark_anim_bright.png" },
	label = _"Sign",
	borders = borders(0.50, 0.60),
	emitted_light_strength = { 0, 5 },
	flags = { GROUND_LEVEL, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "sign",
	animation_fps = 0.6
}
	
-- #450
obstacle {
	image_filenames = { "iso_barrel_radioactive.png" },
	borders = borders(0.70, 0.70),
	emitted_light_strength = { 1, 2, 3, 2, 1 },
	transparency = NO_TRANSPARENCY,
}

-- #451
obstacle {
	image_filenames = "iso_vendingmachine_blue_w.png",
	label = _"Vending Machine",
	borders = borders(1.10, 1.55),
	emitted_light_strength = { 3, 5, 7, 6, 4, 3, 3, 0, 0, 0, 3, 0 },
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #452
obstacle {
	image_filenames = "iso_vendingmachine_blue_s.png",
	label = _"Vending Machine",
	borders = borders(1.55, 1.10),
	emitted_light_strength = { 3, 5, 7, 6, 4, 3, 3, 0, 0, 0, 3, 0  },
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #453
obstacle {
	image_filenames = "iso_vendingmachine_blue_e.png",
	label = _"Vending Machine",
	borders = borders(1.10, 1.55),
	emitted_light_strength = { 3, 5, 7, 6, 4, 3, 3, 0, 0, 0, 3, 0 },
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #454
obstacle {
	image_filenames = "iso_vendingmachine_blue_n.png",
	label = _"Vending Machine",
	borders = borders(1.55, 1.10),
	emitted_light_strength = { 3, 5, 7, 6, 4, 3, 3, 0, 0, 0, 3, 0 },
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #455
obstacle {
	image_filenames = "iso_vendingmachine_white_w.png",
	label = _"Vending Machine",
	borders = borders(1.00, 1.55),
	emitted_light_strength = { 3, 5, 7, 6, 4, 3, 3, 0, 0, 0, 3, 0 },
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #456
obstacle {
	image_filenames = "iso_vendingmachine_white_s.png",
	label = _"Vending Machine",
	borders = borders(1.55, 1.00),
	emitted_light_strength = { 3, 5, 7, 6, 4, 3, 3, 0, 0, 0, 3, 0 },
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #457
obstacle {
	image_filenames = "iso_vendingmachine_white_e.png",
	label = _"Vending Machine",
	borders = borders(1.00, 1.55),
	emitted_light_strength = { 3, 5, 7, 6, 4, 3, 3, 0, 0, 0, 3, 0 },
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #458
obstacle {
	image_filenames = "iso_vendingmachine_white_n.png",
	label = _"Vending Machine",
	borders = borders(1.55, 1.00),
	emitted_light_strength = { 3, 5, 7, 6, 4, 3, 3, 0, 0, 0, 3, 0 },
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #459
obstacle {
	image_filenames = "iso_vendingmachine_red_w.png",
	label = _"Vending Machine",
	borders = borders(1.10, 1.55),
	emitted_light_strength = { 3, 5, 7, 6, 4, 3, 3, 0, 0, 0, 3, 0 },
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #460
obstacle {
	image_filenames = "iso_vendingmachine_red_s.png",
	label = _"Vending Machine",
	borders = borders(1.55, 1.10),
	emitted_light_strength = { 3, 5, 7, 6, 4, 3, 3, 0, 0, 0, 3, 0 },
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #461
obstacle {
	image_filenames = "iso_vendingmachine_red_e.png",
	label = _"Vending Machine",
	borders = borders(1.10, 1.55),
	emitted_light_strength = { 3, 5, 7, 6, 4, 3, 3, 0, 0, 0, 3, 0 },
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #462
obstacle {
	image_filenames = "iso_vendingmachine_red_n.png",
	label = _"Vending Machine",
	borders = borders(1.55, 1.10),
	emitted_light_strength = { 3, 5, 7, 6, 4, 3, 3, 0, 0, 0, 3, 0 },
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "terminal",
}

-- #463
obstacle {
	image_filenames = "iso_transformer.png",
	borders = borders(0.95, 0.95),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #464
obstacle {
	image_filenames = "iso_transformer_rusty.png",
	borders = borders(0.95, 0.95),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #465
obstacle {
	image_filenames = "iso_transformer_sparkles.png",
	borders = borders(0.95, 0.95),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #466
obstacle {
	image_filenames = "iso_bookshelf_lootable_e.png",
	borders = borders(0.60, 1.10),
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "chest",
	label = _"Bookshelf",
	after_looting = 467,
}

-- #467
obstacle {
	image_filenames = "iso_bookshelf_looted_e.png",
	borders = borders(0.60, 1.10),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #468
obstacle {
	image_filenames = "iso_bookshelf_lootable_s.png",
	borders = borders(1.10, 0.60),
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "chest",
	label = _"Bookshelf",
	after_looting = 469,
}

-- #469
obstacle {
	image_filenames = "iso_bookshelf_looted_s.png",
	borders = borders(1.10, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #470
obstacle {
	image_filenames = "iso_bookshelf_lootable_w.png",
	borders = borders(0.60, 1.10),
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "chest",
	label = _"Bookshelf",
	after_looting = 471,
}

-- #471
obstacle {
	image_filenames = "iso_bookshelf_looted_w.png",
	borders = borders(0.60, 1.10),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #472
obstacle {
	image_filenames = "iso_bookshelf_lootable_n.png",
	borders = borders(1.10, 0.60),
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "chest",
	label = _"Bookshelf",
	after_looting = 473,
}

-- #473
obstacle {
	image_filenames = "iso_bookshelf_looted_n.png",
	borders = borders(1.10, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #474
obstacle {
	image_filenames = "iso_bookshelf_long_lootable_e.png",
	borders = borders(0.60, 2.20),
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "chest",
	label = _"Bookshelf",
	after_looting = 475,
}

-- #475
obstacle {
	image_filenames = "iso_bookshelf_long_looted_e.png",
	borders = borders(0.60, 2.20),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #476
obstacle {
	image_filenames = "iso_bookshelf_long_lootable_s.png",
	borders = borders(2.20, 0.60),
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "chest",
	label = _"Bookshelf",
	after_looting = 477,
}

-- #477
obstacle {
	image_filenames = "iso_bookshelf_long_looted_s.png",
	borders = borders(2.20, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #478
obstacle {
	image_filenames = "iso_bookshelf_long_lootable_w.png",
	borders = borders(0.60, 2.20),
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "chest",
	label = _"Bookshelf",
	after_looting = 479,
}

-- #479
obstacle {
	image_filenames = "iso_bookshelf_long_looted_w.png",
	borders = borders(0.60, 2.20),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #480
obstacle {
	image_filenames = "iso_bookshelf_long_lootable_n.png",
	borders = borders(2.20, 0.60),
	flags = { BLOCKS_VISION, IS_CLICKABLE },
	transparency = NO_TRANSPARENCY,
	action = "chest",
	label = _"Bookshelf",
	after_looting = 481,
}

-- #481
obstacle {
	image_filenames = "iso_bookshelf_long_looted_n.png",
	borders = borders(2.20, 0.60),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #482
obstacle {
	image_filenames = "iso_trapdoor_closed_e.png",
	borders = borders(1.00, 1.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #483
obstacle {
	image_filenames = "iso_trapdoor_closed_s.png",
	borders = borders(1.00, 1.00),
	flags = { GROUND_LEVEL },
	transparency = NO_TRANSPARENCY,
}

-- #484
obstacle {
	image_filenames = "iso_statue_883_e.png",
	borders = borders(1.80, 1.80),
	flags = { BLOCKS_VISION, IS_SMASHABLE, IS_CLICKABLE },
	after_smashing = 488,
	transparency = NO_TRANSPARENCY,
	action = "barrel",
	label = _"Statue",
}
-- #485
obstacle {
	image_filenames = "iso_statue_883_n.png",
	borders = borders(1.80, 1.80),
	flags = { BLOCKS_VISION, IS_SMASHABLE, IS_CLICKABLE },
	after_smashing = 489,
	transparency = NO_TRANSPARENCY,
	action = "barrel",
	label = _"Statue",
}
-- #486
obstacle {
	image_filenames = "iso_statue_883_s.png",
	borders = borders(1.80, 1.80),
	flags = { BLOCKS_VISION, IS_SMASHABLE, IS_CLICKABLE },
	after_smashing = 490,
	transparency = NO_TRANSPARENCY,
	action = "barrel",
	label = _"Statue",
}
-- #487
obstacle {
	image_filenames = "iso_statue_883_w.png",
	borders = borders(1.80, 1.80),
	flags = { BLOCKS_VISION, IS_SMASHABLE, IS_CLICKABLE },
	after_smashing = 491,
	transparency = NO_TRANSPARENCY,
	action = "barrel",
	label = _"Statue",
}
-- #488
obstacle {
	image_filenames = "iso_statue_883_smashed_e.png",
	borders = borders(1.80, 1.80),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}
-- #489
obstacle {
	image_filenames = "iso_statue_883_smashed_n.png",
	borders = borders(1.80, 1.80),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}
-- #490
obstacle {
	image_filenames = "iso_statue_883_smashed_s.png",
	borders = borders(1.80, 1.80),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}
-- #491
obstacle {
	image_filenames = "iso_statue_883_smashed_w.png",
	borders = borders(1.80, 1.80),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
}

-- #492
obstacle {
	image_filenames = { "iso_terminal_secure_e_01.png", "iso_terminal_secure_e_02.png", "iso_terminal_secure_e_03.png", "iso_terminal_secure_e_04.png", "iso_terminal_secure_e_05.png", "iso_terminal_secure_e_06.png", "iso_terminal_secure_e_07.png", "iso_terminal_secure_e_08.png", "iso_terminal_secure_e_09.png", "iso_terminal_secure_e_10.png", "iso_terminal_secure_e_11.png", "iso_terminal_secure_e_12.png", "iso_terminal_secure_e_13.png" },
        label = _"Secure terminal",
        borders = borders(0.80, 0.80),
        flags = { IS_CLICKABLE },
        transparency = NO_TRANSPARENCY,
        action = "terminal",
	animation_fps = 12
}

-- #493
obstacle {
	image_filenames = { "iso_terminal_secure_s_01.png", "iso_terminal_secure_s_02.png", "iso_terminal_secure_s_03.png", "iso_terminal_secure_s_04.png", "iso_terminal_secure_s_05.png", "iso_terminal_secure_s_06.png", "iso_terminal_secure_s_07.png", "iso_terminal_secure_s_08.png", "iso_terminal_secure_s_09.png", "iso_terminal_secure_s_10.png", "iso_terminal_secure_s_11.png", "iso_terminal_secure_s_12.png", "iso_terminal_secure_s_13.png" },
	label = _"Secure terminal",
        borders = borders(0.80, 0.80),
        flags = { IS_CLICKABLE },
        transparency = NO_TRANSPARENCY,
        action = "terminal",
        animation_fps = 12
}

-- #494
obstacle {
	image_filenames = "iso_terminal_secure_w_01.png",
	label = _"Secure terminal",
        borders = borders(0.80, 0.80),
        flags = { IS_CLICKABLE },
        transparency = NO_TRANSPARENCY,
        action = "terminal"
}

-- #495
obstacle {
	image_filenames = "iso_terminal_secure_n_01.png",
	label = _"Secure terminal",
        borders = borders(0.80, 0.80),
        flags = { IS_CLICKABLE },
        transparency = NO_TRANSPARENCY,
        action = "terminal",
        animation_fps = 12
}

-- #496
obstacle {
	image_filenames = "iso_wall_cave_dark_we.png",
	borders = borders(1.50, 1.00),
	flags = { IS_HORIZONTAL, BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
	groups = "cave wall"
}

-- #497
obstacle {
	image_filenames = "iso_wall_cave_dark_ns.png",
	borders = borders(1.00, 1.50),
	flags = { IS_VERTICAL, BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
	groups = "cave wall"
}

-- #498
obstacle {
	image_filenames = "iso_wall_cave_curve_dark_nw.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION, CORNER_SE },
	transparency = NO_TRANSPARENCY,
	groups = "cave wall"
}

-- #499
obstacle {
	image_filenames = "iso_wall_cave_curve_dark_es.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION, CORNER_NW },
	transparency = NO_TRANSPARENCY,
	groups = "cave wall"
}

-- #500
obstacle {
	image_filenames = "iso_wall_cave_curve_dark_ne.png",
	borders = borders(1.00, 1.00),
	flags = { BLOCKS_VISION, CORNER_SW },
	transparency = NO_TRANSPARENCY,
	groups = "cave wall"
}

-- #501
obstacle {
	image_filenames = { "iso_stratopod_landed_s_0001.png", "iso_stratopod_landed_s_0002.png" },
	borders = borders(2.50, 2.00),
	flags = { BLOCKS_VISION },
	transparency = NO_TRANSPARENCY,
        animation_fps = 0.5
}

--[[ IMPORTANT NOTE:
Before you add a new obstacle to the end of this list, please try to
replace one of these DUMMY OBSTACLEs.
Thank you.

Dummy obstacle code for usage:

obstacle {
	image_filenames = "DUMMY OBSTACLE"
}

]]--
