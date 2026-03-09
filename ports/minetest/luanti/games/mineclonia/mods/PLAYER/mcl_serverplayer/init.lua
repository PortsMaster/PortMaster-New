if not core.settings:get_bool("mcl_enable_csm", false) then
	local function nop() end
	mcl_serverplayer = {
		add_physics_factor = nop,
		add_status_effect = nop,
		animate_localplayer = nop,
		begin_mount = nop,
		check_movement = nop,
		get_id_of_object = nop,
		get_visual_wielditem = function(player) return player:get_wielded_item() end,
		globalstep = nop,
		handle_acknowledge_vehicle = nop,
		handle_blocking = nop,
		handle_configure_vehicle = nop,
		handle_damage = nop,
		handle_move_vehicle = nop,
		handle_movement_event = nop,
		handle_playeranim = nop,
		handle_playerpose = nop,
		handle_refuse_vehicle = nop,
		handle_turn_vehicle = nop,
		in_singleheight_pose = nop,
		init_player = nop,
		is_csm_at_least = nop,
		is_csm_capable = nop,
		is_swimming = nop,
		load_persistent_physics_factors = nop,
		maybe_correct_course = nop,
		override_pose = nop,
		post_load_model = nop,
		refresh_pose = nop,
		release_useitem = nop,
		remove_physics_factor = nop,
		remove_status_effect = nop,
		save_persistent_physics_factors = nop,
		send_ammoctrl = nop,
		send_bow_capabilities = nop,
		send_effect_ctrl = nop,
		send_knockback = nop,
		send_offhand_item = nop,
		send_player_capabilities = nop,
		send_player_vitals = nop,
		send_posectrl = nop,
		send_register_attribute_modifier = nop,
		send_register_status_effect = nop,
		send_remove_attribute_modifier = nop,
		send_remove_status_effect = nop,
		send_rescind_vehicle = nop,
		send_rocket_use = nop,
		send_shieldctrl = nop,
		send_trident_ctrl = nop,
		send_vehicle_capabilities = nop,
		send_vehicle_handoff = nop,
		send_vehicle_position = nop,
		set_depth_strider_level = nop,
		set_fall_flying_capable = nop,
		set_soul_speed_level = nop,
		sprinting_locally = nop,
		update_ammo = nop,
		update_vehicle = nop,
		update_vitals = nop,
		use_rocket = nop,
		validate_mounting = nop,
	}
	return
end

mcl_serverplayer = {}

------------------------------------------------------------------------
-- Server-client communication.
------------------------------------------------------------------------

local modchannels = {}
local client_states = {}
mcl_serverplayer.client_states = client_states

core.register_on_joinplayer (function (player)
	assert (not modchannels[player])
	local channel = "mcl_player:" .. player:get_player_name ()
	modchannels[player] = core.mod_channel_join (channel)
	client_states[player] = {
		handshake_status = "want_hello",
	}
end)

core.register_on_leaveplayer (function (player)
	assert (modchannels[player])
	modchannels[player]:leave ()
	modchannels[player] = nil
	client_states[player] = nil
end)

-----------------------------------------------------------------------
-- Modchannel message definitions.
-----------------------------------------------------------------------

local MAX_PROTO_VERSION = 10

-- Serverbound messages.
local SERVERBOUND_HELLO = 'aa'
local SERVERBOUND_PLAYERPOSE = 'ab'
local SERVERBOUND_MOVEMENT_STATE = 'ac'
local SERVERBOUND_MOVEMENT_EVENT = 'ad'
local SERVERBOUND_PLAYERANIM = 'ae'
local SERVERBOUND_DAMAGE = 'af'
local SERVERBOUND_GET_AMMO = 'ag'
local SERVERBOUND_RELEASE_USEITEM = 'ah'
local SERVERBOUND_VISUAL_WIELDITEM = 'ai'
local SERVERBOUND_ACKNOWLEDGE_VEHICLE = 'aj'
local SERVERBOUND_REFUSE_VEHICLE = 'ak'
local SERVERBOUND_MOVE_VEHICLE = 'al'
local SERVERBOUND_CONFIGURE_VEHICLE = 'am'
local SERVERBOUND_TURN_VEHICLE = 'an'
local SERVERBOUND_SHIELDCTRL = 'ao' -- Protocol version 1.
local SERVERBOUND_EAT_ITEM = 'ap'
local SERVERBOUND_RELEASE_TRIDENT_ITEM = 'aq' -- Protocol version 4.
local SERVERBOUND_DISCARD_BIOME_DATA = 'ar' -- Protocol version 6.

