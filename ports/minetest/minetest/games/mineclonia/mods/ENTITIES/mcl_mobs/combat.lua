local mob_class = mcl_mobs.mob_class

local damage_enabled = minetest.settings:get_bool("enable_damage")
local mobs_griefing = minetest.settings:get_bool("mobs_griefing") ~= false

local stuck_timeout = 3 -- how long before mob gets stuck in place and starts searching
local stuck_path_timeout = 10 -- how long will mob follow path before giving up

local enable_pathfinding = true

local TIME_TO_FORGET_TARGET = 15

local atann = math.atan
local function atan(x)
	if not x or minetest.is_nan(x) then
		return 0
	else
		return atann(x)
	end
end

-- get node but use fallback for nil or unknown
local function node_ok(pos, fallback)
	fallback = fallback or mcl_mobs.fallback_node
	local node = minetest.get_node_or_nil(pos)
	if node and minetest.registered_nodes[node.name] then
		return node
	end
	return minetest.registered_nodes[fallback]
end

mcl_mobs.effect_functions = {}

function mob_class:day_docile()
	if self.docile_by_day == false then
		return false
	elseif self.docile_by_day == true
	and self.time_of_day > 0.2
	and self.time_of_day < 0.8 then
		return true
	end
end

function mob_class:do_attack(player)
	if self.state == "attack" or self.state == "die" then
		return
	end

	self.attack = player
	self:set_state("attack")

	-- TODO: Implement war_cry sound without being annoying
	--if random(0, 100) < 90 then
		--self:mob_sound("war_cry", true)
	--end
end

-- blast damage to entities nearby
local function entity_physics(pos,radius)

	radius = radius * 2

	local objs = minetest.get_objects_inside_radius(pos, radius)
	local obj_pos, dist

	for n = 1, #objs do

		obj_pos = objs[n]:get_pos()

		dist = vector.distance(pos, obj_pos)
		if dist < 1 then dist = 1 end

		local damage = math.floor((4 / dist) * radius)

		-- punches work on entities AND players
		objs[n]:punch(objs[n], 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = damage},
		}, pos)
	end
end

function mob_class:entity_physics(pos,radius) return entity_physics(pos,radius) end

local los_switcher = false
local height_switcher = false

