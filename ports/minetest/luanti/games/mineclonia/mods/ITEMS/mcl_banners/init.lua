mcl_banners = {}
local modname = core.get_current_modname()
local modpath = core.get_modpath(modname)
local S = core.get_translator(modname)
local D = mcl_util.get_dynamic_translator(modname)

-- Maximum number of layers which can be put on a banner by players.
mcl_banners.max_craftable_layers = 12

-- Max. number layers to be displayed in item descriptions.
local max_layer_lines = 6

local node_sounds = mcl_sounds.node_sound_wood_defaults()
dofile(modpath.."/items.lua")

-- Format:
-- mcl_banners.colors.unicolor_grey = {
--    banner_name = D("Grey Banner"),
--    color_key = "silver", -- used in banner, wool, and dye itemname
--    color_name = "Grey", -- English, for use by dynamic translation
--    rgb = "#818177",
-- }
mcl_banners.colors = {
	-- Backward compatibility with previously wrong unicolor color names.
	["unicolor_brown"] = { color_key = "brown" },
	["unicolor_pink"]  = { color_key = "pink"  },
	["unicolor_lime"]  = { color_key = "lime"  },
	-- Up to date dye colours are added below.
}

local function init_colors ()
	local dye_colors = mcl_dyes.colors
	for k,v in pairs(mcl_dyes.colors) do
		mcl_banners.colors["unicolor_" .. v.unicolor] = { color_key = k }
	end
	for _,v in pairs(mcl_banners.colors) do
		local dye_key = v.color_key -- Set above, "silver"
		local color = dye_colors[dye_key]
		v.color_name = color.readable_name -- "Grey"
		v.banner_name = D(color.readable_name .. " Banner") -- "Grey Banner"
		v.rgb = color.rgb -- "#d0d6d7"
	end
end
init_colors()

-- Helper functions
local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

function mcl_banners.escape_texture (text) -- Escape texture string
	return text:gsub("\\", "\\\\"):gsub("%^", "\\%^"):gsub(":", "\\:")
end

function mcl_banners.read_layers (meta)
	local raw = meta:get_string("layers")
	local layers = core.deserialize(raw)
	if type(layers) ~= "table" then return {}, "" end
	return layers, raw
end

function mcl_banners.write_layers (meta, layers)
	if type(layers) ~= "table" or #layers <= 0 then
		meta:set_string("layers", "")
	else
		meta:set_string("layers", core.serialize(layers))
	end
end

function mcl_banners.is_same_layers (A, B)
	if type(A) ~= type(B) or type(A) ~= "table" or #A ~= #B then return false end
	for i = 1, #A do
		if A[i].pattern ~= B[i].pattern or A[i].color ~= B[i].color then
			return false
		end
	end
	return true
end

-- Update banner description, returning description, name
function mcl_banners.update_description (itemstack, limit)
	local def, meta = itemstack:get_definition(), itemstack:get_meta()
	local name, itemname = meta:get_string("name"), itemstack:get_name()
	local orig_desc = def._tt_original_description or def.description
	local base_name = orig_desc:gsub("%W", "%%%1")
	local layers = mcl_banners.read_layers(meta)
	local def_name = def.description
	if name ~= "" and name:find("Ominous Banner") then name = "" end -- Pre-0.84.0 Ominous Banners
	if name == "" then
		name = def_name
		if mcl_raids.is_banner_item(itemstack, layers) then
			name = def_name:gsub(base_name, mcl_raids.ominous_banner_name)
		end
	else
		name = def_name:gsub(base_name, core.colorize(tt.NAME_COLOR, name))
	end
	if mcl_enchanting.is_enchanted(itemname) then -- Enchanted shield
		local enchantments = mcl_enchanting.get_enchantments(itemstack)
		local old_name = name
		for enchantment, level in pairs(enchantments) do
			name = name .. "\n" .. mcl_enchanting.get_colorized_enchantment_description(enchantment, level)
		end
		if name ~= old_name then
			name = name .. "\n"
		end
	end
	local newdesc = mcl_banners.make_advanced_banner_description(name, layers, limit)
	meta:set_string("description", newdesc)

	if core.get_item_group(itemname, "banner") > 0 then
		local image = mcl_banners.make_banner_texture(def._unicolor, layers, "item")
		meta:set_string("inventory_overlay", image)
		meta:set_string("wield_overlay", image)
	end
	return newdesc, name, def_name
end

