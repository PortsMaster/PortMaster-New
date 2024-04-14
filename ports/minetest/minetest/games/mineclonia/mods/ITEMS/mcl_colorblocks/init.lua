local S = minetest.get_translator(minetest.get_current_modname())
local doc_mod = minetest.get_modpath("doc")

local hc_desc = S("Terracotta is a basic building material. It comes in many different colors.")
local gt_desc = S("Glazed terracotta is a decorative block with a complex pattern. It can be rotated by placing it in different directions.")
local cp_desc = S("Concrete powder is used for creating concrete, but it can also be used as decoration itself. It comes in different colors. Concrete powder turns into concrete of the same color when it comes in contact with water.")
local c_desc = S("Concrete is a decorative block which comes in many different colors. It is notable for having a very strong and clean color.")
local cp_tt = S("Turns into concrete on water contact")

minetest.register_node("mcl_colorblocks:hardened_clay", {
	description = S("Terracotta"),
	_doc_items_longdesc = S("Terracotta is a basic building material which comes in many different colors. This particular block is uncolored."),
	tiles = {"hardened_clay.png"},
	groups = {pickaxey=1, hardened_clay=1,building_block=1, material_stone=1},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_blast_resistance = 4.2,
	_mcl_hardness = 1.25,
})

minetest.register_craft({
	type = "cooking",
	output = "mcl_colorblocks:hardened_clay",
	recipe = "mcl_core:clay",
	cooktime = 10,
})

local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = screwdriver.rotate_simple
end

local canonical_color = "yellow"

