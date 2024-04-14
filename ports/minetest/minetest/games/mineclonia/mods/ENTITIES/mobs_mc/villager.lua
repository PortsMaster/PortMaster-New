-- Villager code originally by maikerumine for mobs_mc
-- massively improved by cora, ancientmarinerdev and codiac

-- TODO: Particles
-- TODO: 4s Regeneration I after trade unlock
-- TODO: Internal inventory, trade with other villagers

local modname = minetest.get_current_modname()
local modpath = minetest.get_modpath(modname)

local S = minetest.get_translator(modname)

local DEFAULT_WALK_CHANCE = 33 -- chance to walk in percent, if no player nearby
local PLAYER_SCAN_INTERVAL = 5 -- every X seconds, villager looks for players nearby
local PLAYER_SCAN_RADIUS = 4 -- scan radius for looking for nearby players

mobs_mc.jobsites = {}
mobs_mc.professions = {}
mobs_mc.villager = {}
mobs_mc.villager_mob = {}

function mobs_mc.register_villager_profession(title, record)

	-- TODO should we allow overriding jobs?
	-- If so what needs to be considered?
	if mobs_mc.professions[title] then
		minetest.log("warning", "[mobs_mc] Trying to register villager job "..title.." which already exists. Skipping.")
		return
	end

	mobs_mc.professions[title] = record

	if record.jobsite then
		table.insert(mobs_mc.jobsites, record.jobsite)
	end
end

for title, record in pairs(dofile(modpath.."/villagers/trades.lua")) do
	mobs_mc.register_villager_profession(title, record)
end


dofile(modpath.."/villagers/activities.lua")
dofile(modpath.."/villagers/trading.lua")

function mobs_mc.villager_mob:set_textures()
	local badge_textures = self:get_badge_textures()
	self.base_texture = badge_textures
	self.object:set_properties({textures=badge_textures})
end

--[------[ MOB REGISTRATION AND SPAWNING ]-------]

local pick_up = { "mcl_farming:bread", "mcl_farming:carrot_item", "mcl_farming:beetroot_item" , "mcl_farming:potato_item" }


function mobs_mc.villager_mob:on_pick_up(itementity)
	local clicker
	local it = ItemStack(itementity.itemstring)
	for _,p in pairs(minetest.get_connected_players()) do
		if vector.distance(p:get_pos(),self.object:get_pos()) < 10 then
			clicker = p
		end
	end
	if clicker and not self.horny then
		self:feed_tame(clicker, 1, true, false, true)
		it:take_item(1)
	end
	return it
end

function mobs_mc.villager_mob:on_rightclick(clicker)
	if self.child or self._profession == "unemployed" or self._profession == "nitwit" then
		self.order = nil
		return
	end

	if self:validate_jobsite() and self.order ~= "work" then
		minetest.log("warning","[mobs_mc] villager has jobsite but doesn't work")
	end

	self:init_trader_vars()
	local name = clicker:get_player_name()
	self._trading_players[name] = true

	if self._trades == nil or self._trades == false then
		self:init_trades()
	end
	self:update_max_tradenum()
	if self._trades == false then
		return
	end

	local inv = minetest.get_inventory({type="detached", name="mobs_mc:trade_"..name})
	if not inv then
		return
	end

	self:show_trade_formspec(name)

	local selfpos = self.object:get_pos()
	local clickerpos = clicker:get_pos()
	local dir = vector.direction(selfpos, clickerpos)
	self.object:set_yaw(minetest.dir_to_yaw(dir))
	self:stand_still()
end

function mobs_mc.villager_mob:do_custom(dtime)
	self:check_summon(dtime)

	if not self._player_scan_timer then
		self._player_scan_timer = 0
	end
	self._player_scan_timer = self._player_scan_timer + dtime

	-- Check infrequently to keep CPU load low
	if self._player_scan_timer > PLAYER_SCAN_INTERVAL then

		self._player_scan_timer = 0
		local selfpos = self.object:get_pos()
		local objects = minetest.get_objects_inside_radius(selfpos, PLAYER_SCAN_RADIUS)
		local has_player = false

		for o, obj in pairs(objects) do
			if obj:is_player() then
				has_player = true
				break
			end
		end
		if has_player then
			self:stand_still()
		else
			self.walk_chance = DEFAULT_WALK_CHANCE
			self.jump = true
		end
	end

	self:do_activity(dtime)
end

