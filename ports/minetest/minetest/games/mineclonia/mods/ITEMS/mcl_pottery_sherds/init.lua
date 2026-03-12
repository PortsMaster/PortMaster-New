mcl_pottery_sherds = {}
local modname = core.get_current_modname()
local S = core.get_translator(modname)
local D = mcl_util.get_dynamic_translator(modname)

mcl_pottery_sherds.defs = {
	["angler"] = { description = "Angler" },
	["archer"] = { description = "Archer" },
	["arms_up"] = { description = "Arms Up" },
	["blade"] = { description = "Blade" },
	["brewer"] = { description = "Brewer" },
	["burn"] = { description = "Burn" },
	["danger"] = { description = "Danger" },
	["explorer"] = { description = "Explorer" },
	["friend"] = { description = "Friend" },
	["heartbreak"] = { description = "Heartbreak" },
	["heart"] = { description = "Heart" },
	["howl"] = { description = "Howl" },
	["miner"] = { description = "Miner" },
	["mourner"] = { description = "Mourner" },
	["plenty"] = { description = "Plenty" },
	["prize"] = { description = "Prize" },
	["sheaf"] = { description = "Sheaf" },
	["shelter"] = { description = "Shelter" },
	["skull"] = { description = "Skull" },
	["snort"] = { description = "Snort" },
	["flow"] = { description = "Flow" },
	["guster"] = { description = "Guster" },
	["scrape"] = { description = "Scrape" },
}

local pot_face_positions = {
	vector.new(0,0, 7/16 + 0.001),
	vector.new(-7/16 - 0.001, 0, 0),
	vector.new(0, 0, -7/16 - 0.001),
	vector.new(7/16 + 0.001,  0, 0),
}

local pot_face_rotations = {
	vector.new(0, 0, 0),
	vector.new(0, 0.5 * math.pi, 0),
	vector.new(0, 0, 0),
	vector.new(0, -0.5 * math.pi, 0),
}

for name, def in pairs(mcl_pottery_sherds.defs) do
	core.register_craftitem("mcl_pottery_sherds:"..name, {
		description = D(def.description.." Pottery Sherd"),
		_tt_help = S("Used for crafting decorated pots"),
		_doc_items_create_entry = false,
		inventory_image = "mcl_pottery_sherds_"..name..".png",
		wield_image = "mcl_pottery_sherds_"..name..".png",
		groups = { pottery_sherd = 1, decorated_pot_recipe = 1, rarity = 1 },
		_mcl_pottery_sherd_name = name,
	})
end

local brick_groups = table.copy(core.registered_items["mcl_core:brick"].groups)
brick_groups["decorated_pot_recipe"] = 1
core.override_item("mcl_core:brick", { groups = brick_groups })

local function update_entities(pos,rm)
	pos = vector.round(pos)
	for v in core.objects_inside_radius(pos, 0.5) do
		local ent = v:get_luaentity()
		if ent and ent.name == "mcl_pottery_sherds:pot_face" then
			v:remove()
		end
	end
	if rm then return end
	local param2 = core.get_node(pos).param2
	local meta = core.get_meta(pos)
	local faces = core.deserialize(meta:get_string("pot_faces"))
	if not faces then return end
	for k,v in pairs(pot_face_positions) do
		local face = faces[(k + param2 - 1) % 4 + 1]
		if face then
			local o = core.add_entity(pos + v, "mcl_pottery_sherds:pot_face")
			local e = o:get_luaentity()
			e.texture = "mcl_pottery_sherds_pattern_"..face..".png"
			o:set_properties({
				textures = { "mcl_pottery_sherds_pattern_"..face..".png" },
			})
			o:set_rotation(pot_face_rotations[k])
		end
	end
end

core.register_entity("mcl_pottery_sherds:pot_face",{
	initial_properties = {
		physical = false,
		visual = "upright_sprite",
		collisionbox = {0,0,0,0,0,0},
		pointable = false,
	},
	on_activate = function(self, staticdata)
		self.object:set_armor_groups({immortal=1})
		local s = core.deserialize(staticdata)
		if type(s) == "table" then
			if not s.texture then
				update_entities(self.object:get_pos())
				self.object:remove()
				return
			end
			self.object:set_properties({
				textures = { s.texture },
			})
		end
	end,
	get_staticdata = function(self)
		return core.serialize({ texture = self.texture })
	end,
	on_step = function(self)
		if core.get_node(self.object:get_pos()).name ~= "mcl_pottery_sherds:pot" then
			self.object:remove()
		end
	end
})

local potbox = {
	type = "fixed",
	fixed = {
		{ -4/16,  9/16, -4/16,  4/16,  12/16,  4/16 },
		{ -3/16,  8/16, -3/16,  3/16,  9/16,  3/16 },
		{ -7/16,  -8/16, -7/16,  7/16,  8/16,  7/16 },
	}
}

local function get_sherd_desc(face)
	if face == nil then
		return core.registered_items["mcl_core:brick"].description
	end
	local description = mcl_pottery_sherds.defs[face].description
	return D(description.." Pottery Sherd")
end

local function get_itemstack_from_meta(metatable)
	local it = ItemStack("mcl_pottery_sherds:pot")
	local im = it:get_meta()
	im:set_string("pot_faces", metatable.fields["pot_faces"] or "")
	tt.reload_itemstack_description(it)
	return it
