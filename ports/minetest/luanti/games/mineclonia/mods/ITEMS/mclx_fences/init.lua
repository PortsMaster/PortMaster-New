local S = core.get_translator(core.get_current_modname())
local extra_nodes = core.settings:get_bool("mcl_extra_nodes", true)

-- Red Nether Brick Fence and Red Nether Brick Fence Gate
mcl_fences.register_fence_and_fence_gate_def("red_nether_brick_fence", {
	tiles = { "mcl_fences_fence_red_nether_brick.png" },
	groups = { pickaxey = 1, fence_nether_brick = 1, not_in_creative_inventory = not extra_nodes and 1 or 0 },
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = core.registered_nodes["mcl_nether:red_nether_brick"]._mcl_blast_resistance,
	_mcl_hardness = core.registered_nodes["mcl_nether:red_nether_brick"]._mcl_hardness,
	_mcl_fences_baseitem = "mcl_nether:red_nether_brick",
	_mcl_fences_stickreplacer = "mcl_nether:netherbrick",
}, {
	description = S("Red Nether Brick Fence"),
	connects_to = { "group:fence_nether_brick", "group:solid" },
}, {
	description = S("Red Nether Brick Fence Gate"),
	_mcl_fences_sounds = {
		open = {
			spec = "mcl_fences_nether_brick_fence_gate_open"
		},
		close = {
			spec = "mcl_fences_nether_brick_fence_gate_close"
		}
	},
	_mcl_fences_output_amount = 2
})

-- Nether Brick Fence Gate
mcl_fences.register_fence_gate_def("nether_brick_fence", {
	description = S("Nether Brick Fence Gate"),
	tiles = { "mcl_fences_fence_gate_nether_brick.png" },
	groups = { pickaxey = 1, fence_nether_brick = 1, not_in_creative_inventory = not extra_nodes and 1 or 0 },
	_mcl_blast_resistance = core.registered_nodes["mcl_nether:nether_brick"]._mcl_blast_resistance,
	_mcl_hardness = core.registered_nodes["mcl_nether:nether_brick"]._mcl_hardness,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_fences_sounds = {
		open = {
			spec = "mcl_fences_nether_brick_fence_gate_open"
		},
		close = {
			spec = "mcl_fences_nether_brick_fence_gate_close"
		}
	},
	_mcl_fences_baseitem = "mcl_nether:nether_brick",
	_mcl_fences_stickreplacer = "mcl_nether:netherbrick",
	_mcl_fences_output_amount = 2
})

-- Aliases for mcl_supplemental
core.register_alias("mcl_supplemental:red_nether_brick_fence", "mclx_fences:red_nether_brick_fence")

core.register_alias("mcl_supplemental:nether_brick_fence_gate", "mclx_fences:nether_brick_fence_gate")
core.register_alias("mcl_supplemental:nether_brick_fence_gate_open", "mclx_fences:nether_brick_fence_gate_open")

core.register_alias("mcl_supplemental:red_nether_brick_fence_gate", "mclx_fences:red_nether_brick_fence_gate")
core.register_alias("mcl_supplemental:red_nether_brick_fence_gate_open", "mclx_fences:red_nether_brick_fence_gate_open")
