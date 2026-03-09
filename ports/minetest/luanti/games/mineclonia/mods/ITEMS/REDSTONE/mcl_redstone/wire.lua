local S = core.get_translator(core.get_current_modname())

local nodebox_wire = {
	{-1/16, -.5, -8/16, 1/16, -.5+1/64, -1/16}, -- z negative
	{-8/16, -.5, -1/16, -1/16, -.5+1/64, 1/16}, -- x negative
	{-1/16, -.5, 1/16, 1/16, -.5+1/64, 8/16}, -- z positive
	{1/16, -.5, -1/16, 8/16, -.5+1/64, 1/16}, -- x positive
}

local connected_nodebox_wire =
{
	{name = "connect_front", nodebox = {-1/16, -.5+1/16, -.5, 1/16, .4999+1/64, -.5+1/16}}, -- z negative up
	{name = "connect_left", nodebox = {-.5, -.5+1/16, -1/16, -.5+1/16, .4999+1/64, 1/16}}, -- x negative up
	{name = "connect_back", nodebox = {-1/16, -.5+1/16, .5-1/16, 1/16, .4999+1/64, .5}}, -- z positive up
	{name = "connect_right", nodebox = {.5-1/16, -.5+1/16, -1/16, .5, .4999+1/64, 1/16}}, -- x positive up
}
local box_center = {-1/16, -.5, -1/16, 1/16, -.5+1/64, 1/16}
local box_bump =  { -2/16, -8/16,  -2/16, 2/16, -.5+1/64, 2/16 }

local selectionbox = {
	type = "fixed",
	fixed = {-.5, -.5, -.5, .5, -.5+1/16, .5}
}

local cross_tile = "redstone_redstone_dust_dot.png^redstone_redstone_dust_line0.png^(redstone_redstone_dust_line1.png^[transformR90)"
local line_tile = "redstone_redstone_dust_line0.png"
local dot_tile = "redstone_redstone_dust_dot.png"

local opaque_tab = mcl_redstone._solid_opaque_tab
local wireflag_tab = mcl_redstone._wireflag_tab

-- Make wires which only extend in one direction also extend in the opposite
-- direction.
local function make_long(wireflags)
	local conv_tab = {
		[0x1] = 0x5,
		[0x4] = 0x5,
		[0x2] = 0xa,
		[0x8] = 0xa,
	}
	for k, v in pairs(conv_tab) do
		if bit.band(wireflags, 0xf) == k then
			return bit.bor(wireflags, v)
		end
	end
	return wireflags
end

--- Wireflags are illegal if they have the `is going upwards` flag set for a
-- direction they arent pointing to. This function removes those extra flags (if
-- there are any).
local function make_legal(wireflags)
	wireflags = make_long(wireflags)

	local y0 = bit.band(wireflags, 0xf)
	local y1 = bit.band(y0, bit.rshift(wireflags, 4))
	return bit.bor(bit.lshift(y1, 4), y0)
end

local function wireflags_to_name(wireflags)
	return wireflags == 0 and
		"mcl_redstone:redstone" or
		"mcl_redstone:wire_"..(bit.tohex(wireflags, 2))
end

