local S = core.get_translator(core.get_current_modname())

-- Template rail function
local function register_rail(itemstring, tiles, def_extras, creative)
	local groups = {handy=1,pickaxey=1, attached_node=1,rail=1,connect_to_raillike=core.raillike_group("rail"),transport=1, no_spawning_inside=1}
	if creative == false then
		groups.not_in_creative_inventory = 1
	end
	local ndef = {
		drawtype = "raillike",
		tiles = tiles,
		is_ground_content = false,
		inventory_image = tiles[1],
		wield_image = tiles[1],
		paramtype = "light",
		walkable = false,
		selection_box = {
			type = "fixed",
			fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
		},
		groups = groups,
		sounds = mcl_sounds.node_sound_metal_defaults(),
		_mcl_hardness = 0.7,
		after_destruct = function(pos)
			-- Scan for minecarts in this pos and force them to execute their "floating" check.
			-- Normally, this will make them drop.
			for obj in core.objects_inside_radius(pos, 1) do
				local le = obj:get_luaentity()
				if le then
					-- All entities in this mod are minecarts, so this works
					if string.sub(le.name, 1, 14) == "mcl_minecarts:" then
						le._last_float_check = mcl_minecarts.check_float_time
					end
				end
			end
		end,
	}
	if def_extras then
		for k,v in pairs(def_extras) do
			ndef[k] = v
		end
	end
	core.register_node(itemstring, ndef)
end

local railuse = S("Place them on the ground to build your railway, the rails will automatically connect to each other and will turn into curves, T-junctions, crossings and slopes as needed.")

-- Normal rail
register_rail("mcl_minecarts:rail",
	{"default_rail.png", "default_rail_curved.png", "default_rail_t_junction.png", "default_rail_crossing.png"},
	{
		description = S("Rail"),
		_tt_help = S("Track for minecarts"),
		_doc_items_longdesc = S("Rails can be used to build transport tracks for minecarts. Normal rails slightly slow down minecarts due to friction."),
		_doc_items_usagehelp = railuse,
	}
)

local golden_rail_tab = {}
local opaque_tab = {}

core.register_on_mods_loaded(function()
	for name, ndef in pairs(core.registered_nodes) do
		local cid = core.get_content_id(name)
		opaque_tab[cid] = core.get_item_group(name, "opaque") ~= 0 and true or nil
		if name == "mcl_minecarts:golden_rail" or name == "mcl_minecarts:golden_rail_on" then
			golden_rail_tab[cid] = {
				c_on = core.get_content_id("mcl_minecarts:golden_rail_on"),
				c_off = core.get_content_id("mcl_minecarts:golden_rail"),
			}
		end
	end
end)

local directions = {
	{ rail = vector.new(1, 0, 0) },
	{ rail = vector.new(-1, 0, 0) },
	{ rail = vector.new(0, 0, 1) },
	{ rail = vector.new(0, 0, -1) },
	{ rail = vector.new(1, 1, 0), obstruct = vector.new(0, 1, 0) },
	{ rail = vector.new(-1, 1, 0), obstruct = vector.new(0, 1, 0) },
	{ rail = vector.new(0, 1, 1), obstruct = vector.new(0, 1, 0) },
	{ rail = vector.new(0, 1, -1), obstruct = vector.new(0, 1, 0) },
	{ rail = vector.new(1, -1, 0), obstruct = vector.new(1, 0, 0) },
	{ rail = vector.new(-1, -1, 0), obstruct = vector.new(-1, 0, 0) },
	{ rail = vector.new(0, -1, 1), obstruct = vector.new(0, 0, 1) },
	{ rail = vector.new(0, -1, -1), obstruct = vector.new(0, 0, -1) },
}

