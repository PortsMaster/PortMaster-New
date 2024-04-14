local S = minetest.get_translator(minetest.get_current_modname())

local PISTON_MAXIMUM_PUSH = 12

--Get mesecon rules of pistons

--everything apart from z- (pusher side)
local piston_rules = {
	{x=0,  y=0,  z=1},
	{x=1,  y=0,  z=0},
	{x=-1, y=0,  z=0},
	{x=0,  y=1,  z=0},
	{x=0,  y=-1, z=0},
}

--everything apart from y+ (pusher side)
local piston_up_rules = {
	{x=0,  y=0,  z=-1},
	{x=0,  y=0,  z=1},
	{x=-1, y=0,  z=0},
	{x=1,  y=0,  z=0},
	{x=0,  y=-1, z=0},
}

--everything apart from y- (pusher side)
local piston_down_rules = {
	{x=0,  y=0,  z=-1},
	{x=0,  y=0,  z=1},
	{x=-1,  y=0,  z=0},
	{x=1,  y=0,  z=0},
	{x=0,  y=1, z=0},
}

local function piston_get_rules(node)
	local rules = piston_rules
	for i = 1, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules
end

local function piston_facedir_direction(node)
	local rules = {{x = 0, y = 0, z = -1}}
	for i = 1, node.param2 do
		rules = mesecon.rotate_rules_left(rules)
	end
	return rules[1]
end

local function piston_get_direction(dir, node)
	if type(dir) == "function" then
		return dir(node)
	else
		return dir
	end
end

-- Remove pusher of piston.
-- To be used when piston was destroyed or dug.
local function piston_remove_pusher(pos, oldnode)
	local pistonspec = minetest.registered_nodes[oldnode.name].mesecons_piston

	local dir = piston_get_direction(pistonspec.dir, oldnode)
	local pusherpos = vector.add(pos, dir)
	local pushername = minetest.get_node(pusherpos).name

	if pushername == pistonspec.pusher then -- make sure there actually is a pusher
		minetest.remove_node(pusherpos)
		minetest.check_for_falling(pusherpos)
		minetest.sound_play("piston_retract", {
			pos = pos,
			max_hear_distance = 31,
			gain = 0.3,
		}, true)
	end
end

-- Remove base node of piston.
-- To be used when pusher was destroyed.
local function piston_remove_base(pos, oldnode)
	local basenodename = minetest.registered_nodes[oldnode.name].corresponding_piston
	local pistonspec = minetest.registered_nodes[basenodename].mesecons_piston

	local dir = piston_get_direction(pistonspec.dir, oldnode)
	local basepos = vector.subtract(pos, dir)
	local basename = minetest.get_node(basepos).name

	if basename == pistonspec.onname then -- make sure there actually is a base node
		minetest.remove_node(basepos)
		minetest.check_for_falling(basepos)
		minetest.sound_play("piston_retract", {
			pos = pos,
			max_hear_distance = 31,
			gain = 0.3,
		}, true)
	end
end

local function piston_on(pos, node)
	local pistonspec = minetest.registered_nodes[node.name].mesecons_piston

	local dir = piston_get_direction(pistonspec.dir, node)
	local np = vector.add(pos, dir)
	local meta = minetest.get_meta(pos)
	local success, stack, oldstack = mesecon.mvps_push(np, dir, PISTON_MAXIMUM_PUSH, meta:get_string("owner"), pos)
	if success then
		minetest.swap_node(pos, {param2 = node.param2, name = pistonspec.onname})
		minetest.set_node(np, {param2 = node.param2, name = pistonspec.pusher})
		local below = minetest.get_node({x=np.x,y=np.y-1,z=np.z})
		if below.name == "mcl_farming:soil" or below.name == "mcl_farming:soil_wet" then
			minetest.set_node({x=np.x,y=np.y-1,z=np.z}, {name = "mcl_core:dirt"})
		end
		mesecon.mvps_process_stack(stack)
		mesecon.mvps_move_objects(np, dir, oldstack)
		minetest.sound_play("piston_extend", {
			pos = pos,
			max_hear_distance = 31,
			gain = 0.3,
		}, true)
	end
end

