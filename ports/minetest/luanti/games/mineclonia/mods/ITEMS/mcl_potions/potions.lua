local S = core.get_translator(core.get_current_modname())
local D = mcl_util.get_dynamic_translator()

mcl_potions.registered_potions = {}
-- shorthand
local registered_potions = mcl_potions.registered_potions

local function potion_image(colorstring)
	return "mcl_potions_potion_overlay.png^[multiply:"..colorstring.."^mcl_potions_potion_bottle.png"
end

local how_to_drink = S("Use the “Place” key to drink it.")
local potion_intro = S("Drinking a potion gives you a particular effect or set of effects.")


-- ██████╗░███████╗░██████╗░██╗░██████╗████████╗███████╗██████╗░
-- ██╔══██╗██╔════╝██╔════╝░██║██╔════╝╚══██╔══╝██╔════╝██╔══██╗
-- ██████╔╝█████╗░░██║░░██╗░██║╚█████╗░░░░██║░░░█████╗░░██████╔╝
-- ██╔══██╗██╔══╝░░██║░░╚██╗██║░╚═══██╗░░░██║░░░██╔══╝░░██╔══██╗
-- ██║░░██║███████╗╚██████╔╝██║██████╔╝░░░██║░░░███████╗██║░░██║
-- ╚═╝░░╚═╝╚══════╝░╚═════╝░╚═╝╚═════╝░░░░╚═╝░░░╚══════╝╚═╝░░╚═╝
--
-- ██████╗░░█████╗░████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- ██████╔╝██║░░██║░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██╔═══╝░██║░░██║░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██║░░░░░╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░

local function generate_get_all_virtual_items_func(itemname, pdef, nocreative)
	return function()
		local category = nocreative and "nici" or "brew"
		local list = {}
		if pdef.has_potent then
			local stack = ItemStack(itemname)
			local potency = pdef._default_potent_level - 1
			stack:get_meta():set_int("mcl_potions:potion_potent", potency)
			tt.reload_itemstack_description(stack)
			table.insert(list, stack:to_string())
		end
		if pdef.has_plus then
			local stack = ItemStack(itemname)
			local extend = pdef._default_extend_level
			stack:get_meta():set_int("mcl_potions:potion_plus", extend)
			tt.reload_itemstack_description(stack)
			table.insert(list, stack:to_string())
		end

		return {[category] = list}
	end
end

function mcl_potions.consume_potion (mob, id, potency, plus)
	local def = registered_potions[id]
	local ef_level, dur
	if not def then
	return
	end
	for name, details in pairs (def._effect_list) do
	ef_level = mcl_potions.level_from_details (details, potency)
	dur = mcl_potions.duration_from_details (details, potency,
						 plus)
	mcl_potions.give_effect_by_level (name, mob, ef_level, dur)
	end
	if def.custom_effect then
	def.custom_effect (mob, potency + 1, plus)
	end
end

