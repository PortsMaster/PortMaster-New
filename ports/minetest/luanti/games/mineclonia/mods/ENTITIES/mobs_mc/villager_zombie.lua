--MCmobs v0.4
--maikerumine
--made for MC like Survival game
--License for code WTFPL and otherwise stated in readmes

local S = core.get_translator ("mobs_mc")
local zombie = mobs_mc.zombie
local mob_class = mcl_mobs.mob_class
local pr = PcgRandom (os.time () * 1203)

------------------------------------------------------------------------
-- Zombie Villager.
------------------------------------------------------------------------

local formspec_escapes = {
	["\\"] = "\\\\",
	["^"] = "\\^",
	[":"] = "\\:",
}

local function modifier_escape (text)
	return string.gsub (text, "[\\^:]", formspec_escapes)
end

local zombie_villager = table.merge (zombie, {
	description = S("Zombie Villager"),
	type = "monster",
	_spawn_category = "monster",
	hp_min = 20,
	hp_max = 20,
	xp_min = 5,
	xp_max = 5,
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.95, 0.3},
	visual = "mesh",
	mesh = "mobs_mc_villager_zombie.b3d",
	head_swivel = "head.control",
	bone_eye_height = 0.0,
	head_eye_height = 1.74,
	curiosity = 2,
	head_pitch_multiplier = 1,
	textures = {
		"mobs_mc_zombie_villager.png",
		"blank.png", -- Armor layer 1
		"blank.png", -- Armor layer 2
	},
	visual_size = {
		x = 2.75,
		y = 2.75,
	},
	animation = {
		stand_start = 20, stand_end = 40,
		walk_start = 0, walk_end = 20, walk_speed = 20,
		run_start = 0, run_end = 20, run_speed = 20,
	},
	drops = {
		{
			name = "mcl_mobitems:rotten_flesh",
			chance = 1,
			min = 0,
			max = 2,
			looting = "common",
		},
		{
			name = "mcl_core:iron_ingot",
			chance = 120, -- 2.5% / 3
			min = 1,
			max = 1,
			looting = "rare",
			looting_factor = 0.01 / 3,
		},
		{
			name = "mcl_farming:carrot_item",
			chance = 120, -- 2.5% / 3
			min = 1,
			max = 1,
			looting = "rare",
			looting_factor = 0.01 / 3,
		},
		{
			name = "mcl_farming:potato_item",
			chance = 120, -- 2.5% / 3
			min = 1,
			max = 1,
			looting = "rare",
			looting_factor = 0.01 / 3,
		},
	},
	_armor_texture_slots = {
		[3] = {
			"head",
			"torso",
			"feet",
		},
		[2] = {
			"legs",
		},
	},
	_armor_transforms = {
		head = function (texture)
			return table.concat ({
				"[combine:64x32:-32,0=",
				"(",
				modifier_escape (texture),
				")",
			})
		end,
	},
	_head_armor_bone = "head.control",
	_head_armor_position = vector.new (0, 1.5, 0),
	_head_armor_visual_scale = 1 / 2.5,
	_head_armor_rotation = vector.new (0, 180, 0),
	wielditem_info = {
		bone = "arm.right",
		position = {
			x = 0.7 / 2.75,
			y = 6.0 / 2.75,
			z = 0.0,
		},
		rotation = {
			x = 0,
			y = 0,
			z = 0,
		},
		toollike_position = {
			x = 0.0,
			y = 5.0 / 2.75,
			z = 4.0 / 2.75,
		},
		toollike_rotation = {
			x = 90,
			y = -45,
			z = -90,
		},
		blocklike_position = {
			x = 0,
			y = 6.0 / 2.75,
			z = 0,
		},
		blocklike_rotation = {
			x = 0,
			y = 180,
			z = 45,
		},
		crossbow_position = {
			x = 0,
			y = 6.0 / 2.75,
			z = 0,
		},
		crossbow_rotation = {
			x = 0,
			y = 180,
			z = 45,
		},
		bow_position = {
			x = 0,
			y = 6.0 / 2.75,
			z = 0,
		},
		bow_rotation = {
			x = 90,
			y = 130,
			z = 115,
		},
		trident_position = {
			x = 0.0,
			y = 5.0 / 2.75,
			z = 0.0,
		},
		trident_rotation = {
			x = 90,
			y = 0,
			z = 0,
		},
	},
	_reinforcement_type = "mobs_mc:villager_zombie",
	_unplaceable_by_default = true,
	_convert_to = false,
})