-- Create a banner description containing all the layer names
function mcl_banners.make_advanced_banner_description (name, layers, limit)
	if layers == nil or #layers == 0 then return name end
	local layerstrings = {}
	if type(limit) ~= "number" or limit < 0 then limit = max_layer_lines end
	for l=1, math.min(#layers, limit) do
		local layer = layers[l]
		local layer_name, valid = mcl_banners.make_pattern_name(layer.color, layer.pattern)
		if valid then
			table.insert(layerstrings, layer_name)
		end
	end
	if #layers == limit + 1 then
		table.insert(layerstrings, S("And one additional layer"))
	elseif #layers > limit + 1 then
		table.insert(layerstrings, S("And @1 additional layers", #layers - max_layer_lines))
	end

	-- Final string concatenations: Just a list of strings
	local append = table.concat(layerstrings, "\n")
	return name .. "\n" .. core.colorize(mcl_colors.GRAY, append)
end

-- Add pattern/emblazoning crafting recipes
dofile(modpath.."/patterncraft.lua")

-- Overlay ratios (0-255)
local base_color_ratio = 255

local standing_banner_entity_offset = vector.new(0, -0.499, 0)
local hanging_banner_entity_offset = vector.new(0, -0.64, 0)

local function rotation_level_to_yaw(rotation_level)
	return (rotation_level * (math.pi/8)) + math.pi
end

local function on_dig_banner(pos, _, digger)
	-- Check protection
	local name = digger:get_player_name()
	if core.is_protected(pos, name) then
		core.record_protection_violation(pos, name)
		return
	end

	local inv = core.get_meta(pos):get_inventory()
	local item = inv:get_stack("banner", 1)
	tt.reload_itemstack_description(item) -- Update description of pre-0.111 banners.
	local item_str = item:is_empty() and "mcl_banners:banner_item_white" or item:to_string()

	core.handle_node_drops(pos, { item_str }, digger)

	item:set_count(0)
	inv:set_stack("banner", 1, item)

	-- Remove node
	core.remove_node(pos)
end

local function on_destruct_banner(pos, hanging)
	local offset, nodename
	if hanging then
		offset = hanging_banner_entity_offset
		nodename = "mcl_banners:hanging_banner"
	else
		offset = standing_banner_entity_offset
		nodename = "mcl_banners:standing_banner"
	end
	-- Find this node's banner entity and remove it
	local checkpos = vector.add(pos, offset)
	for v in core.objects_inside_radius(checkpos, 0.5) do
		local ent = v:get_luaentity()
		if ent and ent.name == nodename then
			v:remove()
			break
		end
	end

	-- Drop item only if it was not handled in on_dig_banner
	local inv = core.get_meta(pos):get_inventory()
	local item = inv:get_stack("banner", 1)
	if not item:is_empty() then
		core.handle_node_drops(pos, {item:to_string()})
	end
end

local function on_destruct_standing_banner(pos)
	return on_destruct_banner(pos, false)
end

local function on_destruct_hanging_banner(pos)
	return on_destruct_banner(pos, true)
end

-- Generate coloured pattern name, used in loom pattern tooltip and banner/shield item descriptions.
-- Param unicolor: unicolor key ("unicolor_grey") or mod.colors item (with .color_name)
-- Param pattern_id: pattern key ("circle") or mod.patterns item (with .name)
-- Return: Localised name, pattern is valid
function mcl_banners.make_pattern_name(unicolor, pattern_id)
	local colortab, pattern = unicolor, pattern_id
	if type(unicolor) ~= "table" then
		colortab = mcl_banners.colors[unicolor]
	end
	if type(pattern_id) ~= "table" then
		pattern = mcl_banners.patterns[pattern_id]
	end
	if not colortab or not colortab.color_name
	or not pattern or not pattern.name then
		return unicolor .. " " .. pattern_id, false
	end
	return D(colortab.color_name .. " " .. pattern.name), true
end

mcl_banners.banner_texture_builder = { -- Images are not scaled; all must have same resolution.
	blank = "mcl_banners_banner_base.png",
	base = function (rgb, ratio)
		return "(mcl_banners_banner_base.png^[mask:mcl_banners_base_inverted.png)"
		    .. "^((mcl_banners_banner_base.png^[colorize:"..rgb..":"..ratio..")^[mask:mcl_banners_base.png)"
	end,
}

mcl_banners.item_texture_builder = {
	blank = "mcl_banners_item_base_48.png^mcl_banners_item_overlay_48.png",
	base = function (rgb, ratio)
		return "mcl_banners_item_base_48.png^(mcl_banners_item_overlay_48.png^[colorize:"..rgb..":"..ratio..")"
	end,
	layer = nil, -- function (previous_result, rgb, pattern)
	combine = function (base, layers)
		if layers == "" then return base end
		local escape = mcl_banners.escape_texture
		-- Banner Item texture size 48x48 offset 14,4.  Pattern resize required to support theme packs.
		-- Pattern Texture size 64x64, Front at offset 1,1 size 20x40.
		return "[combine:48x48:0,0=" .. escape(base)
		    .. ":14,4=" .. escape("[combine:20x40:-1,-1=" .. escape(layers:sub(2).."^[resize:64x64") )
	end,
}

function mcl_banners.make_banner_texture (base_color, layers, builder)
	local colorize, result
	if mcl_banners.colors[base_color] then
		colorize = mcl_banners.colors[base_color].rgb
	end

	builder = builder or mcl_banners.banner_texture_builder
	if builder == "item" then builder = mcl_banners.item_texture_builder end

	-- Vanilla, non-coloured banner.
	if not colorize then
		result = builder.blank or "blank.png"
		if type(result) == "function" then result = result() end
		return result
	end

	-- Base texture with base color.
	result = builder.base(colorize, base_color_ratio)

	-- Pattern Layers.
	local coats = ""
	if layers and #layers > 0 then
		for l=1, #layers do
			local layerinfo = layers[l]
			if layerinfo and layerinfo.pattern and layerinfo.color and mcl_banners.colors[layerinfo.color] then
				local pattern = "mcl_banners_" .. layerinfo.pattern .. ".png"
				local color = mcl_banners.colors[layerinfo.color].rgb
				if builder.layers then
					coats = builder.layers(coats, color, pattern)
				else
					coats = coats .. "^("..pattern.."^[colorize:"..color..":255^[mask:"..pattern..")"
				end
			end
		end
	end

	-- Combine base with patterns.
	if not builder.combine then return result .. coats end
	result = builder.combine(result, coats)
	return result
end

local function spawn_banner_entity(pos, hanging, itemstack)
	local banner = core.add_entity(pos, hanging and "mcl_banners:hanging_banner" or "mcl_banners:standing_banner")
	if banner == nil then return banner end

	local imeta = itemstack:get_meta()
	local desc, name = mcl_banners.update_description(itemstack)
	local layers = mcl_banners.read_layers(imeta)
	local colorid = itemstack:get_definition()._unicolor
	banner:get_luaentity():_set_textures(colorid, layers)
	banner:get_luaentity()._item_name = name
	banner:get_luaentity()._item_description = desc
	return banner
end

local function respawn_banner_entity(pos, node, force)
	local is_hanging = node.name == "mcl_banners:hanging_banner"
	local offset = is_hanging and hanging_banner_entity_offset or standing_banner_entity_offset
	local bpos = vector.add(pos, offset)
	for v in core.objects_inside_radius(bpos, 0.5) do
		local ent = v:get_luaentity()
		if ent and (ent.name == "mcl_banners:standing_banner" or ent.name == "mcl_banners:hanging_banner") then
			if not force then return end -- Banner exists, not forcing removal, just quit.
			v:remove()
		end
	end

	-- Spawn new entity and set rotation
	local meta = core.get_meta(pos)
	local banner_item = meta:get_inventory():get_stack("banner", 1)
	local banner_entity = spawn_banner_entity(bpos, is_hanging, banner_item)
	local rotation_level = meta:get_int("rotation_level")
	local final_yaw = rotation_level_to_yaw(rotation_level)
	if banner_entity then
		banner_entity:set_yaw(final_yaw)
	end
end

local function get_banner_stack(pos)
	local inv = core.get_meta(pos):get_inventory()
	return inv:get_stack("banner", 1)
end

-- Banner nodes.
-- These are an invisible nodes which are only used to destroy the banner entity.
-- All the important banner information (such as color) is stored in the entity.
-- It is used only used internally.

-- Standing banner node
-- This one is also used for the help entry to avoid spamming the help with 16 entries.
core.register_node("mcl_banners:standing_banner", {
	_doc_items_entry_name = S("Banner"),
	_doc_items_image = mcl_banners.make_banner_texture("", nil, "item"),
	_doc_items_longdesc = S("Banners are tall colorful decorative blocks. They can be placed on the floor and at walls. Banners can be emblazoned with a variety of patterns by placing it with a dye in the loom, or with lots of dyes in crafting table."),
	_doc_items_usagehelp = S("Emblazoned banners can be emblazoned again to combine patterns. Up to @1 patterns can be layered on a banner. To wash off a banner's top-most layer, use it on a cauldron with water.", mcl_banners.max_craftable_layers).."\n"..
		S("An emblazoned banner can be copied by placing two banners of the same base color in the crafting table — one needs to be emblazoned, the other one must be clean."),
	walkable = false,
	is_ground_content = false,
	paramtype = "light",
	sunlight_propagates = true,
	drawtype = "nodebox",
	-- Nodebox is drawn as fallback when the entity is missing, so that the
	-- banner node is never truly invisible.
	-- If the entity is drawn, the nodebox disappears within the real banner mesh.
	node_box = {
		type = "fixed",
		fixed = { -1/32, -0.49, -1/32, 1/32, 1.49, 1/32 },
	},
	-- This texture is based on the banner base texture
	tiles = { "mcl_banners_fallback_wood.png" },

	inventory_image = "mcl_banners_item_base_48.png",
	wield_image = "mcl_banners_item_base_48.png",

	selection_box = {type = "fixed", fixed= {-0.3, -0.5, -0.3, 0.3, 0.5, 0.3} },
	groups = {axey=1,handy=1, attached_node = 1, not_in_creative_inventory = 1, banner = 1, not_in_craft_guide = 1, material_wood=1, dig_by_piston=1, flammable=-1, unmovable_by_piston = 1, jigsaw_preserve_meta = 1, jigsaw_construct = 1,},
	stack_max = 16,
	sounds = node_sounds,
	drop = "", -- Item drops are handled in entity code

	--disallow any direct interaction with the banner inventory
	allow_metadata_inventory_put = function() return 0 end,
	allow_metadata_inventory_take = function() return 0 end,
	allow_metadata_inventory_move = function() return 0 end,

	on_dig = on_dig_banner,
	on_destruct = on_destruct_standing_banner,
	on_punch = function(pos, node)
		respawn_banner_entity(pos, node)
	end,
	_mcl_hardness = 1,
	_mcl_baseitem = get_banner_stack,
	on_rotate = function(pos, node, _, mode)
		if mode == screwdriver.ROTATE_FACE then
			local meta = core.get_meta(pos)
			local rot = meta:get_int("rotation_level")
			rot = (rot - 1) % 16
			meta:set_int("rotation_level", rot)
			respawn_banner_entity(pos, node, true)
			return true
		else
			return false
		end
	end,
})

local screwdriver_rot_by_param2 = { 0, 12, 4, 0, 8 }

-- Hanging banner node
core.register_node("mcl_banners:hanging_banner", {
	walkable = false,
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	drawtype = "nodebox",
	inventory_image = "mcl_banners_item_base_48.png",
	wield_image = "mcl_banners_item_base_48.png",
	tiles = { "mcl_banners_fallback_wood.png" },
	node_box = {
		type = "wallmounted",
		wall_side = { -0.49, 0.41, -0.49, -0.41, 0.49, 0.49 },
		wall_top = { -0.49, 0.41, -0.49, -0.41, 0.49, 0.49 },
		wall_bottom = { -0.49, -0.49, -0.49, -0.41, -0.41, 0.49 },
	},
	selection_box = {type = "wallmounted", wall_side = {-0.5, -0.5, -0.5, -4/16, 0.5, 0.5} },
	groups = {axey=1,handy=1, attached_node = 1, not_in_creative_inventory = 1, banner = 1, not_in_craft_guide = 1, material_wood=1, flammable=-1, unmovable_by_piston = 1, jigsaw_preserve_meta = 1, jigsaw_construct = 1},
	stack_max = 16,
	sounds = node_sounds,
	drop = "", -- Item drops are handled in entity code

	--disallow any direct interaction with the banner inventory
	allow_metadata_inventory_put = function() return 0 end,
	allow_metadata_inventory_take = function() return 0 end,
	allow_metadata_inventory_move = function() return 0 end,

	on_dig = on_dig_banner,
	on_destruct = on_destruct_hanging_banner,
	on_punch = respawn_banner_entity,
	_mcl_hardness = 1,
	_mcl_baseitem = get_banner_stack,
	on_rotate = function(pos, node, _, mode)
		if mode ~= screwdriver.ROTATE_FACE then return false end
		local r = screwdriver.rotate.wallmounted(pos, node, mode)
		node.param2 = r
		core.swap_node(pos, node)
		local meta = core.get_meta(pos)
		local rot = screwdriver_rot_by_param2[ r or 0 ] or 0
		meta:set_int("rotation_level", rot)
		respawn_banner_entity(pos, node, true)
		return true
	end,
})

-- Banner items. Comes in 16 base colors, with patterned texture dynamically generated.
-- Combine the items into only 1 item was opposed by erle as it hinders adding banner to map.
local function init_banner_registration ()
	for uni_key, colortab in pairs(mcl_banners.colors) do
		local color_id = colortab.color_key
		local itemstring = "mcl_banners:banner_item_" .. color_id
		local item_texture = mcl_banners.make_banner_texture(uni_key, nil, "item")

		-- Generate pattern names for localisation.
		for _, recipe in pairs(mcl_banners.patterns) do
			mcl_banners.make_pattern_name(colortab, recipe)
		end

		core.register_craftitem(itemstring, {
			description = colortab.banner_name,
			_tt_help = S("Paintable decoration"),
			_doc_items_create_entry = false,
			inventory_image = item_texture,
			wield_image = item_texture,
			-- Banner group groups together the banner items, but not the nodes.
			-- Used for crafting.
			groups = { banner = 1, deco_block = 1, flammable = -1 },
			stack_max = 16,
			_mcl_burntime = 15,
			_unicolor = uni_key,
			on_place = function(itemstack, placer, pointed_thing)
				local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
				if rc then return rc end
				local above = pointed_thing.above
				local under = pointed_thing.under

				local node_under = core.get_node(under)
				if placer and not placer:get_player_control().sneak then
					if mcl_util.check_position_protection(under, placer) then return itemstack end

					if core.get_item_group(node_under.name, "cauldron_water") > 0 then
						if mcl_cauldrons.add_level(pointed_thing.under, -1) then
							local imeta = itemstack:get_meta()
							local layers = mcl_banners.read_layers(imeta)
							if #layers > 0 then
								table.remove(layers)
								mcl_banners.write_layers(imeta, layers)
								tt.reload_itemstack_description(itemstack)
							end
							return itemstack
						end
					end
				end

				-- Place the node!
				local is_hanging = false

				-- Standing or hanging banner. The placement rules are enforced by the node definitions
				local _, success = core.item_place_node(ItemStack("mcl_banners:standing_banner"), placer, pointed_thing)
				if not success then
					-- Forbidden on ceiling
					if pointed_thing.under.y ~= pointed_thing.above.y then
						return itemstack
					end
					_, success = core.item_place_node(ItemStack("mcl_banners:hanging_banner"), placer, pointed_thing)
					if not success then
						return itemstack
					end
					is_hanging = true
				end
				local place_pos
				local def_under = core.registered_nodes[node_under.name]
				if def_under and def_under.buildable_to then
					place_pos = under
				else
					place_pos = above
				end
				local bnode = core.get_node(place_pos)
				if bnode.name ~= "mcl_banners:standing_banner" and bnode.name ~= "mcl_banners:hanging_banner" then
					core.log("error", "[mcl_banners] The placed banner node is not what the mod expected!")
					return itemstack
				end
				local meta = core.get_meta(place_pos)
				local inv = meta:get_inventory()
				inv:set_size("banner", 1)
				local store_stack = ItemStack(itemstack)
				store_stack:set_count(1)
				inv:set_stack("banner", 1, store_stack)

				-- Spawn entity
				local entity_place_pos
				local offset = is_hanging and hanging_banner_entity_offset or standing_banner_entity_offset
				entity_place_pos = vector.add(place_pos, offset)
				local banner_entity = spawn_banner_entity(entity_place_pos, is_hanging, itemstack)
				local name = itemstack:get_meta():get_string("name")
				if name ~= "" then
					meta:set_string("infotext", name)
				end
				-- Set rotation
				local final_yaw, rotation_level
				if is_hanging then
					local pdir = vector.direction(pointed_thing.under, pointed_thing.above)
					final_yaw = core.dir_to_yaw(pdir)
					if pdir.x > 0 then
						rotation_level = 4
					elseif pdir.z > 0 then
						rotation_level = 8
					elseif pdir.x < 0 then
						rotation_level = 12
					else
						rotation_level = 0
					end
				else
					-- Determine the rotation based on player's yaw
					local yaw = placer:get_look_horizontal()
					-- Select one of 16 possible rotations (0-15)
					rotation_level = round((yaw / (math.pi*2)) * 16)
					if rotation_level >= 16 then
						rotation_level = 0
					end
					final_yaw = rotation_level_to_yaw(rotation_level)
				end
				meta:set_int("rotation_level", rotation_level)

				if banner_entity then
					banner_entity:set_yaw(final_yaw)
				end

				if not core.is_creative_enabled(placer:get_player_name()) then
					itemstack:take_item()
				end
				core.sound_play({name="default_place_node_hard", gain=1.0}, {pos = place_pos}, true)

				return itemstack
			end,
			_on_set_item_entity = function (stack)
				return stack, {wield_item = stack:to_string()}
			end,
			_mcl_generate_description = mcl_banners.update_description,
		})

		local wool = "mcl_wool:" .. color_id
		core.register_craft({
			output = itemstring,
			recipe = {
				{ wool, wool, wool },
				{ wool, wool, wool },
				{ "", "mcl_core:stick", "" },
			}
		})
		doc.add_entry_alias("nodes", "mcl_banners:standing_banner", "craftitems", itemstring)
	end

	doc.add_entry_alias("nodes", "mcl_banners:standing_banner", "nodes", "mcl_banners:hanging_banner")
end
init_banner_registration()

-- Banner entities.
local entity_standing = {
	initial_properties = {
		physical = false,
		collide_with_objects = false,
		visual = "mesh",
		mesh = "amc_banner.b3d",
		visual_size = { x=2.499, y=2.499 },
		textures = {mcl_banners.make_banner_texture()},
		pointable = false,
	},

	_base_color = nil, -- base color of banner
	_layers = nil, -- table of layers painted over the base color.
		-- This is a table of tables with each subtable having the following fields:
			-- color: layer color ID, e.g. "unicolor_grey"
			-- pattern: layer pattern ID, e.g. "circle"

	get_staticdata = function(self)
		local out = { _base_color = self._base_color, _layers = self._layers, _name = self._name }
		return core.serialize(out)
	end,
	on_activate = function(self, staticdata)
		self:_set_banner_node()
		if core.get_item_group(core.get_node(self._node_pos).name, "banner") <= 0
			and self.name ~= "mcl_raids:ominous_banner" then
			core.log("warning", "[mcl_banners] Orphan banner entity found at "..core.pos_to_string(self.object:get_pos(), 0).." removing it.")
			self.object:remove()
			return
		end

		if staticdata and staticdata ~= "" then
			local inp = core.deserialize(staticdata)
			self._base_color = inp._base_color
			self._layers = inp._layers
			self._name = inp._name
			self.object:set_properties({
				textures = {mcl_banners.make_banner_texture(self._base_color, self._layers)},
			})
		end
		-- Make banner slowly swing
		self.object:set_animation({x=0, y=80}, 25)
		self.object:set_armor_groups({immortal=1})
	end,

	-- Set the banner textures. This function can be used by external mods.
	-- Meaning of parameters:
	-- * self: Lua entity reference to entity.
	-- * other parameters: Same meaning as in mcl_banners.make_banner_texture
	_set_textures = function(self, base_color, layers)
		if base_color then
			self._base_color = base_color
		end
		if layers then
			self._layers = layers
		end
		self.object:set_properties({textures = {mcl_banners.make_banner_texture(self._base_color, self._layers)}})
	end,
	_set_banner_node = function(self)
		self._node_pos = self.object:get_pos():subtract(standing_banner_entity_offset):round()
	end,
	_mcl_pistons_unmovable = true
}
core.register_entity("mcl_banners:standing_banner", entity_standing)

core.register_entity("mcl_banners:hanging_banner", table.merge(entity_standing, {
	initial_properties = table.merge(entity_standing.initial_properties, {
		mesh = "amc_banner_hanging.b3d"
	}),
	_set_banner_node = function(self)
		self._node_pos = self.object:get_pos():subtract(hanging_banner_entity_offset):round()
	end
}))

-- FIXME: Prevent entity destruction by /clearobjects
core.register_lbm({
	label = "Respawn banner entities",
	name = "mcl_banners:respawn_entities",
	run_at_every_load = true,
	nodenames = {"mcl_banners:standing_banner", "mcl_banners:hanging_banner"},
	action = function(pos, node)
		respawn_banner_entity(pos, node)
	end,
})

-- Update hanging banner to new offset and scale to avoid darkened by unlit block below.
core.register_lbm({
	label = "Update hanging banner",
	name = "mcl_banners:resacle_hanging_banners",
	run_at_every_load = false,
	nodenames = {"mcl_banners:hanging_banner"},
	action = function(pos, node)
		respawn_banner_entity(pos, node, true)
	end,
})