-- Clientbound messages.
local CLIENTBOUND_HELLO = 'AA'
local CLIENTBOUND_PLAYER_CAPABILITIES = 'AB'
local CLIENTBOUND_ROCKET_USE = 'AC'
local CLIENTBOUND_REGISTER_ATTRIBUTE_MODIFIER = 'AD'
local CLIENTBOUND_REMOVE_ATTRIBUTE_MODIFIER = 'AE'
local CLIENTBOUND_REGISTER_STATUS_EFFECT = 'AF'
local CLIENTBOUND_REMOVE_STATUS_EFFECT = 'AG'
local CLIENTBOUND_POSECTRL = 'AH'
local CLIENTBOUND_SHIELDCTRL = 'AI'
local CLIENTBOUND_AMMOCTRL = 'AJ'
local CLIENTBOUND_BOW_CAPABILITIES = 'AK'
local CLIENTBOUND_VEHICLE_HANDOFF = 'AL'
local CLIENTBOUND_VEHICLE_POSITION = 'AM'
local CLIENTBOUND_RESCIND_VEHICLE = 'AN'
local CLIENTBOUND_VEHICLE_CAPABILITIES = 'AO'
local CLIENTBOUND_KNOCKBACK = 'AP'
local CLIENTBOUND_OFFHAND_ITEM = 'AQ' -- Protocol version 1.
local CLIENTBOUND_PLAYER_VITALS = 'AR'
local CLIENTBOUND_EFFECT_CTRL = 'AS' -- Protocol version 2.
local CLIENTBOUND_TRIDENT_CTRL = 'AT' -- Protocol version 4.
local CLIENTBOUND_BIOME_DATA = 'AU' -- Protocol version 6.

local MAX_PAYLOAD = 65533

function mcl_serverplayer.send_player_capabilities (player, caps)
	local caps = core.write_json (caps)
	assert (#caps <= MAX_PAYLOAD, "oversized ClientboundPlayerCapabilities")
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_PLAYER_CAPABILITIES,
		caps,
	}))
end

function mcl_serverplayer.send_rocket_use (player, duration)
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_ROCKET_USE, duration,
	}))
end

function mcl_serverplayer.send_register_attribute_modifier (player, modifier)
	local modifier = core.write_json (modifier)
	assert (#modifier <= MAX_PAYLOAD, "oversized ClientboundRegisterAttributeModifier")
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_REGISTER_ATTRIBUTE_MODIFIER, modifier,
	}))
end

function mcl_serverplayer.send_remove_attribute_modifier (player, field, id)
	local modifier = core.write_json ({
		field = field,
		id = id,
	})
	assert (#modifier <= MAX_PAYLOAD, "oversized ClientboundRemoveAttributeModifier")
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_REMOVE_ATTRIBUTE_MODIFIER,
		modifier,
	}))
end

function mcl_serverplayer.send_register_status_effect (player, effect)
	local effect = core.write_json (effect)
	assert (#effect <= MAX_PAYLOAD, "oversized ClientboundRegisterStatusEffect")
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_REGISTER_STATUS_EFFECT,
		effect,
	}))
end

function mcl_serverplayer.send_remove_status_effect (player, id)
	assert (#id <= MAX_PAYLOAD, "oversized ClientboundRemoveStatusEffect")
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_REMOVE_STATUS_EFFECT, id,
	}))
