--
-- Sounds
--

mcl_sounds = {}

function mcl_sounds.node_sound_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="", gain=1.0}
	table.dug = table.dug or
			{name="default_dug_node", gain=0.25}
	table.dig = table.dig or
			{name="default_dig_oddly_breakable_by_hand", gain=0.5}
	table.place = table.place or
			{name="default_place_node_hard", gain=1.0}
	return table
end

function mcl_sounds.node_sound_stone_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_hard_footstep", gain=0.2}
	table.dug = table.dug or
			{name="default_hard_footstep", gain=1.0}
	table.dig = table.dig or
			{name="default_dig_cracky", gain=0.5}
	mcl_sounds.node_sound_defaults(table)
	return table
end

function mcl_sounds.node_sound_metal_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_metal_footstep", gain=0.2}
	table.dug = table.dug or
			{name="default_dug_metal", gain=0.5}
	table.dig = table.dig or
			{name="default_dig_metal", gain=0.5}
	table.place = table.place or
			{name="default_place_node_metal", gain=0.5}
	mcl_sounds.node_sound_defaults(table)
	return table
end

function mcl_sounds.node_sound_dirt_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_dirt_footstep", gain=0.25}
	table.dug = table.dug or
			{name="default_dirt_footstep", gain=1.0}
	table.dig = table.dig or
			{name="default_dig_crumbly", gain=0.4}
	table.place = table.place or
			{name="default_place_node", gain=1.0}
	mcl_sounds.node_sound_defaults(table)
	return table
end

function mcl_sounds.node_sound_sand_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_sand_footstep", gain=0.045}
	table.dug = table.dug or
			{name="default_sand_footstep", gain=0.15}
	table.dig = table.dig or
			{name="default_dig_crumbly", gain=0.4}
	table.place = table.place or
			{name="default_place_node", gain=1.0}
	mcl_sounds.node_sound_defaults(table)
	return table
end

function mcl_sounds.node_sound_gravel_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_gravel_footstep", gain=0.1}
	table.dug = table.dug or
			{name="default_gravel_dug", gain=0.75}
	table.dig = table.dig or
			{name="default_gravel_dig", gain=0.35}
	table.place = table.place or
			{name="default_place_node", gain=1.0}
	mcl_sounds.node_sound_defaults(table)
	return table
end

function mcl_sounds.node_sound_snow_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="pedology_snow_soft_footstep", gain=0.4}
	table.dug = table.dug or
			{name="pedology_snow_soft_footstep", gain=1.0}
	table.dig = table.dig or
			{name="pedology_snow_soft_footstep", gain=1.0}
	table.place = table.place or
			{name="default_place_node", gain=1.0}
	mcl_sounds.node_sound_defaults(table)
	return table
end

function mcl_sounds.node_sound_ice_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_ice_footstep", gain=0.075}
	table.dug = table.dug or
			{name="default_ice_dug", gain=0.35}
	table.dig = table.dig or
			{name="default_ice_dig", gain=0.35}
	mcl_sounds.node_sound_defaults(table)
	return table
end

function mcl_sounds.node_sound_wood_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_wood_footstep", gain=0.15}
	table.dug = table.dug or
			{name="default_wood_footstep", gain=1.0}
	table.dig = table.dig or
			{name="default_dig_choppy", gain=0.4}
	mcl_sounds.node_sound_defaults(table)
	return table
end

function mcl_sounds.node_sound_wool_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="mcl_sounds_cloth", gain=0.2}
	table.dug = table.dug or
			{name="mcl_sounds_cloth", gain=0.8}
	table.dig = table.dig or
			{name="mcl_sounds_cloth", gain=0.8}
	table.place = table.dig or
			{name="mcl_sounds_cloth", gain=0.8}
	mcl_sounds.node_sound_defaults(table)
	return table
end

function mcl_sounds.node_sound_leaves_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_grass_footstep", gain=0.1325}
	table.dug = table.dug or
			{name="default_grass_footstep", gain=0.425}
	table.dig = table.dig or
			{name="default_dig_snappy", gain=0.4}
	table.place = table.place or
			{name="default_place_node", gain=1.0}
	mcl_sounds.node_sound_defaults(table)
	return table
end

function mcl_sounds.node_sound_glass_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name="default_glass_footstep", gain=0.25}
	table.dug = table.dug or
			{name="default_break_glass", gain=0.5}
	table.dig = table.dig or
			{name="default_dig_cracky", gain=0.5}
	mcl_sounds.node_sound_defaults(table)
	return table
end

function mcl_sounds.node_sound_water_defaults(table)
	table = table or {}
	table.footstep = table.footstep or
			{name = "default_water_footstep", gain = 0.125}
	table.place = table.place or
			{name = "mcl_sounds_place_node_water", gain = 0.4}
	table.dug = table.dug or
			{name = "mcl_sounds_dug_water", gain = 0.4}
	mcl_sounds.node_sound_defaults(table)
	return table
end

function mcl_sounds.node_sound_lava_defaults(table)
	table = table or {}
	-- TODO: Footstep
	table.place = table.place or
			{name = "default_place_node_lava", gain = 1.0}
	table.dug = table.dug or
			{name = "default_place_node_lava", gain = 1.0}
	-- TODO: Different dug sound
	mcl_sounds.node_sound_defaults(table)
	return table
end

-- Player death sound
core.register_on_dieplayer(function(player)
	-- TODO: Add separate death sound
	core.sound_play({name="player_damage", gain = 1.0}, {pos=player:get_pos(), max_hear_distance=16}, true)
end)