for color,colordef in pairs(mcl_dyes.colors) do
	local is_canonical = color == canonical_color
	local sdesc_hc = S("@1 Terracotta", colordef.readable_name)
	local sdesc_gt = S("@1 Glazed Terracotta", colordef.readable_name)
	local sdesc_cp = S("@1 Concrete Powder", colordef.readable_name)
	local sdesc_c = S("@1 Concrete", colordef.readable_name)
	local ldesc_hc, ldesc_gt, ldesc_cp, ldesc_c
	local create_entry
	local ename_hc, ename_gt, ename_cp, ename_c
	local ltt_cp = cp_tt
	if is_canonical then
		ldesc_hc = hc_desc
		ldesc_gt = gt_desc
		ldesc_cp = cp_desc
		ldesc_c = c_desc
		ename_hc = S("Colored Terracotta")
		ename_gt = S("Glazed Terracotta")
		ename_cp = S("Concrete Powder")
		ename_c = S("Concrete")
		create_entry = true
	end

	-- Node Definition
	minetest.register_node("mcl_colorblocks:hardened_clay_"..color, {
		description = sdesc_hc,
		_doc_items_longdesc = ldesc_hc,
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = ename_hc,
		tiles = {"hardened_clay_stained_"..color..".png"},
		groups = {pickaxey=1, hardened_clay=1,building_block=1, material_stone=1},
		sounds = mcl_sounds.node_sound_stone_defaults(),
		_mcl_blast_resistance = 4.2,
		_mcl_hardness = 1.25,
	})

	minetest.register_node("mcl_colorblocks:concrete_powder_"..color, {
		description = sdesc_cp,
		_tt_help = ltt_cp,
		_doc_items_longdesc = ldesc_cp,
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = ename_cp,
		tiles = {"mcl_colorblocks_concrete_powder_"..color..".png"},
		groups = {handy=1,shovely=1, concrete_powder=1,building_block=1,falling_node=1, material_sand=1, float=1},
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_sand_defaults(),
		on_construct  = function(pos)
			-- If placed in water, immediately harden this node
			local nb = minetest.find_node_near(pos,1,{"group:water"})
			if nb then
				local def = minetest.registered_nodes[minetest.get_node(pos).name]
				if def and def._mcl_colorblocks_harden_to then
					minetest.swap_node(pos,{name=def._mcl_colorblocks_harden_to})
				end
			end
		end,

		-- Specify the node to which this node will convert after getting in contact with water
		_mcl_colorblocks_harden_to = "mcl_colorblocks:concrete_"..color,
		_mcl_blast_resistance = 0.5,
		_mcl_hardness = 0.5,
	})

	minetest.register_node("mcl_colorblocks:concrete_"..color, {
		description = sdesc_c,
		_doc_items_longdesc = ldesc_c,
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = ename_c,
		tiles = {"mcl_colorblocks_concrete_"..color..".png"},
		groups = {handy=1,pickaxey=1, concrete=1,building_block=1, material_stone=1},
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		_mcl_blast_resistance = 1.8,
		_mcl_hardness = 1.8,
	})

	local tex = "mcl_colorblocks_glazed_terracotta_"..color..".png"
	local texes = { tex, tex, tex.."^[transformR180", tex, tex.."^[transformR270", tex.."^[transformR90" }
	minetest.register_node("mcl_colorblocks:glazed_terracotta_"..color, {
		description = sdesc_gt,
		_doc_items_longdesc = ldesc_gt,
		_doc_items_create_entry = create_entry,
		_doc_items_entry_name = ename_gt,
		tiles = texes,
		groups = {handy=1,pickaxey=1, glazed_terracotta=1,building_block=1, material_stone=1},
		paramtype2 = "facedir",
		is_ground_content = false,
		sounds = mcl_sounds.node_sound_stone_defaults(),
		_mcl_blast_resistance = 4.2,
		_mcl_hardness = 1.4,
		on_rotate = on_rotate,
	})

	if not is_canonical and doc_mod then
		doc.add_entry_alias("nodes", "mcl_colorblocks:hardened_clay_"..canonical_color, "nodes", "mcl_colorblocks:hardened_clay_"..color)
		doc.add_entry_alias("nodes", "mcl_colorblocks:glazed_terracotta_"..canonical_color, "nodes", "mcl_colorblocks:glazed_terracotta_"..color)
		doc.add_entry_alias("nodes", "mcl_colorblocks:concrete_"..canonical_color, "nodes", "mcl_colorblocks:concrete_"..color)
		doc.add_entry_alias("nodes", "mcl_colorblocks:concrete_powder_"..canonical_color, "nodes", "mcl_colorblocks:concrete_powder_"..color)
	end

	-- Crafting recipes
	minetest.register_craft({
		output = "mcl_colorblocks:hardened_clay_"..color.." 8",
		recipe = {
				{"mcl_colorblocks:hardened_clay", "mcl_colorblocks:hardened_clay", "mcl_colorblocks:hardened_clay"},
				{"mcl_colorblocks:hardened_clay", "mcl_dyes:"..color, "mcl_colorblocks:hardened_clay"},
				{"mcl_colorblocks:hardened_clay", "mcl_colorblocks:hardened_clay", "mcl_colorblocks:hardened_clay"},
		},
	})
	minetest.register_craft({
		type = "shapeless",
		output = "mcl_colorblocks:concrete_powder_"..color.." 8",
		recipe = {
			"mcl_core:sand", "mcl_core:gravel", "mcl_core:sand",
			"mcl_core:gravel", "mcl_dyes:"..color, "mcl_core:gravel",
			"mcl_core:sand", "mcl_core:gravel", "mcl_core:sand",
		}
	})

	minetest.register_craft({
		type = "cooking",
		output = "mcl_colorblocks:glazed_terracotta_"..color,
		recipe = "mcl_colorblocks:hardened_clay_"..color,
		cooktime = 10,
	})
end

-- When water touches concrete powder, it turns into concrete of the same color
minetest.register_abm({
	label = "Concrete powder hardening",
	interval = 1,
	chance = 1,
	nodenames = {"group:concrete_powder"},
	neighbors = {"group:water"},
	action = function(pos, node)
		local harden_to = minetest.registered_nodes[node.name]._mcl_colorblocks_harden_to
               -- It should be impossible for harden_to to be nil, but a Minetest bug might call
               -- the ABM on the new concrete node, which isn't part of this ABM!
        if harden_to then
            node.name = harden_to
			--Fix "float" group not lowering concrete into the water by 1.
			local water_pos = { x = pos.x, y = pos.y-1, z = pos.z }
			local water_node = minetest.get_node(water_pos)
			if minetest.get_item_group(water_node.name, "water") == 0 then
				minetest.set_node(pos, node)
			else
				minetest.set_node(water_pos,node)
				minetest.set_node(pos, {name = "air"})
				minetest.check_for_falling(pos) -- Update C. Powder that stacked above so they fall down after setting air.
			end
        end
	end,
})
