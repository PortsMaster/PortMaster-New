# mcl_armor

This mod implements the ability of registering armors.

## Registering an Armor Set

The `mcl_armor.register_set()` function aims to simplify the process of registering a full set of armor.

This function register four pieces of armor (head, torso, leggings, feets) based on a definition table:

```lua
mcl_armor.register_set({
	--name of the armor material (used for generating itemstrings)
	name = "dummy_armor",

	--localized description of each armor piece
	descriptions = {
		head = S("Dummy Cap"),
		torso = S("Dummy Tunic"),
		legs = S("Dummy Pants"),
		feet = S("Dummy Shoes"),
	},

	--The following MCL2 compatible legacy behavior is still supported, but
	--deprecated, because it interferes with proper localization
	--it is triggered when description is non nil
	--[[
	--description of the armor material
	--do NOT translate this string, it will be concatenated will each piece of armor's description and result will be automatically fetched from your mod's translation files
	description = "Dummy Armor",

	--overide description of each armor piece
	--do NOT localize this string
	descriptions = {
		head = "Cap",    --default: "Helmet"
		torso = "Tunic", --default: "Chestplate"
		legs = "Pants",  --default: "Leggings"
		feet = "Shoes",  --default: "Boots"
	},
	]]

	--this is used to calculate each armor piece durability with the minecraft algorithm
	--head durability = durability * 0.6857 + 1
	--torso durability = durability * 1.0 + 1
	--legs durability = durability * 0.9375 + 1
	--feet durability = durability * 0.8125 + 1
	durability = 80,

	--this is used then you need to specify the durability of each piece of armor
	--this field have the priority over the durability one
	--if the durability of some pieces of armor isn't specified in this field, the durability field will be used insteed
	durabilities = {
		head = 200,
		torso = 500,
		legs = 400,
		feet = 300,
	},

	--this define how good enchants you will get then enchanting one piece of the armor in an enchanting table
	--if set to zero or nil, the armor will not be enchantable
	enchantability = 15,

	--this define how much each piece of armor protect the player
	--these points will be shown in the HUD (chestplate bar above the health bar)
	points = {
		head = 1,
		torso = 3,
		legs = 2,
		feet = 1,
	},

	--this attribute reduce strong damage even more
	--See https://minecraft.fandom.com/wiki/Armor#Armor_toughness for more explanations
	--default: 0
	toughness = 2,

	--this field is used to specify some items groups that will be added to each piece of armor
	--please note that some groups do NOT need to be added by hand, because they are already handeled by the register function:
	--(armor, combat_armor, armor_<element>, combat_armor_<element>, mcl_armor_points, mcl_armor_toughness, mcl_armor_uses, enchantability)
	groups = {op_armor = 1},

	--specify textures that will be overlayed on the entity wearing the armor
	--these fields have default values and its recommanded to keep the code clean by just using the default name for your textures
	textures = {
		head = "dummy_texture.png",  --default: "<modname>_helmet_<material>.png"
		torso = "dummy_texture.png", --default: "<modname>_chestplate_<material>.png"
		legs = "dummy_texture.png",  --default: "<modname>_leggings_<material>.png"
		feet = "dummy_texture.png",  --default: "<modname>_boots_<material>.png"
	},
	--you can also define these fields as functions, that will be called each time the API function mcl_armor.update(obj) is called (every time you equip/unequip some armor piece, take damage, and more)
	--note that the enchanting overlay will not appear unless you implement it in the function
	--this allow to make armors where the textures change whitout needing to register many other armors with different textures
	textures = {
		head = function(obj, itemstack)
			if mcl_enchanting.is_enchanted(itemstack) then
				return "dummy_texture.png^"..mcl_enchanting.overlay
			else
				return "dummy_texture.png"
			end
		end,
	},

	--inventory textures aren't definable using a table similar to textures or previews
	--you are forced to use the default texture names which are:
	--head: "<modname>_inv_helmet_<material>.png
	--torso: "<modname>_inv_chestplate_<material>.png
	--legs: "<modname>_inv_leggings_<material>.png
	--feet: "<modname>_inv_boots_<material>.png

	--this callback table allow you to define functions that will be called each time an entity equip an armor piece or the mcl_armor.on_equip() function is called
	--the functions accept two arguments: obj and itemstack
	on_equip_callbacks = {
		head = function(obj, itemstack)
			--do stuff
		end,
	},

	--this callback table allow you to define functions that will be called each time an entity unequip an armor piece or the mcl_armor.on_unequip() function is called
	--the functions accept two arguments: obj and itemstack
	on_unequip_callbacks = {
		head = function(obj, itemstack)
			--do stuff
		end,
	},

	--this callback table allow you to define functions that will be called then an armor piece break
	--the functions accept one arguments: obj
	--the itemstack isn't sended due to how minetest handle items which have a zero durability
	on_break_callbacks = {
		head = function(obj)
			--do stuff
		end,
	},

	--this is used to generate automaticaly armor crafts based on each element type folowing the regular minecraft pattern
	--if set to nil no craft will be added
	craft_material = "mcl_mobitems:leather",

	--this is used to generate cooking crafts for each piece of armor
	--if set to nil no craft will be added
	cook_material = "mcl_core:gold_nugget", --cooking any piece of this armor will output a gold nugged

	--this is used for allowing each piece of the armor to be repaired by using an anvil with repair_material as aditionnal material
	--it basicaly set the _repair_material item field of each piece of the armor
	--if set to nil no repair material will be added
	repair_material = "mcl_core:iron_ingot",
})
```

## Creating an Armor Piece

