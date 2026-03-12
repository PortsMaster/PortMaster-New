mcl_cauldrons = {}
local S = core.get_translator(core.get_current_modname())

-- Cauldron mod, adds cauldrons.

local function sound_place(itemname, pos)
	local def = core.registered_nodes[itemname]
	if def and def.sounds and def.sounds.place then
		core.sound_play(def.sounds.place, {gain=1.0, pos = pos, pitch = 1 + math.random(-10, 10)*0.005}, true)
	end
end

local function sound_take(itemname, pos)
	local def = core.registered_nodes[itemname]
	if def and def.sounds and def.sounds.dug then
		core.sound_play(def.sounds.dug, {gain=1.0, pos = pos, pitch = 1 + math.random(-10, 10)*0.005}, true)
	end
end

-- Convenience function because the cauldron nodeboxes are very similar
local function create_cauldron_nodebox(water_level)
	local floor_y = -0.1875

	if water_level == 1 then	-- 1/3 filled
		floor_y = 1/16
	elseif water_level == 2 then	-- 2/3 filled
		floor_y = 4/16
	elseif water_level == 3 then	-- full
		floor_y = 7/16
	end
	return {
		type = "fixed",
		fixed = {
			{-0.5, -0.1875, -0.5, -0.375, 0.5, 0.5}, -- Left wall
			{0.375, -0.1875, -0.5, 0.5, 0.5, 0.5}, -- Right wall
			{-0.375, -0.1875, 0.375, 0.375, 0.5, 0.5}, -- Back wall
			{-0.375, -0.1875, -0.5, 0.375, 0.5, -0.375}, -- Front wall
			{-0.5, -0.3125, -0.5, 0.5, floor_y, 0.5}, -- Floor
			{-0.5, -0.5, -0.5, -0.375, -0.3125, -0.25}, -- Left front foot, part 1
			{-0.375, -0.5, -0.5, -0.25, -0.3125, -0.375}, -- Left front foot, part 2
			{-0.5, -0.5, 0.25, -0.375, -0.3125, 0.5}, -- Left back foot, part 1
			{-0.375, -0.5, 0.375, -0.25, -0.3125, 0.5}, -- Left back foot, part 2
			{0.375, -0.5, 0.25, 0.5, -0.3125, 0.5}, -- Right back foot, part 1
			{0.25, -0.5, 0.375, 0.375, -0.3125, 0.5}, -- Right back foot, part 2
			{0.375, -0.5, -0.5, 0.5, -0.3125, -0.25}, -- Right front foot, part 1
			{0.25, -0.5, -0.5, 0.375, -0.3125, -0.375}, -- Right front foot, part 2
		}
	}
end

local cauldron_ids = {
	water = "",
	river_water = "r",
	lava = "_lava",
	powder_snow = "_powder_snow"
}

local liquid_nodes = {
	water = "mcl_core:water_source",
	river_water = "mclx_core:river_water_source",
	lava = "mcl_core:lava_source",
}

local buckets = {
	water = "mcl_buckets:bucket_water",
	river_water = "mcl_buckets:bucket_river_water",
	lava = "mcl_buckets:bucket_lava",
	powder_snow = "mcl_powder_snow:bucket_powder_snow"
}

local water_bottles = {
	water = "mcl_potions:water",
	river_water = "mcl_potions:river_water",
}

function mcl_cauldrons.get_cauldron_name(level, liquid)
	level = math.min(3, level)
	level = math.max(0, level)
	if level == 0 then return "mcl_cauldrons:cauldron" end
	return "mcl_cauldrons:cauldron_"..level..cauldron_ids[liquid or "water"]
end

function mcl_cauldrons.add_level(pos, amount, liquid)
	local node = core.get_node(pos)
	if core.get_item_group(node.name, "cauldron") == 0 then return end
	amount = tonumber(amount) or 1
	local water_level = core.get_item_group(node.name, "cauldron_filled")
	local def = core.registered_nodes[node.name]
	local liquid = def and def._mcl_cauldrons_liquid or liquid
	if amount ~= 0 and liquid then
		if amount > 0 then
			sound_place(liquid_nodes[liquid], pos)
		else
			sound_take(liquid_nodes[liquid], pos)
		end
		node.name = mcl_cauldrons.get_cauldron_name(water_level + amount, liquid)
		mcl_redstone.swap_node(pos, node)
		return true
	end
end


