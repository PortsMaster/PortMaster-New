mcl_signs = {}

local SIGN_WIDTH = 115

local LINE_LENGTH = 15
local NUMBER_OF_LINES = 4

local LINE_HEIGHT = 14
local CHAR_WIDTH = 5

local DEFAULT_COLOR = "#000000"

local SIGN_GLOW_INTENSITY = 14

local signs_editable = minetest.settings:get_bool("mcl_signs_editable", false)

local S = minetest.get_translator(minetest.get_current_modname())
local F = minetest.formspec_escape

local sign_tpl = {
	paramtype = "light",
	description = S("Sign"),
	_tt_help = S("Can be written"),
	_doc_items_longdesc = S("Signs can be written and come in two variants: Wall sign and sign on a sign post. Signs can be placed on the top and the sides of other blocks, but not below them."),
	_doc_items_usagehelp = S("After placing the sign, you can write something on it. You have 4 lines of text with up to 15 characters for each line; anything beyond these limits is lost. Not all characters are supported. The text can not be changed once it has been written; you have to break and place the sign again. Can be colored and made to glow."),
	use_texture_alpha = "opaque",
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
	groups = { axey = 1, handy = 2, sign = 1, not_in_creative_inventory = 1 },
	drop = "mcl_signs:sign",
	stack_max = 16,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	node_placement_prediction = "",
	_mcl_sign_type = "standing"
}

--Signs data / meta
local function normalize_rotation(rot) return math.floor(0.5 + rot / 15) * 15 end

local function get_signdata(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if not def or minetest.get_item_group(node.name,"sign") < 1 then return end
	local meta = minetest.get_meta(pos)
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
		local dir = minetest.wallmounted_to_dir(node.param2)
		spos = vector.add(vector.offset(pos,0,-0.25,0),dir * 0.41 )
		yaw = minetest.dir_to_yaw(dir)
	else
		yaw = math.rad(((node.param2 * 1.5 ) + 1 ) % 360)
		local dir = minetest.yaw_to_dir(yaw)
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
	local meta = minetest.get_meta(pos)
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
local modpath = minetest.get_modpath(minetest.get_current_modname())
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
	chars_file:read("*l")
	charmap[char] = img
end

local function string_to_line_array(str)
	local linechar_table = {}
	local current = 1
	local linechar = 1
	linechar_table[current] = ""
	for char in str:gmatch(".") do
		if char == "\n" then
			current = current + 1
			linechar_table[current] = ""
			linechar = 1
		else
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

function sign_tpl.on_place(itemstack, placer, pointed_thing)
	if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
		return itemstack
	end

	local under = pointed_thing.under
	local node = minetest.get_node(under)
	local def = minetest.registered_nodes[node.name]
	if not def then return itemstack end

	if mcl_util.call_on_rightclick(itemstack, placer, pointed_thing) then
		return itemstack
	end

	local above = pointed_thing.above
	local dir = {x = under.x - above.x, y = under.y - above.y, z = under.z - above.z}
	local wdir = minetest.dir_to_wallmounted(dir)

	local itemstring = itemstack:get_name()
	local placestack = ItemStack(itemstack)
	local def = itemstack:get_definition()

	local pos
	-- place on wall
	if wdir ~= 0 and wdir ~= 1 then
		placestack:set_name("mcl_signs:wall_sign_"..def._mcl_sign_wood)
		itemstack, pos = minetest.item_place(placestack, placer, pointed_thing, wdir)
	elseif wdir == 1 then -- standing, not ceiling
		placestack:set_name("mcl_signs:standing_sign_"..def._mcl_sign_wood)
		local rot = normalize_rotation(placer:get_look_horizontal() * 180 / math.pi / 1.5)
		itemstack, pos = minetest.item_place(placestack, placer, pointed_thing,  rot) -- param2 value is degrees / 1.5
	else
		return itemstack
	end
	mcl_signs.show_formspec(placer, pos)
	itemstack:set_name(itemstring)
	return itemstack
end

function sign_tpl.on_rightclick(pos, node, clicker, itemstack, pointed_thing)
	if itemstack:get_name() == "mcl_mobitems:glow_ink_sac" then
		local data = get_signdata(pos)
		if data.color == "#000000" then
			data.color = "#7e7e7e" --black doesn't glow in the dark
		end
		set_signmeta(pos,{glow="true",color=data.color})
		mcl_signs.update_sign(pos)
		if not minetest.is_creative_enabled(clicker:get_player_name()) then
			itemstack:take_item()
		end
	elseif signs_editable then
		mcl_signs.show_formspec(clicker, pos)
	end
	return itemstack
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
	groups = { axey = 1, handy = 2, sign = 1 },
	_mcl_sign_type = "wall",
})

