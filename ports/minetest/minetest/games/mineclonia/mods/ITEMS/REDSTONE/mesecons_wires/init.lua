-- naming scheme: wire:(xp)(zp)(xm)(zm)(xpyp)(zpyp)(xmyp)(zmyp)_on/off
-- where x= x direction, z= z direction, y= y direction, p = +1, m = -1, e.g. xpym = {x=1, y=-1, z=0}
-- The (xp)/(zpyp)/.. statements shall be replaced by either 0 or 1
-- Where 0 means the wire has no visual connection to that direction and
-- 1 means that the wire visually connects to that other node.

local S = minetest.get_translator(minetest.get_current_modname())

-- #######################
-- ## Update wire looks ##
-- #######################

local wire_rules =
{{x=-1,  y= 0, z= 0, spread=true},
 {x= 1,  y= 0, z= 0, spread=true},
 {x= 0,  y=-1, z= 0, spread=true},
 {x= 0,  y= 1, z= 0, spread=true},
 {x= 0,  y= 0, z=-1, spread=true},
 {x= 0,  y= 0, z= 1, spread=true},

 {x= 1, y= 1, z= 0},
 {x= 1, y=-1, z= 0},
 {x=-1, y= 1, z= 0},
 {x=-1, y=-1, z= 0},
 {x= 0, y= 1, z= 1},
 {x= 0, y=-1, z= 1},
 {x= 0, y= 1, z=-1},
 {x= 0, y=-1, z=-1}}

-- self_pos = pos of any mesecon node, from_pos = pos of conductor to getconnect for
local function wire_getconnect(from_pos, self_pos)
	local node = minetest.get_node(self_pos)
	if minetest.registered_nodes[node.name]
	and minetest.registered_nodes[node.name].mesecons then
		-- rules of node to possibly connect to
		local rules
		if (minetest.registered_nodes[node.name].mesecon_wire) then
			rules = wire_rules
		else
			rules = mesecon.get_any_rules(node)
		end

		for _, r in ipairs(mesecon.flattenrules(rules)) do
			if (vector.equals(vector.add(self_pos, r), from_pos)) then
				return true
			end
		end
	end
	return false
end

-- Update this node
local function wire_updateconnect(pos)
	local connections = {}

	for _, r in ipairs(wire_rules) do
		if wire_getconnect(pos, vector.add(pos, r)) then
			table.insert(connections, r)
		end
	end

	local nid = {}
	for _, vec in ipairs(connections) do
		-- flat component
		if vec.x ==  1 then nid[0] = "1" end
		if vec.z ==  1 then nid[1] = "1" end
		if vec.x == -1 then nid[2] = "1" end
		if vec.z == -1 then nid[3] = "1"  end

		-- slopy component
		if vec.y == 1 then
			if vec.x ==  1 then nid[4] = "1" end
			if vec.z ==  1 then nid[5] = "1" end
			if vec.x == -1 then nid[6] = "1" end
			if vec.z == -1 then nid[7] = "1" end
		end
	end

	local nodeid = 	  (nid[0] or "0")..(nid[1] or "0")..(nid[2] or "0")..(nid[3] or "0")
			..(nid[4] or "0")..(nid[5] or "0")..(nid[6] or "0")..(nid[7] or "0")

	local state_suffix = string.find(minetest.get_node(pos).name, "_off") and "_off" or "_on"
	minetest.set_node(pos, {name = "mesecons:wire_"..nodeid..state_suffix})
end

local function update_on_place_dig(pos, node)
	-- Update placed node (get_node again as it may have been dug)
	local nn = minetest.get_node(pos)
	if (minetest.registered_nodes[nn.name])
	and (minetest.registered_nodes[nn.name].mesecon_wire) then
		wire_updateconnect(pos)
	end

	-- Update nodes around it
	local rules
	if minetest.registered_nodes[node.name]
	and minetest.registered_nodes[node.name].mesecon_wire then
		rules = wire_rules
	else
		rules = mesecon.get_any_rules(node)
	end
	if (not rules) then return end

	for _, r in ipairs(mesecon.flattenrules(rules)) do
		local np = vector.add(pos, r)
		if minetest.registered_nodes[minetest.get_node(np).name]
		and minetest.registered_nodes[minetest.get_node(np).name].mesecon_wire then
			wire_updateconnect(np)
		end
	end
end

mesecon.register_autoconnect_hook("wire", update_on_place_dig)

