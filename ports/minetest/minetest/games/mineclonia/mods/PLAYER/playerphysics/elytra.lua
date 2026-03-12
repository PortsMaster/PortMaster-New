local S = core.get_translator(core.get_current_modname())

local gravity = -1.6

local ONE_TICK			= 0.05

local AIR_DRAG = 0.98
local FALL_FLYING_DRAG_HORIZ	= 0.99
local FALL_FLYING_DRAG_ASCENT	= 0.04
local FALL_FLYING_ACC_DESCENT	= 3.2
local FALL_FLYING_ROTATION_DRAG = 0.1

local BASE_ROCKET_BOOST = 2.0
local ROCKET_BOOST_FORCE = 30.0

local elytra_entity = {
	initial_properties = {
		visual = "mesh",
		mesh = "mcl_elytra_entity.obj",
		textures = { "blank.png" },
		visual_size = {x=1.0, y=1.0},
		collisionbox = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},
		pointable = false,
		physical = true,
		collide_with_objects = false,
		static_save = false,
	},
	_horiz_collision = false,
	_damage_immune = 0,
	_timer = 0,
	_last_fall_y = nil,
	_fall_distance = 0,
	_safe_fall_distance = 3.0,
}

local function horiz_collision (moveresult)
	for _, item in ipairs (moveresult.collisions) do
		if item.axis == "x" or item.axis == "z" then
			-- Exclude ignore nodes from collision detection.
			if item.type ~= "node"
				or core.get_node_or_nil (item.node_pos) then
				return true, item.old_velocity, item.new_velocity
			end
		end
	end
	return false, nil
end

function elytra_entity:rotate()
	local player = self.driver
	local pitch = -player:get_look_vertical()
	local yaw = player:get_look_horizontal()
	local rot = vector.new(pitch, yaw, 0)
	self.object:set_rotation (rot)
end

function elytra_entity:attach(player)
	local player_v = player:get_velocity()
	mcl_player.players[player].elytra.active = true
	self.object:set_velocity(player_v)
	player:set_attach (self.object, "", vector.zero(), vector.zero())
	self.driver = player
end

function elytra_entity:remove(player)
	local elytra = mcl_player.players[player].elytra
	mcl_player.players[player].elytra.active = false
	elytra.rocketing = 0
	self.object:remove()
end

function elytra_entity:detach(player)
	local v = self.object:get_velocity ()
	if v then
		player:add_velocity (v)
	end
	self:remove (player)
	player:set_detach ()
end

function elytra_entity:check_horiz_collision(moveresult)
	local player = self.driver
	local elytra = mcl_player.players[player].elytra
	local damage_immune = math.max (self._damage_immune - 1, 0)
	self._damage_immune = damage_immune

	local old, new
	if not self._horiz_collision then
		self._horiz_collision, old, new = horiz_collision (moveresult)
	end

	-- Apply "kinetic damage" when the player collides
	-- with a wall while fall flying.
	if elytra.active and self._horiz_collision then
		if old and new then
			local diff = math.abs (vector.length (old) - vector.length (new))
			if diff >= 6.0 and self._damage_immune == 0 then
				mcl_damage.damage_player (player, diff * 0.5, {
					type = "fly_into_wall",
				})
				self._damage_immune = 10
			end
		end
	end
end