end

function mcl_serverplayer.send_posectrl (player, override)
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_POSECTRL, override or "",
	}))
end

function mcl_serverplayer.send_shieldctrl (player, active_shield)
	-- On protocol version 0, ACTIVE_SHIELD is an integer
	-- specifying whether a shield is active.
	--
	-- On protocol version >= 10, ACTIVE_SHIELD is the number of
	-- seconds for which shields are to be disabled.
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_SHIELDCTRL, active_shield,
	}))
end

function mcl_serverplayer.send_ammoctrl (player, ammo, challenge)
	modchannels[player]:send_all (table.concat ({
		CLIENTBOUND_AMMOCTRL, ammo, ',', challenge,
	}))
end

function mcl_serverplayer.send_bow_capabilities (player, capabilities)
	local payload = core.write_json (capabilities)
	assert (#payload <= MAX_PAYLOAD, "oversized ClientboundBowCapabilities")
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_BOW_CAPABILITIES, payload,
	})
end

function mcl_serverplayer.send_vehicle_handoff (player, vehicle_type, objid)
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_VEHICLE_HANDOFF,
		vehicle_type, ",", objid,
	})
end

function mcl_serverplayer.send_vehicle_position (player, objid, pos, v)
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_VEHICLE_POSITION,
		objid, ",", pos.x, ",", pos.y, ",", pos.z,
		",", v.x, ",", v.y, ",", v.z,
	})
end

function mcl_serverplayer.send_rescind_vehicle (player, objid)
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_RESCIND_VEHICLE, objid,
	})
end

function mcl_serverplayer.send_vehicle_capabilities (player, objid, capabilities)
	capabilities.id = objid
	local payload = core.write_json (capabilities)
	assert (#payload <= MAX_PAYLOAD, "oversized ClientboundVehicleCapabilities")
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_VEHICLE_CAPABILITIES, payload,
	})
end

function mcl_serverplayer.send_knockback (player, kb)
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_KNOCKBACK, kb.x, ",", kb.y, ",", kb.z,
	})
end

function mcl_serverplayer.send_offhand_item (player, offhand_item)
	-- Remove stack's metadata.
	local stack = ItemStack (offhand_item:get_name ())
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_OFFHAND_ITEM,
		stack:to_string (),
	})
end

function mcl_serverplayer.send_player_vitals (player, hp, hunger, saturation)
	local payload = core.write_json ({
		hp = hp,
		hunger = hunger,
		saturation = saturation,
	})
	assert (#payload <= MAX_PAYLOAD, "oversized ClientboundPlayerVitals")
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_PLAYER_VITALS, payload,
	})
end

function mcl_serverplayer.send_effect_ctrl (player, tbl)
	local payload = core.write_json (tbl)
	assert (#payload <= MAX_PAYLOAD, "oversized ClientboundEffectCtrl")
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_EFFECT_CTRL, payload,
	})
end

function mcl_serverplayer.send_trident_ctrl (player, tbl)
	local payload = core.write_json (tbl)
	assert (#payload <= MAX_PAYLOAD, "oversized ClientboundTridentCtrl")
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_TRIDENT_CTRL, payload,
	})
end

