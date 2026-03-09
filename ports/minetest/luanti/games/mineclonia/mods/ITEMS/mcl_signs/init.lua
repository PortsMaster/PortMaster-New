mcl_signs = {}

local SIGN_WIDTH = 115

local LINE_LENGTH = 15
local NUMBER_OF_LINES = 4

local LINE_HEIGHT = 14
local CHAR_WIDTH = 5

local DEFAULT_COLOR = "#000000"

local SIGN_GLOW_INTENSITY = 14

local signs_editable = core.settings:get_bool("mcl_signs_editable", false)

local S = core.get_translator(core.get_current_modname())
local F = core.formspec_escape

local sign_tpl = {
	_mcl_hardness = 1,
	paramtype = "light",
	description = S("Sign"),
	_tt_help = S("Can be written"),
	_doc_items_longdesc = S("Signs can be written and come in two variants: Wall sign and sign on a sign post. Signs can be placed on the top and the sides of other blocks, but not below them."),
	_doc_items_usagehelp = S("After placing the sign, you can write something on it. You have 4 lines of text with up to 15 characters for each line; anything beyond these limits is lost. Not all characters are supported. The text can not be changed once it has been written; you have to break and place the sign again. Can be colored and made to glow."),
	sunlight_propagates = true,
	walkable = false,
	is_ground_content = false,
	paramtype2 = "degrotate",
	drawtype = "mesh",
	mesh = "mcl_signs_sign.obj",
	inventory_image = "default_sign_greyscale.png",
	wield_image = "default_sign_greyscale.png",
	selection_box = { type = "fixed", fixed = { -0.2, -0.5, -0.2, 0.2, 0.5, 0.2 } },
	tiles = { "mcl_signs_sign_greyscale.png" },
	groups = { axey = 1, handy = 2, sign = 1, not_in_creative_inventory = 1, unmovable_by_piston = 1, attached_node = 1 },
	drop = "mcl_signs:sign",
	stack_max = 16,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	node_placement_prediction = "",
	on_rotate = false,
	_mcl_sign_type = "standing"
}

--Signs data / meta
local function normalize_rotation(rot) return math.floor(0.5 + rot / 15) * 15 end

local function get_signdata(pos)
	local node = core.get_node(pos)
	local def = core.registered_nodes[node.name]
	if not def or core.get_item_group(node.name,"sign") < 1 then return end
	local meta = core.get_meta(pos)
	local text = meta:get_string("text")
	local color = meta:get_string("color")
	local glow = meta:get_string("glow")
	if glow == "true" then
		glow = true
	else
		glow = false
	end
	local yaw, spos
	local typ = "standing"
	if def.paramtype2  == "wallmounted" then
		typ = "wall"
		local dir = core.wallmounted_to_dir(node.param2)
		spos = vector.add(vector.offset(pos,0,-0.25,0),dir * 0.41 )
		yaw = core.dir_to_yaw(dir)
	elseif def.paramtype2 == "4dir" then
		typ = "hanging"
		local dir = core.fourdir_to_dir (node.param2)
		spos = vector.add (vector.offset (pos,0,-0.45,0), dir * -0.075)
		yaw = core.dir_to_yaw (dir)
	elseif def.groups.hanging_sign and def.groups.hanging_sign >= 1 then
		yaw = math.rad(((node.param2 * 1.5 ) + 1 ) % 360)
		local dir = core.yaw_to_dir(yaw)
		spos = vector.add(vector.offset(pos,0,-0.45,0),dir * -0.075)
	else
		yaw = math.rad(((node.param2 * 1.5 ) + 1 ) % 360)
		local dir = core.yaw_to_dir(yaw)
		spos = vector.add(vector.offset(pos,0,0.08,0),dir * -0.05)
	end
	if color == "" then color = DEFAULT_COLOR end
	return {
		text = text,
		color = color,
		yaw = yaw,
		node = node,
		typ = typ,
		glow = glow,
		text_pos = spos,
	}
end

local function set_signmeta(pos,def)
	local meta = core.get_meta(pos)
	if def.text then meta:set_string("text",def.text) end
	if def.color then meta:set_string("color",def.color) end
	if def.glow then meta:set_string("glow",def.glow) end