local function piston_off(pos, node)
	local pistonspec = minetest.registered_nodes[node.name].mesecons_piston
	minetest.swap_node(pos, {param2 = node.param2, name = pistonspec.offname})
	piston_remove_pusher (pos, node)
	if not pistonspec.sticky then
		return
	end

	local dir = piston_get_direction(pistonspec.dir, node)
	local pullpos = vector.add(pos, vector.multiply(dir, 2))
	local meta = minetest.get_meta(pos)
	local success, stack = mesecon.mvps_pull_single(pullpos, vector.multiply(dir, -1), PISTON_MAXIMUM_PUSH, meta:get_string("owner"), pos)
	if success then
		mesecon.mvps_process_stack(pos, dir, stack)
	end
end

local function piston_orientate(pos, placer)
	-- not placed by player
	if not placer then return end

	-- placer pitch in degrees
	local pitch = placer:get_look_vertical() * (180 / math.pi)

	local node = minetest.get_node(pos)
	local pistonspec = minetest.registered_nodes[node.name].mesecons_piston
	if pitch > 55 then
		minetest.add_node(pos, {name=pistonspec.piston_up})
	elseif pitch < -55 then
		minetest.add_node(pos, {name=pistonspec.piston_down})
	end

	-- set owner meta after setting node, or it will not keep
	mesecon.mvps_set_owner(pos, placer)
end


-- Horizontal pistons

local pt = 4/16 -- pusher thickness

local piston_pusher_box = {
	type = "fixed",
	fixed = {
		{-2/16, -2/16, -.5 + pt, 2/16, 2/16,  .5 + pt},
		{-.5  , -.5  , -.5     , .5  , .5  , -.5 + pt},
	},
}

local piston_on_box = {
	type = "fixed",
	fixed = {
		{-.5, -.5, -.5 + pt, .5, .5, .5}
	},
}


-- Normal (non-sticky) ones:

local pistonspec_normal = {
	offname = "mesecons_pistons:piston_normal_off",
	onname = "mesecons_pistons:piston_normal_on",
	dir = piston_facedir_direction,
	pusher = "mesecons_pistons:piston_pusher_normal",
	piston_down = "mesecons_pistons:piston_down_normal_off",
	piston_up   = "mesecons_pistons:piston_up_normal_off",
}

local usagehelp_piston = S("This block can have one of 6 possible orientations.")

