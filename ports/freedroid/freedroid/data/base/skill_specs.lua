
--Artwork internal code
--#Radial wave 0-2; 0=blue-sparks, 1=green/poison, 2=fire
--#Bullet 0-30?

skill_list {

{
	name =_"Hacking",
	icon = "TakeoverTalkSkill.png",
	target = "bot",
	form = "instant",
	effect = {type = "takeover"},
	cost = {base = 30, per_level = 10},
	description =_[[Linarians are gifted with the ability to hack any hostile bot in no time. With this program selected, initiate the takeover process by right clicking a hostile machine of your choice.]],
	startup = true,
},
--------------------------------------------------------------------------------

{
	name =_"Repair equipment",
	icon = "RepairSkill.png",
	form = "special",
	effect = {type = "repair"},
	description =_[[Fully repair any item of your choice. To use this skill, select it, open the inventory screen and then right click on the item you wish to repair. While you can repair items without incurring any cost, the item will get reduced maximum durability.]],
	startup = true,
},
--------------------------------------------------------------------------------

{
	name =_"Use weapon",
	icon = "WeaponSkill.png",
	form = "special",
	effect = {type = "weapon"},
	cost = {base = 0},
	description =_[[This skill allows you to force an attack on something not normally a target or to fire single shots with automatic weapons.]],
	startup = true,
},
--------------------------------------------------------------------------------

{
	name =_"Emergency shutdown",
	icon = "Shutdown.png",
	form = "self",
	effect = {type = "paralyze", duration = {base = 14, per_level = -1}},
	cost = {base = -100, per_level = -10},
	description =_[[Everyone needs to turn off and cool down a bit now and then. Just be careful that you are not still offline when enemy bots close in...]],
	startup = true,
},
--------------------------------------------------------------------------------

{
	name =_"Check system integrity",
	icon = "FirstAidSpell.png",
	form = "self",
	damage = {base = "-30"},
	effect = {type = "paralyze", duration = {base = 4.5, per_level = -0.5}},
	cost = {base = 30, per_level = 0},
	description =_[[While repairing damage, you must remember that patience is a virtue.]],
},
--------------------------------------------------------------------------------

{
	name =_"Sanctuary",
	icon = "TeleportHomeSpell.png",
	form = "self",
	effect = {type = "teleport_home"},
	cost = {base = 120, per_level = -10},
	description =_[[Effect: Teleport to town or back.
The art of rapidly moving away from danger is very useful. Even when used in reverse it has its uses.]],
},
--------------------------------------------------------------------------------

{
	name =_"Invisibility",
	icon = "Invisibility.png",
	form = "self",
	effect = {type = "invisibility", duration = {base = 5, per_level = 1}},
	cost = {base = 45, per_level = 10},
	description =_[[I am not the Linarian you are looking for.]],
},
--------------------------------------------------------------------------------

{
	name =_"Malformed packet",
	icon = "BadPacket.png",
	target = "bot",
	form = "instant",
	damage = {base = "5:7", per_level = 2},
	cost = {base = 15, per_level = 3},
	description =_[[When computers are presented with the unexpected, they can damage themselves.]],
},
--------------------------------------------------------------------------------

{
	name =_"Calculate Pi",
	icon = "Calculate_PI.png",
	target = "bot",
	form = "instant",
	effect = {type = "slowdown", duration = {base = 10, per_level = 1}},
	cost = {base = 14, per_level = 2},
	description =_[[It is not a big problem to make a badly designed system to go hunting for the impossible, causing a performance impact.]],
},
--------------------------------------------------------------------------------

{
	name =_"Blue Screen",
	icon = "BlueScreen.png",
	target = "bot",
	form = "instant",
	effect = {type = "paralyze", duration = {base = 5, per_level = 1}},
	cost = {base = 40},
	description =_[[With a little touch a war machine comes crashing down to a halt. For a while.]],
},
--------------------------------------------------------------------------------

{
	name =_"Broadcast Blue Screen",
	icon = "Poke.png",
	target = "bot",
	form = "radial",
	effect = {type = "paralyze", duration = {base = 3, per_level = 1}},
	cost = {base = 120},
	description =_[[With a little touch a war machine comes crashing down to a halt. For a while. The radio network is a wonderful invention for the people who like to blow up a lot of stuff at once.]],
	artwork = 0,
},
--------------------------------------------------------------------------------

{
	name =_"Virus",
	icon = "Virus.png",
	target = "bot",
	form = "instant",
	damage = {base = "10:30", per_level = 3},
	effect = {type = "slowdown", duration = {base = 12, per_level = 2}},
	cost = {base = 60, per_level = 5},
	description =_[[This is not just a firmware upgrade, my dear bot. You are about to find out what exactly I want to give you.]],
},
--------------------------------------------------------------------------------

{
	name =_"Broadcast virus",
	icon = "BroadcastVirus.png",
	target = "bot",
	form = "radial",
	damage = {base = "12:22", per_level = 2},
	effect = {type = "slowdown", duration = {base = 10, per_level = 1}},
	cost = {base = 100, per_level = 10},
	description =_[[The network is wide and dangerous. Many traps await for the weak and unprepared.]],
	artwork = 1,
},
--------------------------------------------------------------------------------

{
	name =_"Dispel smoke",
	icon = "DispellSmoke.png",
	target = "bot",
	form = "instant",
	damage = {base = "40:60", per_level = 7},
	cost = {base = 90, per_level = 5},
	description =_[[By heating up the chips with a malformed program you can cause them to release the magic smoke which keeps the bot running.]],
},
--------------------------------------------------------------------------------

{
	name =_"Killer poke",
	icon = "DetectItemsSpell.png",
	target = "bot",
	form = "instant",
	damage = {base = "80:160", per_level = 20},
	cost = {base = 180, per_level = 15},
	description =_[[Messing around with the bot's memory can cause it to severely damage itself, but the damage is greatly variable.]],
},
--------------------------------------------------------------------------------

-- Possibly Tux should also get some damage from it? "Everything is equal to it, even Tux."
{
	name =_"Plasma discharge",
	icon = "RadialPlasmaWaveSpell.png",
	target = "all",
	form = "radial",
	damage = {base = "40:60", per_level = 10},
	cost = {base = 150, per_level = 15},
	description =_[[The overload setting exists for emergencies. Plasma does not discriminate between bots and humans. Everything is the same to it.]],
	artwork = 2,
},
--------------------------------------------------------------------------------

{
	name =_"Network Mapper",
	icon = "NmapImage.png",
	form = "self",
	effect = {type = "nmap", duration = {base = 3, per_level = 1}},
	cost = {base = 40, per_level = -2},
	description =_[[Knowing what your enemies are up to is easy with a little signal intelligence. Displays enemy locations on your automap.]]
},
--------------------------------------------------------------------------------

{
	name =_"Light",
	icon = "Light.png",
	form = "self",
	effect = {type = "light", duration = {base = 5, per_level = 5}},
	cost = {base = 10, per_level = 1},
	description =_[[Let there be light...]],
},
--------------------------------------------------------------------------------

{
	-- TODO: Energy Shield currently competes with invisibility because the later
	-- does not have any vulnerability (except against boss). This is to be changed
	-- later.
	name =_"Energy Shield",
	icon = "ExplosionCircleSpell.png",
	form = "self",
	effect = {type = "shield", duration = {base = 8, per_level = 3}},
	cost = {base = 10, per_level = 2},
	description =_[[Creating an energy shield to protect you can be a very useful skill. Every hit that you get will be converted into heat. Beware: This heats up excessively. Equipment can still be damaged by heat. When you overheat, shield will try to automatically turn off to prevent damage to itself. It may provoke extra-heat on this process, so be sure to not let it happen.]],
},
--------------------------------------------------------------------------------

{
	name =_"Extract bot parts",
	icon = "ExtractBotParts.png",
	form = "self",
	effect = {type = "passive"},
	cost = {base = 0},
	description=_[[With a little knowledge, you can extract some useful parts out of the robots you kill. With each bot there is some hope of a part falling out. This skill is always active even when not selected.]],
},
--------------------------------------------------------------------------------

{
	name =_"Treasure Hunting",
	icon = "ChestAndDeadBodyLoot.png",
	form = "self",
	effect = {type = "passive"},
	cost = {base = 0},
	description=_[[Upgrading your search algorithms, you may find items more frequently when destroying bots. This skill is always active even when not selected.]],
},
--------------------------------------------------------------------------------

{
	name =_"Animal Magnetism",
	icon = "Poke.png",
	form = "self",
	effect = {type = "passive"},
	cost = {base = 0},
	description =_[[Get in tune with the magnetic fields around you! Grants you half-second extra time per skill level when hacking bots. This skill is always active even when not selected.]],
},
--------------------------------------------------------------------------------

-------------------------
----  Unused skills  ----
-------------------------

--[[ Potential future implementation

Nethack = takeover for humans. Possibly with a new minigame where you somehow make the human get sucked into playing the game turning it to a somewhat stupid bot, freezing them in place and agreeing to do things for you (eg like Tybalt will open the gate to RG house and let you past even if you are not yet a member). This would open up a lot of options for creating alternative storylines (eg never becoming an RG member).
]]--

{
	name =_"Nethack",
	icon = "Nethack.png",
	target = "human",
	form = "bullet",
	effect = {type = "paralyze", duration = {base = 15, per_level = 5}},
	cost = {base = 50, per_level = -5},
	description =_[[NOT IMPLEMENTED YET The open source game called Nethack is one of the world's greatest wasters of time. Machines don't care about it, but humans can get sucked in quite deeply.]],
	artwork = 5,
},
--------------------------------------------------------------------------------

--[[ Potential future implementation

Or make it something that can increase melee/shooting/programming ? Permanently and/or Temporarily?
]]--

{
	name =_"Reverse-engineer",
	icon = "ReverseEngineer.png",
	form = "self", --"aura",
	cost = {base = 100},
	description =_[[NOT IMPLEMENTED YET There is some dark magic in the art of turning devices or programs inside-out, picking them apart to learn all their secrets and putting them back again.]],
},

--------------------------------------------------------------------------------

--[[ Potential future implementation

Make this into something that increases tux fighting and movementspeed, but heats him up. Possibly make it into an "aura", active while program selected.
]]--

{
	name =_"Ricer CFLAGS",
	icon = "cflag.png",
	form = "self", --"aura",
	effect = {type = "burnup"},
	cost = {base = 100},
	description =_[[NOT IMPLEMENTED YET Optimization is the root of all evil. You can gain some temporary speed improvements to your system, but in the end you will likely overheat and cause permanent damage if you are not careful.]],
},

--------------------
----  Grenades  ----
--------------------

{
	name =_"Small Plasma grenade",
	icon = "NoSkillAvailable.png",
	target = "all",
	form = "radial",
	damage = {base = "100"},
	effect = {type = "short"},
	cost = {base = 200},
	description =_[[If you see this in game it is a bug. Please report this to the developers, unless you cheated, in which case you deserve to see this silly nonsense description.]],
	artwork = 2,
},
--------------------------------------------------------------------------------

{
	name =_"Plasma grenade",
	icon = "NoSkillAvailable.png",
	target = "all",
	form = "radial",
	damage = {base = "400"},
	cost = {base = 400},
	description =_[[If you see this in game it is a bug. Please report this to the developers, unless you cheated, in which case you deserve to see this silly nonsense description.]],
	artwork = 2,
},
--------------------------------------------------------------------------------

{
	name =_"Gas grenade",
	icon = "NoSkillAvailable.png",
	target = "human",
	form = "radial",
	damage = {base = "300"},
	cost = {base = 400},
	description =_[[If you see this in game it is a bug. Please report this to the developers, unless you cheated, in which case you deserve to see this silly nonsense description.]],
	artwork = 1,
},
--------------------------------------------------------------------------------

{
	name =_"Small EMP grenade",
	icon = "NoSkillAvailable.png",
	target = "bot",
	form = "radial",
	effect = {type = "short"},
	damage = {base = "75"},
	cost = {base = 200},
	description =_[[If you see this in game it is a bug. Please report this to the developers, unless you cheated, in which case you deserve to see this silly nonsense description.]],
	artwork = 0,
},
--------------------------------------------------------------------------------

{
	name =_"EMP grenade",
	icon = "NoSkillAvailable.png",
	target = "bot",
	form = "radial",
	damage = {base = "300"},
	cost = {base = 400},
	description =_[[If you see this in game it is a bug. Please report this to the developers, unless you cheated, in which case you deserve to see this silly nonsense description.]],
	artwork = 0,
},
--------------------------------------------------------------------------------

{
	name =_"Electronic Noise",
	icon = "NoSkillAvailable.png",
	target = "bot",
	form = "radial",
	effect = {type = "paralyze", duration = {base = 2}},
	cost = {base = 200},
	description =_[[If you see this in game it is a bug. Please report this to the developers, unless you cheated, in which case you deserve to see this silly nonsense description.]],
	artwork = 0,
},
--------------------------------------------------------------------------------

}
