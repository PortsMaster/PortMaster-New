local S = minetest.get_translator("mobs_mc")

local function reload(self)
	if not self.object:get_pos() then return end
	minetest.sound_play("mcl_bows_crossbow_drawback_1", {object = self.object, max_hear_distance=16}, true)
	local props = self.object:get_properties()
	if not props then return end
	props.textures[2] = "mcl_bows_crossbow_3.png^[resize:16x16"
	self.object:set_properties(props)
end

local function reset_animation(self, animation)
	if not self.object:get_pos() or self._current_animation ~= animation then return end
	self._current_animation = "stand_reload" -- Mobs Redo won't set the animation unless we do this
	self:set_animation(animation)
end

pillager = {
	description = S("Pillager"),
	type = "monster",
	spawn_class = "hostile",
	hp_min = 24,
	hp_max = 24,
	xp_min = 6,
	xp_max = 6,
	breath_max = -1,
	eye_height = 1.5,
	shoot_interval = 3,
	shoot_offset = 1.5,
	armor = {fleshy = 100},
	can_despawn = false,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.98, 0.3},
	pathfinding = 1,
	group_attack = true,
	visual = "mesh",
	mesh = "mobs_mc_pillager.b3d",
	visual_size = {x=2.75, y=2.75},
	makes_footstep_sound = true,
	walk_velocity = 1.2,
	run_velocity = 4,
	view_range = 16,
	fear_height = 4,
	arrow = "mcl_bows:arrow_entity",
	attack_type = "dogshoot", -- Alternate punching/shooting
	attack_npcs = true,
	reach = 0, -- Punching max distance
	damage = 0, -- Punching damage
	dogshoot_switch = 1, -- Start of shooting
	dogshoot_count_max = 5, -- Max time spent shooting (standing)
	dogshoot_count2_max = 1, -- Max time spent punching (running)
	sounds = {
		random = "mobs_mc_pillager_grunt2",
		war_cry = "mobs_mc_pillager_grunt1",
		death = "mobs_mc_pillager_ow2",
		damage = "mobs_mc_pillager_ow1",
		distance = 16,
	},
	textures = {
		{
			"mobs_mc_pillager.png", -- Skin
			"mcl_bows_crossbow_3.png^[resize:16x16", -- Wielded item
		}
	},
	drops = {
		{
			name = "mcl_bows:arrow",
			chance = 1,
			min = 0,
			max = 2,
			looting = "common",
		},
		{
			name = "mcl_bows:crossbow",
			chance = 100 / 8.5,
			min = 1,
			max = 1,
			looting = "rare",
		},
	},
	animation = {
		unloaded_walk_start = 1, unloaded_walk_end = 40,
		unloaded_stand_start = 41, unloaded_stand_end = 60,
		reload_stand_start = 61, reload_stand_end = 100, reload_stand_speed = 20,
		stand_start = 101, stand_end = 109, stand_speed = 6,
		walk_start = 111, walk_end = 150, walk_speed = 30,
		run_start = 111, run_end = 150, run_speed = 50,
		reload_run_start = 151, reload_run_end = 190, reload_run_speed = 20,
		die_start = 191, die_end = 192, die_speed = 15,
		stand_unloaded_start = 40, stand_unloaded_end = 59,
		die_loop = false,
	},
	shoot_arrow = function(self, pos, dir)
		minetest.sound_play("mcl_bows_crossbow_shoot", {object = self.object, max_hear_distance=16}, true)
		local props = self.object:get_properties()
		props.textures[2] = "mcl_bows_crossbow_0.png^[resize:16x16"
		self.object:set_properties(props)
		local old_anim = self._current_animation
		if old_anim == "run" or old_anim == "walk" then
			self:set_animation("reload_run")
		end
		if old_anim == "stand" then
			self:set_animation("reload_stand")
		end
		self._current_animation = old_anim -- Mobs Redo will imediately reset the animation otherwise
		minetest.after(1, reload, self)
		minetest.after(2, reset_animation, self, old_anim)

		-- 2-4 damage per arrow
		local dmg = math.max(4, math.random(2, 8))
		mcl_bows.shoot_arrow_crossbow("mcl_bows:arrow", pos, dir, self.object:get_yaw(), self.object, nil, dmg)

		-- While we are at it, change the sounds since there is no way to do this in Mobs Redo
		if self.sounds and self.sounds.random then
			self.sounds = table.copy(self.sounds)
			self.sounds.random = "mobs_mc_pillager_grunt" .. math.random(2)
		end

		-- Randomize reload time
		self.shoot_interval = math.random(3, 4)
	end,
}

mcl_mobs.register_mob("mobs_mc:pillager", pillager)
mcl_mobs.register_egg("mobs_mc:pillager", S("Pillager"), "#532f36", "#959b9b", 0)