-- offstate
minetest.register_node("mesecons_pistons:piston_normal_off", {
	description = S("Piston"),
	_tt_help = S("Pushes block when powered by redstone power"),
	_doc_items_longdesc = S("A piston is a redstone component with a pusher which pushes the block or blocks in front of it when it is supplied with redstone power. Not all blocks can be pushed, however."),
	_doc_items_usagehelp = usagehelp_piston,
	tiles = {
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png^[transformR90",
		"mesecons_piston_bottom.png^[transformR270",
		"mesecons_piston_back.png",
		"mesecons_piston_pusher_front.png"
	},
	groups = {handy=1, piston=1},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	after_place_node = piston_orientate,
	mesecons_piston = pistonspec_normal,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {
		effector = {
			action_on = piston_on,
			rules = piston_get_rules
		},
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	on_rotate = function(pos, node, user, mode)
		if mode == screwdriver.ROTATE_AXIS then
			minetest.set_node(pos, {name="mesecons_pistons:piston_up_normal_off"})
			return true
		end
	end,
})

-- onstate
minetest.register_node("mesecons_pistons:piston_normal_on", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png^[transformR90",
		"mesecons_piston_bottom.png^[transformR270",
		"mesecons_piston_back.png",
		"mesecons_piston_on_front.png"
	},
	groups = {handy=1, piston=1, not_in_creative_inventory=1},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = "mesecons_pistons:piston_normal_off",
	after_destruct = piston_remove_pusher,
	node_box = piston_on_box,
	selection_box = piston_on_box,
	mesecons_piston = pistonspec_normal,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {
		effector = {
			action_off = piston_off,
			rules = piston_get_rules
		},
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	on_rotate = false,
})

-- pusher
minetest.register_node("mesecons_pistons:piston_pusher_normal", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_pusher_top.png",
		"mesecons_piston_pusher_bottom.png",
		"mesecons_piston_pusher_left.png",
		"mesecons_piston_pusher_right.png",
		"mesecons_piston_pusher_back.png",
		"mesecons_piston_pusher_front.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {piston_pusher=1},
	is_ground_content = false,
	after_destruct = piston_remove_base,
	diggable = false,
	drop = "",
	corresponding_piston = "mesecons_pistons:piston_normal_on",
	selection_box = piston_pusher_box,
	node_box = piston_pusher_box,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 0.5,
	on_rotate = false,
})

-- Sticky ones

local pistonspec_sticky = {
	offname = "mesecons_pistons:piston_sticky_off",
	onname = "mesecons_pistons:piston_sticky_on",
	dir = piston_facedir_direction,
	pusher = "mesecons_pistons:piston_pusher_sticky",
	sticky = true,
	piston_down = "mesecons_pistons:piston_down_sticky_off",
	piston_up   = "mesecons_pistons:piston_up_sticky_off",
}

-- offstate
minetest.register_node("mesecons_pistons:piston_sticky_off", {
	description = S("Sticky Piston"),
	_tt_help = S("Pushes or pulls block when powered by redstone power"),
	_doc_items_longdesc = S("A sticky piston is a redstone component with a sticky pusher which can be extended and retracted. It extends when it is supplied with redstone power. When the pusher extends, it pushes the block or blocks in front of it. When it retracts, it pulls back the single block in front of it. Note that not all blocks can be pushed or pulled."),
	_doc_items_usagehelp = usagehelp_piston,

	tiles = {
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png^[transformR90",
		"mesecons_piston_bottom.png^[transformR270",
		"mesecons_piston_back.png",
		"mesecons_piston_pusher_front_sticky.png"
	},
	groups = {handy=1, piston=2},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	after_place_node = piston_orientate,
	mesecons_piston = pistonspec_sticky,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {
		effector = {
			action_on = piston_on,
			rules = piston_get_rules
		},
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	on_rotate = function(pos, node, user, mode)
		if mode == screwdriver.ROTATE_AXIS then
			minetest.set_node(pos, {name="mesecons_pistons:piston_up_sticky_off"})
			return true
		end
	end,
})

-- onstate
minetest.register_node("mesecons_pistons:piston_sticky_on", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png^[transformR90",
		"mesecons_piston_bottom.png^[transformR270",
		"mesecons_piston_back.png",
		"mesecons_piston_on_front.png"
	},
	groups = {handy=1, piston=2, not_in_creative_inventory=1},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = "mesecons_pistons:piston_sticky_off",
	after_destruct = piston_remove_pusher,
	node_box = piston_on_box,
	selection_box = piston_on_box,
	mesecons_piston = pistonspec_sticky,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {
		effector = {
			action_off = piston_off,
			rules = piston_get_rules
		},
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	on_rotate = false,
})

-- pusher
minetest.register_node("mesecons_pistons:piston_pusher_sticky", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_pusher_top.png",
		"mesecons_piston_pusher_bottom.png",
		"mesecons_piston_pusher_left.png",
		"mesecons_piston_pusher_right.png",
		"mesecons_piston_pusher_back.png",
		"mesecons_piston_pusher_front_sticky.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {piston_pusher=2},
	is_ground_content = false,
	after_destruct = piston_remove_base,
	diggable = false,
	drop = "",
	corresponding_piston = "mesecons_pistons:piston_sticky_on",
	selection_box = piston_pusher_box,
	node_box = piston_pusher_box,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 0.5,
	on_rotate = false,
})

--
--
-- UP
--
--

local piston_up_pusher_box = {
	type = "fixed",
	fixed = {
		{-2/16, -.5 - pt, -2/16, 2/16, .5 - pt, 2/16},
		{-.5  ,  .5 - pt, -.5  , .5  , .5     ,   .5},
	},
}

local piston_up_on_box = {
	type = "fixed",
	fixed = {
		{-.5, -.5, -.5 , .5, .5-pt, .5}
	},
}

-- Normal

local pistonspec_normal_up = {
	offname = "mesecons_pistons:piston_up_normal_off",
	onname = "mesecons_pistons:piston_up_normal_on",
	dir = {x = 0, y = 1, z = 0},
	pusher = "mesecons_pistons:piston_up_pusher_normal",
}

-- offstate
minetest.register_node("mesecons_pistons:piston_up_normal_off", {
	tiles = {
		"mesecons_piston_pusher_front.png",
		"mesecons_piston_back.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png",
	},
	groups = {handy=1, piston=1, not_in_creative_inventory=1},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = "mesecons_pistons:piston_normal_off",
	mesecons_piston = pistonspec_normal_up,
	mesecons = {
		effector = {
			action_on = piston_on,
			rules = piston_up_rules,
		},
	},
	sounds = mcl_sounds.node_sound_stone_defaults({
		footstep = mcl_sounds.node_sound_wood_defaults().footstep
	}),
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	on_rotate = function(pos, node, user, mode)
		if mode == screwdriver.ROTATE_AXIS then
			minetest.set_node(pos, {name="mesecons_pistons:piston_down_normal_off"})
			return true
		end
		return false
	end,
})

-- onstate
minetest.register_node("mesecons_pistons:piston_up_normal_on", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_on_front.png",
		"mesecons_piston_back.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png",
	},
	groups = {handy=1, piston_=1, not_in_creative_inventory=1},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = "mesecons_pistons:piston_normal_off",
	after_destruct = piston_remove_pusher,
	node_box = piston_up_on_box,
	selection_box = piston_up_on_box,
	mesecons_piston = pistonspec_normal_up,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {
		effector = {
			action_off = piston_off,
			rules = piston_up_rules,
		},
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	on_rotate = false,
})

-- pusher
minetest.register_node("mesecons_pistons:piston_up_pusher_normal", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_pusher_front.png",
		"mesecons_piston_pusher_back.png",
		"mesecons_piston_pusher_left.png^[transformR270",
		"mesecons_piston_pusher_right.png^[transformR90",
		"mesecons_piston_pusher_bottom.png",
		"mesecons_piston_pusher_top.png^[transformR180",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {piston_pusher=1},
	is_ground_content = false,
	after_destruct = piston_remove_base,
	diggable = false,
	drop = "",
	corresponding_piston = "mesecons_pistons:piston_up_normal_on",
	selection_box = piston_up_pusher_box,
	node_box = piston_up_pusher_box,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 0.5,
	on_rotate = false,
})