function mobs_mc.villager_mob:on_spawn()
	if self.state == "attack" then
		-- in case a bug in mcl_mobs makes them set this state
		self.state = "stand"
		self.attack = nil
	end
	if not self._profession then
		self._profession = "unemployed"
		if math.random(100) == 1 then
			self._profession = "nitwit"
		end
	end
	if self._id then
		self:set_textures()
		return
	end
	self._id=minetest.sha1(minetest.get_gametime()..minetest.pos_to_string(self.object:get_pos())..tostring(math.random()))
	self:set_textures()
end

function mobs_mc.villager_mob:on_die(pos, cmi_cause)
	-- Close open trade formspecs and give input back to players
	local trading_players = self._trading_players
	if trading_players then
		for name, _ in pairs(trading_players) do
			minetest.close_formspec(name, "mobs_mc:trade_"..name)
			local player = minetest.get_player_by_name(name)
			if player then
				mobs_mc.villager.return_fields(player)
			end
		end
	end

	local bed = self._bed
	if bed then
		local bed_meta = minetest.get_meta(bed)
		bed_meta:set_string("villager", "")
		bed_meta:set_string("infotext", "")
	end
	local jobsite = self._jobsite
	if jobsite then
		local jobsite_meta = minetest.get_meta(jobsite)
		jobsite_meta:set_string("villager", "")
		jobsite_meta:set_string("infotext", "")
	end

	if cmi_cause and cmi_cause.puncher then
		local l = cmi_cause.puncher:get_luaentity()
		if l and math.random(2) == 1 and( l.name == "mobs_mc:zombie" or l.name == "mobs_mc:baby_zombie" or l.name == "mobs_mc:villager_zombie" or l.name == "mobs_mc:husk") then
			mcl_util.replace_mob(self.object,"mobs_mc:villager_zombie")
			return true
		end
	end
end

function mobs_mc.villager_mob:on_lightning_strike(pos, pos2, objects)
	 mcl_util.replace_mob(self.object, "mobs_mc:witch")
	 return true
end

table.update(mobs_mc.villager_mob, {
	description = S("Villager"),
	type = "npc",
	spawn_class = "passive",
	passive = true,
	hp_min = 20,
	hp_max = 20,
	head_swivel = "head.control",
	bone_eye_height = 6.3,
	head_eye_height = 2.2,
	curiosity = 10,
	runaway = true,
	collisionbox = {-0.3, -0.01, -0.3, 0.3, 1.94, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_villager.b3d",
	textures = {
		"mobs_mc_villager.png",
		"mobs_mc_villager.png", --hat
	},
	makes_footstep_sound = true,
	walk_velocity = 1.2,
	run_velocity = 2.4,
	drops = {},
	can_despawn = false,
	-- TODO: sounds
	sounds = {
		random = "mobs_mc_villager",
		damage = "mobs_mc_villager_hurt",
		distance = 10,
	},
	animation = {
		stand_start = 0, stand_end = 0,
		walk_start = 0, walk_end = 40, walk_speed = 25,
		run_start = 0, run_end = 40, run_speed = 25,
		head_shake_start = 60, head_shake_end = 70, head_shake_loop = false,
		head_nod_start = 50, head_nod_end = 60, head_nod_loop = false,
	},
	child_animations = {
		stand_start = 71, stand_end = 71,
		walk_start = 71, walk_end = 111, walk_speed = 37,
		run_start = 71, run_end = 111, run_speed = 37,
		head_shake_start = 131, head_shake_end = 141, head_shake_loop = false,
		head_nod_start = 121, head_nod_end = 131, head_nod_loop = false,
	},
	follow = pick_up,
	nofollow = true,
	view_range = 16,
	fear_height = 4,
	jump = true,
	walk_chance = DEFAULT_WALK_CHANCE,
	_bed = nil,
	_id = nil,
	_profession = "unemployed",
	look_at_player = true,
	pick_up = pick_up,
	can_open_doors = true,
	_player_scan_timer = 0,
	_trading_players = {},
	runaway_from = {
		"mobs_mc:zombie",
		"mobs_mc:baby_zombie",
		"mobs_mc:husk",
		"mobs_mc:baby_husk",
		"mobs_mc:villager_zombie",
		"mobs_mc:zombified_piglin",
		"mobs_mc:zoglin",
		"mobs_mc:pillager",
		"mobs_mc:vindicator",
		"mobs_mc:vex",
		"mobs_mc:evoker",
		"mobs_mc:illusioner",
	},
	after_activate = mobs_mc.villager_mob.set_textures,
})

mcl_mobs.register_mob("mobs_mc:villager", mobs_mc.villager_mob)

-- spawn eggs
mcl_mobs.register_egg("mobs_mc:villager", S("Villager"), "#563d33", "#bc8b72", 0)
