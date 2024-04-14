--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### VEX
--###################

mcl_mobs.register_mob("mobs_mc:vex", {
	description = S("Vex"),
	type = "monster",
	spawn_class = "hostile",
	pathfinding = 1,
	passive = false,
	attack_type = "dogfight",
	physical = false,
	hp_min = 14,
	hp_max = 14,
	xp_min = 6,
	xp_max = 6,
	collisionbox = {-0.2, 0.2, -0.2, 0.2, 1.0, 0.2},  --bat
	visual = "mesh",
	mesh = "mobs_mc_vex.b3d",
	textures = {
		{
			"default_tool_steelsword.png",
			"mobs_mc_vex.png",
		},
	},
	visual_size = {x=1.25, y=1.25},
	damage = 9,
	reach = 2,
	view_range = 16,
	walk_velocity = 2,
	run_velocity = 3,
	sounds = {
		-- TODO: random
		death = "mobs_mc_vex_death",
		damage = "mobs_mc_vex_hurt",
		distance = 16,
	},
	animation = {
		stand_speed = 25,
		walk_speed = 25,
		run_speed = 50,
		stand_start = 40,
		stand_end = 80,
		walk_start = 0,
		walk_end = 40,
		run_start = 0,
		run_end = 40,
	},
	do_custom = function(self, dtime)
		-- Glow red while attacking
		-- TODO: Charge sound
		if self.state == "attack" then
			if self.base_texture[2] ~= "mobs_mc_vex_charging.png" then
				self.base_texture[2] = "mobs_mc_vex_charging.png"
				self.object:set_properties({textures=self.base_texture})
			end
		else
			if self.base_texture[2] == "mobs_mc_vex_charging.png" then
				self.base_texture[2] = "mobs_mc_vex.png"
			end
			if self.base_texture[1] ~= "default_tool_steelsword.png" then
				self.base_texture[1] = "default_tool_steelsword.png"
			end
			self.object:set_properties({textures=self.base_texture})
		end

		-- Take constant damage if the vex' life clock ran out
		-- (only for vexes summoned by evokers)
		if self._summoned then
			if not self._lifetimer then
				self._lifetimer = 33
			end
			self._lifetimer = self._lifetimer - dtime
			if self._lifetimer <= 0 then
				if self._damagetimer then
					self._damagetimer = self._damagetimer - 1
				end
				self.object:punch(self.object, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = 2},
				}, nil)
				self._damagetimer = 1
			end
		end
	end,
	fly = true,
	makes_footstep_sound = false,
})


-- spawn eggs
mcl_mobs.register_egg("mobs_mc:vex", S("Vex"), "#7a90a4", "#e8edf1", 0)