-- path finding and smart mob routine by rnd, line_of_sight and other edits by Elkien3
function mob_class:smart_mobs(s, p, dist, dtime)

	local stepheight = self.object:get_properties().stepheight
	local s1 = self.path.lastpos

	local target_pos = self.attack:get_pos()

	-- is it becoming stuck?
	if math.abs(s1.x - s.x) + math.abs(s1.z - s.z) < .5 then
		self.path.stuck_timer = self.path.stuck_timer + dtime
	else
		self.path.stuck_timer = 0
	end

	self.path.lastpos = {x = s.x, y = s.y, z = s.z}

	local use_pathfind = false
	local has_lineofsight = minetest.line_of_sight(
		{x = s.x, y = (s.y) + .5, z = s.z},
		{x = target_pos.x, y = (target_pos.y) + 1.5, z = target_pos.z}, .2)

	-- im stuck, search for path
	if not has_lineofsight then

		if los_switcher == true then
			use_pathfind = true
			los_switcher = false
		end -- cannot see target!
	else
		if los_switcher == false then

			los_switcher = true
			use_pathfind = false

			minetest.after(1, function(self)
				if not self.object:get_luaentity() then
					return
				end
				if has_lineofsight then self.path.following = false end
			end, self)
		end -- can see target!
	end

	if (self.path.stuck_timer > stuck_timeout and not self.path.following) then

		use_pathfind = true
		self.path.stuck_timer = 0

		minetest.after(1, function(self)
			if not self.object:get_luaentity() then
				return
			end
			if has_lineofsight then self.path.following = false end
		end, self)
	end

	if (self.path.stuck_timer > stuck_path_timeout and self.path.following) then

		use_pathfind = true
		self.path.stuck_timer = 0

		minetest.after(1, function(self)
			if not self.object:get_luaentity() then
				return
			end
			if has_lineofsight then self.path.following = false end
		end, self)
	end

	if math.abs(vector.subtract(s,target_pos).y) > stepheight then

		if height_switcher then
			use_pathfind = true
			height_switcher = false
		end
	else
		if not height_switcher then
			use_pathfind = false
			height_switcher = true
		end
	end

	if use_pathfind then
		-- lets try find a path, first take care of positions
		-- since pathfinder is very sensitive
		-- round position to center of node to avoid stuck in walls
		-- also adjust height for player models!

		s.x = math.floor(s.x + 0.5)
		s.z = math.floor(s.z + 0.5)

		local ssight, sground = minetest.line_of_sight(s, {
			x = s.x, y = s.y - 4, z = s.z}, 1)

		-- determine node above ground
		if not ssight then
			s.y = sground.y + 1
		end

		local p1 = self.attack:get_pos()

		p1.x = math.floor(p1.x + 0.5)
		p1.y = math.floor(p1.y + 0.5)
		p1.z = math.floor(p1.z + 0.5)

		local dropheight = 12
		if self.fear_height ~= 0 then dropheight = self.fear_height end
		local jumpheight = 0
		if self.jump and self.jump_height >= 4 then
			jumpheight = math.min(math.ceil(self.jump_height / 4), 4)
		elseif stepheight > 0.5 then
			jumpheight = 1
		end
		self.path.way = minetest.find_path(s, p1, 16, jumpheight, dropheight, "A*_noprefetch")

		self:set_state("")
		self:do_attack(self.attack)

		-- no path found, try something else
		if not self.path.way then

			self.path.following = false

			 -- lets make way by digging/building if not accessible
			if self.pathfinding == 2 and mobs_griefing then

				-- is player higher than mob?
				if s.y < p1.y then

					-- build upwards
					if not minetest.is_protected(s, "") then

						local ndef1 = minetest.registered_nodes[self.standing_in]

						if ndef1 and (ndef1.buildable_to or ndef1.groups.liquid) then

								minetest.set_node(s, {name = mcl_mobs.fallback_node})
						end
					end
					local props = self.object:get_properties()
					local sheight = math.ceil(props.collisionbox[5]) + 1

					-- assume mob is 2 blocks high so it digs above its head
					s.y = s.y + sheight

					-- remove one block above to make room to jump
					if not minetest.is_protected(s, "") then

						local node1 = node_ok(s, "air").name
						local ndef1 = minetest.registered_nodes[node1]

						if node1 ~= "air"
						and node1 ~= "ignore"
						and ndef1
						and not ndef1.groups.level
						and not ndef1.groups.unbreakable
						and not ndef1.groups.liquid then

							minetest.set_node(s, {name = "air"})
							minetest.add_item(s, ItemStack(node1))

						end
					end

					s.y = s.y - sheight
					self.object:set_pos({x = s.x, y = s.y + 2, z = s.z})

				else -- dig 2 blocks to make door toward player direction

					local yaw1 = self.object:get_yaw() + math.pi / 2
					local p1 = {
						x = s.x + math.cos(yaw1),
						y = s.y,
						z = s.z + math.sin(yaw1)
					}

					if not minetest.is_protected(p1, "") then

						local node1 = node_ok(p1, "air").name
						local ndef1 = minetest.registered_nodes[node1]

						if node1 ~= "air"
							and node1 ~= "ignore"
							and ndef1
							and not ndef1.groups.level
							and not ndef1.groups.unbreakable
							and not ndef1.groups.liquid then

							minetest.add_item(p1, ItemStack(node1))
							minetest.set_node(p1, {name = "air"})
						end

						p1.y = p1.y + 1
						node1 = node_ok(p1, "air").name
						ndef1 = minetest.registered_nodes[node1]

						if node1 ~= "air"
						and node1 ~= "ignore"
						and ndef1
						and not ndef1.groups.level
						and not ndef1.groups.unbreakable
						and not ndef1.groups.liquid then

							minetest.add_item(p1, ItemStack(node1))
							minetest.set_node(p1, {name = "air"})
						end

					end
				end
			end

			-- will try again in 2 seconds
			self.path.stuck_timer = stuck_timeout - 2
		elseif s.y < p1.y and (not self.fly) then
			self:do_jump() --add jump to pathfinding
			self.path.following = true
			-- Yay, I found path!
			-- TODO: Implement war_cry sound without being annoying
			--self:mob_sound("war_cry", true)
		else
			self:set_velocity(self.walk_velocity)

			-- follow path now that it has it
			self.path.following = true
		end
	end
