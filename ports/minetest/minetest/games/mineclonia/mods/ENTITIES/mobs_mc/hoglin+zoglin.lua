--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### hoglin
--###################

local hoglin = {
	description = S("Hoglin"),
	type = "monster",
	passive = false,
	spawn_class = "hostile",
	hp_min = 40,
	hp_max = 40,
	xp_min = 9,
	xp_max = 9,
	armor = {fleshy = 90},
	attack_type = "dogfight",
	dogfight_interval = 3,
	custom_attack_interval = 3,
	damage = 4,
	reach = 3,
	collisionbox = {-.6, -0.01, -.6, .6, 1.4, .6},
	visual = "mesh",
	mesh = "extra_mobs_hoglin.b3d",
	textures = { {
		"extra_mobs_hoglin.png",
	} },
	visual_size = {x=3, y=3},
	sounds = {
		random = "extra_mobs_hoglin",
		damage = "extra_mobs_hoglin_hurt",
		death = "extra_mobs_hoglin_hurt",
		distance = 16,
	},
	jump = true,
	makes_footstep_sound = true,
	walk_velocity = 1,
	run_velocity = 1.3, -- ( was 2.8 )  < 2.4 is slow and 2.6 < is fast
	retaliates = true,
	group_attack = true,
	avoid_from = {
		"mcl_crimson:warped_fungus",
		"mcl_flowerpots:flower_pot_warped_fungus",
		"mcl_portals:portal",
		"mcl_beds:respawn_anchor",
		"mcl_beds:respawn_anchor_charged_1",
		"mcl_beds:respawn_anchor_charged_2",
		"mcl_beds:respawn_anchor_charged_3",
		"mcl_beds:respawn_anchor_charged_4",
	},
	follow = {"mcl_crimson:crimson_fungus"},
	drops = {
		{
			name = "mobs_mcitems:leather",
			chance = 1,
			min = 0,
			max = 1,
		},
		{
			name = "mcl_mobitems:porkchop",
			chance = 1,
			min = 2,
			max = 4,
		},
	},
	animation = {
		stand_speed = 7,
		walk_speed = 7,
		run_speed = 15,
		stand_start = 24,
		stand_end = 24,
		walk_start = 11,
		walk_end = 21,
		run_start = 1,
		run_end = 10,
		punch_start = 22,
		punch_end = 32,
	},
	fear_height = 4,
	view_range = 32,
	floats = 0,
	custom_attack = function(self)
		if self.state == "attack" and self.reach > vector.distance(self.object:get_pos(), self.attack:get_pos()) then
			local shield_dot = vector.dot(self.attack:get_look_dir(), vector.subtract(self.object:get_pos(), self.attack:get_pos()))
			if self.attack:is_player() and mcl_shields and mcl_shields.is_blocking and mcl_shields.is_blocking(self.attack) and shield_dot >= 0 then
				self.attack:add_velocity({x=0,y=9.75,z=0})
			else
				self.attack:add_velocity({x=0,y=13,z=0})
			end
			mcl_util.deal_damage(self.attack, self.damage, {type = "mob"})
		end
	end,
	do_custom = function(self)
		if mcl_worlds.pos_to_dimension(self.object:get_pos()) == "overworld" then
			mcl_util.replace_mob(self.object, "mobs_mc:zoglin")
		end
	end,
	on_rightclick = function(self, clicker)
		if self:feed_tame(clicker, 1, true, false) then return end
	end,
	attack_animals = true,
}
mcl_mobs.register_mob("mobs_mc:hoglin", hoglin)

mcl_mobs.register_mob("mobs_mc:zoglin",table.merge(hoglin,{
	description = S("Zoglin"),
	fire_resistant = 1,
	textures = {"extra_mobs_zoglin.png"},
	do_custom = function() end,
	attacks_monsters = true,
	lava_damage = 0,
	fire_damage = 0,
	sounds = {
		random = "extra_mobs_hoglin",
		damage = "extra_mobs_hoglin_hurt",
		death = "extra_mobs_hoglin_hurt",
		distance = 16,
	},
}))

mcl_mobs.register_mob("mobs_mc:baby_hoglin",table.merge(hoglin,{
	description = S("Baby Hoglin"),
	collisionbox = {-.3, -0.01, -.3, .3, 0.94, .3},
	xp_min = 20,
	xp_max = 20,
	visual_size = {x=hoglin.visual_size.x/2, y=hoglin.visual_size.y/2},
	textures = { {
		"extra_mobs_hoglin.png",
		"blank.png",
	} },
	walk_velocity = 1.2,
	run_velocity = 1.6,
	child = 1,
}))

mcl_mobs.spawn_setup({
	name = "mobs_mc:hoglin",
	type_of_spawning = "ground",
	dimension = "nether",
	min_light = 0,
	max_light = minetest.LIGHT_MAX+1,
	min_height = mcl_vars.mg_lava_nether_max,
	aoc = 3,
	biomes = {
		"Nether",
		"CrimsonForest"
	},
	chance = 200,
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:hoglin", S("Hoglin"), "#85682e", "#2b2140", 0)
