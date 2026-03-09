local modpath = core.get_modpath(core.get_current_modname())

mcl_lanterns = {}

--[[
TODO:
- add lantern specific sounds
- remove the hack arround walmounted nodes
]]

local allowed_non_solid_nodes_floor = {
	"mcl_core:ice",
	"mcl_nether:soul_sand",
	"mcl_mobspawners:spawner",
	"mcl_core:barrier",
	"mcl_end:chorus_flower",
	"mcl_end:chorus_flower_dead",
	"mcl_end:end_rod",
	"mcl_end:dragon_egg",
	"mcl_portals:end_portal_frame_eye",
}

local allowed_non_solid_groups_floor = {"anvil", "wall", "glass", "fence", "fence_gate", "pane", "slab_top", "chain"}

local allowed_non_solid_nodes_ceiling = {
	"mcl_core:ice",
	"mcl_nether:soul_sand",
	"mcl_mobspawners:spawner",
	"mcl_core:barrier",
	"mcl_end:chorus_flower",
	"mcl_end:chorus_flower_dead",
	"mcl_end:end_rod",
	"mcl_core:grass_path",
}

local allowed_non_solid_groups_ceiling = {"anvil", "wall", "glass", "fence", "fence_gate", "soil", "pane", "end_portal_frame", "chain"}

local function check_placement(node, wdir)
	local nn = node.name
	local def = core.registered_nodes[nn]

	if not def then
		return false
	else
		--wdir:
		--0: ceiling
		--1: floor
		if wdir == 0 then
			if core.get_item_group(nn, "solid") > 0 or core.get_item_group(nn, "opaque") > 0 then
				return true
			else
				for _,i in ipairs(allowed_non_solid_nodes_ceiling) do
					if nn == i then
						return true
					end
				end
				for _,j in ipairs(allowed_non_solid_groups_ceiling) do
					if def.groups[j] then
						return true
					end
				end
				if core.get_item_group(nn, "slab") > 0 and core.get_item_group(nn, "slab_top") <= 0 then
					return true
				end
				return false
			end
		else --assuming wdir == 1
			if core.get_item_group(nn, "solid") > 0 or core.get_item_group(nn, "opaque") > 0 then
				return true
			else
				for _,i in ipairs(allowed_non_solid_nodes_floor) do
					if nn == i then
						return true
					end
				end
				for _,j in ipairs(allowed_non_solid_groups_floor) do
					if def.groups[j] then
						return true
					end
				end
				return false
			end
		end
	end
end


