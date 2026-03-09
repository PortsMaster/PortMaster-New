local modname = core.get_current_modname()
local S = core.get_translator(modname)
local D = mcl_util.get_dynamic_translator(modname)

local SHIELD_BLOCK_ARC = 180 -- A shield's effective arc in degree. 180 degrees equals frontal half.
local SHIELD_BLOCK_COSINE = -math.cos(SHIELD_BLOCK_ARC/2) -- Actual value for angle check.

-- XXX: Adapted from creative.lua.
local function is_touch_enabled(player)
	local name = player:get_player_name()
	local window = core.get_player_window_information(name)
	return window and window.touch_controls
end

mcl_shields = {
	types = {
		mob = true,
		player = true,
		arrow = true,
		generic = true,
		explosion = true,
		dragon_breath = true,
		trident = true,
	},
	enchantments = {"mending", "unbreaking"},
	players = {},
}

local interact_priv = core.registered_privileges.interact
interact_priv.give_to_singleplayer = false
interact_priv.give_to_admin = false

local overlay = mcl_enchanting.overlay
local hud = "mcl_shield_hud.png"

local shield_disables = {}

core.register_tool("mcl_shields:shield", {
	description = S("Shield"),
	_doc_items_longdesc = S("A shield is a tool used for protecting the player against attacks."),
	inventory_image = "mcl_shield_48.png",
	stack_max = 1,
	groups = {
		shield = 1,
		weapon = 2,
		enchantability = -1,
		offhand_item = 1,
	},
	sound = {breaks = "default_tool_breaks"},
	_repair_material = "group:wood",
	wield_scale = vector.new(2, 2, 2),
	_mcl_wieldview_item = "",
	_placement_class = "shield",
	_mcl_uses = 336
})

local function wielded_item(obj, i)
	local itemstack = obj:get_wielded_item()
	if i == 1 then
		itemstack = mcl_offhand.get_offhand(obj)
	end
	return itemstack:get_name(), itemstack
end

local function set_wielded_item(player, stack, i)
	if i ~= 1 then
		player:set_wielded_item(stack)
	else
		mcl_offhand.set_offhand(player, stack)
	end
end

function mcl_shields.wielding_shield(obj, i)
	return wielded_item(obj, i):find("mcl_shields:shield")
end

local function shield_is_enchanted(obj, i)
	return mcl_enchanting.is_enchanted(wielded_item(obj, i))
end

local rgb_to_unicolor

