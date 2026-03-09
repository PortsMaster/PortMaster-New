local S = core.get_translator(core.get_current_modname())
local C = core.colorize
local F = core.formspec_escape
local minimum_required_protocol_version = 44  --protocol version 44 corresponds to minetest 5.9.0

local fs_title = S("Outdated Client version detected!")
local fs_notagain = S("Do not show again")
local fs_leave = S("Leave Server")
local fs_ignore = S("Ignore")
local low_version_warning = S("You are connecting with an unsupported client. This will generally not keep you from playing the game but you should expect some visual issues, particularly with mobs and certain items.\n\nTo enjoy the best mineclonia experience use a minetest/luanti client of version 5.9.0 or greater.")

core.register_on_joinplayer(function(player)
	local pn = player:get_player_name()
	local pm = player:get_meta()
	local last_confirm = pm:get_int("mcla_last_confirmed_unsupported_protocol")
	local current_protocol = core.get_player_information(pn).protocol_version
	local skip_nag = core.get_player_information and current_protocol >= minimum_required_protocol_version
	if not skip_nag and last_confirm < current_protocol then
		core.show_formspec(pn, "mcl_init:version_nagscreen", table.concat({
			"formspec_version[4]",
			"size[14.75,5.925]",
			"label[0.375,0.375;" .. F(C("#FF0000", fs_title)) .. "]",
			--"label[0.375,1.375;"..low_version_warning.."]",
			"textarea[0.375,0.875;12.0,3.5;;" .. core.formspec_escape(low_version_warning) .. ";]" ..
			"checkbox[0.375,4.0;notagain;"..F(C(mcl_formspec.label_color, fs_notagain)) .. "]",
			"button_exit[0.375,4.5;3,1;leave;"..F(C(mcl_formspec.label_color, fs_leave)) .. "]",
			"button_exit[3.575,4.5;3,1;ignore;"..F(C(mcl_formspec.label_color, fs_ignore)) .. "]",
		}))
	end
end)

core.register_on_player_receive_fields(function(player, formname, fields)
	if not fields or formname ~= "mcl_init:version_nagscreen" then return end

	local pn = player:get_player_name()
	local pm = player:get_meta()
	local current_protocol = core.get_player_information(pn).protocol_version
	if fields.leave then
		core.kick_player(pn, fs_title)
	elseif fields.notagain then
		pm:set_int("mcla_last_confirmed_unsupported_protocol", current_protocol)
	end
end)
