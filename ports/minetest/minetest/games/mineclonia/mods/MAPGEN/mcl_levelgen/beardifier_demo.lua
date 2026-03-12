if not mcl_levelgen.is_levelgen_environment
	and mcl_levelgen.register_notification_handler then
	return
end

local R = mcl_levelgen.build_random_spread_placement

local function beardifier_demo_place (self, level, terrain, rng, x1, z1, x2, z2)
	mcl_levelgen.set_block (self.x, self.y, self.z, self.cid, 0)
end

local function beardifier_demo_create_start (self, level, terrain, rng, cx, cz)
	local x, z = cx * 16 + 8, cz * 16 + 8
	local surface = terrain:get_one_height (x, z)
	local bbox = {
		x - 12,
		surface + 30,
		z - 12,
		x + 12,
		surface + 45,
		z + 12,
	}
	-- print (x, surface - 64, -z - 1)
	if mcl_levelgen.structure_biome_test (level, self, x, surface + 2, z) then
		return mcl_levelgen.create_structure_start (self, {
			{
				bbox = bbox,
				place = beardifier_demo_place,
				x = x,
				y = surface + 31,
				z = z,
				cid = self.glass_type,
			},
		})
	end
	return nil
end

local function getcid (name)
	return core and core.get_content_id (name) or 1000
end

mcl_levelgen.register_structure ("mcl_levelgen:beardifier_demo_box", {
	step = mcl_levelgen.UNDERGROUND_STRUCTURES,
	create_start = beardifier_demo_create_start,
	terrain_adaptation = "beard_box",
	biomes = mcl_levelgen.build_biome_list ({"#is_overworld",}),
	glass_type = getcid ("mcl_core:glass_magenta"),
})

mcl_levelgen.register_structure ("mcl_levelgen:beardifier_demo_thin", {
	step = mcl_levelgen.UNDERGROUND_STRUCTURES,
	create_start = beardifier_demo_create_start,
	terrain_adaptation = "beard_thin",
	biomes = mcl_levelgen.build_biome_list ({"#is_overworld",}),
	glass_type = getcid ("mcl_core:glass_cyan"),
})

mcl_levelgen.register_structure ("mcl_levelgen:beardifier_demo_bury", {
	step = mcl_levelgen.UNDERGROUND_STRUCTURES,
	create_start = beardifier_demo_create_start,
	terrain_adaptation = "bury",
	biomes = mcl_levelgen.build_biome_list ({"#is_overworld",}),
	glass_type = getcid ("mcl_core:glass_orange"),
})

mcl_levelgen.register_structure ("mcl_levelgen:beardifier_demo_encapsulate", {
	step = mcl_levelgen.UNDERGROUND_STRUCTURES,
	create_start = beardifier_demo_create_start,
	terrain_adaptation = "encapsulate",
	biomes = mcl_levelgen.build_biome_list ({"#is_overworld",}),
	glass_type = getcid ("mcl_core:glass_green"),
})

mcl_levelgen.register_structure_set ("mcl_levelgen:beardifier_demo", {
	structures = {
		{
			structure = "mcl_levelgen:beardifier_demo_thin",
			weight = 20,
		},
		{
			structure = "mcl_levelgen:beardifier_demo_box",
			weight = 20,
		},
		{
			structure = "mcl_levelgen:beardifier_demo_bury",
			weight = 20,
		},
		{
			structure = "mcl_levelgen:beardifier_demo_encapsulate",
			weight = 20,
		},
	},
	placement = R (0.5, "default", 16, 0, 0, "linear", nil, nil),
})
