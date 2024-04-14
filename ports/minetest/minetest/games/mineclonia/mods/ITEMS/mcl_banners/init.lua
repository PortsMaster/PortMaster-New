local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)
local S = minetest.get_translator(modname)

local mod_mcl_core = minetest.get_modpath("mcl_core")
local mod_doc = minetest.get_modpath("doc")

local node_sounds
if minetest.get_modpath("mcl_sounds") then
	node_sounds = mcl_sounds.node_sound_wood_defaults()
end
dofile(modpath.."/items.lua")

-- Helper function
local function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

mcl_banners = {}

mcl_banners.colors = {
	-- Format:
	-- [ID] = { banner description, wool, unified dyes color group, overlay color, dye, color name for emblazonings }
	["unicolor_white"] =      {"white",      S("White Banner"),      "mcl_wool:white", mcl_dyes.colors.white.rgb, "mcl_dyes:white", S("White") },
	["unicolor_darkgrey"] =   {"grey",       S("Grey Banner"),       "mcl_wool:grey", mcl_dyes.colors.grey.rgb, "mcl_dyes:dark_grey", S("Grey") },
	["unicolor_grey"] =       {"silver",     S("Light Grey Banner"), "mcl_wool:silver", mcl_dyes.colors.silver.rgb, "mcl_dyes:grey", S("Light Grey") },
	["unicolor_black"] =      {"black",      S("Black Banner"),      "mcl_wool:black", mcl_dyes.colors.black.rgb, "mcl_dyes:black", S("Black") },
	["unicolor_red"] =        {"red",        S("Red Banner"),        "mcl_wool:red", mcl_dyes.colors.red.rgb, "mcl_dyes:red", S("Red") },
	["unicolor_yellow"] =     {"yellow",     S("Yellow Banner"),     "mcl_wool:yellow", mcl_dyes.colors.yellow.rgb, "mcl_dyes:yellow", S("Yellow") },
	["unicolor_dark_green"] = {"green",      S("Green Banner"),      "mcl_wool:green", mcl_dyes.colors.green.rgb, "mcl_dyes:dark_green", S("Green") },
	["unicolor_cyan"] =       {"cyan",       S("Cyan Banner"),       "mcl_wool:cyan", mcl_dyes.colors.cyan.rgb, "mcl_dyes:cyan", S("Cyan") },
	["unicolor_blue"] =       {"blue",       S("Blue Banner"),       "mcl_wool:blue", mcl_dyes.colors.blue.rgb, "mcl_dyes:blue", S("Blue") },
	["unicolor_red_violet"] = {"magenta",    S("Magenta Banner"),    "mcl_wool:magenta", mcl_dyes.colors.magenta.rgb, "mcl_dyes:magenta", S("Magenta")},
	["unicolor_orange"] =     {"orange",     S("Orange Banner"),     "mcl_wool:orange", mcl_dyes.colors.orange.rgb, "mcl_dyes:orange", S("Orange") },
	["unicolor_violet"] =     {"purple",     S("Purple Banner"),     "mcl_wool:purple", mcl_dyes.colors.purple.rgb, "mcl_dyes:violet", S("Violet") },
	["unicolor_brown"] =      {"brown",      S("Brown Banner"),      "mcl_wool:brown", mcl_dyes.colors.brown.rgb, "mcl_dyes:brown", S("Brown") },
	["unicolor_dark_orange"] ={"brown",      S("Brown Banner"),      "mcl_wool:brown", mcl_dyes.colors.brown.rgb, "mcl_dyes:brown", S("Brown") },
	["unicolor_pink"] =       {"pink",       S("Pink Banner"),       "mcl_wool:pink", mcl_dyes.colors.pink.rgb, "mcl_dyes:pink", S("Pink") },
	["unicolor_light_red"] =  {"pink",       S("Pink Banner"),       "mcl_wool:pink", mcl_dyes.colors.pink.rgb, "mcl_dyes:pink", S("Pink") },
	["unicolor_lime"] =       {"lime",       S("Lime Banner"),       "mcl_wool:lime", mcl_dyes.colors.lime.rgb, "mcl_dyes:green", S("Lime") },
	["unicolor_green"] =      {"lime",       S("Lime Banner"),       "mcl_wool:lime", mcl_dyes.colors.lime.rgb, "mcl_dyes:green", S("Lime") },
	--the duplicate lines for brown/dark_orange, lime/green and pink/light_red are needed because mcl_banners previously used the wrong unicolor color names
	["unicolor_light_blue"] = {"light_blue", S("Light Blue Banner"), "mcl_wool:light_blue", mcl_dyes.colors.light_blue.rgb, "mcl_dyes:lightblue", S("Light Blue") },
}


