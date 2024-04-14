local mob_class = mcl_mobs.mob_class
local DEFAULT_FALL_SPEED = -9.81*1.5
local FLOP_HEIGHT = 6
local FLOP_HOR_SPEED = 1.5

local node_snow = "mcl_core:snow"


local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false

local atann = math.atan
local function atan(x)
	if not x or x ~= x then
		return 0
	else
		return atann(x)
	end
end

-- get node but use fallback for nil or unknown
local node_ok = function(pos, fallback)
	fallback = fallback or mcl_mobs.fallback_node
	local node = minetest.get_node_or_nil(pos)
	if node and minetest.registered_nodes[node.name] then
		return node
	end
	return minetest.registered_nodes[fallback]
end

-- Returns true is node can deal damage to self
function mob_class:is_node_dangerous(nodename)
	local nn = nodename
	if self.lava_damage > 0 then
		if minetest.get_item_group(nn, "lava") ~= 0 then
			return true
		end
	end
	if self.fire_damage > 0 then
		if minetest.get_item_group(nn, "fire") ~= 0 then
			return true
		end
	end
	if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].damage_per_second and minetest.registered_nodes[nn].damage_per_second > 0 then
		return true
	end
	return false
end


-- Returns true if node is a water hazard
function mob_class:is_node_waterhazard(nodename)
	local nn = nodename
	if self.water_damage > 0 then
		if minetest.get_item_group(nn, "water") ~= 0 then
			return true
		end
	end
	if minetest.registered_nodes[nn] and minetest.registered_nodes[nn].drowning and minetest.registered_nodes[nn].drowning > 0 then
		if self.object:get_properties().breath_max ~= -1 then
			-- check if the mob is water-breathing _and_ the block is water; only return true if neither is the case
			-- this will prevent water-breathing mobs to classify water or e.g. sand below them as dangerous
			if not self.breathes_in_water and minetest.get_item_group(nn, "water") ~= 0 then
				return true
			end
		end
	end
	return false
end

function mob_class:target_visible(origin, target)
	if not origin then return end

	if not target and self.attack then
		target = self.attack
	end
	if not target then return end

	local target_pos = target:get_pos()
	if not target_pos then return end

	local origin_eye_pos = vector.offset(origin, 0, self.head_eye_height, 0)

	local targ_head_height, targ_feet_height
	local cbox = self.object:get_properties().collisionbox
	if target:is_player() then
		targ_head_height = vector.offset(target_pos, 0, cbox[5], 0)
		targ_feet_height = target_pos -- Cbox would put feet under ground which interferes with ray
	else
		targ_head_height = vector.offset(target_pos, 0, cbox[5], 0)
		targ_feet_height = vector.offset(target_pos, 0, cbox[2], 0)
	end

	if minetest.line_of_sight(origin_eye_pos, targ_head_height) then
		return true
	end

	if minetest.line_of_sight(origin_eye_pos, targ_feet_height) then
		return true
	end

	-- TODO mid way between feet and head

	return false
end

-- check line of sight (BrunoMine)
function mob_class:line_of_sight(pos1, pos2, stepsize)

	stepsize = stepsize or 1

	local s, _ = minetest.line_of_sight(pos1, pos2, stepsize)

	-- normal walking and flying mobs can see you through air
	if s == true then
		return true
	end

	-- New pos1 to be analyzed
	local npos1 = {x = pos1.x, y = pos1.y, z = pos1.z}

	local r, pos = minetest.line_of_sight(npos1, pos2, stepsize)

	-- Checks the return
	if r == true then return true end

	-- Nodename found
	local nn = minetest.get_node(pos).name

	-- Target Distance (td) to travel
	local td = vector.distance(pos1, pos2)

	-- Actual Distance (ad) traveled
	local ad = 0

	-- It continues to advance in the line of sight in search of a real
	-- obstruction which counts as 'normal' nodebox.
	while minetest.registered_nodes[nn]
	and minetest.registered_nodes[nn].walkable == false do

		-- Check if you can still move forward
		if td < ad + stepsize then
			return true -- Reached the target
		end

		-- Moves the analyzed pos
		local d = vector.distance(pos1, pos2)

		npos1.x = ((pos2.x - pos1.x) / d * stepsize) + pos1.x
		npos1.y = ((pos2.y - pos1.y) / d * stepsize) + pos1.y
		npos1.z = ((pos2.z - pos1.z) / d * stepsize) + pos1.z

		-- NaN checks
		if d == 0
		or npos1.x ~= npos1.x
		or npos1.y ~= npos1.y
		or npos1.z ~= npos1.z then
			return false
		end

		ad = ad + stepsize

		-- scan again
		r, pos = minetest.line_of_sight(npos1, pos2, stepsize)

		if r == true then return true end

		-- New Nodename found
		nn = minetest.get_node(pos).name

	end

	return false
