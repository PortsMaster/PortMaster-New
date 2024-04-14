--MCmobs v0.2
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### SHULKER
--###################

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,1,0),
	vector.new(0,-1,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}
local function check_spot(pos)
	pos = vector.offset(pos,0,0.5,0)
	local n = minetest.get_node(pos)
	if n.name ~="air" then return false end
	for _,a in pairs(adjacents) do
		local p = vector.add(pos,a)
		local pn = minetest.get_node(p)
		if minetest.get_item_group(pn.name,"solid") > 0 then return true end
	end
	return false
end
local pr = PseudoRandom(os.time()*(-334))

local messy_textures = {
	grey = "mobs_mc_shulker_gray.png",
}

-- animation 45-80 is transition between passive and attack stance
mcl_mobs.register_mob("mobs_mc:shulker", {
	description = S("Shulker"),
	type = "monster",
	spawn_class = "hostile",
	attack_type = "shoot",
	shoot_interval = 5.5,
	arrow = "mobs_mc:shulkerbullet",
	shoot_offset = 0.5,
	passive = false,
	hp_min = 30,
	hp_max = 30,
	xp_min = 5,
	xp_max = 5,
	armor = 20,
	collisionbox = {-0.5, -0.01, -0.5, 0.5, 0.99, 0.5},
	visual = "mesh",
	mesh = "mobs_mc_shulker.b3d",
	textures = { "mobs_mc_endergolem.png", },
	-- TODO: sounds
	-- TODO: Make shulker dye-able
	visual_size = {x=3, y=3},
	walk_chance = 10,
	knock_back = false,
	jump = false,
	can_despawn = false,
	fall_speed = 0,
	does_not_prevent_sleep = true,
	drops = {
		{name = "mcl_mobitems:shulker_shell",
		chance = 2,
		min = 1,
		max = 1,
		looting = "rare",
		looting_factor = 0.0625},
	},
	animation = {
		stand_speed = 25, walk_speed = 25, run_speed = 50, punch_speed = 25,
		speed_normal = 25,		speed_run = 50,
		stand_start = 0,		stand_end = 25,
		walk_start = 45,		walk_end = 65,
		walk_loop = false,
		run_start = 65,		run_end = 85,
		run_loop = false,
        punch_start = 80,  punch_end = 100,
	},
	view_range = 16,
	fear_height = 0,
	walk_velocity = 0,
	run_velocity = 0,
	noyaw = true,
	_mcl_fishing_hookable = true,
	_mcl_fishing_reelable = false,
	on_rightclick = function(self,clicker)
		if clicker:is_player() then
			local wstack = clicker:get_wielded_item()
			if minetest.get_item_group(wstack:get_name(),"dye") > 0 then
				local color = minetest.registered_items[wstack:get_name()]._color
				local tx = "mobs_mc_shulker_"..color..".png"
				if messy_textures[color] then tx = messy_textures[color] end
				self.object:set_properties({
					textures = { tx },
				})
				if not minetest.is_creative_enabled(clicker:get_player_name()) then
					wstack:take_item()
					clicker:set_wielded_item(wstack)
				end
			end
		end
	end,
	do_custom = function(self,dtime)
		local pos = self.object:get_pos()
		if math.floor(self.object:get_yaw()) ~=0 then
			self.object:set_yaw(0)
			mcl_mobs.yaw(self, 0, 0, dtime)
		end
		if self.state == "attack" then
			self:set_animation("run")
			self.armor = 0
		elseif self.state == "walk" or self.state == "run" then
			self.armor = 0
		else
			self.armor = 20
		end
		self.path.way = false
		self.look_at_players = false
		if not check_spot(pos) then
			self:teleport(nil)
		end
	end,
	do_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
		self:teleport(puncher)
	end,
	do_teleport = function(self, target)
		if target ~= nil then
			local target_pos = target:get_pos()
			-- Find all solid nodes below air in a 10×10×10 cuboid centered on the target
			local nodes = minetest.find_nodes_in_area_under_air(vector.subtract(target_pos, 5), vector.add(target_pos, 5), {"group:solid", "group:cracky", "group:crumbly"})
			local telepos
			if nodes ~= nil then
				if #nodes > 0 then
					-- Up to 64 attempts to teleport
					for n=1, math.min(64, #nodes) do
						local r = pr:next(1, #nodes)
						local nodepos = nodes[r]
						local tg = vector.offset(nodepos,0,1,0)
						if check_spot(tg) then
							telepos = tg
						end
					end
					if telepos then
						self.object:set_pos(telepos)
					end
				end
			end
		else
			local pos = self.object:get_pos()
			-- Up to 8 top-level attempts to teleport
			for n=1, 8 do
				local node_ok = false
				-- We need to add (or subtract) different random numbers to each vector component, so it couldn't be done with a nice single vector.add() or .subtract():
				local randomCube = vector.new( pos.x + 8*(pr:next(0,16)-8), pos.y + 8*(pr:next(0,16)-8), pos.z + 8*(pr:next(0,16)-8) )
				local nodes = minetest.find_nodes_in_area_under_air(vector.subtract(randomCube, 4), vector.add(randomCube, 4), {"group:solid", "group:cracky", "group:crumbly"})
				if nodes ~= nil then
					if #nodes > 0 then
						-- Up to 8 low-level (in total up to 8*8 = 64) attempts to teleport
						for n=1, math.min(8, #nodes) do
							local r = pr:next(1, #nodes)
							local nodepos = nodes[r]
							local tg = vector.offset(nodepos,0,0.5,0)
							if check_spot(tg) then
								self.object:set_pos(tg)
								node_ok = true
								break
							end
						end
					end
				end
				if node_ok then
					 break
				end
			end
		end
	end,
	on_attack = function(self, dtime)
		self.shoot_interval = 1 + (math.random() * 4.5)
	end,
})

-- bullet arrow (weapon)
mcl_mobs.register_arrow("mobs_mc:shulkerbullet", {
	visual = "sprite",
	visual_size = {x = 0.25, y = 0.25},
	textures = {"mobs_mc_shulkerbullet.png"},
	velocity = 5,
	homing = true,
	_mcl_fishing_hookable = true,
	_mcl_fishing_reelable = true,
	hit_player = mcl_mobs.get_arrow_damage_func(4),
	hit_mob = mcl_mobs.get_arrow_damage_func(4),
	hit_node = function(self, _)
		self.object:remove()
	end
})

mcl_mobs.register_egg("mobs_mc:shulker", S("Shulker"), "#946694", "#4d3852", 0)