-- Sticky


local pistonspec_sticky_up = {
	offname = "mesecons_pistons:piston_up_sticky_off",
	onname = "mesecons_pistons:piston_up_sticky_on",
	dir = {x = 0, y = 1, z = 0},
	pusher = "mesecons_pistons:piston_up_pusher_sticky",
	sticky = true,
}

-- offstate
minetest.register_node("mesecons_pistons:piston_up_sticky_off", {
	tiles = {
		"mesecons_piston_pusher_front_sticky.png",
		"mesecons_piston_back.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png",
	},
	groups = {handy=1, piston=2, not_in_creative_inventory=1},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = "mesecons_pistons:piston_sticky_off",
	mesecons_piston = pistonspec_sticky_up,
	sounds = mcl_sounds.node_sound_stone_defaults({
		footstep = mcl_sounds.node_sound_wood_defaults().footstep
	}),
	mesecons = {
		effector = {
			action_on = piston_on,
			rules = piston_up_rules,
		},
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	on_rotate = function(pos, node, user, mode)
		if mode == screwdriver.ROTATE_AXIS then
			minetest.set_node(pos, {name="mesecons_pistons:piston_down_sticky_off"})
			return true
		end
		return false
	end,
})

-- onstate
minetest.register_node("mesecons_pistons:piston_up_sticky_on", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_on_front.png",
		"mesecons_piston_back.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png",
		"mesecons_piston_bottom.png",
	},
	groups = {handy=1, piston=2, not_in_creative_inventory=1},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = "mesecons_pistons:piston_sticky_off",
	after_destruct = piston_remove_pusher,
	node_box = piston_up_on_box,
	selection_box = piston_up_on_box,
	mesecons_piston = pistonspec_sticky_up,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {
		effector = {
			action_off = piston_off,
			rules = piston_up_rules,
		},
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	on_rotate = false,
})

-- pusher
minetest.register_node("mesecons_pistons:piston_up_pusher_sticky", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_pusher_front_sticky.png",
		"mesecons_piston_pusher_back.png",
		"mesecons_piston_pusher_left.png^[transformR270",
		"mesecons_piston_pusher_right.png^[transformR90",
		"mesecons_piston_pusher_bottom.png",
		"mesecons_piston_pusher_top.png^[transformR180",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {piston_pusher=2},
	is_ground_content = false,
	after_destruct = piston_remove_base,
	diggable = false,
	drop = "",
	corresponding_piston = "mesecons_pistons:piston_up_sticky_on",
	selection_box = piston_up_pusher_box,
	node_box = piston_up_pusher_box,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 0.5,
	on_rotate = false,
})

--
--
-- DOWN
--
--