end

function mob_class:attack_players_and_npcs()
	if not damage_enabled or
	self.state == "attack" or
	self.passive or
	self:day_docile() or
	self.type ~= "monster" or
	not self.attack_type
	then return end

	local pos = self.object:get_pos()
	local objs = minetest.get_objects_inside_radius(pos, self.view_range)
	for _,obj in pairs(objs) do
		if self:line_of_sight(pos, obj:get_pos(), 2) then
			local l = obj:get_luaentity()
			if obj:is_player() then
				self:do_attack(obj)
				break
			elseif self.attack_npcs and (l and l.type == "npc") then
				self:do_attack(obj)
				break
			end
		end
	end

	return false
end

function mob_class:attack_specific()
	if not self.specific_attack or
	self.state == "attack" or
	(not self.damage or self.damage == 0) or
	(self.passive and not self.aggro)
	then return end

	local pos = self.object:get_pos()
	local objs = minetest.get_objects_inside_radius(pos, self.view_range)
	for _,obj in pairs(objs) do
		if obj:is_player() and table.indexof(self.specific_attack,"player") and self.aggro then
			self:do_attack(obj)
			break
		end
		local l = obj:get_luaentity()
		if l and l.is_mob then
			if table.indexof(self.specific_attack,l.name) ~= -1 and self:line_of_sight(pos, obj:get_pos(), 2) then
				self:do_attack(obj)
				break
			end
		end
	end
end

function mob_class:attack_monsters()
	if self.type ~= "npc" or self.state == "attack" then return end

	local pos = self.object:get_pos()
	local objs = minetest.get_objects_inside_radius(pos, self.view_range)
	for _,obj in pairs(objs) do
		local l = obj:get_luaentity()
		if l and l.type == "monster" and self:target_visible(pos, obj) then
			self:do_attack(obj)
		end
	end
end

-- dogshoot attack switch and counter function
function mob_class:dogswitch(dtime)

	-- switch mode not activated
	if not self.dogshoot_switch
	or not dtime then
		return 0
	end

	self.dogshoot_count = self.dogshoot_count + dtime

	if (self.dogshoot_switch == 1
	and self.dogshoot_count > self.dogshoot_count_max)
	or (self.dogshoot_switch == 2
	and self.dogshoot_count > self.dogshoot_count2_max) then

		self.dogshoot_count = 0

		if self.dogshoot_switch == 1 then
			self.dogshoot_switch = 2
		else
			self.dogshoot_switch = 1
		end
	end

	return self.dogshoot_switch
end

-- no damage to nodes explosion
function mob_class:safe_boom(pos, strength, no_remove)
	minetest.sound_play(self.sounds and self.sounds.explode or "tnt_explode", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = self.sounds and self.sounds.distance or 32
	}, true)
	local radius = strength
	entity_physics(pos, radius)
	mcl_mobs.effect(pos, 32, "mcl_particles_smoke.png", radius * 3, radius * 5, radius, 1, 0)
	if not no_remove then
		if self.is_mob then
			self:safe_remove()
		else
			self.object:remove()
		end
	end
end


-- make explosion with protection and tnt mod check
function mob_class:boom(pos, strength, fire, no_remove)
	if mobs_griefing and not minetest.is_protected(pos, "") then
		mcl_explosions.explode(pos, strength, { fire = fire }, self.object)
	else
		mcl_mobs.mob_class.safe_boom(self, pos, strength, no_remove) --need to call it this way bc self can be the "arrow" object here
	end
	if not no_remove then
		if self.is_mob then
			self:safe_remove()
		else
			self.object:remove()
		end
	end
