local S = core.get_translator(core.get_current_modname())
mcl_sculk = {}

--local mt_sound_play = core.sound_play

local spread_to = {"mcl_core:stone","mcl_core:dirt","mcl_core:sand","mcl_core:dirt_with_grass","group:grass_block","mcl_core:andesite","mcl_core:diorite","mcl_core:granite","mcl_core:mycelium","group:dirt","mcl_end:end_stone","mcl_nether:netherrack","mcl_blackstone:basalt","mcl_nether:soul_sand","mcl_blackstone:soul_soil","mcl_crimson:warped_nylium","mcl_crimson:crimson_nylium","mcl_core:gravel","mcl_deepslate:deepslate","mcl_deepslate:tuff"}

local sounds = {
	footstep = {name = "mcl_sculk_block", gain = 0.2},
	dug      = {name = "mcl_sculk_block", gain = 0.2},
}

local SPREAD_RANGE = 8
--local SENSOR_RANGE = 8
--local SENSOR_DELAY = 0.5
--local SHRIEKER_COOLDOWN = 10

local adjacents = {
	vector.new(1,0,0),
	vector.new(-1,0,0),
	vector.new(0,1,0),
	vector.new(0,-1,0),
	vector.new(0,0,1),
	vector.new(0,0,-1),
}

--[[
local function sensor_action(p,tp)
	local s = core.find_node_near(p,SPREAD_RANGE,{"mcl_sculk:shrieker"})
	local n = core.get_node(s)
	if s and n.param2 ~= 1 then
		core.sound_play("mcl_sculk_shrieker", {pos=s, gain=1.5, max_hear_distance = 16}, true)
		n.param2 = 1
		core.set_node(s,n)
		core.after(SHRIEKER_COOLDOWN,function(s)
			core.set_node(s,{name = "mcl_sculk:shrieker",param2=0})
		end,s)
	end
	--local p1 = vector.offset(p,-SENSOR_RANGE,-SENSOR_RANGE,-SENSOR_RANGE)
	--local p2 = vector.offset(p,SENSOR_RANGE,SENSOR_RANGE,SENSOR_RANGE)
	--darken_area(p1,p2)
end

function core.sound_play(spec, parameters, ephemeral)
	local rt = old_sound_play(spec, parameters, ephemeral)
	if parameters.pos then
		pos = parameters.pos
	elseif parameters.to_player then
		pos = core.get_player_by_name(parameters.to_player):get_pos()
	end
	if not pos then return rt end
	local s = core.find_node_near(pos,SPREAD_RANGE,{"mcl_sculk:sensor"})
	if s then
		--core.after(SENSOR_DELAY,sensor_action,s,pos)
	end
	return rt
end

mcl_walkover.register_global(function(pos, node, player)
	local s = core.find_node_near(pos,SPREAD_RANGE,{"mcl_sculk:sensor"})
	if not s then return end
	local v = player:get_velocity()
	if v.x == 0 and v.y == 0 and v.z == 0 then return end
	if player:get_player_control().sneak then return end
	local def = core.registered_nodes[node.name]
	if def and def.sounds then
		core.log("mcl_walkover "..node.name)
		core.after(SENSOR_DELAY,sensor_action,s,pos)
	end
end)
--]]

local function get_node_xp(pos)
	local meta = core.get_meta(pos)
	return meta:get_int("xp")
end
local function set_node_xp(pos,xp)
	local meta = core.get_meta(pos)
	return meta:set_int("xp",xp)
end

local function sculk_after_dig_node(pos, oldnode, oldmetadata, digger) ---@diagnostic disable-line: unused-local
	-- Check if node will yield its useful drop by the digger's tool
	if digger and digger:is_player() then
		local tool = digger:get_wielded_item()
		local is_book = tool:get_name() == "mcl_enchanting:book_enchanted"

		if mcl_autogroup.can_harvest(oldnode.name, tool:get_name(), digger) then
			if tool and not is_book and mcl_enchanting.get_enchantments(tool).silk_touch then
				-- Don't drop experience when mined with silk touch
				return
			end
		end
	end

	local xp = get_node_xp(pos)
	if oldnode.param2 == 1 then
		xp = 1
	end
	local obs = mcl_experience.throw_xp(pos,xp)
	if obs then
		for _,v in pairs(obs) do
			local l = v:get_luaentity()
			l._sculkdrop = true
		end
	end
end

local function has_air(pos)
	for _,v in pairs(adjacents) do
		if core.get_item_group(core.get_node(vector.add(pos,v)).name,"solid") <= 0 then return true end
	end
end

local function has_nonsculk(pos)
	for _,v in pairs(adjacents) do
		local p = vector.add(pos,v)
		if core.get_item_group(core.get_node(p).name,"sculk") <= 0 and core.get_item_group(core.get_node(p).name,"solid") > 0 then return p end
	end
end
local function retrieve_close_spreadable_nodes (p)
	local nnn = core.find_nodes_in_area(vector.offset(p,-SPREAD_RANGE,-SPREAD_RANGE,-SPREAD_RANGE),vector.offset(p,SPREAD_RANGE,SPREAD_RANGE,SPREAD_RANGE),spread_to)
	local nn={}
	for _,v in pairs(nnn) do
		if has_air(v) then
			table.insert(nn,v)
		end
	end
	table.sort(nn,function(a, b)
		return vector.distance(p, a) < vector.distance(p, b)
	end)
	return nn
