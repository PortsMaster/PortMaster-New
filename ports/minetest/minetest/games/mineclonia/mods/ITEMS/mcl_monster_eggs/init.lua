-- Monster eggs!
-- Blocks which spawn silverfish when destroyed.

local S = minetest.get_translator(minetest.get_current_modname())

local function spawn_silverfish(pos, oldnode, oldmetadata, digger)
	if not minetest.is_creative_enabled("") then
		minetest.add_entity(pos, "mobs_mc:silverfish")
	end
end

-- Template function for registering monster egg blocks
local function register_block(subname, description, tiles, is_ground_content)
	if is_ground_content == nil then
		is_ground_content = false
	end
	minetest.register_node("mcl_monster_eggs:monster_egg_"..subname, {
		description = description,
		tiles = tiles,
		is_ground_content = is_ground_content,
		groups = {dig_immediate = 3, spawns_silverfish = 1, deco_block = 1},
		drop = "",
		sounds = mcl_sounds.node_sound_stone_defaults(),
		after_dig_node = spawn_silverfish,
		_tt_help = S("Hides a silverfish"),
		_doc_items_longdesc = S([[
			An infested block is a block from which a silverfish will pop out when it is broken.
			It looks identical to its normal counterpart.
		]]),
		_mcl_hardness = 0,
		_mcl_blast_resistance = 0.5,
	})
end

-- Register all the monster egg blocks
register_block("stone", S("Infested Stone"), {"default_stone.png"}, true)
register_block("cobble", S("Infested Cobblestone"), {"default_cobble.png"})
register_block("stonebrick", S("Infested Stone Bricks"), {"default_stone_brick.png"})
register_block("stonebrickcracked", S("Infested Cracked Stone Bricks"), {"mcl_core_stonebrick_cracked.png"})
register_block("stonebrickmossy", S("Infested Mossy Stone Bricks"), {"mcl_core_stonebrick_mossy.png"})
register_block("stonebrickcarved", S("Infested Chiseled Stone Bricks"), {"mcl_core_stonebrick_carved.png"})