end

function mob_class:can_jump_cliff()
	local pos = self.object:get_pos()

	--is there nothing under the block in front? if so jump the gap.
	local dir_x, dir_z = self:forward_directions()
	local pos_low = vector.offset(pos, dir_x, -0.5, dir_z)
	local pos_far = vector.offset(pos, dir_x * 2, -0.5, dir_z * 2)
	local pos_far2 = vector.offset(pos, dir_x * 3, -0.5, dir_z * 3)

	local nodLow = node_ok(pos_low, "air")
	local nodFar = node_ok(pos_far, "air")
	local nodFar2 = node_ok(pos_far2, "air")

	if minetest.registered_nodes[nodLow.name]
	and minetest.registered_nodes[nodLow.name].walkable ~= true


	and (minetest.registered_nodes[nodFar.name]
	and minetest.registered_nodes[nodFar.name].walkable == true

	or minetest.registered_nodes[nodFar2.name]
	and minetest.registered_nodes[nodFar2.name].walkable == true)

	then
		--disable fear heigh while we make our jump
		self._jumping_cliff = true
		minetest.after(1, function()
			if self and self.object then
				self._jumping_cliff = false
			end
		end)
		return true
	else
		return false
	end
end

-- is mob facing a cliff or danger
function mob_class:is_at_cliff_or_danger()
	if self.fear_height == 0 or self._jumping_cliff or not self.object:get_luaentity() then -- 0 for no falling protection!
		return false
	end

	local cbox = self.object:get_properties().collisionbox
	local dir_x, dir_z = self:forward_directions()
	local pos = self.object:get_pos()

	local free_fall, blocker = minetest.line_of_sight(
		vector.offset(pos, dir_x, cbox[2], dir_z),
		vector.offset(pos, dir_x, -self.fear_height, dir_z))

	if free_fall then
		return true
	else
		local bnode = minetest.get_node(blocker)
		local danger = self:is_node_dangerous(bnode.name)
		if danger then
			return true
		else
			local def = minetest.registered_nodes[bnode.name]
			if def and def.walkable then
				return false
			end
		end
	end

	return false
end


-- copy the 'mob facing cliff_or_danger check' from above, and rework to avoid water
function mob_class:is_at_water_danger()
	if not self.object:get_luaentity() or self._jumping_cliff then
		return false
	end

	local dir_x, dir_z = self:forward_directions()
	local cbox = self.object:get_properties().collisionbox
	local pos = self.object:get_pos()

	local p1 = vector.offset(pos, dir_x, cbox[2], dir_z)
	local p2 = vector.offset(pos, dir_x, cbox[2] - 3, dir_z)
	if not mcl_mobs.check_vector(pos) or not mcl_mobs.check_vector(p1) or not mcl_mobs.check_vector(p2) then return false end

	local free_fall, blocker = minetest.line_of_sight(p1, p2)

	if free_fall then
		return true
	else
		local bnode = minetest.get_node(blocker)
		local waterdanger = self:is_node_waterhazard(bnode.name)
		if
			waterdanger and (self:is_node_waterhazard(self.standing_in) or self:is_node_waterhazard( self.standing_on)) then
			return false
		elseif waterdanger and (self:is_node_waterhazard(self.standing_in) or self:is_node_waterhazard(self.standing_on)) == false then
			return true
		else
			local def = minetest.registered_nodes[bnode.name]
			if def and def.walkable then
				return false
			end
		end
	end

	return false
end

