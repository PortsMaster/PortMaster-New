-------------------------------------------------------------------------
-- Spawning initialization.
-------------------------------------------------------------------------

local S = core.get_translator (core.get_current_modname ())

local only_peaceful_mobs
	= core.settings:get_bool ("only_peaceful_mobs", false)

mobs_mc.overworld_biomes = {
	"BambooJungle",
	"Beach",
	"BirchForest",
	"CherryGrove",
	"DarkForest",
	"DeepColdOcean",
	"DeepFrozenOcean",
	"DeepLukewarmOcean",
	"DeepOcean",
	"Desert",
	"DripstoneCaves",
	"ErodedMesa",
	"FlowerForest",
	"Forest",
	"FrozenOcean",
	"FrozenPeaks",
	"FrozenRiver",
	"Grove",
	"IceSpikes",
	"JaggedPeaks",
	"Jungle",
	"LukewarmOcean",
	"LushCaves",
	"MangroveSwamp",
	"Meadow",
	"Mesa",
	"MushroomIslands",
	"Ocean",
	"OldGrowthBirchForest",
	"OldGrowthPineTaiga",
	"OldGrowthSpruceTaiga",
	"Plains",
	"River",
	"Savannah",
	"SavannahPlateau",
	"SnowyBeach",
	"SnowyPlains",
	"SnowySlopes",
	"SnowyTaiga",
	"SparseJungle",
	"StonyPeaks",
	"StonyShore",
	"SunflowerPlains",
	"Swamp",
	"Taiga",
	"WarmOcean",
	"WindsweptForest",
	"WindsweptGravellyHills",
	"WindsweptHills",
	"WindsweptSavannah",
	"WoodedMesa",
}

mobs_mc.farm_animal_biomes = {
	"BambooJungle",
	"BirchForest",
	"CherryGrove",
	"DarkForest",
	"FlowerForest",
	"Forest",
	"Jungle",
	"OldGrowthBirchForest",
	"OldGrowthPineTaiga",
	"OldGrowthSpruceTaiga",
	"Plains",
	"SavannahPlateau",
	"Savannah",
	"SnowyTaiga",
	"SparseJungle",
	"SunflowerPlains",
	"Swamp",
	"Taiga",
	"WindsweptForest",
	"WindsweptGravellyHills",
	"WindsweptHills",
	"WindsweptSavannah",
}

mobs_mc.monster_biomes = {
	"BambooJungle",
	"Beach",
	"BirchForest",
	"CherryGrove",
	"ColdOcean",
	"DarkForest",
	"DeepColdOcean",
	"DeepFrozenOcean",
	"DeepLukewarmOcean",
	"DeepOcean",
	"Desert",
	"DripstoneCaves",
	"ErodedMesa",
	"FlowerForest",
	"Forest",
	"FrozenOcean",
	"FrozenPeaks",
	"FrozenRiver",
	"Grove",
	"IceSpikes",
	"JaggedPeaks",
	"Jungle",
	"LukewarmOcean",
	"LushCaves",
	"MangroveSwamp",
	"Meadow",
	"Mesa",
	"Ocean",
	"OldGrowthBirchForest",
	"OldGrowthPineTaiga",
	"OldGrowthSpruceTaiga",
	"Plains",
	"River",
	"Savannah",
	"SavannahPlateau",
	"SnowyBeach",
	"SnowyPlains",
	"SnowySlopes",
	"StonyPeaks",
	"StonyShore",
	"SunflowerPlains",
	"Swamp",
	"Taiga",
	"WarmOcean",
	"WindsweptGravellyHills",
	"WindsweptHills",
	"WindsweptSavannah",
	"WoodedMesa",
}

-------------------------------------------------------------------------
-- Default spawners.
-------------------------------------------------------------------------

-- Land animals.

local default_spawner = mcl_mobs.default_spawner
local animal_spawner = table.merge (default_spawner, {
	spawn_category = "creature",
	spawn_placement = "ground",
})

function animal_spawner:test_supporting_node (node)
	return core.get_item_group (node.name, "grass_block") > 0
end

function animal_spawner:describe_supporting_nodes ()
	return S ("on grass nodes")
end

function animal_spawner:get_misc_spawning_description ()
	return S ("This mob will spawn infrequently @1 with a surface occupying a full node when no obstructions exist within a volume @2 nodes in size around the center of such a node's upper surface, in light levels of 8 or greater.",
		  self:describe_supporting_nodes (), self:describe_mob_collision_box ())
end

