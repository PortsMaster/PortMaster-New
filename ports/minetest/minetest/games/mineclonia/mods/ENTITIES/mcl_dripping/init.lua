mcl_dripping = {}

local ZERO_VECTOR = vector.zero ()
local DROP_ACCELERATION = vector.new (0, -5, 0)

local function make_drop_2 (pt, sound, interval)
	pt.acceleration = DROP_ACCELERATION
	pt.collisiondetection = true
	pt.expirationtime = math.random () + math.random (1, interval / 2)
	core.add_particle (pt)
	core.sound_play (sound, {
		pos = pt.pos,
		gain = 0.5,
		max_hear_distance = 8,
	}, true)
end

local function make_drop_1 (t, pt, sound, interval, texture)
	pt.acceleration = ZERO_VECTOR
	pt.collisiondetection = false
	pt.expirationtime = t
	pt.texture = table.concat ({
		"[combine:2x2:",
		math.random (-14, 0),
		",",
		math.random (-14, 0),
		"=",
		texture,
	})
	core.add_particle (pt)
	core.after (t, make_drop_2, pt, sound, interval)
end

local function make_drop (x, y, z, sound, interval, texture)
	local dx = math.random () - 0.5 * 0.45
	local dz = math.random () - 0.5 * 0.45
	local t = math.random () + math.random (1, interval)
	local pt = {
		velocity = ZERO_VECTOR,
		collision_removal = false,
		pos = vector.new (x + dx, y - 0.52, z + dz),
	}

	core.after (t, make_drop_1, t, pt, sound, interval, texture)
end

local cid_air = core.CONTENT_AIR
local lcg_next = mcl_util.lcg_next

function mcl_dripping.register_drop(def)
	local r = math.ceil (def.interval / 20)
	local area = r * r
	local half_area = math.floor (area / 2)
	local a, c = mcl_util.findlcg (area)
	local floor = math.floor
	local position_eligible_p, default_position_eligible_p
	local sound = def.sound
	local interval = def.interval
	local texture = def.texture

	core.register_on_mods_loaded (function ()
		local is_source_node = {}
		local is_liquid_node = {}

		local cids = mcl_levelgen.construct_cid_list (def.nodes)
		for _, cid in ipairs (cids) do
			is_source_node[cid] = true
		end

		local cids = mcl_levelgen.construct_cid_list ({
			"group:" .. def.liquid,
		})
		for _, cid in ipairs (cids) do
			is_liquid_node[cid] = true
		end

		position_eligible_p = function (x, y, z)
			local cid_below, _, _, _
				= core.get_node_raw (x, y - 1, z)
			local cid, _, _, _
				= core.get_node_raw (x, y, z)
			local cid_above, _, _, _
				= core.get_node_raw (x, y + 1, z)
			return cid_below == cid_air
				and is_source_node[cid]
				and is_liquid_node[cid_above]
		end

		default_position_eligible_p = function (x, y, z)
			local cid_below, _, _, _
				= core.get_node_raw (x, y - 1, z)
			local cid_above, _, _, _
				= core.get_node_raw (x, y + 1, z)
			return cid_below == cid_air
				and is_liquid_node[cid_above]
		end
	end)

	core.register_abm({
		label = "Create drops for group:" .. def.liquid,
		nodenames = def.nodes,
		neighbors = { "group:" .. def.liquid },
		interval = def.interval,
		chance = def.chance,
		action = function(pos)
			local x, y, z = pos.x, pos.y, pos.z
			if default_position_eligible_p (x, y, z) then
				make_drop (x, y, z, sound, interval, texture)

				-- Create particles for adjacent nodes
				-- to be able to get away with longer
				-- abm cycles.
				local state = math.random (0, area - 1)
				for i = 1, math.random (half_area, area) do
					state = lcg_next (a, c, area, state)
					if state ~= 0 then
						local x = floor (state / r) + x
						local z = state % r + z
						if position_eligible_p (x, y, z) then
							make_drop (x, y, z, sound, interval,
								   texture)
						end
					end
				end
			end
		end,
	})
end

mcl_dripping.register_drop({
	liquid   = "water",
	texture  = "default_water_source_animated.png",
	light    = 1,
	nodes    = { "group:opaque", "group:leaves" },
	sound    = "drippingwater_drip",
	interval = 60.3,
	chance   = 10,
})

mcl_dripping.register_drop({
	liquid   = "lava",
	texture  = "default_lava_source_animated.png",
	light    = math.max(7, core.registered_nodes["mcl_core:lava_source"].light_source - 3),
	nodes    = { "group:opaque" },
	sound    = "drippingwater_lavadrip",
	interval = 110.1,
	chance   = 10,
})
