--[[
Explosion API mod for Minetest (adapted to MineClone 2)

This mod is based on the Minetest explosion API mod, but has been changed
to have the same explosion mechanics as Minecraft and work with MineClone.
The computation-intensive parts of the mod has been optimized to allow for
larger explosions and faster world updating.

This mod was created by Elias Astrom <ryvnf@riseup.net> and is released
under the LGPLv2.1 license.
--]]

mcl_explosions = {}

local mod_fire = minetest.get_modpath("mcl_fire")
local explosions_griefing = minetest.settings:get_bool("mcl_explosions_griefing", true)

-- Saved sphere explosion shapes for various radiuses
local sphere_shapes = {}

-- Saved node definitions in table using cid-keys for faster look-up.
local node_blastres = {}
local node_on_blast = {}
local node_walkable = {}

-- The step length for the rays (Minecraft uses 0.3)
local STEP_LENGTH = 0.3

-- How many rays to compute entity exposure to explosion
local N_EXPOSURE_RAYS = 16

-- Nodes having a blast resistance of this value or higher are treated as
-- indestructible
local INDESTRUCT_BLASTRES = 1000000

minetest.register_on_mods_loaded(function()
	-- Store blast resistance values by content ids to improve performance.
	for name, def in pairs(minetest.registered_nodes) do
		local id = minetest.get_content_id(name)
		node_blastres[id] = def._mcl_blast_resistance or 0
		node_on_blast[id] = def.on_blast
		node_walkable[id] = def.walkable
	end
end)

