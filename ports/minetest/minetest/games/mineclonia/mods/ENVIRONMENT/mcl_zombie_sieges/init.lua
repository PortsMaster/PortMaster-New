
local function spawn_zombies(self)
	local pos = self.pos
	local v = vector.new ()
	for i = 1, 20 do
		for i1 = 1, 10 do
			v.x = pos.x - math.random (-8, 7)
			v.z = pos.z - math.random (-8, 7)
			v.y = pos.y
			local nodepos = mobs_mc.find_surface_position (v)
			if mcl_villages.get_poi_heat (nodepos) >= 5 then
				local m = mcl_mobs.spawn_abnormally (nodepos, "mobs_mc:zombie",
								     "siege")
				if m then
					local l = m:get_luaentity()
					table.insert (self.mobs, m)
					self.health_max = self.health_max + l.health
					break
				end
			end
		end
	end
end

local without_zombie_sieges_p = mcl_biome_dispatch.make_biome_test ({
	"MushroomIslands",
})
local ull = mcl_levelgen.ull
local rng = mcl_levelgen.xoroshiro (ull (0, 0), ull (0, 0))

mcl_events.register_event("zombie_siege",{
	readable_name = "Zombie Siege",
	max_stage = 1,
	health = 1,
	health_max = 1,
	exclusive_to_area = 128,
	enable_bossbar = false,
	cond_start = function()
		local r = {}

		local t = core.get_timeofday ()
		mcl_levelgen.set_region_seed (rng, mcl_levelgen.seed,
					      core.get_day_count (),
					      0, 1220384)

		if t < 0.04 and rng:next_within (10) == 0 then
			local players = core.get_connected_players ()
			table.shuffle (players)
			for _, p in ipairs (players) do
				if p:is_valid () then
					local nodepos = mcl_util.get_nodepos (p:get_pos ())
					local biome = mcl_biome_dispatch.get_biome_name (nodepos)
					for i = 1, 10 do
						if not without_zombie_sieges_p (biome)
							and mcl_villages.get_poi_heat (nodepos) >= 5 then
							local dir = rng:next_float () * math.pi * 2
							local dz = math.floor (math.cos (dir) * 32)
							local dx = math.floor (math.sin (dir) * 32)
							nodepos.x = nodepos.x + dx
							nodepos.z = nodepos.z + dz
							if mcl_villages.get_poi_heat (nodepos) >= 5 then
								table.insert (r, {
									player = p:get_player_name(),
									pos = nodepos,
								})
								break
							end
						end
					end
				end
			end
		end
		if #r > 0 then return r end
	end,
	on_start = function(self)
		self.mobs = {}
		self.health_max = 1
		self.health = 0
	end,
	cond_progress = function(self)
		local m = {}
		local h = 0
		for _, o in pairs(self.mobs) do
			if o and o:get_pos() then
				local l = o:get_luaentity()
				h = h + l.health
				table.insert(m,o)
			end
		end
		self.mobs = m
		self.health = h
		self.percent = math.max(0,(self.health / self.health_max ) * 100)
		if #m < 1 then
			return true end
	end,
	on_stage_begin = spawn_zombies,
	cond_complete = function(self)
		local m = {}
		for _, o in pairs(self.mobs) do
			if o and o:get_pos() then
				table.insert(m,o)
			end
		end
		return self.stage >= self.max_stage and #m < 1
	end,
	on_complete = function(self)
	end,
})