------------------------------------------------------------------------
-- Zombie Villager mechanics.
------------------------------------------------------------------------

function zombie_villager:post_load_staticdata ()
	mob_class.post_load_staticdata (self)

	if pr:next (1, 100) <= 5
		and not self._zombie_villager_initialized then
		self.child = true
	end
	self._zombie_villager_initialized = true
end

------------------------------------------------------------------------
-- Zombie Villager interaction.
------------------------------------------------------------------------

function zombie_villager:actionable_on_rightclick (clicker)
	local wielditem = clicker:get_wielded_item()
	return wielditem:get_name () == "mcl_core:apple_gold"
		and mcl_potions.has_effect (self.object, "weakness")
end

function zombie_villager:on_rightclick (clicker)
	if not self._curing and clicker and clicker:is_player() then
		local wielditem = clicker:get_wielded_item()
		if wielditem:get_name () == "mcl_core:apple_gold"
			and mcl_potions.has_effect (self.object, "weakness") then
			mcl_potions.clear_effect (self.object, "weakness")
			mcl_potions.clear_effect (self.object, "strength")

			-- Grant Strength.  Contrary to the MC Wiki,
			-- the potency of this effect _does_ vary by
			-- difficulty.
			local effect_level = math.max (mcl_vars.difficulty - 1, 0)
			if effect_level > 0 then
				mcl_potions.give_effect_by_level ("strength", self.object,
								effect_level, math.huge)
			end

			local playername = clicker:get_player_name ()
			if not core.is_creative_enabled (playername) then
				wielditem:take_item ()
				clicker:set_wielded_item (wielditem)
			end

			self._curing = math.random (3 * 60, 5 * 60)
			self._curer = playername
			self.shaking = true
			self.persistent = true

			core.sound_play("mobs_mc_zombie_villager_cure",
					{pos=self.object:get_pos(), gain=0.6, max_hear_range=6}, true)
		end
	end
end

function zombie_villager:previous_staticdata ()
	if not self._previous_incarnation then
		return {
			persistent = true,
		}
	end
	return {
		_xp = self._previous_incarnation.xp,
		_tier = self._previous_incarnation.tier,
		_profession = self._previous_incarnation.profession,
		_villager_type = self._previous_incarnation.villager_type,
		_gossips = self._previous_incarnation.gossips,
		_reputation = self._previous_incarnation.reputation,
		_trades = self._previous_incarnation.trades,
		persistent = true,
	}
end

local CURE_ACCELERANTS = {
	"group:bed",
	"group:iron_bars",
}

