local S = minetest.get_translator(minetest.get_current_modname())
--local brewhelp = S("Try different combinations to create potions.")

local function potion_image(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return "mcl_potions_potion_overlay.png^[colorize:"..colorstring..":"..tostring(opacity).."^mcl_potions_potion_bottle.png"
end

local how_to_drink = S("Use the “Place” key to drink it.")
local potion_intro = S("Drinking a potion gives you a particular effect.")

local function time_string(dur)
	if not dur then
		return nil
	end
	return math.floor(dur/60)..string.format(":%02d",math.floor(dur % 60))
end
local function perc_string(num)

	local rem = math.floor((num-1.0)*100 + 0.1) % 5
	local out = math.floor((num-1.0)*100 + 0.1) - rem

	if (num - 1.0) < 0 then
		return out.."%"
	else
		return "+"..out.."%"
	end
end


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


function return_on_use(def, effect, dur)
	return function (itemstack, user, pointed_thing)
		if pointed_thing.type == "node" then
			local rc = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
			if rc then return rc end
		elseif pointed_thing.type == "object" then
			return itemstack
		end

		def.on_use(user, effect, dur)
		local old_name, old_count = itemstack:get_name(), itemstack:get_count()
		itemstack = minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
		if old_name ~= itemstack:get_name() or old_count ~= itemstack:get_count() then
			mcl_potions._use_potion(itemstack, user, def.color)
		end
		return itemstack
	end
end


local function register_potion(def)

	local dur = mcl_potions.DURATION

	if def.is_inv then
		dur = dur * mcl_potions.INV_FACTOR
	end
	if def.name == "poison" or def.name == "regeneration" or def.name == "withering" then
		dur = 45
	end

	local on_use = nil

	if def.on_use then
		on_use = return_on_use(def, def.effect, dur)
	end

	local function get_tt(tt, effect, dur)
		local _tt
		if effect and def.is_dur then
			_tt = perc_string(effect).." | "..time_string(dur)
			if def.name == "poison" or def.name == "regeneration" or def.name == "withering" then
				_tt = S("1 HP/@1s | @2", effect, time_string(dur))
			end
		elseif def.name == "healing" or def.name == "harming" then
				_tt = S("@1 HP", effect)
		else
			_tt = tt or time_string(dur) or S("No effect")
		end
		return _tt
	end

	local function get_splash_fun(effect, sp_dur)
		if def.is_dur then
			return function(player, redx) def.on_use(player, effect, sp_dur*redx) end
		elseif def.effect then
			return function(player, redx) def.on_use(player, effect*redx, sp_dur) end
		end
		-- covers case of no effect (water, awkward, mundane)
		return function() end
	end

	local function get_lingering_fun(effect, ling_dur)
		if def.is_dur then
			return function(player) def.on_use(player, effect, ling_dur) end
		elseif def.effect then
			return function(player) def.on_use(player, effect*0.5, ling_dur) end
		end
		-- covers case of no effect (water, awkward, mundane)
		return function() end
	end

	local function get_arrow_fun(effect, dur)
		if def.is_dur then
			return function(player) def.on_use(player, effect, dur) end
		elseif def.effect then
			return function(player) def.on_use(player, effect, dur) end
		end
		-- covers case of no effect (water, awkward, mundane)
		return function() end
	end

	local desc
	if not def.no_potion then
		if def.description_potion then
			desc = def.description_potion
		else
			desc = S("@1 Potion", def.description)
		end
	else
		desc = def.description
	end
	local potion_longdesc = def._longdesc
	if not def.no_effect then
		potion_longdesc = potion_intro .. "\n" .. def._longdesc
	end
	local potion_usagehelp
	local basic_potion_tt
	if def.name ~= "dragon_breath" then
		potion_usagehelp = how_to_drink
		basic_potion_tt = get_tt(def._tt, def.effect, dur)
	end

	minetest.register_craftitem("mcl_potions:"..def.name, {
		description = desc,
		_tt_help = basic_potion_tt,
		_doc_items_longdesc = potion_longdesc,
		_doc_items_usagehelp = potion_usagehelp,
		stack_max = def.stack_max or 1,
		inventory_image = def.image or potion_image(def.color),
		wield_image = def.image or potion_image(def.color),
		groups = def.groups or {brewitem=1, food=3, can_eat_when_full=1, potion = 1 },
		on_place = on_use,
		on_secondary_use = on_use,
	})

	-- Register Splash and Lingering
	local splash_dur = dur * mcl_potions.SPLASH_FACTOR
	local ling_dur = dur * mcl_potions.LINGERING_FACTOR

	local splash_def = {
		tt = get_tt(def._tt, def.effect, splash_dur),
		longdesc = def._longdesc,
		potion_fun = get_splash_fun(def.effect, splash_dur),
		no_effect = def.no_effect,
		instant = def.instant,
	}

	local ling_def
	if def.name == "healing" or def.name == "harming" then
		ling_def = {
			tt = get_tt(def._tt, def.effect*mcl_potions.LINGERING_FACTOR, ling_dur),
			longdesc = def._longdesc,
			potion_fun = get_lingering_fun(def.effect*mcl_potions.LINGERING_FACTOR, ling_dur),
			no_effect = def.no_effect,
			instant = def.instant,
		}
	else
		ling_def = {
			tt = get_tt(def._tt, def.effect, ling_dur),
			longdesc = def._longdesc,
			potion_fun = get_lingering_fun(def.effect, ling_dur),
			no_effect = def.no_effect,
			instant = def.instant,
		}
	end

	local arrow_def = {
		tt = get_tt(def._tt, def.effect, dur/8.),
		longdesc = def._longdesc,
		potion_fun = get_arrow_fun(def.effect, dur/8.),
		no_effect = def.no_effect,
		instant = def.instant,
	}

	if def.color and not def.no_throwable then
		local desc
		if def.description_splash then
			desc = def.description_splash
		else
			desc = S("Splash @1 Potion", def.description)
		end
		mcl_potions.register_splash(def.name, desc, def.color, splash_def)
		if def.description_lingering then
			desc = def.description_lingering
		else
			desc = S("Lingering @1 Potion", def.description)
		end
		mcl_potions.register_lingering(def.name, desc, def.color, ling_def)
		if not def.no_arrow then
			mcl_potions.register_arrow(def.name, S("Arrow of @1", def.description), def.color, arrow_def)
		end
	end

	if def.is_II then

		local desc_mod = S(" II")

		local effect_II
		if def.name == "healing" or def.name == "harming" then
			effect_II = def.effect*mcl_potions.II_FACTOR
		elseif def.name == "poison" or def.name == "regeneration" then
			effect_II = 1.2
		elseif def.name == "withering" then
			effect_II = 2
		else
			effect_II = def.effect^mcl_potions.II_FACTOR
		end

		local dur_2 = dur / mcl_potions.II_FACTOR
		if def.name == "poison" then dur_2 = dur_2 - 1 end

		if def.name == "slowness" then
			dur_2 = 20
			effect_II = 0.40
			desc_mod = S(" IV")
		end

		on_use = return_on_use(def, effect_II, dur_2)

		minetest.register_craftitem("mcl_potions:"..def.name.."_2", {
			description = S("@1 Potion@2", def.description, desc_mod),
			_tt_help = get_tt(def._tt_2, effect_II, dur_2),
			_doc_items_longdesc = potion_longdesc,
			_doc_items_usagehelp = potion_usagehelp,
			stack_max = def.stack_max or 1,
			inventory_image = def.image or potion_image(def.color),
			wield_image = def.image or potion_image(def.color),
			groups = def.groups or {brewitem=1, food=3, can_eat_when_full=1, potion = 2},
			on_place = on_use,
			on_secondary_use = on_use,
		})

		-- Register Splash and Lingering
		local splash_dur_2 = dur_2 * mcl_potions.SPLASH_FACTOR
		local ling_dur_2 = dur_2 * mcl_potions.LINGERING_FACTOR

		local splash_def_2
		if def.name == "healing" then
			splash_def_2 = {
				tt = get_tt(def._tt_2, 7, splash_dur_2),
				longdesc = def._longdesc,
				potion_fun = get_splash_fun(7, splash_dur_2),
				no_effect = def.no_effect,
				instant = def.instant,
			}
		else
			splash_def_2 = {
				tt = get_tt(def._tt_2, effect_II, splash_dur_2),
				longdesc = def._longdesc,
				potion_fun = get_splash_fun(effect_II, splash_dur_2),
				no_effect = def.no_effect,
				instant = def.instant,
			}
		end


		local ling_def_2
		if def.name == "healing" or def.name == "harming" then
			ling_def_2 = {
				tt = get_tt(def._tt_2, effect_II*mcl_potions.LINGERING_FACTOR, ling_dur_2),
				longdesc = def._longdesc,
				potion_fun = get_lingering_fun(effect_II*mcl_potions.LINGERING_FACTOR, ling_dur_2),
				no_effect = def.no_effect,
				instant = def.instant,
			}
		else
			ling_def_2 = {
				tt = get_tt(def._tt_2, effect_II, ling_dur_2),
				longdesc = def._longdesc,
				potion_fun = get_lingering_fun(effect_II, ling_dur_2),
				no_effect = def.no_effect,
				instant = def.instant,
			}
		end

		local arrow_def_2 = {
			tt = get_tt(def._tt_2, effect_II, dur_2/8.),
			longdesc = def._longdesc,
			potion_fun = get_arrow_fun(effect_II, dur_2/8.),
			no_effect = def.no_effect,
			instant = def.instant,
		}

		if def.color and not def.no_throwable then
			mcl_potions.register_splash(def.name.."_2", S("Splash @1@2 Potion", def.description, desc_mod), def.color, splash_def_2)
			mcl_potions.register_lingering(def.name.."_2", S("Lingering @1@2 Potion", def.description, desc_mod), def.color, ling_def_2)
			if not def.no_arrow then
				mcl_potions.register_arrow(def.name.."_2", S("Arrow of @1@2", def.description, desc_mod), def.color, arrow_def_2)
			end
		end

	end

	if def.is_plus then

		local dur_pl = dur * mcl_potions.PLUS_FACTOR
		if def.name == "poison" or def.name == "regeneration" or def.name == "withering" then
			dur_pl = 90
		end

		on_use = return_on_use(def, def.effect, dur_pl)

		minetest.register_craftitem("mcl_potions:"..def.name.."_plus", {
			description = S("@1 + Potion", def.description),
			_tt_help = get_tt(def._tt_plus, def.effect, dur_pl),
			_doc_items_longdesc = potion_longdesc,
			_doc_items_usagehelp = potion_usagehelp,
			stack_max = 1,
			inventory_image = def.image or potion_image(def.color),
			wield_image = def.image or potion_image(def.color),
			groups = def.groups or {brewitem=1, food=3, can_eat_when_full=1, potion = 3},
			on_place = on_use,
			on_secondary_use = on_use,
		})

		-- Register Splash
		local splash_dur_pl = dur_pl * mcl_potions.SPLASH_FACTOR
		local ling_dur_pl = dur_pl * mcl_potions.LINGERING_FACTOR

		local splash_def_pl = {
			tt = get_tt(def._tt_plus, def.effect, splash_dur_pl),
			longdesc = def._longdesc,
			potion_fun = get_splash_fun(def.effect, splash_dur_pl),
			no_effect = def.no_effect,
			instant = def.instant,
		}
		local ling_def_pl = {
			tt = get_tt(def._tt_plus, def.effect, ling_dur_pl),
			longdesc = def._longdesc,
			potion_fun = get_lingering_fun(def.effect, ling_dur_pl),
			no_effect = def.no_effect,
			instant = def.instant,
		}
		local arrow_def_pl = {
			tt = get_tt(def._tt_pl, def.effect, dur_pl/8.),
			longdesc = def._longdesc,
			potion_fun = get_arrow_fun(def.effect, dur_pl/8.),
			no_effect = def.no_effect,
			instant = def.instant,
		}
		if def.color and not def.no_throwable then
			mcl_potions.register_splash(def.name.."_plus", S("Splash @1 + Potion", def.description), def.color, splash_def_pl)
			mcl_potions.register_lingering(def.name.."_plus", S("Lingering @1 + Potion", def.description), def.color, ling_def_pl)
			if not def.no_arrow then
				mcl_potions.register_arrow(def.name.."_plus", S("Arrow of @1 +", def.description), def.color, arrow_def_pl)
			end
		end

	end

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


local awkward_def = {
	name = "awkward",
	description_potion = S("Awkward Potion"),
	description_splash = S("Awkward Splash Potion"),
	description_lingering = S("Awkward Lingering Potion"),
	no_arrow = true,
	no_effect = true,
	_tt = S("No effect"),
	_longdesc = S("Has an awkward taste and is used for brewing potions."),
	color = "#0000FF",
	groups = {brewitem=1, food=3, can_eat_when_full=1, potion = 1},
	on_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
}

local mundane_def = {
	name = "mundane",
	description_potion = S("Mundane Potion"),
	description_splash = S("Mundane Splash Potion"),
	description_lingering = S("Mundane Lingering Potion"),
	no_arrow = true,
	no_effect = true,
	_tt = S("No effect"),
	_longdesc = S("Has a terrible taste and is not useful for brewing potions."),
	color = "#0000FF",
	on_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
}

local thick_def = {
	name = "thick",
	description_potion = S("Thick Potion"),
	description_splash = S("Thick Splash Potion"),
	description_lingering = S("Thick Lingering Potion"),
	no_arrow = true,
	no_effect = true,
	_tt = S("No effect"),
	_longdesc = S("Has a bitter taste and is not useful for brewing potions."),
	color = "#0000FF",
	on_use = minetest.item_eat(0, "mcl_potions:glass_bottle"),
}

local dragon_breath_def = {
	name = "dragon_breath",
	description = S("Dragon's Breath"),
	no_arrow = true,
	no_potion = true,
	no_throwable = true,
	no_effect = true,
	_longdesc = S("This item is used in brewing and can be combined with splash potions to create lingering potions."),
	image = "mcl_potions_dragon_breath.png",
	groups = { brewitem = 1, potion = 1},
	on_use = nil,
}

local healing_def = {
	name = "healing",
	description = S("Healing"),
	_tt = S("+4 HP"),
	_tt_2 = S("+8 HP"),
	_longdesc = S("Instantly heals."),
	color = "#F82423",
	effect = 4,
	instant = true,
	on_use = mcl_potions.healing_func,
	is_II = true,
}


local harming_def = {
	name = "harming",
	description = S("Harming"),
	_tt = S("-6 HP"),
	_tt_II = S("-12 HP"),
	_longdesc = S("Instantly deals damage."),
	color = "#430A09",
	effect = -6,
	instant = true,
	on_use = mcl_potions.healing_func,
	is_II = true,
	is_inv = true,
}

local night_vision_def = {
	name = "night_vision",
	description = S("Night Vision"),
	_tt = nil,
	_longdesc = S("Increases the perceived brightness of light under a dark sky."),
	color = "#1F1FA1",
	effect = nil,
	is_dur = true,
	on_use = mcl_potions.night_vision_func,
	is_plus = true,
}

local swiftness_def = {
	name = "swiftness",
	description = S("Swiftness"),
	_tt = nil,
	_longdesc = S("Increases walking speed."),
	color = "#7CAFC6",
	effect = 1.2,
	is_dur = true,
	on_use = mcl_potions.swiftness_func,
	is_II = true,
	is_plus = true,
}

local slowness_def = {
	name = "slowness",
	description = S("Slowness"),
	_tt = nil,
	_longdesc = S("Decreases walking speed."),
	color = "#5A6C81",
	effect = 0.85,
	is_dur = true,
	on_use = mcl_potions.swiftness_func,
	is_II = true,
	is_plus = true,
	is_inv = true,
}

local leaping_def = {
	name = "leaping",
	description = S("Leaping"),
	_tt = nil,
	_longdesc = S("Increases jump strength."),
	color = "#22FF4C",
	effect = 1.15,
	is_dur = true,
	on_use = mcl_potions.leaping_func,
	is_II = true,
	is_plus = true,
}

local withering_def = {
	name = "withering",
	description = S("Withering"),
	_tt = nil,
	_longdesc = S("Applies the withering effect which deals damage at a regular interval and can kill."),
	color = "#000000",
	effect = 4,
	is_dur = true,
	on_use = mcl_potions.withering_func,
	is_II = true,
	is_plus = true,
	is_inv = true,
}

local poison_def = {
	name = "poison",
	description = S("Poison"),
	_tt = nil,
	_longdesc = S("Applies the poison effect which deals damage at a regular interval."),
	color = "#4E9331",
	effect = 2.5,
	is_dur = true,
	on_use = mcl_potions.poison_func,
	is_II = true,
	is_plus = true,
	is_inv = true,
}

local regeneration_def = {
	name = "regeneration",
	description = S("Regeneration"),
	_tt = nil,
	_longdesc = S("Regenerates health over time."),
	color = "#CD5CAB",
	effect = 2.5,
	is_dur = true,
	on_use = mcl_potions.regeneration_func,
	is_II = true,
	is_plus = true,
}

local invisibility_def = {
	name = "invisibility",
	description = S("Invisibility"),
	_tt = nil,
	_longdesc = S("Grants invisibility."),
	color = "#7F8392",
	is_dur = true,
	on_use = mcl_potions.invisiblility_func,
	is_plus = true,
}

local water_breathing_def = {
	name = "water_breathing",
	description = S("Water Breathing"),
	_tt = nil,
	_longdesc = S("Grants limitless breath underwater."),
	color = "#2E5299",
	is_dur = true,
	on_use = mcl_potions.water_breathing_func,
	is_plus = true,
}

local fire_resistance_def = {
	name = "fire_resistance",
	description = S("Fire Resistance"),
	_tt = nil,
	_longdesc = S("Grants immunity to damage from heat sources like fire."),
	color = "#E49A3A",
	is_dur = true,
	on_use = mcl_potions.fire_resistance_func,
	is_plus = true,
}



local defs = { awkward_def, mundane_def, thick_def, dragon_breath_def,
	healing_def, harming_def, night_vision_def, swiftness_def,
	slowness_def, leaping_def, withering_def, poison_def, regeneration_def,
	invisibility_def, water_breathing_def, fire_resistance_def}

for _, def in ipairs(defs) do
	register_potion(def)
end




-- minetest.register_craftitem("mcl_potions:weakness", {
-- 	description = S("Weakness"),
-- 	_tt_help = TODO,
-- 	_doc_items_longdesc = brewhelp,
-- 	wield_image = potion_image("#484D48"),
-- 	inventory_image = potion_image("#484D48"),
-- 	groups = { brewitem=1, food=3, can_eat_when_full=1, potion = 1 },
-- 	stack_max = 1,
--
-- 	on_place = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, -4, mcl_potions.DURATION*mcl_potions.INV_FACTOR)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#484D48")
-- 		return itemstack
-- 	end,
--
-- 	on_secondary_use = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, -4, mcl_potions.DURATION*mcl_potions.INV_FACTOR)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#484D48")
-- 		return itemstack
-- 	end
-- })
--
-- minetest.register_craftitem("mcl_potions:weakness_plus", {
-- 	description = S("Weakness +"),
-- 	_tt_help = TODO,
-- 	_doc_items_longdesc = brewhelp,
-- 	wield_image = potion_image("#484D48"),
-- 	inventory_image = potion_image("#484D48"),
-- 	groups = { brewitem=1, food=3, can_eat_when_full=1, potion = 1 },
-- 	stack_max = 1,
--
-- 	on_place = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, -4, mcl_potions.DURATION_2*mcl_potions.INV_FACTOR)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#484D48")
-- 		return itemstack
-- 	end,
--
-- 	on_secondary_use = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, -4, mcl_potions.DURATION_2*mcl_potions.INV_FACTOR)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#484D48")
-- 		return itemstack
-- 	end
-- })
--
-- minetest.register_craftitem("mcl_potions:strength", {
-- 	description = S("Strength"),
-- 	_tt_help = TODO,
-- 	_doc_items_longdesc = brewhelp,
-- 	wield_image = potion_image("#932423"),
-- 	inventory_image = potion_image("#932423"),
-- 	groups = { brewitem=1, food=3, can_eat_when_full=1, potion = 1 },
-- 	stack_max = 1,
--
-- 	on_place = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, 3, mcl_potions.DURATION)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#932423")
-- 		return itemstack
-- 	end,
--
-- 	on_secondary_use = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, 3, mcl_potions.DURATION)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#932423")
-- 		return itemstack
-- 	end
-- })
--
-- minetest.register_craftitem("mcl_potions:strength_2", {
-- 	description = S("Strength II"),
-- 	_tt_help = TODO,
-- 	_doc_items_longdesc = brewhelp,
-- 	wield_image = potion_image("#932423"),
-- 	inventory_image = potion_image("#932423"),
-- 	groups = { brewitem=1, food=3, can_eat_when_full=1, potion = 1 },
-- 	stack_max = 1,
--
-- 	on_place = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, 6, mcl_potions.DURATION_2)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#932423")
-- 		return itemstack
-- 	end,
--
-- 	on_secondary_use = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, 6, mcl_potions.DURATION_2)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#932423")
-- 		return itemstack
-- 	end
-- })
--
-- minetest.register_craftitem("mcl_potions:strength_plus", {
-- 	description = S("Strength +"),
-- 	_tt_help = TODO,
-- 	_doc_items_longdesc = brewhelp,
-- 	wield_image = potion_image("#932423"),
-- 	inventory_image = potion_image("#932423"),
-- 	groups = { brewitem=1, food=3, can_eat_when_full=1, potion = 1 },
-- 	stack_max = 1,
--
-- 	on_place = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, 3, mcl_potions.DURATION_PLUS)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#932423")
-- 		return itemstack
-- 	end,
--
-- 	on_secondary_use = function(itemstack, user, pointed_thing)
-- 		mcl_potions.weakness_func(user, 3, mcl_potions.DURATION_PLUS)
-- 		minetest.do_item_eat(0, "mcl_potions:glass_bottle", itemstack, user, pointed_thing)
-- 		mcl_potions._use_potion(itemstack, user, "#932423")
-- 		return itemstack
-- 	end
-- })
