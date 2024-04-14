# mcl_mobs
This mod was originally based of off "mobs_redo" (https://notabug.org/TenPlus1/mobs_redo) by TenPlus1.
Heavily modified and adapted for mineclonia / mcl2 by several people.

## Registering mobs and mob definition

A new mob is registered using
`mcl_mobs.register_mob(name, mob_definition)`

This takes care of registering the mob entity using fields from the definition below.

Since commit PR#598 (mineclonia 0.90) these special rules apply to the fields used in the mob definition, before this no custom fields could be used in the mob definition!

All fields that correspond to a minetest object property e.g. collisionbox, will automatically be moved to the `initial_properties` sub-table to comply with minetest 5.8 deprecation.

Fields not mentioned in this document can also be added as custom fields for the luaentity.


### Mob definition table
```lua
{
	nametag = "name",
	-- contains the name which is shown above mob.

	type = "monster",
	-- holds the type of mob that inhabits your world e.g.
		--"animal" fights as specified by 'specific_attack', 'group_attack', 'passive', and 'retaliates'. Killing mobs of 'type' "animal" won't award XP.
		-- "monster" enables attacking players or npcs (depending on 'attack_npcs') on sight in addition to 'specific_attack' processing. This behaviour requires setting 'attack_type' and can be modified using 'passive' and 'docile_by_day'. Even child variants will fight and give loot. Mobs of 'type' "npc" will attack mobs of 'type' "monster" on sight. All mobs of 'type' "monster" can be completely disabled by server setting 'only_peaceful_mobs'. Killing a mob of 'type' "monster" awards "Monster Hunter" achievement.
		-- "npc"  can follow owner. Fights as specified by 'specific_attack', 'group_attack', 'passive', and 'retaliates'. Will additionally attack all mobs of 'type' "monster" on sight (this is not affected by 'passive', bug or feature?).

	hp_min = 1,
	-- the minimum health value the mob can spawn with.

	hp_max = 20,
	-- the maximum health value the mob can spawn with.

	breath_max = -1,
	-- The maximum breath value the mob can spawn with and can have. If -1 (default), mob does not take drowning damage.

	breathes_in_water = true,
	--If true, mob loses breath when not in water. Otherwise, mob loses breath when inside a node with `drowning` attribute set (default: false).

	armor = 100,
	-- entity armor groups (see lua_api.txt). If table, a list of armor groups like for entities. If number, set value of 'fleshy' armor group only. Note: The 'immortal=1' armor group will automatically be added since this mod handles health and damage manually. Default: 100 (mob will take full dmg from 'fleshy' hits)

	passive = false,
	--if true disables standard behaviour of attacking players (and npcs - depending on 'attack_npcs') on sight for mob 'type' "monster", disables processing of the 'specific_attack' table unless aggroed for all mobs, and even prevents retaliation against direct attacks unless overriden by 'retaliates'. 'group_attack' processing is not affected by 'passive' (bug or feature?).

	retaliates = false,
	-- if true this mob will retaliate against direct attacks even if 'passive' is set to true.

	walk_velocity = 4,
	-- is the speed that your mob can walk around.

	run_velocity = 6,
	-- the speed your mob can run with, usually when attacking.

	walk_chance = 50,
	-- has a 0-100 chance value your mob will walk from standing, set to 0 for jumping mobs only.

	jump = true,
	-- when true allows your mob to jump updwards.

	jump_height = 1,
	-- holds the height your mob can jump, 0 to disable jumping.

	stepheight = 0.6,
	-- height of a block that your mob can easily walk up onto, defaults to 0.6.

	fly = false,
	-- when true allows your mob to fly around instead of walking.

	fly_in = { "mcl_core:water_source" },
	-- holds the node name or a table of node names in which the mob flies (or swims) around in. The special name '__airlike' stands for all nodes with 'walkable=false' that are not liquids

	runaway = false,
	-- if true causes animals to turn and run away when hit.

	view_range = 20,
	-- how many nodes in distance the mob can see a player.

	damage = 0,
	-- how many health points the mob does to a player or another mob when melee attacking.

	knock_back = false,
	-- when true has mobs falling backwards when hit, the greater the damage the more they move back.

	fear_height = 7,
	-- is how high a cliff or edge has to be before the mob stops walking, 0 to turn off height fear.

	fall_speed = -9.81,
	-- has the maximum speed the mob can fall at, default is -10.

	fall_damage = true,
	-- when true causes falling to inflict damage.

	water_damage = 0,
	-- holds the damage per second infliced to mobs when standing in water (default: 0).

	lava_damage = 8,
	-- holds the damage per second inflicted to mobs when standing in lava (default: 8).

	fire_damage = 1,
	-- holds the damage per second inflicted to mobs when standing in fire (default: 1).

	light_damage = 1,
	-- holds the damage per second inflicted to mobs when it's too bright (above 13 light).

	suffocation = false,
	-- when true causes mobs to suffocate inside solid blocks (2 damage per second).

	floats = 1,
	-- when set to 1 mob will float in water, 0 has them sink.

	follow = { "mcl_core:apple" },
	-- mobs follow player when holding any of the items which appear on this table, the same items can be fed to a mob to tame or breed e.g. {"farming:wheat", "default:apple"}

	reach = 3,
	-- is how far the mob can attack player when standing nearby, default is 3 nodes.

	docile_by_day = false,
	-- when true has mobs wandering around during daylight hours and only attacking player at night or when provoked.

	attacks_monsters = false,
	-- when true has npc's attacking monsters or not.

	attack_animals = false,
	-- does nothing...use 'specific_attack' instead.

	attack_npcs = false,
	-- when true mobs of 'type' "monster" will attack npcs in addition to players.

	owner_loyal = true,
	-- when true will have tamed mobs attack anything player punches when nearby.

	group_attack = false,
	-- when true all mobs of the same name in range will group together to attack offender if one of them gets attacked. When a table, this is a list of mob names that will get alerted as well (besides same mob). Only mobs that already have any target to attack or are owned by the offender will not participate in the group attack.

	attack_type = "dogfight",
	-- tells the api what a mob does when attacking the player or another mob:
		--	dogfight - is a melee attack when player is within mob reach.
		--	shoot - has mob shoot pre-defined arrows at player when inside view_range.
		--	dogshoot - has melee attack when inside reach and shoot attack when inside view_range.
		--	explode - causes mob to stop and explode when inside reach.

	explosion_radius = 1,
	-- the radius of explosion node destruction, defaults to 1

	explosion_damage_radius = 2,
	-- the radius of explosion entity & player damage,	defaults to explosion_radius * 2

	explosion_timer 3,
	-- number of seconds before mob explodes while its target is still inside reach or explosion_damage_radius, defaults to 3.

	explosiontimer_reset_radius = 6,
	--The distance you must travel before the timer will be reset.

	allow_fuse_reset = true,
	-- Allow 'explode' attack_type to reset fuse and resume chasing if target leaves the blast radius or line of sight. Defaults to true.

	stop_to_explode = true,
	-- When set to true (default), mob must stop and wait for explosion_timer in order to explode. If false, mob will continue chasing.

	arrow = "mcl_bows:arrow_entity",
	-- holds the pre-defined arrow object to shoot when attacking.

	dogshoot_switch = 1,
	-- allows switching between attack types by using timers (1 for shoot, 2 for dogfight)

	dogshoot_count_max = 5,
	-- contains how many seconds before switching from dogfight to shoot.

	dogshoot_count2_max = 5,
	-- contains how many seconds before switching from shoot to dogfight.

	shoot_interval = 1,
	-- has the number of seconds between shots.

	shoot_offset = 0,
	-- holds the y position added as to where the arrow/fireball appears on mob.

	specific_attack = { "player", "mobs_mc:cow" },
	--has a table of entity names that mob can also attack e.g. {"player", "mobs_animal:chicken"}.

	runaway_from = { "player", "mobs_mc:cat" },
	-- contains a table with mob/node names to run away from, add "player" to list to runaway from player also.

	avoid_from = {},
	-- contains a table with mob/node names to avoid from, add "player" to list to avoid from player (wielding) also.

	pathfinding = 1,
	-- set to 1 for mobs to use pathfinder feature to locate player, set to 2 so they can build/break also (only works with dogfight attack and when 'mobs_griefing' in minetest.conf is not false).

	immune_to = {},
	-- is a table that holds specific damage when being hit by certain items e.g. {"default:sword_wood",0} -- causes no damage, {"default:gold_lump", -10} -- heals by 10 health points, {"default:coal_block", 20} -- 20 damage when hit on head with coal blocks.

	makes_footstep_sound = true,
	-- when true you can hear mobs walking.

	sounds =
	-- this is a table with sounds of the mob Note: For all sounds except fuse and explode, the pitch is slightly randomized from the base pitch. The pitch of children is 50% higher.
	{
		distance = "",
		-- maximum distance sounds can be heard, default is 10.

		base_pitch = "",
		-- base pitch to use adult mobs, default is 1.0
		random = "",
		-- played randomly from time to time. also played for overfeeding animal.

		eat = "",
		-- played when mob eats something

		war_cry = "",
		-- what you hear when mob starts to attack player. (currently disabled)
		attack = "",
		-- what you hear when being attacked.

		shoot_attack = "",	-- sound played when mob shoots.
		damage = "",
		-- sound heard when mob is hurt.

		death = "",
		-- played when mob is killed.

		jump = "",
		-- played when mob jumps. There's a built-in cooloff timer to avoid sound spam

		flop = "",
		-- played when mob flops (like a stranded fish)

		fuse = "",
		-- sound played when mob explode timer starts.

		explode = "",
		-- sound played when mob explodes.
	}
	sounds_child = {},
	-- same as sounds, but for childs. If not defined, childs will use same sound as adults but with higher pitch
	sound_params = {},
	--optional table of `sound parameters` to be applied to this mobs' sounds
	drops =
		-- table of items that are dropped when mob is killed, fields are:
	{
		name = "mcl_core:cobble",
		-- name of item to drop.

		chance = 1,
		--chance of drop, 1 for always, 2 for 1-in-2 chance etc.

		min = 1,
		--minimum number of items dropped.

		max = 5,
		--maximum number of items dropped.
	},

	textures = {},
	-- holds a table list of textures to be used for mob, or you could use multiple lists inside another table for random selection e.g. { {"texture1.png"}, {"texture2.png"} }

	child_texture = {},
	-- holds the texture table for when baby mobs are used.

	gotten_texture = {},
	-- holds the texture table for when self.gotten value istrue, used for milking cows or shearing sheep.

	gotten_mesh = "mesh.b3d",
	-- holds the name of the external object used for when self.gotten is true for mobs.

	rotate = 0,
	-- custom model rotation, 0 = front, 90 = side, 180 = back, 270 = other side.

	double_melee_attack = false,
	-- when true has the api choose between 'punch' and 'punch2' animations.

	pushable = true,
	-- Allows players, & other mobs to push the mob.

	animation =
	-- holds a table containing animation names and settings for use with mesh models: Using '_loop = false' setting will stop any of the animations from looping. 'speed_normal' is used for animation speed for compatibility with some older mobs.
	{
		stand_start = 10,
		--start frame for when mob stands still.

		stand_end = 10,
		--end frame of stand animation.

		stand_speed = 10,
		-- speed of animation in frames per second.

		walk_start = 10,
		--when mob is walking around.
		walk_end = 10,
		walk_speed = 10,

		run_start = 10,
		-- when a mob runs or attacks.
		run_end = 10,
		run_speed = 10,

		fly_start = 10,
		-- when a mob is flying.
		fly_end = 10,
		fly_speed = 10,

		punch_start = 10,
		-- when a mob melee attacks.
		punch_end = 10,
		punch_speed = 10,

		punch2_start = 10,
		-- alternative melee attack animation.
		punch2_end = 10,
		punch2_speed = 10,

		shoot_start = 10,
		-- shooting animation.
		shoot_end = 10,
		shoot_speed = 10,

		die_start = 10,
		-- death animation
		die_end = 10,
		die_speed = 10,
		die_loop = 10,
		-- when set to false stops the animation looping.
	}

	spawn_class = "hostile",
	-- Classification of mod for the spawning algorithm: "hostile" changes default light levels to 0-7 from 7-max+1, "passive" changes default of 'can_despawn' to false and reduces spawning occurences to the PASSIVE_INTERVAL (20s), "ambient" or "water" (or any other string) have no effect

	ignores_nametag = false,
	-- if true, mob cannot be named by nametag

	rain_damage = 0
	-- damage per second if mob is standing in rain (default: 0)

	sunlight_damage = 0,
	-- holds the damage per second inflicted to mobs when they are in direct sunlight

	spawn_small_alternative = "",
	-- name of a smaller mob to use as replacement if spawning fails due to space requirements

	glow = 0,
	-- same as in entity definition

	child = false,
	-- if true, spawn mob as child. Killing child variants of mobs won't award XP.

	shoot_arrow = function(self, pos, dir) end,
	-- function that is called when mob wants to shoot an arrow. You can spawn your own arrow here. pos is mob position, dir is mob's aiming direction

	follow_velocity = 4,
	--The speed at which a mob moves toward the player when they're holding the appropriate follow item.

	instant_death = false,
	-- If true, mob dies instantly (no death animation or delay) (default: false)

	xp_min = 0,
	--the minimum XP it drops on death (default: 0)

	xp_max = 0,
	--the maximum XP it drops on death (default: 0)

	fire_resistant = false,
	--If true, the mob can't burn

	fire_damage_resistant = false,
	-- If true the mob will not take damage when burning

	ignited_by_sunlight = false,
	-- If true the mod will burn at daytime. (Takes sunlight_damage per second)

	nofollow = false,
	--Do not follow players when they wield the "follow" item. For mobs (like villagers) that are bred in a different way.

	pick_up = { "mcl_core:apple" },
	--table of itemstrings the mob will pick up (e.g. for breeding)

	on_pick_up = function(self, itementity),
	--function that will be called on item pickup - arguments are self and the itementity return a (modified) itemstack

	custom_visual_size = { x = 1, y = 1},
	-- will not reset visual_size from the base class on reload

	noyaw = false,
	-- If true this mob will not automatically change yaw

	particlespawners = {},
	-- Table of particlespawners attached to the mob. This is implemented in a coord safe manner i.e. spawners are only sent to players within the player_transfer_distance (and automatically removed). This enables infinitely lived particlespawners.

	doll_size_override = { x = 1, y = 1 },
	--visual_size override for use as a "doll" in mobspawners - used for visually large mobs

	extra_hostile = false,
	-- Attacks "everything that moves" (all mobs). Not implemented.

	attack_exception = function(obj) end,
	-- Exceptions for 'extra_hostile': Function that takes the object as argument. If it returns true that object will not be attacked. Not implemented.

	deal_damage = function(self, damage, mcl_reason)
	-- if present this gets called instead of the normal damage functions

	player_active_range = 48,
	-- Mobs further away from the player than this will stop moving (and doing most other things)

-- Object Properties
--------------------
--	Object properties can be defined right in the definition table for compatibility reasons. Note that these will be rewritten to "initial_properties" in the final mob entity.

}
```

### Mobs API functions
Every luaentity registered by mcl_mobs.register_mob has mcl_mobs.mob_class set as a metatable which, besides default values for fields in the luaentity provides a number of functions.

These functions can be called from the entity as well as overwritten on a per-mob basis.

"mob" refers to the luaentity of the mob in the following list:

 * mob:safe_remove()
	* removes the mob in the on_step allowing other functions to still run. It also extinguishes the mob if it is burning as to not leave behind flame entities.
 * mob:set_nametag(new_name)
	* sets the nametag of the mob
 * mob:set_properties(property_table)
	* works in the same way as mob.object:set_properties() would except that it will not set fields that are already set to the given value, potentially saving network bandwidth.

#### Breeding
 * mob:feed_tame(clicker, feed_count, breed, tame, notake)
 * mob:toggle_sit(clicker,p)

#### Combat
 * mob:day_docile()
	* Used to check if a "docile_by_day" mob is currently docile according to time. Returns true if mob is currently docile, false otherwise.
 * mob:do_attack(object)
	* Can be called to immediately attack a known object.
 * mob:smart_mobs(s, p, dist, dtime)
	* "Smart" pathfinding function to locate targets to attack. Will set the path to the found target.
 * mob:attack_players_and_npcs()
	* For monsters: function to find players or npcs to attack. Sets targets if found.
 * mob:attack_specific()
	* For all mobs: function to find specific things(mobs or players) to attack. Sets targets if found.
 * mob:attack_monsters()
	* For non-monsters: function to find specific monsters to attack. Sets targets if found.
 * mob:dogswitch(dtime)
	* This functions switches between dogshoot and dofight attack modes
* mob:boom(pos, strength, fire, no_remove)
	* Make the mob explode damaging players and entities and destroying nodes.
 * mob:safe_boom(pos, strength, no_remove)
	* Safe explosion that does not remove any nodes (when mobs_griefing is disabled)
 * mob:on_punch(hitter, tflp, tool_capabilities, dir)
	* Called when the mob is punched. Handles damage by default.
 * mob:check_aggro(dtime)
	* Periodically called and returns true if mob is still aggressive
 * mob:clear_aggro()
	* Clear all aggro settings of the mob
 * mob:do_states_attack(dtime)
	* This function manages the internal state machine of the mob.

#### Movement
 * mob:is_node_dangerous(nodename)
	* Function that checks if the mob considers the given node dangerous
 * mob:is_node_waterhazard(nodename)
	* Function that checks if the mob considers the given node a water hazard
 * mob:target_visible(origin)
	* Function that checks if the selected target is currently visible
 * mob:line_of_sight(pos1, pos2, stepsize)
	* Wrapper around minetest.line_of_sight that checks some additional stuff.
 * mob:can_jump_cliff()
	* Checks if mob is at a jumpable cliff.
 * mob:is_at_cliff_or_danger()
	* Checks if mob is facing a cliff it considers dangerous
 * mob:is_at_water_danger()
	* Checks if mob is facing water.
 * mob:env_danger_movement_checks(dtime)
	* This function runs all environment danger checks above.
 * mob:do_jump()
	* Jump if facing a solid node (not fences or gates)
 * mob:follow_holding(clicker)
	* Checks if mob should follow 'clicker'
 * mob:replace(pos)
	* Replaces node at position if node replacement is configured for this mob
 * mob:check_runaway_from()
	* Checks if there are objects the mob should run away from
 * mob:follow_flop()
	* Follow player if owner or holding item, if fish outta water then flop
 * mob:go_to_pos(b)
	* Turn in direction of pos and start moving forward.
 * mob:check_herd(dtime)
	* Herd movement logic: makes mob turn in the same direction as other mobs of the same type found nearby
 * mob:teleport(target)
	* Teleports the mobs to target pos
 * mob:do_states_walk()
	* State logic for the "walk" state
 * mob:do_states_stand()
	* State logic for the "stand" state
 * mob:do_states_runaway()
	* State logic for the "runaway" state
 * mob:check_smooth_rotation(dtime)
	* Turn slightly more towards selected target yaw for smooth rotation
 * mob:is_object_in_view(object_list, object_range, node_range, turn_around)
		Returns 'true' if an object (mob or node) is in the field of view.

			'object_list'		list of mob and/or node names
			'object_range'		maximum distance to a mob from object_list
			'node_range'            maximum distance to a node from object_list
			'turn_around'           true or false

#### Physics
 * mob:player_in_active_range()
	* Periodically checks if a player is in active range (default: 48), if it returns false mob will be suspended.
 * mob:object_in_range(object)
	* Checks if object is in view range of the mob
 * mob:object_in_follow_range(object)
	* Checks if object is in following range of the mob
 * mob:item_drop(cooked, looting_level)
	* Drop item drops (is run when mob dies)
 * mob:collision()
	* Mob collision logic
 * mob:slow_mob()
	* diffuse object velocity, slow down depending on state.
 * mob:set_velocity(v)
	* Turn in direction of v, set start moving, respects set orders.
 * mob:get_velocity()
	* Get combined mob velocity (speed) - returns a number not a vector!
 * mob:set_yaw(yaw, delay, dtime)
	* Sets mob yaw using smooth rotation
 * mob:flight_check()
	* Checks if mob is flying in what it is suppose to
 * mob:check_for_death(cause, cmi_cause)
	* Checks if mob is dead and runs death logic in that case.
 * mob:deal_light_damage(pos, damage)
	* Deal light damage to mob, returns true if mob died
 * mob:is_in_node(itemstring)
	* if mob is within a specific node or a node group (e.g. group:lava)
 * mob:do_env_damage()
	* Deals environment damage if applicable
 * mob:env_damage (dtime, pos)
	* Runs periodic checks for entity cramming and environment damage
 * mob:damage_mob(reason, damage)
	* Damage the mob
 * mob:check_entity_cramming()
	* Checks and deals entity cramming damage if applicable
 * mob:falling(pos)
	* Checks if mob is falling and applies acceleration accordingly
 * mob:check_water_flow()
	* Checks if mob is in flowing water and applies movement accordingly
 * mob:check_dying()
	* Checks if mob is currently dying and applies "falling to the side" rotation
 * mob:check_suspend()
	* Checks and suspends mob if needed.

#### Effects
 * mcl_mobs.effect(pos, amount, texture, min_size, max_size, radius, gravity, glow, go_down)
	* Custom particle effect for mobs
 * mob:mob_sound(soundname, is_opinion, fixed_pitch)
	* Emit a preconfigured mob sound
 * mob:add_texture_mod(mod)
	* Add a texture modifier to mob
 * mob:remove_texture_mod(mod)
	* Remove a texture modifier from mob
 * mob:damage_effect(damage)
	* Display damage effect (black hearts) depending on amount of damage
 * mob:remove_particlespawners(name)
	* Remove a permanent named particlespawner from mob
 * mob:add_particlespawners(pn)
	* Add a permanent named particlespawner to mob
 * mob:check_particlespawners(dtime)
	* Checks if particlespawners need to be deleted or sent to players
 * mob:set_animation(anim, fixed_frame)
	* Set a specific mob animation
 * mob:who_are_you_looking_at()
	* Check what to look at
 * mob:check_head_swivel(dtime)
	* Checks and applies head movement
 * mob:set_animation_speed()
	* Sets mob animation speed

#### Items
 * mob:set_armor_texture()
	* Sets armor textures from mob.armor_list
 * mob:check_item_pickup()
	* Checks and makes the mob pick up nearby item entities

#### Mount
 * mob:on_detach_child(child)
	* Kicks out "driver" (rider) if mob is a child and runs custom detach_child function.

#### Pathfinding
 * mob:gopath(target,callback_arrived)
	* pathfind a way to target and run callback on arrival

#### Custom Definition Functions

Along with the above mob registry settings we can also use custom functions to
enhance mob functionality and have them do many interesting things:

* `on_die`		 a function that is called when the mob is killed; the parameters are (self, pos). Return true to skip the builtin death animation and death effects
* `on_rightclick`its same as in minetest.register_entity()
* `on_blast`		is called when an explosion happens near mob when using TNT functions, parameters are (object, damage) and returns (do_damage, do_knockback, drops)
* `on_spawn`		is a custom function that runs on mob spawn with `self` as variable, return true at end of function to run only once.
* `after_activate` is a custom function that runs once mob has been activated with these paramaters (self, staticdata, def, dtime)
* `on_breed`		called when two similar mobs breed, paramaters are (parent1, parent2) objects, return false to stop child from being resized and owner/tamed flags and child textures being applied.Function itself must spawn new child mob.
* `on_grown`		is called when a child mob has grown up, only paramater is (self).
* `do_punch`		called when mob is punched with paramaters (self, hitter, time_from_last_punch, tool_capabilities, direction), return false to stop punch damage and knockback from taking place.
* `custom_attack`when set this function is called instead of the normal mob melee attack, parameters are (self, to_attack).
* `on_die`		 a function that is called when mob is killed (self, pos)
* `do_custom`	a custom function that is called every tick while mob is active and which has access to all of the self.* variables e.g. (self.health for health or self.standing_in for node status), return with `false` to skip remainder of mob API.
* `force_step`	a function that will run on every step before the player in range check is run

#### Internal Variables

The mob api also has some preset variables and functions that it will remember
for each mob.

* `self.health`		contains current health of mob (cannot exceed
						self.hp_max)
* `self.breath`		contains current breath of mob, if mob takes drowning
						damage at all (cannot exceed self.breath_max). Breath
						decreases by 1 each second while in a node with drowning
						damage and increases by 1 each second otherwise.
* `self.texture_list`contains list of all mob textures
* `self.child_texture` contains mob child texture when growing up
* `self.base_texture`contains current skin texture which was randomly
						selected from textures list
* `self.gotten`		this is used to track whether some special item has been
						gotten from the mob, for example, wool from sheep.
						Initialized as false, and the mob must set this value
						manually.
* `self.horny`		 when animal fed enough it is set to true and animal can
						breed with same animal
* `self.hornytimer`	background timer that controls breeding functions and
						mob childhood timings
* `self.child`		 used for when breeding animals have child, will use
						child_texture and be half size
* `self.owner`		 string used to set owner of npc mobs, typically used for
						dogs
* `self.order`		 set to "follow" or "stand" so that npc will follow owner
						or stand it`s ground
* `self.state`		 Current mob state.
						"stand": no movement (except turning around)
						"walk": walk or move around aimlessly
						"attack": chase and attack enemy
						"runaway": flee from target
						"flop": bounce around aimlessly
								(for swimming mobs that have stranded)
						"die": during death
* `self.nametag`		contains the name of the mob which it can show above


### Node Replacement
Mobs can look around for specific nodes as they walk and replace them to mimic
eating.

* `replace_what`	group of items to replace e.g.
				{"farming:wheat_8", "farming:carrot_8"}
				or you can use the specific options of what, with and
				y offset by using this instead:
				{
					{"group:grass", "air", 0},
					{"default:dirt_with_grass", "default:dirt", -1}
				}
* `replace_with`	replace with what e.g. "air" or in chickens case "mobs:egg"
* `replace_rate`	how random should the replace rate be (typically 10)
`replace_offset` +/- value to check specific node to replace

* `on_replace(self, pos, oldnode, newnode)`
	is called when mob is about to replace a node. Also called
	when not actually replacing due to mobs_griefing setting being false.
* `self`	ObjectRef of mob
* `pos`	 Position of node to replace
* `oldnode` Current node
* `newnode` What the node will become after replacing. If false is returned, the mob will not replace the node.	By default, replacing sets self.gotten to true and resets the object properties.

### Riding Mobs

Mobs can now be ridden by players and the following shows its functions and
usage:


`mcl_mobs.attach(self, player)`

This function attaches a player to the mob so it can be ridden.

 * 'self'	mob information
 * 'player' player information


`mcl_mobs.detach(player, offset)`

This function will detach the player currently riding a mob to an offset
position.

 * 'player' player information
 * 'offset' position table containing offset values


`mcl_mobs.drive(self, move_animation, stand_animation, can_fly, dtime)`

This function allows an attached player to move the mob around and animate it at
same time.

 * 'self'			mob information
 * 'move_animation'string containing movement animation e.g. "walk"
 * 'stand_animation' string containing standing animation e.g. "stand"
 * 'can_fly'		 if true then jump and sneak controls will allow mob to fly up and down
 * 'dtime'			tick time used inside drive function


`mcl_mobs.fly(self, dtime, speed, can_shoot, arrow_entity, move_animation, stand_animation)`

This function allows an attached player to fly the mob around using directional
controls.

 * 'self'			mob information
 * 'dtime'			tick time used inside fly function
 * 'speed'			speed of flight
 * 'can_shoot'		true if mob can fire arrow (sneak and left mouse button fires)
 * 'arrow_entity'	name of arrow entity used for firing
 * 'move_animation'string containing name of pre-defined animation e.g. "walk" or "fly" etc.
 * 'stand_animation' string containing name of pre-defined animation e.g. "stand" or "blink" etc.

Note: animation names above are from the pre-defined animation lists inside mob
registry without extensions.

Certain variables need to be set before using the above functions:

 * 'self.v2'				toggle switch used to define below values for the first time
 * 'self.max_speed_forward' max speed mob can move forward
 * 'self.max_speed_reverse' max speed mob can move backwards
 * 'self.accel'			 acceleration speed
 * 'self.terrain_type'	integer containing terrain mob can walk on (1 = water, 2 or 3 = land)
 * 'self.driver_attach_at'position offset for attaching player to mob
 * 'self.driver_eye_offset' position offset for attached player view
 * 'self.driver_scale'	sets driver scale for mobs larger than {x=1, y=1}

## Spawning mobs
Mobs can be added to the natural spawn cycle using

`mcl_mobs.spawn_setup(spawn_definition)`

### Spawn Definition table
```lua
{
	name = "mobs_mc:mob",
	--name of the mob to be spawned

	dimension = "overworld",
	--dimension this spawn rule applies to; overworld | nether | end

	type_of_spawning = "ground",
	-- "ground", "water" or "lava"

	biomes = nil,
	--table of biome names this rule applies to

	biomes_except = nil,
	--apply to all biomes of the dimension except the ones in this table (exclusive with biomes)

	min_light = 0,
	--minimum light value this rule applies to

	max_light = 15,
	--maximum light value ..

	chance = 10000,
	--chance the mob is spawned, higher values make spawning more likely

	aoc = 5,
	--"active object count", don't spawn mob if this amount of other mobs is already in the area

	min_height = -30912,
	--minimum Y position this rule applies to

	max_height = 30927,
	--maximum Y position this rule applies to

	check_position = function(pos) end,
	--function to check the position the mob would spawn at, return false to deny spawning

	on_spawn = function(pos) end,
	--function that will be run when the mob successfully spawned
}
```

## Commands
* /spawn_mob mob_name - spawns a mob at the player position
* /spawncheck mob_name runs through the natural spawn checks to verify if a mob can spawn at the players position (and if not gives a reason why spawning was denied)
* /mobstats - gives some statistics about the currently active mobs and spawn attempts on the whole server
* /clearmobs [<all> | <nametagged> | <tamed>] [<range>] - a safer alternative to /clearobjects that only applies to loaded mobs
## Mob Eggs
	mcl_mobs.register_egg(mob, desc, background_color, overlay_color, addegg, no_creative)

 * 'name'		this is the name of your new mob to spawn e.g. "mob:sheep"
 * 'description' the name of the new egg you are creating e.g. "Spawn Sheep"
 * 'background_color' and 'overlay_color' define the colors for the texture displayed for the egg in inventory
 * 'addegg'	would you like an egg image in front of your texture (1 = yes, 0 = no)
 * 'no_creative' when set to true this stops spawn egg appearing in creative mode for destructive mobs like Dungeon Masters.

## Mob projectiles
Custom projectiles for mobs can be registered using
 * mcl_mobs.register_arrow(name, arrow_def)
 * mcl_mobs.get_arrow_damage_func(damage, damage_type, shooter_object)
 * 	Returns a damage function to be used in arrow hit functions.

### Arrow definition
#### Object Properties
	Object properties can be defined right in the definition table for compatibility reasons. Note that these will be rewritten to "initial_properties" in the final mob entity.

```lua
{
	visual = "cube",
	--Same is in minetest.register_entity()

	visual_size = { x = 1, y = 1},
	--Same is in minetest.register_entity()

	textures = {},
	--Same is in minetest.register_entity()

	velocity = 1,
	--The velocity of the arrow

	drop = "",
	-- If set to true any arrows hitting a node will drop as item

	hit_player = function(self, player) end,
	-- A function that is called when the arrow hits a player; this function should hurt the player, the parameters are (self, player)

	hit_mob = function(self, mob) end,
	-- A function that is called when the arrow hits a mob; this function should hurt the mob, the parameters are (self, mob)

	hit_object = function(self, object) end,
	--a function that is called when the arrow hits an object that is neither a player nor a mob. this function should hurt the object, the parameters are (self, object)

	hit_node = function(self, pos, node) end,
	a function that is called when the arrow hits a node, the parameters are (self, pos, node)

	tail = 0,
	-- When set to 1 adds a trail or tail to mob arrows

	tail_texture = "",
	-- Texture string used for above effect

	tail_size = 5,
	-- Has size for above texture (defaults to between 5 and 10)

	expire = 0.25,
	-- Contains float value for how long tail appears for (defaults to 0.25)

	homing = false,
	-- Wether arrow corrects it's trajectory when target is moving.

	glow = 0,
	-- Has value for how brightly tail glows 1 to 10 (default is 0 for no glow)

	rotate = 0,
	-- Integer value in degrees to rotate arrow

	on_step =  function(dtime) end,
	-- Is a custom function when arrow is active, nil for default.
}
```
## External Settings for "minetest.conf"

 * 'enable_damage'			if true monsters will attack players (default is true)
 * 'only_peaceful_mobs'	if true only animals will spawn in game (default is false)
 * 'mcl_damage_particles'	if true, damage effects appear when mob is hit (default is true)
 * 'mobs_spawn_protected'	if set to false then mobs will not spawn in protected areas (default is true)
 * 'mob_difficulty'		sets difficulty level (health and hit damage multiplied by this number), defaults to 1.0.
 * 'mob_spawn_chance'		multiplies chance of all mobs spawning and can be set to 0.5 to have mobs spawn more or 2.0 to spawn less. e.g.1 in 7000 * 0.5 = 1 in 3500 so better odds of spawning.
 * 'mobs_spawn'			 if false then mobs no longer spawn without spawner or spawn egg.
 * 'mobs_drop_items'		when false mobs no longer drop items when they die.
 * 'mobs_griefing'			when false mobs cannot break blocks when using either pathfinding level 2, replace functions or mobs:boom
