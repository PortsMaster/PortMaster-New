-- Comments after the NPC names are meant to declare alternative i18n'd names
-- those will be set in dialog scripts (via a call to set_bot_name()).
-- Those declarations are currently needed, here, due to the separation between
-- the translation domains of dialog and config files.
npc_list{
	"WillGapes",             --[[ _"Will Gapes - MegaSys CSA" ]]--
	"Vending-Machine",       --[[TRM]]--
	"Tybalt",                --[[ _"Tybalt - Citadel Gate Guard" ]]--
	"TutorialTom",           --[[ _"Tutorial Tom" ]]--
	"TutorialTerminal",      --[[TRM]]--
	"Town-TuxGuard",         --[[ _"Red Guard Escort" ]]--
	"Town-TeleporterGuard",
	"Town-NorthGateGuard",
	"Town-GuardhouseGuard",
	"Town-614",
	"TestDroid",
	"Terminal",              --[[TRM]]--
	"Tania",                 --[[ _"Tania - lonely scientist" ]]--
	"Tamara",                --[[ _"Tamara - Librarian" ]]--
	"Stone",                 --[[ _"Stone - Shop owner", _"Lily Stone - Shop owner" ]]--
	"Spencer",
	"Speechless",
	"Sorenson",              --[[ _"Sorenson - Mystery coder" ]]--
	"Skippy",                --[[ _"Skippy - Map-Maker Maker" ]]--
	"Singularity-Drone",
	"Singularity",
	--	"Serge",
	"Scavenger",             --[[ _"Scavenger Bot" ]]--
	"Saul",                  --[[ _"Saul", _"Saul, leader of the Resistance" ]]--
	"Samson",                --[[ _"Coder", _"Samson, the Coder" ]]--
	"SADD",                  --[[ _"SADD - Exterminate Mode", _"SADD - Secret Area Defense Droid" ]]--
	"SACD",                  --[[TRM]]--
	"Richard",               --[[ _"Richard - Programmer" ]]--
	"Peter",
	"Pendragon",             --[[ _"Fighter", _"Pendragon - Fighter" ]]--
	"MS-Factory-Addon-Terminal",--[[TRM]]--
	"MO-RGGateGuardLeader",
	"MO-RGGateGuard",
	"MO-HFGateAccessServer", --[[TRM]]--
	"MiniFactory-Terminal",  --[[TRM]]--
	"Mike",
	"Michelangelo",          --[[ _"Michelangelo - Chef" ]]--
	"Maintenance-Terminal",  --[[TRM]]--
	"Lukas",
	--	"Lina",
	"Koan",                  --[[ _"Koan" ]]--
	"Kevin-Lawnmower",
	"KevinGuard",            --[[ _"614 - Kevin's Guard" ]]--
	"Kevin",                 --[[ _"Kevin - Hacker" ]]--
	"Karol",                 --[[ _"Karol - Shop owner" ]]--
	"John",
	"Jim",                   --[[ _"Jim", _"Jim - Portal Guardian" ]]--
	"Jennifer",
	"Jasmine",               --[[ _"Jasmine", _"Jasmine - Girlfriend of a true Hacker" ]]--
	"Iris",                  --[[ _"Iris", _"Iris - treasure hunter" ]]--
	"InvaderBot",
	"HF-FirmwareUpdateServer",--[[TRM]]--
	"HF-EntranceBot",
	"Geist",                 --[[ _"Geist - Hunter" ]]--
	"Francis",               --[[ _"Dr. Francis - Cryonicist" ]]--
	"FactionDeadBot",
	"Ewalds_296",
	"Ewald",                 --[[ _"Ewald - Barkeeper" ]]--
	"Erin",                  --[[ _"Erin - bot hunter", _"Bot hunter" ]]--
	"Engel",                 --[[ _"Engel - Hunter" ]]--
	"Duncan",                --[[ _"Duncan - Bombmaker" ]]--
	"Dude",
	"DSB-PowerControlGate1", --[[TRM]]--
	"DSB-PowerControl",      --[[TRM]]--
	"DSB-MachineDeckControl",--[[TRM]]--
	"DocMoore",              --[[ _"Doc Moore - Medic" ]]--
	"Dixon",                 --[[ _"Dixon - Mechanic" ]]--
	"DeadGuy",
	"Cult-Member",             --[[ _"Cult Member" ]]--
	"Cryo-Terminal",         --[[TRM]]--
	"c-net",                 --[[TRM]]--
	"CerebrumPortalGuardian",--[[ _"999 Cerebrum", _"Cerebrum - Portal Guardian" ]]--
	"Chandra",
	"Butch",                 --[[ _"Butch - Arena Master" ]]--
	"Bruce",                 --[[ _"Bruce - Mine Worker" ]]--
	--	"Boris",
	"Bob",                   --[[ _"Bob", _"Bob - Gate Guardian" ]]--
	"Benjamin",              --[[ _"Benjamin - Gunsmith" ]]--
	"Bender",                --[[ _"Bender", _"Bender - The strongest one" ]]--
	"Arthur",                --[[ _"Arthur", _"Arthur - Game developer" ]]--
	"ArenaTerminal",         --[[TRM]]--
	"AfterTakeover",
	"614_portal",            --[[ _"614 - Gate Guard Bot ]]--
	"614_cryo",              --[[ _"614 - Cryo Lab Guard Bot" ]]--
	"24-Controllable-Bot",
	"Guy"} -- check this dialog first until we can check every dialog independently

npc_shop{
name = "Stone",
items = {
	 {"Big kitchen knife"},
	 {"Meat cleaver"},
	 {"Small Axe"},
	 {"Large Axe"},
	 {"Hunting knife"},
	 {"Iron pipe"},
	 {"Big wrench"},
	 {"Crowbar"},
	 {"Power hammer"},
	 {"Baseball bat"},
	 {"Normal Jacket", 2},
	 {"Reinforced Jacket", 2},
	 {"Standard Shield"},
	 {"Heavy Shield"},
	 {"Worker Helmet", 2},
	 {"Miner Helmet"},
	 {"Shoes", 2},
	 {"Worker Shoes"}
	}
}

npc_shop{
name = "DocMoore",
items = {
	 {"Diet supplement", 3 },
	 {"Antibiotic"},
	 {"Doc-in-a-can"}
	}
}

npc_shop{
name = "Lukas",
items = {
	 {"Laser pistol"},
	 {"Laser Rifle"},
	 {"Plasma pistol"},
	 {"Plasma gun"},
	 {"Riot Shield"},
	 {"Light Battle Helmet"},
	 {"Battle Helmet"},
	 {"Battle Shoes"},
	 {"Red Guard's Light Robe"},
	 {"Red Guard's Heavy Robe"}
	}
}
	
npc_shop{
name = "Skippy",
items = {
	 -- "Map Maker", Script?
	 {"Teleporter homing beacon", 3}
	}
}

npc_shop{
name = "Duncan",
items = {
	 {"VMX Gas Grenade"},
	 {"VMX Gas Grenade"},
	 {"Small EMP Shockwave Generator", 2},
	 {"Electronic Noise Generator", 2},
	 {"Small Plasma Shockwave Emitter", 2}
	}
}

npc_shop{
name = "Ewald",
items = {
	 {"Bottled ice"},
	 {"Industrial coolant"},
	 {"Liquid nitrogen"},
	 {"Barf's Energy Drink"},
	 {"Running Power Capsule"},
	 {"Fork"},
	 {"Plate"},
	 {"Mug"}
	}
}

npc_shop{
name = "Vending-Machine",
items = {
	 {"Bottled ice"},
	 {"Industrial coolant"},
	 {"Barf's Energy Drink"},
	 {"Diet supplement"},
	}
}

npc_shop{
name = "Benjamin",
items = {
	 {".22 LR Ammunition"},
	 {"Shotgun shells"},
	 {"2 mm Exterminator Ammunition", 2},
	 {"Laser power pack", 3},
	 {"Plasma energy container", 3}
	 --"9x19mm Ammunition",
	 --"7.62x39mm Ammunition",
	 --".50 BMG (12.7x99mm) Ammunition",
	}
}

npc_shop{
name = "Samson",
items = {
	 {"Industrial coolant"},
	 {"Liquid nitrogen"},
	 {"Running Power Capsule"},
	 {"Strength Capsule"},
	 {"Dexterity Capsule"}
	}
}

npc_shop{
name = "Sorenson",
items = {
	 {"Source Book of Emergency shutdown"},
	 {"Source Book of Check system integrity"},
	 {"Source Book of Malformed packet"},
	 {"Source Book of Blue Screen"},
	 {"Source Book of Calculate Pi"},
	 {"Source Book of Energy Shield"},
	 {"Source Book of Repair equipment"}
	 --"Source Book of Reverse-engineer",
	 --"Source Book of Nethack",
	}
}

npc_shop{
name = "Tamara",
items = {
	 {"Source Book of Emergency shutdown"},
	 {"Source Book of Check system integrity"},
	 {"Source Book of Malformed packet"},
	 {"Source Book of Blue Screen"},
	 {"Source Book of Calculate Pi"},
	 {"Source Book of Repair equipment"}
	 -- "Source Book of Energy Shield",
	 -- "Source Book of Reverse-engineer",
	 -- "Source Book of Nethack",
	}
}

npc_shop{
name = "Karol",
items = {
	 {"Source Book of Repair equipment"},
	 {"Barf's Energy Drink"},
	 {"Anti-grav Pod for Droids"},
	 {"Chainsaw"},
	 {"Iron pipe"},
	 {"Big wrench"},
	 {"Power hammer"},
	 {"Crowbar"},
	 {"Pot Helmet"},
	 {"Reinforced Jacket"},
	 {"Protective Jacket"},
	 {"Worker Shoes"}
	}
}

 -- debug level (24)
npc_shop{
name = "Dude",
items = {
	 {"Big kitchen knife"},
	 {"Cutlass"},
	 {"Antique Greatsword"},
	 {"Chainsaw"},
	 {"Meat cleaver"},
	 {"Small Axe"},
	 {"Large Axe"},
	 {"Hunting knife"},
	 {"Iron pipe"},
	 {"Big wrench"},
	 {"Crowbar"},
	 {"Power hammer"},
	 {"Mace"},
	 {"Baseball bat"},
	 {"Iron bar"},
	 {"Sledgehammer"},
	 {"Light saber"},
	 {"Laser staff"},
	 {"Nobody's edge"},
	 {"Laser Scalpel"},
	 {"Shock knife"},
	 {"Energy whip"},
	 {".22 LR Ammunition"},
	 {".22 Automatic"},
	 {".22 Hunting Rifle"},
	 {"Shotgun shells"},
	 {"Two Barrel sawn off shotgun"},
	 {"Two Barrel shotgun"},
	 {"Pump action shotgun"},
	 {"9x19mm Ammunition"},
	 {"9mm Automatic"},
	 {"9mm Sub Machine Gun"},
	 {"7.62x39mm Ammunition"}
--[[	 {"7.62mm Hunting Rifle"}, -- too many items make the game crash so just comment a few out...
	 {"7.62mm AK-47"},
	 {".50 BMG (12.7x99mm) Ammunition"},
	 {"Barrett M82 Sniper Rifle"},
	 {"Laser power pack"},
	 {"Laser pistol"},
	 {"Laser Rifle"},
	 {"Laser Pulse Rifle"},
	 {"Laser Pulse Cannon"},
	 {"Plasma energy container"},
	 {"Plasma pistol"},
	 {"Plasma gun"},
	 {"2 mm Exterminator Ammunition"},
	 {"Exterminator"},
	 {"The Super Exterminator!!!"},
	 {"Electro Laser Rifle"},
	 {"VMX Gas Grenade"},
	 {"Small EMP Shockwave Generator"},
	 {"EMP Shockwave Generator"},
	 {"Electronic Noise Generator"},
	 {"Small Plasma Shockwave Emitter"},
	 {"Plasma Shockwave Emitter"},
	 {"Normal Jacket"},
	 {"Reinforced Jacket"},
	 {"Protective Jacket"},
	 {"Red Guard's Light Robe"},
	 {"Red Guard's Heavy Robe"},
	 {"Improvised Buckler"},
	 {"Bot Carapace"},
	 {"Standard Shield"},
	 {"Heavy Shield"},
	 {"Riot Shield"},
	 {"Pot Helmet"},
	 {"Worker Helmet"},
	 {"Miner Helmet"},
	 {"Light Battle Helmet"},
	 {"Battle Helmet"},
	 {"Dixon's Helmet"},
	 {"Shoes"},
	 {"Worker Shoes"},
	 {"Battle Shoes"},
	 {"Source Book of Emergency shutdown"},
	 {"Source Book of Check system integrity"},
	 {"Source Book of Sanctuary"},
	 {"Source Book of Malformed packet"},
	 {"Source Book of Calculate Pi"},
	 {"Source Book of Blue Screen"},
	 {"Source Book of Broadcast Blue Screen"},
	 {"Source Book of Invisibility"},
	 {"Source Book of Virus"},
	 {"Source Book of Broadcast virus"},
	 {"Source Book of Dispel smoke"},
	 {"Source Book of Killer poke"},
	 {"Source Book of Repair equipment"},
	 {"Source Book of Plasma discharge"},
	 {"Source Book of Nethack"},
	 {"Source Book of Ricer CFLAGS"},
	 {"Source Book of Reverse-engineer"},
	 {"Source Book of Light"},
	 {"Source Book of Network Mapper"},
	 {"Nuclear Science for Dummies IV"},
	 {"Manual of the Automated Factory"},
	 {"Strength Pill"},
	 {"Dexterity Pill"},
	 {"Code Pill"},
	 {"Brain Enlargement Pills Antidote"},
	 {"Brain Enlargement Pill"},
	 {"Diet supplement"},
	 {"Antibiotic"},
	 {"Doc-in-a-can"},
	 {"Bottled ice"},
	 {"Industrial coolant"},
	 {"Liquid nitrogen"},
	 {"Barf's Energy Drink"},
	 {"Running Power Capsule"},
	 {"Strength Capsule"},
	 {"Dexterity Capsule"},
	 {"Valuable Circuits"},
	 {"Anti-grav Pod for Droids"},
	 {"Dixon's Toolbox"},
	 {"Toolbox"},
	 {"Entropy Inverter"},
	 {"Plasma Transistor"},
	 {"Superconducting Relay Unit"},
	 {"Antimatter-Matter Converter"},
	 {"Tachyon Condensator"},
	 {"Desk Lamp"},
	 {"Red Dilithium Crystal"},
	 { "Map Maker"},
	 {"Light Enhancer? to be included in the future..."},
	 {"Fork"},
	 {"Plate"},
	 {"Mug"},
	 {"Cup"},
	 {"Teleporter homing beacon"},
	 {"Data cube"},
	 {"Kevin's Data Cube"},
	 {"Pandora's Cube"},
	 {"Rubber duck"},
	 {"Empty Picnic Basket"},
	 {"Lunch in a Picnic Basket"},
	 {"MS Stock Certificate"},
	 {"Elbow Grease Can"},
	 {"Linarian power crank"},
	 {"Tungsten spikes"},
	 {"Tinfoil patch"},
	 {"Laser sight"},
	 {"Exoskeletal joint"},
	 {"Heatsink"},
	 {"Peltier element"},
	 {"Steel mesh"},
	 {"Shock discharger"},
	 {"Silencer"},
	 {"Coprocessor"},
	 {"Pedometer"},
	 {"Foot warmers"},
	 {"Circuit jammer"},
	 {"Sensor disruptor"},
	 {"Headlamp"},
	 {"Brain stimulator"},
	 {"NPC Hand to hand weapon"},
	 {"Droid 123 Weak Robotic Arm"},
	 {"Droid 139 Plasma Trash Vaporiser"},
	 {"Droid 247 Robotic Arm"},
	 {"Droid 249 Pulse Laser Welder"},
	 {"Droid 296 Plasmabeam Cutter"},
	 {"Droid 302 Overcharged Barcode Reader"},
	 {"Droid 329 Dual Overcharged Barcode Reader"},
	 {"Droid 420 Laser Scalpel"},
	 {"Droid 476 Small Laser"},
	 {"Droid 493 Power Hammer"},
	 {"Droid 516 Robotic Fist"},
	 {"Droid 543 Tree Harvester"},
	 {"Droid 571 Robotic Fist"},
	 {"Droid 598 Robotic Fist"},
	 {"Droid 7xx Tux Seeking Missiles"},
	 {"Droid Advanced Twin Laser"},
	 {"Droid 883 Exterminator"},
	 {"Autogun Laser Pistol"},
	 {"PC LOAD LETTER"},
	 {"Cheat Gun"} ]]--
	}
}
