---------------------------------------------------------------------
-- This file is part of Freedroid
--
-- Freedroid is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Freedroid is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with Freedroid; see the file COPYING. If not, write to the
-- Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
-- MA 02111-1307 USA
----------------------------------------------------------------------

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	EveryTime = function()
		play_sound("effects/Menu_Item_Deselected_Sound_0.ogg") --@TODO check that the captcha works
		--  < infrared_> The captcha code could probably be condensed into an array, at the cost of readability for non-coders; translating it shouldn't be a problem.
		if (not MO_HFGateAccessServer_skip_captcha) then
			-- Are we human? CAPTCHA!!!
			number_one=math.random(2,7)
			number_two=math.random(1,number_one-1)
			captcha = number_one - number_two
			-- Convert number_one and number_two to text
			-- This could be optimized but that can be done after r17 RC 1
			if (number_one == 1) then
				number_one = _"one"
			elseif (number_one == 2) then
				number_one = _"two"
			elseif (number_one == 3) then
				number_one = _"three"
			elseif (number_one == 4) then
				number_one = _"four"
			elseif (number_one == 5) then
				number_one = _"five"
			elseif (number_one == 6) then
				number_one = _"six"
			elseif (number_one == 7) then
				number_one = _"seven"
			end

			if (number_two == 1) then
				number_two = _"one"
			elseif (number_two == 2) then
				number_two = _"two"
			elseif (number_two == 3) then
				number_two = _"three"
			elseif (number_two == 4) then
				number_two = _"four"
			elseif (number_two == 5) then
				number_two = _"five"
			elseif (number_two == 6) then
				number_two = _"six"
			elseif (number_two == 7) then
				number_two = _"seven"
			end

			-- Just to be sure there won't be str/int problems
			if (captcha == 1) then
				captcha = "1"
			elseif (captcha == 2) then
				captcha = "2"
			elseif (captcha == 3) then
				captcha = "3"
			elseif (captcha == 4) then
				captcha = "4"
			elseif (captcha == 5) then
				captcha = "5"
			elseif (captcha == 6) then
				captcha = "6"
			end
			response = user_input_string(string.format(_"CAPTCHA: Please write the number that answers the following: %s - %s = ?", number_one, number_two))
		else
			MO_HFGateAccessServer_skip_captcha = false
		end
		if (captcha ~= response) then
			Npc:says(_"Non-human detected. Administering paralyzing shock.")
			Npc:says(_"NOTE: If you are a human, try again, and make sure you enter digits and not a word.")
			freeze_tux_npc(7)
			Tux:hurt(20)
			Tux:heat(20)
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		else
			Npc:says(_"Welcome to MS gate access server for region #54648.")
			if (not MO_HFGateAccessServer_Spencer_chat) then
				Tux:says(_"WHAT?!")
				Tux:update_quest("Propagating a faulty firmware update", _"The firmware server seems to actually be an access server to a gate. What am I supposed to do now?")
				MO_HFGateAccessServer_Spencer = true
				MO_HFGateAccessServer_Spencer_chat = true
				MO_HFGateAccessServer_skip_captcha = true
				start_chat("Spencer")
				play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
				end_dialog()
			end
			if (MO_HFGateAccessServer_Spencer) then
				MO_HFGateAccessServer_Spencer = false
				play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
				end_dialog()
			else
				Npc:says(_"Please select action")
			end
			show("node1", "node99")
		end
	end,

	{
		id = "node1",
		text = _"status",
		echo_text = false,
		code = function()
			Tux:says(_"status", "NO_WAIT")
			if (cmp_obstacle_state("HF-Gate-outer", "opened")) then
				Npc:says(_"Gate 1 status: OPENED", "NO_WAIT")
			else
				Npc:says(_"Gate 1 status: CLOSED", "NO_WAIT")
				if (not MO_HFGateAccessServer_hacked) then
					show("node2")
				end
			end

			if (cmp_obstacle_state("HF-Gate-inner", "opened")) then
				Npc:says(_"Gate 2 status: OPENED", "NO_WAIT")
			else
				Npc:says(_"Gate 2 status: CLOSED", "NO_WAIT")
				if (not MO_HFGateAccessServer_hacked) then
					show("node2")
				end
			end

			if (cmp_obstacle_state("HF-Gate-inner", "opened")) and
			(cmp_obstacle_state("HF-Gate-outer", "opened")) then
			end
		end,
	},
	{
		id = "node2",
		text = _"open gate",
		echo_text = false,
		code = function()
			Tux:says(_"open gate", "NO_WAIT")
			Npc:says(_"Permission denied")
			Tux:hurt(5)
			Tux:heat(10)
			display_console_message("The server is secured, looks like I have to hack it.")
			hide("node2") show("node3")
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
	{
		id = "node3",
		text = _"(Try hacking the server)",
		code = function()
			if (takeover(get_program("Hacking")+3)) then
				Tux:says("sudo open_gates")
				--; TRANSLATORS: this is parody of Microsoft Windows' error message;
				--; 	"sudo" verbatim
				Npc:says(_"'sudo' is not recognized as an internal or external command, operable program or batch file.")
				Tux:says(_"Oh, of course.", "NO_WAIT")
				Tux:says(_"Now, let me see if I can remember this correctly ...")
				--; TRANSLATORS: parody of Microsoft Windows' runas command;
				--; 	"RUNAS" and "OPENGATE.EXE" verbatim
				Tux:says(_"RUNAS /user:Administrator OPENGATE.EXE", "NO_WAIT")
				Npc:says(_"Which gates do you want to open?")
				Tux:update_quest("Open Sesame", "Whew, I finally managed to hack the gate access server. I can open the gates now.")
				MO_HFGateAccessServer_hacked = true
				hide("node3") show("node4")
			else
				Npc:says(_"Permission denied.")
				Tux:heat(15)
				Tux:hurt(10)
				play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
				end_dialog()
			end
		end,
	},
	{
		id = "node4",
		text = "OPENGATE.EXE /?",
		echo_text = false,
		code = function()
			--; TRANSLATORS: this block is parody of Microsoft Windows' format for documentation internal to a command
			Tux:says("OPENGATE.EXE /?", "NO_WAIT")
			Npc:says(_"Opens gates via command prompt on a console.", "NO_WAIT")
			Npc:says(" ")
			--; TRANSLATORS: "OPENGATE" verbatim
			Npc:says(_"OPENGATE [inner] [outer]", "NO_WAIT")
			Npc:says(" ")
			Npc:says(_"  inner   Opens the inner gate.", "NO_WAIT")
			Npc:says(_"  outer   Opens the outer gate.", "NO_WAIT")
			Npc:says(" ")
			Npc:says(_"Without parameters, OPENGATE will prompt you with a helpful query.", "NO_WAIT")
			Npc:says(_"To secure the gates, use SHUTGATE.", "NO_WAIT")
			Npc:says(_"Press any key to continue . . .")
			Npc:says(" ")
			Npc:says(_"Take note: These are not the gates you are looking for.", "NO_WAIT")
			Npc:says(_"Version: 9.13.1665.0 Aug 11, 1998")
			-- NOTE	the text "FreedroidRPG" encoded in US-ASCII and then those decimal values summed is equal to 1665
			hide("node4") show("node5", "node6", "node7")
		end,
	},
	{
		id = "node5",
		--; TRANSLATORS: "OPENGATE" verbatim
		text = _"OPENGATE inner",
		echo_text = false,
		code = function()
			--; TRANSLATORS: "OPENGATE" verbatim
			Tux:says(_"OPENGATE inner", "NO_WAIT")
			Npc:says(_"inner gate opened", "NO_WAIT")
			Npc:says(_"[b]WARNING[/b]:", "NO_WAIT")
			Npc:says(_"Anomalies detected!")
			change_obstacle_state("HF-Gate-inner", "opened")
			if (cmp_obstacle_state("HF-Gate-outer", "opened")) then
				Tux:update_quest("Open Sesame", "I think I managed to open the gates to the Hell Fortress. But where can I find them?")
				hide("node7")
			end
			hide("node5")
		end,
	},
	{
		id = "node6",
		--; TRANSLATORS: "OPENGATE" verbatim
		text = _"OPENGATE outer",
		echo_text = false,
		code = function()
			--; TRANSLATORS: "OPENGATE" verbatim
			Tux:says(_"OPENGATE outer", "NO_WAIT")
			Npc:says(_"outer gate opened", "NO_WAIT")
			Npc:says(_"[b]WARNING[/b]:", "NO_WAIT")
			Npc:says(_"Anomalies detected!")
			change_obstacle_state("HF-Gate-outer", "opened")
			if (cmp_obstacle_state("HF-Gate-inner", "opened")) then
				Tux:update_quest("Open Sesame", "I think I managed to open the gates to Hell Fortress. But where can I find them?")
				hide("node7")
			end
			hide("node6")
		end,
	},
	{
		id = "node7",
		--; TRANSLATORS: "OPENGATE" verbatim
		text = _"OPENGATE inner outer",
		echo_text = false,
		code = function()
			--; TRANSLATORS: "OPENGATE" verbatim
			Tux:says(_"OPENGATE inner outer", "NO_WAIT")
			Npc:says(_"inner gate opened", "NO_WAIT")
			Npc:says(_"outer gate opened", "NO_WAIT")
			Npc:says(_"[b]WARNING[/b]:", "NO_WAIT")
			Npc:says(_"Anomalies detected!")
			change_obstacle_state("HF-Gate-inner", "opened")
			change_obstacle_state("HF-Gate-outer", "opened")
			Tux:update_quest("Open Sesame", "I think I managed to open the gates to Hell Fortress. But where can I find them?")
			hide("node5", "node6", "node7")
		end,
	},
	{
		id = "node99",
		text = _"logout",
		echo_text = false,
		code = function()
			Tux:says(_"logout")
			Npc:says(_"exiting...")
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
}
