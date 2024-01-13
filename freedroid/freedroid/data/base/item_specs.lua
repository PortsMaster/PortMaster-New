--[[ This file specifies the item specs in the game.

--------------------------------------------------------------------

	[Macro or common value]
	Weapons
		[Hand to Hand]
		[Ranged]
		[Grenades/bombs]
	Armor
		[Body]
		[Handheld]
		[Head]
		[Feet]
	Usable
		[Book]
		[Pills & Potions]
	[Others]
	[Add-ons]
	[Droid & NPC Weapons]
	[Secret or cheat items]

------------------------------------------------------------------]]

--------------------------------------------------------------------
----    Macros or common values                                 ----
--------------------------------------------------------------------

----------------------------------------------------------------------

--[[ item specs description

	name (string) 
	--  The name of the item. Must be unique and not empty.
	--  If you change a name, make sure to check so you don't break things.
	--  From the source root folder do: grep -nR 'old_name' dialogs/ map/ src/

	slot (none | weapon | shield | special | armour | drive) default = none
	--  What slot the item can be installed.  

	drop.class (range) default = nil
	--  Distribution of item dropped by droid progression ingame.
	--  The drop class is limited to 0-9. Item isn't dropped with the value nil. 

	drop.number (range) default = 1-1
	--  How many items are dropped together.

	drop.sound (string)
	--  The path to the audio file to play when dropped on ground.

	use_help (string)
	--  Short text used to describe the right-click use of the item.

	inventory.(x,y) (integer, integer)
	--  The size of the item in inventory.
	--  Max weapon size = 4x5, other items can potentially be bigger.

	inventory.stackable (boolean) default = false
	--  Items of same type are collected together in inventory.

	inventory.image (string)
	--  The path to the image displayed in the inventory.

	base_price (integer) default = 0
	--  The basic shop price that item is sold.
	--  Unsaleable (and buyable) with the value 0.

	description (string)
	--  Text to describe the item.

	rotation_series (string)
	--  The path to directory of images for shop animation.

	[=[ Weapon ]=]

	weapon.damage (range) default = 0
	-- The distribution of damage inflict by the holder of the weapon.

	weapon.attack_time (float) default = 0
	--  The time one attack is performed.

	weapon.reloading_time (float) default = 0
	--  The time to reload ammunition.

	weapon.reloading_sound (string)
	--  Name of sound file to play when reloading weapon 
	--  NOTE: must use path with reference to SOUND_DIR of file to use.
	    (i.e. "effects/item_sounds/soundfile.ogg")

	weapon.bullet.type (string)
	--  The type of bullet throw by the weapon.
	--  Bullet is specified in bullet_archetype.dat
	--  NOTE: For melee weapon, do not set any bullet data

	weapon.bullet.speed (float)
	--  The speed of bullet.

	weapon.bullet.lifetime (float)
	--  Time before the bullet is wasted.

	weapon.ammunition.type (string)
	--  Type of the ammunition (an ammunition can be a bullet, a battery, anything
	    that needs to be loaded in the weapon to have it working...)

	weapon.ammunition.clip (integer)
	--  Number of ammunition that can be loaded in the weapon.

	weapon.melee (boolean)
	--  The weapon is a melee weapon.

	weapon.motion_class (string)
	--  The class of graphic used to display the weapon.

]]