-- API - registers a potion
-- required parameters in def:
-- name - string - potion name in code
-- optional parameters in def:
-- desc_whole - translated string - overrides entire potion name, including the word "Potion"
-- desc_prefix - translated string - part of visible potion name, comes before the word "Potion"
-- desc_suffix - translated string - part of visible potion name, comes after the word "Potion"
-- _tt - translated string - custom tooltip text
-- _dynamic_tt - function(level) - returns custom tooltip text dependent on potion level
-- _longdesc - translated string - text for in-game documentation
-- stack_max - int - max stack size - defaults to 1
-- image - string - name of a custom texture of the potion icon
-- color - string - colorstring for potion icon when image is not defined - defaults to #0000FF
-- groups - table - item groups definition for the regular potion, not splash or lingering -
--   - must contain _mcl_potion=1 for tooltip to include dynamic_tt and effects
--   - defaults to {brewitem=1, food=3, can_eat_when_full=1, _mcl_potion=1}
-- nocreative - bool - adds a not_in_creative_inventory=1 group - defaults to false
-- _effect_list - table - all the effects dealt by the potion in the format of tables
-- -- the name of each sub-table should be a name of a registered effect, and fields can be the following:
-- -- -- uses_level - bool - whether the level of the potion affects the level of the effect -
-- -- --   - defaults to the uses_factor field of the effect definition
-- -- -- level - int - used as the effect level if uses_level is false and for lvl1 potions - defaults to 1
-- -- -- level_scaling - int - used as the number of effect levels added per potion level - defaults to 1 -
-- -- --   - this has no effect if uses_level is false
-- -- -- dur - float - duration of the effect in seconds - defaults to mcl_potions.DURATION
-- -- -- dur_variable - bool - whether variants of the potion should have the length of this effect changed -
-- -- --   - defaults to true
-- -- --   - if at least one effect has this set to true, the potion has a "plus" variant
-- -- -- potent_factor - int - factor which raised to the power of the effect level provides a value by which to divide the duration of a potent effect; defaults to POTENT_FACTOR
-- uses_level - bool - whether the potion should come at different levels -
--   - defaults to true if uses_level is true for at least one effect, else false
-- drinkable - bool - defaults to true
-- vanishing - bool - if drunk, vanish instead of restoring a glass bottle to inventory
-- has_splash - bool - defaults to true
-- has_lingering - bool - defaults to true
-- has_arrow - bool - defaults to false
-- has_potent - bool - whether there is a potent (e.g. II) variant - defaults to the value of uses_level
-- default_potent_level - int - potion level used for the default potent variant - defaults to 2
-- default_extend_level - int - extention level (amount of +) used for the default extended variant - defaults to 1
-- custom_on_use - function(user, level) - called when the potion is drunk, returns true on success
-- custom_effect - function(object, level, plus) - called when the potion effects are applied, returns true on success
-- custom_splash_effect - function(pos, level) - called when the splash potion explodes, returns true on success
function mcl_potions.register_potion(def)
	local modname = core.get_current_modname()
	local name = def.name
	assert(name ~= nil, "Unable to register potion: name is nil")
	assert(type(name) == "string", "Unable to register potion: name is not a string")
	local pdef = {}
	if def.desc_whole then
		pdef.description = def.desc_whole
	elseif def.desc_prefix and def.desc_suffix then
		pdef.description = D(def.desc_prefix .. " Potion " .. def.desc_suffix)
	elseif def.desc_prefix then
		pdef.description = D(def.desc_prefix .. " Potion")
	elseif def.desc_suffix then
		pdef.description = D("Potion " .. def.desc_suffix)
	else
		pdef.description = S("Strange Potion")
	end
	pdef._tt_help = def._tt
	pdef._dynamic_tt = def._dynamic_tt
	local potion_longdesc = def._longdesc
	if def._effect_list then
		potion_longdesc = potion_intro .. "\n" .. def._longdesc
	end
	pdef._doc_items_longdesc = potion_longdesc
	if def.drinkable ~= false then
		pdef._doc_items_usagehelp = how_to_drink
	end
	pdef.stack_max = def.stack_max or 1
	local color = def.color or "#FF00FF"
	pdef.inventory_image = def.image or potion_image(color)
	pdef.wield_image = pdef.inventory_image
	pdef.groups = def.groups or {brewitem=1, food=3, eatable=0, can_eat_when_full=1,
					 _mcl_potion=1, potion = 1, }
	if def.nocreative then pdef.groups.not_in_creative_inventory = 1 end

	pdef._effect_list = {}
	local effect
	local uses_level = false
	local has_plus = false
	if def._effect_list then
		for name, details in pairs(def._effect_list) do
			effect = mcl_potions.registered_effects[name]
			assert(effect, "Unable to register potion: effect not registered")
			local ulvl
			if details.uses_level ~= nil then ulvl = details.uses_level
			else ulvl = effect.uses_factor end
			if ulvl then uses_level = true end
			local durvar = true
			if details.dur_variable ~= nil then durvar = details.dur_variable end
			if durvar then has_plus = true end
			pdef._effect_list[name] = {
				uses_level = ulvl,
				level = details.level or 1,
				level_scaling = details.level_scaling or 1,
				dur = details.dur or mcl_potions.DURATION,
				dur_variable = durvar,
				potent_factor = details.potent_factor,
			}
		end
	end
	if def.uses_level ~= nil then uses_level = def.uses_level end
	pdef.uses_level = uses_level
	if def.has_potent ~= nil then pdef.has_potent = def.has_potent
	else pdef.has_potent = uses_level end
	pdef._default_potent_level = def.default_potent_level or 2
	pdef._default_extend_level = def.default_extend_level or 1
	pdef.has_plus = has_plus
	if def.drinkable ~= false then
		pdef._mcl_eat_effect = function (itemstack, player)
			local potency = itemstack:get_meta():get_int("mcl_potions:potion_potent")
			local plus = itemstack:get_meta():get_int("mcl_potions:potion_plus")
			local ef_level
			local dur
			for name, details in pairs(pdef._effect_list) do
				ef_level = mcl_potions.level_from_details (details, potency)
				dur = mcl_potions.duration_from_details (details, potency,
									plus)
				mcl_potions.give_effect_by_level(name, player, ef_level, dur)
			end

			local on_use = def.custom_on_use
			if on_use then on_use(player, potency+1) end

			local custom_effect = def.custom_effect
			if custom_effect then custom_effect(player, potency+1, plus, player) end
		end
		pdef._mcl_eat_replace_with = def.vanishing and "" or "mcl_potions:glass_bottle"
	end
	pdef._mcl_filter_description = mcl_potions.filter_potion_description

	local internal_def = table.copy(pdef)
	local itemname = modname .. ":" .. name

	pdef._get_all_virtual_items = generate_get_all_virtual_items_func(itemname, pdef, def.nocreative)
	core.register_craftitem (":" .. itemname, pdef)

	if def.has_splash or def.has_splash == nil then
		local splash_desc = S("Splash @1", pdef.description)
		local sdef = {}
		sdef._id_override = def._id_override
		sdef._tt = def._tt
		sdef._dynamic_tt = def._dynamic_tt
		sdef._longdesc = def._longdesc
		sdef.nocreative = def.nocreative
		sdef.stack_max = pdef.stack_max
		sdef._effect_list = pdef._effect_list
		sdef.uses_level = uses_level
		sdef.has_potent = pdef.has_potent
		sdef.has_plus = has_plus
		sdef._default_potent_level = pdef._default_potent_level
		sdef._default_extend_level = pdef._default_extend_level
		sdef.custom_effect = def.custom_effect
		sdef.on_splash = def.custom_splash_effect
		sdef.base_potion = itemname
		sdef._get_all_virtual_items = generate_get_all_virtual_items_func("mcl_potions:" .. name .. "_splash", sdef, def.nocreative)
		if not def._effect_list then sdef.instant = true end
		mcl_potions.register_splash(name, splash_desc, color, sdef)
		internal_def.has_splash = true
	end

	if def.has_lingering or def.has_lingering == nil then
		local ling_desc = S("Lingering @1", pdef.description)
		local ldef = {}
		ldef._id_override = def._id_override
		ldef._tt = def._tt
		ldef._dynamic_tt = def._dynamic_tt
		ldef._longdesc = def._longdesc
		ldef.nocreative = def.nocreative
		ldef.stack_max = pdef.stack_max
		ldef._effect_list = pdef._effect_list
		ldef.uses_level = uses_level
		ldef.has_potent = pdef.has_potent
		ldef.has_plus = has_plus
		ldef._default_potent_level = pdef._default_potent_level
		ldef._default_extend_level = pdef._default_extend_level
		ldef.custom_effect = def.custom_effect
		ldef.on_splash = def.custom_splash_effect
		ldef.while_lingering = def.custom_linger_effect
		ldef.base_potion = itemname
		ldef._get_all_virtual_items = generate_get_all_virtual_items_func("mcl_potions:" .. name .. "_lingering", ldef, def.nocreative)
		if not def._effect_list then ldef.instant = true end
		mcl_potions.register_lingering(name, ling_desc, color, ldef)
		internal_def.has_lingering = true
	end

	if def.has_arrow then
		local arr_desc
		if def.desc_prefix and def.desc_suffix then
			arr_desc = D(def.desc_prefix .. " Arrow " .. def.desc_suffix)
		elseif def.desc_prefix then
			arr_desc = D(def.desc_prefix .. " Arrow")
		elseif def.desc_suffix then
			arr_desc = D("Arrow " .. def.desc_suffix)
		else
			arr_desc = S("Strange Tipped Arrow")
		end
		local adef = {}
		adef._id_override = def._id_override
		adef._tt = def._tt
		adef._dynamic_tt = def._dynamic_tt
		adef._longdesc = def._longdesc
		adef.nocreative = def.nocreative
		adef._effect_list = pdef._effect_list
		adef.uses_level = uses_level
		adef.has_potent = pdef.has_potent
		adef.has_plus = has_plus
		adef._default_potent_level = pdef._default_potent_level
		adef._default_extend_level = pdef._default_extend_level
		adef.custom_effect = def.custom_effect
		adef._get_all_virtual_items = generate_get_all_virtual_items_func("mcl_potions:" .. name .. "_arrow", adef, def.nocreative)
		if not def._effect_list then adef.instant = true end
		mcl_potions.register_arrow(name, arr_desc, color, adef)
		internal_def.has_arrow = true
	end
	internal_def.custom_effect = def.custom_effect
	mcl_potions.registered_potions[modname..":"..name] = internal_def