--Formspec
function mcl_signs.show_formspec(player, pos)
	if not pos then return end
	local old_text = minetest.get_meta(pos):get_string("text")
	minetest.show_formspec(player:get_player_name(),
		"mcl_signs:set_text_" .. pos.x .. "_" .. pos.y .. "_" .. pos.z,
		"size[6,3]textarea[0.25,0.25;6,1.5;text;" ..
		F(S("Enter sign text:")) .. ";"..minetest.formspec_escape(old_text) .."]label[0,1.5;" ..
		F(S("Maximum line length: 15")) .. "\n" ..
		F(S("Maximum lines: 4")) ..
		"]button_exit[0,2.5;6,1;submit;" .. F(S("Done")) .. "]"
	)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname:find("mcl_signs:set_text_") == 1 then
		local x, y, z = formname:match("mcl_signs:set_text_(.-)_(.-)_(.*)")
		local pos = { x = tonumber(x), y = tonumber(y), z = tonumber(z) }
		if not pos or not pos.x or not pos.y or not pos.z then
			return
		end
		if signs_editable or minetest.get_meta(pos):get_string("text") == "" then
			set_signmeta(pos,{
				text = fields.text,
			})
			mcl_signs.update_sign(pos)
		end
	end
end)

--Text entity handling
function mcl_signs.get_text_entity (pos, force_remove)
	local objects = minetest.get_objects_inside_radius(pos, 0.5)
	local text_entity
	for _, v in pairs(objects) do
		local ent = v:get_luaentity()
		if ent and ent.name == "mcl_signs:text" then
			if force_remove ~= nil and force_remove == true then
				v:remove()
			else
				text_entity = v
				break
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
		text_entity = minetest.add_entity(data.text_pos, "mcl_signs:text")
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

minetest.register_lbm({
	nodenames = {"group:sign"},
	name = "mcl_signs:restore_entities",
	label = "Restore sign text",
	run_at_every_load = true,
	action = function(pos, node)
		mcl_signs.update_sign(pos)
	end
})

minetest.register_entity("mcl_signs:text", {
	initial_properties = {
		pointable = false,
		visual = "upright_sprite",
		textures = {},
		physical = false,
		collide_with_objects = false,
	},
	on_activate = function(self, staticdata)
		local pos = self.object:get_pos()
		mcl_signs.update_sign(pos)
	end,
})

local function colored_texture(texture,color)
	return texture.."^[multiply:"..color
end

mcl_signs.old_rotnames = {}

function mcl_signs.register_sign(name,color,def)
	local newfields = {
		tiles = { colored_texture("mcl_signs_sign_greyscale.png", color) },
		inventory_image = colored_texture("default_sign_greyscale.png", color),
		wield_image = colored_texture("default_sign_greyscale.png", color),
		drop = "mcl_signs:wall_sign_"..name,
		_mcl_sign_wood = name,
	}

	minetest.register_node(":mcl_signs:standing_sign_"..name, table.merge(sign_tpl, newfields, def or {}))
	minetest.register_node(":mcl_signs:wall_sign_"..name,table.merge(sign_wall, newfields, def or {}))

	table.insert(mcl_signs.old_rotnames,"mcl_signs:standing_sign22_5_"..name)
	table.insert(mcl_signs.old_rotnames,"mcl_signs:standing_sign45_"..name)
	table.insert(mcl_signs.old_rotnames,"mcl_signs:standing_sign67_5_"..name)
end