function elytra_entity:rocket_boost(dtime)
	local player = self.driver
	local elytra = mcl_player.players[player].elytra
	local dir = player:get_look_dir()
	local self_pos = player:get_pos()
	local v = self.object:get_velocity()

	if elytra.rocketing > 0 then
		v.x = dir.x * BASE_ROCKET_BOOST
			+ (dir.x * ROCKET_BOOST_FORCE - v.x) * 0.5
			+ v.x
		v.y = dir.y * BASE_ROCKET_BOOST
			+ (dir.y * ROCKET_BOOST_FORCE - v.y) * 0.5
			+ v.y
		v.z = dir.z * BASE_ROCKET_BOOST
			+ (dir.z * ROCKET_BOOST_FORCE - v.z) * 0.5
			+ v.z
		elytra.rocketing = elytra.rocketing - dtime
		local dir = vector.new (dir.x, 0, dir.z)
		local pos = vector.normalize (dir)
		local s = pos.x
		local c = pos.z
		pos.x = self_pos.x + (c * 0.5 + s * 0.7)
		pos.y = self_pos.y + 0.3
		pos.z = self_pos.z + (c * 0.7 - s * 0.5)
		core.add_particle ({
			pos = pos,
			expirationtime = 1.0,
			texture = "mcl_bows_rocket_particle.png^[colorize:#bc7a57:127",
		})
	end

	self.object:set_velocity(v)
end

function elytra_entity:riptide_boost(dtime)
	local player = self.driver
	local elytra = mcl_player.players[player].elytra
	local dir = player:get_look_dir()
	local self_pos = player:get_pos()
	local v = self.object:get_velocity()

	local item = player:get_wielded_item ()
	local riptide = mcl_enchanting.get_enchantment (item, "riptide")

	if elytra.riptide > 0 then
		v.x = dir.x * BASE_ROCKET_BOOST
			+ (dir.x * ROCKET_BOOST_FORCE * riptide - v.x) * 0.5
			+ v.x
		v.y = dir.y * BASE_ROCKET_BOOST
			+ (dir.y * ROCKET_BOOST_FORCE * riptide - v.y) * 0.5
			+ v.y
		v.z = dir.z * BASE_ROCKET_BOOST
			+ (dir.z * ROCKET_BOOST_FORCE * riptide - v.z) * 0.5
			+ v.z
		elytra.riptide = elytra.riptide - dtime
		local dir = vector.new (dir.x, 0, dir.z)
		local pos = vector.normalize (dir)
		local s = pos.x
		local c = pos.z
		pos.x = self_pos.x + (c * 0.5 + s * 0.7)
		pos.y = self_pos.y + 0.3
		pos.z = self_pos.z + (c * 0.7 - s * 0.5)
	end

	self.object:set_velocity(v)
end

function elytra_entity:consume_durability(dtime)
	self._timer = self._timer + dtime
	if self._timer >= 1.0 then
		local player = self.driver
		if core.is_creative_enabled (player:get_player_name ()) then
			return
		end
		local inv = mcl_util.get_inventory(player)
		local itemstack = inv:get_stack("armor", 3)
		local durability = mcl_util.calculate_durability (itemstack)
		local remaining = math.floor ((65536 - itemstack:get_wear ())
			* durability / 65536)

		if remaining == 1 then
			self:detach(player)
			mcl_armor.disable_elytra (itemstack)
		else
			mcl_util.use_item_durability(itemstack, 1)
			inv:set_stack("armor", 3, itemstack)
		end

		self._timer = self._timer - 1.0
	end
end

