local D = mcl_util.get_dynamic_translator()

-- Fish Buckets
local fish_names = {
	["cod"] = {"Cod", "a Cod"},
	["salmon"] = {"Salmon", "a Salmon"},
	["tropical_fish"] = {"Tropical Fish", "a Tropical Fish"},
	["axolotl"] = {"Axolotl", "an Axolotl"},
	["pufferfish"] = {"Pufferfish", "a Pufferfish"},
}

local fishbucket_prefix = "mcl_buckets:bucket_"

local function on_place_fish(itemstack, placer, pointed_thing)
	local new_stack = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
	if new_stack then
		return new_stack
	end

	if pointed_thing.type ~= "node" then return end

	local pos = pointed_thing.above
	local n = core.get_node(pointed_thing.above)
	local defs = core.registered_nodes[n.name]

	local fish = itemstack:get_definition()._mcl_buckets_fish
	if fish_names[fish] then
		local props = table.merge(
			core.deserialize(itemstack:get_meta():get_string("properties")) or {},
			{persistent = true}
		)

		local bucket_name = itemstack:get_meta():get_string("name")
		if bucket_name ~= "" then
			props = table.merge(props, {nametag=bucket_name})
		end

		local o = core.add_entity(pos,
			"mobs_mc:" .. fish, core.serialize(props))

		if o and o:get_pos() then
			local water = "mcl_core:water_source"
			if n.name == "mclx_core:river_water_source" then
				water = n.name
			elseif n.name == "mclx_core:river_water_flowing" then
				water = nil ---@diagnostic disable-line: cast-local-type
			end
			if mcl_worlds.pos_to_dimension(pos) == "nether" then
				water = nil ---@diagnostic disable-line: cast-local-type
				core.sound_play("fire_extinguish_flame", {pos = pos, gain = 0.25, max_hear_distance = 16}, true)
			end
			if water then
				if defs and (core.get_item_group(n.name, "solid") ~= 1 and core.get_item_group(n.name, "opaque") ~= 1) then
					core.dig_node(pos)
					core.set_node(pos, {name = water})
				else
					return
				end
			end
			if not placer or not core.is_creative_enabled(placer:get_player_name()) then
				itemstack = ItemStack("mcl_buckets:bucket_empty")
			end
		end
	end
	return itemstack
end

for techname, fishname in pairs(fish_names) do
	local fish, a_fish, a_fish_dot = fishname[1], fishname[2], fishname[2] .. "."
	core.register_craftitem(fishbucket_prefix .. techname, {
		description = D("Bucket of " .. fish),
		_doc_items_longdesc = D("This bucket is filled with water and " .. a_fish_dot),
		_doc_items_usagehelp = D("Place it to empty the bucket and place " .. a_fish_dot .. " Obtain by right clicking on " .. a_fish .. " with a bucket of water."),
		_tt_help = D("Places a water source and " .. a_fish_dot),
		inventory_image = techname .. "_bucket.png",
		stack_max = 1,
		groups = {bucket = 1, fish_bucket = 1},
		_mcl_buckets_fish = techname,
		on_place = on_place_fish,
		on_secondary_use = on_place_fish,
		_on_dispense = function(stack, _, droppos)
			local fake_pt = {type = "node"}
			fake_pt.above = droppos
			fake_pt.under = vector.offset(droppos, 0, -1, 0)

			return on_place_fish(stack, nil, fake_pt)
		end,
	})

	core.register_alias("mcl_fishing:bucket_" .. techname, "mcl_buckets:bucket_" .. techname)
end
