local S = minetest.get_translator(minetest.get_current_modname())
local storage = mcl_portals.storage

local gateway_positions = {
	{x = 96, y = -26925, z = 0},
	{x = 91, y = -26925, z = 29},
	{x = 77, y = -26925, z = 56},
	{x = 56, y = -26925, z = 77},
	{x = 29, y = -26925, z = 91},
	{x = 0, y = -26925, z = 96},
	{x = -29, y = -26925, z = 91},
	{x = -56, y = -26925, z = 77},
	{x = -77, y = -26925, z = 56},
	{x = -91, y = -26925, z = 29},
	{x = -96, y = -26925, z = 0},
	{x = -91, y = -26925, z = -29},
	{x = -77, y = -26925, z = -56},
	{x = -56, y = -26925, z = -77},
	{x = -29, y = -26925, z = -91},
	{x = 0, y = -26925, z = -96},
	{x = 29, y = -26925, z = -91},
	{x = 56, y = -26925, z = -77},
	{x = 77, y = -26925, z = -56},
	{x = 91, y = -26925, z = -29},
}

local path_gateway_portal = minetest.get_modpath("mcl_structures").."/schematics/mcl_structures_end_gateway_portal.mts"

local function spawn_gateway_portal(pos, dest_str)
	return mcl_structures.place_schematic(vector.add(pos, vector.new(-1, -2, -1)), path_gateway_portal, "0", nil, true, nil, dest_str and function()
		minetest.get_meta(pos):set_string("mcl_portals:gateway_destination", dest_str)
	end)
end

function mcl_portals.spawn_gateway_portal()
	local id = storage:get_int("gateway_last_id") + 1
	local pos = gateway_positions[id]
	if not pos then return end
	storage:set_int("gateway_last_id", id)
	spawn_gateway_portal(pos)
end

local gateway_def = table.copy(minetest.registered_nodes["mcl_portals:portal_end"])
gateway_def.description = S("End Gateway Portal")
gateway_def._tt_help = S("Used to construct end gateway portals")
gateway_def._doc_items_longdesc = S("An End gateway portal teleports creatures and objects to the outer End (and back!).")
gateway_def._doc_items_usagehelp = S("Throw an ender pearl into the portal to teleport. Entering an Gateway portal near the Overworld teleports you to the outer End. At this destination another gateway portal will be constructed, which you can use to get back.")
gateway_def.after_destruct = nil
gateway_def.drawtype = "normal"
gateway_def.node_box = nil
gateway_def.walkable = true
gateway_def.tiles[3] = nil
minetest.register_node("mcl_portals:portal_gateway", gateway_def)

local function find_destination_pos(minp, maxp)
	for y = maxp.y, minp.y, -1 do
		for x = maxp.x, minp.x, -1 do
			for z = maxp.z, minp.z, -1 do
				local pos = vector.new(x, y, z)
				local nn = minetest.get_node(pos).name
				if nn ~= "ignore" and nn ~= "mcl_portals:portal_gateway" and nn ~= "mcl_core:bedrock" then
					local def = minetest.registered_nodes[nn]
					if def and def.walkable then
						return vector.add(pos, vector.new(0, 1.5, 0))
					end
				end
			end
		end
	end
end

local preparing = {}

local function teleport(pos, obj)
	local meta = minetest.get_meta(pos)
	local dest_portal
	local dest_str = meta:get_string("mcl_portals:gateway_destination")
	local pos_str = minetest.pos_to_string(pos)
	if dest_str == "" then
		dest_portal = vector.multiply(vector.direction(vector.new(0, pos.y, 0), pos), math.random(768, 1024))
		dest_portal.y = -26970
		spawn_gateway_portal(dest_portal, pos_str)
		meta:set_string("mcl_portals:gateway_destination", minetest.pos_to_string(dest_portal))
	else
		dest_portal = minetest.string_to_pos(dest_str)
	end
	local minp = vector.subtract(dest_portal, vector.new(5, 40, 5))
	local maxp = vector.add(dest_portal, vector.new(5, 10, 5))
	preparing[pos_str] = true
	minetest.emerge_area(minp, maxp, function(blockpos, action, calls_remaining, param)
		if calls_remaining < 1 then
			if obj and obj:is_player() or obj:get_luaentity() then
				obj:set_pos(find_destination_pos(minp, maxp) or vector.add(dest_portal, vector.new(0, 3.5, 0)))
			end
			preparing[pos_str] = false
		end
	end)
end

minetest.register_abm({
	label = "End gateway portal teleportation",
	nodenames = {"mcl_portals:portal_gateway"},
	interval = 0.1,
	chance = 1,
	action = function(pos)
		if preparing[minetest.pos_to_string(pos)] then return end
		for _, obj in pairs(minetest.get_objects_inside_radius(pos, 1)) do
			if obj:get_hp() > 0 then
				local luaentity = obj:get_luaentity()
				if luaentity and luaentity.name == "mcl_throwing:ender_pearl" then
					obj:remove()
					obj = luaentity._thrower
				end
				teleport(pos, obj)
				return
			end
		end
	end,
})