function mob_class:should_get_out_of_water()

	if self.breathes_in_water or self.object:get_properties().breath_max == -1 then
		return false
	end

	if
		(
			minetest.registered_nodes[self.standing_in]
			and minetest.registered_nodes[self.standing_in].drowning
			and minetest.registered_nodes[self.standing_in].drowning > 0
		)
		and (
			minetest.registered_nodes[self.standing_on]
			and minetest.registered_nodes[self.standing_on].drowning
			and minetest.registered_nodes[self.standing_on].drowning > 0
		)
	then
		return true
	end

	return false
end

function mob_class:get_out_of_water()
	local mypos = self.object:get_pos()
	local land = minetest.find_nodes_in_area_under_air(
		vector.offset(mypos, -32, -1, -32),
		vector.offset(mypos, 32, 1, 32),
		{ "group:solid" }
	)

	local closest = 10000
	local closest_land

	for _, v in pairs(land) do
		local dst = vector.distance(mypos, v)
		if dst < closest then
			closest = dst
			closest_land = v
		end
	end

	if closest_land then
		self:go_to_pos(closest_land)
	end
end

function mob_class:env_danger_movement_checks(dtime)
	local yaw = 0
	if self:is_at_water_danger() and self.state ~= "attack" then
		if math.random(1, 10) <= 6 then
			self:set_velocity(0)
			self:set_state("stand")
			self:set_animation( "stand")
			yaw = yaw + math.random(-0.5, 0.5)
			self:set_yaw( yaw, 8)
		end
	elseif self:should_get_out_of_water() and self.state ~= "attack" then
		self:get_out_of_water()
	else
		if self.move_in_group ~= false then
			self:check_herd(dtime)
		end
	end

	if self:is_at_cliff_or_danger() then
		self:set_velocity(0)
		self:set_state("stand")
		self:set_animation( "stand")
		local yaw = self.object:get_yaw() or 0
		self:set_yaw( yaw + 0.78, 8)
	end
end

-- jump if facing a solid node (not fences or gates)
function mob_class:do_jump()
	if not self.jump
	or self.jump_height == 0
	or self.fly
	or self.order == "stand" then
		return false
	end

	self.facing_fence = false

	-- something stopping us while moving?
	if self.state ~= "stand"
	and self:get_velocity() > 0.5
	and self.object:get_velocity().y ~= 0 then
		return false
	end

	local pos = self.object:get_pos()

	-- what is mob standing on?
	local cbox = self.object:get_properties().collisionbox
	local nod = node_ok(vector.offset(pos, 0, cbox[2] - 0.2, 0))

	local in_water = minetest.get_item_group(node_ok(pos).name, "water") > 0

	if minetest.registered_nodes[nod.name].walkable == false and not in_water then
		return false
	end

	-- what is in front of mob?
	nod = self:node_infront_ok(pos, 0.5)

	-- this is used to detect if there's a block on top of the block in front of the mob.
	-- If there is, there is no point in jumping as we won't manage.
	local y_up = 1.5
	if in_water then
		y_up = cbox[5]
	end
	local nodTop = self:node_infront_ok(pos, y_up, "air")

	-- we don't attempt to jump if there's a stack of blocks blocking
	if minetest.registered_nodes[nodTop.name].walkable == true and not (self.attack and self.state == "attack") then
		return false
	end

	-- thin blocks that do not need to be jumped
	if nod.name == node_snow then
		return false
	end

	local ndef = minetest.registered_nodes[nod.name]
	if self.walk_chance == 0 or ndef and ndef.walkable or self:can_jump_cliff() then

		if minetest.get_item_group(nod.name, "fence") == 0
		and minetest.get_item_group(nod.name, "fence_gate") == 0
		and minetest.get_item_group(nod.name, "wall") == 0 then

			local v = self.object:get_velocity()

			v.y = self.jump_height + 0.1 * 3

			if in_water then
				v = vector.multiply(v, vector.new(1.5, 1.7, 1.5))
			elseif self:can_jump_cliff() then
				v = vector.multiply(v, vector.new(2.8, 1, 2.8))
			end

			self:set_animation( "jump") -- only when defined

			self.object:set_velocity(v)

			-- when in air move forward
			minetest.after(0.3, function(self, v)
				if (not self.object) or (not self.object:get_luaentity()) or (self.state == "die") then
					return
				end
				self.object:set_acceleration({
					x = v.x * 2,
					y = DEFAULT_FALL_SPEED,
					z = v.z * 2,
				})
			end, self, v)

			if self.jump_sound_cooloff <= 0 then
				self:mob_sound("jump")
				self.jump_sound_cooloff = 0.5
			end
		else
			self.facing_fence = true
		end

		-- if we jumped against a block/wall 4 times then turn
		if self.object:get_velocity().x ~= 0
		and self.object:get_velocity().z ~= 0 then

			self.jump_count = (self.jump_count or 0) + 1

			if self.jump_count == 4 then

				local yaw = self.object:get_yaw() or 0

				self:set_yaw( yaw + 1.35, 8)

				self.jump_count = 0
			end
		end

		return true
	end

	return false