function mcl_lanterns.register_lantern(name, def)
	local itemstring_floor = "mcl_lanterns:"..name.."_floor"
	local itemstring_ceiling = "mcl_lanterns:"..name.."_ceiling"

	local sounds = mcl_sounds.node_sound_metal_defaults()

	local groups = def.groups or {}
	groups.pickaxey = def.pickaxey or 1
	groups.attached_node = 1
	groups.deco_block = 1
	groups.lantern = 1
	groups.attaches_to_top = 1
	groups.attaches_to_base = 1

	core.register_node(":"..itemstring_floor, {
		description = def.description,
		_doc_items_longdesc = def.longdesc,
		drawtype = "mesh",
		mesh = "mcl_lanterns_lantern_floor.obj",
		inventory_image = def.texture_inv,
		wield_image = def.texture_inv,
		tiles = {
			{
				name = def.texture,
				animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
			}
		},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "wallmounted",
		place_param2 = 1,
		node_placement_prediction = "",
		sunlight_propagates = true,
		light_source = def.light_level,
		groups = groups,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.1875, -0.5, -0.1875, 0.1875, -0.0625, 0.1875},
				{-0.125, -0.0625, -0.125, 0.125, 0.0625, 0.125},
				{-0.0625, -0.5, -0.0625, 0.0625, 0.1875, 0.0625},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.1875, -0.5, -0.1875, 0.1875, -0.0625, 0.1875},
				{-0.125, -0.0625, -0.125, 0.125, 0.0625, 0.125},
				{-0.0625, -0.5, -0.0625, 0.0625, 0.1875, 0.0625},
			},
		},
		sounds = sounds,
		on_place = function(itemstack, placer, pointed_thing)
			local new_stack = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
			if new_stack then
				return new_stack
			end

			local under = pointed_thing.under
			local above = pointed_thing.above
			local node = core.get_node(under)
			local def = core.registered_nodes[node.name]

			local wdir = core.dir_to_wallmounted(vector.subtract(under, above))
			local fakestack = itemstack

			if type(def.placement_prevented) == "function" then
				if
					def.placement_prevented({
						itemstack = itemstack,
						placer = placer,
						pointed_thing = pointed_thing,
					})
				then
					return itemstack
				end
			elseif check_placement(node, wdir) == false then
				return itemstack
			end

			local fakestack_name = fakestack:get_name ()
			if wdir == 0 then
				fakestack:set_name(
					fakestack_name:find ("_preserved")
					and itemstring_ceiling .. "_preserved"
					or itemstring_ceiling
				)
			elseif wdir == 1 then
				fakestack:set_name(
					fakestack_name:find ("_preserved")
					and itemstring_floor .. "_preserved"
					or itemstring_floor
				)
			end

			local success
			itemstack, success = core.item_place_node(fakestack, placer, pointed_thing, wdir)
			itemstack:set_name(
				fakestack_name:find ("_preserved")
				and itemstring_floor .. "_preserved"
				or itemstring_floor
			)

			if success then
				core.sound_play(sounds.place, {pos = under, gain = 1}, true)
			end

			return itemstack
		end,
		on_rotate = false,
		_mcl_hardness = 3.5,
	})

	core.register_node(":"..itemstring_ceiling, {
		description = def.description,
		_doc_items_longdesc = def.longdesc,
		drawtype = "mesh",
		mesh = "mcl_lanterns_lantern_ceiling.obj",
		tiles = {
			{
				name = def.texture,
				animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 3.3}
			}
		},
		use_texture_alpha = "clip",
		paramtype = "light",
		paramtype2 = "wallmounted",
		place_param2 = 0,
		node_placement_prediction = "",
		sunlight_propagates = true,
		light_source = def.light_level,
		groups = {pickaxey = 1, attached_node = 1, deco_block = 1, lantern = 1, not_in_creative_inventory = 1},
		drop = itemstring_floor,
		selection_box = {
			type = "fixed",
			fixed = {
				{-0.1875, 0, -0.1875, 0.1875, 0.4375, 0.1875},
				{-0.125, -0.125, -0.125, 0.125, 0, 0.125},
				{-0.0625, -0.5, -0.0625, 0.0625, -0.125, 0.0625},
			},
		},
		collision_box = {
			type = "fixed",
			fixed = {
				{-0.1875, 0, -0.1875, 0.1875, 0.4375, 0.1875},
				{-0.125, -0.125, -0.125, 0.125, 0, 0.125},
				{-0.0625, -0.5, -0.0625, 0.0625, -0.125, 0.0625},
			},
		},
		sounds = sounds,
		on_rotate = false,
		_mcl_hardness = 3.5,
	})
end

local chain_tpl = {
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	use_texture_alpha = "clip",
	mesh = "mcl_lanterns_chain.obj",
	is_ground_content = false,
	sunlight_propagates = true,
	collision_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {
			{-0.0625, -0.5, -0.0625, 0.0625, 0.5, 0.0625},
		}
	},
	groups = {chain=1, pickaxey=1, deco_block=1},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	on_place = function(itemstack, placer, pointed_thing)
		local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if rc then return rc end

		if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
			return itemstack
		end

		local p0 = pointed_thing.under
		local p1 = pointed_thing.above
		local param2 = 0

		local placer_pos = placer:get_pos()
		if placer_pos then
			local dir = {
				x = p1.x - placer_pos.x,
				y = p1.y - placer_pos.y,
				z = p1.z - placer_pos.z
			}
			param2 = core.dir_to_facedir(dir)
		end

		if p0.y - 1 == p1.y then
			param2 = 20
		elseif p0.x - 1 == p1.x then
			param2 = 16
		elseif p0.x + 1 == p1.x then
			param2 = 12
		elseif p0.z - 1 == p1.z then
			param2 = 8
		elseif p0.z + 1 == p1.z then
			param2 = 4
		end

		return core.item_place_node(itemstack, placer, pointed_thing, param2)
	end,
	_mcl_blast_resistance = 6,
	_mcl_hardness = 5,
}


function mcl_lanterns.register_chain(name, def)
	core.register_node(":mcl_lanterns:"..name, table.merge(chain_tpl, def))
end



dofile(modpath.."/register.lua")