-- Update connections for wire at position.
local function update_wire(pos)
	local update_tab = {
		{ wire = vector.new(0, -1, -1), obstruct = vector.new(0, 0, -1), mask = 0x1 },
		{ wire = vector.new(-1, -1, 0), obstruct = vector.new(-1, 0, 0), mask = 0x2 },
		{ wire = vector.new(0, -1, 1), obstruct = vector.new(0, 0, 1), mask = 0x4 },
		{ wire = vector.new(1, -1, 0), obstruct = vector.new(1, 0, 0), mask = 0x8 },
		{ wire = vector.new(0, 0, -1), mask = 0x1 },
		{ wire = vector.new(-1, 0, 0), mask = 0x2 },
		{ wire = vector.new(0, 0, 1), mask = 0x4 },
		{ wire = vector.new(1, 0, 0), mask = 0x8 },
		{ wire = vector.new(0, 1, -1), obstruct = vector.new(0, 1, 0), mask = 0x11 },
		{ wire = vector.new(-1, 1, 0), obstruct = vector.new(0, 1, 0), mask = 0x22 },
		{ wire = vector.new(0, 1, 1), obstruct = vector.new(0, 1, 0), mask = 0x44 },
		{ wire = vector.new(1, 1, 0), obstruct = vector.new(0, 1, 0), mask = 0x88 },
	}
	local fourdir_tab = {
		{ dir = vector.new(0, 0, -1), mask = 0x1 },
		{ dir = vector.new(-1, 0, 0), mask = 0x2 },
		{ dir = vector.new(0, 0, 1), mask = 0x4 },
		{ dir = vector.new(1, 0, 0), mask = 0x8 },
	}

	local node = core.get_node(pos)
	local present = wireflag_tab[node.name] ~= nil
	local wireflags = 0

	for _, entry in pairs(update_tab) do
		local wire = entry.wire
		local obstruct = (wire.y < 0 and wire:multiply(vector.new(1, 0, 1))) or
			(wire.y > 0 and wire:multiply(vector.new(0, 1, 0))) or
			nil
		if not obstruct or not opaque_tab[core.get_node(pos:add(obstruct)).name] then
			local pos2 = pos:add(wire)
			local node2 = core.get_node(pos2)

			if wireflag_tab[node2.name] then
				wireflags = bit.bor(wireflags, entry.mask)
			end
		end
	end
	for _, entry in pairs(fourdir_tab) do
		local pos2 = pos:add(entry.dir)
		local node2 = core.get_node(pos2)
		local ndef2 = core.registered_nodes[node2.name]
		if ndef2 then
			local redstone = ndef2._mcl_redstone
			local connects_to = redstone and redstone.connects_to

			if connects_to and connects_to(node2, -entry.dir) then
				wireflags = bit.bor(wireflags, entry.mask)
			end
		end
	end

	if present then
		core.swap_node(pos, {
			name = wireflags_to_name(make_legal(wireflags)),
			param2 = node.param2,
		})
	end
end

function mcl_redstone._update_opaque_connections(pos)
	local dirs = {
		vector.new(0, -1, 0),
		vector.new(1, 0, 0),
		vector.new(-1, 0, 0),
		vector.new(0, 0, 1),
		vector.new(0, 0, -1),
	}
	for _, dir in pairs(dirs) do
		local pos2 = pos:add(dir)
		if wireflag_tab[core.get_node(pos2).name] then
			update_wire(pos2)
		end
	end
end

local function update_wire_connections(pos)
	local dirs = {
		vector.new(0, 0, 0),
		vector.new(1, 0, 0),
		vector.new(-1, 0, 0),
		vector.new(0, 0, 1),
		vector.new(0, 0, -1),
		vector.new(1, -1, 0),
		vector.new(-1, -1, 0),
		vector.new(0, -1, 1),
		vector.new(0, -1, -1),
		vector.new(1, 1, 0),
		vector.new(-1, 1, 0),
		vector.new(0, 1, 1),
		vector.new(0, 1, -1),
	}
	for _, dir in pairs(dirs) do
		local pos2 = pos:add(dir)
		if wireflag_tab[core.get_node(pos2).name] then
			update_wire(pos2)
		end
	end
end