end

function mcl_potions.filter_potion_description (itemstack, orig_desc)
	local meta = itemstack:get_meta ()
	local potency = meta:get_int("mcl_potions:potion_potent")
	local plus = meta:get_int("mcl_potions:potion_plus")
	if potency > 0 then
	local sym_potency = mcl_util.to_roman(potency+1)
	orig_desc = orig_desc .. " ".. sym_potency
	end
	if plus > 0 then
	local sym_plus = " "
	local i = plus
	while i>0 do
		i = i - 1
		sym_plus = sym_plus .. "+"
	end
	orig_desc = orig_desc .. sym_plus
	end
	return orig_desc
end

-- ██████╗░░█████╗░████████╗██╗░█████╗░███╗░░██╗
-- ██╔══██╗██╔══██╗╚══██╔══╝██║██╔══██╗████╗░██║
-- ██████╔╝██║░░██║░░░██║░░░██║██║░░██║██╔██╗██║
-- ██╔═══╝░██║░░██║░░░██║░░░██║██║░░██║██║╚████║
-- ██║░░░░░╚█████╔╝░░░██║░░░██║╚█████╔╝██║░╚███║
-- ╚═╝░░░░░░╚════╝░░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝
--
-- ██████╗░███████╗███████╗██╗███╗░░██╗██╗████████╗██╗░█████╗░███╗░░██╗░██████╗
-- ██╔══██╗██╔════╝██╔════╝██║████╗░██║██║╚══██╔══╝██║██╔══██╗████╗░██║██╔════╝
-- ██║░░██║█████╗░░█████╗░░██║██╔██╗██║██║░░░██║░░░██║██║░░██║██╔██╗██║╚█████╗░
-- ██║░░██║██╔══╝░░██╔══╝░░██║██║╚████║██║░░░██║░░░██║██║░░██║██║╚████║░╚═══██╗
-- ██████╔╝███████╗██║░░░░░██║██║░╚███║██║░░░██║░░░██║╚█████╔╝██║░╚███║██████╔╝
-- ╚═════╝░╚══════╝╚═╝░░░░░╚═╝╚═╝░░╚══╝╚═╝░░░╚═╝░░░╚═╝░╚════╝░╚═╝░░╚══╝╚═════╝░


