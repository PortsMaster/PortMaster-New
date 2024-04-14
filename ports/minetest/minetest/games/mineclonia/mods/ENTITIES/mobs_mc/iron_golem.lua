--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### IRON GOLEM
--###################

local walk_dist = 40
local tele_dist = 80

mcl_mobs.register_mob("mobs_mc:iron_golem", {
	description = S("Iron Golem"),
	type = "npc",
	spawn_class = "passive",
	passive = true,
	retaliates = true,
	hp_min = 100,
	hp_max = 100,
	breath_max = -1,
	collisionbox = {-0.7, -0.01, -0.7, 0.7, 2.69, 0.7},
	doll_size_override = { x = 0.9, y = 0.9 },
	visual = "mesh",
	mesh = "mobs_mc_iron_golem.b3d",
	head_swivel = "head.control",
	bone_eye_height = 3.38,
	head_eye_height = 2.6,
	curiosity = 10,
	textures = {
		{"mobs_mc_iron_golem.png"},
	},
	visual_size = {x=3, y=3},
	makes_footstep_sound = true,
	-- TODO: sounds
	view_range = 16,
	stepheight = 1.1,
	owner = "",
	order = "follow",
	floats = 0,
	walk_velocity = 0.6,
	run_velocity = 1.2,
	-- Approximation
	damage = 14,
	knock_back = false,
	reach = 3,
	group_attack = { "mobs_mc:iron_golem", "mobs_mc:villager" },
	attacks_monsters = true,
	attack_type = "dogfight",
	_got_poppy = false,
	pick_up = {"mcl_flowers:poppy"},
	on_pick_up = function(self,n)
		local it = ItemStack(n.itemstring)
		if it:get_name() == "mcl_flowers:poppy" then
			if not self._got_poppy then
				self._got_poppy=true
				it:take_item(1)
			end
		end
		return it
	end,
	replace_what = {"mcl_flowers:poppy"},
	replace_with = {"air"},
	on_replace = function(self, pos, oldnode, newnode)
		if not self.got_poppy and oldnode.name == "mcl_flowers:poppy" then
			self._got_poppy=true
			return
		end
		return false
	end,
	drops = {
		{name = "mcl_core:iron_ingot",
		chance = 1,
		min = 3,
		max = 5,},
		{name = "mcl_flowers:poppy",
		chance = 1,
		min = 0,
		max = 2,},
	},
	fall_damage = 0,
	animation = {
		stand_speed = 15, walk_speed = 15, run_speed = 25, punch_speed = 15,
		stand_start = 0,		stand_end = 0,
		walk_start = 0,		walk_end = 40,
		run_start = 40,		run_end = 80,
		punch_start = 80,  punch_end = 90,
	},
	jump = true,
	do_custom = function(self, dtime)
		self.home_timer = (self.home_timer or 0) + dtime

		if self.home_timer > 10 then
			self.home_timer = 0
			if self._home and self.state ~= "attack" then
				local dist = vector.distance(self._home,self.object:get_pos())
				if dist >= tele_dist then
					self.object:set_pos(self._home)
					self.state = "stand"
					self.order = "follow"
				elseif dist >= walk_dist then
					self:gopath(self._home, function(self)
						self.state = "stand"
						self.order = "follow"
					end)
				end
			end
		end
	end,
})


-- spawn eggs
mcl_mobs.register_egg("mobs_mc:iron_golem", S("Iron Golem"), "#3b3b3b", "#f57223", 0)

--[[ This is to be called when a pumpkin or jack'o lantern has been placed. Recommended: In the on_construct function of the node.
This summons an iron golen if placing the pumpkin created an iron golem summon pattern:

.P.
III
.I.

P = Pumpkin or jack'o lantern
I = Iron block
. = Air
]]