end

-- Text/texture
--[[ File format of characters.txt:
It's an UTF-8 encoded text file that contains metadata for all supported characters. It contains a sequence of info
	blocks, one for each character. Each info block is made out of 3 lines:
Line 1: The literal UTF-8 encoded character
Line 2: Name of the texture file for this character minus the “.png” suffix; found in the “textures/” sub-directory
Line 3: Currently ignored. Previously this was for the character width in pixels

After line 3, another info block may follow. This repeats until the end of the file.

All character files must be 5 or 6 pixels wide (5 pixels are preferred)
]]
local modpath = core.get_modpath(core.get_current_modname())
local chars_file = io.open(modpath .. "/characters.txt", "r")
-- FIXME: Support more characters (many characters are missing). Currently ASCII and Latin-1 Supplement are supported.
assert(chars_file,"[mcl_signs] characters.txt not found")
local charmap = {}
while true do
	local char = chars_file:read("*l")
	if char == nil then
		break
	end
	local img = chars_file:read("*l")
	local _ = chars_file:read("*l")
	charmap[char] = img
end

local function string_to_line_array(str)
	local linechar_table = {}
	local current = 1
	local linechar = 1
	local cr_last = false
	linechar_table[current] = ""
	for char in str:gmatch(".") do
		local add
		local is_cr, is_lf = char == "\r", char == "\n"

		if is_cr and not cr_last then
			cr_last = true
			add = false
		elseif is_lf or cr_last or linechar > 15 then
			cr_last = is_cr
			add = not (is_cr or is_lf)
			current = current + 1
			linechar_table[current] = ""
			linechar = 1
		else
			add = true
		end

		if add then
			linechar_table[current] = linechar_table[current] .. char
			linechar = linechar + 1
		end
	end
	return linechar_table
end


function mcl_signs.create_lines(text)
	local line_num = 1
	local text_table = {}
	for _, line in ipairs(string_to_line_array(text)) do
		if line_num > NUMBER_OF_LINES then
			break
		end
		table.insert(text_table, line)
		line_num = line_num + 1
	end
	return text_table
end

function mcl_signs.generate_line(s, ypos)
	local i = 1
	local parsed = {}
	local width = 0
	local chars = 0
	local printed_char_width = CHAR_WIDTH + 1
	while chars < LINE_LENGTH and i <= #s do
		local file
		-- Get and render character
		if charmap[s:sub(i, i)] then
			file = charmap[s:sub(i, i)]
			i = i + 1
		elseif i < #s and charmap[s:sub(i, i + 1)] then
			file = charmap[s:sub(i, i + 1)]
			i = i + 2
		else
			-- Use replacement character:
			file = "_rc"
			i = i + 1
		end
		if file then
			width = width + printed_char_width
			table.insert(parsed, file)
			chars = chars + 1
		end
	end
	width = width - 1
	local texture = ""
	local xpos = math.floor((SIGN_WIDTH - width) / 2)

	for j = 1, #parsed do
		texture = texture .. ":" .. xpos .. "," .. ypos .. "=" .. parsed[j] .. ".png"
		xpos = xpos + printed_char_width
	end
	return texture
end

function mcl_signs.generate_texture(data)
	local lines = mcl_signs.create_lines(data.text or "")
	local texture = "[combine:" .. SIGN_WIDTH .. "x" .. SIGN_WIDTH
	local ypos = 0
	local letter_color = data.color or DEFAULT_COLOR

	for i = 1, #lines do
		texture = texture .. mcl_signs.generate_line(lines[i], ypos)
		ypos = ypos + LINE_HEIGHT
	end

	texture = "(" .. texture .. "^[multiply:" .. letter_color .. ")"
	return texture
end

local function project_placer_dir (axis, placer_dir)
	local axis_1 = vector.normalize (vector.new (axis.z, 0, axis.x))
	local dot = vector.dot (axis_1, placer_dir)
	return vector.multiply (axis_1, dot ~= 0.0 and dot or 1.0)
end

local FULL_BLOCK = mcl_util.decompose_AABBs ({
	{
		-0.5, -0.5, -0.5,
		0.5, 0.5, 0.5,
	},
})