-- ############################
-- ## Wire node registration ##
-- ############################
-- Nodeboxes:
local box_center = {-1/16, -.5, -1/16, 1/16, -.5+1/64, 1/16}
local box_bump1 =  { -2/16, -8/16,  -2/16, 2/16, -.5+1/64, 2/16 }

local nbox_nid =
{
	[0] = {1/16, -.5, -1/16, 8/16, -.5+1/64, 1/16}, -- x positive
	[1] = {-1/16, -.5, 1/16, 1/16, -.5+1/64, 8/16}, -- z positive
	[2] = {-8/16, -.5, -1/16, -1/16, -.5+1/64, 1/16}, -- x negative
	[3] = {-1/16, -.5, -8/16, 1/16, -.5+1/64, -1/16}, -- z negative

	[4] = {.5-1/16, -.5+1/16, -1/16, .5, .4999+1/64, 1/16}, -- x positive up
	[5] = {-1/16, -.5+1/16, .5-1/16, 1/16, .4999+1/64, .5}, -- z positive up
	[6] = {-.5, -.5+1/16, -1/16, -.5+1/16, .4999+1/64, 1/16}, -- x negative up
	[7] = {-1/16, -.5+1/16, -.5, 1/16, .4999+1/64, -.5+1/16}  -- z negative up
}

local selectionbox =
{
	type = "fixed",
	fixed = {-.5, -.5, -.5, .5, -.5+1/16, .5}
}

-- go to the next nodeid (ex.: 01000011 --> 01000100)
local function nid_inc() end
function nid_inc(nid)
	local i = 0
	while nid[i-1] ~= 1 do
		nid[i] = (nid[i] ~= 1) and 1 or 0
		i = i + 1
	end

	-- BUT: Skip impossible nodeids:
	if ((nid[0] == 0 and nid[4] == 1) or (nid[1] == 0 and nid[5] == 1)
	or (nid[2] == 0 and nid[6] == 1) or (nid[3] == 0 and nid[7] == 1)) then
		return nid_inc(nid)
	end

	return i <= 8
end

local function register_wires()
	local nid = {}
	while true do
		-- Create group specifiction and nodeid string (see note above for details)
		local nodeid = 	  (nid[0] or "0")..(nid[1] or "0")..(nid[2] or "0")..(nid[3] or "0")
				..(nid[4] or "0")..(nid[5] or "0")..(nid[6] or "0")..(nid[7] or "0")

		-- Calculate nodebox
		local nodebox = {type = "fixed", fixed={box_center}}
		for i=0,7 do
			if nid[i] == 1 then
				table.insert(nodebox.fixed, nbox_nid[i])
			end
		end

		-- Add bump to nodebox if curved
		if (nid[0] == 1 and nid[1] == 1) or (nid[1] == 1 and nid[2] == 1)
		or (nid[2] == 1 and nid[3] == 1) or (nid[3] == 1 and nid[0] == 1) then
			table.insert(nodebox.fixed, box_bump1)
		end

		-- If nothing to connect to, still make a nodebox of a straight wire
		if nodeid == "00000000" then
			nodebox.fixed = {-8/16, -.5, -1/16, 8/16, -.5+1/16, 1/16}
		end

		local meseconspec_off = { conductor = {
			rules = wire_rules,
			state = mesecon.state.off,
			onstate = "mesecons:wire_"..nodeid.."_on"
		}}

		local meseconspec_on = { conductor = {
			rules = wire_rules,
			state = mesecon.state.on,
			offstate = "mesecons:wire_"..nodeid.."_off"
		}}

		local groups_on = {dig_immediate = 3, mesecon_conductor_craftable = 1,
			not_in_creative_inventory = 1, attached_node = 1, dig_by_water = 1,destroy_by_lava_flow=1, dig_by_piston = 1}
		local groups_off = {dig_immediate = 3, mesecon_conductor_craftable = 1,
			attached_node = 1, dig_by_water = 1,destroy_by_lava_flow=1, dig_by_piston = 1, craftitem = 1}
		if nodeid ~= "00000000" then
			groups_off["not_in_creative_inventory"] = 1
		end

		-- Wire textures
		local ratio_off = 128
		local ratio_on = 192
		local crossing_off = "(redstone_redstone_dust_dot.png^redstone_redstone_dust_line0.png^(redstone_redstone_dust_line1.png^[transformR90))^[colorize:#FF0000:"..ratio_off
		local crossing_on = "(redstone_redstone_dust_dot.png^redstone_redstone_dust_line0.png^(redstone_redstone_dust_line1.png^[transformR90))^[colorize:#FF0000:"..ratio_on
		local straight0_off = "redstone_redstone_dust_line0.png^[colorize:#FF0000:"..ratio_off
		local straight0_on = "redstone_redstone_dust_line0.png^[colorize:#FF0000:"..ratio_on
		local straight1_off = "redstone_redstone_dust_line0.png^[colorize:#FF0000:"..ratio_off
		local straight1_on = "redstone_redstone_dust_line0.png^[colorize:#FF0000:"..ratio_on
		local dot_off = "redstone_redstone_dust_dot.png^[colorize:#FF0000:"..ratio_off
		local dot_on = "redstone_redstone_dust_dot.png^[colorize:#FF0000:"..ratio_on

		local tiles_off, tiles_on

		local wirehelp, tt, longdesc, usagehelp, img, desc_off, desc_on
		if nodeid == "00000000" then
			-- Non-connected redstone wire
			nodebox.fixed = {-8/16, -.5, -8/16, 8/16, -.5+1/64, 8/16}
			-- “Dot” texture
			tiles_off = { dot_off, dot_off, "blank.png", "blank.png", "blank.png", "blank.png" }
			tiles_on = { dot_on, dot_on, "blank.png", "blank.png", "blank.png", "blank.png" }

			tt = S("Transmits redstone power, powers mechanisms")
			longdesc = S("Redstone is a versatile conductive mineral which transmits redstone power. It can be placed on the ground as a trail.").."\n"..