function mobs_mc.check_iron_golem_summon(pos, player)
	local checks = {
		-- These are the possible placement patterns, with offset from the pumpkin block.
		-- These tables include the positions of the iron blocks (1-4) and air blocks (5-8)
		-- 4th element is used to determine spawn position.
		-- If a 9th element is present, that one is used for the spawn position instead.
		-- Standing (x axis)
		{
			{x=-1, y=-1, z=0}, {x=1, y=-1, z=0}, {x=0, y=-1, z=0}, {x=0, y=-2, z=0}, -- iron blocks
			{x=-1, y=0, z=0}, {x=1, y=0, z=0}, {x=-1, y=-2, z=0}, {x=1, y=-2, z=0}, -- air
		},
		-- Upside down standing (x axis)
		{
			{x=-1, y=1, z=0}, {x=1, y=1, z=0}, {x=0, y=1, z=0}, {x=0, y=2, z=0},
			{x=-1, y=0, z=0}, {x=1, y=0, z=0}, {x=-1, y=2, z=0}, {x=1, y=2, z=0},
			{x=0, y=0, z=0}, -- Different offset for upside down pattern
		},

		-- Standing (z axis)
		{
			{x=0, y=-1, z=-1}, {x=0, y=-1, z=1}, {x=0, y=-1, z=0}, {x=0, y=-2, z=0},
			{x=0, y=0, z=-1}, {x=0, y=0, z=1}, {x=0, y=-2, z=-1}, {x=0, y=-2, z=1},
		},
		-- Upside down standing (z axis)
		{
			{x=0, y=1, z=-1}, {x=0, y=1, z=1}, {x=0, y=1, z=0}, {x=0, y=2, z=0},
			{x=0, y=0, z=-1}, {x=0, y=0, z=1}, {x=0, y=2, z=-1}, {x=0, y=2, z=1},
			{x=0, y=0, z=0},
		},

		-- Lying
		{
			{x=-1, y=0, z=-1}, {x=0, y=0, z=-1}, {x=1, y=0, z=-1}, {x=0, y=0, z=-2},
			{x=-1, y=0, z=0}, {x=1, y=0, z=0}, {x=-1, y=0, z=-2}, {x=1, y=0, z=-2},
		},
		{
			{x=-1, y=0, z=1}, {x=0, y=0, z=1}, {x=1, y=0, z=1}, {x=0, y=0, z=2},
			{x=-1, y=0, z=0}, {x=1, y=0, z=0}, {x=-1, y=0, z=2}, {x=1, y=0, z=2},
		},
		{
			{x=-1, y=0, z=-1}, {x=-1, y=0, z=0}, {x=-1, y=0, z=1}, {x=-2, y=0, z=0},
			{x=0, y=0, z=-1}, {x=0, y=0, z=1}, {x=-2, y=0, z=-1}, {x=-2, y=0, z=1},
		},
		{
			{x=1, y=0, z=-1}, {x=1, y=0, z=0}, {x=1, y=0, z=1}, {x=2, y=0, z=0},
			{x=0, y=0, z=-1}, {x=0, y=0, z=1}, {x=2, y=0, z=-1}, {x=2, y=0, z=1},
		},


	}

	for c=1, #checks do
		-- Check all possible patterns
		local ok = true
		-- Check iron block nodes
		for i=1, 4 do
			local cpos = vector.add(pos, checks[c][i])
			local node = minetest.get_node(cpos)
			if node.name ~= "mcl_core:ironblock" then
				ok = false
				break
			end
		end
		-- Check air nodes
		for a=5, 8 do
			local cpos = vector.add(pos, checks[c][a])
			local node = minetest.get_node(cpos)
			if node.name ~= "air" then
				ok = false
				break
			end
		end
		-- Pattern found!
		if ok then
			-- Remove the nodes
			minetest.remove_node(pos)
			core.check_for_falling(pos)
			for i=1, 4 do
				local cpos = vector.add(pos, checks[c][i])
				minetest.remove_node(cpos)
				core.check_for_falling(cpos)
			end
			-- Summon iron golem
			local place
			if checks[c][9] then
				place = vector.add(pos, checks[c][9])
			else
				place = vector.add(pos, checks[c][4])
			end
			place.y = place.y - 0.5
			local o = minetest.add_entity(place, "mobs_mc:iron_golem")
			local l = o:get_luaentity()
			if l then l._creator = player:get_player_name() end
			break
		end
	end
end