function sign_tpl.on_place(itemstack, placer, pointed_thing)
	local rc = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if rc then return rc end

	if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
		return itemstack
	end

	local under = pointed_thing.under
	local node = core.get_node(under)
	local ndef = core.registered_nodes[node.name]
	if not ndef then return itemstack end

	if mcl_util.call_on_rightclick(itemstack, placer, pointed_thing) then
		return itemstack
	end

	local above = pointed_thing.above
	local dir = {x = under.x - above.x, y = under.y - above.y, z = under.z - above.z}
	local wdir = core.dir_to_wallmounted(dir)

	local itemstring = itemstack:get_name()
	local placestack = ItemStack(itemstack)
	local def = itemstack:get_definition()

	local pos
	if core.get_item_group (itemstring, "hanging_sign") == 0 then
		-- place on wall
		if wdir ~= 0 and wdir ~= 1 then
			placestack:set_name("mcl_signs:wall_sign_"..def._mcl_sign_wood)
			itemstack, pos = core.item_place_node(placestack, placer, pointed_thing, wdir)
		elseif wdir == 1 then -- standing, not ceiling
			placestack:set_name("mcl_signs:standing_sign_"..def._mcl_sign_wood)
			local rot = normalize_rotation(placer:get_look_horizontal() * 180 / math.pi / 1.5)
			itemstack, pos = core.item_place_node(placestack, placer, pointed_thing,  rot) -- param2 value is degrees / 1.5
		else
			return itemstack
		end
	else
		-- Hanging sign.
		if wdir == 0 then
			if not ndef.walkable then
				return itemstack
			end

			local boxes = core.get_node_boxes ("collision_box", pointed_thing.under)
			local shape = mcl_util.decompose_AABBs (boxes)
			if not shape then
				return itemstack
			end
			local face = shape:select_face ("y", -0.5)
			if face:equal_p (FULL_BLOCK) then
				local dir = vector.subtract (above, placer:get_pos ())
				local fourdir = core.dir_to_fourdir (dir)
				placestack:set_name ("mcl_signs:hanging_sign_" .. def._mcl_sign_wood)
				itemstack, pos = core.item_place_node (placestack, placer, pointed_thing,
								       fourdir)
			else
				local rot = normalize_rotation(placer:get_look_horizontal() * 180 / math.pi / 1.5)
				placestack:set_name ("mcl_signs:hanging_sign_attached_" .. def._mcl_sign_wood)
				itemstack, pos = core.item_place_node (placestack, placer, pointed_thing, rot)
			end
		elseif wdir ~= 1 then
			local placer_dir = vector.subtract (above, placer:get_pos ())
			local dir = project_placer_dir (dir, vector.normalize (placer_dir))
			local fourdir = core.dir_to_fourdir (dir)
			placestack:set_name ("mcl_signs:hanging_sign_wall_" .. def._mcl_sign_wood)
			itemstack, pos = core.item_place_node (placestack, placer, pointed_thing,
							       fourdir)
		else
			return itemstack
		end
	end
	mcl_signs.show_formspec(placer, pos)
	itemstack:set_name(itemstring)
	return itemstack
end

function sign_tpl.on_rightclick(pos, _, clicker, itemstack, _)
	if itemstack:get_name() == "mcl_mobitems:glow_ink_sac" then
		local data = get_signdata(pos)
		if data then
			if data.color == "#000000" then
				data.color = "#7e7e7e" --black doesn't glow in the dark
			end
			set_signmeta(pos,{glow="true",color=data.color})
			mcl_signs.update_sign(pos)
			if not core.is_creative_enabled(clicker:get_player_name()) then
				itemstack:take_item()
			end
		end
	elseif signs_editable then
		if not mcl_util.check_position_protection(pos, clicker) then
			mcl_signs.show_formspec(clicker, pos)
		end
	end
	return itemstack
end

function sign_tpl.on_construct (pos)
	mcl_signs.update_sign (pos)
end

function sign_tpl.on_destruct(pos)
	mcl_signs.get_text_entity (pos, true)
end

function sign_tpl._on_dye_place(pos,color)
	set_signmeta(pos,{
		color = mcl_dyes.colors[color].rgb
	})
	mcl_signs.update_sign(pos)