local function migrate_custom_shield_texture(texture)
	-- Build colour mapping, required to parse layer info from old texture
	if not rgb_to_unicolor then
		rgb_to_unicolor = {}
		for _, v in pairs( mcl_dyes.colors ) do
			rgb_to_unicolor[v.rgb:lower()] = v.unicolor
		end
	end
	-- Rebuild layers from texture.
	-- Example: (mcl_shield_base_nopattern.png^mcl_shield_pattern_base.png^[mask:mcl_shield_base_nopattern.png^mcl_shield_pattern_base.png)^((mcl_shield_base_nopattern.png^mcl_shield_pattern_base.png^[colorize:#f1b216:224)^[mask:mcl_shield_pattern_base.png)^((mcl_shield_pattern_rhombus.png^[colorize:#912222:255)^[mask:mcl_shield_pattern_rhombus.png)^((mcl_shield_pattern_globe.png^[colorize:#60ac19:255)^[mask:mcl_shield_pattern_globe.png)
	local layers = {}
	for layer in texture:gmatch("mcl_shield_pattern_([%w_]+%.png%^%[colorize:#[%w]+)") do
		-- layer = base.png^[colorize:#f1b216, rhombus.png^[colorize:#912222, globe.png^[colorize:#60ac19
		local i,j = layer:find( "%.png%^%[colorize:" )
		local pattern, colour = layer:sub(1, i-1), layer:sub(j+1):lower()
		if pattern ~= "base" then -- Base colour already coded in itemstring, only need layers.
			if not rgb_to_unicolor[colour] then
				core.log("warning", "Cannot migrate old shield banner pattern: "..colour.." not found in dye")
				return nil
			end
			table.insert(layers, { color = "unicolor_"..rgb_to_unicolor[colour], pattern = pattern } )
		end
	end
	return layers
end

local shield_texture_builder = {
	-- luacheck will flag this style of "function table" as non-standard global hence add an exception
	blank = function() return shield_texture_builder.combine("mcl_banners_banner_base.png","") end, -- luacheck: globals shield_texture_builder
	base = function (rgb, ratio)
		local banner = "mcl_banners_banner_base.png"
		if rgb then banner = "(" .. banner .. "^[colorize:"..rgb..":"..ratio .. ")" end
		return banner -- Passed as "base" in combine()
	end,
	combine = function (base, layers)
		local escape = mcl_banners.escape_texture
		-- Enlarge base texture for banner placement.  Banner patterns need to be resized and offset to leave only front.
		local shield = "[combine:128x128:0,0=mcl_shield_base_nopattern.png\\^[resize\\:128x128"
		return shield .. ":4,4=" .. escape("[combine:20x40:-1,-1=" .. escape(base .. layers .."^[resize:64x64"))
	end,
}

local function set_shield_layers(itemstack, layers)
	if not itemstack then return end
	local itemname, meta = itemstack:get_name(), itemstack:get_meta()
	local def = core.registered_items[itemname]
	if not meta or not def or not def._shield_color_key then return end
	local b, base_colour = mcl_banners, def._shield_color_key

	if layers and #layers > 0 then mcl_banners.write_layers(meta, layers) end
	b.update_description(itemstack)

	local item_image = b.make_banner_texture(base_colour, layers, "item")
	item_image = item_image:gsub("mcl_banners_item_base_48.png", "mcl_shield_48.png")
	meta:set_string("inventory_overlay", item_image)

	local texture = b.make_banner_texture(base_colour, layers, shield_texture_builder)
	meta:set_string("mcl_shields:banner_texture", texture)
	return texture
end

core.register_entity("mcl_shields:shield_entity", {
	initial_properties = {
		visual = "mesh",
		mesh = "mcl_shield.obj",
		physical = false,
		pointable = false,
		collide_with_objects = false,
		textures = {"mcl_shield_base_nopattern.png"},
		visual_size = vector.new(1, 1, 1),
	},
	_blocking = false,
	_shield_number = 2,
	_texture_copy = "",
	on_step = function(self, _, _)
		local player = self.object:get_attach()
		if not player then
			self.object:remove()
			return
		end
		local shield_texture = "mcl_shield_base_nopattern.png"
		local i = self._shield_number
		local item, itemstack = wielded_item(player, i)

		if item ~= "mcl_shields:shield" and item ~= "mcl_shields:shield_enchanted" then -- Bannered shield?
			local meta = itemstack:get_meta()
			local meta_texture = meta:get_string("mcl_shields:banner_texture")
			if meta_texture and meta_texture ~= "" then
				shield_texture = meta_texture
			else
				local layers
				meta:set_string("wield_overlay", "") -- Clear inner face (wield_texture) to show raw shield.
				local custom_texture = meta:get_string("mcl_shields:shield_custom_pattern_texture")
				if custom_texture and custom_texture ~= "" then -- Parse layers from custom standalone pattern texture.
					shield_texture = custom_texture
					layers = migrate_custom_shield_texture(custom_texture) -- May be nil
					if layers then -- Item image would be broken on downgrade anyway, may as well remove old cache.
						meta:set_string("mcl_shields:shield_custom_pattern_texture", nil)
					end
				else
					layers = mcl_banners.read_layers(meta) -- Non-nil
				end
				if layers then
					local texture = set_shield_layers(itemstack, layers)
					if texture then
						shield_texture = texture
					end
				end
				meta:set_string("mcl_shields:banner_texture", shield_texture)
				set_wielded_item(player, itemstack, i)
			end
		end

		if shield_is_enchanted(player, i) then
			shield_texture = shield_texture .. overlay
		end

		if self._texture_copy ~= shield_texture then
			self.object:set_properties({textures = {shield_texture}})
			self._texture_copy = shield_texture
		end
	end,
})

for _, e in pairs(mcl_shields.enchantments) do
	mcl_enchanting.enchantments[e].secondary.shield = true
end

local shield_disable_duration = 5
function mcl_shields.disable_player_shield(player)
	shield_disables[player] = shield_disable_duration
	if mcl_serverplayer.is_csm_at_least (player, 10) then
		mcl_serverplayer.send_shieldctrl (player, shield_disable_duration)
	end
	core.sound_play("default_tool_breaks", {object = player}, true)
end

-- Check if a player is holding up his/her shield.
-- Return nil if no shield or shield is not raised.
-- Otherwise return shield hand (1 = offhand, 2 = mainhand), shield itemstack
function mcl_shields.is_blocking(obj)
	if not obj or not obj:is_player() then return end
	if shield_disables[obj] then return end
	if mcl_shields.players[obj] then
		local blocking = mcl_shields.players[obj].blocking
		if blocking <= 0 then return end
		local _, shieldstack = wielded_item(obj, blocking)
		return blocking, shieldstack
	end
end

-- Find attack angle relative to a player's position, height, and view angle.
-- Return the dot product of normalised attack vector and normalised view vector.
-- -1 means the attack is at the center of view.  -0.7 or -cos(45°) means attack is at a frontal 45 degree.
-- 0 means exactly perpendicular (side/top/bottom). >0 means it come from the rear.
function mcl_shields.find_angle (attack_pos, obj)
	if not attack_pos then return end
	local obj_pos = obj:get_pos()
	obj_pos.y = obj_pos.y + ( obj:get_properties().eye_height * 2/3 ) -- Loose approximation of shield centre.
	local attack_direction = vector.normalize(vector.subtract(obj_pos, attack_pos))
	local player_look_dir = vector.normalize(obj:get_look_dir())
	return vector.dot(attack_direction, player_look_dir)
end

-- Check whether the player can block an attack at this moment.
-- obj is player.  dpos_or_dot can be the attack position OR angle of attack (see find_angle).
-- if reason is not null, the type of attack will be checked.
-- if dpos/dot is provided, or deducible from reason, attack angle will be checked.
-- When attack is not blockable, return false and reason (string)
-- When attack is bloackable, return true, {blocking,itemstack}, is_angle_checked.
function mcl_shields.can_block (obj, dpos_or_dot, reason)
	if not obj or not obj:is_player() then return false, "non-player" end

	if shield_disables[obj] then return false, "shield-disabled" end

	local blocking, shieldstack = mcl_shields.is_blocking(obj)
	if not blocking then return false, "no-shield" end

	if reason then
		local type = reason.type
		if not mcl_shields.types[type] then return false, "non-blockable" end
		if not dpos_or_dot then
			local damager = reason.direct
			local entity = damager and damager:get_luaentity()
			if entity then
				if entity._shooter then
					damager = entity._shooter
				elseif entity._saved_shooter_pos then
					-- Used for removed / killed entities before the projectile hits the player
					dpos_or_dot = entity._saved_shooter_pos
				end
			end
			damager = damager and damager.is_valid and damager:is_valid() and damager
			if not dpos_or_dot and damager then
				dpos_or_dot = damager:get_pos()
			end
		end
	end

	if dpos_or_dot then
		local angle
		if type(dpos_or_dot) == "number" then
			angle = dpos_or_dot
		else
			angle = mcl_shields.find_angle(dpos_or_dot, obj)
		end
		if angle > SHIELD_BLOCK_COSINE then return false, "non-frontal" end
	end

	return true, { blocking, shieldstack }, dpos_or_dot
end

-- Add wear to a player's active shield.
-- If damage is provided, will not add wear if damage is below threshold.
-- blockstack is usually returned by can_block, and can be nil.
-- Shield state will be checked regardless of whether it is provided or not.
-- n is number of use to reduce, default 1.
-- When wear is not reduced, return false and reason (string).
-- Otherwise return true.
function mcl_shields.add_wear (obj, damage, blockstack, n)
	if not obj or not obj:is_player() then return false, "non-player" end
	if not core.is_creative_enabled(obj:get_player_name()) then return false, "creative" end

	if damage and damage < 3 then return false, "threshold" end
	if n and n <= 0 then return false, "use-count" end

	local blocking, shieldstack
	if blockstack then
		blocking, shieldstack = blockstack[0], blockstack[1]
	else
		blocking, shieldstack = mcl_shields.is_blocking(obj)
	end
	if not blocking then return false, "no-shield" end

	local durability = 336
	local unbreaking = mcl_enchanting.get_enchantment(shieldstack, mcl_shields.enchantments[2])
	if unbreaking > 0 then
		durability = durability * (unbreaking + 1)
	end

	shieldstack:add_wear(65535 / durability * (n or 1))
	if blocking == 2 then
		obj:set_wielded_item(shieldstack)
	else
		obj:get_inventory():set_stack("offhand", 1, shieldstack)
		mcl_inventory.update_inventory_formspec(obj)
	end
	return true
end

mcl_damage.register_modifier(function(obj, damage, reason)
	local can_block, stack, dpos = mcl_shields.can_block (obj, nil, reason)
	if can_block and dpos then
		local wielded_item = mcl_util.get_wielditem(reason.direct)
		if core.get_item_group(wielded_item:get_name(), "axe") > 0 then
			mcl_shields.disable_player_shield(obj)
		end
		mcl_shields.add_wear(obj, damage, stack)
		local direct = reason.direct
		if direct then
			local entity = direct:get_luaentity ()
			if entity and entity.is_mob and obj:is_valid () then
				entity:shield_impact (obj, reason)
			end
		end
		core.sound_play({name = "mcl_block"}, {pos = obj:get_pos(), max_hear_distance = 16})
		return 0
	end
end)

local function modify_shield(player, vpos, vrot, i)
	local arm = "Right"
	if i == 1 then
		arm = "Left"
	end
	local shield = mcl_shields.players[player].shields[i]
	if shield then
		shield:set_attach(player, "Arm_" .. arm, vpos, vrot, false)
	end
end

local function set_shield(player, block, i)
	if block then
		if i == 1 then
			modify_shield(player, vector.new(-9, 4, 0.5), vector.new(80, 100, 0), i) -- TODO
		else
			modify_shield(player, vector.new(-8, 4, -2.5), vector.new(80, 80, 0), i)
		end
	else
		if i == 1 then
			modify_shield(player, vector.new(-3, -5, 0), vector.new(0, 180, 0), i)
		else
			modify_shield(player, vector.new(3, -5, 0), vector.new(0, 0, 0), i)
		end
	end
	local shield = mcl_shields.players[player].shields[i]
	if not shield then return end

	local luaentity = shield:get_luaentity()
	if not luaentity then return end

	luaentity._blocking = block
end

local function set_interact(player, interact)
	local player_name = player:get_player_name()
	local privs = core.get_player_privs(player_name)
	if privs.interact == interact then
		return
	end
	local meta = player:get_meta()

	if interact and meta:get_int("mcl_shields:interact_revoked") ~= 0 then
		meta:set_int("mcl_shields:interact_revoked", 0)
		privs.interact = true
	elseif not interact then
		meta:set_int("mcl_shields:interact_revoked", privs.interact and 1 or 0)
		privs.interact = nil
	end

	core.set_player_privs(player_name, privs)
end

-- Prevent player from being able to circumvent interact privilage removal by
-- using shield.
core.register_on_priv_revoke(function(name, revoker, priv)
	if priv == "interact" and revoker then
		local player = core.get_player_by_name(name)
		if not player then
			return
		end
		local meta = player:get_meta()
		meta:set_int("mcl_shields:interact_revoked", 0)
	end
end)

local shield_hud = {}

local function remove_shield_hud(player)
	set_interact(player, true)
	playerphysics.remove_physics_factor(player, "speed", "shield_speed")

	player:hud_remove(shield_hud[player])
	shield_hud[player] = nil
	set_shield(player, false, 1)
	set_shield(player, false, 2)

	local hf = player:hud_get_flags()
	if not hf.wielditem then
		player:hud_set_flags({wielditem = true})
	end
end

local function add_shield_entity(player, i)
	local shield = core.add_entity(player:get_pos(), "mcl_shields:shield_entity")
	if shield and shield:get_pos() then
		shield:get_luaentity()._shield_number = i
		mcl_shields.players[player].shields[i] = shield
		set_shield(player, false, i)
	end
end

local function remove_shield_entity(player, i)
	local shields = mcl_shields.players[player].shields
	if shields[i] then
		shields[i]:remove()
		shields[i] = nil
	end
end

local function is_node_stack(itemstack)
	return itemstack:get_definition().drawtype -- only node's definition table contains element "drawtype"
end

local function is_rmb_conflicting_node(nodename)
	local nodedef = core.registered_nodes[nodename]
	return nodedef and nodedef.on_rightclick
end

function mcl_shields.set_blocking (player, blocking)
	local player_shield = mcl_shields.players[player]
	if player_shield then
		player_shield.blocking = blocking
	end
end

local function handle_blocking(player)
	local player_shield = mcl_shields.players[player]
	if not player_shield then return end

	if mcl_serverplayer.is_csm_at_least (player, 1) then
		local shield_in_offhand
			= mcl_shields.wielding_shield (player, 1)
		local shield_in_hand
			= mcl_shields.wielding_shield (player)
		if not shield_in_hand and not shield_in_offhand then
			player_shield.blocking = 0
		end
		return
	end

	-- XXX: This currently assumes that players using touch screen
	-- devices do not use a physical mouse.
	local has_touchscreen = is_touch_enabled(player)
	local control = player:get_player_control()
	local should_clear_block =
		(not has_touchscreen and not control.RMB) or -- desktop
		(has_touchscreen and not control.sneak)	     -- mobile
	if should_clear_block then
		if player_shield.blocking ~= 0 then
			mcl_serverplayer.handle_blocking (player, 0)
		end
		player_shield.blocking = 0
		return
	end

	local pointed_thing = mcl_util.get_pointed_thing(player, true)
	local wielded_stack = player:get_wielded_item()
	if pointed_thing and pointed_thing.type == "node" then
		local pointed_node = core.get_node(pointed_thing.under)
		if core.get_item_group(pointed_node.name, "container") > 1
		or is_rmb_conflicting_node(pointed_node.name)
		or is_node_stack(wielded_stack)
		then
			return
		end
	end
	if pointed_thing and pointed_thing.type == "object" then
		local ent = pointed_thing.ref:get_luaentity()
		if ent then
			local def = core.registered_entities[ent.name]
			if def.on_rightclick and not def._unplaceable_by_default then
				return
			end
		end
	end

	local shield_in_offhand = mcl_shields.wielding_shield(player, 1)
	local shield_in_hand = mcl_shields.wielding_shield(player)
	local not_blocking = player_shield.blocking == 0

	if shield_in_hand then
		if not_blocking then
			core.after(0.05, function()
				if (not_blocking or not shield_in_offhand) and shield_in_hand then
					if player_shield.blocking ~= 2 then
						mcl_serverplayer.handle_blocking (player, 2)
					end
					player_shield.blocking = 2
					set_shield(player, true, 2)
				end
			end)
		elseif not shield_in_offhand then
			player_shield.blocking = 2
			if player_shield.blocking ~= 2 then
				mcl_serverplayer.handle_blocking (player, 2)
			end
		end
	elseif shield_in_offhand then -- usual case for blocking
		local offhand_can_block =
			(core.get_item_group(wielded_item(player), "bow") ~= 1
			 and core.get_item_group(wielded_item(player), "crossbow") ~= 1)
		if not offhand_can_block then
			return
		end
		local want_block =
			(not has_touchscreen and control.RMB) or -- desktop
			(has_touchscreen and control.sneak)	 -- mobile
		if not_blocking then
			core.after(0.05, function()
				if (not_blocking or not shield_in_hand) and shield_in_offhand and want_block and offhand_can_block then
					if player_shield.blocking ~= 1 then
						mcl_serverplayer.handle_blocking (player, 1)
					end
					player_shield.blocking = 1
					set_shield(player, true, 1)
				end
			end)
		elseif not shield_in_hand then
			if player_shield.blocking ~= 1 then
				mcl_serverplayer.handle_blocking (player, 1)
			end
			player_shield.blocking = 1
		end
	else			-- not holding any shield
		if player_shield.blocking ~= 0 then
			mcl_serverplayer.handle_blocking (player, 0)
		end
		player_shield.blocking = 0
	end
end

local function update_shield_entity(player, blocking, i)
	local shield = mcl_shields.players[player].shields[i]
	if mcl_shields.wielding_shield(player, i) then
		if not shield then
			add_shield_entity(player, i)
		else
			if blocking == i then
				if shield:get_luaentity() and not shield:get_luaentity()._blocking then
					set_shield(player, true, i)
				end
			else
				set_shield(player, false, i)
			end
		end
	elseif shield then
		remove_shield_entity(player, i)
	end
end

local function add_shield_hud(shieldstack, player, blocking)
	local texture = hud
	if mcl_enchanting.is_enchanted(shieldstack:get_name()) then
		texture = texture .. overlay
	end
	local offset = 100
	if blocking == 1 then
		texture = texture .. "^[transform4"
		offset = -100
	else
		player:hud_set_flags({wielditem = false})
	end
	shield_hud[player] = player:hud_add({
		type = "image",
		position = {x = 0.5, y = 0.5},
		scale = {x = -101, y = -101},
		offset = {x = offset, y = 0},
		text = texture,
		z_index = -200,
	})
	playerphysics.add_physics_factor(player, "speed", "shield_speed", 0.5)
	set_interact(player, false)
end

local function update_shield_hud(player, blocking, shieldstack)
	local shieldhud = shield_hud[player]
	if not shieldhud then
		add_shield_hud(shieldstack, player, blocking)
		return
	end

	local wielditem = player:hud_get_flags().wielditem
	if blocking == 1 then
		if not wielditem then
			player:hud_change(shieldhud, "text", hud .. "^[transform4")
			player:hud_change(shieldhud, "offset", {x = -100, y = 0})
			player:hud_set_flags({wielditem = true})
		end
	elseif wielditem then
		player:hud_change(shieldhud, "text", hud)
		player:hud_change(shieldhud, "offset", {x = 100, y = 0})
		player:hud_set_flags({wielditem = false})
	end

	local image = player:hud_get(shieldhud).text
	local enchanted = hud .. overlay
	local enchanted1 = image == enchanted
	local enchanted2 = image == enchanted .. "^[transform4"
	if mcl_enchanting.is_enchanted(shieldstack:get_name()) then
		if not enchanted1 and not enchanted2 then
			if blocking == 1 then
				player:hud_change(shieldhud, "text", hud .. overlay .. "^[transform4")
			else
				player:hud_change(shieldhud, "text", hud .. overlay)
			end
		end
	elseif enchanted1 or enchanted2 then
		if blocking == 1 then
			player:hud_change(shieldhud, "text", hud .. "^[transform4")
		else
			player:hud_change(shieldhud, "text", hud)
		end
	end
end

mcl_player.register_globalstep(function(player, dtime)
	handle_blocking(player)

	if shield_disables[player] then
		shield_disables[player] = shield_disables[player] - dtime
		if shield_disables[player] <= 0 then
			shield_disables[player] = nil
		end
	end

	local blocking, shieldstack = mcl_shields.is_blocking(player)

	if blocking then
		update_shield_hud(player, blocking, shieldstack)
	elseif shield_hud[player] then --this function takes a long time. only run it when necessary
		remove_shield_hud(player)
	end

	for i = 1, 2 do
		update_shield_entity(player, blocking, i)
	end
end)

core.register_on_dieplayer(function(player)
	set_interact(player, true)
	playerphysics.remove_physics_factor(player, "speed", "shield_speed")
	if not core.settings:get_bool("mcl_keepInventory") then
		remove_shield_entity(player, 1)
		remove_shield_entity(player, 2)
	end
end)

core.register_on_leaveplayer(function(player)
	shield_hud[player] = nil
	mcl_shields.players[player] = nil
end)

core.register_craft({
	output = "mcl_shields:shield",
	recipe = {
		{"group:wood", "mcl_core:iron_ingot", "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
		{"", "group:wood", ""},
	}
})

for colorkey, colortab in pairs(mcl_banners.colors) do
	local color = colortab.color_key
	core.register_tool("mcl_shields:shield_" .. color, {
		description = D(colortab.color_name.." Shield"), -- "Purple Shield"
		_doc_items_longdesc = S("A shield is a tool used for protecting the player against attacks."),
		inventory_image = "mcl_shield_48.png^(mcl_banners_item_overlay_48.png^[colorize:" .. colortab.rgb ..")",
		wield_image = "mcl_shield_48.png",
		stack_max = 1,
		groups = {
			shield = 1,
			weapon = 1,
			enchantability = -1,
			not_in_creative_inventory = 1,
			offhand_item = 1,
		},
		sound = {breaks = "default_tool_breaks"},
		_repair_material = "group:wood",
		wield_scale = vector.new(2, 2, 2),
		_placement_class = "shield",
		_shield_color_key = colorkey,
		_mcl_wieldview_item = "",
		_mcl_generate_description = mcl_banners.update_description,
		_on_set_item_entity = function (stack)
			local meta = stack:get_meta()
			meta:set_string("mcl_shields:banner_texture", "") -- Force texture rebuild to clear wield texture.
			local pattern = meta:get_string("inventory_overlay")
			if pattern and pattern ~= "" then
				meta:set_string("wield_overlay", pattern) -- Set texture of dropped item.
			end
			return stack, {wield_item = stack:to_string()}
		end,
	})

	local banner = "mcl_banners:banner_item_" .. color
	core.register_craft({
		type = "shapeless",
		output = "mcl_shields:shield_" .. color,
		recipe = {"mcl_shields:shield", banner},
	})
	core.register_craft({
		type = "shapeless",
		output = "mcl_shields:shield_" .. color .. "_enchanted",
		recipe = {"mcl_shields:shield_enchanted", banner},
	})
end

local function craft_banner_on_shield(itemstack, player, old_craft_grid, _)
	if not string.find(itemstack:get_name(), "^mcl_shields:shield_") then
		return
	end

	local shield_stack, banner_stack
	for i = 1, player:get_inventory():get_size("craft") do
		local stack = old_craft_grid[i]
		local name = stack:get_name()
		if name ~= "" then
			if core.get_item_group(name, "shield") > 0 then
				if shield_stack then return end
				shield_stack = stack
			elseif core.get_item_group(name, "banner") > 0 then
				if banner_stack then return end
				banner_stack = stack
			else
				return
			end
			if shield_stack and banner_stack then break end
		end
	end
	if not shield_stack or not banner_stack then return end

	local b, e = mcl_banners, mcl_enchanting
	local banner_meta = banner_stack:get_meta()
	local layers = b.read_layers(banner_meta)
	if #layers > b.max_craftable_layers then
		return ItemStack("") -- Too many layers to be placed on a shield.
	end

	-- Data copy
	local item_meta, shield_meta = itemstack:get_meta(), shield_stack:get_meta()
	local banner_name, shield_name = banner_meta:get_string("name"), shield_meta:get_string("name")
	if shield_name and shield_name ~= "" then
		item_meta:set_string("name", shield_name)
	elseif banner_name and banner_name ~= "" then
		item_meta:set_string("name", banner_name)
	end
	if e.is_enchanted(shield_stack:get_name()) then
		e.set_enchantments(itemstack, e.get_enchantments(shield_stack))
	end
	set_shield_layers(itemstack, layers)
	itemstack:set_wear(shield_stack:get_wear())
end

core.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
	return craft_banner_on_shield(itemstack, player, old_craft_grid, craft_inv)
end)

core.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	return craft_banner_on_shield(itemstack, player, old_craft_grid, craft_inv)
end)

core.register_on_joinplayer(function(player)
	mcl_shields.players[player] = {
		shields = {},
		blocking = 0,
	}
	set_interact(player, true)
	playerphysics.remove_physics_factor(player, "speed", "shield_speed")
end)
