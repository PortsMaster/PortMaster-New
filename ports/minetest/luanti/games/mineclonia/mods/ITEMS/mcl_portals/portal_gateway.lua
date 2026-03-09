local S = core.get_translator(core.get_current_modname())
local storage = mcl_portals.storage
local portal_y = mcl_vars.mg_end_min + 75

local gateway_positions = {
	{x = 96, y = portal_y, z = 0},
	{x = 91, y = portal_y, z = 29},
	{x = 77, y = portal_y, z = 56},
	{x = 56, y = portal_y, z = 77},
	{x = 29, y = portal_y, z = 91},
	{x = 0, y = portal_y, z = 96},
	{x = -29, y = portal_y, z = 91},
	{x = -56, y = portal_y, z = 77},
	{x = -77, y = portal_y, z = 56},
	{x = -91, y = portal_y, z = 29},
	{x = -96, y = portal_y, z = 0},
	{x = -91, y = portal_y, z = -29},
	{x = -77, y = portal_y, z = -56},
	{x = -56, y = portal_y, z = -77},
	{x = -29, y = portal_y, z = -91},
	{x = 0, y = portal_y, z = -96},
	{x = 29, y = portal_y, z = -91},
	{x = 56, y = portal_y, z = -77},
	{x = 77, y = portal_y, z = -56},
	{x = 91, y = portal_y, z = -29},
}

local path_gateway_portal = core.get_modpath("mcl_structures").."/schematics/mcl_structures_end_gateway_portal.mts"

local function spawn_gateway_portal(pos, dest_str)
	return mcl_structures.place_schematic(vector.add(pos, vector.new(-1, -2, -1)), path_gateway_portal, "0", nil, true, nil, dest_str and function()
		core.get_meta(pos):set_string("mcl_portals:gateway_destination", dest_str)
	end)
end

function mcl_portals.spawn_gateway_portal()
	local id = storage:get_int("gateway_last_id") + 1
	local pos = gateway_positions[id]
	if not pos then return end
	storage:set_int("gateway_last_id", id)
	spawn_gateway_portal(pos)
end

local gateway_def = table.copy(core.registered_nodes["mcl_portals:portal_end"])
gateway_def.description = S("End Gateway Portal")
gateway_def._tt_help = S("Used to construct end gateway portals")
gateway_def._doc_items_longdesc = S("An End gateway portal teleports creatures and objects to the outer End (and back!).")
gateway_def._doc_items_usagehelp = S("Throw an ender pearl into the portal to teleport. Entering an Gateway portal near the Overworld teleports you to the outer End. At this destination another gateway portal will be constructed, which you can use to get back.")
gateway_def.after_destruct = nil
gateway_def.drawtype = "normal"
gateway_def.node_box = nil
gateway_def.walkable = true
gateway_def.tiles[3] = nil
core.register_node("mcl_portals:portal_gateway", gateway_def)

local function find_destination_pos(minp, maxp)
	for y = maxp.y, minp.y, -1 do
		for x = maxp.x, minp.x, -1 do
			for z = maxp.z, minp.z, -1 do
				local pos = vector.new(x, y, z)
				local nn = core.get_node(pos).name
				if nn ~= "ignore" and nn ~= "mcl_portals:portal_gateway" and nn ~= "mcl_core:bedrock" then
					local def = core.registered_nodes[nn]
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
	local meta = core.get_meta(pos)
	local dest_portal
	local dest_str = meta:get_string("mcl_portals:gateway_destination")
	local pos_str = core.pos_to_string(pos)
	local levelgen_enabled = mcl_levelgen.levelgen_enabled
	if dest_str == "" then
		dest_portal = vector.multiply(vector.direction(vector.new(0, pos.y, 0), pos), math.random(1024, 1167))
		dest_portal.y = mcl_vars.mg_end_min + 75
		if not levelgen_enabled then
			spawn_gateway_portal(dest_portal, pos_str)
		end
		meta:set_string("mcl_portals:gateway_destination", core.pos_to_string(dest_portal))
	else
		dest_portal = core.string_to_pos(dest_str)
	end

	if not levelgen_enabled then
		local minp = vector.subtract(dest_portal, vector.new(5, 40, 5))
		local maxp = vector.add(dest_portal, vector.new(5, 10, 5))
		preparing[pos_str] = true
		core.emerge_area(minp, maxp, function(_, _, calls_remaining)
			if calls_remaining < 1 then
				if obj and obj:is_player() or obj:get_luaentity() then
					obj:set_pos(find_destination_pos(minp, maxp) or vector.add(dest_portal, vector.new(0, 3.5, 0)))
				end
				preparing[pos_str] = false
			end
		end)
	elseif not obj:get_attach () then
		local minp = vector.subtract (dest_portal, vector.new (64, 64, 64))
		local maxp = vector.add (dest_portal, vector.new(64, 64, 64))
		local minp_search = vector.subtract(dest_portal, vector.new(5, 40, 5))
		local maxp_search = vector.add(dest_portal, vector.new(5, 10, 5))
		mcl_biome_dispatch.teleport_with_emerge (obj, minp, maxp, nil, function (_, _)
			spawn_gateway_portal (dest_portal, pos_str)
			-- If obj is attached, this call will produce no effect.
			obj:set_pos(find_destination_pos(minp_search, maxp_search)
				    or vector.add(dest_portal, vector.new(0, 3.5, 0)))
		end)
	end
end

core.register_abm({
	label = "End gateway portal teleportation",
	nodenames = {"mcl_portals:portal_gateway"},
	interval = 0.1,
	chance = 1,
	action = function(pos)
		if preparing[core.pos_to_string(pos)] then return end
		for obj in core.objects_inside_radius(pos, 1) do
			if mcl_portals.object_teleport_allowed (obj) then
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

function mcl_portals.gateway_teleport (pos, player)
	if mcl_portals.object_teleport_allowed (player) then
		teleport (pos, player)
		return true
	end
	return false
end