end

local function get_itemstack_from_node(pos)
	return get_itemstack_from_meta(core.get_meta(pos):to_table())
end

local function get_drops_from_node(metatable)
	local faces = core.deserialize(metatable.fields["pot_faces"]) or {}
	local drops = {}
	for i = 1, 4 do
		local face = faces[i]
		local item = face and"mcl_pottery_sherds:"..face or "mcl_core:brick"
		table.insert(drops, item)
	end

	local loot = metatable.fields["loot"]
	table.insert(drops, loot or {})
	return drops
end

local function drop_items(pos, metatable, silk_touch)
	local drops = silk_touch and {get_itemstack_from_meta(metatable)} or get_drops_from_node(metatable)
	for _, itemstack in pairs(drops) do
		core.add_item(pos, itemstack)
	end
end

core.register_node("mcl_pottery_sherds:pot", {
	description = S("Decorated Pot"),
	_doc_items_longdesc = S("Pots are decorative blocks."),
	_doc_items_usagehelp = S("Specially decorated pots can be crafted using pottery sherds"),
	drawtype = "nodebox",
	node_box = potbox,
	selection_box = potbox,
	collision_box = potbox,
	tiles = {
		{ name = "mcl_pottery_sherds_pot_top.png", align_style = "world" },
		{ name = "mcl_pottery_sherds_pot_bottom.png", align_style = "world" },
		{ name = "mcl_pottery_sherds_pot_side.png", align_style = "world" },
	},
	use_texture_alpha = "clip",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	is_ground_content = false,
	groups = {
		handy = 1, pickaxey = 1, dig_immediate = 3, deco_block = 1,
		attached_node = 1, dig_by_piston = 1, flower_pot = 1,
		not_in_creative_inventory = 1, pathfinder_partial = 2,
		jigsaw_construct = 1, jigsaw_preserve_meta = 1
	},
	sounds = mcl_sounds.node_sound_stone_defaults(),
	drop = "",
	_mcl_hardness = 0,
	_mcl_baseitem = get_itemstack_from_node,
	_mcl_generate_description = function(stack)
		if not stack then return nil end
		local meta = stack:get_meta()
		local faces = core.deserialize(meta:get_string("pot_faces"))
		if not faces then return nil end
		local def = stack:get_definition()

		local facedescs = {}
		for i = 1, 4 do
			facedescs[i] = get_sherd_desc(faces[i])
		end

		local img1 = faces[3] and "mcl_pottery_sherds_pattern_"..faces[3]..".png" or "blank.png"
		local img2 = faces[2] and "mcl_pottery_sherds_pattern_"..faces[2]..".png" or "blank.png"

		local img = core.inventorycube("blank.png", img2, img1)
		meta:set_string("inventory_overlay", img)
		meta:set_string("wield_overlay", img)
		meta:set_string("description", def.description.. "\n" .. core.colorize(mcl_colors.GREEN,table.concat(facedescs, "\n")))
	end,
	on_construct = function (pos)
		update_entities(pos)
	end,
	after_place_node = function(pos, _, itemstack, _)
		local meta = core.get_meta(pos)
		meta:set_string("pot_faces",itemstack:get_meta():get_string("pot_faces"))
		update_entities(pos)
	end,
	on_destruct = function(pos)
		update_entities(pos, true)
	end,
	on_blast = function(pos)
		drop_items(pos, core.get_meta(pos):to_table(), false)
		core.remove_node(pos)
	end,
	after_dig_node = function(pos, _, oldmeta, digger)
		local wielded = digger:get_wielded_item()
		local silk_touch = mcl_enchanting.get_enchantment(wielded, "silk_touch") ~= 0
		drop_items(pos, oldmeta, silk_touch)
	end,
	on_rotate = function(_, _,  _, mode, _)
		if mode == screwdriver.ROTATE_AXIS then
			return false
		end
	end,
	after_rotate = function(pos)
		update_entities(pos)
	end,
})

local function get_sherd_name(itemstack)
	local def = core.registered_items[itemstack:get_name()]
	local r = nil
	if def and def._mcl_pottery_sherd_name then
		r = def._mcl_pottery_sherd_name
	end
	return r
end

local function get_craft(itemstack, _, old_craft_grid, _)
	if itemstack:get_name() ~= "mcl_pottery_sherds:pot" then return end
	if old_craft_grid[1][2] == "mcl_core:brick" then return end
	local meta = itemstack:get_meta()

	meta:set_string("pot_faces",core.serialize({
		get_sherd_name(old_craft_grid[2]),
		get_sherd_name(old_craft_grid[6]),
		get_sherd_name(old_craft_grid[8]),
		get_sherd_name(old_craft_grid[4]),
	}))
	tt.reload_itemstack_description(itemstack)
	return itemstack
end

core.register_craft_predict(get_craft)
core.register_on_craft(get_craft)

core.register_craft({
	output = "mcl_pottery_sherds:pot",
	recipe = {
		{ "", "group:decorated_pot_recipe", "" },
		{ "group:decorated_pot_recipe", "", "group:decorated_pot_recipe" },
		{ "", "group:decorated_pot_recipe", "" },
	}
})