local pattern_names = {
      "",
      "border",
      "bricks",
      "circle",
      "creeper",
      "cross",
      "curly_border",
      "diagonal_up_left",
      "diagonal_up_right",
      "diagonal_right",
      "diagonal_left",
      "flower",
      "gradient",
      "gradient_up",
      "half_horizontal_bottom",
      "half_horizontal",
      "half_vertical",
      "half_vertical_right",
      "thing",
      "rhombus",
      "skull",
      "small_stripes",
      "square_bottom_left",
      "square_bottom_right",
      "square_top_left",
      "square_top_right",
      "straight_cross",
      "stripe_bottom",
      "stripe_center",
      "stripe_downleft",
      "stripe_downright",
      "stripe_left",
      "stripe_middle",
      "stripe_right",
      "stripe_top",
      "triangle_bottom",
      "triangle_top",
      "triangles_bottom",
      "triangles_top",
      "globe",
      "piglin",
}

local colors_reverse = {}
for k,v in pairs(mcl_banners.colors) do
	colors_reverse["mcl_banners:banner_item_"..v[1]] = k
end

function mcl_banners.color_reverse(itemname)
	return colors_reverse[itemname]
end

-- Add pattern/emblazoning crafting recipes
dofile(modpath.."/patterncraft.lua")

-- Overlay ratios (0-255)
local base_color_ratio = 224
local layer_ratio = 255

local standing_banner_entity_offset = { x=0, y=-0.499, z=0 }
local hanging_banner_entity_offset = { x=0, y=-1.7, z=0 }

local function rotation_level_to_yaw(rotation_level)
	return (rotation_level * (math.pi/8)) + math.pi
end

local function on_dig_banner(pos, node, digger)
	-- Check protection
	local name = digger:get_player_name()
	if minetest.is_protected(pos, name) then
		minetest.record_protection_violation(pos, name)
		return
	end

	local inv = minetest.get_meta(pos):get_inventory()
	local item = inv:get_stack("banner", 1)
	local item_str = item:is_empty() and "mcl_banners:banner_item_white"
		or item:to_string()

	minetest.handle_node_drops(pos, { item_str }, digger)

	item:set_count(0)
	inv:set_stack("banner", 1, item)

	-- Remove node
	minetest.remove_node(pos)
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
	local objects = minetest.get_objects_inside_radius(checkpos, 0.5)
	for _, v in ipairs(objects) do
		local ent = v:get_luaentity()
		if ent and ent.name == nodename then
			v:remove()
		end
	end

	-- Drop item only if it was not handled in on_dig_banner
	local inv = minetest.get_meta(pos):get_inventory()
	local item = inv:get_stack("banner", 1)
	if not item:is_empty() then
		minetest.handle_node_drops(pos, {item:to_string()})
	end
end

local function on_destruct_standing_banner(pos)
	return on_destruct_banner(pos, false)
end

local function on_destruct_hanging_banner(pos)
	return on_destruct_banner(pos, true)
end

function mcl_banners.make_banner_texture(base_color, layers)
	local colorize
	if mcl_banners.colors[base_color] then
		colorize = mcl_banners.colors[base_color][4]
	end
	if colorize then
		-- Base texture with base color
		local base = "(mcl_banners_banner_base.png^[mask:mcl_banners_base_inverted.png)^((mcl_banners_banner_base.png^[colorize:"..colorize..":"..base_color_ratio..")^[mask:mcl_banners_base.png)"

		-- Optional pattern layers
		if layers then
			local finished_banner = base
			for l=1, #layers do
				local layerinfo = layers[l]
				if layerinfo and layerinfo.pattern and layerinfo.color and mcl_banners.colors[layerinfo.color] then
					local pattern = "mcl_banners_" .. layerinfo.pattern .. ".png"
					local color = mcl_banners.colors[layerinfo.color][4]

					-- Generate layer texture
					local layer = "(("..pattern.."^[colorize:"..color..":"..layer_ratio..")^[mask:"..pattern..")"

					finished_banner = finished_banner .. "^" .. layer
				end
			end
			return finished_banner
		end
		return base
	else
		return "mcl_banners_banner_base.png"
	end