end

local function in_list(list, what)
	return type(list) == "table" and table.indexof(list, what) ~= -1
end

function mob_class:is_object_in_view(object_list, object_range, node_range, turn_around)
	local s = self.object:get_pos()
	local min_dist = object_range + 1
	local objs = minetest.get_objects_inside_radius(s, object_range)
	local object_pos = nil

	for n = 1, #objs do
		local name = ""
		local object = objs[n]

		if object:is_player() then
			if not (mcl_mobs.invis[ object:get_player_name() ]
			or self.owner == object:get_player_name()
			or (not self:object_in_range(object))) then
				name = "player"
				if not (name ~= self.name
				and in_list(object_list, name)) then
					local item = object:get_wielded_item()
					name = item:get_name() or ""
				end
			end
		else
			local obj = object:get_luaentity()

			if obj then
				object = obj.object
				name = obj.name or ""
			end
		end

		-- find specific mob to avoid or runaway from
		if name ~= "" and name ~= self.name
		and in_list(object_list, name) then

			local p = object:get_pos()
			local dist = vector.distance(p, s)

			-- choose closest player/mob to avoid or runaway from
			if dist < min_dist
			-- aim higher to make looking up hills more realistic
			and self:line_of_sight(vector.offset(s, 0,1,0), vector.offset(p, 0,1,0)) == true then
				min_dist = dist
				object_pos = p
			end
		end
	end

	if not object_pos then

		-- find specific node to avoid or runaway from
		local p = minetest.find_node_near(s, node_range, object_list, true)
		local dist = p and vector.distance(p, s)
		if dist and dist < min_dist
		and self:line_of_sight(s, p) == true then
			object_pos = p
		end
	end

	if object_pos and turn_around then

		local vec = vector.subtract(object_pos, s)
		local yaw = (atan(vec.z / vec.x) + 3 *math.pi/ 2) - self.rotate
		if object_pos.x > s.x then yaw = yaw + math.pi end

		self:set_yaw(yaw, 4)
	end

	return object_pos ~= nil
end

-- should mob follow what I'm holding ?
function mob_class:follow_holding(clicker)
	if self.nofollow then return false end

	if mcl_mobs.invis[clicker:get_player_name()] then
		return false
	end

	local item = clicker:get_wielded_item()
	local t = type(self.follow)

	-- single item
	if t == "string"
	and item:get_name() == self.follow then
		return true

	-- multiple items
	elseif t == "table" and in_list(self.follow, item:get_name()) then
		return true
	end

	return false
end


