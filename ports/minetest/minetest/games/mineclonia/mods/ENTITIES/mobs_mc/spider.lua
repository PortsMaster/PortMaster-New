--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

--###################
--################### SPIDER
--###################


-- Spider by AspireMint (fishyWET (CC-BY-SA 3.0 license for texture)
minetest.register_entity("mobs_mc:spider_eyes", {
	initial_properties = {
		pointable = false,
		visual = "mesh",
		mesh = "mobs_mc_spider.b3d",
		visual_size = {x=1.01/3, y=1.01/3},
		glow = 50,
		textures = {
			"mobs_mc_spider_eyes.png",
		},
	},
	on_step = function(self)
		if self and self.object then
			if not self.object:get_attach() then
				self.object:remove()
			end
		end
	end,
})

local spider = {
	description = S("Spider"),
	type = "monster",
	spawn_class = "hostile",
	passive = false,
	docile_by_day = true,
	attack_type = "dogfight",
	pathfinding = 1,
	damage = 2,
	reach = 2,
	hp_min = 16,
	hp_max = 16,
	xp_min = 5,
	xp_max = 5,
	armor = {fleshy = 100, arthropod = 100},
	on_spawn = function(self)
		self.object:set_properties({visual_size={x=1,y=1}})
		local spider_eyes=false
		for n = 1, #self.object:get_children() do
			local obj = self.object:get_children()[n]
			if obj:get_luaentity() and self.object:get_luaentity().name == "mobs_mc:spider_eyes" then
				spider_eyes = true
			end
		end
		if not spider_eyes then
			minetest.add_entity(self.object:get_pos(), "mobs_mc:spider_eyes"):set_attach(self.object, "body.head", vector.new(0,-0.98,2), vector.new(90,180,180))
		end
	end,
	on_die=function(self)
		if self.object:get_children() and self.object:get_children()[1] then
			self.object:get_children()[1]:set_detach()
		end
	end,
	head_swivel = "Head_Control",
	bone_eye_height = 1,
	curiosity = 10,
	head_yaw="z",
	collisionbox = {-0.7, -0.01, -0.7, 0.7, 0.89, 0.7},
	visual = "mesh",
	mesh = "mobs_mc_spider.b3d",
	textures = {
		{"mobs_mc_spider.png"},
	},
	visual_size = {x=1, y=1},
	makes_footstep_sound = false,
	sounds = {
		random = "mobs_mc_spider_random",
		attack = "mobs_mc_spider_attack",
		damage = "mobs_mc_spider_hurt",
		death = "mobs_mc_spider_death",
		-- TODO: sounds: walk
		distance = 16,
	},
	walk_velocity = 1.1,
	run_velocity = 1.45, -- (was 2.4) a bit slower, they arent much different from running skeletons
	jump = true,
	jump_height = 4,
	view_range = 16,
	floats = 1,
	drops = {
		{name = "mcl_mobitems:string", chance = 1, min = 0, max = 2, looting = "common"},
		{name = "mcl_mobitems:spider_eye", chance = 3, min = 1, max = 1, looting = "common", looting_chance_function = function(lvl)
			return 1 - 2 / (lvl + 3)
		end},
	},
	specific_attack = { "player", "mobs_mc:iron_golem" },
	fear_height = 4,
	animation = {
		stand_speed = 10,
		walk_speed = 25,
		run_speed = 50,
		stand_start = 20,
		stand_end = 40,
		walk_start = 0,
		walk_end = 20,
		run_start = 0,
		run_end = 20,
	},
}
mcl_mobs.register_mob("mobs_mc:spider", spider)

-- Cave spider
local cave_spider = table.copy(spider)
cave_spider.description = S("Cave Spider")
cave_spider.textures = { {"mobs_mc_cave_spider.png^(mobs_mc_spider_eyes.png^[makealpha:0,0,0)"} }
cave_spider.damage = 2
cave_spider.hp_min = 1
cave_spider.hp_max = 12
cave_spider.collisionbox = {-0.35, -0.01, -0.35, 0.35, 0.46, 0.35}
cave_spider.visual_size = {x=0.55,y=0.5}
cave_spider.on_spawn = function(self)
	self.object:set_properties({visual_size={x=0.55,y=0.5}})
	local spider_eyes=false
	for n = 1, #self.object:get_children() do
		local obj = self.object:get_children()[n]
		if obj:get_luaentity() and self.object:get_luaentity().name == "mobs_mc:spider_eyes" then
			spider_eyes = true
		end
	end
	if not spider_eyes then
		minetest.add_entity(self.object:get_pos(), "mobs_mc:spider_eyes"):set_attach(self.object, "body.head", vector.new(0,-0.98,2), vector.new(90,180,180))
	end
end
cave_spider.walk_velocity = 1.3
cave_spider.run_velocity = 3.2
cave_spider.sounds = table.copy(spider.sounds)
cave_spider.sounds.base_pitch = 1.25
cave_spider.dealt_effect = {
	name = "poison",
	factor = 2.5,
	dur = 7,
}
mcl_mobs.register_mob("mobs_mc:cave_spider", cave_spider)

mcl_mobs.spawn_setup({
	name = "mobs_mc:spider",
	type_of_spawning = "ground",
	dimension = "overworld",
	aoc = 9,
	biomes_except = {
		"MushroomIslandShore",
		"MushroomIsland"
	},
	chance = 1000,
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:spider", S("Spider"), "#342d26", "#a80e0e", 0)
mcl_mobs.register_egg("mobs_mc:cave_spider", S("Cave Spider"), "#0c424e", "#a80e0e", 0)
