local S = minetest.get_translator(minetest.get_current_modname())

-- Wrapper around mintest.pointed_thing_to_face_pos.
local function get_fpos(placer, pointed_thing)
	local fpos
	-- Workaround: minetest.pointed_thing_to_face_pos crashes in MT 0.4.16 if
	-- pointed_thing.under and pointed_thing.above are equal
	-- FIXME: Remove this when MT got fixed.
	if not vector.equals(pointed_thing.under, pointed_thing.above) then
		-- The happy case: Everything is normal
		local finepos = minetest.pointed_thing_to_face_pos(placer, pointed_thing)
		fpos = finepos.y % 1
	else
		-- Fallback if both above and under are equal
		fpos = 0
	end
	return fpos
end

---- Trapdoor ----

local on_rotate
if minetest.get_modpath("screwdriver") then
	on_rotate = function(pos, node, user, mode, param2)
		-- Flip trapdoor vertically
		if mode == screwdriver.ROTATE_AXIS then
			local minor = node.param2
			if node.param2 >= 20 then
				minor = node.param2 - 20
				if minor == 3 then
					minor = 1
				elseif minor == 1 then
					minor = 3
				end
				node.param2 = minor
			else
				if minor == 3 then
					minor = 1
				elseif minor == 1 then
					minor = 3
				end
				node.param2 = minor
				node.param2 = node.param2 + 20
			end
			minetest.set_node(pos, node)
			return true
		end
	end
end

function mcl_doors:register_trapdoor(name, def)
	local groups = table.copy(def.groups)
	if groups == nil then
		groups = {}
	end
	groups.mesecon_ignore_opaque_dig = 1

	if not def.sound_open then
		def.sound_open = "doors_door_open"
	end
	if not def.sound_close then
		def.sound_close = "doors_door_close"
	end

	local function punch(pos)
		local me = minetest.get_node(pos)
		local tmp_node
		-- Close
		if minetest.get_item_group(me.name, "trapdoor") == 2 then
			minetest.sound_play(def.sound_close, {pos = pos, gain = 0.3, max_hear_distance = 16}, true)
			tmp_node = {name=name, param1=me.param1, param2=me.param2}
		-- Open
		else
			minetest.sound_play(def.sound_open, {pos = pos, gain = 0.3, max_hear_distance = 16}, true)
			tmp_node = {name=name.."_open", param1=me.param1, param2=me.param2}
		end
		minetest.set_node(pos, tmp_node)
	end

	local on_rightclick
	if not def.only_redstone_can_open then
		on_rightclick = function(pos, node, clicker)
			punch(pos)
		end
	end

	-- Default help texts
	local longdesc, usagehelp, tt_help
	longdesc = def._doc_items_longdesc
	if not longdesc then
		if def.only_redstone_can_open then
			longdesc = S("Trapdoors are horizontal barriers which can be opened or closed and climbed like a ladder when open. They occupy the upper or lower part of a block, depending on how they have been placed. This trapdoor can only be opened or closed by redstone power.")
		else
			longdesc = S("Trapdoors are horizontal barriers which can be opened or closed and climbed like a ladder when open. They occupy the upper or lower part of a block, depending on how they have been placed. This trapdoor can be opened or closed by hand or redstone power.")
		end
	end
	usagehelp = def._doc_items_usagehelp
	if not usagehelp and not def.only_redstone_can_open then
		usagehelp = S("To open or close this trapdoor, rightclick it or send a redstone signal to it.")
	end
    if def.only_redstone_can_open then
        tt_help = S("Openable by redstone power")
    else
        tt_help = S("Openable by players and redstone power")
    end

	-- Closed trapdoor

	local tile_front = def.tile_front
	local tile_side = def.tile_side
	if not tile_side then
		tile_side = tile_front
	end
	local tiles_closed = {
		tile_front,
		tile_front .. "^[transformFY",
		tile_side, tile_side,
		tile_side, tile_side,
	}

	local groups_closed = groups
	groups_closed.trapdoor = 1
	groups_closed.deco_block = 1
	minetest.register_node(":"..name, {
		description = def.description,
		_tt_help = tt_help,
		_doc_items_longdesc = longdesc,
		_doc_items_usagehelp = usagehelp,
		drawtype = "nodebox",
		tiles = tiles_closed,
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
		inventory_image = def.inventory_image,
		wield_image = def.wield_image,
		is_ground_content = false,
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		groups = groups_closed,
		_mcl_hardness = def._mcl_hardness,
		_mcl_blast_resistance = def._mcl_blast_resistance,
		sounds = def.sounds,
		node_box = {
			type = "fixed",
			fixed = {
			{-8/16, -8/16, -8/16, 8/16, -5/16, 8/16},},
		},
		mesecons = {effector = {
			action_on = (function(pos, node)
				punch(pos)
			end),
		}},
		on_place = function(itemstack, placer, pointed_thing)

			if not placer or not placer:is_player() then
				return itemstack
			end

			local p0 = pointed_thing.under
			local p1 = pointed_thing.above
			local param2 = 0

			local placer_pos = placer:get_pos()
			if placer_pos then
				param2 = minetest.dir_to_facedir(vector.subtract(p1, placer_pos))
			end

			local fpos = get_fpos(placer, pointed_thing)

			--local origname = itemstack:get_name()
			if p0.y - 1 == p1.y or (fpos > 0 and fpos < 0.5)
					or (fpos < -0.5 and fpos > -0.999999999) then
				param2 = param2 + 20
				if param2 == 21 then
					param2 = 23
				elseif param2 == 23 then
					param2 = 21
				end
			end
			return minetest.item_place(itemstack, placer, pointed_thing, param2)
		end,
		on_rightclick = on_rightclick,
		on_rotate = on_rotate,
	})

	-- Open trapdoor

	local groups_open = table.copy(groups)

	local tiles_open = {
		tile_side,
		tile_side .. "^[transformR180",
		tile_side .. "^[transformR270",
		tile_side .. "^[transformR90",
		tile_front .. "^[transform46",
		tile_front .. "^[transformFY",
	}

	groups_open.trapdoor = 2
	groups_open.not_in_creative_inventory = 1
	minetest.register_node(":"..name.."_open", {
		drawtype = "nodebox",
		tiles = tiles_open,
		use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
		is_ground_content = false,
		paramtype = "light",
		paramtype2 = "facedir",
		-- TODO: Implement Minecraft behaviour: Climbable if directly above
		-- ladder w/ matching orientation.
		-- Current behavour: Always climbable
		climbable = true,
		sunlight_propagates = true,
		pointable = true,
		groups = groups_open,
		_mcl_hardness = def._mcl_hardness,
		_mcl_blast_resistance = def._mcl_blast_resistance,
		sounds = def.sounds,
		drop = name,
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, 5/16, 0.5, 0.5, 0.5}
		},
		on_rightclick = on_rightclick,
		mesecons = {effector = {
			action_off = (function(pos, node)
				punch(pos)
			end),
		}},
		on_rotate = on_rotate,
	})

	if minetest.get_modpath("doc") then
		doc.add_entry_alias("nodes", name, "nodes", name.."_open")
	end

end