end

local function spawn_banner_entity(pos, hanging, itemstack)
	local banner
	if hanging then
		banner = minetest.add_entity(pos, "mcl_banners:hanging_banner")
	else
		banner = minetest.add_entity(pos, "mcl_banners:standing_banner")
	end
	if banner == nil then
		return banner
	end
	local imeta = itemstack:get_meta()
	local layers_raw = imeta:get_string("layers")
	local layers = minetest.deserialize(layers_raw)
	local colorid = mcl_banners.color_reverse(itemstack:get_name())
	banner:get_luaentity():_set_textures(colorid, layers)
	local mname = imeta:get_string("name")
	if mname and mname ~= "" then
		banner:get_luaentity()._item_name = mname
		banner:get_luaentity()._item_description = imeta:get_string("description")
	end

	return banner
end

local function respawn_banner_entity(pos, node, force)
	local hanging = node.name == "mcl_banners:hanging_banner"
	local offset
	if hanging then
		offset = hanging_banner_entity_offset
	else
		offset = standing_banner_entity_offset
	end
	-- Check if a banner entity already exists
	local bpos = vector.add(pos, offset)
	local objects = minetest.get_objects_inside_radius(bpos, 0.5)
	for _, v in ipairs(objects) do
		local ent = v:get_luaentity()
		if ent and (ent.name == "mcl_banners:standing_banner" or ent.name == "mcl_banners:hanging_banner") then
			if force then
				v:remove()
			else
				return
			end
		end
	end
	-- Spawn new entity
	local meta = minetest.get_meta(pos)
	local banner_item = meta:get_inventory():get_stack("banner", 1)
	local banner_entity = spawn_banner_entity(bpos, hanging, banner_item)

	-- Set rotation
	local rotation_level = meta:get_int("rotation_level")
	local final_yaw = rotation_level_to_yaw(rotation_level)
	banner_entity:set_yaw(final_yaw)
end

-- Banner nodes.
-- These are an invisible nodes which are only used to destroy the banner entity.
-- All the important banner information (such as color) is stored in the entity.
-- It is used only used internally.