-- Propagate power from pos through powered rails. 'old_power' is the old power
-- of the node if it was updated. 'updates' is a table which get populated with
-- positions that have been traversed.
local function propagate_golden_rail_power(pos, new_power, old_power, powered_on)
	local vm = core.get_voxel_manip()
	local emin, emax = vm:read_from_map(pos:offset(-9, -9, -9), pos:offset(9, 9, 9))
	local a = VoxelArea:new{MinEdge = emin, MaxEdge = emax}
	local data = vm:get_data()
	local old_param2_data = vm:get_param2_data()
	local param2_data = vm:get_param2_data()

	local function get_power(ind)
		local cid = data[ind]
		if golden_rail_tab[cid] then
			return param2_data[ind]
		end
	end

	local function update_power(ind, power)
		local cid = data[ind]
		data[ind] = power > 0 and golden_rail_tab[cid].c_on or golden_rail_tab[cid].c_off
		param2_data[ind] = power
	end

	local clear_queue = mcl_util.queue()
	local fill_queue = mcl_util.queue()
	if old_power then
		clear_queue:enqueue({ pos = pos, power = old_power })
	end
	if new_power then
		local ind = a:indexp(pos)
		update_power(ind, new_power)
		fill_queue:enqueue({ pos = pos, power = new_power })
	end

	while clear_queue:size() > 0 do
		local entry = clear_queue:dequeue()
		local pos = entry.pos
		local ind = a:indexp(pos)
		local power = entry.power
		update_power(ind, 0)

		for _, dir in pairs(directions) do
			if not dir.obstruct or not opaque_tab[data[a:indexp(pos:add(dir.obstruct))]] then
				local pos2 = pos:add(dir.rail)
				local ind2 = a:indexp(pos2)
				local power2 = get_power(ind2)

				if power2 and power2 > 0 then
					if power2 < power then
						if golden_rail_tab[data[ind2]] then
							update_power(ind, 0)
							clear_queue:enqueue({ pos = pos2, power = power2 })
						end
					else
						update_power(ind2, power2)
						fill_queue:enqueue({ pos = pos2, power = power2 })
					end
				end
			end
		end
	end

	while fill_queue:size() > 0 do
		local entry = fill_queue:dequeue()
		local pos = entry.pos
		local ind = a:indexp(pos)
		local power = entry.power
		local power2 = power - 1
		update_power(ind, power)
		if old_param2_data[ind] == 0 and param2_data ~= 0 then
			powered_on[ind] = pos
		end

		for _, dir in pairs(directions) do
			if not dir.obstruct or not opaque_tab[data[a:indexp(pos:add(dir.obstruct))]] then
				local pos2 = pos:add(dir.rail)
				local ind2 = a:indexp(pos2)
				if golden_rail_tab[data[ind2]] and get_power(ind2) < power2 then
					update_power(ind2, power2)
					fill_queue:enqueue({ pos = pos2, power = power2 })
				end
			end
		end
	end

	vm:set_data(data)
	vm:set_param2_data(param2_data)
	vm:write_to_map(false)
end

local function push_minecart(pos)
	local dir = mcl_minecarts:get_start_direction(pos)
	if not dir then return end
	for o in core.objects_inside_radius(pos, 1) do
		local l = o:get_luaentity()
		local v = o:get_velocity()
		if l and string.sub(l.name, 1, 14) == "mcl_minecarts:"
		and v and vector.equals(v, vector.zero())
		then
			mcl_minecarts:set_velocity(l, dir)
		end
	end
end

local function golden_rail_redstone_update(pos)
	local oldpower = core.get_node(pos).param2
	local newpower = mcl_redstone.get_power(pos) ~= 0 and 8 or 0
	local powered_on = {}
	propagate_golden_rail_power(pos, newpower, oldpower, powered_on)

	for _, pos in pairs(powered_on) do
		push_minecart(pos)
	end
end

-- Powered rail (off = brake mode)
register_rail("mcl_minecarts:golden_rail",
	{"mcl_minecarts_rail_golden.png", "mcl_minecarts_rail_golden_curved.png", "mcl_minecarts_rail_golden_t_junction.png", "mcl_minecarts_rail_golden_crossing.png"},
	{
		description = S("Powered Rail"),
		_tt_help = S("Track for minecarts").."\n"..S("Speed up when powered, slow down when not powered"),
		_doc_items_longdesc = S("Rails can be used to build transport tracks for minecarts. Powered rails are able to accelerate and brake minecarts."),
		_doc_items_usagehelp = railuse .. "\n" .. S("Without redstone power, the rail will brake minecarts. To make this rail accelerate minecarts, power it with redstone power."),
		_rail_acceleration = -3,
		_mcl_redstone = {
			connects_to = function(node, dir)
				return true
			end,
			update = golden_rail_redstone_update,
		},
	}
)

-- Powered rail (on = acceleration mode)
register_rail("mcl_minecarts:golden_rail_on",
	{"mcl_minecarts_rail_golden_powered.png", "mcl_minecarts_rail_golden_curved_powered.png", "mcl_minecarts_rail_golden_t_junction_powered.png", "mcl_minecarts_rail_golden_crossing_powered.png"},
	{
		_doc_items_create_entry = false,
		_rail_acceleration = 4,
		_mcl_redstone = {
			connects_to = function(node, dir)
				return true
			end,
			update = golden_rail_redstone_update,
		},
		drop = "mcl_minecarts:golden_rail",
	},
	false
)