core.register_craftitem("mcl_potions:dragon_breath", {
	description = S("Dragon's Breath"),
	_doc_items_longdesc = S("This item is used in brewing and can be combined with splash potions to create lingering potions."),
	inventory_image = "mcl_potions_dragon_breath.png",
	groups = { brewitem = 1, bottle = 1, rarity = 1 },
})

mcl_potions.register_potion({
	name = "awkward",
	desc_prefix = "Awkward",
	_tt = S("No effect"),
	_longdesc = S("Has an awkward taste and is used for brewing potions."),
	color = "#8091ff",
})

mcl_potions.register_potion({
	name = "mundane",
	desc_prefix = "Mundane",
	_tt = S("No effect"),
	_longdesc = S("Has a terrible taste and is not really useful for brewing potions."),
	color = "#8091ff",
})

mcl_potions.register_potion({
	name = "thick",
	desc_prefix = "Thick",
	_tt = S("No effect"),
	_longdesc = S("Has a bitter taste and is not really useful for brewing potions."),
	color = "#8091ff",
})

mcl_potions.register_potion({
	name = "healing",
	desc_suffix = "of Healing",
	_dynamic_tt = function(level)
		return S("+@1 HP", 4 * level)
	end,
	_longdesc = S("Instantly heals."),
	color = "#f6493a",
	uses_level = true,
	has_arrow = true,
	custom_effect = function(object, level, _, user)
		return mcl_potions.healing_func(object, 4 * level, user)
	end,
})