end

local sign_wall = table.merge(sign_tpl,{
	mesh = "mcl_signs_signonwallmount.obj",
	paramtype2 = "wallmounted",
	selection_box = { type = "wallmounted", wall_side = { -0.5, -7 / 28, -0.5, -23 / 56, 7 / 28, 0.5 }},
	groups = { axey = 1, handy = 2, sign = 1, deco_block = 1, unmovable_by_piston = 1 },
	_mcl_sign_type = "wall",
})

local sign_hanging = table.merge(sign_tpl,{
	mesh = "mcl_signs_sign_hanging.obj",
	tiles = { "mcl_signs_sign_hanging.png" },
	paramtype2 = "4dir",
	use_texture_alpha = "clip",
	selection_box = {
		type = "fixed",
		fixed = {
			-0.4375,
			-0.5,
			-0.0625,
			0.4375,
			0.125,
			0.0625,
		},
	},
	groups = {
		axey = 1, handy = 2, sign = 1, hanging_sign = 1,
		attached_node = 4, deco_block = 1,
	},
	_mcl_sign_type = "hanging",
})

local sign_hanging_wall = table.merge(sign_tpl,{
	mesh = "mcl_signs_sign_hanging_wall.obj",
	tiles = { "mcl_signs_sign_hanging_wall.png" },
	paramtype2 = "4dir",
	use_texture_alpha = "clip",
	walkable = true,
	selection_box = {
		type = "fixed",
		fixed = {
			{
				-0.4375,
				-0.5,
				-0.0625,
				0.4375,
				0.125,
				0.0625,
			},
			{
				-0.5,
				0.375,
				-0.125,
				0.5,
				0.5,
				0.125,
			},
		},
	},
	collision_box = {
		type = "fixed",
		fixed = {
			{
				-0.5,
				0.375,
				-0.125,
				0.5,
				0.5,
				0.125,
			},
		},
	},
	groups = {
		axey = 1, handy = 2,
		sign = 1, hanging_sign = 1,
		not_in_creative_inventory = 1,
	},
	_mcl_sign_type = "hanging",
})

local sign_hanging_attached = table.merge (sign_tpl, {
	mesh = "mcl_signs_sign_hanging_attached.obj",
	tiles = { "mcl_signs_sign_hanging_wall.png" },
	paramtype2 = "degrotate",
	use_texture_alpha = "clip",
	selection_box = {
		type = "fixed",
		fixed = {
			{
				-0.4375,
				-0.5,
				-0.4375,
				0.4375,
				0.125,
				0.4375,
			},
		},
	},
	groups = {
		axey = 1, handy = 2, sign = 1, hanging_sign = 1,
		attached_node = 4, not_in_creative_inventory = 1,
	},
})

--Formspec
function mcl_signs.show_formspec(player, pos)
	if not pos then return end
	local old_text = core.get_meta(pos):get_string("text")
	core.show_formspec(player:get_player_name(),
		"mcl_signs:set_text_" .. pos.x .. "_" .. pos.y .. "_" .. pos.z,
		"size[6,3]textarea[0.25,0.25;6,1.5;text;" ..
		F(S("Enter sign text:")) .. ";"..core.formspec_escape(old_text) .."]label[0,1.5;" ..
		F(S("Maximum line length: 15")) .. "\n" ..
		F(S("Maximum lines: 4")) ..
		"]button_exit[0,2.5;6,1;submit;" .. F(S("Done")) .. "]"
	)
end

core.register_on_player_receive_fields(function(player, formname, fields)
	if formname:find("mcl_signs:set_text_") == 1 then
		local x, y, z = formname:match("mcl_signs:set_text_(.-)_(.-)_(.*)")
		local pos = { x = tonumber(x), y = tonumber(y), z = tonumber(z) }
		if not pos or not pos.x or not pos.y or not pos.z or not fields or not fields.text then
			return
		end
		if not mcl_util.check_position_protection(pos, player) and (signs_editable or core.get_meta(pos):get_string("text") == "") then
			set_signmeta(pos,{
				text = tostring(fields.text):sub(1, 256), --limit saved text to 256 characters (4 lines x 15 chars = 60 so this should be more than is ever needed).
			})
			mcl_signs.update_sign(pos)
		end
	end
end)