-- Activator rail (off)
register_rail("mcl_minecarts:activator_rail",
	{"mcl_minecarts_rail_activator.png", "mcl_minecarts_rail_activator_curved.png", "mcl_minecarts_rail_activator_t_junction.png", "mcl_minecarts_rail_activator_crossing.png"},
	{
		description = S("Activator Rail"),
		_tt_help = S("Track for minecarts").."\n"..S("Activates minecarts when powered"),
		_doc_items_longdesc = S("Rails can be used to build transport tracks for minecarts. Activator rails are used to activate special minecarts."),
		_doc_items_usagehelp = railuse .. "\n" .. S("To make this rail activate minecarts, power it with redstone power and send a minecart over this piece of rail."),
		_mcl_redstone = {
			update = function(pos)
				if mcl_redstone.get_power(pos) ~= 0 then
					core.swap_node(pos, {name = "mcl_minecarts:activator_rail_on"})
				end
			end,
		},
	}
)

-- Activator rail (on)
register_rail("mcl_minecarts:activator_rail_on",
	{"mcl_minecarts_rail_activator_powered.png", "mcl_minecarts_rail_activator_curved_powered.png", "mcl_minecarts_rail_activator_t_junction_powered.png", "mcl_minecarts_rail_activator_crossing_powered.png"},
	{
		_doc_items_create_entry = false,
		_mcl_redstone = {
			update = function(pos)
				if mcl_redstone.get_power(pos) == 0 then
					core.swap_node(pos, {name = "mcl_minecarts:activator_rail"})
				else
					local pos2 = { x = pos.x, y =pos.y + 1, z = pos.z }
					for o in core.objects_inside_radius(pos2, 1) do
						local l = o:get_luaentity()
						if l and string.sub(l.name, 1, 14) == "mcl_minecarts:" and l.on_activate_by_rail then
							l:on_activate_by_rail()
						end
					end
				end
			end,
		},
		drop = "mcl_minecarts:activator_rail",
	},
	false
)

-- Detector rail (off)
register_rail("mcl_minecarts:detector_rail",
	{"mcl_minecarts_rail_detector.png", "mcl_minecarts_rail_detector_curved.png", "mcl_minecarts_rail_detector_t_junction.png", "mcl_minecarts_rail_detector_crossing.png"},
	{
		description = S("Detector Rail"),
		_tt_help = S("Track for minecarts").."\n"..S("Emits redstone power when a minecart is detected"),
		_doc_items_longdesc = S("Rails can be used to build transport tracks for minecarts. A detector rail is able to detect a minecart above it and powers redstone mechanisms."),
		_doc_items_usagehelp = railuse .. "\n" .. S("To detect a minecart and provide redstone power, connect it to redstone trails or redstone mechanisms and send any minecart over the rail."),
	}
)

-- Detector rail (on)
register_rail("mcl_minecarts:detector_rail_on",
	{"mcl_minecarts_rail_detector_powered.png", "mcl_minecarts_rail_detector_curved_powered.png", "mcl_minecarts_rail_detector_t_junction_powered.png", "mcl_minecarts_rail_detector_crossing_powered.png"},
	{
		_doc_items_create_entry = false,
		_mcl_redstone = {
			get_power = function(node, dir)
				return 15, dir.y < 0
			end,
		},
		drop = "mcl_minecarts:detector_rail",
	},
	false
)


-- Crafting
core.register_craft({
	output = "mcl_minecarts:rail 16",
	recipe = {
		{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:stick", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
	}
})

core.register_craft({
	output = "mcl_minecarts:golden_rail 6",
	recipe = {
		{"mcl_core:gold_ingot", "", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mcl_core:stick", "mcl_core:gold_ingot"},
		{"mcl_core:gold_ingot", "mcl_redstone:redstone", "mcl_core:gold_ingot"},
	}
})

core.register_craft({
	output = "mcl_minecarts:activator_rail 6",
	recipe = {
		{"mcl_core:iron_ingot", "mcl_core:stick", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_redstone_torch:redstone_torch_on", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_core:stick", "mcl_core:iron_ingot"},
	}
})

core.register_craft({
	output = "mcl_minecarts:detector_rail 6",
	recipe = {
		{"mcl_core:iron_ingot", "", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_pressureplates:pressure_plate_stone_off", "mcl_core:iron_ingot"},
		{"mcl_core:iron_ingot", "mcl_redstone:redstone", "mcl_core:iron_ingot"},
	}
})


doc.add_entry_alias("nodes", "mcl_minecarts:golden_rail", "nodes", "mcl_minecarts:golden_rail_on")

