-- Climbable nodes
local S = core.get_translator(core.get_current_modname())

local function rotate_climbable(pos, node, _, mode)
	if mode == screwdriver.ROTATE_FACE then
		local r = screwdriver.rotate.wallmounted(pos, node, mode)
		node.param2 = r
		core.swap_node(pos, node)
		return true
	end
	return false
end

core.register_node("mcl_core:ladder", {
	description = S("Ladder"),
	_doc_items_longdesc = S("A piece of ladder which allows you to climb vertically. Ladders can only be placed on the side of solid blocks and not on glass, leaves, ice, slabs, glowstone, nor sea lanterns."),
	drawtype = "signlike",
	is_ground_content = false,
	tiles = {"default_ladder.png"},
	inventory_image = "default_ladder.png",
	wield_image = "default_ladder.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	climbable = true,
	node_box = {
		type = "wallmounted",
		wall_side = { -0.5, -0.5, -0.5, -7/16, 0.5, 0.5 },
	},
	selection_box = {
		type = "wallmounted",
		wall_side = { -0.5, -0.5, -0.5, -7/16, 0.5, 0.5 },
	},
	groups = {handy=1,axey=1, attached_node=1, deco_block=1, dig_by_piston=1, unsticky = 1, pathfinder_partial = 1},
	sounds = mcl_sounds.node_sound_wood_defaults(),
	node_placement_prediction = "",
	-- Restrict placement of ladders
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			-- no interaction possible with entities
			return itemstack
		end

		local under = pointed_thing.under
		local node = core.get_node(under)
		local def = core.registered_nodes[node.name]
		if not def then
			return itemstack
		end
		local groups = def.groups

		-- Don't allow to place the ladder at particular nodes
		if (groups and (groups.glass or groups.leaves or groups.slab)) or
				node.name == "mcl_core:ladder" or node.name == "mcl_core:ice" or node.name == "mcl_nether:glowstone" or node.name == "mcl_ocean:sea_lantern" then
			return itemstack
		end

		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end
		local above = pointed_thing.above

		-- Ladders may not be placed on ceiling or floor
		if under.y ~= above.y then
			return itemstack
		end
		local idef = itemstack:get_definition()
		local success = core.item_place_node(itemstack, placer, pointed_thing)

		if success then
			if idef.sounds and idef.sounds.place then
				core.sound_play(idef.sounds.place, {pos=above, gain=1}, true)
			end
		end
		return itemstack
	end,

	_mcl_hardness = 0.4,
	_mcl_burntime = 15,
	on_rotate = rotate_climbable,
})

core.register_node("mcl_core:vine", {
	description = S("Vines"),
	_doc_items_longdesc = S("Vines are climbable blocks which can be placed on the sides of solid full-cube blocks. Vines slowly grow and spread."),
	drawtype = "signlike",
	tiles = {"mcl_core_vine.png"},
	inventory_image = "mcl_core_vine.png",
	wield_image = "mcl_core_vine.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = true,
	buildable_to = true,
	selection_box = {
		type = "wallmounted",
	},
	groups = {
		handy = 1, axey = 1, shearsy = 1, swordy = 1, deco_block = 1, vinelike_node = 4,
		dig_by_piston = 1, destroy_by_lava_flow = 1, compostability = 50,
		flammable = 2, fire_encouragement = 15, fire_flammability = 100, unsticky = 1
	},
	sounds = mcl_sounds.node_sound_leaves_defaults(),
	drop = "",
	_mcl_shears_drop = true,
	node_placement_prediction = "",
	-- Restrict placement of vines
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			-- no interaction possible with entities
			return itemstack
		end

		local under = pointed_thing.under
		local node = core.get_node(under)
		local def = core.registered_nodes[node.name]
		if not def then return itemstack end

		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		-- Only place on full cubes
		if not mcl_core.supports_vines(node.name) then
			return itemstack
		end

		local above = pointed_thing.above

		-- Vines may not be placed on top or below another block
		if under.y ~= above.y then
			return itemstack
		end
		local idef = itemstack:get_definition()
		local itemstack, success = core.item_place_node(itemstack, placer, pointed_thing)

		if success then
			if idef.sounds and idef.sounds.place then
				core.sound_play(idef.sounds.place, {pos=above, gain=1}, true)
			end
		end
		return itemstack
	end,

	-- If dug, also dig a “dependant” vine below it.
	-- A vine is dependant if it hangs from this node and has no supporting block.
	_mcl_hardness = 0.2,
	on_rotate = false,
})