local piston_down_pusher_box = {
	type = "fixed",
	fixed = {
		{-2/16, -.5 + pt, -2/16, 2/16,  .5 + pt, 2/16},
		{-.5  , -.5     , -.5  , .5  , -.5 + pt,   .5},
	},
}

local piston_down_on_box = {
	type = "fixed",
	fixed = {
		{-.5, -.5+pt, -.5 , .5, .5, .5}
	},
}



-- Normal

local pistonspec_normal_down = {
	offname = "mesecons_pistons:piston_down_normal_off",
	onname = "mesecons_pistons:piston_down_normal_on",
	dir = {x = 0, y = -1, z = 0},
	pusher = "mesecons_pistons:piston_down_pusher_normal",
}

-- offstate
minetest.register_node("mesecons_pistons:piston_down_normal_off", {
	tiles = {
		"mesecons_piston_back.png",
		"mesecons_piston_pusher_front.png",
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png^[transformR180",
	},
	groups = {handy=1, piston=1, not_in_creative_inventory=1},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = "mesecons_pistons:piston_normal_off",
	mesecons_piston = pistonspec_normal_down,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {
		effector = {
			action_on = piston_on,
			rules = piston_down_rules,
		},
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	on_rotate = function(pos, node, user, mode)
		if mode == screwdriver.ROTATE_AXIS then
			minetest.set_node(pos, {name="mesecons_pistons:piston_normal_off"})
			return true
		end
		return false
	end,
})

-- onstate
minetest.register_node("mesecons_pistons:piston_down_normal_on", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_back.png",
		"mesecons_piston_on_front.png",
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png^[transformR180",
	},
	groups = {handy=1, piston=1, not_in_creative_inventory=1},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = "mesecons_pistons:piston_normal_off",
	after_destruct = piston_remove_pusher,
	node_box = piston_down_on_box,
	selection_box = piston_down_on_box,
	mesecons_piston = pistonspec_normal_down,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {
		effector = {
			action_off = piston_off,
			rules = piston_down_rules,
		},
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	on_rotate = false,
})

-- pusher
minetest.register_node("mesecons_pistons:piston_down_pusher_normal", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_pusher_back.png",
		"mesecons_piston_pusher_front.png",
		"mesecons_piston_pusher_left.png^[transformR90",
		"mesecons_piston_pusher_right.png^[transformR270",
		"mesecons_piston_pusher_bottom.png^[transformR180",
		"mesecons_piston_pusher_top.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {piston_pusher=1},
	is_ground_content = false,
	after_destruct = piston_remove_base,
	diggable = false,
	drop = "",
	corresponding_piston = "mesecons_pistons:piston_down_normal_on",
	selection_box = piston_down_pusher_box,
	node_box = piston_down_pusher_box,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 0.5,
	on_rotate = false,
})

-- Sticky

local pistonspec_sticky_down = {
	onname = "mesecons_pistons:piston_down_sticky_on",
	offname = "mesecons_pistons:piston_down_sticky_off",
	dir = {x = 0, y = -1, z = 0},
	pusher = "mesecons_pistons:piston_down_pusher_sticky",
	sticky = true,
}

-- offstate
minetest.register_node("mesecons_pistons:piston_down_sticky_off", {
	tiles = {
		"mesecons_piston_back.png",
		"mesecons_piston_pusher_front_sticky.png",
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png^[transformR180",
	},
	groups = {handy=1, piston=2, not_in_creative_inventory = 1},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = "mesecons_pistons:piston_sticky_off",
	mesecons_piston = pistonspec_sticky_down,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {
		effector = {
			action_on = piston_on,
			rules = piston_down_rules,
		},
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	on_rotate = function(pos, node, user, mode)
		if mode == screwdriver.ROTATE_AXIS then
			minetest.set_node(pos, {name="mesecons_pistons:piston_sticky_off"})
			return true
		end
		return false
	end,
})

-- onstate
minetest.register_node("mesecons_pistons:piston_down_sticky_on", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_back.png",
		"mesecons_piston_on_front.png",
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png^[transformR180",
		"mesecons_piston_bottom.png^[transformR180",
	},
	groups = {handy=1, piston=1, not_in_creative_inventory=1},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	drop = "mesecons_pistons:piston_sticky_off",
	after_destruct = piston_remove_pusher,
	node_box = piston_down_on_box,
	selection_box = piston_down_on_box,
	mesecons_piston = pistonspec_sticky_down,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	mesecons = {
		effector = {
			action_off = piston_off,
			rules = piston_down_rules,
		},
	},
	_mcl_blast_resistance = 0.5,
	_mcl_hardness = 0.5,
	on_rotate = false,
})

-- pusher
minetest.register_node("mesecons_pistons:piston_down_pusher_sticky", {
	drawtype = "nodebox",
	tiles = {
		"mesecons_piston_pusher_back.png",
		"mesecons_piston_pusher_front_sticky.png",
		"mesecons_piston_pusher_left.png^[transformR90",
		"mesecons_piston_pusher_right.png^[transformR270",
		"mesecons_piston_pusher_bottom.png^[transformR180",
		"mesecons_piston_pusher_top.png",
	},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {piston_pusher=2},
	is_ground_content = false,
	after_destruct = piston_remove_base,
	diggable = false,
	drop = "",
	corresponding_piston = "mesecons_pistons:piston_down_sticky_on",
	selection_box = piston_down_pusher_box,
	node_box = piston_down_pusher_box,
	sounds = mcl_sounds.node_sound_wood_defaults(),
	_mcl_blast_resistance = 0.5,
	on_rotate = false,
})


mesecon.register_mvps_stopper("mesecons_pistons:piston_pusher_normal")
mesecon.register_mvps_stopper("mesecons_pistons:piston_pusher_sticky")
mesecon.register_mvps_stopper("mesecons_pistons:piston_up_pusher_normal")
mesecon.register_mvps_stopper("mesecons_pistons:piston_up_pusher_sticky")
mesecon.register_mvps_stopper("mesecons_pistons:piston_down_pusher_normal")
mesecon.register_mvps_stopper("mesecons_pistons:piston_down_pusher_sticky")
mesecon.register_mvps_stopper("mesecons_pistons:piston_normal_on")
mesecon.register_mvps_stopper("mesecons_pistons:piston_sticky_on")
mesecon.register_mvps_stopper("mesecons_pistons:piston_up_normal_on")
mesecon.register_mvps_stopper("mesecons_pistons:piston_up_sticky_on")
mesecon.register_mvps_stopper("mesecons_pistons:piston_down_normal_on")
mesecon.register_mvps_stopper("mesecons_pistons:piston_down_sticky_on")

--craft recipes
minetest.register_craft({
	output = "mesecons_pistons:piston_normal_off",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"mcl_core:cobble", "mcl_core:iron_ingot", "mcl_core:cobble"},
		{"mcl_core:cobble", "mesecons:redstone", "mcl_core:cobble"},
	},
})