end

local function spread_sculk (p, xp_amount)
	local c = core.find_node_near(p,SPREAD_RANGE,{"mcl_sculk:catalyst"})
	if c then
		local nn = retrieve_close_spreadable_nodes (p)
		if nn and #nn > 0 then
			if xp_amount > 0 then
				--local d = math.random(100)
				--[[ --enable to generate shriekers and sensors
				if d <= 1 then
					core.set_node(nn[1],{name = "mcl_sculk:shrieker"})
					set_node_xp(nn[1],math.min(1,self._xp - 10))
					self.object:remove()
					return ret
				elseif d <= 9 then
					core.set_node(nn[1],{name = "mcl_sculk:sensor"})
					set_node_xp(nn[1],math.min(1,self._xp - 5))
					self.object:remove()
					return ret
				else --]]


				local r = math.min(math.random(#nn), xp_amount)

				for i=1,r do
					core.set_node(nn[i],{name = "mcl_sculk:sculk" })
					set_node_xp(nn[i],math.floor(xp_amount / r))
				end
				for i=1,r do
					local p = has_nonsculk(nn[i])
					if p and has_air(p) then
						core.set_node(vector.offset(p,0,1,0),{name = "mcl_sculk:vein", param2 = 1})
					end
				end
				set_node_xp(nn[1],get_node_xp(nn[1]) + xp_amount % r)
				return true
			end
		end
	end
end

function mcl_sculk.handle_death(pos, xp_amount)
	if not pos or not xp_amount then return end
	return spread_sculk (pos, xp_amount)
end

core.register_on_dieplayer(function(player)
	mcl_sculk.handle_death(player:get_pos(), 5)
end)

core.register_node("mcl_sculk:sculk", {
	description = S("Sculk"),
	tiles = {
		{ name = "mcl_sculk_sculk.png",
		animation = {
			type = "vertical_frames",
			aspect_w = 16,
			aspect_h = 16,
			length = 3.0,
		}, },
	},
	drop = "",
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1, unmovable_by_piston = 1},
	place_param2 = 1,
	sounds = sounds,
	is_ground_content = false,
	after_dig_node = sculk_after_dig_node,
	_mcl_blast_resistance = 0.2,
	_mcl_hardness = 0.6,
	_mcl_silk_touch_drop = true,
})

core.register_node("mcl_sculk:vein", {
	description = S("Sculk Vein"),
	_doc_items_longdesc = S("Sculk vein."),
	drawtype = "signlike",
	tiles = {"mcl_sculk_vein.png"},
	inventory_image = "mcl_sculk_vein.png",
	wield_image = "mcl_sculk_vein.png",
	paramtype = "light",
	sunlight_propagates = true,
	paramtype2 = "wallmounted",
	walkable = false,
	climbable = true,
	buildable_to = true,
	selection_box = {
		type = "wallmounted",
	},
	groups = {
		handy = 1, axey = 1, shearsy = 1, swordy = 1, deco_block = 1,
		dig_by_piston = 1, destroy_by_lava_flow = 1, sculk = 1, dig_by_water = 1,
	},
	sounds = sounds,
	drop = "",
	_mcl_shears_drop = true,
	node_placement_prediction = "",
	_mcl_hardness = 0.2,
	on_rotate = false,
})

core.register_node("mcl_sculk:catalyst", {
	description = S("Sculk Catalyst"),
	tiles = {
		"mcl_sculk_catalyst_top.png",
		"mcl_sculk_catalyst_bottom.png",
		"mcl_sculk_catalyst_side.png"
	},
	drop = "",
	sounds = sounds,
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1, unmovable_by_piston = 1},
	place_param2 = 1,
	is_ground_content = false,
	after_dig_node = sculk_after_dig_node,
	light_source  = 6,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})

--[[
core.register_node("mcl_sculk:sensor", {
	description = S("Sculk Sensor"),
	tiles = {
		"mcl_sculk_sensor_top.png",
		"mcl_sculk_sensor_bottom.png",
		"mcl_sculk_sensor_side.png"
	},
	drop = "",
	sounds = sounds,
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 1,
	is_ground_content = false,
	after_dig_node = sculk_after_dig_node,
	light_source  = 1,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})
core.register_node("mcl_sculk:shrieker", {
	description = S("Sculk Shrieker"),
	tiles = {
		"mcl_sculk_shrieker_top.png",
		"mcl_sculk_shrieker_bottom.png",
		"mcl_sculk_shrieker_side.png"
	},
	drop = "",
	sounds = sounds,
	groups = {handy = 1, hoey = 1, building_block=1, sculk = 1,},
	place_param2 = 0,
	is_ground_content = false,
	after_dig_node = sculk_after_dig_node,
	light_source  = 0,
	_mcl_hardness = 3,
	_mcl_silk_touch_drop = true,
})
--]]

core.register_craftitem("mcl_sculk:echo_shard", {
	description = S("Echo Shard"),
	groups = {craftitem = 1, rarity = 1},
	inventory_image = "mcl_sculk_echo_shard.png",
	wield_image = "mcl_sculk_echo_shard.png"
})

local modpath = core.get_modpath (core.get_current_modname ())
mcl_levelgen.register_levelgen_script (modpath .. "/lg_register.lua")

