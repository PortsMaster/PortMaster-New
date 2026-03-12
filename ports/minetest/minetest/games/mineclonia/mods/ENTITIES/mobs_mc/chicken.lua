--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator("mobs_mc")
local mob_class = mcl_mobs.mob_class

--###################
--################### CHICKEN
--###################

local chicken = {
	description = S("Chicken"),
	type = "animal",
	_spawn_category = "creature",
	hp_min = 4,
	hp_max = 4,
	xp_min = 1,
	xp_max = 3,
	collisionbox = {-0.2, 0.0, -0.2, 0.2, 0.7, 0.2},
	runaway = true,
	floats = 1,
	head_swivel = "head.control",
	bone_eye_height = 4,
	head_eye_height = 0.644,
	horizontal_head_height = -.3,
	curiosity = 10,
	head_yaw="z",
	visual_size = {x=1,y=1},
	visual = "mesh",
	mesh = "mobs_mc_chicken.b3d",
	textures = {
		{"mobs_mc_chicken.png"},
	},
	makes_footstep_sound = true,
	movement_speed = 5.0,
	drops = {
		{name = "mcl_mobitems:chicken",
		 chance = 1,
		 min = 1,
		 max = 1,
		 looting = "common",},
		{name = "mcl_mobitems:feather",
		 chance = 1,
		 min = 0,
		 max = 2,
		 looting = "common",},
	},
	fall_damage = 0,
	gravity_drag = 0.6,
	sounds = {
		random = {name="mobs_mc_chicken_buck", gain=0.7},
		damage = "mobs_mc_chicken_hurt",
		death = "mobs_mc_chicken_hurt",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	sounds_child = {
		random = {name="mobs_mc_chicken_child", gain=0.7},
		damage = "mobs_mc_chicken_child",
		death = "mobs_mc_chicken_child",
		eat = "mobs_mc_animal_eat_generic",
		distance = 16,
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 20, walk_speed = 40,
		run_start = 0, run_end = 20, run_speed = 50,
		flap_start = 20, flap_end = 30, flap_speed = 60,
	},
	_child_animations = {
		stand_start = 31, stand_end = 31,
		walk_start = 31, walk_end = 51, walk_speed = 80,
		run_start = 31, run_end = 51, run_speed = 80,
		flap_start = 31, flap_end = 31, flap_speed = 0,
	},
	follow = {
		"mcl_farming:wheat_seeds",
		"mcl_farming:melon_seeds",
		"mcl_farming:pumpkin_seeds",
		"mcl_farming:beetroot_seeds",
	},
	run_bonus = 1.4,
	_is_chicken_jockey = false,
}

------------------------------------------------------------------------
-- Chicken AI.
------------------------------------------------------------------------

chicken.ai_functions = {
	mob_class.check_frightened,
	mob_class.check_breeding,
	mob_class.check_following,
	mob_class.follow_herd,
	mob_class.check_pace,
}

function chicken:on_rightclick (clicker)
	if self:follow_holding(clicker)
		and self:feed_tame(clicker, 4, true, false) then
		return
	end
end

function chicken:do_custom (dtime)
	-- Chickens mounted by a baby zombie never proceed to lay eggs
	-- again.
	if not self._is_chicken_jockey and not self.child then
		self.egg_timer = (self.egg_timer or math.random(300, 600)) - dtime
		if self.egg_timer > 0 then
			return
		end
		self.egg_timer = nil

		local pos = self.object:get_pos ()
		core.add_item (pos, "mcl_throwing:egg")
		core.sound_play ("mobs_mc_chicken_lay_egg", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 16,
		}, true)
	end
	if self._is_chicken_jockey then
		self.xp_min = 10
		self.xp_max = 10
	end
end

function chicken:despawn_allowed ()
	local nametag = self.nametag and self.nametag ~= ""
	if self._is_chicken_jockey then
		return not nametag and not self.persistent
			and not self.tamed
	else
		return mob_class.despawn_allowed (self)
	end
end

------------------------------------------------------------------------
-- Chicken visuals.
------------------------------------------------------------------------

function chicken:set_animation (anim, fixed_frame)
	if self._flapping then
		anim = "flap"
	end
	mob_class.set_animation (self, anim, fixed_frame)
end

function chicken:set_animation_speed (custom_speed)
	local anim
	local v = self.object:get_velocity ()
	if self._flapping then
		anim = "flap"
	else
		if v.x * v.x + v.z * v.z > 5.0e-2 then
			anim = "walk"
		else
			anim = "stand"
		end
	end
	self:set_animation (anim)
	mob_class.set_animation_speed (self, custom_speed)
end

function chicken:mob_activate (staticdata, dtime)
	self._flapping = false
	return mob_class.mob_activate (self, staticdata, dtime)
end

function chicken:motion_step (dtime, moveresult, self_pos)
	local v = self.object:get_velocity ()
	self._flapping = v.y < 0
	mob_class.motion_step (self, dtime, moveresult, self_pos)
end

mcl_mobs.register_mob ("mobs_mc:chicken", chicken)

------------------------------------------------------------------------
-- Chicken spawning.
------------------------------------------------------------------------

-- spawn eggs
mcl_mobs.register_egg ("mobs_mc:chicken", S("Chicken"), "#a1a1a1", "#ff0000", 0)

------------------------------------------------------------------------
-- Modern Chicken spawning.
------------------------------------------------------------------------

local chicken_spawner = table.merge (mobs_mc.animal_spawner, {
	name = "mobs_mc:chicken",
	biomes = mobs_mc.farm_animal_biomes,
	weight = 10,
})

local chicken_spawner_jungle = table.merge (mobs_mc.animal_spawner, {
	name = "mobs_mc:chicken",
	biomes = {
		"#is_jungle",
	},
	weight = 10,
})

mcl_mobs.register_spawner (chicken_spawner)
mcl_mobs.register_spawner (chicken_spawner_jungle)
