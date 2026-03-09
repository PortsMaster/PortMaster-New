local S = core.get_translator(core.get_current_modname())

local arrow_def = core.registered_items["mcl_bows:arrow"]
local arrow_longdesc = arrow_def._doc_items_longdesc or ""
local arrow_tt = arrow_def._tt_help or ""

local function arrow_image(colorstring, opacity)
	if not opacity then
		opacity = 127
	end
	return {"mcl_bows_arrow.png^(mcl_bows_arrow_overlay.png^[colorize:"..colorstring..":"..tostring(opacity)..")"}
end

function mcl_potions.register_arrow(name, desc, color, def)
	local id = def._id_override or "mcl_potions:"..name
	local tt = def._tt or ""
	local groups = {ammo=1, ammo_bow=1, ammo_crossbow=1, brewitem=1, tipped_arrow = 1, _mcl_potion=1}
	if def.nocreative then groups.not_in_creative_inventory = 1 end
	core.register_craftitem(":" .. id.."_arrow", table.merge (arrow_def, {
		description = desc,
		_tt_help = arrow_tt .. "\n" .. tt,
		_dynamic_tt = def._dynamic_tt,
		_mcl_filter_description = mcl_potions.filter_potion_description,
		_doc_items_longdesc = arrow_longdesc .. "\n" ..
			S("This particular arrow is tipped and will give an effect when it hits a player or mob.") .. "\n" ..
			(def.longdesc or ""),
		_effect_list = def._effect_list,
		uses_level = def.uses_level,
		has_potent = def.has_potent,
		has_plus = def.has_plus,
		_default_potent_level = def._default_potent_level,
		_default_extend_level = def._default_extend_level,
		inventory_image = "mcl_bows_arrow_inv.png^(mcl_potions_arrow_inv.png^[colorize:"..color..":100)",
		groups = groups,
		_get_all_virtual_items = def._get_all_virtual_items
	}))

	local ARROW_ENTITY = table.copy(core.registered_entities["mcl_bows:arrow_entity"])
	ARROW_ENTITY.initial_properties.textures = arrow_image (color, 100)
	ARROW_ENTITY._itemstring = id.."_arrow"

	function ARROW_ENTITY:_extra_hit_func (obj)
		local potency, plus = 0, 0
		if def._effect_list then
		local ef_level
		local dur

		for name, details in pairs(def._effect_list) do
			ef_level = mcl_potions.level_from_details (details, potency)
			dur = mcl_potions.duration_from_details (details, potency,
								 plus,
								 mcl_potions.TIPPED_FACTOR)
			mcl_potions.give_effect_by_level(name, obj, ef_level, dur)
		end
		end
		if def.custom_effect then def.custom_effect (obj, potency+1, nil, self._shooter) end
	end

	core.register_entity(":"..id.."_arrow_entity", ARROW_ENTITY)

	core.register_craft({
		output = id.."_arrow 8",
		recipe = {
			{"mcl_bows:arrow","mcl_bows:arrow","mcl_bows:arrow"},
			{"mcl_bows:arrow",id.."_lingering","mcl_bows:arrow"},
			{"mcl_bows:arrow","mcl_bows:arrow","mcl_bows:arrow"}
		}
	})

	doc.sub.identifier.register_object("mcl_bows:arrow_entity", "craftitems", "mcl_bows:arrow")
end

local function on_craft(itemstack, _, old_craft_grid)
	if core.get_item_group(itemstack:get_name(), "tipped_arrow") == 1 then
		local potion_meta

		for _, stack in pairs(old_craft_grid) do
			if core.get_item_group(stack:get_name(), "ling_potion") == 1 then
				potion_meta = stack:get_meta()
			end
		end

		if potion_meta then
			local potency = potion_meta:get_int("mcl_potions:potion_potent")
			local extend = potion_meta:get_int("mcl_potions:potion_plus")

			if potency and potency > 0 then
				itemstack:get_meta():set_int("mcl_potions:potion_potent", potency)
			end
			if extend and extend > 0 then
				itemstack:get_meta():set_int("mcl_potions:potion_plus", extend)
			end
		end

		tt.reload_itemstack_description(itemstack)
	end

	return itemstack
end

core.register_craft_predict(on_craft)
core.register_on_craft(on_craft)