S("A redstone trail can be in two states: Powered or not powered. A powered redstone trail will power (and thus activate) adjacent redstone components.").."\n"..
S("Redstone power can be received from various redstone components, such as a block of redstone or a button. Redstone power is used to activate numerous mechanisms, such as redstone lamps or pistons.")
			usagehelp = S("Place redstone on the ground to build a redstone trail. The trails will connect to each other automatically and it can also go over hills.").."\n\n"..

S("Read the help entries on the other redstone components to learn how redstone components interact.")
			img = "redstone_redstone_dust.png"
			desc_off = S("Redstone")
			desc_on = S("Powered Redstone Spot (@1)", nodeid)
		else
			-- Connected redstone wire
			tiles_off = { crossing_off, crossing_off, straight0_off, straight1_off, straight0_off, straight1_off }
			tiles_on = { crossing_on, crossing_on, straight0_on, straight1_on, straight0_on, straight1_on }
			wirehelp = false
			desc_off = S("Redstone Trail (@1)", nodeid)
			desc_on = S("Powered Redstone Trail (@1)", nodeid)
		end

		mesecon.register_node(":mesecons:wire_"..nodeid, {
			drawtype = "nodebox",
			paramtype = "light",
			use_texture_alpha = minetest.features.use_texture_alpha_string_modes and "clip" or true,
			sunlight_propagates = true,
			selection_box = selectionbox,
			node_box = nodebox,
			walkable = false,
			drop = "mesecons:wire_00000000_off",
			sounds = mcl_sounds.node_sound_defaults(),
			is_ground_content = false,
			mesecon_wire = true
		},{
			description = desc_off,
			inventory_image = img,
			wield_image = img,
			_tt_help = tt,
			_doc_items_create_entry = wirehelp,
			_doc_items_longdesc = longdesc,
			_doc_items_usagehelp = usagehelp,
			tiles = tiles_off,
			mesecons = meseconspec_off,
			groups = groups_off,
		},{
			description = desc_on,
			_doc_items_create_entry = false,
			tiles = tiles_on,
			mesecons = meseconspec_on,
			groups = groups_on
		})

		-- Add Help entry aliases for e.g. making it identifiable by the lookup tool [doc_identifier]
		if minetest.get_modpath("doc") then
			if nodeid ~= "00000000" then
				doc.add_entry_alias("nodes", "mesecons:wire_00000000_off", "nodes", "mesecons:wire_"..nodeid.."_off")
			end
			doc.add_entry_alias("nodes", "mesecons:wire_00000000_off", "nodes", "mesecons:wire_"..nodeid.."_on")
		end

		if (nid_inc(nid) == false) then return end
	end
end
register_wires()

minetest.register_alias("mesecons:redstone", "mesecons:wire_00000000_off")

minetest.register_craft({
	type = "cooking",
	output = "mesecons:redstone",
	recipe = "mcl_core:stone_with_redstone",
	cooktime = 10,
})