-- Start of the list of item
item_list{

{
	id = "The first item is VERY buggy ingame, so don't use it.",
	name =_"The first item is VERY buggy ingame, so don't use it.",
	-- NOTE can't be dropped, can't be equipped, et kin
	slot = "none",
	armor_class = "0:0",
	right_use = {tooltip = _"Dummy item. If you see this, please report it as bug."},
	inventory = {x = 1, y = 1, image = "inventory_image_bug.png" },
	drop = {class = nil, number = "0:0", sound = "Item_Drop_Sound_0.ogg"},
	base_price = 0,
	description =_[[Dummy item. If you see this, report it as bug.]],
	rotation_series = "NONE_AVAILABLE_YET",
},

----------------------------------------------------------------------
----    Weapons - [Hand to Hand]                                  ----
----------------------------------------------------------------------

----------------------------------------------------------------------

{
	id = "Big kitchen knife",
	name =_"Big Kitchen Knife",
	slot = "weapon",
	weapon = {
		damage = "1:2",
		attack_time = 0.500000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "10:15",
	base_price = 30,
	inventory = {x = 1, y = 2, image = "weapons/big_kitchen_knife/inv_image.png" },
	drop = {class = "0", sound = "drop_sword_sound.ogg"},
	description =_[[Light and maneuverable in combat, but unfortunately not very effective in cutting through steel as well as quickly reaching the point of breaking if you try. Though, for sure better than hitting at metal with your bare fists.]],
	rotation_series = "weapons/big_kitchen_knife",
	tux_part = "iso_big_kitchen_knife",
},
----------------------------------------------------------------------

{
	id = "Cutlass",
	name =_"Cutlass",
	slot = "weapon",
	weapon = {
		damage = "2:4",
		attack_time = 0.550000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	requirements = {dexterity = 20},
	durability = "20:30",
	base_price = 100,
	inventory = {x = 1, y = 4, image = "weapons/cutlass/inv_image.png" },
	drop = {class = "0", sound = "drop_sword_sound.ogg"},
	description =_[[Long reach while remaining maneuverable enough in combat to find the weak spots in droid armor are the advantages that partially makes up for the inability of a cutting blade to incur lots of damage on a heavily protected target. Repeatedly striking at metal quickly damages the blade though.]],
	rotation_series = "weapons/cutlass",
	tux_part = "iso_cutlass",
},
----------------------------------------------------------------------

{
	id = "Antique Greatsword",
	name =_"Antique Greatsword",
	slot = "weapon",
	weapon = {
		damage = "12:18",
		attack_time = 1.000000,
		reloading_time = 0.000000,
		melee = true,
		two_hand = true,
		motion_class = "1hmelee",
	},
	requirements = {strength = 25, dexterity = 20},
	durability = "20:30",
	base_price = 400,
	inventory = {x = 2, y = 5, image = "weapons/sword/inv_image.png" },
	drop = {class = "0", sound = "drop_sword_sound.ogg"},
	description =_[[Very maneuverable for its size, and heavy enough to punch though weaker bot armor in one hit, the only real disadvantage of this old weapon is the same as for other swords. It just doesn't last long when cutting into metal parts.]],
	rotation_series = "weapons/sword",
	tux_part = "iso_antique_greatsword",
},
----------------------------------------------------------------------

{
	id = "Chainsaw",
	name =_"Chainsaw",
	slot = "weapon",
	weapon = {
		damage = "2:3",
		attack_time = 0.150000,
		reloading_time = 0.000000,
		melee = true,
		two_hand = true,
		motion_class = "2h_heavy_melee",
	},
	requirements = {strength = 20, dexterity = 20},
	durability = "6:8",
	base_price = 500,
	inventory = {x = 2, y = 4, image = "weapons/chainsaw/inv_image.png" },
	drop = {class = "5", sound = "drop_sword_sound.ogg"},
	description =_[[Quite efficient at separating limbs from even a droid body, or digging through weaker armored parts to cause massive damage on internal electronics. But, the chain wears out very quickly when used on materials harder than wood, and supply shortages of new chains and other parts makes it expensive to maintain.]],
	rotation_series = "weapons/chainsaw",
	tux_part = "iso_chainsaw",
},
----------------------------------------------------------------------

{
	id = "Meat cleaver",
	name =_"Meat Cleaver",
	slot = "weapon",
	weapon = {
		damage = "1:3",
		attack_time = 0.600000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "30:40",
	base_price = 50,
	inventory = {x = 2, y = 2, image = "weapons/meat_cleaver/inv_image.png" },
	drop = {class = "0", sound = "drop_sword_sound.ogg"},
	description =_[[Designed to chop through meat and bones, it's not as fragile as cutting blades when used against metal enemies. However, it is a bit slower and clumsier to use than more graceful weapons.]],
	rotation_series = "weapons/meat_cleaver",
	tux_part = "iso_meat_cleaver",
},
----------------------------------------------------------------------

{
	id = "Small Axe",
	name =_"Small Axe",
	slot = "weapon",
	weapon = {
		damage = "2:6",
		attack_time = 0.600000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	requirements = {strength = 14, dexterity = 15},
	durability = "40:60",
	base_price = 80,
	inventory = {x = 2, y = 3, image = "weapons/small_axe/inv_image.png" },
	drop = {class = "0", sound = "drop_sword_sound.ogg"},
	description =_[[While this axe was made for splitting wood, with some luck it can damage vital parts of a droid as well.]],
	rotation_series = "weapons/small_axe",
	tux_part = "iso_small_axe",
},
----------------------------------------------------------------------

{
	id = "Large Axe",
	name =_"Large Axe",
	slot = "weapon",
	weapon = {
		damage = "10:20",
		attack_time = 1.200000,
		reloading_time = 0.000000,
		melee = true,
		two_hand = true,
		motion_class = "1hmelee",
	},
	requirements = {strength = 25, dexterity = 18},
	durability = "40:100",
	base_price = 120,
	inventory = {x = 2, y = 5, image = "weapons/large_axe/inv_image.png" },
	drop = {class = "0", sound = "drop_sword_sound.ogg"},
	description =_[[While this weapon is somewhat slow and cumbersome to use, it is as good at leaving big dents in droids as it is at felling trees. A good hit is often capable of taking out lesser droids in a single hit.]],
	rotation_series = "weapons/large_axe",
	tux_part = "iso_small_axe", -- hack as we currently have no animation for this
},
----------------------------------------------------------------------

{
	id = "Hunting knife",
	name =_"Hunting Knife",
	slot = "weapon",
	weapon = {
		damage = "0:2",
		attack_time = 0.400000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "6:10",
	base_price = 40,
	inventory = {x = 1, y = 2, image = "weapons/hunting_knife/inv_image.png" },
	drop = {class = "0", sound = "drop_sword_sound.ogg"},
	description =_[[A short stabbing dagger doesn't have much effect on the metal body of a droid, but with luck you might damage some wires or hoses in less protected areas, so it's still better than trying to take the machines on with bare hands.]],
	rotation_series = "weapons/hunting_knife",
	tux_part = "iso_hunting_knife",
},
----------------------------------------------------------------------

{
	id = "Iron pipe",
	name =_"Iron Pipe",
	slot = "weapon",
	weapon = {
		damage = "1:3",
		attack_time = 0.750000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "35:55",
	base_price = 30,
	inventory = {x = 1, y = 3, image = "weapons/iron_pipe/inv_image.png" },
	drop = {class = "0:9", sound = "drop_sword_sound.ogg"},
	description =_[[A medium sized water pipe of iron can turn into an effective weapon even versus a metal opponent. While not likely to penetrate the armor of a bot, the impact force alone can still damage and shake loose circuit boards and weldings beneath the protective metal layer.]],
	rotation_series = "weapons/iron_pipe",
	tux_part = "iso_iron_pipe",
},
----------------------------------------------------------------------

{
	id = "Big wrench",
	name =_"Big Wrench",
	slot = "weapon",
	weapon = {
		damage = "1:4",
		attack_time = 0.750000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "30:50",
	base_price = 60,
	inventory = {x = 1, y = 3, image = "weapons/big_wrench/inv_image.png" },
	drop = {class = "0", sound = "drop_sword_sound.ogg"},
	description =_[[A big heavy wrench can be surprisingly efficient at turning a bot into second hand parts, in a hands-on and brutal way, if needed.]],
	rotation_series = "weapons/big_wrench",
	tux_part = "iso_big_wrench",
},
----------------------------------------------------------------------

{
	id = "Crowbar",
	name =_"Crowbar",
	slot = "weapon",
	weapon = {
		damage = "1:4",
		attack_time = 0.600000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	requirements = {strength = 15},
	durability = "45:65",
	base_price = 60,
	inventory = {x = 1, y = 3, image = "weapons/crowbar/inv_image.png" },
	drop = {class = "0", sound = "drop_sword_sound.ogg"},
	description =_[[Something originally intended for breaking up doors or pulling out nails can also be used to break open droid skulls or give enough leverage to pull off their extremities.]],
	rotation_series = "weapons/crowbar",
	tux_part = "iso_crowbar",
},
----------------------------------------------------------------------

{
	id = "Power hammer",
	name =_"Power Hammer",
	slot = "weapon",
	weapon = {
		damage = "1:2",
		attack_time = 0.250000,
		reloading_time = 2.000000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = true,
		ammunition = {id = "Laser power pack", clip = 60},
		motion_class = "1hranged",
	},
	durability = "30:40",
	base_price = 250,
	inventory = {x = 2, y = 3, image = "weapons/power_hammer/inv_image.png" },
	drop = {class = "2:4", sound = "drop_sword_sound.ogg"},
	description =_[[The POWER NAIL DRIVER 3000 will, according to the advertisement, 'build your house for you'. While it's unclear how many nails your igloo will actually need, it sure can be handy nonetheless for bashing bot skulls. As long as the battery lasts, anyway.]],
	rotation_series = "weapons/power_hammer",
	tux_part = "iso_power_hammer",
},
----------------------------------------------------------------------

{
	id = "Mace",
	name =_"Mace",
	slot = "weapon",
	weapon = {
		damage = "3:8",
		attack_time = 0.800000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	requirements = {strength = 25, dexterity = 15},
	durability = "50:70",
	base_price = 180,
	inventory = {x = 1, y = 3, image = "weapons/mace/inv_image.png" },
	drop = {class = "3:7", sound = "drop_sword_sound.ogg"},
	description =_[[The mace already proved on the medieval battlefield that it was good at crushing even heavily armored skulls. Unfortunately for the droids, this old knowledge still holds true.]],
	rotation_series = "weapons/mace",
	tux_part = "iso_mace",
},
----------------------------------------------------------------------

{
	id = "Baseball bat",
	name =_"Baseball Bat",
	slot = "weapon",
	weapon = {
		damage = "4:10",
		attack_time = 0.700000,
		reloading_time = 0.000000,
		melee = true,
		two_hand = true,
		motion_class = "1hmelee",
	},
	requirements = {strength = 12, dexterity = 15},
	durability = "10:15",
	base_price = 30,
	inventory = {x = 2, y = 4, image = "weapons/baseball_bat/inv_image.png" },
	drop = {class = "0", sound = "drop_sword_sound.ogg"},
	description =_[[With 1-2 good two handed swings, a former droids head might fly far enough for you to score a home run. Just make sure to bring a backup weapon, because wooden bats have a predilection for splitting in two after too many hard hits.]],
	rotation_series = "weapons/baseball_bat",
	tux_part = "iso_baseball_bat",
},
----------------------------------------------------------------------

{
	id = "Iron bar",
	name =_"Iron Bar",
	slot = "weapon",
	weapon = {
		damage = "6:12",
		attack_time = 1.000000,
		reloading_time = 0.000000,
		melee = true,
		two_hand = true,
		motion_class = "2h_heavy_melee",
	},
	requirements = {strength = 20, dexterity = 15},
	durability = "60:75",
	base_price = 70,
	inventory = {x = 1, y = 5, image = "weapons/iron_bar/inv_image.png" },
	drop = {class = "2:6", sound = "drop_sword_sound.ogg"},
	description =_[[A bit slow and cumbersome to use, and prohibiting the security of a shield to cower behind, this weapon isn't always a good option. But if you do hit, you are sure to do more damage than just a scratch.]],
	rotation_series = "weapons/iron_bar",
	tux_part = "iso_iron_bar",
},
----------------------------------------------------------------------

{
	id = "Sledgehammer",
	name =_"Sledgehammer",
	slot = "weapon",
	weapon = {
		damage = "20:30",
		attack_time = 1.500000,
		reloading_time = 0.000000,
		melee = true,
		two_hand = true,
		motion_class = "2h_heavy_melee",
	},
	requirements = {strength = 25, dexterity = 20},
	durability = "40:60",
	base_price = 150,
	inventory = {x = 2, y = 5, image = "weapons/sledgehammer/inv_image.png" },
	drop = {class = "0", sound = "drop_sword_sound.ogg"},
	description =_[[Very slow and only for the strongest wielder, but only the tougher droids can survive more than 1-2 direct hits.]],
	rotation_series = "weapons/sledgehammer",
	tux_part = "iso_sledgehammer",
},
----------------------------------------------------------------------

{
	id = "Light saber",
	name =_"Light Saber",
	slot = "weapon",
	weapon = {
		damage = "30:40",
		attack_time = 0.500000,
		reloading_time = 2.000000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = true,
		ammunition = {id = "Laser power pack", clip = 20},
		motion_class = "1hmelee",
	},
	requirements = {dexterity = 30},
	durability = "1000:1000",
	base_price = 1500,
	inventory = {x = 1, y = 2, image = "weapons/light_saber/inv_image.png" },
	drop = {class = "7:9", sound = "drop_sword_sound.ogg"},
	description =_[[In the hands of a true master, this excellent technological craftsmanship is as deadly as it is beautiful. It requires laser crystals to work properly.]],
	rotation_series = "weapons/light_saber",
	tux_part = "iso_sword",
},
----------------------------------------------------------------------

{
	id = "Laser staff",
	name =_"Laser Staff",
	slot = "weapon",
	weapon = {
		damage = "40:60",
		attack_time = 0.400000,
		reloading_time = 2.000000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = true,
		ammunition = {id = "Laser power pack", clip = 20},
		motion_class = "1hmelee",
	},
	requirements = {dexterity = 40},
	durability = "1000:1000",
	base_price = 2000,
	inventory = {x = 1, y = 3, image = "weapons/laser_staff/inv_image.png" },
	drop = {class = "8:9", sound = "drop_sword_sound.ogg"},
	description =_[[A close combat master with this weapon in his hands is a pure whirling dervish of death. It requires laser crystals to work properly.]],
	rotation_series = "weapons/laser_staff",
	tux_part = "iso_sword",
},
----------------------------------------------------------------------

{
	id = "Nobody's edge",
	name =_"Nobody's Edge",
	slot = "weapon",
	weapon = {
		damage = "40:40",
		attack_time = 0.500000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	base_price = 0,
	inventory = {x = 1, y = 2, image = "weapons/laser_dagger/inv_image.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[This blade pulses with evil. That power. That energy. Nothing can stop you now.]],
	rotation_series = "weapons/laser_dagger",
	tux_part = "iso_hunting_knife",
},
----------------------------------------------------------------------

{
	id = "Laser Scalpel",
	name =_"Laser Scalpel",
	slot = "weapon",
	weapon = {
		damage = "1:1",
		attack_time = 0.500000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	base_price = 50,
	inventory = {x = 1, y = 1, image = "weapons/laser_dagger/inv_image.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[I murdered the only person within a thousand miles who can heal me, and all I got was this lousy scalpel.]],
	rotation_series = "weapons/laser_dagger",
	tux_part = "iso_hunting_knife",
},
----------------------------------------------------------------------

{
	id = "Shock knife",
	name =_"Shock Knife",
	slot = "weapon",
	weapon = {
		damage = "40:40",
		attack_time = 0.500000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	base_price = 0,
	inventory = {x = 1, y = 2, image = "weapons/shock_knife/inv_image.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[FIXME and all values]],
	rotation_series = "weapons/shock_knife",
	tux_part = "iso_shock_knife",
},
----------------------------------------------------------------------

{
	id = "Energy whip",
	name =_"Energy Whip",
	slot = "weapon",
	weapon = {
		damage = "18:25",
		attack_time = 0.600000,
		reloading_time = 2.500000,
		melee = true,
		ammunition = {id = "Laser power pack", clip = 15},
		motion_class = "1hmelee",
	},
	requirements = {strength = 25, dexterity = 25},
	base_price = 2500,
	inventory = {x = 2, y = 2, image = "weapons/energy_whip/inv_image.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[An energy whip commonly found at management from MegaSys facilities. What purpose they serve for is still unknown. Because the real whip is pure energy, it will never break, but it does not stays on the strong side.]],
	rotation_series = "weapons/energy_whip",
	tux_part = "iso_energy_whip",
},
----------------------------------------------------------------------

----------------------------------------------------------------------
----    Weapons - [Ranged]                                        ----
----------------------------------------------------------------------

{
	id = ".22 LR Ammunition",
	name =_".22 LR Ammunition",
	base_price = 4,
	inventory = {x = 2, y = 1,stackable = true, image = "weapons/22_ammo/inv_image.png" },
	drop = {class = "2:6", number = "10:60", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[.22 Long Rifle ammunition used to be a very common ammo for target practice, mainly because it was cheap and gave little recoil. It's just too weak to penetrate any real droid armor though.]],
	rotation_series = "weapons/22_ammo",
},
----------------------------------------------------------------------

{
	id = ".22 Automatic",
	name =_".22 Automatic",
	slot = "weapon",
	weapon = {
		damage = "1:3",
		attack_time = 0.300000,
		reloading_time = 2.700000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "half_pulse", speed = 30.000000, lifetime = -1.000000},
		ammunition = {id = ".22 LR Ammunition", clip = 11},
		motion_class = "1hranged",
	},
	durability = "70:80",
	base_price = 150,
	inventory = {x = 1, y = 2, image = "weapons/22_automatic/inv_image.png" },
	drop = {class = "0", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[With .22 ammo, it's mostly dumb luck if you actually damage a bot with this pistol. On the bright side, you will get a LOT of target practice out of each bot before a bullet or two manages to find a weak enough spot to take the bot out.]],
	rotation_series = "weapons/22_automatic",
	tux_part = "iso_22_automatic",
},
----------------------------------------------------------------------

{
	id = ".22 Hunting Rifle",
	name =_".22 Hunting Rifle",
	slot = "weapon",
	weapon = {
		damage = "2:8",
		attack_time = 0.750000,
		reloading_time = 5.250000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "half_pulse", speed = 30.000000, lifetime = -1.000000},
		ammunition = {id = ".22 LR Ammunition", clip = 11},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "70:80",
	base_price = 250,
	inventory = {x = 1, y = 5, image = "weapons/22_rifle/inv_image.png" },
	drop = {class = "0", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[A .22 hunting rifle was mainly used for sports shooting and for cheap training. As a hunting weapon its main use was to kill small vermin such as rats and squirrels. It was also highly effective against rabbits. Unfortunately, you won't be hunting 'wabbits'...]],
	rotation_series = "weapons/22_rifle",
	tux_part = "iso_22_hunting_rifle",
},
----------------------------------------------------------------------

{
	id = "Shotgun shells",
	name =_"Shotgun Shells",
	base_price = 12,
	inventory = {x = 2, y = 1,stackable = true, image = "weapons/shotgun_ammo/inv_image.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[Shotgun shells come in a range of gauges, but mixing and matching shotgun ammo sizes can cause your gun to explode and take your hand along with it. Luckily for you, all of your ammo is the same size and fits your shotgun(s) perfectly. An additional bonus is that it all seems to be buckshot.
	Undoubtedly these were the most popular type of shotgun ammunition when hunting for food became unfeasible due to the extinction of most wildlife.]],
	rotation_series = "weapons/shotgun_ammo",
},
----------------------------------------------------------------------

{
	id = "Two Barrel sawn off shotgun",
	name =_"Two Barrel Sawn Off Shotgun",
	slot = "weapon",
	weapon = {
		damage = "2:10",
		attack_time = 0.200000,
		reloading_time = 2.800000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "shotgun", speed = 30.000000, lifetime = -1.000000},
		ammunition = {id = "Shotgun shells", clip = 2},
		motion_class = "1hranged",
	},
	durability = "50:60",
	base_price = 200,
	inventory = {x = 2, y = 2, image = "weapons/shotgun_sawn_off/inv_image.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[Often wielded in the past by thugs or convenience store owners, this little baby is less powerful than the two-handed model, but makes up for it by letting you use a shield in conjunction with it.]],
	rotation_series = "weapons/shotgun_sawn_off",
	tux_part = "iso_shotgun_sawn_off",
},
----------------------------------------------------------------------

{
	id = "Two Barrel shotgun",
	name =_"Two Barrel Shotgun",
	slot = "weapon",
	weapon = {
		damage = "2:18",
		attack_time = 0.200000,
		reloading_time = 3.800000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "shotgun", speed = 30.000000, lifetime = -1.000000},
		ammunition = {id = "Shotgun shells", clip = 2},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "50:60",
	base_price = 250,
	inventory = {x = 2, y = 4, image = "weapons/shotgun_2_barrel/inv_image.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[An old standby of farmers and bird hunters. While capable of causing a fair amount of damage to droid armor, the limited rounds capacity and fairly slow reloading time make this weapon preferable to melee weapons, but only just. Requires two hands to wield.]],
	rotation_series = "weapons/shotgun_2_barrel",
	tux_part = "iso_shotgun",
},
----------------------------------------------------------------------

{
	id = "Pump action shotgun",
	name =_"Pump Action Shotgun",
	slot = "weapon",
	weapon = {
		damage = "2:14",
		attack_time = 0.750000,
		reloading_time = 3.2500000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "shotgun", speed = 30.000000, lifetime = -1.000000},
		ammunition = {id = "Shotgun shells", clip = 8},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "45:55",
	base_price = 300,
	inventory = {x = 2, y = 4, image = "weapons/shotgun_pump/inv_image.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[The pump action shotgun isn't quite as powerful as the double barrel equivalent, but it does hold more ammo per clip. Requires two hands to wield.]],
	rotation_series = "weapons/shotgun_pump",
	tux_part = "iso_shotgun",
},
----------------------------------------------------------------------

{
	id = "9x19mm Ammunition",
	name =_"9x19mm Ammunition",
	base_price = 18,
	inventory = {x = 2, y = 1,stackable = true, image = "weapons/9mm_ammo/inv_image.png" },
	drop = {class = "5:8", number = "10:20", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[You know a little about these. A metal jacket holds a bullet tightly at one end and is filled with an explosive chemical which acts as a propellant. At the other end is a primer cap filled with another explosive, which when struck will ignite the propellant. The bullet then becomes a projectile and is usually launched out through the barrel of a gun or similar device. Or, something like that.]],
	rotation_series = "weapons/9mm_ammo",
},
----------------------------------------------------------------------

{
	id = "9mm Automatic",
	name =_"9mm Automatic",
	slot = "weapon",
	weapon = {
		damage = "4:10",
		attack_time = 0.500000,
		reloading_time = 2.500000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "half_pulse", speed = 30.000000, lifetime = -1.000000},
		ammunition = {id = "9x19mm Ammunition", clip = 19},
		motion_class = "1hranged",
	},
	durability = "50:60",
	base_price = 400,
	inventory = {x = 2, y = 1, image = "weapons/9mm_pistol/inv_image.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[Nine millimeter ammo is a common caliber. While not very powerful, it allows for more rounds per clip than bigger ammunition.]],
	rotation_series = "weapons/9mm_pistol",
	tux_part = "iso_9mm_pistol",
},
----------------------------------------------------------------------

{
	id = "9mm Sub Machine Gun",
	name =_"9mm Sub Machine Gun",
	slot = "weapon",
	weapon = {
		damage = "3:8",
		attack_time = 0.200000,
		reloading_time = 2.800000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "half_pulse", speed = 30.000000, lifetime = -1.000000},
		ammunition = {id = "9x19mm Ammunition", clip = 30},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "60:70",
	base_price = 950,
	inventory = {x = 2, y = 3, image = "weapons/9mm_smg/inv_image.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[These are commonly referred to as bullet hoses.]],
	rotation_series = "weapons/9mm_smg",
	tux_part = "iso_9mm_sub_machine_gun",
},
----------------------------------------------------------------------

{
	id = "7.62x39mm Ammunition",
	name =_"7.62x39mm Ammunition",
	base_price = 24,
	inventory = {x = 2, y = 1,stackable = true, image = "weapons/7_62mm_ammo/inv_image.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[7.62mm ammo. Commonly used in assault rifles from old.]],
	rotation_series = "weapons/7_62mm_ammo",
},
----------------------------------------------------------------------

{
	id = "7.62mm Hunting Rifle",
	name =_"7.62mm Hunting Rifle",
	slot = "weapon",
	weapon = {
		damage = "10:16",
		attack_time = 0.800000,
		reloading_time = 4.200000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "half_pulse", speed = 30.000000, lifetime = -1.000000},
		ammunition = {id = "7.62x39mm Ammunition", clip = 5},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "50:60",
	base_price = 800,
	inventory = {x = 2, y = 5, image = "weapons/7_62mm_hunting_rifle/inv_image.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[7.62 millimeter ammo is commonly used in assault rifles. This is a more civilian take on that concept.]],
	rotation_series = "weapons/7_62mm_hunting_rifle",
	tux_part = "iso_7_62mm_hunting_rifle",
},
----------------------------------------------------------------------

{
	id = "7.62mm AK-47",
	name =_"7.62mm AK-47",
	slot = "weapon",
	weapon = {
		damage = "6:12",
		attack_time = 0.200000,
		reloading_time = 2.800000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "half_pulse", speed = 30.000000, lifetime = -1.000000},
		ammunition = {id = "7.62x39mm Ammunition", clip = 30},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "70:80",
	base_price = 1400,
	inventory = {x = 2, y = 4, image = "weapons/7_62mm_ak47/inv_image.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[The favorite weapon of third-world countries everywhere, this is a mass-produced, fairly reliable automatic weapon.]],
	rotation_series = "weapons/7_62mm_ak47",
	tux_part = "iso_7_62mm_ak47",
},
----------------------------------------------------------------------

{
	id = ".50 BMG (12.7x99mm) Ammunition",
	name =_".50 BMG (12.7x99mm) Ammunition",
	base_price = 200,
	inventory = {x = 1, y = 1, image = "weapons/50_bmg_ammo/inv_image.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[Browning Machine Gun ammo. Commonly used against small fortress and also to stop vehicles. You probably won't find a weapon to use this ammo, though.]],
	rotation_series = "weapons/50_bmg_ammo",
},
----------------------------------------------------------------------

{
	id = "Barrett M82 Sniper Rifle",
	name =_"Barrett M82 Sniper Rifle",
	slot = "weapon",
	weapon = {
		damage = "40:240",
		attack_time = 1.200000,
		reloading_time = 2.800000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "single", speed = 30.000000, lifetime = -1.000000},
		ammunition = {id = ".50 BMG (12.7x99mm) Ammunition", clip = 10},
		two_hand = true,
		motion_class = "2hranged",
	},
	requirements = {strength = 24},
	durability = "40:50",
	base_price = 2000,
	inventory = {x = 2, y = 5, image = "weapons/50_barrett_m82/inv_image.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[Powerful enough to stop a truck, literally, the likelihood of even a battle droid surviving more than 2 hits by this weapon is quite slim. It doesn't even matter if the pesky droid is cowering behind a wall, the bullets will break right through and make the bot ready for the scrap heap in no time.]],
	rotation_series = "weapons/50_barrett_m82",
	tux_part = "iso_barrett_m82_sniper_rifle",
},
----------------------------------------------------------------------

{
	id = "Laser power pack",
	name =_"Laser Power Pack",
	base_price = 2,
	inventory = {x = 2, y = 2,stackable = true, image = "weapons/laser_power_pack/inv_image.png" },
	drop = {class = "2:9", number = "10:20", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[Energy crystal load for laser weapons and other power tools. Each round fired consumes a load within the crystal.]],
	rotation_series = "weapons/laser_power_pack",
},
----------------------------------------------------------------------

{
	id = "Laser pistol",
	name =_"Laser Pistol",
	slot = "weapon",
	weapon = {
		damage = "4:10",
		attack_time = 0.400000,
		reloading_time = 2.600000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "laser_rifle", speed = 90.000000, lifetime = -1.000000},
		ammunition = {id = "Laser power pack", clip = 20},
		motion_class = "1hranged",
	},
	durability = "100:110",
	base_price = 500,
	inventory = {x = 2, y = 1, image = "weapons/laser_pistol/inv_image.png" },
	drop = {class = "6:8", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[A basic laser, but it has good uses in certain situations. No warranty of any kind, though.]],
	rotation_series = "weapons/laser_pistol",
	tux_part = "iso_laser_pistol",
},
----------------------------------------------------------------------

{
	id = "Laser Rifle",
	name =_"Laser Rifle",
	slot = "weapon",
	weapon = {
		damage = "8:16",
		attack_time = 0.600000,
		reloading_time = 3.400000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "laser_rifle", speed = 90.000000, lifetime = -1.000000},
		ammunition = {id = "Laser power pack", clip = 40},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "100:110",
	base_price = 1000,
	inventory = {x = 1, y = 4, image = "weapons/laser_rifle/inv_image.png" },
	drop = {class = "7:9", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[This rifle is a high-end laser weapon. There is only one problem with it: Shooting it is too much fun. People often end up with no ammunition in the middle of a battle.]],
	rotation_series = "weapons/laser_rifle",
	tux_part = "iso_laser_rifle",
},
----------------------------------------------------------------------

{
	id = "Laser Pulse Rifle",
	name =_"Laser Pulse Rifle",
	slot = "weapon",
	weapon = {
		damage = "3:8",
		attack_time = 0.150000,
		reloading_time = 2.8500000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "laser_rifle", speed = 90.000000, lifetime = -1.000000},
		ammunition = {id = "Laser power pack", clip = 60},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "140:160",
	base_price = 1000,
	inventory = {x = 2, y = 4, image = "weapons/laser_pulse_rifle/inv_image.png" },
	drop = {class = "7:9", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[The pulse laser technology, allowing for many repeated short bursts without the weapon overheating, makes this quite a useful weapon. The damage from each shot is noticeably less than from a Laser rifle, but the firing rate more than makes up for it.]],
	rotation_series = "weapons/laser_pulse_rifle",
	tux_part = "iso_laser_pulse_rifle",
},
----------------------------------------------------------------------

{
	id = "Laser Pulse Cannon",
	name =_"Laser Pulse Cannon",
	slot = "weapon",
	weapon = {
		damage = "6:14",
		attack_time = 0.150000,
		reloading_time = 3.8500000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "military", speed = 90.000000, lifetime = -1.000000},
		ammunition = {id = "Laser power pack", clip = 80},
		two_hand = true,
		motion_class = "2hranged",
	},
	requirements = {strength = 28},
	durability = "140:160",
	base_price = 2500,
	inventory = {x = 4, y = 4, image = "weapons/laser_pulse_cannon/inv_image.png" },
	drop = {class = "8:9", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[The pulse laser technology, allowing for many repeated short bursts without the weapon overheating, combined with a military design makes this weapon the preferred choice for most soldiers. Its quick no-recoil firing, large magazine, and awesome killing power makes it the ideal weapon for cleansing large droid infestations in mere minutes.]],
	rotation_series = "weapons/laser_pulse_cannon",
	tux_part = "iso_laser_pulse_cannon",
},
----------------------------------------------------------------------

{
	id = "Electro Laser Rifle",
	name =_"Electro Laser Rifle",
	slot = "weapon",
	weapon = {
		damage = "25:47",
		attack_time = 1.000000,
		reloading_time = 3.300000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "electro_laser", speed = 70.000000, lifetime = -1.000000},
		ammunition = {id = "Laser power pack", clip = 8},
		two_hand = true,
		motion_class = "2hranged",
	},
	requirements = {strength = 25},
	durability = "130:140",
	base_price = 2500,
	inventory = {x = 2, y = 5, image = "weapons/electro_laser_rifle/inv_image.png" },
	drop = {class = "8:9", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[A specialized beam of laser momentarily ionizes the air between the target and the gun, turning it into highly conductive plasma. Milliseconds later, a powerful electric shock is delivered through the air and hits the target. This weapon is effective against people as it is against bots, and indeed few are the droid classes that can withstand more than a few hits from it before going down. The ammo is cheap, and it is one of the few man-made weapons which actually produces a blast, being able to harm more than one bot at once. However, it is still no match against Exterminators.]],
	rotation_series = "weapons/electro_laser_rifle",
	tux_part = "iso_electro_laser_rifle",
},
----------------------------------------------------------------------

{
	id = "Plasma energy container",
	name =_"Plasma Energy Container",
	base_price = 4,
	inventory = {x = 2, y = 2,stackable = true, image = "weapons/plasma_energy_container/inv_image.png" },
	drop = {class = "2:9", number = "10:20", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[A container filled with all materials and energy required to make plasma weapons work in one handy and relatively safe package. This is the most common way of loading a plasma weapon.]],
	rotation_series = "weapons/plasma_energy_container",
},
----------------------------------------------------------------------

{
	id = "Plasma pistol",
	name =_"Plasma Pistol",
	slot = "weapon",
	weapon = {
		damage = "12:18",
		attack_time = 0.750000,
		reloading_time = 2.2500000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "plasma_white", speed = 15.000000, lifetime = -1.000000},
		ammunition = {id = "Plasma energy container", clip = 6},
		motion_class = "1hranged",
	},
	durability = "30:40",
	base_price = 750,
	inventory = {x = 2, y = 2, image = "weapons/plasma_pistol/inv_image.png" },
	drop = {class = "6:8", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[The basic plasma weapon in a conveniently small package.]],
	rotation_series = "weapons/plasma_pistol",
	tux_part = "iso_plasma_pistol",
},
----------------------------------------------------------------------

{
	id = "Plasma gun",
	name =_"Plasma Gun",
	slot = "weapon",
	weapon = {
		damage = "24:30",
		attack_time = 1.000000,
		reloading_time = 4.000000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "plasma_white", speed = 15.000000, lifetime = -1.000000},
		ammunition = {id = "Plasma energy container", clip = 12},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "30:40",
	base_price = 1200,
	inventory = {x = 2, y = 3, image = "weapons/plasma_gun/inv_image2.png" },
	drop = {class = "7:9", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[A somewhat slow weapon, but once you do hit plenty a bot will just down on the spot. A good alternative to a pulse laser for the skilled marksman.]],
	rotation_series = "weapons/plasma_gun",
	tux_part = "iso_gun1",
},
----------------------------------------------------------------------

{
	id = "Plasma Cannon",
	name =_"Plasma Cannon",
	slot = "weapon",
	weapon = {
		damage = "40:100",
		attack_time = 1.000000,
		reloading_time = 3.500000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "plasma_white", speed = 15.000000, lifetime = -1.000000},
		ammunition = {id = "Plasma energy container", clip = 10},
		two_hand = true,
		motion_class = "2hranged",
	},
	requirements = {strength = 25},
	durability = "140:160",
	base_price = 2500,
	inventory = {x = 2, y = 3, image = "weapons/plasma_gun/inv_image2.png" },
	drop = {class = "8:9", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[The plasma cannon is one of the slowest weapon mankind even produced. Based on the Barrett M86 Sniper Rifle, it takes a long time to heat before shooting. Being a plasma bullet, a newbie will most likely miss the target. However, for the skilled marksman, it is a good alternative to a pulse laser cannon, because once it hit, molten metal is usually all that remains where the bot used to be.]],
	rotation_series = "weapons/plasma_gun",
	tux_part = "iso_gun1",
},
----------------------------------------------------------------------

{
	id = "2 mm Exterminator Ammunition",
	name =_"2mm Exterminator Ammunition",
	base_price = 5,
	inventory = {x = 2, y = 2,stackable = true, image = "weapons/exterminator_ammo/inv_image.png" },
	drop = {class = "6:9", number = "5:10", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[Exterminators need this kind of ammunition. It can cause skin irritations due to leaking extermination radiation when carried close to the body for long time.]],
	rotation_series = "weapons/exterminator_ammo",
},
----------------------------------------------------------------------

{
	id = "Exterminator",
	name =_"Exterminator",
	slot = "weapon",
	weapon = {
		damage = "8:48",
		attack_time = 0.5000000,
		reloading_time = 4.500000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "exterminator", speed = 30.000000, lifetime = -1.000000},
		ammunition = {id = "2 mm Exterminator Ammunition", clip = 2},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "40:50",
	base_price = 1000,
	inventory = {x = 2, y = 2, image = "weapons/exterminator_simple/inv_image.png" },
	drop = {class = "8:9", sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[While this weapon is capable of firing really powerful shots, beware of the exceptionally long reloading times. (Don't get swarmed by enemies with this weapon unless you have powerful armor!)]],
	rotation_series = "weapons/exterminator_simple",
	tux_part = "iso_exterminator",
},
----------------------------------------------------------------------

{
	id = "The Super Exterminator!!!",
	name =_"The Super Exterminator!!!",
	slot = "weapon",
	weapon = {
		damage = "80:120",
		attack_time = 0.600000,
		reloading_time = 4.500000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "exterminator", speed = 30.000000, lifetime = -1.000000},
		ammunition = {id = "2 mm Exterminator Ammunition", clip = 2},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "30:40",
	base_price = 3000,
	inventory = {x = 2, y = 3, image = "weapons/exterminator_simple/inv_image2.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[This bad boy is known to blow away most enemies with a single blast. A dangerous weapon that you don't want to be on the receiving end of.]],
	rotation_series = "weapons/exterminator_simple",
	tux_part = "iso_exterminator",
},
----------------------------------------------------------------------

{
	id = "VMX Gas Grenade",
	name =_"VMX Gas Grenade",
	right_use = {tooltip = _"Gas attack", skill = "Gas grenade", busy = {type = "throwing", duration = 1}},
	base_price = 250,
	inventory = {x = 1, y = 1,stackable = true, image = "grenades/vmx/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[The gas does not look terrifying. It even smells somewhat nice. And then you die. You die a most horrible death, never knowing what killed you. (Note: This does not work on bots)]],
	rotation_series = "grenades/vmx",
},
----------------------------------------------------------------------

{
	id = "Small EMP Shockwave Generator",
	name =_"Small EMP Shockwave Generator",
	right_use = {tooltip = _"Small Electromagnetic pulse", skill = "Small EMP grenade", busy = {type = "throwing", duration = 1}},
	base_price = 100,
	inventory = {x = 1, y = 1,stackable = true, image = "grenades/emp/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This sphere contains a few strange bits of technology invented by Nikola Tesla in the early 20th century. The magnetic pulse that it generates can damage most electronic devices in just one blast.]],
	rotation_series = "grenades/emp",
},
----------------------------------------------------------------------

{
	id = "EMP Shockwave Generator",
	name =_"EMP Shockwave Generator",
	right_use = {tooltip = _"Electromagnetic pulse", skill = "EMP grenade", busy = {type = "throwing", duration = 1}},
	base_price = 300,
	inventory = {x = 1, y = 1,stackable = true, image = "grenades/emp/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This sphere contains a few strange bits of technology invented by Nikola Tesla in the early 20th century. The magnetic pulse that it generates can destroy most electronic devices in just one blast.]],
	rotation_series = "grenades/emp",
},
----------------------------------------------------------------------

{
	id = "Electronic Noise Generator",
	name =_"Electronic Noise Generator",
	right_use = {tooltip = _"Disable Electronics", skill = "Electronic Noise", busy = {type = "throwing", duration = 1}},
	base_price = 90,
	inventory = {x = 1, y = 1,stackable = true, image = "grenades/emp/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This sphere creates a short blast of electronic noise that temporarily disables most electronics.]],
	rotation_series = "grenades/emp",
},
----------------------------------------------------------------------

{
	id = "Small Plasma Shockwave Emitter",
	name =_"Small Plasma Shockwave Emitter",
	right_use = {tooltip = _"Explosion", skill = "Small Plasma grenade", busy = {type = "throwing", duration = 1}},
	base_price = 200,
	inventory = {x = 1, y = 1,stackable = true, image = "grenades/plasma/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[Said to be an upscaled version of a traditional high temperature explosive.]],
	rotation_series = "grenades/plasma",
},
----------------------------------------------------------------------

{
	id = "Plasma Shockwave Emitter",
	name =_"Plasma Shockwave Emitter",
	right_use = {tooltip = _"Huge explosion", skill = "Plasma grenade", busy = {type = "throwing", duration = 1}},
	base_price = 600,
	inventory = {x = 1, y = 1,stackable = true, image = "grenades/plasma/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[Said to be the downscaled version of the original Pandora's Sphere, this device extinguishes life with superheated plasma.]],
	rotation_series = "grenades/plasma",
},


----------------------------------------------------------------------
---
---             Armor
---
----------------------------------------------------------------------

{
	id = "Normal Jacket",
	name =_"Normal Jacket",
	slot = "armour",
	armor_class = "3:9",
	durability = "10:20",
	base_price = 50,
	inventory = {x = 2, y = 2, image = "armours/basic/inv_image.png" },
	drop = {class = "0:4", sound = "Item_Armour_Put_Sound_0.ogg"},
	description =_[[This piece of clothing made out of Synthex(TM) does a decent job of protection. I guess. Maybe. I'm not sure.]],
	rotation_series = "armours/basic",
	tux_part = "iso_armour1",
},
----------------------------------------------------------------------

{
	id = "Reinforced Jacket",
	name =_"Reinforced Jacket",
	slot = "armour",
	armor_class = "9:18",
	requirements = {strength = 15},
	durability = "20:30",
	base_price = 350,
	inventory = {x = 2, y = 2, image = "armours/basic2/inv_image.png" },
	drop = {class = "2:6", sound = "Item_Armour_Put_Sound_0.ogg"},
	description =_[[One step up from a normal jacket.]],
	rotation_series = "armours/basic2",
	tux_part = "iso_armour1",
},
----------------------------------------------------------------------

{
	id = "Protective Jacket",
	name =_"Protective Jacket",
	slot = "armour",
	armor_class = "18:30",
	requirements = {strength = 25},
	durability = "30:40",
	base_price = 600,
	inventory = {x = 2, y = 2, image = "armours/basic3/inv_image.png" },
	drop = {class = "4:7", sound = "Item_Armour_Put_Sound_0.ogg"},
	description =_[[Very strong for its size, this jacket made out of Shootex(TM) does a good job of absorbing basic blows. It is suitable for all kinds of extreme sports, such as climbing, rafting, bungee-jumping, fencing and even racing.]],
	rotation_series = "armours/basic3",
	tux_part = "iso_armour1",
},
----------------------------------------------------------------------

{
	id = "Red Guard's Light Robe",
	name =_"Red Guard's Light Robe",
	slot = "armour",
	armor_class = "36:42",
	requirements = {strength = 20},
	durability = "35:35",
	base_price = 800,
	inventory = {x = 2, y = 3, image = "armours/robe/inv_image.png" },
	drop = {sound = "Item_Armour_Put_Sound_0.ogg"},
	description =_[[The universal riot gear of the Red Guard. Tough as nails and able to withstand most blows.]],
	rotation_series = "armours/robe",
	tux_part = "iso_robe",
},
----------------------------------------------------------------------

{
	id = "Red Guard's Heavy Robe",
	name =_"Red Guard's Heavy Robe",
	slot = "armour",
	armor_class = "42:48",
	requirements = {strength = 30},
	durability = "40:40",
	base_price = 1000,
	inventory = {x = 2, y = 3, image = "armours/robe/inv_image.png" },
	drop = {sound = "Item_Armour_Put_Sound_0.ogg"},
	description =_[[Defense is acquired at a high level with this durable piece of armor.]],
	rotation_series = "armours/robe",
	tux_part = "iso_robe",
},
----------------------------------------------------------------------

----------------------------------------------------------------------
----    Armor - [Handheld]                                        ----
----------------------------------------------------------------------


{
	id = "Improvised Buckler",
	name =_"Improvised Buckler",
	slot = "shield",
	armor_class = "10:20",
	durability = "5:15",
	base_price = 20,
	inventory = {x = 2, y = 2, image = "shields/buckler/inv_image.png" },
	drop = {class = "0:4", sound = "Item_Armour_Put_Sound_0.ogg"},
	description =_[[This shield is a compilation of various objects which happened to be around. It has tubes, bolts and parts of metal, all slapped together to provide a small bit of protection from enemies. It's very simple and rough, but some sensors and lights have been added to let the wielder know when the item is getting hit, and how long it will remain operational and other cool stuff like that.]],
	rotation_series = "shields/buckler",
	tux_part = "iso_buckler",
},
----------------------------------------------------------------------

{
	id = "Bot Carapace",
	name =_"Bot Carapace",
	slot = "shield",
	armor_class = "15:25",
	durability = "15:25",
	base_price = 40,
	inventory = {x = 2, y = 2, image = "shields/small/inv_image.png" },
	drop = {class = "0:9", sound = "Item_Armour_Put_Sound_0.ogg"},
	description =_[[A small, lightweight and pretty straightforward shield. Provides decent protection.]],
	rotation_series = "shields/small",
	tux_part = "iso_standard_shield",
},
----------------------------------------------------------------------

{
	id = "Standard Shield",
	name =_"Standard Shield",
	slot = "shield",
	armor_class = "25:30",
	durability = "20:30",
	base_price = 250,
	inventory = {x = 2, y = 2, image = "shields/standard/inv_image.png" },
	drop = {class = "1:6", sound = "Item_Armour_Put_Sound_0.ogg"},
	description =_[[Better than a buckler, and a lot more effective.]],
	rotation_series = "shields/standard",
	tux_part = "iso_standard_shield",
},
----------------------------------------------------------------------

{
	id = "Heavy Shield",
	name =_"Heavy Shield",
	slot = "shield",
	armor_class = "25:30",
	requirements = {strength = 20},
	durability = "30:40",
	base_price = 250,
	inventory = {x = 2, y = 2, image = "shields/heavy/inv_image.png" },
	drop = {class = "3:7", sound = "Item_Armour_Put_Sound_0.ogg"},
	description =_[[A medium sized, reinforced shield. Heavier than a standard shield, but should last longer. Provides decent protection.]],
	rotation_series = "shields/heavy",
	tux_part = "iso_heavy_shield",
},
----------------------------------------------------------------------

{
	id = "Riot Shield",
	name =_"Riot Shield",
	slot = "shield",
	armor_class = "35:40",
	requirements = {strength = 25},
	durability = "40:50",
	base_price = 480,
	inventory = {x = 2, y = 2, image = "shields/riot/inv_image.png" },
	drop = {class = "5:9", sound = "Item_Armour_Put_Sound_0.ogg"},
	description =_[[A powerful shield, as useful to protect from bots as it is to control big crowds of angry protesters.]],
	rotation_series = "shields/riot",
	tux_part = "iso_riot_shield",
},
----------------------------------------------------------------------

----------------------------------------------------------------------
----    Armor - [Head]                                            ----
----------------------------------------------------------------------

{
	id = "Pot Helmet",
	name =_"Pot Helmet",
	slot = "special",
	armor_class = "3:6",
	durability = "5:20",
	base_price = 20,
	inventory = {x = 2, y = 2, image = "helmets/skull_cap/inv_image.png" },
	drop = {class = "0:9", sound = "Item_Drop_Sound_0.ogg"},
	description =_[[Top of the line headgear, for bots. But rip it off their metal necks and take out the circuits it also manages to protect living beings decently against a myriad of close range and long range attacks.]],
	rotation_series = "helmets/skull_cap",
	tux_part = "iso_helm1",
},
----------------------------------------------------------------------

{
	id = "Worker Helmet",
	name =_"Worker Helmet",
	slot = "special",
	armor_class = "4:7",
	durability = "15:25",
	base_price = 90,
	inventory = {x = 2, y = 2, image = "helmets/yellow/inv_image.png" },
	drop = {class = "1:5", sound = "Item_Drop_Sound_0.ogg"},
	description =_[[A simple cover to protect your head. Don't expect to be incognito, your flippers and penguin like body are hard to miss.]],
	rotation_series = "helmets/yellow",
	tux_part = "iso_helm1",
},
----------------------------------------------------------------------

{
	id = "Miner Helmet",
	name =_"Miner Helmet",
	slot = "special",
	armor_class = "5:10",
	durability = "10:20",
	base_price = 250,
	inventory = {x = 2, y = 2, image = "helmets/yellow4/inv_image.png" },
	drop = {class = "2:6", sound = "Item_Drop_Sound_0.ogg"},
	description =_[[It might look a bit silly, but it will save your life many times.]],
	rotation_series = "helmets/yellow4",
	tux_part = "iso_helm1",
},
----------------------------------------------------------------------

{
	id = "Light Battle Helmet",
	name =_"Light Battle Helmet",
	slot = "special",
	armor_class = "8:12",
	requirements = {strength = 15},
	durability = "25:35",
	base_price = 360,
	inventory = {x = 2, y = 2, image = "helmets/yellow2/inv_image.png" },
	drop = {class = "3:7", sound = "Item_Drop_Sound_0.ogg"},
	description =_[[A rather useful helmet, has a few defense issues here and there but mainly is worth the wear.]],
	rotation_series = "helmets/yellow2",
	tux_part = "iso_helm1",
},
----------------------------------------------------------------------

{
	id = "Battle Helmet",
	name =_"Battle Helmet",
	slot = "special",
	armor_class = "12:16",
	requirements = {strength = 20},
	durability = "25:40",
	base_price = 480,
	inventory = {x = 2, y = 2, image = "helmets/yellow3/inv_image.png" },
	drop = {class = "4:8", sound = "Item_Drop_Sound_0.ogg"},
	description =_[[Now this is head protection. Feel safe with sturdy Resosteel(TM) protecting your head. Not as comfortable as other hats but the precious content stays safe.]],
	rotation_series = "helmets/yellow3",
	tux_part = "iso_helm1",
},
----------------------------------------------------------------------

{
	id = "Dixon's Helmet",
	name =_"Dixon's Helmet",
	slot = "special",
	armor_class = "11",
	durability = "3:3",
	base_price = 55,
	inventory = {x = 2, y = 2, image = "helmets/yellow4/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_0.ogg"},
	description =_[[A gift from Dixon. It looks like it is about to turn into dust.]],
	rotation_series = "helmets/yellow4",
	tux_part = "iso_helm1",
},
----------------------------------------------------------------------

----------------------------------------------------------------------
----    Armor - [Feet]                                            ----
----------------------------------------------------------------------


{
	id = "Shoes",
	name =_"Shoes",
	slot = "drive",
	armor_class = "2:6",
	durability = "5:10",
	base_price = 27,
	inventory = {x = 2, y = 2, image = "armours/boots/inv_image.png" },
	drop = {class = "0:4", sound = "Item_Drop_Sound_1.ogg"},
	description =_[[These simple boots are designed for comfort of the wearer more than to give actual protection.]],
	rotation_series = "armours/boots",
	tux_part = "iso_boots1",
},
----------------------------------------------------------------------

{
	id = "Worker Shoes",
	name =_"Worker Shoes",
	slot = "drive",
	armor_class = "6:10",
	durability = "10:20",
	base_price = 85,
	inventory = {x = 2, y = 2, image = "armours/boots/inv_image.png" },
	drop = {class = "1:5", sound = "Item_Drop_Sound_0.ogg"},
	description =_[[These footwears are steel tipped, and generally quite sturdy, giving a bit extra protection.]],
	rotation_series = "armours/boots",
	tux_part = "iso_boots1",
},
----------------------------------------------------------------------

{
	id = "Battle Shoes",
	name =_"Battle Shoes",
	slot = "drive",
	armor_class = "10:14",
	durability = "15:25",
	base_price = 250,
	inventory = {x = 2, y = 2, image = "armours/boots/inv_image.png" },
	drop = {class = "4:8", sound = "Item_Drop_Sound_0.ogg"},
	description =_[[These boots are similar to the simple shoes, but the material they are made of is hardened for extra protection.]],
	rotation_series = "armours/boots",
	tux_part = "iso_boots1",
},
----------------------------------------------------------------------

----------------------------------------------------------------------
----    Usable - [Book]                                           ----
----------------------------------------------------------------------

{
	id = "Source Book of Emergency shutdown",
	name =_"Source Book of Emergency Shutdown",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Emergency shutdown"},
	base_price = 500,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_green.png" },
	drop = {class = "2:9", sound = "drop_book_sound.ogg"},
	description =_[[Everyone needs to blow off some steam every now and then.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Check system integrity",
	name =_"Source Book of Check System Integrity",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Check system integrity"},
	base_price = 250,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_white.png" },
	drop = {class = "2:9", sound = "drop_book_sound.ogg"},
	description =_[[An incredible healing program, probably the only one you will ever need.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Sanctuary",
	name =_"Source Book of Sanctuary",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Sanctuary"},
	base_price = 450,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_green.png" },
	drop = {sound = "drop_book_sound.ogg"},
	description =_[[The art of rapidly moving away from danger is very useful. Even when used in reverse, it has its uses.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Malformed packet",
	name =_"Source Book of Malformed Packet",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Malformed packet"},
	base_price = 300,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_purple.png" },
	drop = {class = "2:9", sound = "drop_book_sound.ogg"},
	description =_[[When computers are presented with the unexpected, they can damage themselves.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Calculate Pi",
	name =_"Source Book of Calculate Pi",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Calculate Pi"},
	base_price = 300,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_orange.png" },
	drop = {class = "2:9", sound = "drop_book_sound.ogg"},
	description =_[[It is not a big problem to make a badly designed system to go hunting for the impossible, causing a performance impact.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Blue Screen",
	name =_"Source Book of Blue Screen",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Blue Screen"},
	base_price = 300,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_blue.png" },
	drop = {class = "3:9", sound = "drop_book_sound.ogg"},
	description =_[[With a little touch a war machine comes crashing to a halt. For a while.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Broadcast Blue Screen",
	name =_"Source Book of Broadcast Blue Screen",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Broadcast Blue Screen"},
	base_price = 900,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_blue.png" },
	drop = {class = "5:9", sound = "drop_book_sound.ogg"},
	description =_[[With a little touch a war machine comes crashing to a halt. For a while.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Invisibility",
	name =_"Source Book of Invisibility",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Invisibility"},
	base_price = 550,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_green.png" },
	drop = {class = "6:9", sound = "drop_book_sound.ogg"},
	description =_[[I am not the Linarian you are looking for.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Virus",
	name =_"Source Book of Virus",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Virus"},
	base_price = 450,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_red.png" },
	drop = {class = "4:9", sound = "drop_book_sound.ogg"},
	description =_[[This is not just a firmware upgrade, my dear bot. You are about to find out what exactly I want to give you.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Broadcast virus",
	name =_"Source Book of Broadcast Virus",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Broadcast virus"},
	base_price = 1350,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_red.png" },
	drop = {class = "6:9", sound = "drop_book_sound.ogg"},
	description =_[[The network is wide and dangerous. Many traps await the weak and unprepared.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Dispel smoke",
	name =_"Source Book of Dispel Smoke",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Dispel smoke"},
	base_price = 600,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_grey.png" },
	drop = {class = "3:9", sound = "drop_book_sound.ogg"},
	description =_[[By heating up the chips with a malformed program, you can cause them to release the magic smoke which keeps the bot running.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Killer poke",
	name =_"Source Book of Killer Poke",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Killer poke"},
	base_price = 1200,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_greenblue.png" },
	drop = {class = "5:9", sound = "drop_book_sound.ogg"},
	description =_[[Messing around with the bot's memory can cause it to damage itself, but the damage is greatly variable.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Repair equipment",
	name =_"Source Book of Repair Equipment",
	right_use = {tooltip = _"Learn about repairing items", add_skill = "Repair equipment"},
	base_price = 1200,
	inventory = {x = 2, y = 2, image = "repairbook/inv_image.png" },
	drop = {class = "4:9", sound = "drop_book_sound.ogg"},
	description =_[[This manual will help you fix a broken dishwasher, a car, or a gun. The covers does not mention anything about breaking robots however.]],
	rotation_series = "repairbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Plasma discharge",
	name =_"Source Book of Plasma Discharge",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Plasma discharge"},
	base_price = 1800,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image.png" },
	drop = {sound = "drop_book_sound.ogg"},
	description =_[[The overload setting exists for emergencies. Plasma does not discriminate between bots and humans. Everything is the same to it.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Nethack",
	name =_"Source Book of Nethack",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Nethack"},
	base_price = 450,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_yellow.png" },
	drop = {sound = "drop_book_sound.ogg"},
	description =_[[The open source game called Nethack is one of the world's greatest wasters of time. Machines don't care about it, but humans can get sucked in quite deeply.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Ricer CFLAGS",
	name =_"Source Book of Ricer CFLAGS",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Ricer CFLAGS"},
	base_price = 600,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image.png" },
	drop = {sound = "drop_book_sound.ogg"},
	description =_[[Optimization is the root of all evil. You can gain some temporary improvements to your system, but in the end you are only likely to cause permanent damage.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Reverse-engineer",
	name =_"Source Book of Reverse-engineer",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Reverse-engineer"},
	base_price = 450,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_orange.png" },
	drop = {sound = "drop_book_sound.ogg"},
	description =_[[There is some dark magic in the art of turning bots inside-out to learn all their secrets.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Light",
	name =_"Source Book of Light",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Light"},
	base_price = 450,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_white.png" },
	drop = {sound = "drop_book_sound.ogg"},
	description =_[[Let there be light...]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Network Mapper",
	name =_"Source Book of Network Mapper",
	right_use = {tooltip = _"Permanently acquire/enhance this program", add_skill = "Network Mapper"},
	base_price = 300,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_green.png" },
	drop = {sound = "drop_book_sound.ogg"},
	description =_[[Knowing what your enemies are up to is easy with a little signal intelligence. Displays enemy locations on your automap.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Source Book of Energy Shield",
	name =_"Source Book of Energy Shield",
	right_use = {tooltip =_"Permanently acquire/enhance this program", add_skill =_"Energy Shield"},
	base_price = 500,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_greenblue.png" },
	drop = {sound = "drop_book_sound.ogg"},
	description =_[[Creating an energy shield to protect you can be a very useful skill. Every hit that you get will be converted into heat. Beware: This heats up excessively. Equipment can still be damaged by heat. When you overheat, shield will try to automatically turn off to prevent damage to itself. It may provoke extra-heat on this process, so be sure to not let it happen.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Nuclear Science for Dummies IV",
	name =_"Subatomic and Nuclear Science for Dummies, Volume IV",
	base_price = 600,
	inventory = {x = 2, y = 2, image = "spellbook/inv_image_green.png" },
	drop = {sound = "drop_book_sound.ogg"},
	description =_[[From the back of the cover: 'Subatomic and Nuclear Science for Dummies, Volume IV is the most popular handbook series for learning nuclear science: Learn to generate enough power to keep you town lit up for a decade! Discover how to really scare neighboring countries! Find out how to make your very own mutant pet!' This obviously important tome of knowledge from before the great assault comes with no warranty whatsoever.]],
	rotation_series = "spellbook",
},
----------------------------------------------------------------------

{
	id = "Manual of the Automated Factory",
	name =_"Manual of the Automated Factory",
	base_price = 0,
	inventory = {x = 2, y = 2, image = "repairbook/inv_image.png" },
	drop = {sound = "drop_book_sound.ogg"},
	description =_[[This book describes the operation and repair of automated factories. Included are common error codes and how to fix them. However, most repairs simply call for liberal application of 'Elbow Grease'.]],
	rotation_series = "repairbook",
},
----------------------------------------------------------------------

{
	id = "Manual of the Extract Bot Parts",
	name =_"Manual of the Extract Bot Parts",
	right_use = {tooltip = _"USE FOR CHEATING ONLY. If you see this ingame, please report the bug.", add_skill = "Extract bot parts"},
	base_price = 0,
	inventory = {x = 2, y = 2, image = "repairbook/inv_image.png" },
	drop = {sound = "drop_book_sound.ogg"},
	description =_[[USE FOR CHEATING ONLY. If you see this ingame, please report the bug.]],
	rotation_series = "repairbook",
},
----------------------------------------------------------------------

----------------------------------------------------------------------
----    Usable - [Pills & Potions]                                ----
----------------------------------------------------------------------

{
	id = "Strength Pill",
	name =_"Strength Pill",
	right_use = {tooltip = _"Permanently gain +1 strength", busy = {type = "pill", duration = 1}},
	base_price = 250,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/strength/inv_image.png" },
	drop = {class = "2:9", sound = "Item_Drop_Sound_4.ogg"},
	description =_[[These pills permanently raise strength within a person. They work on a nano-technological basis. Consult your physician, the receipt or pharmacy experts for details on intended effects, possible interactions and side effects of this drug.]],
	rotation_series = "pills_potions/strength",
},
----------------------------------------------------------------------

{
	id = "Dexterity Pill",
	name =_"Dexterity Pill",
	right_use = {tooltip = _"Permanently gain +1 dexterity", busy = {type = "pill", duration = 1}},
	base_price = 250,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/dexterity/inv_image.png" },
	drop = {class = "2:9", sound = "Item_Drop_Sound_4.ogg"},
	description =_[[These pills permanently raise dexterity within a person. They work on a nano-technological basis. Consult your physician, the receipt or pharmacy experts for details on intended effects, possible interactions and side effects of this drug.]],
	rotation_series = "pills_potions/dexterity",
},
----------------------------------------------------------------------

{
	id = "Code Pill",
	name =_"Code Pill",
	right_use = {tooltip = _"Permanently gain +1 cooling", busy = {type = "pill", duration = 1}},
	base_price = 250,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/magic/inv_image.png" },
	drop = {class = "2:9", sound = "Item_Drop_Sound_4.ogg"},
	description =_[[Dude! This fab food will totally bump up your code skills, man! A real blast. Scarf these down to *see* the code.]],
	rotation_series = "pills_potions/magic",
},
----------------------------------------------------------------------

{
	id = "Brain Enlargement Pills Antidote",
	name =_"Brain Enlargement Pills Antidote",
	base_price = 0,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/brain_enlargement_antidode/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[These pills can reverse the harmful effects of the 'brain enlargement pills' that are publicly sold via the Internet. The planet-wide guild of medics has recommended not to respond to these adverts at all, while attempts to entirely ban the distribution of those pills were never completely successful.]],
	rotation_series = "pills_potions/brain_enlargement_antidode",
},
----------------------------------------------------------------------

{
	id = "Brain Enlargement Pill",
	name =_"Brain Enlargement Pill",
	right_use = {tooltip = _"Gain fast acting cancer", busy = {type = "pill", duration = 1}},
	base_price = 0,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/brain_enlargement_antidode/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	--; xgettext:no-c-format
	description =_[[Doctors all over the planet have tried to suppress the amazing breakthrough which has brought increased alertness and concentration that comes with a larger brain. They are synthesized using cutting edge technology and 100% natural herbal ingredients from a secret five thousand-year-old traditional holistic recipe. Get yours direct from our online Canadian ph4rm4cy!!! 100% satisfaction guaranteed!!!]],
	rotation_series = "pills_potions/brain_enlargement_antidode",
},
----------------------------------------------------------------------

{
	id = "Diet supplement",
	name =_"Diet Supplement",
	right_use = {tooltip = _"Recover Health", busy = {type = "drinking", duration = 1}},
	base_price = 20,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/health_capsule/inv_image_small.png" },
	drop = {class = "0:5", sound = "drop_potion_sound.ogg"},
	description =_[[Only proper vitamin and mineral intake can keep you healthy during the apocalypse. This can cure a cold.]],
	rotation_series = "pills_potions/health_capsule",
},
----------------------------------------------------------------------

{
	id = "Antibiotic",
	name =_"Antibiotic",
	right_use = {tooltip = _"Recover Health", busy = {type = "pill", duration = 1}},
	base_price = 40,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/health_capsule/inv_image_medium.png" },
	drop = {class = "4:7", sound = "drop_potion_sound.ogg"},
	description =_[[Truly wonderful things can be extracted from molds. This can cure lethal food poisoning. Wish you had that in your last Nethack game, eh?]],
	rotation_series = "pills_potions/health_capsule",
},
----------------------------------------------------------------------

{
	id = "Doc-in-a-can",
	name =_"Doc-in-a-can",
	right_use = {tooltip = _"Recover Health", busy = {type = "drinking", duration = 1}},
	base_price = 60,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/health_capsule/inv_image_big.png" },
	drop = {class = "6:9", sound = "drop_potion_sound.ogg"},
	description =_[[This is a drink filled with nanobots designed to heal any damage that they notice inside you. It can cure decapitation. Most of the time.]],
	rotation_series = "pills_potions/health_capsule",
},
----------------------------------------------------------------------

{
	id = "Bottled ice",
	name =_"Bottled Ice",
	right_use = {tooltip = _"Cooling aid", busy = {type = "drinking", duration = 1}},
	base_price = 15,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/force_capsule/inv_image_small.png" },
	drop = {class = "0:5", sound = "drop_potion_sound.ogg"},
	description =_[[This bottle is filled with ice. It can keep you cool during a warm summer day.]],
	rotation_series = "pills_potions/force_capsule",
},
----------------------------------------------------------------------

{
	id = "Industrial coolant",
	name =_"Industrial Coolant",
	right_use = {tooltip = _"Cooling aid", busy = {type = "drinking", duration = 1}},
	base_price = 30,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/force_capsule/inv_image_medium.png" },
	drop = {class = "4:7", sound = "drop_potion_sound.ogg"},
	description =_[[Bartenders around the world add this to drinks to get them cold very fast. Plus, the coolant is much cheaper. It can keep you cool inside a nuclear reactor.]],
	rotation_series = "pills_potions/force_capsule",
},
----------------------------------------------------------------------

{
	id = "Liquid nitrogen",
	name =_"Liquid Nitrogen",
	right_use = {tooltip = _"Extreme Cooling aid", busy = {type = "drinking", duration = 1}},
	base_price = 45,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/force_capsule/inv_image_big.png" },
	drop = {class = "6:9", sound = "drop_potion_sound.ogg"},
	description =_[[When you want something frozen solid, this is what you need. It can keep you cool even inside a class M star.]],
	rotation_series = "pills_potions/force_capsule",
},
----------------------------------------------------------------------

{
	id = "Barf's Energy Drink",
	name =_"Barf's Energy Drink",
	right_use = {tooltip = _"Cool down, cure minor wounds.", busy = {type = "drinking", duration = 1}},
	base_price = 50,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/blue_energy_drink/inv_image.png" },
	drop = {class = "2:9", sound = "drop_potion_sound.ogg"},
	description =_[[Warning! These energy drinks contain high doses of caffeine! The average person drops dead after consuming 12 grams of caffeine. One of these bottles contains over double that amount.]],
	rotation_series = "pills_potions/blue_energy_drink",
},
----------------------------------------------------------------------

{
	id = "Running Power Capsule",
	name =_"Running Power Capsule",
	right_use = {tooltip = _"Recover Running Power", busy = {type = "drinking", duration = 1}},
	base_price = 45,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/energy_capsule/inv_image.png" },
	drop = {class = "2:9", sound = "drop_potion_sound.ogg"},
	description =_[[These small containers hold purified running strength. Each capsule can be used only once, but many of them can be grouped together like one item in your inventory.]],
	rotation_series = "pills_potions/energy_capsule",
},
----------------------------------------------------------------------

{
	id = "Strength Capsule",
	name =_"Strength Capsule",
	right_use = {tooltip = _"Temporary Boost to Strength", busy = {type = "drinking", duration = 1}},
	base_price = 150,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/energy_capsule/inv_image.png" },
	drop = {class = "2:9", sound = "drop_potion_sound.ogg"},
	description =_[[These small containers hold purified strength. This item will give a temporary boost to strength. Each capsule can be used only once, but many of them can be grouped together like one item in your inventory.]],
	rotation_series = "pills_potions/energy_capsule",
},
----------------------------------------------------------------------

{
	id = "Dexterity Capsule",
	name =_"Dexterity Capsule",
	right_use = {tooltip = _"Temporary Boost to Dexterity", busy = {type = "drinking", duration = 1}},
	base_price = 150,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/energy_capsule/inv_image.png" },
	drop = {class = "2:9", sound = "drop_potion_sound.ogg"},
	description =_[[These small containers hold purified dexterity. This item will give a temporary bonus to dexterity. Each capsule can be used only once, but many of them can be grouped together like one item in your inventory.]],
	rotation_series = "pills_potions/energy_capsule",
},
----------------------------------------------------------------------

----------------------------------------------------------------------
----    [Others]                                                  ----
----------------------------------------------------------------------

{
	id = "Valuable Circuits",
	name =_"Valuable Circuits",
	base_price = 1,
	inventory = {x = 1, y = 1,stackable = true, image = "cyberbucks/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_2.ogg"},
	description =_[[The new monetary standard of the world. With the collapse of the banking system, the precious metals in bot circuitry are now de facto hard cash. A bit difficult to get, though, as the bots are not likely to just hand it over...]],
	rotation_series = "cyberbucks",
},
----------------------------------------------------------------------

{
	id = "Anti-grav Pod for Droids",
	name =_"Anti-grav Pod for Droids",
	base_price = 450,
	inventory = {x = 2, y = 2, image = "antigrav_unit/inv_image.png" },
	drop = {class = "3:9", sound = "Item_Drop_Sound_0.ogg"},
	description =_[[The bots use this to hover around.]],
	rotation_series = "antigrav_unit",
},
----------------------------------------------------------------------

{
	id = "Dixon's Toolbox",
	name =_"Dixon's Toolbox",
	base_price = 0,
	inventory = {x = 2, y = 2, image = "dixons_toolbox/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This is a teleporter service toolbox. It's complete and orderly, though a few dents on the outside give proof of frequent use. 'C. Dixon' is carved into the outside with fine print.]],
	rotation_series = "dixons_toolbox",
},
----------------------------------------------------------------------

{
	id = "Toolbox",
	name =_"Toolbox",
	base_price = 0,
	inventory = {x = 2, y = 2, image = "toolbox/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This is a regular toolbox. It's complete and orderly, though a few dents on the outside give proof of frequent use.]],
	rotation_series = "toolbox",
},
----------------------------------------------------------------------

{
	id = "Entropy Inverter",
	name =_"Entropy Inverter",
	base_price = 40,
	inventory = {x = 1, y = 1,stackable = true, image = "entropy_inverter/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This is an standard part within many robot types.]],
	rotation_series = "entropy_inverter",
},
----------------------------------------------------------------------

{
	id = "Plasma Transistor",
	name =_"Plasma Transistor",
	base_price = 40,
	inventory = {x = 1, y = 1,stackable = true, image = "plasma_transistor/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This is an standard part within many robot types.]],
	rotation_series = "plasma_transistor",
},
----------------------------------------------------------------------

{
	id = "Superconducting Relay Unit",
	name =_"Superconducting Relay Unit",
	base_price = 50,
	inventory = {x = 1, y = 1,stackable = true, image = "superconducting_relay_unit/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This is an standard part within many robot types.]],
	rotation_series = "superconducting_relay_unit",
},
----------------------------------------------------------------------

{
	id = "Antimatter-Matter Converter",
	name =_"Antimatter-Matter Converter",
	base_price = 100,
	inventory = {x = 1, y = 1,stackable = true, image = "antimatter_matter_converter/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This is an standard part within many robot types.]],
	rotation_series = "antimatter_matter_converter",
},
----------------------------------------------------------------------

{
	id = "Tachyon Condensator",
	name =_"Tachyon Condensator",
	base_price = 40,
	inventory = {x = 1, y = 1,stackable = true, image = "tachyon_converter/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This is an standard part within many robot types.]],
	rotation_series = "tachyon_converter",
},
----------------------------------------------------------------------

{
	id = "Desk Lamp",
	name =_"Desk Lamp",
	base_price = 32,
	inventory = {x = 2, y = 2, image = "desk_lamp/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[What would modern science be without this important item?]],
	rotation_series = "desk_lamp",
},
----------------------------------------------------------------------

{
	id = "Red Dilithium Crystal",
	name =_"Red Dilithium Crystal",
	base_price = 0,
	inventory = {x = 2, y = 2,stackable = true, image = "red_dilitium_crystal/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[These dilithium crystals are used as an energy source in many modern electricity or heat based devices. Energy is extracted from the crystal by making use of the ordering of the crystal molecules. This principle has allowed us to build devices that consume a lot of energy, but do not need to be connected to a power line.]],
	rotation_series = "red_dilitium_crystal",
},
----------------------------------------------------------------------

{
	id = "Map Maker",
	name =_"Map Maker",
	right_use = {tooltip = _"To implant the automap device"},
	base_price = 75,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/magic/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This small device automatically collects data about the area within a range of 7 times 7 meters and draws a small-scale plan of the immediate surroundings. Because of its very tiny display, it needs to be held closely to the eye, and the image will then be projected directly into the eyeball of the user. Still, the collected map data will be split up by the device into several sectors for convenient viewing.]],
	rotation_series = "pills_potions/magic",
},
----------------------------------------------------------------------

{
	id = "Light Enhancer? to be included in the future...",
	name =_"Light Enhancer? to be included in the future...",
	right_use = {tooltip = _"See better in the dark."},
	base_price = 18,
	inventory = {x = 2, y = 2, image = "map_maker/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[See better in the dark.]],
	rotation_series = "map_maker",
},
----------------------------------------------------------------------

{
	id = "Fork",
	name =_"Fork",
	slot = "weapon",
	weapon = {
		damage = "1:1",
		attack_time = 0.100000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "1:1",
	base_price = 50,
	inventory = {x = 1, y = 1, image = "eating_fork/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This item is part of the 'Self Cleaning Kitchen' (SCK) project from before the Great Assault. All of the items in the SCK project have an inner mechanism that will clean the object automatically if left alone for a given time. It comes with its own power supply, and has a supposed duration of 200 years.]],
	rotation_series = "eating_fork",
	tux_part = "iso_hunting_knife",
},
----------------------------------------------------------------------

{
	id = "Plate",
	name =_"Plate",
	base_price = 50,
	inventory = {x = 2, y = 2,stackable = true, image = "eating_plate/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This item is part of the 'Self Cleaning Kitchen' (SCK) project from before the Great Assault. All of the items in the SCK project have an inner mechanism that will clean the object automatically if left alone for a given time. It comes with its own power supply, and has a supposed duration of 200 years.]],
	rotation_series = "eating_plate",
},
----------------------------------------------------------------------

{
	id = "Mug",
	name =_"Mug",
	base_price = 50,
	inventory = {x = 1, y = 1, image = "drinking_mug/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This item is part of the 'Self Cleaning Kitchen' (SCK) project from before the Great Assault. All of the items in the SCK project have an inner mechanism that will clean the object automatically if left alone for a given time. It comes with its own power supply, and has a supposed duration of 200 years.]],
	rotation_series = "drinking_mug",
},
----------------------------------------------------------------------

{
	id = "Cup",
	name =_"Cup",
	base_price = 50,
	inventory = {x = 1, y = 1, image = "drinking_mug_2/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This item is part of the 'Self Cleaning Kitchen' (SCK) project from before the Great Assault. All of the items in the SCK project have an inner mechanism that will clean the object automatically if left alone for a given time. It comes with its own power supply, and has a supposed duration of 200 years.]],
	rotation_series = "drinking_mug_2",
},
----------------------------------------------------------------------

{
	id = "Teleporter homing beacon",
	name =_"Teleporter Homing Beacon",
	right_use = {tooltip = _"Teleports you elsewhere", skill = "Sanctuary"},
	base_price = 40,
	inventory = {x = 1, y = 1,stackable = true, image = "tele_beacon/inv_image.png" },
	drop = {sound = "drop_book_sound.ogg"},
	description =_[[This device sends a signal to a nearby teleporter requesting a transport, and then helps with locking on and boosting the signal to ensure the teleportation attempt is successful. The battery inside is sufficient for one use *only* and the device becomes useless afterwards. At least, most people don't try to use them twice... and those few who do usually end up with parts of their body missing or attached in the wrong place. Note: Multiple of these may be grouped together in the inventory.]],
	rotation_series = "tele_beacon",
},
----------------------------------------------------------------------

{
	id = "Data cube",
	name =_"Data Cube",
	base_price = 40,
	inventory = {x = 1, y = 1, image = "datacube/inv_image.png" },
	drop = {sound = "drop_book_sound.ogg"},
	description =_[[This was the most common form of portable information storage used on Earth until the Great Assault, its three-dimensional memory capable of storing up to 2 terabytes and compatible with most of the hardware on the planet.]],
	rotation_series = "datacube",
},
----------------------------------------------------------------------

{
	id = "Kevin's Data Cube",
	name =_"Kevin's Data Cube",
	base_price = 0,
	inventory = {x = 2, y = 2, image = "kevins_datacube/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This data cube contains confidential government data on the installations around the town. Kevin hopes that when the data is evaluated properly, a way out of the current crisis might be found. However, the amount of data is so vast, it can only be evaluated properly using a large cluster of computers. The Red Guard base is said to store an infrastructure suitable to this purpose.]],
	rotation_series = "kevins_datacube",
},
----------------------------------------------------------------------

{
	id = "Pandora's Cube",
	name =_"Pandora's Cube",
	base_price = 0,
	inventory = {x = 3, y = 3, image = "datacube/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This is heavy. Cannot the end of the world come in a smaller package? It would be a great time for Duncan to explain a few things...]],
	rotation_series = "datacube",
},
----------------------------------------------------------------------

{
	id = "Rubber duck",
	name =_"Rubber Duck",
	base_price = 0,
	inventory = {x = 1, y = 1, image = "rubber_duck/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[It appears that humans enjoy bathing with squeaky little pieces of plastic shaped like waterfowl. As a penguinoid, you should probably be disturbed, but you have to admit this thing is actually quite adorable.]],
	rotation_series = "rubber_duck",
},
----------------------------------------------------------------------

{
	id = "Empty Picnic Basket",
	name =_"Empty Picnic Basket",
	base_price = 0,
	inventory = {x = 4, y = 4, image = "empty_picnic_basket/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This is the latest in 'Dr. How?'-brand picnic basket technology! With patented food-preserving time-dilation, space-bending miniaturization, and anti-gravity, your food stays fresh and your drinks stay cold in a small light-as-a-feather package! Now you can picnic the old fashioned way! Batteries sold separately.]],
	rotation_series = "empty_picnic_basket",
},
----------------------------------------------------------------------

{
	id = "Lunch in a Picnic Basket",
	name =_"Lunch in a Picnic Basket",
	base_price = 0,
	inventory = {x = 4, y = 4, image = "picnic_basket/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This is a 'Dr. How?'-brand picnic basket stuffed full of enough food and drinks to feed a dozen people. With 'Dr. How?'-time dilation, the food keeps oven-fresh, and the drinks stay ice-cold.]],
	rotation_series = "picnic_basket",
},
----------------------------------------------------------------------

{
	id = "MS Stock Certificate",
	name =_"MS Stock Certificate",
	base_price = 0,
	inventory = {x = 1, y = 1, image = "stock_certificate/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This is a Stock Certificate for transfer of ownership of five hundred sixty-seven million shares of MegaSystems from William Gapes to bearer.]],
	rotation_series = "stock_certificate",
},
----------------------------------------------------------------------

{
	id = "Elbow Grease Can",
	name =_"Elbow Grease Can",
	base_price = 0,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/blue_energy_drink/inv_image.png" },
	drop = {sound = "drop_potion_sound.ogg"},
	description =_[[A can filled with elbow grease. Hard to make it if you are not a strong man.]],
	rotation_series = "pills_potions/blue_energy_drink",
},

 ----------------------------------------------------------------------

{
	id = "MS EPROM Programming Interface",
	name =_"MS EPROM Programming Interface",
	base_price = 0,
	inventory = {x = 2, y = 2, image = "eprom/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[Used by developers at MegaSys to load firmware onto newly assembled droids.]],
	rotation_series = "eprom",
},
----------------------------------------------------------------------

----------------------------------------------------------------------
----    [Add-ons]                                                 ----
----------------------------------------------------------------------

{
	id = "Linarian power crank",
	name =_"Linarian Power Crank",
	base_price = 100,
	inventory = {x = 1, y = 1, image = "addons/linarian_power_crank/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This mechanical crank, product of the highly advanced and sophisticated technological genius of the Linarian race, performs elaborate operations on energy and directs it towards a biochemical structure. For short, it buffs up your muscles. That's good.]],
	rotation_series = "addons/linarian_power_crank",
},
----------------------------------------------------------------------

{
	id = "Tungsten spikes",
	name =_"Tungsten Spikes",
	base_price = 100,
	inventory = {x = 1, y = 1, image = "addons/tungsten_spikes/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This polycarbonate surface is lined with hard tungsten spikes, and can be installed into a mechanical socket on most melee weapons, offering a simple and affordable solution to increasing damage dealt. Handle only with gloves. Do not attempt to use as footwear. Do not attempt to eat.]],
	rotation_series = "addons/tungsten_spikes",
},
----------------------------------------------------------------------

{
	id = "Tinfoil patch",
	name =_"Tinfoil Patch",
	base_price = 100,
	inventory = {x = 2, y = 2,stackable = true, image = "addons/tinfoil_patch/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[When attached to your armor, this patch of tinfoil allows you to stay cooler by reducing the amount of electromagnetic radiation that your body absorbs.]],
	rotation_series = "addons/tinfoil_patch",
},
----------------------------------------------------------------------

{
	id = "Laser sight",
	name =_"Laser Sight",
	base_price = 100,
	inventory = {x = 1, y = 1, image = "addons/laser_sight/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[A miniaturized laser powered by a nuclear battery. When attached parallel to the barrel of a gun, it makes a little red dot on the target and helps with aiming.]],
	rotation_series = "addons/laser_sight",
},
----------------------------------------------------------------------

{
	id = "Exoskeletal joint",
	name =_"Exoskeletal Joint",
	base_price = 100,
	inventory = {x = 2, y = 2, image = "addons/exoskeletal_joint/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This electromechanical joint helps you to perform physically demanding tasks more easily by amplifying the movements of your body.]],
	rotation_series = "addons/exoskeletal_joint",
},
----------------------------------------------------------------------

{
	id = "Heatsink",
	name =_"Heatsink",
	base_price = 100,
	inventory = {x = 1, y = 1, image = "addons/heatsink/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[A simple heatsink add-on that keeps you cooler by dissipating heat from your armor.]],
	rotation_series = "addons/heatsink",
},
----------------------------------------------------------------------

{
	id = "Peltier element",
	name =_"Peltier Element",
	base_price = 100,
	inventory = {x = 1, y = 1, image = "addons/peltier_element/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[A thermoelectric device that increases your cooling rate.]],
	rotation_series = "addons/peltier_element",
},
----------------------------------------------------------------------

{
	id = "Steel mesh",
	name =_"Steel Mesh",
	base_price = 100,
	inventory = {x = 2, y = 2,stackable = true, image = "addons/steel_mesh/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[A sturdy metal mesh that provides an extra protective layer to your armor.]],
	rotation_series = "addons/steel_mesh",
},
----------------------------------------------------------------------

{
	id = "Shock discharger",
	name =_"Shock Discharger",
	base_price = 100,
	inventory = {x = 1, y = 1, image = "addons/shock_discharger/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[When installed to a melee weapon, this nifty device gives a small electric shock to enemies you hit.]],
	rotation_series = "addons/shock_discharger",
},
----------------------------------------------------------------------

{
	id = "Silencer",
	name =_"Silencer",
	base_price = 100,
	inventory = {x = 1, y = 1, image = "addons/silencer/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This new generation silencer will not only allow you to catch your enemies by surprise, but will also help you to do more damage in ranged combat.]],
	-- NOTE silencers slow bullets to subsonic to make them quieter when they emerge from the barrel.
	rotation_series = "addons/silencer",
},
----------------------------------------------------------------------

{
	id = "Coprocessor",
	name =_"Coprocessor",
	base_price = 100,
	inventory = {x = 1, y = 1, image = "addons/coprocessor/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[By speeding up your computations, this chip helps you to excel in many activities.]],
	rotation_series = "addons/coprocessor",
},
----------------------------------------------------------------------

{
	id = "Pedometer",
	name =_"Pedometer",
	base_price = 100,
	inventory = {x = 1, y = 1, image = "addons/pedometer/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[A device that helps you to move dexterously by giving feedback on your foot movement.]],
	rotation_series = "addons/pedometer",
},
----------------------------------------------------------------------

{
	id = "Foot warmers",
	name =_"Foot Warmers",
	base_price = 100,
	inventory = {x = 2, y = 2, image = "addons/foot_warmers/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This pair of electric fuzzy foot warmers would make even a penguin warm and comfortable in any shoes, and help maintain a healthy body temperature, thus preventing colds and making you look cool. At least, that's what the advertisement says. And ads don't lie, do they?]],
	rotation_series = "addons/foot_warmers",
},
----------------------------------------------------------------------

{
	id = "Circuit jammer",
	name =_"Circuit Jammer",
	base_price = 100,
	inventory = {x = 1, y = 1, image = "addons/circuit_jammer/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[This item improves your melee weapon by blasting the enemies you hit with an electromagnetic pulse. The pulse is powerful enough to temporarily shut down the circuits of the attacked bot.]],
	rotation_series = "addons/circuit_jammer",
},
----------------------------------------------------------------------

{
	id = "Sensor disruptor",
	name =_"Sensor Disruptor",
	base_price = 100,
	inventory = {x = 1, y = 1, image = "addons/sensor_disruptor/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[When attached to a melee weapon, this item induces errors to the sensors of the bots you attack, causing them to slow down momentarily.]],
	rotation_series = "addons/sensor_disruptor",
},
----------------------------------------------------------------------

{
	id = "Headlamp",
	name =_"Headlamp",
	base_price = 100,
	inventory = {x = 2, y = 1, image = "addons/headlamp/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[When fastened to your helmet, this lamp allows you to see better in dark environments.]],
	rotation_series = "addons/headlamp",
},
----------------------------------------------------------------------

{
	id = "Brain stimulator",
	name =_"Brain Stimulator",
	base_price = 100,
	inventory = {x = 2, y = 2, image = "addons/brain_stimulator/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[A chip that allows faster learning by connecting directly to the brain via a neural interface (colloquially referred to as a 'weird swim cap with little thingies on it') and providing additional feedback on various actions.]],
	rotation_series = "addons/brain_stimulator",
},
----------------------------------------------------------------------

----------------------------------------------------------------------
----    [Droid & NPC Weapons]                                     ----
----------------------------------------------------------------------

{
	id = "NPC Hand to hand weapon",
	name =_"NPC Hand to Hand Weapon",
	slot = "weapon",
	weapon = {
		damage = "3:8",
		attack_time = 0.450000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "35:45",
	base_price = 350,
	inventory = {x = 2, y = 2, image = "weapons/bot_melee.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[Bot use only]],
	rotation_series = "weapons/laser_sword_yellow",
	tux_part = "iso_sword",
},
----------------------------------------------------------------------

{
	id = "Droid 123 Weak Robotic Arm",
	name =_"Droid 123 Weak Robotic Arm",
	slot = "weapon",
	weapon = {
		damage = "0:3",
		attack_time = 0.950000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "20:30",
	base_price = 120,
	inventory = {x = 2, y = 2, image = "weapons/bot_melee.png" },
	drop = {sound = "Item_Drop_Sound_0.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "NONE_AVAILABLE_YET",
	tux_part = "iso_sword",
},
----------------------------------------------------------------------

{
	id = "Droid 139 Plasma Trash Vaporiser",
	name =_"Droid 139 Plasma Trash Vaporiser",
	slot = "weapon",
	weapon = {
		damage = "2:4",
		attack_time = 0.350000,
		reloading_time = 6.6500000,
		melee = false,
		bullet = {type = "plasma_white", speed = 12.000000, lifetime = 2.000000},
		ammunition = {id = "Plasma energy container", clip = 3},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "10:20",
	base_price = 40,
	inventory = {x = 2, y = 2, image = "weapons/bot_ranged.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "NONE_AVAILABLE_YET",
	tux_part = "iso_gun1",
},
----------------------------------------------------------------------

{
	id = "Droid 247 Robotic Arm",
	name =_"Droid 247 Robotic Arm",
	slot = "weapon",
	weapon = {
		damage = "2:7",
		attack_time = 0.600000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "10:20",
	base_price = 120,
	inventory = {x = 2, y = 2, image = "weapons/bot_melee.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "weapons/laser_sword_yellow",
	tux_part = "iso_sword",
},
----------------------------------------------------------------------

{
	id = "Droid 249 Pulse Laser Welder",
	name =_"Droid 249 Pulse Laser Welder",
	slot = "weapon",
	weapon = {
		damage = "1:1",
		attack_time = 0.150000,
		reloading_time = 4.8500000,
		melee = false,
		bullet = {type = "half_pulse", speed = 60.000000, lifetime = 2.00000},
		ammunition = {id = "Laser power pack", clip = 15},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "10:20",
	base_price = 100,
	inventory = {x = 2, y = 2, image = "weapons/bot_ranged.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "NONE_AVAILABLE_YET",
	tux_part = "iso_gun1",
},
----------------------------------------------------------------------

{
	id = "Droid 296 Plasmabeam Cutter",
	name =_"Droid 296 Plasmabeam Cutter",
	slot = "weapon",
	weapon = {
		damage = "8:13",
		attack_time = 0.600000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "10:20",
	base_price = 120,
	inventory = {x = 2, y = 2, image = "weapons/bot_melee.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "weapons/laser_sword_yellow",
	tux_part = "iso_sword",
},
----------------------------------------------------------------------

{
	id = "Droid 302 Overcharged Barcode Reader",
	name =_"Droid 302 Overcharged Barcode Reader",
	slot = "weapon",
	weapon = {
		damage = "6:11",
		attack_time = 0.600000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "10:20",
	base_price = 120,
	inventory = {x = 2, y = 2, image = "weapons/bot_melee.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "weapons/laser_sword_yellow",
	tux_part = "iso_sword",
},
----------------------------------------------------------------------

{
	id = "Droid 329 Dual Overcharged Barcode Reader",
	name =_"Droid 329 Dual Overcharged Barcode Reader",
	slot = "weapon",
	weapon = {
		damage = "8:13",
		attack_time = 0.600000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "10:20",
	base_price = 120,
	inventory = {x = 2, y = 2, image = "weapons/bot_melee.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "weapons/laser_sword_yellow",
	tux_part = "iso_sword",
},
----------------------------------------------------------------------

{
	id = "Droid 420 Laser Scalpel",
	name =_"Droid 420 Laser Scalpel",
	slot = "weapon",
	weapon = {
		damage = "10:15",
		attack_time = 0.600000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "10:20",
	base_price = 120,
	inventory = {x = 2, y = 2, image = "weapons/bot_melee.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "weapons/laser_sword_yellow",
	tux_part = "iso_sword",
},
----------------------------------------------------------------------

{
	id = "Droid 476 Small Laser",
	name =_"Droid 476 Small Laser",
	slot = "weapon",
	weapon = {
		damage = "3:6",
		attack_time = 1.200000,
		reloading_time = 1.200000,
		melee = false,
		bullet = {type = "single", speed = 52.000000, lifetime = -1.000000},
		ammunition = {id = "Laser power pack", clip = 5},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "10:20",
	base_price = 250,
	inventory = {x = 2, y = 2, image = "weapons/bot_ranged.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "NONE_AVAILABLE_YET",
	tux_part = "iso_gun1",
},
----------------------------------------------------------------------

{
	id = "Droid 493 Power Hammer",
	name =_"Droid 493 Power Hammer",
	slot = "weapon",
	weapon = {
		damage = "12:17",
		attack_time = 6.00000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "10:20",
	base_price = 120,
	inventory = {x = 2, y = 2, image = "weapons/bot_melee.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "weapons/laser_sword_yellow",
	tux_part = "iso_sword",
},
----------------------------------------------------------------------

{
	id = "Droid 516 Robotic Fist",
	name =_"Droid 516 Robotic Fist",
	slot = "weapon",
	weapon = {
		damage = "14:19",
		attack_time = 0.600000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "10:20",
	base_price = 120,
	inventory = {x = 2, y = 2, image = "weapons/bot_melee.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "weapons/laser_sword_yellow",
	tux_part = "iso_sword",
},
----------------------------------------------------------------------

{
	id = "Droid 543 Tree Harvester",
	name =_"Droid 543 Tree Harvester",
	slot = "weapon",
	weapon = {
		damage = "8:13",
		attack_time = 0.100000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "10:20",
	base_price = 120,
	inventory = {x = 2, y = 2, image = "weapons/bot_melee.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "weapons/laser_sword_yellow",
	tux_part = "iso_sword",
},
----------------------------------------------------------------------

{
	id = "Droid 571 Robotic Fist",
	name =_"Droid 571 Robotic Fist",
	slot = "weapon",
	weapon = {
		damage = "16:21",
		attack_time = 0.600000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "10:20",
	base_price = 120,
	inventory = {x = 2, y = 2, image = "weapons/bot_melee.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "weapons/laser_sword_yellow",
	tux_part = "iso_sword",
},
----------------------------------------------------------------------

{
	id = "Droid 598 Robotic Fist",
	name =_"Droid 598 Robotic Fist",
	slot = "weapon",
	weapon = {
		damage = "18:23",
		attack_time = 0.600000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	durability = "10:20",
	base_price = 120,
	inventory = {x = 2, y = 2, image = "weapons/bot_melee.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "weapons/laser_sword_yellow",
	tux_part = "iso_sword",
},
----------------------------------------------------------------------

{
	id = "Droid 7xx Tux Seeking Missiles",
	name =_"Droid 7xx Tux Seeking Missiles",
	slot = "weapon",
	weapon = {
		damage = "6:24",
		attack_time = 1.200000,
		reloading_time = 0.800000,
		melee = false,
		bullet = {type = "single", speed = 16.000000, lifetime = -1.000000},
		ammunition = {id = "Laser power pack", clip = 30},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "10:20",
	base_price = 250,
	inventory = {x = 2, y = 2, image = "weapons/bot_ranged.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "NONE_AVAILABLE_YET",
	tux_part = "iso_gun1",
},
----------------------------------------------------------------------

{
	id = "Droid Advanced Twin Laser",
	name =_"Droid Advanced Twin Laser",
	slot = "weapon",
	weapon = {
		damage = "10:22",
		attack_time = 1.400000,
		reloading_time = 2.600000,
		melee = false,
		bullet = {type = "military", speed = 60.000000, lifetime = -1.000000},
		ammunition = {id = "Laser power pack", clip = 30},
		two_hand = true,
		motion_class = "2hranged",
	},
	requirements = {strength = 30, dexterity = 40},
	durability = "10:20",
	base_price = 800,
	inventory = {x = 2, y = 2, image = "weapons/bot_ranged.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "weapons/laser_pulse_rifle",
	tux_part = "iso_gun1",
},
----------------------------------------------------------------------

{
	id = "Droid 883 Exterminator",
	name =_"Droid 883 Exterminator",
	slot = "weapon",
	weapon = {
		damage = "4:8",
		attack_time = 1.00000,
		reloading_time = 3.000000,
		melee = false,
		bullet = {type = "exterminator", speed = 35.000000, lifetime = -1.000000},
		ammunition = {id = "2 mm Exterminator Ammunition", clip = 2},
		two_hand = true,
		motion_class = "2hranged",
	},
	requirements = {strength = 20, dexterity = 45},
	durability = "10:20",
	base_price = 1001,
	inventory = {x = 2, y = 2, image = "weapons/bot_ranged.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[Droid weaponry]],
	rotation_series = "weapons/exterminator_simple",
	tux_part = "iso_gun1",
},
----------------------------------------------------------------------

{
	id = "Autogun Laser Pistol",
	name =_"Autogun Laser Pistol",
	slot = "weapon",
	weapon = {
		damage = "3:9",
		attack_time = 1.100000,
		reloading_time = 0.000000,
		reloading_sound = "effects/item_sounds/Item_Range_Weapon_Put_Sound_0.ogg",
		melee = false,
		bullet = {type = "laser_rifle", speed = 50.000000, lifetime = -1.000000},
		ammunition = {id = "Laser power pack", clip = 1},
		motion_class = "1hranged",
	},
	durability = "100:110",
	base_price = 500,
	inventory = {x = 1, y = 1, image = "weapons/bot_ranged.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[This is the laser weapon of the autogun. If you see this item whilst normal gameplay, please make a bugreport.]],
	rotation_series = "weapons/laser_pistol",
	tux_part = "iso_laser_pistol",
},
----------------------------------------------------------------------

----------------------------------------------------------------------
----    [Secret or cheat items]                                   ----
----------------------------------------------------------------------

{
	id = "PC LOAD LETTER",
	name =_"PC LOAD LETTER",
	base_price = 0,
	inventory = {x = 1, y = 1, image = "stock_certificate/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[An envelop saying 'PC LOAD LETTERS'. I have no idea what that means...]],
	rotation_series = "stock_certificate",
},
----------------------------------------------------------------------

{
	id = "Arcane Lore",
	name =_"Arcane Lore",
	base_price = 0,
	inventory = {x = 1, y = 1, image = "script/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_4.ogg"},
	description =_[[I've bought an anti-hack software, so I could try to hack it! ...But what, exactly, is the 'Arcane Lore'?]],
	rotation_series = "script",
},
----------------------------------------------------------------------

{
	id = "PGP key",
	name =_"PGP key",
	base_price = 0,
	inventory = {x = 2, y = 2, image = "hacker_wristband/inv_image.png" },
	drop = {sound = "Item_Drop_Sound_0.ogg"},
	description =_[[It won't open your house, but it can unlock important encrypted archives.]],
	rotation_series = "hacker_wristband",-- TODO: Image is temporary
},
----------------------------------------------------------------------

{
	id = "Cheat Gun",
	name =_"Cheat Gun",
	slot = "weapon",
	weapon = {
		damage = "9999:9999",
		attack_time = 0.100000,
		reloading_time = 0.000000,
		melee = false,
		bullet = {type = "plasma_white", speed = 200.000000, lifetime = -1.000000},
		two_hand = true,
		motion_class = "2hranged",
	},
	durability = "16000:16001",
	base_price = 10000,
	inventory = {x = 2, y = 3, image = "weapons/plasma_gun/inv_image2.png" },
	drop = {sound = "Item_Range_Weapon_Put_Sound_0.ogg"},
	description =_[[This item is used by testers. If you find it ingame without using a cheat, please report it as a bug.]],
	rotation_series = "weapons/plasma_gun",
	tux_part = "iso_gun1",
},

----------------------------------------------------------------------
---
---             Tutorial
--- (Items to be used in the tutorial only!)
----------------------------------------------------------------------


{
	id = "Small Tutorial Axe",
	name =_"Small Tutorial Axe",
	slot = "weapon",
	weapon = {
		damage = "2:6",
		attack_time = 0.600000,
		reloading_time = 0.000000,
		melee = true,
		motion_class = "1hmelee",
	},
	requirements = {strength = 14, dexterity = 15},
	durability = "40:60",
	base_price = 80,
	inventory = {x = 2, y = 3, image = "weapons/small_axe/inv_image_tutorial.png" },
	drop = {sound = "drop_sword_sound.ogg"},
	description =_[[While this axe was made for splitting wood, with some luck it can damage vital parts of a droid as well.
Sell me!
Click the red button with the cross on it when you are done.]],
	rotation_series = "weapons/small_axe",
	tux_part = "iso_small_axe",
},

{
	id = "Bottled Tutorial ice",
	name =_"Bottled Tutorial Ice",
	right_use = {tooltip = _"Cooling aid"},
	base_price = 15,
	inventory = {x = 1, y = 1,stackable = true, image = "pills_potions/force_capsule/inv_image_small_tutorial.png" },
	drop = {sound = "drop_potion_sound.ogg"},
	description =_[[This bottle is filled with ice. It can keep you cool during a warm summer day.
Buy me!
Click the red button with the cross on it when you are done.]],
	rotation_series = "pills_potions/force_capsule",
}

}
