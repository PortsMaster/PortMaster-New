--License for code WTFPL and otherwise stated in readmes

local S = minetest.get_translator("mobs_mc")

local function check_light(pos, environmental_light, artificial_light, sky_light)
	local date = os.date("*t")
	local maxlight
	if (date.month == 10 and date.day >= 20) or (date.month == 11 and date.day <= 3) then
		maxlight = 6
	else
		maxlight = 3
	end

	if artificial_light > maxlight then
		return false, "To bright"
	end

	return true, ""
end

mcl_mobs.register_mob("mobs_mc:bat", {
	description = S("Bat"),
	type = "animal",
	spawn_class = "ambient",
	can_despawn = true,
	spawn_in_group = 8,
	passive = true,
	hp_min = 6,
	hp_max = 6,
	collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.89, 0.25},
	visual = "mesh",
	mesh = "mobs_mc_bat.b3d",
	textures = {
		{"mobs_mc_bat.png"},
	},
	visual_size = {x=1, y=1},
	sounds = {
		random = "mobs_mc_bat_idle",
		damage = "mobs_mc_bat_hurt",
		death = "mobs_mc_bat_death",
		distance = 16,
	},
	walk_velocity = 4.5,
	run_velocity = 6.0,
	-- TODO: Hang upside down
	animation = {
		stand_speed = 80,
		stand_start = 0,
		stand_end = 40,
		walk_speed = 80,
		walk_start = 0,
		walk_end = 40,
		run_speed = 80,
		run_start = 0,
		run_end = 40,
		die_speed = 60,
		die_start = 40,
		die_end = 80,
		die_loop = false,
	},
	walk_chance = 100,
	fall_damage = 0,
	view_range = 16,
	fear_height = 0,

	jump = false,
	fly = true,
	makes_footstep_sound = false,
	check_light = check_light,
})


-- Spawning

--[[ If the game has been launched between the 20th of October and the 3rd of November system time,
-- the maximum spawn light level is increased. ]]
local date = os.date("*t")
local maxlight
if (date.month == 10 and date.day >= 20) or (date.month == 11 and date.day <= 3) then
	maxlight = 6
else
	maxlight = 3
end

mcl_mobs.spawn_setup({
	name = "mobs_mc:bat",
	type_of_spawning = "ground",
	dimension = "overworld",
	min_height = mcl_vars.mg_overworld_min,
	max_height = mobs_mc.water_level - 1,
	min_light = 0,
	max_light = maxlight,
	aoc = 3,
	chance = 100,
})

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:bat", S("Bat"), "#4c3e30", "#0f0f0f", 0)
