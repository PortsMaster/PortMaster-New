minetest.register_craft({
	output = "mcl_copper:block_raw",
	recipe = {
		{ "mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper" },
		{ "mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper" },
		{ "mcl_copper:raw_copper", "mcl_copper:raw_copper", "mcl_copper:raw_copper" },
	},
})

minetest.register_craft({
	output = "mcl_copper:block",
	recipe = {
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
		{ "mcl_copper:copper_ingot", "mcl_copper:copper_ingot", "mcl_copper:copper_ingot" },
	},
})

minetest.register_craft({
	output = "mcl_copper:block_cut 4",
	recipe = {
		{ "mcl_copper:block", "mcl_copper:block" },
		{ "mcl_copper:block", "mcl_copper:block" },
	},
})

minetest.register_craft({
	output = "mcl_copper:block_exposed_cut 4",
	recipe = {
		{ "mcl_copper:block_exposed", "mcl_copper:block_exposed" },
		{ "mcl_copper:block_exposed", "mcl_copper:block_exposed" },
	},
})

minetest.register_craft({
	output = "mcl_copper:block_oxidized_cut 4",
	recipe = {
		{ "mcl_copper:block_oxidized", "mcl_copper:block_oxidized" },
		{ "mcl_copper:block_oxidized", "mcl_copper:block_oxidized" },
	},
})

minetest.register_craft({
	output = "mcl_copper:block_weathered_cut 4",
	recipe = {
		{ "mcl_copper:block_weathered", "mcl_copper:block_weathered" },
		{ "mcl_copper:block_weathered", "mcl_copper:block_weathered" },
	},
})

local waxable_blocks = { "block", "block_cut", "block_exposed", "block_exposed_cut", "block_weathered", "block_weathered_cut", "block_oxidized", "block_oxidized_cut" }

for _, w in ipairs(waxable_blocks) do
	minetest.register_craft({
		output = "mcl_copper:"..w.."_preserved",
		recipe = {
			{ "mcl_copper:"..w, "mcl_honey:honeycomb" },
		},
	})
end

minetest.register_craft({
	output = "mcl_copper:copper_ingot 9",
	recipe = {
		{ "mcl_copper:block" },
	},
})

minetest.register_craft({
	output = "mcl_copper:raw_copper 9",
	recipe = {
		{ "mcl_copper:block_raw" },
	},
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_copper:copper_ingot",
	recipe = "mcl_copper:raw_copper",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_copper:copper_ingot",
	recipe = "mcl_copper:stone_with_copper",
	cooktime = 10,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_copper:block",
	recipe = "mcl_copper:block_raw",
	cooktime = 90,
})
