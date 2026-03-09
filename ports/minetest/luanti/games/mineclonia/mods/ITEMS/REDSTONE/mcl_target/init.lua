mcl_target = {}

local S = core.get_translator("mcl_target")
local ERROR_MARGIN = 0.08
local FACE_RADIUS = 0.5
local ACHIEVEMENT_DISTANCE = 30

local function project_to_face(vec)
	local ax, ay, az = math.abs(vec.x), math.abs(vec.y), math.abs(vec.z)
	if ax > ay and ax > az then
		return vec.z, vec.y
	elseif ay > ax and ay > az then
		return vec.x, vec.z
	else
		return vec.x, vec.y
	end
end

local function calculate_signal(dist)
	local raw = 30 * (FACE_RADIUS - dist + ERROR_MARGIN)
	return math.floor(math.max(1, math.min(15, raw)))
end

local function calculate_dist(dx, dy)
	return math.sqrt(dx * dx + dy * dy)
end

local function check_achievement(pos, arrow, signal)
	if not arrow then return end
	local shooter = arrow._shooter
	if signal ~= 15 or not (shooter and shooter:is_player()) then
		return
	end
	local shooter_pos = shooter:get_pos()
	local rel = vector.subtract(shooter_pos, pos)
	local dist = calculate_dist(rel.x, rel.z)
	if math.floor(dist) >= ACHIEVEMENT_DISTANCE then
		awards.unlock(shooter:get_player_name(), "mcl:bullseye")
	end
end

function mcl_target.hit(pos, arrow)
	local arrow_pos = arrow and arrow.object and arrow.object:get_pos() or pos
	local rel = vector.subtract(arrow_pos, pos)
	local dx, dy = project_to_face(rel)
	local dist = calculate_dist(dx, dy)
	local signal = calculate_signal(dist)
	mcl_redstone.swap_node(pos, {name = "mcl_target:target_on", param2 = signal})
	core.get_node_timer(pos):start(1)
	check_achievement(pos, arrow, signal)
end

local commdef = {
	_mcl_hardness = 0.5,
	_mcl_redstone = {
		connects_to = function() return true end
	},
	description = S("Target"),
	groups = {hoey = 1},
	sounds = mcl_sounds.node_sound_dirt_defaults({
		footstep = {gain = 0.1, name = "default_grass_footstep"}
	}),
	tiles = {
		"mcl_target_target_top.png", "mcl_target_target_top.png", "mcl_target_target_side.png"
	}
}

core.register_node("mcl_target:target_off", table.merge(commdef, {
	_doc_items_longdesc = S("A target is a block that provides a temporary redstone charge when hit by a projectile."),
	_doc_items_usagehelp = S("Throw a projectile on the target to activate it."),
	_on_arrow_hit = function(pos, arrow) mcl_target.hit(pos, arrow) end
}))

core.register_node("mcl_target:target_on", table.merge(commdef, {
	_doc_items_create_entry = false,
	_mcl_redstone = table.merge(commdef._mcl_redstone, {
		get_power = function(node) return node.param2, false end
	}),
	drop = "mcl_target:target_off",
	groups = table.merge(commdef.groups, {not_in_creative_inventory = 1}),
	on_timer = function(pos, _)
		local node = core.get_node(pos)
		if node.name == "mcl_target:target_on" then
			core.set_node(pos, {name = "mcl_target:target_off", param2 = 0})
		end
	end
}))

core.register_craft({
	output = "mcl_target:target_off",
	recipe = {
		{"", "mcl_redstone:redstone", ""},
		{"mcl_redstone:redstone", "mcl_farming:hay_block", "mcl_redstone:redstone"},
		{"", "mcl_redstone:redstone", ""}
	}
})