mcl_potions.register_potion({
	name = "harming",
	desc_suffix = "of Harming",
	_dynamic_tt = function(level)
		return S("-@1 HP", 6 * level)
	end,
	_longdesc = S("Instantly deals damage."),
	color = "#a07669",
	uses_level = true,
	has_arrow = true,
	custom_effect = function(object, level, _, user)
		return mcl_potions.healing_func(object, -6 * level, user)
	end,
})

mcl_potions.register_potion({
	name = "night_vision",
	desc_suffix = "of Night Vision",
	_tt = nil,
	_longdesc = S("Increases the perceived brightness of light under a dark sky."),
	color = "#c8f356",
	_effect_list = {
		night_vision = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "swiftness",
	desc_suffix = "of Swiftness",
	_tt = nil,
	_longdesc = S("Increases walking speed."),
	color = "#5ae9fe",
	_effect_list = {
		swiftness = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "slowness",
	desc_suffix = "of Slowness",
	_tt = nil,
	_longdesc = S("Decreases walking speed."),
	color = "#8bb3de",
	_effect_list = {
		slowness = {dur=mcl_potions.DURATION_INV,
			-- Slowness IV should last 20 seconds.
			potent_factor = math.pow (4.5, 1/3),
		},
	},
	default_potent_level = 4,
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "leaping",
	desc_suffix = "of Leaping",
	_tt = nil,
	_longdesc = S("Increases jump strength."),
	color = "#fafd8e",
	_effect_list = {
		leaping = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "withering",
	desc_suffix = "of Decay",
	_tt = nil,
	_longdesc = S("Applies the withering effect which deals damage at a regular interval and can kill."),
	color = "#6d5c50",
	_effect_list = {
		withering = {dur=mcl_potions.DURATION_POISON},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "poison",
	desc_suffix = "of Poison",
	_tt = nil,
	_longdesc = S("Applies the poison effect which deals damage at a regular interval."),
	color = "#86a25b",
	_effect_list = {
		poison = {dur=mcl_potions.DURATION_POISON},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "regeneration",
	desc_suffix = "of Regeneration",
	_tt = nil,
	_longdesc = S("Regenerates health over time."),
	color = "#cb54ba",
	_effect_list = {
		regeneration = {dur=mcl_potions.DURATION_POISON},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "invisibility",
	desc_suffix = "of Invisibility",
	_tt = nil,
	_longdesc = S("Grants invisibility."),
	color = "#f7fdfc",
	_effect_list = {
		invisibility = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "water_breathing",
	desc_suffix = "of Water Breathing",
	_tt = nil,
	_longdesc = S("Grants limitless breath underwater."),
	color = "#98dac1",
	_effect_list = {
		water_breathing = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "fire_resistance",
	desc_suffix = "of Fire Resistance",
	_tt = nil,
	_longdesc = S("Grants immunity to damage from heat sources like fire."),
	color = "#fd970e",
	_effect_list = {
		fire_resistance = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "strength",
	desc_suffix = "of Strength",
	_tt = nil,
	_longdesc = S("Increases attack power."),
	color = "#f8c800",
	_effect_list = {
		strength = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "weakness",
	desc_suffix = "of Weakness",
	_tt = nil,
	_longdesc = S("Decreases attack power."),
	color = "#4a4e49",
	_effect_list = {
		weakness = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "slow_falling",
	desc_suffix = "of Slow Falling",
	_tt = nil,
	_longdesc = S("Instead of falling, you descend gracefully."),
	color = "#eed1ba",
	_effect_list = {
		slow_falling = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "turtle_master",
	desc_suffix = "of the Turtle Master",
	_tt = nil,
	_longdesc = S("Decreases damage taken at the cost of speed."),
	color = "#8473dd",
	_effect_list = {
		resistance = {
			level = 3,
			dur = 20,
		},
		slowness = {
			level = 4,
			level_scaling = 2,
			dur = 20,
		},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "luck",
	desc_suffix = "of Luck",
	_tt = nil,
	_longdesc = S("Increases luck."),
	color = "#59c500",
	_effect_list = {
		luck = {},
	},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "bad_luck",
	desc_suffix = "of Bad Luck",
	_tt = nil,
	_longdesc = S("Decreases luck."),
	color = "#c9aa56",
	_effect_list = {
		bad_luck = {},
	},
	has_arrow = true,
	nocreative = true,
})

mcl_potions.register_potion({
	name = "ominous",
	desc_whole = "Ominous Bottle",
	groups = {brewitem=1, food=3, can_eat_when_full=1,
	_mcl_potion=1, potion = 1, rarity = 1},
	_tt = nil,
	_longdesc = S("Attracts danger."),
	image = "mcl_potions_ominous_potion.png",
	_effect_list = {
		bad_omen = {dur = 6000, dur_variable = false,},
	},
	has_splash = false,
	has_lingering = false,
	vanishing = true,
})

mcl_potions.register_potion({
	name = "infestation",
	desc_suffix = "of Infestation",
	_tt = nil,
	_longdesc = S("Causes 1-3 silverfish to spawn with a 5% chance when damaged. It not applies to silverfishes."),
	color = "#899b8a",
	_effect_list = {infested = {}},
	has_arrow = true
})

mcl_potions.register_potion({
	name = "oozing",
	desc_suffix = "of Oozing",
	_tt = nil,
	_longdesc = S("Causes 2 medium slimes to spawn on death. It not applies to slimes."),
	color = "#a5fda9",
	_effect_list = {oozing = {}},
	has_arrow = true
})

mcl_potions.register_potion({
	name = "weaving",
	desc_suffix = "of Weaving",
	_tt = nil,
	_longdesc = S("Causes 2-3 cobwebs to appear on death. Also increases walking speed when crossing cobwebs."),
	color = "#75675a",
	_effect_list = {weaving = {}},
	has_arrow = true,
})

mcl_potions.register_potion({
	name = "wind_charged",
	desc_suffix = "of Wind Charging",
	_tt = nil,
	_longdesc = S("Causes A wind burst on death."),
	color = "#bcc8ff",
	_effect_list = {wind_charged = {}},
	has_arrow = true,
})

-- COMPAT CODE
local function replace_legacy_potion(itemstack)
	local name = itemstack:get_name()
	local suffix = ""
	local bare_name = name:match("^(.+)_splash$")
	if bare_name then
		suffix = "_splash"
	else
		bare_name = name:match("^(.+)_lingering$")
		if bare_name then
			suffix = "_lingering"
		else
			bare_name = name:match("^(.+)_arrow$")
			if bare_name then
				suffix = "_arrow"
			else
				bare_name = name
			end
		end
	end
	local new_name = bare_name:match("^(.+)_plus$")
	local new_stack
	if new_name then
		new_stack = ItemStack(new_name..suffix)
		new_stack:get_meta():set_int("mcl_potions:potion_plus",
			registered_potions[new_name]._default_extend_level)
		new_stack:set_count(itemstack:get_count())
		tt.reload_itemstack_description(new_stack)
	end
	new_name = bare_name:match("^(.+)_2$")
	if new_name then
		new_stack = ItemStack(new_name..suffix)
		new_stack:get_meta():set_int("mcl_potions:potion_potent",
			registered_potions[new_name]._default_potent_level-1)
		new_stack:set_count(itemstack:get_count())
		tt.reload_itemstack_description(new_stack)
	end
	return new_stack
end
local compat = "mcl_potions:compat_potion"
local compat_arrow = "mcl_potions:compat_arrow"
local compat_def = {
	description = S("Unknown Potion") .. "\n" .. core.colorize("#ff0", S("Right-click to identify")),
	inventory_image = "mcl_potions_potion_overlay.png^[colorize:#00F:127^mcl_potions_potion_bottle.png^mcl_unknown.png",
	groups = {not_in_creative_inventory = 1},
	on_secondary_use = replace_legacy_potion,
	on_place = replace_legacy_potion,
}
local compat_arrow_def = {
	description = S("Unknown Tipped Arrow") .. "\n" .. core.colorize("#ff0", S("Right-click to identify")),
	inventory_image = "mcl_bows_arrow_inv.png^(mcl_potions_arrow_inv.png^[colorize:#FFF:100)^mcl_unknown.png",
	groups = {not_in_creative_inventory = 1},
	on_secondary_use = replace_legacy_potion,
	on_place = replace_legacy_potion,
}
core.register_craftitem(compat, table.copy(compat_def))
core.register_craftitem(compat_arrow, table.copy(compat_arrow_def))

local old_potions_plus = {
	"fire_resistance", "water_breathing", "invisibility", "regeneration", "poison",
	"withering", "leaping", "slowness", "swiftness", "night_vision"
}
local old_potions_2 = {
	"healing", "harming", "swiftness", "slowness", "leaping",
	"withering", "poison", "regeneration"
}

for _, name in pairs(old_potions_2) do
	core.register_craftitem("mcl_potions:" .. name .. "_2", table.copy(compat_def))
	core.register_craftitem("mcl_potions:" .. name .. "_2_splash", table.copy(compat_def))
	core.register_craftitem("mcl_potions:" .. name .. "_2_lingering", table.copy(compat_def))
	core.register_craftitem("mcl_potions:" .. name .. "_2_arrow", table.copy(compat_arrow_def))
end
for _, name in pairs(old_potions_plus) do
	core.register_craftitem("mcl_potions:" .. name .. "_plus", table.copy(compat_def))
	core.register_craftitem("mcl_potions:" .. name .. "_plus_splash", table.copy(compat_def))
	core.register_craftitem("mcl_potions:" .. name .. "_plus_lingering", table.copy(compat_def))
	core.register_craftitem("mcl_potions:" .. name .. "_plus_arrow", table.copy(compat_arrow_def))
end
