--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes
mobs_mc = {}

local pr = PseudoRandom(os.time()*5)

local offsets = {}
for x=-2, 2 do
	for z=-2, 2 do
		table.insert(offsets, {x=x, y=0, z=z})
	end
end

--[[ Periodically check and teleport mob to owner if not sitting (order ~= "sit") and
the owner is too far away. To be used with do_custom. Note: Optimized for mobs smaller than 1×1×1.
Larger mobs might have space problems after teleportation.

* dist: Minimum required distance from owner to teleport. Default: 12
* teleport_check_interval: Optional. Interval in seconds to check the mob teleportation. Default: 4 ]]
mobs_mc.make_owner_teleport_function = function(dist, teleport_check_interval)
	return function(self, dtime)
		-- No teleportation if no owner or if sitting
		if not self.owner or self.order == "sit" then
			return
		end
		if not teleport_check_interval then
			teleport_check_interval = 4
		end
		if not dist then
			dist = 12
		end
		if self._teleport_timer == nil then
			self._teleport_timer = teleport_check_interval
			return
		end
		self._teleport_timer = self._teleport_timer - dtime
		if self._teleport_timer <= 0 then
			self._teleport_timer = teleport_check_interval
			local mob_pos = self.object:get_pos()
			local owner = minetest.get_player_by_name(self.owner)
			if not owner then
				-- No owner found, no teleportation
				return
			end
			local owner_pos = owner:get_pos()
			local dist_from_owner = vector.distance(owner_pos, mob_pos)
			if dist_from_owner > dist then
				-- Check for nodes below air in a 5×1×5 area around the owner position
				local check_offsets = table.copy(offsets)
				-- Attempt to place mob near player. Must be placed on walkable node below a non-walkable one. Place inside that air node.
				while #check_offsets > 0 do
					local r = pr:next(1, #check_offsets)
					local telepos = vector.add(owner_pos, check_offsets[r])
					local telepos_below = {x=telepos.x, y=telepos.y-1, z=telepos.z}
					table.remove(check_offsets, r)
					-- Long story short, spawn on a platform
					local trynode = minetest.registered_nodes[minetest.get_node(telepos).name]
					local trybelownode = minetest.registered_nodes[minetest.get_node(telepos_below).name]
					if trynode and not trynode.walkable and
							trybelownode and trybelownode.walkable then
						-- Correct position found! Let's teleport.
						self.object:set_pos(telepos)
						return
					end
				end
			end
		end
	end
end

mobs_mc.shears_wear = 276
mobs_mc.water_level = tonumber(minetest.settings:get("water_level")) or 0

-- Auto load all lua files
local path = minetest.get_modpath("mobs_mc")
for _, file in pairs(minetest.get_dir_list(path, false)) do
	if file:sub(-4) == ".lua" and file ~= "init.lua" then
		dofile(path .. "/" ..file)
	end
end
