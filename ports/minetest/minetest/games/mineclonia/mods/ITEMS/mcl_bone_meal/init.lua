mcl_bone_meal = {}

local S = core.get_translator(core.get_current_modname())

function mcl_bone_meal.add_bone_meal_particle(pos, def)
	if not def then
		def = {}
	end
	core.add_particlespawner({
		amount = def.amount or 10,
		time = def.time or 0.1,
		minpos = def.minpos or vector.subtract(pos, 0.5),
		maxpos = def.maxpos or vector.add(pos, 0.5),
		minvel = def.minvel or vector.new(-0.01, 0.01, -0.01),
		maxvel = def.maxvel or vector.new(0.01, 0.01, 0.01),
		minacc = def.minacc or vector.new(0, 0, 0),
		maxacc = def.maxacc or vector.new(0, 0, 0),
		minexptime = def.minexptime or 1,
		maxexptime = def.maxexptime or 4,
		minsize = def.minsize or 0.7,
		maxsize = def.maxsize or 2.4,
		texture = "mcl_particles_bonemeal.png^[colorize:#00EE00:125", -- TODO: real MC color
		glow = def.glow or 1,
	})
end

local function bone_meal(itemstack, user, pointed_thing)
	local pname = user and user:get_player_name()
	local unode = core.get_node(pointed_thing.under)
	local anode = core.get_node(pointed_thing.above)
	local udef = core.registered_nodes[unode.name]
	local adef = core.registered_nodes[anode.name]
	if udef and udef._on_bone_meal then
		if pname and core.is_protected(pointed_thing.under, pname) then
			core.record_protection_violation(pointed_thing.under, pname)
			return itemstack
		end
		if udef._on_bone_meal(itemstack,user,pointed_thing, pointed_thing.under,unode) ~= false then
			mcl_bone_meal.add_bone_meal_particle(pointed_thing.under)
			mcl_bone_meal.add_bone_meal_particle(pointed_thing.above)
			if not core.is_creative_enabled(pname) then
				itemstack:take_item()
			end
		end
	elseif adef and adef._on_bone_meal then
		if core.is_protected(pointed_thing.above, pname) then
			core.record_protection_violation(pointed_thing.above, pname)
			return itemstack
		end
		if adef._on_bone_meal(itemstack,user,pointed_thing,pointed_thing.above,anode) ~= false then
			mcl_bone_meal.add_bone_meal_particle(pointed_thing.above)
			if not core.is_creative_enabled(pname) then
				itemstack:take_item()
			end
		end
	end
	return itemstack
end

core.register_craftitem("mcl_bone_meal:bone_meal", {
	inventory_image = "mcl_bone_meal_bone_meal.png",
	description = S("Bone Meal"),
	_tt_help = S("Speeds up plant growth"),
	_doc_items_longdesc = S("Bone meal is a white dye and also useful as a fertilizer to speed up the growth of many plants."),
	_doc_items_usagehelp = S("Rightclick a sheep to turn its wool white. Rightclick a plant to speed up its growth. Note that not all plants can be fertilized like this. When you rightclick a grass block, tall grass and flowers will grow all over the place."),
	on_place = function(itemstack, user, pointed_thing)
		local rc = mcl_util.call_on_rightclick(itemstack, user, pointed_thing)
		if rc then return rc end

		return bone_meal(itemstack, user, pointed_thing)
	end,
	_on_dispense = function(stack, pos, droppos, dropnode)
		-- Apply bone meal, if possible
		local pointed_thing
		if dropnode.name == "air" then
			pointed_thing = { above = droppos, under = { x=droppos.x, y=droppos.y-1, z=droppos.z } }
		else
			pointed_thing = { above = pos, under = droppos }
		end
		return bone_meal(stack,nil,pointed_thing)
	end,
	_dispense_into_walkable = true,
	_mcl_crafting_output = {
		single = {output = "mcl_dyes:white"},
		square3 = {output = "mcl_core:bone_block"}
	}
})