function animal_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache,
					     spawn_flag)
	local light = core.get_node_light (node_pos)
	if not light or light <= 8 then
		return false
	end
	local node_below = self:get_node (node_cache, -1, node_pos)
	if self:test_supporting_node (node_below) then
		if default_spawner.test_spawn_position (self, spawn_pos,
							node_pos, sdata,
							node_cache,
							spawn_flag) then
			return true
		end
	end
	return false
end

mobs_mc.animal_spawner = animal_spawner

-- Aquatic animals.

local default_spawner = mcl_mobs.default_spawner
local aquatic_animal_spawner = table.merge (default_spawner, {
	spawn_category = "water_ambient",
	spawn_placement = "aquatic",
})

function aquatic_animal_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache,
						     spawn_flag)
	if spawn_pos.y > 0.5 or spawn_pos.y < -12.5 then
		return false
	end

	local node_below = self:get_node (node_cache, -1, node_pos)
	local node_above = self:get_node (node_cache, 1, node_pos)
	if core.get_item_group (node_below.name, "water") > 0
		and core.get_item_group (node_above.name, "water") > 0 then
		if default_spawner.test_spawn_position (self, spawn_pos,
							node_pos, sdata,
							node_cache,
							spawn_flag) then
			return true
		end
	end
	return false
end

function aquatic_animal_spawner:get_misc_spawning_description ()
	return S ("This mob will spawn between sea level and Y level -12 when the nodes above and below are water and no obstructions exist within a volume @1 nodes in size around the center of the base of the fluid node where spawning is being attempted.",
		  self:describe_mob_collision_box ())
end

mobs_mc.aquatic_animal_spawner = aquatic_animal_spawner

-- Monsters.

local monster_spawner = table.merge (default_spawner, {
	spawn_placement = "ground",
	spawn_category = "monster",
	pack_min = 4,
	pack_max = 4,
	max_artificial_light = 0,
	max_light = 6,
})

function monster_spawner:test_spawn_position (spawn_pos, node_pos, sdata, node_cache,
					      spawn_flag)
	if mcl_vars.difficulty == 0 or only_peaceful_mobs then
		return false
	end

	local node_data = self:get_node (node_cache, 0, node_pos)
	local light = core.get_artificial_light (node_data.param1)
	if spawn_flag ~= "trial_spawner" and (not light or light > self.max_artificial_light) then
		return false
	end

	if default_spawner.test_spawn_position (self, spawn_pos, node_pos,
						sdata, node_cache, spawn_flag) then
		-- Natural light tests are expensive...
		local natural_light = core.get_natural_light (node_pos)
		if spawn_flag ~= "trial_spawner"
			and (
				not natural_light
				or natural_light > self.max_light
				or natural_light > math.random (0, 31)
			) then
			return false
		end
		return true
	end
	return false
end

function monster_spawner:describe_additional_spawning_criteria ()
	if self.max_artificial_light == 15 and self.max_light >= 14 then
		return nil
	elseif self.max_artificial_light == 0 then
		return S ("Spawning will only succeed in the absence of artificial lighting and if the natural light is @1 or dimmer.", self.max_light)
	elseif self.max_light == 15 then
		return S ("Spawning will only succeed between artificial light levels of 0 and @1.", self.max_artificial_light)
	elseif self.max_artificial_light >= 14 then
		return S ("Spawning will only succeed between natural light levels of 0 and @1.", self.max_light)
	else
		return S ("Spawning will only succeed between artificial light levels of 0 and @1, and natural light levels of 0 and @2.", self.max_artificial_light, self.max_light)
	end
end

mobs_mc.monster_spawner = monster_spawner

-------------------------------------------------------------------------
-- Default structure spawning configurations.
-------------------------------------------------------------------------

mcl_mobs.suppress_spawning_in_structure ("mcl_levelgen:trial_chambers", "ambient")
mcl_mobs.suppress_spawning_in_structure ("mcl_levelgen:trial_chambers", "axolotl")
mcl_mobs.suppress_spawning_in_structure ("mcl_levelgen:trial_chambers", "creature")
mcl_mobs.suppress_spawning_in_structure ("mcl_levelgen:trial_chambers", "monster")
mcl_mobs.suppress_spawning_in_structure ("mcl_levelgen:trial_chambers", "underground_water_creature")
mcl_mobs.suppress_spawning_in_structure ("mcl_levelgen:trial_chambers", "water_ambient")
mcl_mobs.suppress_spawning_in_structure ("mcl_levelgen:trial_chambers", "water_creature")