local function bucket_place(itemstack,placer,pointed_thing)
	local name = core.get_node(pointed_thing.under).name
	if core.get_item_group(name, "cauldron_filled")  >= 3 then return itemstack end
	local def = core.registered_nodes[name]
	local l = itemstack:get_definition()._mcl_buckets_liquid
	if def and l and ( def._mcl_cauldrons_liquid == l or core.get_item_group(name, "cauldron") == 1 ) then
		mcl_cauldrons.add_level(pointed_thing.under, 3, l)
		if not core.is_creative_enabled(placer:get_player_name()) then
			if itemstack:get_count() == 1 then
				itemstack:set_name("mcl_buckets:bucket_empty")
				return itemstack
			end
			itemstack:take_item()
			local inv = placer:get_inventory()
			local rest = inv:add_item("main","mcl_buckets:bucket_empty")
			if not rest:is_empty() then
				mcl_util.drop_item_stack(pointed_thing.above, rest)
			end
		end
	end
	return itemstack
end

local function bottle_place(itemstack, placer, pointed_thing)
	local def = itemstack:get_definition()
	local node = core.get_node(pointed_thing.under)
	local ndef = core.registered_nodes[node.name]

	local cauldron_filled = core.get_item_group(node.name, "cauldron_filled")
	if def and ndef and (cauldron_filled == 0 or def._mcl_cauldrons_liquid == ndef._mcl_cauldrons_liquid) then
		mcl_cauldrons.add_level(pointed_thing.under, 1, def._mcl_cauldrons_liquid)
		local bottle = ItemStack("mcl_potions:glass_bottle")
		return mcl_inventory.give_and_take(placer, itemstack, bottle, "give_new")
	end
	local cauldron_filled = core.get_item_group(core.get_node(pointed_thing.under).name, "cauldron_filled")
	if ndef and ndef._mcl_cauldrons_liquid and itemstack:get_name() == "mcl_potions:glass_bottle" and cauldron_filled > 0 then
		mcl_cauldrons.add_level(pointed_thing.under, -1, ndef._mcl_cauldrons_liquid)
		local bottle = ItemStack(water_bottles[ndef._mcl_cauldrons_liquid])
		return mcl_inventory.give_and_take(placer, itemstack, bottle, "give")
	end

	return itemstack
end

-- Empty cauldron
core.register_node("mcl_cauldrons:cauldron", {
	description = S("Cauldron"),
	_tt_help = S("Stores water"),
	_doc_items_longdesc = S("Cauldrons are used to store water and slowly fill up under rain."),
	_doc_items_usagehelp = S("Place a water bucket into the cauldron to fill it with water. Place an empty bucket on a full cauldron to retrieve the water. Place a water bottle into the cauldron to fill the cauldron to one third with water. Place a glass bottle in a cauldron with water to retrieve one third of the water."),
	wield_image = "mcl_cauldrons_cauldron.png",
	inventory_image = "mcl_cauldrons_cauldron.png",
	drawtype = "nodebox",
	paramtype = "light",
	is_ground_content = false,
	groups = {pickaxey=1, deco_block=1, cauldron=1, comparator_signal=0, pathfinder_partial=2},
	node_box = create_cauldron_nodebox(0),
	selection_box = { type = "regular" },
	tiles = {
		"mcl_cauldrons_cauldron_inner.png^mcl_cauldrons_cauldron_top.png",
		"mcl_cauldrons_cauldron_inner.png^mcl_cauldrons_cauldron_bottom.png",
		"mcl_cauldrons_cauldron_side.png"
	},
	sounds = mcl_sounds.node_sound_metal_defaults(),
	_mcl_hardness = 2,
	_on_bucket_place = bucket_place,
	_on_bottle_place = bottle_place,
})