function elytra_entity:step_fall_flying (dtime)
	local player = self.driver
	local v = self.object:get_velocity()
	if not v then
		-- The object was unloaded??
		self:detach (player)
		return
	end

	local inv = mcl_util.get_inventory(player)
	local itemstack = inv:get_stack("armor", 3)
	local armor_name = itemstack:get_name()

	if core.get_item_group(armor_name, "elytra") <= 0 then
		self:detach(player)
	end

	-- Limit fall_distance to 1.0 if vertical velocity is
	-- less than -0.5 n/tick.
	if v.y > -10.0 and self._fall_distance > 1.0 then
		self._fall_distance = 1.0
	end

	local dir = player:get_look_dir()
	local pitch = player:get_look_vertical()
	local horiz = math.sqrt (dir.x * dir.x + dir.z * dir.z)
	local movement = math.sqrt (v.x * v.x + v.z * v.z)
	local incline = math.cos (pitch)
	local v_movement = incline * incline

	-- Vy(n) = (Vy(n - 1) + a) + (Vy(n - 1) + a) * (b * c)
	-- a = -gravity * (-1.0 + v_movement * 0.75)
	-- b = ONE_TICK * -0.1 * v_movement * TICK_TO_SEC
	-- c = (Vy(n - 1) + a) * D
	-- c = (aD((D ^ n) - 1) / (D-1)) + Vy(last)D^(n)
	-- n = dtime / ONE_TICK
	--
	-- Vy(n) = a(b + 1)D((((b + 1)D) ^ n) - 1) / bD + D - 1 + Vy(last)((b + 1)D) ^ n-1

	local D = AIR_DRAG
	local default_b = -0.1 * v_movement
	local a = -gravity * (-1.0 + v_movement * 0.75)
	local n = dtime / ONE_TICK
	local c = v.y * D ^ (n) + (a * D * ((D ^ n) - 1)) / (D - 1)
	local b = (c < 0.0 and horiz > 0.0) and default_b or 0
	local a_factor = ((b + 1) * D * ((((b + 1) * D) ^ n) - 1)) / (b * D + D - 1)
	v.y = v.y * (((b + 1) * D) ^ (n)) + a * a_factor

	local D = FALL_FLYING_DRAG_HORIZ
	local h_factor = (D * ((D ^ n) - 1)) / (D - 1)

	-- Accelerate if moving downward.
	if c < 0.0 and horiz > 0.0 then
		-- Vx(n) = (Vx(n) + d) * D
		-- d = c / horiz * b * dir.x
		-- Vx(n) = (dD((D ^ n) - 1) / (D-1)) + Vx(last)D^(n)

		local d = (dir.x * (default_b * c) / horiz)
		local e = (dir.z * (default_b * c) / horiz)
		v.x = v.x * (D ^ (n)) + (d * h_factor)
		v.z = v.z * (D ^ (n)) + (e * h_factor)
	end
	-- Arrest horizontal movement when moving upward.
	if horiz > 0.0 and pitch < 0.0 then
		local arrest = movement * -math.sin (pitch)
			* FALL_FLYING_DRAG_ASCENT
		v.x = v.x + -dir.x * arrest / horiz * h_factor
		v.y = v.y + arrest * FALL_FLYING_ACC_DESCENT * a_factor
		v.z = v.z + -dir.z * arrest / horiz * h_factor
	end
	-- Apply rotation penalties.
	if horiz > 0.0 then
		v.x = v.x + (dir.x / horiz * movement - v.x)
			* FALL_FLYING_ROTATION_DRAG * h_factor
		v.z = v.z + (dir.z / horiz * movement - v.z)
			* FALL_FLYING_ROTATION_DRAG * h_factor
	end

	self.object:set_velocity(v)
end

function elytra_entity:underwater()
	local player = self.driver
	local fly_pos = player:get_pos()
	local fly_node = core.get_node(vector.offset(fly_pos,0,-0.1,0)).name
	local def = core.registered_nodes[fly_node]
	local liquid_type = def and (def.liquidtype or def._liquidtype)

	if liquid_type and liquid_type ~= "none" then
		self:detach (player)
		return true
	end
	return false
end

local cid_ignore = core.CONTENT_IGNORE

local function touching_only_ignore (moveresult)
	for _, item in pairs (moveresult.collisions) do
		if item.axis == "y" and item.old_velocity.y < 0 then
			if item.type ~= "node" then
				return false
			else
				local cid, _, _ = core.get_node_raw (item.node_pos.x,
								     item.node_pos.y,
								     item.node_pos.z)
				if cid ~= cid_ignore then
					return false
				end
			end
		end
	end
	return true
end

