local S = minetest.get_translator(minetest.get_current_modname())

local planton = {"mcl_core:dirt_with_grass", "mcl_core:dirt", "mcl_core:podzol", "mcl_core:coarse_dirt", "mcl_farming:soil", "mcl_farming:soil_wet", "mcl_lush_caves:moss"}

for i=0, 3 do
	local texture = "mcl_farming_sweet_berry_bush_" .. i .. ".png"
	local node_name = "mcl_farming:sweet_berry_bush_" .. i
	local groups = {sweet_berry=1, dig_immediate=3, not_in_creative_inventory=1,plant=1,attached_node=1,dig_by_water=1,destroy_by_lava_flow=1,dig_by_piston=1, flammable=3, fire_encouragement=60, fire_flammability=20, compostability=30}
	if i > 0 then
		groups.sweet_berry_thorny = 1
	end
	local drop_berries = (i >= 2)
	local berries_to_drop = drop_berries and {i - 1, i} or nil
	local orc
	if i >= 2 then
		orc = function(pos, node, clicker, itemstack, pointed_thing)
			if clicker and clicker:is_player() then
				local pn = clicker:get_player_name()
				if minetest.is_protected(pos, pn) then
					minetest.record_protection_violation(pos, pn)
					return false
				end
				if clicker:get_wielded_item():get_name() == "mcl_bone_meal:bone_meal" then
					return false
				end
			end
			for j=1, berries_to_drop[math.random(2)] do
				minetest.add_item(pos, "mcl_farming:sweet_berry")
			end
			minetest.swap_node(pos, {name = "mcl_farming:sweet_berry_bush_1"})
			return itemstack
		end
	end

	minetest.register_node(node_name, {
		drawtype = "plantlike",
		tiles = {texture},
		description = S("Sweet Berry Bush (Stage @1)", i),
		paramtype = "light",
		sunlight_propagates = true,
		paramtype2 = "meshoptions",
		place_param2 = 3,
		move_resistance = 7,
		walkable = false,
		-- Dont even create a table if no berries are dropped.
		drop = not drop_berries and "" or {
			max_items = 1,
			items = {
				{ items = {"mcl_farming:sweet_berry " .. berries_to_drop[1] }, rarity = 2 },
				{ items = {"mcl_farming:sweet_berry " .. berries_to_drop[2] } }
			}
		},
		selection_box = {
			type = "fixed",
			fixed = {-6 / 16, -0.5, -6 / 16, 6 / 16, (-0.30 + (i*0.25)), 6 / 16},
		},
		inventory_image = texture,
		wield_image = texture,
		groups = groups,
		sounds = mcl_sounds.node_sound_leaves_defaults(),
		_mcl_blast_resistance = 0,
		_mcl_hardness = 0,
		on_rightclick = orc,
		_on_bone_meal = function(itemstack,placer,pointed_thing,pos,node)
			mcl_farming.on_bone_meal(itemstack,placer,pointed_thing,pos,node,"plant_sweet_berry_bush",1)
		end,
	})
	minetest.register_alias("mcl_sweet_berry:sweet_berry_bush_" .. i, node_name)
end

minetest.register_craftitem("mcl_farming:sweet_berry", {
	description = S("Sweet Berry"),
	inventory_image = "mcl_farming_sweet_berry.png",
	_mcl_saturation = 0.4,
	groups = { food = 2, eatable = 1, compostability=30 },
	on_secondary_use = minetest.item_eat(1),
	on_place = function(itemstack, placer, pointed_thing)
		local pn = placer:get_player_name()
		if placer:is_player() and minetest.is_protected(pointed_thing.above, pn or "") then
			minetest.record_protection_violation(pointed_thing.above, pn)
			return itemstack
		end
		if pointed_thing.type == "node" and
				table.indexof(planton, minetest.get_node(pointed_thing.under).name) ~= -1 and
				pointed_thing.above.y > pointed_thing.under.y and
				minetest.get_node(pointed_thing.above).name == "air" then
			minetest.set_node(pointed_thing.above, {name="mcl_farming:sweet_berry_bush_0"})
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:take_item()
			end
			return itemstack
		end
		return minetest.do_item_eat(1, nil, itemstack, placer, pointed_thing)
	end,
})
minetest.register_alias("mcl_sweet_berry:sweet_berry", "mcl_farming:sweet_berry")

-- TODO: Find proper interval and chance values for sweet berry bushes. Current interval and chance values are copied from mcl_farming:beetroot which has similar growth stages.
mcl_farming:add_plant("plant_sweet_berry_bush", "mcl_farming:sweet_berry_bush_3", {"mcl_farming:sweet_berry_bush_0", "mcl_farming:sweet_berry_bush_1", "mcl_farming:sweet_berry_bush_2"}, 68, 3)

local function berry_damage_check(obj)
	local p = obj:get_pos()
	if not p then return end
	if not minetest.find_node_near(p,0.4,{"group:sweet_berry_thorny"},true) then return end
	local v = obj:get_velocity()
	if math.abs(v.x) < 0.1 and math.abs(v.y) < 0.1 and math.abs(v.z) < 0.1 then return end

	mcl_util.deal_damage(obj, 0.5, {type = "sweet_berry"})
end

local etime = 0
minetest.register_globalstep(function(dtime)
	etime = dtime + etime
	if etime < 0.5 then return end
	etime = 0
	for _,pl in pairs(minetest.get_connected_players()) do
		berry_damage_check(pl)
	end
	for _,ent in pairs(minetest.luaentities) do
		if ent.is_mob then
			berry_damage_check(ent.object)
		end
	end
end)