minetest.register_craft({
	output = "mesecons_pistons:piston_sticky_off",
	recipe = {
		{"mcl_mobitems:slimeball"},
		{"mesecons_pistons:piston_normal_off"},
	},
})

-- Add entry aliases for the Help
if minetest.get_modpath("doc") then
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_normal_off", "nodes", "mesecons_pistons:piston_normal_on")
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_normal_off", "nodes", "mesecons_pistons:piston_up_normal_off")
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_normal_off", "nodes", "mesecons_pistons:piston_up_normal_on")
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_normal_off", "nodes", "mesecons_pistons:piston_down_normal_off")
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_normal_off", "nodes", "mesecons_pistons:piston_down_normal_on")
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_normal_off", "nodes", "mesecons_pistons:piston_pusher_normal")
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_normal_off", "nodes", "mesecons_pistons:piston_up_pusher_normal")
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_normal_off", "nodes", "mesecons_pistons:piston_down_pusher_normal")

	doc.add_entry_alias("nodes", "mesecons_pistons:piston_sticky_off", "nodes", "mesecons_pistons:piston_sticky_on")
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_sticky_off", "nodes", "mesecons_pistons:piston_up_sticky_off")
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_sticky_off", "nodes", "mesecons_pistons:piston_up_sticky_on")
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_sticky_off", "nodes", "mesecons_pistons:piston_down_sticky_off")
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_sticky_off", "nodes", "mesecons_pistons:piston_down_sticky_on")
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_sticky_off", "nodes", "mesecons_pistons:piston_pusher_sticky")
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_sticky_off", "nodes", "mesecons_pistons:piston_up_pusher_sticky")
	doc.add_entry_alias("nodes", "mesecons_pistons:piston_sticky_off", "nodes", "mesecons_pistons:piston_down_pusher_sticky")
end