function elytra_entity:check_fall_damage (moveresult)
	local self_pos = self.object:get_pos ()
	if not self_pos then return end
	local fall_y = self._last_fall_y or self_pos.y
	local d = self._fall_distance + (fall_y - self_pos.y)
	self._fall_distance = math.max (d, 0)
	self._last_fall_y = self_pos.y

	if moveresult.touching_ground
		and not touching_only_ignore (moveresult) then
		local distance = self._fall_distance
		if distance > self._safe_fall_distance then
			local damage = {
				type = "fall",
			}
			if self.driver:is_valid () then
				local amt = self._fall_distance
				mcl_damage.damage_player (self.driver, amt, damage)
			end
		end
		self._last_fall_y = nil
		self._fall_distance = 0
	end
end

function elytra_entity:on_step(dtime, moveresult)
	if not self.driver or not moveresult then
		return
	end

	self:consume_durability(dtime)
	self:check_horiz_collision(moveresult)
	if not self:underwater () then
		self:rotate ()
		self:check_fall_damage (moveresult)
		self:step_fall_flying (dtime)
		self:rocket_boost (dtime)
		self:riptide_boost (dtime)
	end

	local attach = self.driver:get_attach()
	if attach and attach:get_luaentity()
		and attach:get_luaentity().name ~= "mcl_armor:elytra_entity" then
		self:remove(self.driver)
	end

	if moveresult and moveresult.touching_ground then
		self:detach(self.driver)
	end
end

core.register_entity(":mcl_armor:elytra_entity", elytra_entity)

local function attach_elytra (player, itemstack, self_pos)
	if itemstack then
		local durability = mcl_util.calculate_durability (itemstack)
		local remaining = math.floor ((65536 - itemstack:get_wear ())
			* durability / 65536)
		if remaining <= 1 then
			mcl_title.set(player, "actionbar", { text = S("Elytra is already broken."), color = "white", stay = 30 })
			return
		end
	end
	local obj = core.add_entity(self_pos, "mcl_armor:elytra_entity")
	local ent = obj:get_luaentity()
	if obj and ent then
		player:set_pos(vector.offset(self_pos,0,1,0))
		ent:attach(player)
	end
end

core.register_chatcommand ("attach_elytra", {
	privs = { server = true },
	func = function (name, _)
		local player = core.get_player_by_name (name);
		if player then
			player:set_look_vertical (math.rad (21.0))
			player:set_look_horizontal (0)
			attach_elytra (player, nil, player:get_pos ())
		end
	end,
})

local jump_counters = {}
local jump_min_interval = 0.1

mcl_player.register_globalstep(function (player)
	if mcl_serverplayer.is_csm_capable (player) then
		return
	end
	local self_pos = player:get_pos()
	local inv = mcl_util.get_inventory(player)
	local itemstack = inv:get_stack("armor", 3)
	local armor_name = itemstack:get_name()

	local elytra = mcl_player.players[player].elytra

	if elytra.active then
		return
	end

	local fly_pos = player:get_pos()
	local fly_node = core.get_node(vector.offset(fly_pos,0,-0.1,0)).name
	local fly_node_walkable = core.registered_nodes[fly_node]
		and core.registered_nodes[fly_node].walkable

	local timestamp = core.get_us_time()
	if player:get_velocity().y == 0 then
		jump_counters[player] = nil
	elseif player:get_player_control().jump
			and not mcl_player.players[player].is_pressing_jump
			and (not jump_counters[player] or  timestamp - jump_counters[player].last_jump > jump_min_interval) then

		jump_counters[player] = jump_counters[player] or {count = 0, last_jump = 0}
		jump_counters[player].count = jump_counters[player].count + 1
		jump_counters[player].last_jump = timestamp
	end

	local can_fly = core.get_item_group(armor_name, "elytra") > 0
		and not player:get_attach()
		and ((jump_counters[player] and jump_counters[player].count) or 0) >= 2
		and ((not fly_node_walkable) or fly_node == "ignore")

	mcl_player.players[player].is_pressing_jump = player:get_player_control().jump

	if can_fly then
		attach_elytra (player, itemstack, self_pos)
		jump_counters[player] = nil
	end
end)