-- find and replace what mob is looking for (grass, wheat etc.)
function mob_class:replace(pos)


	if not self.replace_rate
	or not self.replace_what
	or self.child == true
	or self.object:get_velocity().y ~= 0
	or math.random(1, self.replace_rate) > 1 then
		return
	end

	local what, with, y_offset

	if type(self.replace_what[1]) == "table" then

		local num = math.random(#self.replace_what)

		what = self.replace_what[num][1] or ""
		with = self.replace_what[num][2] or ""
		y_offset = self.replace_what[num][3] or 0
	else
		what = self.replace_what
		with = self.replace_with or ""
		y_offset = self.replace_offset or 0
	end

	pos.y = pos.y + y_offset

	local node = minetest.get_node(pos)
	if node.name == what then

		local oldnode = {name = what, param2 = node.param2}
		local newnode = {name = with, param2 = node.param2}
		local on_replace_return = false
		if self.on_replace then
			on_replace_return = self.on_replace(self, pos, oldnode, newnode)
		end


		if on_replace_return ~= false then

			if mobs_griefing then
				minetest.after(self.replace_delay, function()
					if self and self.object and self.object:get_velocity() and self.health > 0 then
						minetest.set_node(pos, newnode)
					end
				end)
			end
		end
	end
end

-- find someone to runaway from
function mob_class:check_runaway_from()
	if not self.runaway_from and self.state ~= "flop" then
		return
	end
	if self:is_object_in_view(self.runaway_from, self.view_range, self.view_range / 2, true) then
		self.state = "runaway"
		self.runaway_timer = 3
		self.following = nil
	end
end


-- follow player if owner or holding item, if fish outta water then flop
function mob_class:follow_flop()

	-- find player to follow
	if (self.follow ~= ""
	or self.order == "follow")
	and not self.following
	and self.state ~= "attack"
	and self.order ~= "sit"
	and self.state ~= "runaway" then

		local players = minetest.get_connected_players()

		for n = 1, #players do

			if (self:object_in_range(players[n]))
			and not mcl_mobs.invis[ players[n]:get_player_name() ] then

				self.following = players[n]

				break
			end
		end
	end

	if self.type == "npc"
	and self.order == "follow"
	and self.state ~= "attack"
	and self.order ~= "sit"
	and self.owner ~= "" then

		-- npc stop following player if not owner
		if self.following
		and self.owner
		and self.owner ~= self.following:get_player_name() then
			self.following = nil
		end
	else
		-- stop following player if not holding specific item,
		-- mob is horny, fleeing or attacking
		if self.following
		and self.following:is_player()
		and (self:follow_holding(self.following) == false or
		self.horny or self.state == "runaway") then
			self.following = nil
		end

	end

	-- follow that thing
	if self.following then

		local s = self.object:get_pos()
		local p

		if self.following:is_player() then

			p = self.following:get_pos()

		elseif self.following.object then

			p = self.following.object:get_pos()
		end

		if p then

			local dist = vector.distance(p, s)

			-- dont follow if out of range
			if (not self:object_in_follow_range(self.following)) then
				self.following = nil
			else
				local vec = {
					x = p.x - s.x,
					z = p.z - s.z
				}

				local yaw = (atan(vec.z / vec.x) +math.pi/ 2) - self.rotate

				if p.x > s.x then yaw = yaw +math.pi end

				self:set_yaw( yaw, 2.35)

				-- anyone but standing npc's can move along
				if dist > 3
				and self.order ~= "stand" then

					self:set_velocity(self.follow_velocity)

					if self.walk_chance ~= 0 then
						self:set_animation( "run")
					end
				else
					self:set_velocity(0)
					self:set_animation( "stand")
				end

				return
			end
		end
	end

	-- swimmers flop when out of their element, and swim again when back in
	if self.fly then
		local s = self.object:get_pos()
		if self:flight_check( s) == false then

			self:set_state("flop")
			self.object:set_acceleration({x = 0, y = DEFAULT_FALL_SPEED, z = 0})

			local p = self.object:get_pos()
			local cbox = self.object:get_properties().collisionbox
			local sdef = minetest.registered_nodes[node_ok(vector.add(p, vector.new(0,cbox[2]-0.2,0))).name]
			-- Flop on ground
			if sdef and sdef.walkable then
				if self.object:get_velocity().y < 0.1 then
					self:mob_sound("flop")
					self.object:set_velocity({
						x = math.random(-FLOP_HOR_SPEED, FLOP_HOR_SPEED),
						y = FLOP_HEIGHT,
						z = math.random(-FLOP_HOR_SPEED, FLOP_HOR_SPEED),
					})
				end
			end

			self:set_animation( "stand", true)

			return
		elseif self.state == "flop" then
			self:set_state("stand")
			self.object:set_acceleration({x = 0, y = 0, z = 0})
			self:set_velocity(0)
		end
	end
end

function mob_class:look_at(b)
	local s=self.object:get_pos()
	local v = { x = b.x - s.x, z = b.z - s.z }
	local yaw = (atann(v.z / v.x) +math.pi/ 2) - self.rotate
	if b.x > s.x then yaw = yaw +math.pi end
	self.object:set_yaw(yaw)
end

function mob_class:go_to_pos(b)
	if not self then return end
	local s=self.object:get_pos()
	if not b then
		--self:set_state("stand")
		return end
	if vector.distance(b,s) < 0.5 then
		--self:set_velocity(0)
		return true
	end
	self:look_at(b)
	self:set_velocity(self.walk_velocity)
	self:set_animation("walk")
end

local check_herd_timer = 0
function mob_class:check_herd(dtime)
	local pos = self.object:get_pos()
	if not pos then return end
	check_herd_timer = check_herd_timer + dtime
	if check_herd_timer < 4 then return end
	check_herd_timer = 0
	for _,o in pairs(minetest.get_objects_inside_radius(pos,self.view_range)) do
		local l = o:get_luaentity()
		local p,y
		if l and l.is_mob and l.name == self.name then
			if self.horny and l.horny then
				p = l.object:get_pos()
			else
				y = o:get_yaw()
			end
			if p then
				self:go_to_pos(p)
			elseif y then
				self:set_yaw(y)
			end
		end
	end
end

function mob_class:teleport(target)
	if self.do_teleport then
		if self.do_teleport(self, target) == false then
			return
		end
	end
end

function mob_class:do_states_walk()
	local yaw = self.object:get_yaw() or 0

	local s = self.object:get_pos()
	local lp = nil

	-- is there something I need to avoid?
	if (self.water_damage > 0
			and self.lava_damage > 0)
			or self.object:get_properties().breath_max ~= -1 then
		lp = minetest.find_node_near(s, 1, {"group:water", "group:lava"})
	elseif self.water_damage > 0 then
		lp = minetest.find_node_near(s, 1, {"group:water"})
	elseif self.lava_damage > 0 then
		lp = minetest.find_node_near(s, 1, {"group:lava"})
	elseif self.fire_damage > 0 then
		lp = minetest.find_node_near(s, 1, {"group:fire"})
	end

	local is_in_danger = false
	if lp then
		-- If mob in or on dangerous block, look for land
		if (self:is_node_dangerous(self.standing_in) or
				self:is_node_dangerous(self.standing_on)) or (self:is_node_waterhazard(self.standing_in) or self:is_node_waterhazard(self.standing_on)) and (not self.fly) then
			is_in_danger = true

			-- If mob in or on dangerous block, look for land
			if is_in_danger then
				-- Better way to find shore - copied from upstream
				lp = minetest.find_nodes_in_area_under_air(
						{x = s.x - 5, y = s.y - 0.5, z = s.z - 5},
						{x = s.x + 5, y = s.y + 1, z = s.z + 5},
						{"group:solid"})

				lp = #lp > 0 and lp[math.random(#lp)]

				-- did we find land?
				if lp then

					local vec = {
						x = lp.x - s.x,
						z = lp.z - s.z
					}

					yaw = (atan(vec.z / vec.x) +math.pi/ 2) - self.rotate


					if lp.x > s.x  then yaw = yaw +math.pi end

					-- look towards land and move in that direction
					yaw = self:set_yaw( yaw, 6)
					self:set_velocity(self.walk_velocity)

				end
			end
		end
	end

	if not is_in_danger then
		local distance = self.avoid_distance or self.view_range / 2
		-- find specific node to avoid
		if self:is_object_in_view(self.avoid_nodes, distance, distance, true) then
			self:set_velocity(self.walk_velocity)
		-- otherwise randomly turn
		elseif math.random(1, 100) <= 30 then
			yaw = yaw + math.random(-0.5, 0.5)
			self:set_yaw(yaw, 8)
		end
	end

	-- stand for great fall or danger or fence in front
	local cliff_or_danger = false
	if is_in_danger then
		cliff_or_danger = self:is_at_cliff_or_danger()
	end

	local facing_solid = false

	-- No need to check if we are already going to turn
	if not self.facing_fence and not cliff_or_danger then
		local nod = self:node_infront_ok(s, 0.5)

		if minetest.registered_nodes[nod.name] and minetest.registered_nodes[nod.name].walkable == true then
			facing_solid = true
		end
	end
	if self.facing_fence == true
			or cliff_or_danger
			or facing_solid
			or math.random(1, 100) <= 30 then

		self:set_velocity(0)
		self:set_state("stand")
		self:set_animation( "stand")
		local yaw = self.object:get_yaw() or 0
		self:set_yaw( yaw + 0.78, 8)
	else

		self:set_velocity(self.walk_velocity)

		if self:flight_check()
				and self.animation
				and self.animation.fly_start
				and self.animation.fly_end then
			self:set_animation( "fly")
		else
			self:set_animation( "walk")
		end
	end
end

function mob_class:do_states_stand()
	local yaw = self.object:get_yaw() or 0

	if math.random(1, 4) == 1 then

		local s = self.object:get_pos()
		local objs = minetest.get_objects_inside_radius(s, 3)
		local lp
		for n = 1, #objs do
			if objs[n]:is_player() then
				lp = objs[n]:get_pos()
				break
			end
		end

		-- look at any players nearby, otherwise turn randomly
		if lp and self.look_at_players then

			local vec = {
				x = lp.x - s.x,
				z = lp.z - s.z
			}

			yaw = (atan(vec.z / vec.x) +math.pi/ 2) - self.rotate

			if lp.x > s.x then yaw = yaw +math.pi end
		else
			yaw = yaw + math.random(-0.5, 0.5)
		end

		self:set_yaw( yaw, 8)
	end
	if self.order == "sit" then
		self:set_animation( "sit")
		self:set_velocity(0)
	else
		self:set_animation( "stand")
		self:set_velocity(0)
	end

	-- npc's ordered to stand stay standing
	if self.order == "stand" or self.order == "sleep" or self.order == "work" then
		self:set_state("stand")
		self:set_animation( "stand")
	else
		if self.walk_chance ~= 0
				and self.facing_fence ~= true
				and math.random(1, 100) <= self.walk_chance
				and self:is_at_cliff_or_danger() == false then

			self:set_velocity(self.walk_velocity)
			self:set_state("walk")
			self:set_animation( "walk")
		end
	end
end

function mob_class:do_states_runaway()
	self.runaway_timer = self.runaway_timer + 1

	-- stop after 5 seconds or when at cliff
	if self.runaway_timer > 5
			or self:is_at_cliff_or_danger() then
		self.runaway_timer = 0
		self:set_velocity(0)
		self:set_state("stand")
		self:set_animation( "stand")
		local yaw = self.object:get_yaw() or 0
		self:set_yaw( yaw + 0.78, 8)
	else
		self:set_velocity( self.run_velocity)
		self:set_animation( "run")
	end
end






function mob_class:check_smooth_rotation(dtime)
	-- smooth rotation by ThomasMonroe314
	if self._turn_to then
		self:set_yaw( self._turn_to, .1)
	end

	if self.delay and self.delay > 0 then

		local yaw = self.object:get_yaw() or 0

		if self.delay == 1 then
			yaw = self.target_yaw
		else
			local dif = math.abs(yaw - self.target_yaw)

			if yaw > self.target_yaw then

				if dif > math.pi then
					dif = 2 * math.pi - dif -- need to add
					yaw = yaw + dif / self.delay
				else
					yaw = yaw - dif / self.delay -- need to subtract
				end

			elseif yaw < self.target_yaw then

				if dif >math.pi then
					dif = 2 * math.pi - dif
					yaw = yaw - dif / self.delay -- need to subtract
				else
					yaw = yaw + dif / self.delay -- need to add
				end
			end

			if yaw > (math.pi * 2) then yaw = yaw - (math.pi * 2) end
			if yaw < 0 then yaw = yaw + (math.pi * 2) end
		end

		self.delay = self.delay - 1
		if self.shaking then
			yaw = yaw + (math.random() * 2 - 1) * 5 * dtime
		end
		self.object:set_yaw(yaw)
		self:update_roll()
	end
	-- end rotation
end