-- Compute the rays which make up a sphere with radius.	Returns a list of rays
-- which can be used to trace explosions. This function is not efficient
-- (especially for larger radiuses), so the generated rays for various radiuses
-- should be cached and reused.
--
-- Should be possible to improve by using a midpoint circle algorithm multiple
-- times to create the sphere, currently uses more of a brute-force approach.
local function compute_sphere_rays(radius)
	local rays = {}
	local sphere = {}

	local function add_ray(pos)
		sphere[minetest.hash_node_position(pos)] = pos
	end

	for y = -radius, radius do
		for z = -radius, radius do
			for x = -radius, 0 do
				local d = x * x + y * y + z * z
				if d <= radius * radius then
					add_ray(vector.new(x, y, z))
					add_ray(vector.new(-x, y, z))
					break
				end
			end
		end
	end

	for x = -radius, radius do
		for z = -radius, radius do
			for y = -radius, 0 do
				local d = x * x + y * y + z * z
				if d <= radius * radius then
					add_ray(vector.new(x, y, z))
					add_ray(vector.new(x, -y, z))
					break
				end
			end
		end
	end

	for x = -radius, radius do
		for y = -radius, radius do
			for z = -radius, 0 do
				local d = x * x + y * y + z * z
				if d <= radius * radius then
					add_ray(vector.new(x, y, z))
					add_ray(vector.new(x, y, -z))
					break
				end
			end
		end
	end

	for _, pos in pairs(sphere) do
		rays[#rays + 1] = vector.normalize(pos)
	end

	return rays
end

-- Add particles from explosion
--
-- Parameters:
-- pos - The position of the explosion
-- radius - The radius of the explosion
local function add_particles(pos, radius)
	minetest.add_particlespawner({
		amount = 64,
		time = 0.125,
		minpos = pos,
		maxpos = pos,
		minvel = vector.new(-radius, -radius, -radius),
		maxvel = vector.new(radius, radius, radius),
		minacc = vector.zero(),
		maxacc = vector.zero(),
		minexptime = 0.5,
		maxexptime = 1.0,
		minsize = radius * 0.5,
		maxsize = radius * 1.0,
		texture = "mcl_particles_smoke.png",
	})
end

-- Traces the rays of an explosion, and updates the environment.
--
-- Parameters:
-- pos - Where the rays in the explosion should start from
-- strength - The strength of each ray
-- raydirs - The directions for each ray
-- radius - The maximum distance each ray will go
-- info - Table containing information about explosion
-- direct - direct source object of the damage (optional)
-- source - indirect source object of the damage (optional)
--
-- Values in info:
-- drop_chance - The chance that destroyed nodes will drop their items
-- fire - If true, 1/3 nodes become fire
-- griefing - If true, the explosion will destroy nodes (default: true)
-- max_blast_resistance - The explosion will treat all non-indestructible nodes
--                        as having a blast resistance of no more than this
--                        value
-- grief_protected - If true, the explosion will also destroy nodes which have
--                   been protected
--
-- Note that this function has been optimized, it contains code which has been
-- inlined to avoid function calls and unnecessary table creation. This was
-- measured to give a significant performance increase.
local function trace_explode(pos, strength, raydirs, radius, info, direct, source)
	local vm = minetest.get_voxel_manip()

	local emin, emax = vm:read_from_map(vector.subtract(pos, radius),
		vector.add(pos, radius))
	local emin_x = emin.x
	local emin_y = emin.y
	local emin_z = emin.z

	local ystride = (emax.x - emin_x + 1)
	local zstride = ystride * (emax.y - emin_y + 1)

	--[[local area = VoxelArea:new {
		MinEdge = emin,
		MaxEdge = emax
	}]]
	local data = vm:get_data()
	local destroy = {}

	local drop_chance = info.drop_chance
	local fire = info.fire
	local max_blast_resistance = info.max_blast_resistance
	local grief_protected = info.grief_protected

	-- Trace rays for environment destruction
	if info.griefing and explosions_griefing then
		for i = 1, #raydirs do
			local rpos_x = pos.x
			local rpos_y = pos.y
			local rpos_z = pos.z
			local rdir_x = raydirs[i].x
			local rdir_y = raydirs[i].y
			local rdir_z = raydirs[i].z
			local rstr = (0.7 + math.random() * 0.6) * strength

			for r = 0, math.ceil(radius * (1.0 / STEP_LENGTH)) do
				local npos_x = math.floor(rpos_x + 0.5)
				local npos_y = math.floor(rpos_y + 0.5)
				local npos_z = math.floor(rpos_z + 0.5)
				local npos = { x = npos_x, y = npos_y, z = npos_z }
				local idx = (npos_z - emin_z) * zstride + (npos_y - emin_y) * ystride +
					npos_x - emin_x + 1

				local cid = data[idx]
				local br = node_blastres[cid] or INDESTRUCT_BLASTRES
				if br < INDESTRUCT_BLASTRES and br > max_blast_resistance then
					br = max_blast_resistance
				end

				local hash = minetest.hash_node_position(npos)

				rpos_x = rpos_x + STEP_LENGTH * rdir_x
				rpos_y = rpos_y + STEP_LENGTH * rdir_y
				rpos_z = rpos_z + STEP_LENGTH * rdir_z

				rstr = rstr - 0.75 * STEP_LENGTH - (br + 0.3) * STEP_LENGTH

				if rstr <= 0 then
					break
				end

				if cid ~= minetest.CONTENT_AIR then
					if not minetest.is_protected(npos, "") or grief_protected then
						destroy[hash] = idx
					end
				end
			end
		end
	end

	-- Entities in radius of explosion
	local punch_radius = 2 * strength
	local objs = minetest.get_objects_inside_radius(pos, punch_radius)

	-- Trace rays for entity damage
	for _, obj in pairs(objs) do
		local ent = obj:get_luaentity()

		-- Ignore items to lower lag
		if (obj:is_player() or (ent and ent.name ~= "__builtin.item")) and obj:get_hp() > 0 then
			local opos = obj:get_pos()
			local collisionbox = obj:get_properties().collisionbox

			if collisionbox then
				-- Create rays from random points in the collision box
				local x1 = collisionbox[1]
				local y1 = collisionbox[2]
				local z1 = collisionbox[3]
				local x2 = collisionbox[4]
				local y2 = collisionbox[5]
				local z2 = collisionbox[6]
				local x_len = math.abs(x2 - x1)
				local y_len = math.abs(y2 - y1)
				local z_len = math.abs(z2 - z1)

				-- Move object position to the center of its bounding box
				opos.x = opos.x + 0.5 * (x1 + x2)
				opos.y = opos.y + 0.5 * (y1 + y2)
				opos.z = opos.z + 0.5 * (z1 + z2)

				-- Count number of rays from collision box which are unobstructed
				local count = N_EXPOSURE_RAYS

				for i = 1, N_EXPOSURE_RAYS do
					local rpos_x = opos.x + math.random() * x_len - x_len / 2
					local rpos_y = opos.y + math.random() * y_len - y_len / 2
					local rpos_z = opos.z + math.random() * z_len - z_len / 2
					local rdir_x = pos.x - rpos_x
					local rdir_y = pos.y - rpos_y
					local rdir_z = pos.z - rpos_z
					local rdir_len = math.hypot(rdir_x, math.hypot(rdir_y, rdir_z))
					rdir_x = rdir_x / rdir_len
					rdir_y = rdir_y / rdir_len
					rdir_z = rdir_z / rdir_len

					for i = 0, rdir_len / STEP_LENGTH do
						rpos_x = rpos_x + rdir_x * STEP_LENGTH
						rpos_y = rpos_y + rdir_y * STEP_LENGTH
						rpos_z = rpos_z + rdir_z * STEP_LENGTH
						local npos_x = math.floor(rpos_x + 0.5)
						local npos_y = math.floor(rpos_y + 0.5)
						local npos_z = math.floor(rpos_z + 0.5)
						local idx = (npos_z - emin_z) * zstride + (npos_y - emin_y) * ystride +
							npos_x - emin_x + 1


						local cid = data[idx]
						local walkable = node_walkable[cid]

						if walkable then
							count = count - 1
							break
						end
					end
				end

				-- Punch entity with damage depending on explosion exposure and
				-- distance to explosion
				local exposure = count / N_EXPOSURE_RAYS
				local punch_vec = vector.subtract(opos, pos)
				local punch_dir = vector.normalize(punch_vec)
				local impact = (1 - vector.length(punch_vec) / punch_radius) * exposure
				if impact < 0 then
					impact = 0
				end
				local damage = math.floor((impact * impact + impact) * 7 * strength + 1)

				mcl_util.deal_damage(obj, damage, { type = "explosion", direct = direct, source = source })

				if obj:is_player() or ent.tnt_knockback then
					local player_dir = obj:get_look_dir() or opos
					local shield_dot = vector.dot(player_dir, vector.subtract(pos, opos))
					if obj:is_player() and mcl_shields and mcl_shields.is_blocking and mcl_shields.is_blocking(obj) and shield_dot >= 0 then
						obj:add_velocity(vector.multiply(punch_dir, impact * 10))
					else
						obj:add_velocity(vector.multiply(punch_dir, impact * 20))
					end
				end
			end
		end

		-- Punch End Crystals to make them explode
		if ent and ent.name == "mcl_end:crystal" then
			if direct then
				local puncher = direct:get_luaentity()
				if puncher and puncher.name == "mcl_end:crystal" then
					ent.object:punch(direct, 1.0, { -- End Crystal nearby, trigger it.
						full_punch_interval = 1.0,
							damage_groups = {fleshy = 1},
						}, nil, nil)
				else
					ent.object:remove() -- Direct Exists, but it is not an end crystal, remove crystal.
				end
			else
				ent.object:remove() -- Node exploded the end crystal, remove it.
			end
		end
	end

	local airs, fires = {}, {}

	-- Remove destroyed blocks and drop items
	for hash, idx in pairs(destroy) do
		local do_drop = math.random() <= drop_chance
		local on_blast = node_on_blast[data[idx]]
		local remove = true

		if do_drop or on_blast then
			local npos = minetest.get_position_from_hash(hash)
			if on_blast then
				on_blast(npos, 1.0, do_drop)
				remove = false
			else
				local name = minetest.get_name_from_content_id(data[idx])
				local drop = minetest.get_node_drops(name, "")

				for _, item in ipairs(drop) do
					if type(item) ~= "string" then
						item = item:get_name() .. item:get_count()
					end
					minetest.add_item(npos, item)
				end
			end
		end
		if remove then
			if mod_fire and fire and math.random(1, 3) == 1 then
				table.insert(fires, minetest.get_position_from_hash(hash))
			else
				table.insert(airs, minetest.get_position_from_hash(hash))
			end
		end
	end
	-- We use minetest.bulk_set_node instead of LVM because we want to have on_destruct and
	-- on_construct being called
	if #airs > 0 then
		minetest.bulk_set_node(airs, { name = "air" })
	end
	if #fires > 0 then
		minetest.bulk_set_node(fires, { name = "mcl_fire:fire" })
	end
	-- Update falling nodes
	for a = 1, #airs do
		local p = airs[a]
		minetest.check_for_falling(vector.offset(p, 0, 1, 0))
	end
	for f = 1, #fires do
		local p = fires[f]
		minetest.check_for_falling(vector.offset(p, 0, 1, 0))
	end

	-- Log explosion
	minetest.log("action", "Explosion at " .. minetest.pos_to_string(pos) .. " with strength " .. strength .. " and radius " ..
		radius)
end

-- Create an explosion with strength at pos.
--
-- Parameters:
-- pos - The position where the explosion originates from
-- strength - The blast strength of the explosion (a TNT explosion uses 4)
-- info - Table containing information about explosion
-- direct - direct source object of the damage (optional)
-- source - indirect source object of the damage (optional)
--
-- Values in info:
-- drop_chance - If specified becomes the drop chance of all nodes in the
--               explosion (default: 1.0 / strength)
-- max_blast_resistance - If specified the explosion will treat all
--                        non-indestructible nodes as having a blast resistance
--                        of no more than this value
-- sound - If true, the explosion will play a sound (default: true)
-- particles - If true, the explosion will create particles (default: true)
-- fire - If true, 1/3 nodes become fire (default: false)
-- griefing - If true, the explosion will destroy nodes (default: true)
-- grief_protected - If true, the explosion will also destroy nodes which have
--                   been protected (default: false)
function mcl_explosions.explode(pos, strength, info, direct, source)
	if info == nil then
		info = {}
	end

	-- The maximum blast radius (in the air)
	local radius = math.ceil(1.3 * strength / (0.3 * 0.75) * 0.3)

	if not sphere_shapes[radius] then
		sphere_shapes[radius] = compute_sphere_rays(radius)
	end
	local shape = sphere_shapes[radius]

	-- Default values
	if info.drop_chance == nil then info.drop_chance = 1 / strength end
	if info.particles == nil then info.particles = true end
	if info.sound == nil then info.sound = true end
	if info.fire == nil then info.fire = false end
	if info.griefing == nil then info.griefing = true end
	if info.grief_protected == nil then info.grief_protected = false end
	if info.max_blast_resistance == nil then
		info.max_blast_resistance = INDESTRUCT_BLASTRES
	end

	-- Dont do drops in creative mode
	if minetest.is_creative_enabled("") then
		info.drop_chance = 0
	end

	trace_explode(pos, strength, shape, radius, info, direct, source)

	if info.particles then
		add_particles(pos, radius)
	end
	if info.sound then
		minetest.sound_play("tnt_explode", {
			pos = pos, gain = 1.0,
			max_hear_distance = strength * 16
		}, true)
	end
end