end

-- deal damage and effects when mob punched
function mob_class:on_punch(hitter, tflp, tool_capabilities, dir)

	if self.do_punch then
		if self.do_punch(self, hitter, tflp, tool_capabilities, dir) == false then
			return
		end
	end

	-- error checking when mod profiling is enabled
	if not tool_capabilities then
		minetest.log("warning", "[mobs] Mod profiling enabled, damage not enabled")
		return
	end

	local is_player = hitter:is_player()

	if is_player then
		self.last_player_hit_time = minetest.get_gametime()
		self.last_player_hit_name = hitter:get_player_name()
		-- is mob protected?
		if self.protected and minetest.is_protected(self.object:get_pos(), hitter:get_player_name()) then
			return
		end

		if minetest.is_creative_enabled(hitter:get_player_name()) then
			-- Instantly kill mob after a slight delay.
			-- Without this delay the node behind would be dug by the punch as well.
			minetest.after(0.15, function(self)
				if self and self.object and self.object:get_pos() then
					self.health = 0
				end
			end, self)
		end

		-- set/update 'drop xp' timestamp if hitted by player
		self.xp_timestamp = minetest.get_us_time()
	end


	-- punch interval
	local weapon = hitter:get_wielded_item()
	local punch_interval = 1.4

	-- exhaust attacker
	if is_player then
		mcl_hunger.exhaust(hitter:get_player_name(), mcl_hunger.EXHAUST_ATTACK)
	end

	-- calculate mob damage
	local damage = 0
	local armor = self.object:get_armor_groups() or {}
	local tmp

	-- quick error check incase it ends up 0 (serialize.h check test)
	if tflp == 0 then
		tflp = 0.2
	end


	for group,_ in pairs( (tool_capabilities.damage_groups or {}) ) do

		tmp = tflp / (tool_capabilities.full_punch_interval or 1.4)

		if tmp < 0 then
			tmp = 0.0
		elseif tmp > 1 then
			tmp = 1.0
		end

		damage = damage + (tool_capabilities.damage_groups[group] or 0)
			* tmp * ((armor[group] or 0) / 100.0)
	end

	if weapon then
		local fire_aspect_level = mcl_enchanting.get_enchantment(weapon, "fire_aspect")
		if fire_aspect_level > 0 then
			mcl_burning.set_on_fire(self.object, fire_aspect_level * 4)
		end
	end

	-- check for tool immunity or special damage
	for n = 1, #self.immune_to do

		if self.immune_to[n][1] == weapon:get_name() then

			damage = self.immune_to[n][2] or 0
			break
		end
	end

	-- healing
	if damage <= -1 then
		self.health = self.health - math.floor(damage)
		return
	end

	if tool_capabilities then
		punch_interval = tool_capabilities.full_punch_interval or 1.4
	end

	-- add weapon wear manually
	-- Required because we have custom health handling ("health" property)
	if minetest.is_creative_enabled("") ~= true
	and tool_capabilities then
		if tool_capabilities.punch_attack_uses then
			-- Without this delay, the wear does not work. Quite hacky ...
			minetest.after(0, function(name)
				local player = minetest.get_player_by_name(name)
				if not player then return end
				local weapon = hitter:get_wielded_item(player)
				local def = weapon:get_definition()
				if def.tool_capabilities and def.tool_capabilities.punch_attack_uses then
					local wear = math.floor(65535/tool_capabilities.punch_attack_uses)
					weapon:add_wear(wear)
					hitter:set_wielded_item(weapon)
				end
			end, hitter:get_player_name())
		end
	end

	local die = false


	if damage >= 0 then
		-- only play hit sound and show blood effects if damage is 1 or over; lower to 0.1 to ensure armor works appropriately.
		if damage >= 0.1 then
			-- weapon sounds
			if weapon:get_definition().sounds ~= nil then

				local s = math.random(0, #weapon:get_definition().sounds)

				minetest.sound_play(weapon:get_definition().sounds[s], {
					object = self.object, --hitter,
					max_hear_distance = 8
				}, true)
			else
				minetest.sound_play("default_punch", {
					object = self.object,
					max_hear_distance = 5
				}, true)
			end

			self:damage_effect(damage)

			-- do damage
			self.health = self.health - damage

			-- skip future functions if dead, except alerting others
			if self:check_for_death( "hit", {type = "punch", puncher = hitter}) then
				die = true
			end
		end
		-- knock back effect (only on full punch)
		if self.knock_back
		and tflp >= punch_interval then
			-- direction error check
			dir = dir or {x = 0, y = 0, z = 0}

			local v = self.object:get_velocity()
			if not v then return end
			local r = 1.4 - math.min(punch_interval, 1.4)
			local kb = r * (math.abs(v.x)+math.abs(v.z))
			local up = 2

			if die==true then
				kb=kb*2
			end

			-- if already in air then dont go up anymore when hit
			if math.abs(v.y) > 0.1
			or self.fly then
				up = 0
			end


			-- check if tool already has specific knockback value
			if tool_capabilities.damage_groups["knockback"] then
				kb = tool_capabilities.damage_groups["knockback"]
			else
				kb = kb * 1.5
			end


			local luaentity
			if hitter then
				luaentity = hitter:get_luaentity()
			end
			if hitter and is_player then
				local wielditem = hitter:get_wielded_item()
				kb = kb + 3 * mcl_enchanting.get_enchantment(wielditem, "knockback")
			elseif luaentity and luaentity._knockback then
				kb = kb + luaentity._knockback
			end
			self._kb_turn = true
			self._turn_to=self.object:get_yaw()-1.57
			self.frame_speed_multiplier=2.3
			if self.animation.run_end then
				self:set_animation( "run")
			elseif self.animation.walk_end then
				self:set_animation( "walk")
			end
			minetest.after(0.2, function()
				if self and self.object then
					self.frame_speed_multiplier=1
					self._kb_turn = false
				end
			end)
			self.object:add_velocity({
				x = dir.x * kb,
				y = up*2,
				z = dir.z * kb
			})

			self.pause_timer = 0.25
		end
	end -- END if damage

	-- if skittish then run away
	if hitter and is_player and hitter:get_pos() and not die and self.runaway == true and self.state ~= "flop" then

		self:set_yaw( minetest.dir_to_yaw(vector.direction(hitter:get_pos(), self.object:get_pos())))
		minetest.after(0.2,function()
			if self and self.object and self.object:get_pos() and hitter and is_player and hitter:get_pos() then
				self:set_yaw( minetest.dir_to_yaw(vector.direction(hitter:get_pos(), self.object:get_pos())))
				self:set_velocity( self.run_velocity)
			end
		end)
		self:set_state("runaway")
		self.runaway_timer = 0
		self.following = nil
	end

	local name = hitter:get_player_name() or ""

	-- attack puncher
	if ( self.passive == false or self.retaliates )
	and self.state ~= "flop"
	and (self.child == false or self.type == "monster")
	and hitter:get_player_name() ~= self.owner
	and not mcl_mobs.invis[ name ] then
		if not die then
			-- attack whoever punched mob
			self:set_state("")
			self:do_attack(hitter)
			self.aggro = true
		end
	end

	-- alert others to the attack
	local objs = minetest.get_objects_inside_radius(hitter:get_pos(), self.view_range)
	local obj

	for n = 1, #objs do

		obj = objs[n]:get_luaentity()

		if obj then
			-- only alert members of same mob or friends
			if obj.group_attack
			and obj.state ~= "attack"
			and obj.owner ~= name then
				if obj.name == self.name then
					obj:do_attack(hitter)
				elseif type(obj.group_attack) == "table" then
					for i=1, #obj.group_attack do
						if obj.group_attack[i] == self.name then
							obj.aggro = true
							obj:do_attack(hitter)
							break
						end
					end
				end
			end

			-- have owned mobs attack player threat
			if obj.owner == name and obj.owner_loyal then
				obj:do_attack(self.object)
			end
		end
	end
end

function mob_class:check_aggro(dtime)
	if not self.aggro or not self.attack then return end
	if not self._check_aggro_timer or self._check_aggro_timer > 5 then
		self._check_aggro_timer = 0
		if not self.attack:get_pos() or vector.distance(self.attack:get_pos(),self.object:get_pos()) > 128 then
			self.aggro = nil
			self.attack = nil
			self:set_state("stand")
		end
	end
	self._check_aggro_timer = self._check_aggro_timer + dtime
end



function mob_class:clear_aggro()
	self:set_state("stand")
	self:set_velocity( 0)
	self:set_animation( "stand")

	self.attack = nil
	self.aggro = nil

	self.v_start = false
	self.timer = 0
	self.blinktimer = 0
	self.path.way = nil
end

function mob_class:do_states_attack (dtime)
	local yaw
	local attacked
	local s = self.object:get_pos()
	local p = self.attack:get_pos() or s

	-- stop attacking if player invisible or out of range
	if not self.attack
			or not self.attack:get_pos()
			or not self:object_in_range(self.attack)
			or self.attack:get_hp() <= 0
			or (self.attack:is_player() and mcl_mobs.invis[ self.attack:get_player_name() ]) then

		self:clear_aggro()
		return
	end

	local target_line_of_sight = self:target_visible(s)

	if not target_line_of_sight then
		if self.target_time_lost then
			local time_since_seen = os.time() - self.target_time_lost
			if time_since_seen > TIME_TO_FORGET_TARGET then
				self.target_time_lost = nil
				self:clear_aggro()
				return
			end
		else
			self.target_time_lost = os.time()
		end
	else
		self.target_time_lost = nil
	end

	-- calculate distance from mob and enemy
	local dist = vector.distance(p, s)

	if self.attack_type == "explode" then

		if target_line_of_sight then
			local vec = { x = p.x - s.x, z = p.z - s.z }
			local yaw = (atan(vec.z / vec.x) +math.pi/ 2) - self.rotate
			if p.x > s.x then yaw = yaw +math.pi end
			self:set_yaw( yaw, 0, dtime)
		end

		local node_break_radius = self.explosion_radius or 1
		local entity_damage_radius = self.explosion_damage_radius
				or (node_break_radius * 2)

		-- start timer when in reach and line of sight
		if not self.v_start and dist <= self.reach and target_line_of_sight then
			self.v_start = true
			self.timer = 0
			self.blinktimer = 0
			self:mob_sound("fuse", nil, false)

			-- stop timer if out of reach or direct line of sight
		elseif self.allow_fuse_reset and self.v_start
				and (dist >= self.explosiontimer_reset_radius or not target_line_of_sight) then
			self.v_start = false
			self.timer = 0
			self.blinktimer = 0
			self.blinkstatus = false
			self:remove_texture_mod("^[brighten")
		end

		-- walk right up to player unless the timer is active
		if self.v_start and (self.stop_to_explode or dist < self.reach) or not target_line_of_sight then
			self:set_velocity(0)
		else
			self:set_velocity(self.run_velocity)
		end

		if self.animation and self.animation.run_start then
			self:set_animation( "run")
		else
			self:set_animation( "walk")
		end

		if self.v_start then
			self.timer = self.timer + dtime
			self.blinktimer = (self.blinktimer or 0) + dtime

			if self.blinktimer > 0.2 then
				self.blinktimer = 0
				if self.blinkstatus then
					self:remove_texture_mod("^[brighten")
				else
					self:add_texture_mod("^[brighten")
				end
				self.blinkstatus = not self.blinkstatus
			end

			if self.timer > self.explosion_timer then
				local pos = self.object:get_pos()

				if mobs_griefing and not minetest.is_protected(pos, "") then
					mcl_explosions.explode(mcl_util.get_object_center(self.object), self.explosion_strength, {}, self.object)
				else
					minetest.sound_play(self.sounds.explode, {
						pos = pos,
						gain = 1.0,
						max_hear_distance = self.sounds.distance or 32
					}, true)
					self:entity_physics(pos,entity_damage_radius)
					mcl_mobs.effect(pos, 32, "mcl_particles_smoke.png", nil, nil, node_break_radius, 1, 0)
				end

				if self.on_attack then
					self:on_attack(dtime)
				end
				self:safe_remove()

				return true
			end
		end

	elseif self.attack_type == "dogfight"
			or (self.attack_type == "dogshoot" and self:dogswitch(dtime) == 2) and (dist >= self.avoid_distance or not self.shooter_avoid_enemy)
			or (self.attack_type == "dogshoot" and dist <= self.reach and self:dogswitch() == 0) then

		if self.fly
				and dist > self.reach then

			local p1 = s
			local me_y = math.floor(p1.y)
			local p2 = p
			local p_y = math.floor(p2.y + 1)
			local v = self.object:get_velocity()

			if self:flight_check( s) then

				if me_y < p_y then

					self.object:set_velocity({
						x = v.x,
						y = 1 * self.walk_velocity,
						z = v.z
					})

				elseif me_y > p_y then

					self.object:set_velocity({
						x = v.x,
						y = -1 * self.walk_velocity,
						z = v.z
					})
				end
			else
				if me_y < p_y then

					self.object:set_velocity({
						x = v.x,
						y = 0.01,
						z = v.z
					})

				elseif me_y > p_y then

					self.object:set_velocity({
						x = v.x,
						y = -0.01,
						z = v.z
					})
				end
			end

		end

		-- rnd: new movement direction
		if self.path.following
				and self.path.way
				and self.attack_type ~= "dogshoot" then

			-- no paths longer than 50
			if #self.path.way > 50
					or dist < self.reach then
				self.path.following = false
				return
			end

			local p1 = self.path.way[1]

			if not p1 then
				self.path.following = false
				return
			end

			if math.abs(p1.x-s.x) + math.abs(p1.z - s.z) < 0.6 then
				-- reached waypoint, remove it from queue
				table.remove(self.path.way, 1)
			end

			-- set new temporary target
			p = {x = p1.x, y = p1.y, z = p1.z}
		end

		local vec = {
			x = p.x - s.x,
			z = p.z - s.z
		}

		yaw = (atan(vec.z / vec.x) + math.pi / 2) - self.rotate

		if p.x > s.x then yaw = yaw + math.pi end

		self:set_yaw( yaw, 0, dtime)

		-- move towards enemy if beyond mob reach
		if dist > self.reach then

			-- path finding by rnd
			if self.pathfinding -- only if mob has pathfinding enabled
					and enable_pathfinding then

				self:smart_mobs(s, p, dist, dtime)
			end

			if self:is_at_cliff_or_danger() then

				self:set_velocity( 0)
				self:set_animation( "stand")
				local yaw = self.object:get_yaw() or 0
				self:set_yaw( yaw + 0.78, 8)
			else

				if self.path.stuck then
					self:set_velocity( self.walk_velocity)
				else
					self:set_velocity( self.run_velocity)
				end

				if self.animation and self.animation.run_start then
					self:set_animation( "run")
				else
					self:set_animation( "walk")
				end
			end

		else -- rnd: if inside reach range

			self.path.stuck = false
			self.path.stuck_timer = 0
			self.path.following = false -- not stuck anymore

			self:set_velocity( 0)

			if not self.custom_attack then

				if self.timer > self.dogfight_interval then

					self.timer = 0

					if self.double_melee_attack
							and math.random(1, 2) == 1 then
						self:set_animation( "punch2")
					else
						self:set_animation( "punch")
					end

					if self:target_visible(self.object:get_pos()) then
						-- play attack sound
						self:mob_sound("attack")

						-- punch player (or what player is attached to)
						local attached = self.attack:get_attach()
						if attached then
							self.attack = attached
						end
						self.attack:punch(self.object, 1.0, {
							full_punch_interval = 1.0,
							damage_groups = {fleshy = self.damage}
						}, nil)
						if self.dealt_effect then
							mcl_mobs.effect_functions[self.dealt_effect.name](
								self.attack, self.dealt_effect.factor, self.dealt_effect.dur
							)
						end
						attacked = true
					end
				end
			else	-- call custom attack every second
				if self.custom_attack
						and self.timer > self.custom_attack_interval then

					self.timer = 0

					self:custom_attack(p)
					attacked = true
				end
			end
		end

	elseif self.attack_type == "shoot"
			or (self.attack_type == "dogshoot" and self:dogswitch(dtime) == 1)
			or (self.attack_type == "dogshoot" and (dist > self.reach or dist < self.avoid_distance and self.shooter_avoid_enemy) and self:dogswitch() == 0) then

		p.y = p.y - .5
		s.y = s.y + .5

		local dist = vector.distance(p, s)
		local vec = {
			x = p.x - s.x,
			y = p.y - s.y,
			z = p.z - s.z
		}

		yaw = (atan(vec.z / vec.x) +math.pi/ 2) - self.rotate

		if p.x > s.x then yaw = yaw +math.pi end

		self:set_yaw( yaw, 0, dtime)

		local stay_away_from_player = vector.new(0,0,0)

		--strafe back and fourth

		--stay away from player so as to shoot them
		if dist < self.avoid_distance and self.shooter_avoid_enemy then
			self:set_animation( "shoot")
			stay_away_from_player=vector.multiply(vector.direction(p, s), 0.33)
		end

		if self.strafes then
			if not self.strafe_direction then
				self.strafe_direction = 1.57
			end
			if math.random(40) == 1 then
				self.strafe_direction = self.strafe_direction*-1
			end
			self.acc = vector.add(vector.multiply(vector.rotate_around_axis(vector.direction(s, p), vector.new(0,1,0), self.strafe_direction), 0.3*self.walk_velocity), stay_away_from_player)
		else
			self:set_velocity( 0)
		end

		local p = self.object:get_pos()
		local props = self.object:get_properties()
		p.y = p.y + (props.collisionbox[2] + props.collisionbox[5]) / 2

		if self.shoot_interval
				and self.timer > self.shoot_interval
				and not minetest.raycast(vector.add(p, vector.new(0,self.shoot_offset,0)), vector.add(self.attack:get_pos(), vector.new(0,1.5,0)), false, false):next()
				and math.random(1, 100) <= 60 then

			self.timer = 0
			self:set_animation( "shoot")

			-- play shoot attack sound
			self:mob_sound("shoot_attack")

			-- Shoot arrow
			if minetest.registered_entities[self.arrow] then

				local arrow, ent
				local v = 1
				if not self.shoot_arrow then
					self.firing = true
					minetest.after(1, function()
						self.firing = false
					end)
					arrow = minetest.add_entity(p, self.arrow)
					ent = arrow:get_luaentity()
					if ent.velocity then
						v = ent.velocity
					end
					ent.switch = 1
					ent.owner_id = tostring(self.object) -- add unique owner id to arrow

					-- important for mcl_shields
					ent._shooter = self.object
					ent._saved_shooter_pos = self.object:get_pos()
					if ent.homing then
						ent._target = self.attack
					end
				end

				local amount = (vec.x * vec.x + vec.y * vec.y + vec.z * vec.z) ^ 0.5
				-- offset makes shoot aim accurate
				vec.y = vec.y + self.shoot_offset
				vec.x = vec.x * (v / amount)
				vec.y = vec.y * (v / amount)
				vec.z = vec.z * (v / amount)
				if self.shoot_arrow then
					vec = vector.normalize(vec)
					self:shoot_arrow(p, vec)
				else
					arrow:set_velocity(vec)
				end
				attacked = true
			end
		end
	elseif self.attack_type == "custom" and self.attack_state then
		self:attack_state(dtime)
		attacked = true
	end
	if attacked and self.on_attack then
		self:on_attack(dtime)
	end
end