do
	local wires = {}
	for y0 = 0, 15 do
		for y1 = 0, 15 do
			local wire = bit.bor(bit.lshift(y1, 4), y0)
			if wire == make_legal(make_long(wire)) then
				table.insert(wires, wire)
			end
		end
	end

	for _, wire in pairs(wires) do
		local wireid = bit.tohex(wire, 2)

		local tt
		local longdesc
		local usagehelp
		local nodebox
		local tiles
		if wire == 0 then
			tt = S("Transmits redstone power, powers mechanisms")
			longdesc = S("Redstone is a versatile conductive mineral which transmits redstone power. It can be placed on the ground as a trail.").."\n"..
				S("A redstone trail can be in two states: Powered or not powered. A powered redstone trail will power (and thus activate) adjacent redstone components.").."\n"..
				S("Redstone power can be received from various redstone components, such as a block of redstone or a button. Redstone power is used to activate numerous mechanisms, such as redstone lamps or pistons.")
			usagehelp = S("Place redstone on the ground to build a redstone trail. The trails will connect to each other automatically and it can also go over hills.").."\n\n"..
				S("Read the help entries on the other redstone components to learn how redstone components interact.")
			tiles = {dot_tile, dot_tile, "blank.png", "blank.png", "blank.png", "blank.png"}
			nodebox = {type = "fixed", fixed={-8/16, -.5, -8/16, 8/16, -.5+1/64, 8/16}}
		else
			tiles = { cross_tile, cross_tile, line_tile, line_tile, line_tile, line_tile }
			nodebox = {type = "connected", fixed={box_center}}

			-- Calculate nodebox
			for i = 0, 3 do
				if bit.band(wire, bit.lshift(1, i)) ~= 0 then
					table.insert(nodebox.fixed, nodebox_wire[i + 1])
				end
			end

			-- Calculate the nodeboxe's connections
			for i = 4, 7 do
				if bit.band(wire, bit.lshift(1, i)) ~= 0 then
					nodebox[connected_nodebox_wire[i - 3].name] = connected_nodebox_wire[i - 3].nodebox
				end
			end

			-- Add bump to nodebox if the wireflags has any bits set for X and any bits set for Z
			if bit.band(wire, 0xA) ~= 0 and bit.band(wire, 0x5) ~= 0 then
				table.insert(nodebox.fixed, box_bump)
			end

			doc.add_entry_alias("nodes", "mcl_redstone:redstone", "nodes", "mcl_redstone:wire_"..wireid)
		end

		-- Toggle between cross and dot using rightclick
		local on_rightclick
		if wire == 0 then
			on_rightclick = function(pos)
				core.swap_node(pos, {
					name = "mcl_redstone:wire_0f",
					param2 = core.get_node(pos).param2,
				})
			end
		elseif bit.band(wire, 0xf) == 0xf then
			on_rightclick = function(pos)
				core.swap_node(pos, {
					name = "mcl_redstone:redstone",
					param2 = core.get_node(pos).param2,
				})
				update_wire_connections(pos)
			end
		end

		local name = wireflags_to_name(wire)
		core.register_node(name, {
			drawtype = "nodebox",
			connects_to = {"group:solid"},
			paramtype = "light",
			paramtype2 = "color",
			palette = "mcl_redstone_palette_power.png",
			use_texture_alpha = "clip",
			sunlight_propagates = true,
			selection_box = selectionbox,
			node_box = nodebox,
			tiles = tiles,
			walkable = false,
			drop = "mcl_redstone:redstone",
			sounds = mcl_sounds.node_sound_defaults(),
			is_ground_content = false,
			groups = {redstone_wire = 1, dig_immediate = 3, attached_node = 1, dig_by_water = 1, destroy_by_lava_flow=1, dig_by_piston = 1, unsticky = 1, craftitem = 1, not_in_creative_inventory = wire ~= 0 and 1 or 0},
			description = S("Redstone Dust"),
			_tt_help = tt,
			_doc_items_create_entry = longdesc and true or false,
			_doc_items_longdesc = longdesc,
			_doc_items_usagehelp = usagehelp,
			wield_image = wire == 0 and "redstone_redstone_dust.png" or nil,
			inventory_image = wire == 0 and "redstone_redstone_dust.png" or nil,
			on_construct = function(pos)
				update_wire_connections(pos)
			end,
			after_destruct = function(pos, oldnode)
				update_wire_connections(pos)
			end,
			on_rightclick = on_rightclick,
			_mcl_armor_trim_color = wire == 0 and "#e80202" or nil,
			_mcl_armor_trim_desc = wire == 0 and S("Redstone Material") or nil
		})
		wireflag_tab[name] = wire
	end
end

local fourdirs = {
	vector.new(1, 0, 0),
	vector.new(-1, 0, 0),
	vector.new(0, 0, 1),
	vector.new(0, 0, -1),
}

function mcl_redstone._connect_with_wires(pos)
	for _, dir in pairs(fourdirs) do
		local pos2 = pos:add(dir)
		local node = core.get_node(pos2)
		if core.get_item_group(node.name, "redstone_wire") ~= 0 then
			update_wire(pos2)
		end
	end
end