If you don't want to register a full set of armor, then you will need to manually register your own single item.

```lua
minetest.register_tool("dummy_mod:random_armor", {
	description = S("Random Armor"),

	--these two item fields are used for ingame documentation
	--the mcl_armor.longdesc and mcl_armor.usage vars contains the basic usage and purpose of a piece of armor
	--these vars may not be enough for that you want to do, so you may add some extra informations like that:
	--_doc_items_longdesc = mcl_armor.longdesc.." "..S("Some extra informations.")
	_doc_items_longdesc = mcl_armor.longdesc,
	_doc_items_usagehelp = mcl_armor.usage,

	--this field is similar to any item definition in minetest
	--it just set the image shown then the armor is dropped as an item or inside an inventory
	inventory_image = "mcl_armor_inv_elytra.png",

	--this field is used by minetest internally and also by some helper functions
	--in order for the tool to be shown is the right creative inventory tab, the right groups should be added
	--"mcl_armor_uses" is required to give your armor a durability
	--in that case, the armor can be worn by 10 points before breaking
	--if you want the armor to be enchantable, you should also add the "enchantability" group, with the highest number the better enchants you can apply
	groups = {armor = 1, non_combat_armor = 1, armor_torso = 1, non_combat_torso = 1, mcl_armor_uses = 10},

	--this table is used by minetest for seraching item specific sounds
	--the _mcl_armor_equip and _mcl_armor_unequip are used by the armor implementation to play sounds on equip and unequip
	--note that you don't need to provide any file extention
	sounds = {
		_mcl_armor_equip = "mcl_armor_equip_leather",
		_mcl_armor_unequip = "mcl_armor_unequip_leather",
	},

	--these fields should be initialised like that in most cases
	--mcl_armor.equip_on_use is a function that try to equip the piece of armor you have in hand inside the right armor slot if the slot is empty
	on_place = mcl_armor.equip_on_use,
	on_secondary_use = mcl_armor.equip_on_use,

	--this field define that the tool is ACTUALLY an armor piece and in which armor slot you can put it
	--it should be set to "head", "torso", "legs" or "feet"
	_mcl_armor_element = "torso",


	--this field is used to provide the texture that will be overlayed on the object (player or mob) skin
	--this field can be a texture name or a function that will be called each time the mcl_armor.update(obj) function is called
	--see the mcl_armor.register_set() documentation for more explanations
	_mcl_armor_texture = "mcl_armor_elytra.png"

	--callbacks
	--see the mcl_armor.register_set() documentation for more explanations

	_on_equip = function(obj, itemstack)
	end,
	_on_unequip = function(obj, itemstack)
	end,
	_on_break = function(obj)
	end,
})
```

## Interacting with Armor of an Entity

Mods may want to interact with armor of an entity.

Most global functions not described here may not be stable or may be for internal use only.

You can equip a piece of armor on an entity inside a mod by using `mcl_armor.equip()`.

```lua
--itemstack: an itemstack containing the armor piece to equip
--obj: the entity you want to equip the armor on
--swap: boolean, force equiping the armor piece, even if the entity already have one of the same type
mcl_armor.equip(itemstack, obj, swap)
```

You can update the entity apparence by using `mcl_armor.update()`.

This function put the armor overlay on the object's base texture.
If the object is player it will update his displayed armor points count in HUD.

This function will work both on players and mobs.

```lua
--obj: the entity you want the apparence to be updated
mcl_armor.update(obj)
```

## Handling Enchantments

Armors can be enchanted in most cases.

The enchanting part of MineClone2 is separated from the armor part, but closely linked.

Existing armor enchantments in Minecraft improve most of the time how the armor protect the entity from damage.

The `mcl_armor.register_protection_enchantment()` function aims to simplificate the creation of such enchants.

```lua
mcl_armor.register_protection_enchantment({
	--this field is the id that will be used for registering enchanted book and store the enchant inside armor metadata.
	--(his internal name)
	id = "magic_protection",

	--visible name of the enchant
	--this field is used as the name of registered enchanted book and inside armor tooltip
	--translation should be added
	name = S("Magic Protection"),

	--this field is used to know that the enchant currently do
	--translation should be added
	description = S("Reduces magic damage."),

	--how many levels can the enchant have
	--ex: 4 => I, II, III, IV
	--default: 4
	max_level = 4,

	--which enchants this enchant will not be compatible with
	--each of these values is a enchant id
	incompatible = {blast_protection = true, fire_protection = true, projectile_protection = true},

	--how much will the enchant consume from the enchantability group of the armor item
	--default: 5
	weight = 5,

	--false => the enchant can be obtained in an enchanting table
	--true => the enchant isn't obtainable in the enchanting table
	--is true, you will probably need to implement some ways to obtain it
	--even it the field is named "treasure", it will be no way to find it
	--default: false
	treasure = false,

	--how much will damage be reduced
	--see Minecraft Wiki for more informations
	--https://minecraft.gamepedia.com/Armor#Damage_protection
	--https://minecraft.gamepedia.com/Armor#Enchantments
	factor = 1,

	--restrict damage to one type
	--allow the enchant to only protect of one type of damage
	damage_type = "magic",

	--restrict damage to one category
	--allow to protect from many type of damage at once
	--this is much less specific than damage_type and also much more customisable
	--the "is_magic" flag is used in the "magic", "dragon_breath", "wither_skull" and "thorns" damage types
	--you can checkout the mcl_damage source code for a list of availlable damage types and associated flags
	--but be warned that mods can register additionnal damage types
	damage_flag = "is_magic",
})
```