function mcl_serverplayer.send_biome_data (player, index, meta)
	local payload = index .. meta

	-- The maximum size of the payload of a biome data message for
	-- a volume 7x7x7 in size is 43904 b for the metadata and 6517
	-- b for the index (= 50078 bytes), given that the largest of
	-- biome metadata strings are 4^3*2 bytes in length, and index
	-- entries comprise a 5-digit offset into the payload, a
	-- 12-digit block hash, and two delimiter characters.
	assert (#payload + 5 <= MAX_PAYLOAD,  "oversized ClientboundBiomeData")
	modchannels[player]:send_all (table.concat {
		CLIENTBOUND_BIOME_DATA,
		tostring (#index), ",", index, meta,
	})
end

-----------------------------------------------------------------------
-- Handshakes.  When a client joins, it is not considered CSM-enabled
-- till a SERVERBOUND_HELLO packet is received containing the protocol
-- version of the client.
--
-- Multiple CLIENTBOUND_HELLO messages are subsequently delivered
-- incorporating a variable length serialized handshake of the
-- following form:
--
--   {
--     proto = PROTO_VERSION,
--     node_definitions = ..., -- an abridgement of core.registered_nodes
--   }
--
-- The server subsequently waits for the client to deliver any packet,
-- thus concluding the handshake.
-----------------------------------------------------------------------

function mcl_serverplayer.is_csm_capable (player)
	return client_states[player]
		and (client_states[player].handshake_status
			== "complete")
end

function mcl_serverplayer.is_csm_at_least (player, proto)
	return client_states[player]
		and (client_states[player].proto or -1) >= proto
end

local serverbound_handshake = {}
local keys_to_copy = {
	"_mcl_velocity_factor",
	"groups",
	"liquidtype",
	"_liquid_type",
	"climbable",
}
local biome_keys_to_copy = {
	"temperature",
	"temperature_modifier",
	"has_precipitation",
}

core.register_on_mods_loaded (function ()
	local tbl = {}
	for name, def in pairs (core.registered_nodes) do
		local def1 = {}
		for _, key in pairs (keys_to_copy) do
			def1[key] = def[key]
		end
		tbl[name] = def1
	end
	serverbound_handshake.node_definitions = tbl
	serverbound_handshake.bow_info = mcl_serverplayer.bow_info
end)

mcl_serverplayer.handshake_item_defs = {}
mcl_serverplayer.handshake_item_defs_v4 = {}
local item_defs_v4

local function serialize_id_to_name_map (id_to_name_map)
	local tbl = {}
	for id, biome in pairs (id_to_name_map) do
		assert (id < 255)
		if id == 0 then
			-- Biome ID 0 cannot be transmitted over
			-- modchannels.
			id = 255
		end
		tbl[tostring (id)] = biome
	end
	return tbl
end

local function process_serverbound_hello (player, state, payload)
	if state.handshake_status ~= "want_hello" then
		error ("Duplicate ServerboundHello messages")
	end
	local proto = tonumber (payload)
	if proto then
		local proto = math.min (proto, MAX_PROTO_VERSION)
		client_states[player].proto = proto

		-- Generate the response.
		serverbound_handshake.proto = proto
		if proto >= 4 then
			if not item_defs_v4 then
				local defs = mcl_serverplayer.handshake_item_defs
				local defs_v4 = mcl_serverplayer.handshake_item_defs_v4
				item_defs_v4
					= table.merge (defs, defs_v4)
			end
			serverbound_handshake.item_defs = item_defs_v4
			serverbound_handshake.trident_info
				= mcl_serverplayer.trident_info
		elseif proto >= 1 then
			serverbound_handshake.item_defs
				= mcl_serverplayer.handshake_item_defs
		else
			serverbound_handshake.item_defs = nil
		end
		if proto >= 2 then
			serverbound_handshake.map_configuration = {
				{
					min = mcl_vars.mg_nether_min,
					max = mcl_vars.mg_nether_max + 128,
					dim = "nether",
				},
				{
					min = mcl_vars.mg_overworld_min,
					max = mcl_vars.mg_overworld_max,
					dim = "overworld",
				},
				{
					min = mcl_vars.mg_end_min,
					max = mcl_vars.mg_end_max,
					dim = "end",
				},
			}
		else
			serverbound_handshake.map_configuration = nil
		end
		if proto >= 6 then
			if proto == 6 then
				serverbound_handshake.biome_data_available
					= mcl_levelgen.levelgen_enabled
			elseif proto >= 7 then
				serverbound_handshake.biome_data_available = true
				if mcl_levelgen.levelgen_enabled then
					serverbound_handshake.biome_data_type = "levelgen_data"
				else
					serverbound_handshake.biome_data_type = "engine_data"
				end
			end
			if mcl_levelgen.levelgen_enabled then
				serverbound_handshake.biome_id_to_name_map
					= serialize_id_to_name_map (mcl_levelgen.biome_id_to_name_map)
				local biomes = {}
				for name, def in pairs (mcl_levelgen.registered_biomes) do
					local tbl = {}
					for _, key in ipairs (biome_keys_to_copy) do
						tbl[key] = def[key]
					end
					biomes[name] = tbl
				end
				serverbound_handshake.biome_definitions = biomes
				if proto >= 9 then
					serverbound_handshake.biome_seed
						= mcl_levelgen.biome_seed
					serverbound_handshake.registered_dimensions
						= mcl_serverplayer.marshal_registered_dimensions ()
				end
			elseif proto >= 7 then
				local id_to_name, name_to_def
					= mcl_serverplayer.marshal_engine_biomes ()
				serverbound_handshake.biome_id_to_name_map
					= id_to_name
				serverbound_handshake.biome_definitions
					= name_to_def
			end
		else
			serverbound_handshake.biome_data_available = nil
		end
		local payload = core.write_json (serverbound_handshake)
		if (#payload % MAX_PAYLOAD) == 0 then
			-- Insert trailing whitespace so that partial
			-- payloads may always be correctly terminated.
			payload = payload .. " "
		end
		local i = 1
		while i <= #payload do
			local max = math.min (i + MAX_PAYLOAD - 1, #payload)
			local substr = payload:sub (i, max)
			local str = table.concat ({
				CLIENTBOUND_HELLO,
				substr,
			})
			modchannels[player]:send_all (str)
			i = i + MAX_PAYLOAD
		end
		state.handshake_status = "want_acknowledgment"
		mcl_serverplayer.init_player (state, player)
	else
		error ("Invalid payload")
	end
end

local function process_serverbound_movement_state (player, state, payload)
	if state.handshake_status == "want_hello" then
		error ("ServerboundMovementState received before completion of handshake")
	end
	local json = core.parse_json (payload)
	if not json or type (json) ~= "table" then
		error ("Invalid ServerboundMovementState payload")
	end
	state.is_fall_flying = json.is_fall_flying
	state.is_sprinting = json.is_sprinting
	state.in_water = json.in_water
	state.is_swimming = json.is_swimming
end

-----------------------------------------------------------------------
-- Packet delivery.
-----------------------------------------------------------------------

local function check_table (value)
	if type (value) ~= "table" then
		error ("Invalid table: " .. dump (value))
	end
end

local function check_vector (value)
	if type (value) ~= "table"
		or type (value.x) ~= "number"
		or type (value.y) ~= "number"
		or type (value.z) ~= "number" then
		error ("Invalid vector: " .. dump (value))
	end
end

local function check_number (value)
	if type (value) ~= "number" then
		error ("Invalid number: " .. dump (value))
	end
end

local function receive_modchannel_message_1 (player, message)
	local msgtype = message:sub (1, 2)
	local payload = message:sub (3, #message)
	local state = client_states[player]

	if msgtype == SERVERBOUND_HELLO then
		process_serverbound_hello (player, state, payload)
	else
		if state.handshake_status == "want_acknowledgment" then
			local blurb = "Established CSM connection with client "
				.. player:get_player_name ()
			core.log ("action", blurb)
			state.handshake_status = "complete"

			if state.proto >= 1 then
				local inv = player:get_inventory ()
				local stack = inv:get_stack ("offhand", 1)
				mcl_serverplayer.send_offhand_item (player, stack)
			end
		end
		if msgtype == SERVERBOUND_PLAYERPOSE then
			local id = tonumber (payload)
			if not id then
				error ("Invalid player pose")
			end
			mcl_serverplayer.handle_playerpose (player, state, id)
		elseif msgtype == SERVERBOUND_MOVEMENT_STATE then
			process_serverbound_movement_state (player, state, payload)
		elseif msgtype == SERVERBOUND_MOVEMENT_EVENT then
			local id = tonumber (payload)
			if not id then
				error ("Invalid movement event payload")
			end
			mcl_serverplayer.handle_movement_event (player, id)
		elseif msgtype == SERVERBOUND_PLAYERANIM then
			mcl_serverplayer.handle_playeranim (player, state, payload)
		elseif msgtype == SERVERBOUND_DAMAGE then
			local json = core.parse_json (payload)
			if not json or type (json) ~= "table" then
				error ("Invalid movement damage payload")
			end
			if json.type == "fall" then
				-- Verify the collision list,
				-- damage_pos, and amount.
				if not json.collisions then
					json.collisions = {}
				end
				check_table (json.collisions)
				for _, item in pairs (json.collisions) do
					check_vector (item)
				end
				check_vector (json.damage_pos)
				check_number (json.amount)
			elseif json.type == "kinetic" then
				check_number (json.amount)
			end
			mcl_serverplayer.handle_damage (player, state, json)
		elseif msgtype == SERVERBOUND_GET_AMMO then
			local challenge = tonumber (payload)
			if not challenge or challenge <= state.ammo_challenge then
				error ("Invalid or out of order ServerboundGetAmmo message")
			end
			state.ammo_challenge = challenge
			mcl_serverplayer.update_ammo (state, player, true)
		elseif msgtype == SERVERBOUND_RELEASE_USEITEM then
			local ctrlwords = string.split (payload, ',')
			if #ctrlwords ~= 2
				or not (tonumber (ctrlwords[1]))
				or not (tonumber (ctrlwords[2]))
				or tonumber (ctrlwords[2]) <= state.ammo_challenge then
				error ("Invalid ServerboundReleaseUseitem message")
			end
			local usetime = tonumber (ctrlwords[1])
			local challenge = tonumber (ctrlwords[2])
			mcl_serverplayer.release_useitem (state, player, usetime, challenge)
		elseif msgtype == SERVERBOUND_VISUAL_WIELDITEM then
			local item = ItemStack (payload)

			if not item:is_empty () then
				state.visual_wielditem = item
			else
				state.visual_wielditem = nil
			end
		elseif msgtype == SERVERBOUND_ACKNOWLEDGE_VEHICLE then
			local id = tonumber (payload)
			if not id then
				error ("Invalid ServerboundAcknowledgeVehicle message")
			end
			mcl_serverplayer.handle_acknowledge_vehicle (player, state, id)
		elseif msgtype == SERVERBOUND_REFUSE_VEHICLE then
			local id = tonumber (payload)
			if not id then
				error ("Invalid ServerboundRefuseVehicle message")
			end
			mcl_serverplayer.handle_refuse_vehicle (player, state, id)
		elseif msgtype == SERVERBOUND_MOVE_VEHICLE then
			local id, tsc, x, y, z, vx, vy, vz
				= unpack (payload:split (','))
			if not id or not tsc or not x or not y or not z
				or not vx or not vy or not vz then
				error ("Parameters absent from ServerboundMoveVehicle message")
			end
			tsc = tonumber (tsc)
			id = tonumber (id)
			x = tonumber (x)
			y = tonumber (y)
			z = tonumber (z)
			vx = tonumber (vx)
			vy = tonumber (vy)
			vz = tonumber (vz)
			if not id or not tsc or not x or not y
				or not z or not vx or not vy or not vz then
				error ("Invalid ServerboundMoveVehicle message")
			end
			local pos = vector.new (x, y, z)
			local vel = vector.new (vx, vy, vz)
			mcl_serverplayer.handle_move_vehicle (player, state, id, tsc, pos, vel)
		elseif msgtype == SERVERBOUND_CONFIGURE_VEHICLE then
			local config = core.parse_json (payload)
			if not config then
				error ("Invalid configuration")
			end
			mcl_serverplayer.handle_configure_vehicle (player, state, config)
		elseif msgtype == SERVERBOUND_TURN_VEHICLE then
			local id, tsc, yaw = unpack (payload:split (','))
			if not id or not tsc or not yaw then
				error ("Parameters absent from ServerboundTurnVehicle message")
			end
			id = tonumber (id)
			tsc = tonumber (tsc)
			yaw = tonumber (yaw)
			if not id or not tsc or not yaw then
				error ("Invalid ServerboundTurnVehicle message")
			end
			mcl_serverplayer.handle_turn_vehicle (player, state, id, tsc, yaw)
		elseif msgtype == SERVERBOUND_SHIELDCTRL then
			if state.proto < 1 then
				error ("ServerboundShieldctrl messages can only be "
				       .. "delivered when protocol version >= 1")
			end

			local blocking = tonumber (payload)
			if blocking ~= 0 and blocking ~= 1 and blocking ~= 2 then
				error ("Invalid parameter in ServerboundShieldctrl message")
			end
			mcl_shields.set_blocking (player, blocking)
		elseif msgtype == SERVERBOUND_EAT_ITEM then
			if state.proto < 1 then
				error ("ServerboundEatItem messages can only be "
				       .. "delivered when protocol version >= 1")
			end

			local payload = core.parse_json (payload)
			if type (payload) ~= "table"
				or type (payload.stack) ~= "string"
				or type (payload.index) ~= "number" then
				error ("Invalid payload in ServerboundEatItem message")
			end
			local stack = ItemStack (payload.stack)
			local index = payload.index
			local def = stack:get_definition ()

			if def and def.on_place
				and def.groups.food
				and def.groups.food > 0 then
				local inv = player:get_inventory ()

				-- Guarantee that the stack's contents
				-- haven't changed in the interim.
				if inv:get_stack ("main", index):equals (stack) then
					core.do_item_eat(def.groups.eatable, def._mcl_eat_replace_with, stack, player)
					player:set_wielded_item(stack)
				end
			else
				error ("Attempting to consume non-edible item")
			end
		elseif msgtype == SERVERBOUND_RELEASE_TRIDENT_ITEM then
			if state.proto < 4 then
				error ("ServerboundReleaseTridentItem messages can"
				       .. " only be delivered when protocol version >= 4")
			end
			mcl_serverplayer.release_trident_item (player, state)
		elseif msgtype == SERVERBOUND_DISCARD_BIOME_DATA then
			if state.proto < 6 then
				error ("ServerboundDiscardBiomeData messages require"
				       .. " protocol version >= 6")
			end

			local list = string.split (payload, ',')
			for i, hash in ipairs (list) do
				list[i] = tonumber (hash)
				if not list[i] then
					error ("Invalid data in ServerboundDiscardBiomeData message")
				end
			end

			mcl_serverplayer.discard_biome_data (player, state, list)
		else
			core.log ("warning", table.concat ({
				"Client ", player:get_player_name (), " delivered",
				" unknown message of type '", msgtype,
				"'",
			}))
		end
	end
end

local function receive_modchannel_message (channel_name, sender, message)
	if channel_name == "mcl_player:" .. sender then
		local player = core.get_player_by_name (sender)
		if player then
			local _, err
				= pcall (receive_modchannel_message_1, player, message)
			if err then
				local reason = "Malformed serverbound message: " .. dump (err)
				core.kick_player (sender, reason)
			end
		end
	end
end

core.register_on_modchannel_message (receive_modchannel_message)

local modpath = core.get_modpath (core.get_current_modname ())
dofile (modpath .. "/player.lua")
dofile (modpath .. "/items.lua")
dofile (modpath .. "/mount.lua")
dofile (modpath .. "/effects.lua")
dofile (modpath .. "/level.lua")