-- Standing banner node
-- This one is also used for the help entry to avoid spamming the help with 16 entries.
minetest.register_node("mcl_banners:standing_banner", {
	_doc_items_entry_name = S("Banner"),
	_doc_items_image = "mcl_banners_item_base.png^mcl_banners_item_overlay.png",
	_doc_items_longdesc = S("Banners are tall colorful decorative blocks. They can be placed on the floor and at walls. Banners can be emblazoned with a variety of patterns using a lot of dye in crafting."),
	_doc_items_usagehelp = S("Use crafting to draw a pattern on top of the banner. Emblazoned banners can be emblazoned again to combine various patterns. You can draw up to 12 layers on a banner that way. If the banner includes a gradient, only 3 layers are possible.").."\n"..
S("You can copy the pattern of a banner by placing two banners of the same color in the crafting grid—one needs to be emblazoned, the other one must be clean. Finally, you can use a banner on a cauldron with water to wash off its top-most layer."),
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

	inventory_image = "mcl_banners_item_base.png",
	wield_image = "mcl_banners_item_base.png",

	selection_box = {type = "fixed", fixed= {-0.3, -0.5, -0.3, 0.3, 0.5, 0.3} },
	groups = {axey=1,handy=1, attached_node = 1, not_in_creative_inventory = 1, banner = 1, not_in_craft_guide = 1, material_wood=1, dig_by_piston=1, flammable=-1 },
	stack_max = 16,
	sounds = node_sounds,
	drop = "", -- Item drops are handled in entity code

	on_dig = on_dig_banner,
	on_destruct = on_destruct_standing_banner,
	on_punch = function(pos, node)
		respawn_banner_entity(pos, node)
	end,
	_mcl_hardness = 1,
	_mcl_blast_resistance = 1,
	on_rotate = function(pos, node, user, mode, param2)
		if mode == screwdriver.ROTATE_FACE then
			local meta = minetest.get_meta(pos)
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

-- Hanging banner node
minetest.register_node("mcl_banners:hanging_banner", {
	walkable = false,
	is_ground_content = false,
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	drawtype = "nodebox",
	inventory_image = "mcl_banners_item_base.png",
	wield_image = "mcl_banners_item_base.png",
	tiles = { "mcl_banners_fallback_wood.png" },
	node_box = {
		type = "wallmounted",
		wall_side = { -0.49, 0.41, -0.49, -0.41, 0.49, 0.49 },
		wall_top = { -0.49, 0.41, -0.49, -0.41, 0.49, 0.49 },
		wall_bottom = { -0.49, -0.49, -0.49, -0.41, -0.41, 0.49 },
	},
	selection_box = {type = "wallmounted", wall_side = {-0.5, -0.5, -0.5, -4/16, 0.5, 0.5} },
	groups = {axey=1,handy=1, attached_node = 1, not_in_creative_inventory = 1, banner = 1, not_in_craft_guide = 1, material_wood=1, flammable=-1 },
	stack_max = 16,
	sounds = node_sounds,
	drop = "", -- Item drops are handled in entity code

	on_dig = on_dig_banner,
	on_destruct = on_destruct_hanging_banner,
	on_punch = function(pos, node)
		respawn_banner_entity(pos, node)
	end,
	_mcl_hardness = 1,
	_mcl_blast_resistance = 1,
	on_rotate = function(pos, node, user, mode, param2)
		if mode == screwdriver.ROTATE_FACE then
			local r = screwdriver.rotate.wallmounted(pos, node, mode)
			node.param2 = r
			minetest.swap_node(pos, node)
			local meta = minetest.get_meta(pos)
			local rot = 0
			if node.param2 == 2 then
				rot = 12
			elseif node.param2 == 3 then
				rot = 4
			elseif node.param2 == 4 then
				rot = 0
			elseif node.param2 == 5 then
				rot = 8
			end
			meta:set_int("rotation_level", rot)
			respawn_banner_entity(pos, node, true)
			return true
		else
			return false
		end
	end,
})

-- for pattern_name, pattern in pairs(patterns) do
for colorid, colortab in pairs(mcl_banners.colors) do
    for i, pattern_name in ipairs(pattern_names) do
	local itemid = colortab[1]
	local desc = S("@1 Banner", mcl_dyes.colors[itemid].readable_name)
	local wool = colortab[3]
	local colorize = colortab[4]

	local itemstring
	if pattern_name == "" then
		itemstring = "mcl_banners:banner_item_" .. itemid
	else
		itemstring = "mcl_banners:banner_preview" .. "_" .. pattern_name .. "_" .. itemid
	end

	local inv
	local base
	local finished_banner
	if pattern_name == "" then
	    if colorize then
		-- Base texture with base color
		base = "mcl_banners_item_base.png^(mcl_banners_item_overlay.png^[colorize:"..colorize..")^[resize:32x32"
	    else
		base = "mcl_banners_item_base.png^mcl_banners_item_overlay.png^[resize:32x32"
	    end
	    finished_banner = base
	else
		-- Banner item preview background
		base = "mcl_banners_item_base.png^(mcl_banners_item_overlay.png^[colorize:#CCCCCC)^[resize:32x32"

		desc = S("Preview Banner")

		local pattern = "mcl_banners_" .. pattern_name .. ".png"
		local color = colorize

		-- Generate layer texture

		-- TODO: The layer texture in the icon is squished
		-- weirdly because the width/height aspect ratio of
		-- the banner icon is 1:1.5, whereas the aspect ratio
		-- of the banner entity is 1:2. A solution would be to
		-- redraw the pattern textures as low-resolution pixel
		-- art and use that instead.

		local layer = "(([combine:20x40:-2,-2="..pattern.."^[resize:16x24^[colorize:"..color..":"..layer_ratio.."))"

		function escape(text)
			 return text:gsub("%^", "\\%^"):gsub(":", "\\:") -- :gsub("%(", "\\%("):gsub("%)", "\\%)")
		end

		finished_banner = "[combine:32x32:0,0=" .. escape(base) .. ":8,4=" .. escape(layer)
	end

	inv = finished_banner

	-- Banner items.
	-- This is the player-visible banner item. It comes in 16 base colors with a lot of patterns.
	-- The multiple items are really only needed for the different item images.
	-- TODO: Combine the items into only 1 item.
	local groups
	if pattern_name == "" then
		groups = { banner = 1, deco_block = 1, flammable = -1 }
	else
		groups = { not_in_creative_inventory = 1 }
	end

	minetest.register_craftitem(itemstring, {
		description = desc,
		_tt_help = S("Paintable decoration"),
		_doc_items_create_entry = false,
		inventory_image = inv,
		wield_image = inv,
		-- Banner group groups together the banner items, but not the nodes.
		-- Used for crafting.
		groups = groups,
		stack_max = 16,

		on_place = function(itemstack, placer, pointed_thing)
			local above = pointed_thing.above
			local under = pointed_thing.under

			local node_under = minetest.get_node(under)
			if placer and not placer:get_player_control().sneak then
				local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
				if rc then return rc end

				if minetest.get_modpath("mcl_cauldrons") then
					-- Use banner on cauldron to remove the top-most layer. This reduces the water level by 1.
					local new_node
					if node_under.name == "mcl_cauldrons:cauldron_3" then
						new_node = "mcl_cauldrons:cauldron_2"
					elseif node_under.name == "mcl_cauldrons:cauldron_2" then
						new_node = "mcl_cauldrons:cauldron_1"
					elseif node_under.name == "mcl_cauldrons:cauldron_1" then
						new_node = "mcl_cauldrons:cauldron"
					elseif node_under.name == "mcl_cauldrons:cauldron_3r" then
						new_node = "mcl_cauldrons:cauldron_2r"
					elseif node_under.name == "mcl_cauldrons:cauldron_2r" then
						new_node = "mcl_cauldrons:cauldron_1r"
					elseif node_under.name == "mcl_cauldrons:cauldron_1r" then
						new_node = "mcl_cauldrons:cauldron"
					end
					if new_node then
						local imeta = itemstack:get_meta()
						local layers_raw = imeta:get_string("layers")
						local layers = minetest.deserialize(layers_raw)
						if type(layers) == "table" and #layers > 0 then
							table.remove(layers)
							imeta:set_string("layers", minetest.serialize(layers))
							local newdesc = mcl_banners.make_advanced_banner_description(itemstack:get_definition().description, layers)
							local mname = imeta:get_string("name")
							-- Don't change description if item has a name
							if mname == "" then
								imeta:set_string("description", newdesc)
							end
						end

						-- Washing off reduces the water level by 1.
						-- (It is possible to waste water if the banner had 0 layers.)
						minetest.swap_node(pointed_thing.under, {name=new_node})

						-- Play sound (from mcl_potions mod)
						minetest.sound_play("mcl_potions_bottle_pour", {pos=pointed_thing.under, gain=0.5, max_hear_range=16}, true)

						return itemstack
					end
				end
			end

			-- Update old pre 0.84.0 Ominous Banners with correct description.
			local stackmeta = itemstack:get_meta()
			if stackmeta:get_string("name"):find("Ominous Banner") then
				local oban_layers = minetest.deserialize(stackmeta:get_string("layers"))
				local banner_description = string.gsub(itemstack:get_definition().description, "White Banner", "Ominous Banner")
				local description = mcl_banners.make_advanced_banner_description(banner_description, oban_layers)
				stackmeta:set_string("description", description)
				stackmeta:set_string("name", "")
			end

			-- Place the node!
			local hanging = false

			-- Standing or hanging banner. The placement rules are enforced by the node definitions
			local _, success = minetest.item_place_node(ItemStack("mcl_banners:standing_banner"), placer, pointed_thing)
			if not success then
				-- Forbidden on ceiling
				if pointed_thing.under.y ~= pointed_thing.above.y then
					return itemstack
				end
				_, success = minetest.item_place_node(ItemStack("mcl_banners:hanging_banner"), placer, pointed_thing)
				if not success then
					return itemstack
				end
				hanging = true
			end
			local place_pos
			local def_under = minetest.registered_nodes[node_under.name]
			if def_under and def_under.buildable_to then
				place_pos = under
			else
				place_pos = above
			end
			local bnode = minetest.get_node(place_pos)
			if bnode.name ~= "mcl_banners:standing_banner" and bnode.name ~= "mcl_banners:hanging_banner" then
				minetest.log("error", "[mcl_banners] The placed banner node is not what the mod expected!")
				return itemstack
			end
			local meta = minetest.get_meta(place_pos)
			local inv = meta:get_inventory()
			inv:set_size("banner", 1)
			local store_stack = ItemStack(itemstack)
			store_stack:set_count(1)
			inv:set_stack("banner", 1, store_stack)

			-- Spawn entity
			local entity_place_pos
			if hanging then
				entity_place_pos = vector.add(place_pos, hanging_banner_entity_offset)
			else
				entity_place_pos = vector.add(place_pos, standing_banner_entity_offset)
			end
			local banner_entity = spawn_banner_entity(entity_place_pos, hanging, itemstack)
			-- Set rotation
			local final_yaw, rotation_level
			if hanging then
				local pdir = vector.direction(pointed_thing.under, pointed_thing.above)
				final_yaw = minetest.dir_to_yaw(pdir)
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

			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
			end
			minetest.sound_play({name="default_place_node_hard", gain=1.0}, {pos = place_pos}, true)

			return itemstack
		end,

		_mcl_generate_description = function(itemstack)
			local meta = itemstack:get_meta()
			local layers_raw = meta:get_string("layers")
			if not layers_raw then
				return nil
			end
			local layers = minetest.deserialize(layers_raw)
			local desc = itemstack:get_definition().description
			local newdesc = mcl_banners.make_advanced_banner_description(desc, layers)
			meta:set_string("description", newdesc)
			return newdesc
		end,
	})

	if mod_mcl_core and minetest.get_modpath("mcl_wool") and pattern_name == "" then
		minetest.register_craft({
			output = itemstring,
			recipe = {
				{ wool, wool, wool },
				{ wool, wool, wool },
				{ "", "mcl_core:stick", "" },
			}
		})
	end

	if mod_doc then
		-- Add item to node alias
		doc.add_entry_alias("nodes", "mcl_banners:standing_banner", "craftitems", itemstring)
	end
    end
end

if mod_doc then
	-- Add item to node alias
	doc.add_entry_alias("nodes", "mcl_banners:standing_banner", "nodes", "mcl_banners:hanging_banner")
end


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
		-- This is a table of tables with each table having the following fields:
			-- color: layer color ID (see colors table above)
			-- pattern: name of pattern (see list above)

	get_staticdata = function(self)
		local out = { _base_color = self._base_color, _layers = self._layers, _name = self._name }
		return minetest.serialize(out)
	end,
	on_activate = function(self, staticdata)
		if staticdata and staticdata ~= "" then
			local inp = minetest.deserialize(staticdata)
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
}
minetest.register_entity("mcl_banners:standing_banner", entity_standing)

local entity_hanging = table.copy(entity_standing)
entity_hanging.mesh = "amc_banner_hanging.b3d"
minetest.register_entity("mcl_banners:hanging_banner", entity_hanging)

-- FIXME: Prevent entity destruction by /clearobjects
minetest.register_lbm({
	label = "Respawn banner entities",
	name = "mcl_banners:respawn_entities",
	run_at_every_load = true,
	nodenames = {"mcl_banners:standing_banner", "mcl_banners:hanging_banner"},
	action = function(pos, node)
		respawn_banner_entity(pos, node)
	end,
})

minetest.register_craft({
	type = "fuel",
	recipe = "group:banner",
	burntime = 15,
})

