local S = core.get_translator(core.get_current_modname())
local F = core.formspec_escape

local command_blocks_activated = core.settings:get_bool("mcl_enable_commandblocks", true)
local msg_not_activated = S("Command blocks are not enabled on this server")

local function resolve_commands(commands, pos)
	local players = core.get_connected_players()

	local meta = core.get_meta(pos)
	local commander = meta:get_string("commander")

	-- A non-printable character used while replacing “@@”.
	local SUBSTITUTE_CHARACTER = "\26" -- ASCII SUB

	-- No players online: remove all commands containing
	-- problematic placeholders.
	if #players == 0 then
		commands = commands:gsub("[^\r\n]+", function (line)
			line = line:gsub("@@", SUBSTITUTE_CHARACTER)
			if line:find("@n") then return "" end
			if line:find("@p") then return "" end
			if line:find("@f") then return "" end
			if line:find("@r") then return "" end
			line = line:gsub("@c", commander)
			line = line:gsub(SUBSTITUTE_CHARACTER, "@")
			return line
		end)
		return commands
	end

	local nearest, farthest = nil, nil
	local min_distance, max_distance = math.huge, -1
	for index, player in pairs(players) do
		local distance = vector.distance(pos, player:get_pos())
		if distance < min_distance then
			min_distance = distance
			nearest = player:get_player_name()
		end
		if distance > max_distance then
			max_distance = distance
			farthest = player:get_player_name()
		end
	end
	local random = players[math.random(#players)]:get_player_name()
	commands = commands:gsub("@@", SUBSTITUTE_CHARACTER)
	commands = commands:gsub("@p", nearest)
	commands = commands:gsub("@n", nearest)
	commands = commands:gsub("@f", farthest)
	commands = commands:gsub("@r", random)
	commands = commands:gsub("@c", commander)
	commands = commands:gsub(SUBSTITUTE_CHARACTER, "@")
	return commands
end

local function check_commands(commands, player_name)
	for _, command in pairs(commands:split("\n")) do
		local pos = command:find(" ")
		local cmd = command
		if pos then
			cmd = command:sub(1, pos - 1)
		end
		local cmddef = core.chatcommands[cmd]
		if not cmddef then
			-- Invalid chat command
			local msg = S("Error: The command “@1” does not exist; your command block has not been changed. Use the “help” chat command for a list of available commands.", cmd)
			if string.sub(cmd, 1, 1) == "/" then
				msg = S("Error: The command “@1” does not exist; your command block has not been changed. Use the “help” chat command for a list of available commands. Hint: Try to remove the leading slash.", cmd)
			end
			return false, core.colorize(mcl_colors.RED, msg)
		end
		if player_name then
			local player_privs = core.get_player_privs(player_name)

			for cmd_priv, _ in pairs(cmddef.privs) do
				if player_privs[cmd_priv] ~= true then
					local msg = S("Error: You have insufficient privileges to use the command “@1” (missing privilege: @2)! The command block has not been changed.", cmd, cmd_priv)
					return false, core.colorize(mcl_colors.RED, msg)
				end
			end
		end
	end
	return true
end

local function commandblock_action_on(pos, node)
	if node.name ~= "mcl_commandblock:commandblock_off" then
		return
	end

	local meta = core.get_meta(pos)
	local commander = meta:get_string("commander")

	if not command_blocks_activated then
		return
	end
	core.swap_node(pos, {name = "mcl_commandblock:commandblock_on"})

	local commands = resolve_commands(meta:get_string("commands"), pos)
	for _, command in pairs(commands:split("\n")) do
		local cpos = command:find(" ")
		local cmd, param = command, ""
		if cpos then
			cmd = command:sub(1, cpos - 1)
			param = command:sub(cpos + 1)
		end
		local cmddef = core.chatcommands[cmd]
		if not cmddef then
			-- Invalid chat command
			return
		end
		-- Execute command in the name of commander
		cmddef.func(commander, param)
	end
end

local function commandblock_action_off(pos, node)
	if node.name == "mcl_commandblock:commandblock_on" then
		core.swap_node(pos, {name = "mcl_commandblock:commandblock_off"})
	end
end

local function show_formspec(pos, player)
	if not command_blocks_activated then
		core.chat_send_player(player:get_player_name(), msg_not_activated)
		return
	end
	local can_edit = true
	-- Only allow write access in Creative Mode
	if not core.is_creative_enabled(player:get_player_name()) then
		can_edit = false
	end
	local pname = player:get_player_name()
	if core.is_protected(pos, pname) then
		can_edit = false
	end
	local privs = core.get_player_privs(pname)
	if not privs.maphack then
		can_edit = false
	end

	local meta = core.get_meta(pos)
	local commands = meta:get_string("commands")
	if not commands then
		commands = ""
	end
	local commander = meta:get_string("commander")
	local commanderstr
	if commander == "" or commander == nil then
		commanderstr = S("Error: No commander! Block must be replaced.")
	else
		commanderstr = S("Commander: @1", commander)
	end
	local textarea_name, submit, textarea
	-- If editing is not allowed, only allow read-only access.
	-- Player can still view the contents of the command block.
	if can_edit then
		textarea_name = "commands"
		submit = "button_exit[3.3,4.4;2,1;submit;"..F(S("Submit")).."]"
	else
		textarea_name = ""
		submit = ""
	end
	if not can_edit and commands == "" then
		textarea = "label[0.5,0.5;"..F(S("No commands.")).."]"
	else
		textarea = "textarea[0.5,0.5;8.5,4;"..textarea_name..";"..F(S("Commands:"))..";"..F(commands).."]"
	end
	local formspec = "size[9,5;]" ..
	textarea ..
	submit ..
	"image_button[8,4.4;1,1;doc_button_icon_lores.png;doc;]" ..
	"tooltip[doc;"..F(S("Help")).."]" ..
	"label[0,4;"..F(commanderstr).."]"
	core.show_formspec(pname, "commandblock_"..pos.x.."_"..pos.y.."_"..pos.z, formspec)
end

local commdef = {
	description = S("Command Block"),
	groups = {creative_breakable=1, unmovable_by_piston = 1, command_block = 1},
	drop = "",
	is_ground_content = false,
	on_construct = function(pos)
		local meta = core.get_meta(pos)
		meta:set_string("commands", "")
		meta:set_string("commander", "")
	end,
	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" or not placer or not placer:is_player() then
			return itemstack
		end
		local new_stack = mcl_util.call_on_rightclick(itemstack, placer, pointed_thing)
		if new_stack then
			return new_stack
		end
		local privs = core.get_player_privs(placer and placer:get_player_name() or "")
		if not privs.maphack then
			core.chat_send_player(placer:get_player_name(), S("Placement denied. You need the “maphack” privilege to place command blocks."))
			return itemstack
		end

		return core.item_place_node(itemstack, placer, pointed_thing)
	end,
	after_place_node = function(pos, placer)
		if placer then
			local meta = core.get_meta(pos)
			meta:set_string("commander", placer:get_player_name())
		end
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing)
		show_formspec(pos, player)
	end,
	sounds = mcl_sounds.node_sound_stone_defaults(),
	_mcl_redstone = {
		connects_to = function(node, dir)
			return true
		end,
		update = function(pos, node)
			local powered = mcl_redstone.get_power(pos) ~= 0
			local node = core.get_node(pos)
			if powered then
				commandblock_action_on(pos, node)
			else
				commandblock_action_off(pos, node)
			end
		end,
	},
	_mcl_blast_resistance = 3600000,
	_mcl_hardness = -1,
}

core.register_node("mcl_commandblock:commandblock_off", table.merge(commdef, {
	_tt_help = S("Executes server commands when powered by redstone power"),
	_doc_items_longdesc =
S("Command blocks are mighty redstone components which are able to alter reality itself. In other words, they cause the server to execute server commands when they are supplied with redstone power."),
	_doc_items_usagehelp =
S("Everyone can activate a command block and look at its commands, but not everyone can edit and place them.").."\n\n"..

S("To view the commands in a command block, use it. To activate the command block, just supply it with redstone power. This will execute the commands once. To execute the commands again, turn the redstone power off and on again.")..
"\n\n"..

S("To be able to place a command block and change the commands, you need to be in Creative Mode and must have the “maphack” privilege. A new command block does not have any commands and does nothing. Use the command block (in Creative Mode!) to edit its commands. Read the help entry “Advanced usage > Server Commands” to understand how commands work. Each line contains a single command. You enter them like you would in the console, but without the leading slash. The commands will be executed from top to bottom.").."\n\n"..

S("All commands will be executed on behalf of the player who placed the command block, as if the player typed in the commands. This player is said to be the “commander” of the block.").."\n\n"..

S("Command blocks support placeholders, insert one of these placeholders and they will be replaced by some other text:").."\n"..
S("• “@@c”: commander of this command block").."\n"..
S("• “@@n” or “@@p”: nearest player from the command block").."\n"..
S("• “@@f” farthest player from the command block").."\n"..
S("• “@@r”: random player currently in the world").."\n"..
S("• “@@@@”: literal “@@” sign").."\n\n"..

S("Example 1:\n    time 12000\nSets the game clock to 12:00").."\n\n"..

S("Example 2:\n    give @@n mcl_core:apple 5\nGives the nearest player 5 apples"),
	tiles = {{name="jeija_commandblock_off.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=2}}},
}))

core.register_node("mcl_commandblock:commandblock_on", table.merge(commdef, {
	tiles = {{name="jeija_commandblock_off.png", animation={type="vertical_frames", aspect_w=32, aspect_h=32, length=2}}},
	groups = table.merge(commdef.groups, {not_in_creative_inventory=1}),
	_mcl_blast_resistance = 3600000,
	_mcl_hardness = -1,
}))

core.register_on_player_receive_fields(function(player, formname, fields)
	if string.sub(formname, 1, 13) == "commandblock_" then
		if fields.doc then
			doc.show_entry(player:get_player_name(), "nodes", "mcl_commandblock:commandblock_off", true)
			return
		end
		if (not fields.submit and not fields.key_enter) or (not fields.commands) then
			return
		end

		local privs = core.get_player_privs(player:get_player_name())
		if not privs.maphack then
			core.chat_send_player(player:get_player_name(), S("Access denied. You need the “maphack” privilege to edit command blocks."))
			return
		end

		local index, _, x, y, z = string.find(formname, "commandblock_(-?%d+)_(-?%d+)_(-?%d+)")
		if index and x and y and z then
			local pos = {x = tonumber(x), y = tonumber(y), z = tonumber(z)}
			local meta = core.get_meta(pos)
			if not core.is_creative_enabled(player:get_player_name()) then
				core.chat_send_player(player:get_player_name(), S("Editing the command block has failed! You can only change the command block in Creative Mode!"))
				return
			end
			local check, error_message = check_commands(fields.commands, player:get_player_name())
			if check == false then
				-- Command block rejected
				core.chat_send_player(player:get_player_name(), error_message)
				return
			else
				meta:set_string("commands", fields.commands)
			end
		else
			core.chat_send_player(player:get_player_name(), S("Editing the command block has failed! The command block is gone."))
		end
	end
end)

doc.add_entry_alias("nodes", "mcl_commandblock:commandblock_off", "nodes", "mcl_commandblock:commandblock_on")