function zombie_villager:do_custom (dtime)
	zombie.do_custom (self, dtime)
	if self._curing then
		if pr:next (1, mcl_mobs.scale_chance (100, dtime)) == 1 then
			-- Search for conversion ``accelerant''
			-- blocks.
			local self_pos = self.object:get_pos ()
			local aa = vector.offset (self_pos, -4, -4, -4)
			local bb = vector.offset (self_pos, 4, 4, 4)
			local nodes = core.find_nodes_in_area (aa, bb, CURE_ACCELERANTS)
			if #nodes > 0 then
				for i = 1, math.min (#nodes, 12) do
					if pr:next (1, 10) < 3 then
						dtime = dtime + 0.05
					end
				end
			end
		end
		self._curing = self._curing - dtime
		if self._curing <= 0 then
			self:drop_player_equipment ()

			local data = self:previous_staticdata ()
			local villager_obj = self:replace_with ("mobs_mc:villager", false, data)
			if villager_obj then
				-- Drop any equipment collected from
				-- players that is not enchanted.
				self._curing = nil
				-- Give this villager 10 seconds of nausea.
				mcl_potions.give_effect ("nausea", villager_obj, 1, 10, false)

				if self._curer then
					local villager = villager_obj:get_luaentity ()
					villager:record_gossip (self._curer, "major_positive", 20)
					villager:record_gossip (self._curer, "minor_positive", 25)
					awards.unlock(self._curer, "mcl:zombie_doctor")
				end
				return false
			end
		end
	end
end

------------------------------------------------------------------------
-- Zombie Villager visuals.
------------------------------------------------------------------------

local zombie_villager_professions = {
	armorer = {
		texture = "mobs_mc_zombie_villager_profession_armorer.png",
	},
	butcher = {
		texture = "mobs_mc_zombie_villager_profession_butcher.png",
	},
	cartographer = {
		texture = "mobs_mc_zombie_villager_profession_cartographer.png",
	},
	cleric = {
		texture = "mobs_mc_zombie_villager_profession_cleric.png",
	},
	farmer = {
		texture = "mobs_mc_zombie_villager_profession_farmer.png",
	},
	fisherman = {
		texture = "mobs_mc_zombie_villager_profession_fisherman.png",
	},
	fletcher = {
		texture = "mobs_mc_zombie_villager_profession_fletcher.png",
	},
	leatherworker = {
		texture = "mobs_mc_zombie_villager_profession_leatherworker.png",
	},
	librarian = {
		texture = "mobs_mc_zombie_villager_profession_librarian.png",
	},
	mason = {
		texture = "mobs_mc_zombie_villager_profession_mason.png",
	},
	shepherd = {
		texture = "mobs_mc_zombie_villager_profession_shepherd.png",
	},
	toolsmith = {
		texture = "mobs_mc_zombie_villager_profession_toolsmith.png",
	},
	weaponsmith = {
		texture = "mobs_mc_zombie_villager_profession_weaponsmith.png",
	},
	nitwit = {
		texture = "mobs_mc_zombie_villager_profession_nitwit.png",
	},
}

local profession_names = {}

for key, _ in pairs (zombie_villager_professions) do
	table.insert (profession_names, key)
end

local zombie_villager_type_overlays = {
	taiga = "mobs_mc_zombie_villager_taiga.png",
	swamp = "mobs_mc_zombie_villager_swamp.png",
	snowy = "mobs_mc_zombie_villager_snow.png",
	savanna = "mobs_mc_zombie_villager_savanna.png",
	plains = "mobs_mc_zombie_villager_plains.png",
	jungle = "mobs_mc_zombie_villager_jungle.png",
	desert = "mobs_mc_zombie_villager_desert.png",
}

local desert_p, jungle_p, savannah_p, snowy_p, taiga_p, swamp_p

core.register_on_mods_loaded (function ()
	desert_p = mcl_biome_dispatch.make_biome_test ({
		"#is_badlands",
		"Desert",
	})
	jungle_p = mcl_biome_dispatch.make_biome_test ({
		"#is_jungle",
	})
	snowy_p = mcl_biome_dispatch.make_biome_test ({
		"DeepFrozenOcean",
		"FrozenOcean",
		"FrozenPeaks",
		"FrozenRiver",
		"Grove",
		"IceSpikes",
		"JaggedPeaks",
		"SnowyBeach",
		"SnowyPlains",
		"SnowySlopes",
		"SnowyTaiga",
	})
	savannah_p = mcl_biome_dispatch.make_biome_test ({
		"#is_savannah",
	})
	taiga_p = mcl_biome_dispatch.make_biome_test ({
		"OldGrowthPineTaiga",
		"OldGrowthSpruceTaiga",
		"Taiga",
		"WindsweptForest",
		"WindsweptGravellyHills",
		"WindsweptHills",
	})
	swamp_p = mcl_biome_dispatch.make_biome_test ({
		"Swamp",
		"MangroveSwamp",
	})
end)

local function zombie_villager_type_from_biome (name)
	if not name then
		return "plains"
	end

	if desert_p (name) then
		return "desert"
	elseif jungle_p (name) then
		return "jungle"
	elseif savannah_p (name) then
		return "savanna"
	elseif snowy_p (name) then
		return "snowy"
	elseif taiga_p (name) then
		return "taiga"
	elseif swamp_p (name) then
		return "swamp"
	else
		return "plains"
	end
end

local badge_textures = {
	"mobs_mc_stone.png",
	"mobs_mc_iron.png",
	"mobs_mc_gold.png",
	"mobs_mc_emerald.png",
	"mobs_mc_diamond.png",
}

function zombie_villager:get_overlaid_texture ()
	local data = self._previous_incarnation
	if not data then
		return "mobs_mc_zombie_villager.png"
	end

	local overlay = zombie_villager_type_overlays[data.villager_type]
	local profession = data.profession
		and zombie_villager_professions[data.profession]
	local textures = {}

	table.insert (textures, "mobs_mc_zombie_villager_base.png")
	if overlay ~= "" then
		table.insert (textures, overlay)
	end
	if profession and profession.texture then
		table.insert (textures, profession.texture)

		local badge = badge_textures[data.tier or 0]
		if badge then
			table.insert (textures, badge)
		end
	end
	return table.concat (textures, "^")
end

function zombie_villager:mob_activate (staticdata, dtime)
	if not zombie.mob_activate (self, staticdata, dtime) then
		return false
	end
	if not self._previous_incarnation then
		local self_pos = self.object:get_pos ()
		local biomename = mcl_biome_dispatch.get_biome_name (self_pos)
		local villager_type = zombie_villager_type_from_biome (biomename)
		local profession = profession_names[pr:next (1, #profession_names)]
		self._previous_incarnation = {
			villager_type = villager_type,
			xp = 0,
			tier = 1,
			profession = profession,
			gossips = {},
			reputation = {},
			trades = {},
		}
	end
	self.base_texture[1] = self:get_overlaid_texture ()
	self:set_textures (self.base_texture)
	self:set_armor_texture ()
	return true
end

function zombie_villager:update_textures ()
	self.base_texture = {
		self:get_overlaid_texture (),
		"blank.png",
		"blank.png",
	}
	self:set_textures (self.base_texture)
	self.base_mesh = self.initial_properties.mesh
	self.base_size = self.initial_properties.visual_size
	self.base_colbox = self.initial_properties.collisionbox
	self.base_selbox = self.initial_properties.selectionbox
end

local zombie_villager_poses = {
	default = {
		["arm.left.001"] = {},
		["arm.right.001"] = {},
	},
	aggressive = {
		["arm.left.001"] = {
			nil,
			vector.new (-155, 0, 180),
			nil,
		},
		["arm.right.001"] = {
			nil,
			vector.new (-155, 0, 180),
			nil,
		},
	},
}

mcl_mobs.define_composite_pose (zombie_villager_poses, "jockey", {
	["leg.right"] = {
		nil,
		vector.new (-90, 35, 0),
	},
	["leg.left"] = {
		nil,
		vector.new (-90, -35, 0),
	},
})

mcl_mobs.define_composite_pose (zombie_villager_poses, "child", {
	["head.scale"] = {
		nil,
		nil,
		vector.new (1.5, 1.5, 1.5),
	},
})

zombie_villager._arm_poses = zombie_villager_poses

function zombie_villager:wielditem_transform (info, stack)
	local rot, pos, size
		= mob_class.wielditem_transform (self, info, stack)
	size.x = size.x / 2.75
	size.y = size.y / 2.75
	return rot, pos, size
end

function zombie_villager:select_arm_pose ()
	local pose = zombie.select_arm_pose (self)
	if self.child then
		return "child_" .. pose
	else
		return pose
	end
end

------------------------------------------------------------------------
-- Zombie Villager AI.
------------------------------------------------------------------------

function zombie_villager:tick_breeding ()
	-- Zombie Villagers may be children, but do not breed or
	-- mature.
	return
end

function zombie_villager:drop_player_equipment ()
	self:drop_armor (0.0, 2.0)
	self:drop_wielditem (0.0, 2.0)
	self:drop_offhand_item (0.0, 2.0)
end

mcl_mobs.register_mob ("mobs_mc:villager_zombie", zombie_villager)

------------------------------------------------------------------------
-- Zombie Villager spawning.
------------------------------------------------------------------------

-- spawn eggs
mcl_mobs.register_egg ("mobs_mc:villager_zombie", S("Zombie Villager"), "#563d33", "#799c66", 0)

------------------------------------------------------------------------
-- Modern Zombie Villager spawning.
------------------------------------------------------------------------

local non_desert_biomes = {}

for _, biome in pairs (mobs_mc.monster_biomes) do
	if biome ~= "Desert" then
		table.insert (non_desert_biomes, biome)
	end
end

local zombie_villager_spawner = table.merge (mobs_mc.monster_spawner, {
	name = "mobs_mc:villager_zombie",
	weight = 5,
	pack_max = 1,
	pack_min = 1,
	biomes = non_desert_biomes,
})

local zombie_villager_spawner_desert = table.merge (mobs_mc.monster_spawner, {
	name = "mobs_mc:villager_zombie",
	weight = 1,
	pack_max = 1,
	pack_min = 1,
	biomes = {
		"Desert",
	},
})

mcl_mobs.register_spawner (zombie_villager_spawner)
mcl_mobs.register_spawner (zombie_villager_spawner_desert)