-- Template function for cauldrons with water
local function register_filled_cauldron(water_level, description, liquid)
	local id = mcl_cauldrons.get_cauldron_name(water_level, liquid)
	local water_tex
	local light_level = 0
	local cauldron_water = 0
	if liquid == "river_water" then
		cauldron_water = 2
		water_tex = "default_river_water_source_animated.png^[verticalframe:16:0"
	elseif liquid == "lava" then
		light_level = core.LIGHT_MAX
		water_tex = "default_lava_source_animated.png^[verticalframe:16:0"
	elseif liquid == "powder_snow" then
		water_tex = "powder_snow.png"
	else
		cauldron_water = 1
		water_tex = "default_water_source_animated.png^[verticalframe:16:0"
	end
	core.register_node(id, {
		description = description,
		_doc_items_create_entry = false,
		drawtype = "nodebox",
		paramtype = "light",
		light_source = light_level,
		is_ground_content = false,
		groups = {pickaxey=1, not_in_creative_inventory=1, cauldron=(1+water_level), cauldron_filled=water_level, comparator_signal=water_level, cauldron_water = cauldron_water, pathfinder_partial = 2},
		node_box = create_cauldron_nodebox(water_level),
		collision_box = create_cauldron_nodebox(0),
		selection_box = { type = "regular" },
		tiles = {
			"("..water_tex..")^mcl_cauldrons_cauldron_top.png",
			"mcl_cauldrons_cauldron_inner.png^mcl_cauldrons_cauldron_bottom.png",
			"mcl_cauldrons_cauldron_side.png"
		},
		sounds = mcl_sounds.node_sound_metal_defaults(),
		drop = "mcl_cauldrons:cauldron",
		_mcl_hardness = 2,
		_mcl_cauldrons_liquid = liquid or "water",
		_mcl_baseitem = "mcl_cauldrons:cauldron",
		_on_bottle_place = bottle_place,
		_on_bucket_place = bucket_place,
		_on_bucket_place_empty  = function(itemstack,placer,pointed_thing)
			local name = core.get_node(pointed_thing.under).name
			if core.get_item_group(name, "cauldron_filled") < 3 then return itemstack end
			mcl_cauldrons.add_level(pointed_thing.under, -3)
			if not core.is_creative_enabled(placer:get_player_name()) then
				local def = core.registered_nodes[name]
				if def and def._mcl_cauldrons_liquid and buckets[def._mcl_cauldrons_liquid] then
					if itemstack:get_count() == 1 then
						itemstack:set_name(buckets[def._mcl_cauldrons_liquid])
						return itemstack
					end
					itemstack:take_item()
					local inv = placer:get_inventory()
					local rest = inv:add_item("main", buckets[def._mcl_cauldrons_liquid])
					if not rest:is_empty() then
						mcl_util.drop_item_stack(pointed_thing.above, rest)
					end
				end
			end
			return itemstack
		end,
	})

	doc.add_entry_alias("nodes", "mcl_cauldrons:cauldron", "nodes", id)
end

-- Filled cauldrons (3 levels)
for i=1,3 do
	register_filled_cauldron(i, S("Cauldron (@1/3 Water)", i))
	register_filled_cauldron(i, S("Cauldron (@1/3 Lava)", i),"lava")
	register_filled_cauldron(i, S("Cauldron (@1/3 Powder Snow)", i), "powder_snow")
	register_filled_cauldron(i, S("Cauldron (@1/3 River Water)", i),"river_water")
end

core.register_craft({
	output = "mcl_cauldrons:cauldron",
	recipe = {
		{ "mcl_core:iron_ingot", "", "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot", "", "mcl_core:iron_ingot" },
		{ "mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot" },
	}
})

local function cauldron_extinguish(obj,pos)
	local node = core.get_node(pos)
	if mcl_burning.is_burning(obj) then
		mcl_burning.extinguish(obj)
		local new_group = core.get_item_group(node.name, "cauldron_filled") - 1
		core.swap_node(pos, {name = "mcl_cauldrons:cauldron" .. (new_group == 0 and "" or "_" .. new_group)})
	end
end

local etime = 0
core.register_globalstep(function(dtime)
	etime = dtime + etime
	if etime < 0.5 then return end
	etime = 0
	for pl in mcl_util.connected_players() do
		local n = core.find_node_near(pl:get_pos(),0.4,{"group:cauldron_filled"},true)
		if n and not core.get_node(n).name:find("lava") then
			cauldron_extinguish(pl,n)
		elseif n and core.get_node(n).name:find("lava") then
				mcl_burning.set_on_fire(pl, 5)
		end
	end
	for _,ent in pairs(core.luaentities) do
		if ent.object:get_pos() and ent.is_mob then
			local n = core.find_node_near(ent.object:get_pos(),0.4,{"group:cauldron_filled"},true)
			if n and not core.get_node(n).name:find("lava") then
				cauldron_extinguish(ent.object,n)
			elseif n and core.get_node(n).name:find("lava") then
				mcl_burning.set_on_fire(ent.object, 5)
			end
		end
	end
end)