--Text entity handling
function mcl_signs.get_text_entity (pos, force_remove)
	local text_entity
	local i = 0
	for v in core.objects_inside_radius(pos, 0.5) do
		local ent = v:get_luaentity()
		if ent and ent.name == "mcl_signs:text" then
			i = i + 1
			if i > 1 or force_remove == true then
				v:remove()
			else
				text_entity = v
			end
		end
	end
	return text_entity
end

function mcl_signs.update_sign(pos)
	local data = get_signdata(pos)

	local text_entity = mcl_signs.get_text_entity(pos)
	if text_entity and not data then
		text_entity:remove()
		return false
	elseif not data then
		return false
	elseif not text_entity then
		text_entity = core.add_entity(data.text_pos, "mcl_signs:text")
		if not text_entity or not text_entity:get_pos() then return end
	end

	local glow
	if data.glow then
		glow = SIGN_GLOW_INTENSITY
	end
	text_entity:set_properties({
		textures = { mcl_signs.generate_texture(data) },
		glow = glow,
	})
	text_entity:set_yaw(data.yaw)
	text_entity:set_armor_groups({ immortal = 1 })
	return true
end

core.register_lbm({
	nodenames = {"group:sign"},
	name = "mcl_signs:restore_entities",
	label = "Restore sign text",
	run_at_every_load = true,
	action = function(pos)
		mcl_signs.update_sign(pos)
	end
})

core.register_entity("mcl_signs:text", {
	initial_properties = {
		pointable = false,
		visual = "upright_sprite",
		physical = false,
		collide_with_objects = false,
	},
	on_activate = function(self)
		local pos = self.object:get_pos()
		mcl_signs.update_sign(pos)
		local props = self.object:get_properties()
		local t = props and props.textures
		if type(t) ~= "table" or #t == 0 then self.object:remove() end
	end,
	_mcl_pistons_unmovable = true
})

local function colored_texture(texture,color)
	return texture.."^[multiply:"..color
end

mcl_signs.old_rotnames = {}

function mcl_signs.register_sign(name, color, def)
	local newfields = {
		tiles = { colored_texture("mcl_signs_sign_greyscale.png", color) },
		inventory_image = colored_texture("default_sign_greyscale.png", color),
		wield_image = colored_texture("default_sign_greyscale.png", color),
		drop = "mcl_signs:wall_sign_"..name,
		_mcl_sign_wood = name,
	}

	core.register_node(":mcl_signs:standing_sign_"..name, table.merge(sign_tpl, newfields, def or {}))
	core.register_node(":mcl_signs:wall_sign_"..name,table.merge(sign_wall, newfields, def or {}))
	table.insert(mcl_signs.old_rotnames,"mcl_signs:standing_sign22_5_"..name)
	table.insert(mcl_signs.old_rotnames,"mcl_signs:standing_sign45_"..name)
	table.insert(mcl_signs.old_rotnames,"mcl_signs:standing_sign67_5_"..name)
end

function mcl_signs.register_hanging_sign (name, def)
	local newfields = {
		inventory_image = "mcl_signs_hanging_sign_" .. name .. "_item.png",
		wield_image = "mcl_signs_hanging_sign_" .. name .. "_item.png",
		drop = "mcl_signs:hanging_sign_" .. name,
		_mcl_sign_wood = name,
	}
	core.register_node(":mcl_signs:hanging_sign_"..name,table.merge(sign_hanging, newfields, {
		tiles = {
			"mcl_signs_hanging_sign_" .. name .. ".png",
		},
	}, def or {}))
	core.register_node(":mcl_signs:hanging_sign_wall_"..name,table.merge(sign_hanging_wall, newfields, {
		tiles = {
			"mcl_signs_hanging_sign_" .. name .. ".png",
		},
	}, def or {}))
	core.register_node(":mcl_signs:hanging_sign_attached_"..name,table.merge(sign_hanging_attached, newfields, {
		tiles = {
			"mcl_signs_hanging_sign_" .. name .. ".png",
		},
	}, def or {}))
end
