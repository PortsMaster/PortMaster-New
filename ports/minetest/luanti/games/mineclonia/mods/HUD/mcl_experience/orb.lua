local size_min, size_max = 20, 59
local delta_size = size_max - size_min

local size_to_xp = {
	{-32768,     2}, --  1
	{     3,     6}, --  2
	{     7,    16}, --  3
	{    17,    36}, --  4
	{    37,    72}, --  5
	{    73,   148}, --  6
	{   149,   306}, --  7
	{   307,   616}, --  8
	{   617,  1236}, --  9
	{  1237,  2476}, -- 10
	{  2477, 32767}  -- 11
}

local function xp_to_size(xp)
	if not xp then return 1 end
	local i, l = 1, #size_to_xp

	while xp > size_to_xp[i][1] and i < l do
		i = i + 1
	end

	return ((i - 1) / (l - 1) * delta_size + size_min) / 100
end

local max_orb_age = 300 -- seconds
local gravity = vector.new(0, -((tonumber(core.settings:get("movement_gravity"))) or 9.81), 0)

local collector, pos, pos2
local direction, distance, player_velocity, goal
local currentvel, acceleration, multiplier, velocity
local node, vel, def
local is_moving, is_slippery, slippery, slip_factor
local size
local function xp_step(self, dtime)
	--if item set to be collected then only execute go to player
	if self.collected == true then
		if not self.collector then
			self.collected = false
			return
		end
		collector = core.get_player_by_name(self.collector)
		if collector and collector:get_hp() > 0 and vector.distance(self.object:get_pos(),collector:get_pos()) < 7.25 then
			self.object:set_acceleration(vector.new(0,0,0))
			self.disable_physics(self)
			--get the variables
			pos = self.object:get_pos()
			pos2 = collector:get_pos()

			player_velocity = collector:get_velocity() or collector:get_player_velocity()

			pos2.y = pos2.y + 0.8

			direction = vector.direction(pos,pos2)
			distance = vector.distance(pos2,pos)
			multiplier = distance
			if multiplier < 1 then
				multiplier = 1
			end
			goal = vector.multiply(direction,multiplier)
			currentvel = self.object:get_velocity()

			if distance > 1 then
				multiplier = 20 - distance
				velocity = vector.multiply(direction,multiplier)
				goal = velocity
				acceleration = vector.new(goal.x-currentvel.x,goal.y-currentvel.y,goal.z-currentvel.z)
				self.object:add_velocity(vector.add(acceleration,player_velocity))
			elseif distance < 0.8 then
				mcl_experience.add_xp(collector, self._xp)
				self.object:remove()
			end
			return
		else
			self.collector = nil
			self.enable_physics(self)
		end
	end


	self.age = self.age + dtime
	if self.age > max_orb_age then
		self.object:remove()
		return
	end

	pos = self.object:get_pos()

	if pos then
		node = core.get_node_or_nil({
			x = pos.x,
			y = pos.y -0.25,
			z = pos.z
		})
	else
		return
	end

	-- Remove nodes in 'ignore'
	if node and node.name == "ignore" then
		self.object:remove()
		return
	end

	if not self.physical_state then
		return -- Don't do anything
	end

	-- Slide on slippery nodes
	vel = self.object:get_velocity()
	def = node and core.registered_nodes[node.name]
	is_moving = (def and not def.walkable) or
		vel.x ~= 0 or vel.y ~= 0 or vel.z ~= 0
	is_slippery = false

	if def and def.walkable then
		slippery = core.get_item_group(node.name, "slippery")
		is_slippery = slippery ~= 0
		if is_slippery and (math.abs(vel.x) > 0.2 or math.abs(vel.z) > 0.2) then
			-- Horizontal deceleration
			slip_factor = 4.0 / (slippery + 4)
			self.object:set_acceleration({
				x = -vel.x * slip_factor,
				y = 0,
				z = -vel.z * slip_factor
			})
		elseif vel.y == 0 then
			is_moving = false
		end
	end

	if self.moving_state == is_moving and self.slippery_state == is_slippery then
		-- Do not update anything until the moving state changes
		return
	end

	self.moving_state = is_moving
	self.slippery_state = is_slippery

	if is_moving then
		self.object:set_acceleration(gravity)
	else
		self.object:set_acceleration({x = 0, y = 0, z = 0})
		self.object:set_velocity({x = 0, y = 0, z = 0})
	end
end

core.register_entity("mcl_experience:orb", {
	initial_properties = {
		hp_max = 1,
		physical = true,
		collide_with_objects = false,
		collisionbox = {-0.2, -0.2, -0.2, 0.2, 0.2, 0.2},
		visual = "sprite",
		visual_size = {x = 0.4, y = 0.4},
		textures = {"mcl_experience_orb.png"},
		spritediv = {x = 1, y = 14},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = true,
		pointable = false,
		static_save = false,
	},
	moving_state = true,
	slippery_state = false,
	physical_state = true,
	-- Item expiry
	age = 0,
	-- Pushing item out of solid nodes
	force_out = nil,
	force_out_start = nil,
	--Collection Variables
	collectable = false,
	try_timer = 0,
	collected = false,
	delete_timer = 0,
	radius = 4,


	on_activate = function(self, staticdata)
		self.object:set_velocity(vector.new(
			math.random(-2,2)*math.random(),
			math.random(2,5),
			math.random(-2,2)*math.random()
		))
		self.object:set_armor_groups({immortal = 1})
		self.object:set_velocity({x = 0, y = 2, z = 0})
		self.object:set_acceleration(gravity)
		local xp = tonumber(staticdata) or 0 --assign 0 xp in case the entity was persisted even though it should not have been (static_save = false) this was a minetest bug for a while: https://github.com/minetest/minetest/issues/14420
		self._xp = xp
		size = xp_to_size(xp)
		self.object:set_properties({
			visual_size = {x = size, y = size},
			glow = 14,
		})
		self.object:set_sprite({x=1,y=math.random(1,14)}, 14, 0.05, false)
	end,

	enable_physics = function(self)
		if not self.physical_state then
			self.physical_state = true
			self.object:set_properties({physical = true})
			self.object:set_velocity({x=0, y=0, z=0})
			self.object:set_acceleration(gravity)
		end
	end,

	disable_physics = function(self)
		if self.physical_state then
			self.physical_state = false
			self.object:set_properties({physical = false})
			self.object:set_velocity({x=0, y=0, z=0})
			self.object:set_acceleration({x=0, y=0, z=0})
		end
	end,
	on_step = function(self, dtime)
		xp_step(self, dtime)
	end,
})
