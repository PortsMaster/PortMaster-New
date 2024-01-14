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
local hacking_level = get_program("Hacking")

return {
	EveryTime = function()
		play_sound("effects/Menu_Item_Deselected_Sound_0.ogg")
		Act2BotFactory_prompt = "tux@gateserv.rr: ~ #"

		if (not Tux:has_item("Arcane Lore")) then
			cli_says(_"Connection refused. ", "NO_WAIT")
			Npc:says(_"Terminal #1979 is immune to hack attempts. Or so says the lore.") -- RR 1979 is ACT2 Review Request on Review Board...
			end_dialog()
		else
			Npc:says(_"[b]Arcane Lore[/b] - I've bought an anti-hack software, so I could try to hack it!", "NO_WAIT")
			Npc:says(_"[b]User tux created.[/b] Enjoy!", "NO_WAIT")
			Npc:says("")
			cli_says(_"Login : ", "NO_WAIT")
			--; TRANSLATORS: username, maybe this should stay in lowercase letters?
			Tux:says(_"tux", "NO_WAIT")
			cli_says(_"Entering as tux", "NO_WAIT")
			Npc:says("", "NO_WAIT")

			if (cmp_obstacle_state("Act2BotFactory", "closed")) then
				Npc:says(_"R&R Factory gate status: CLOSED", "NO_WAIT")
				show("node0")
			elseif (cmp_obstacle_state("Act2BotFactory", "opened")) then
				Npc:says(_"R&R Factory gate status: OPEN", "NO_WAIT")
				show("node10")
			else
				Npc:says("GAME BUG. PLEASE REPORT, RRGATE_TERMINAL EveryTime LuaCode")
			end
			cli_says(Act2BotFactory_prompt, "NO_WAIT")
			if (hacking_level < 9) then
				show("node20") hide("node21")
			end
			show("node99")
		end
	end,

	{
		id = "node0",
		--; TRANSLATORS: command,  use lowercase here
		text = _"open gate",
		echo_text = false,
		code = function()
			--; TRANSLATORS: command,  use lowercase here
			Tux:says(_"open gate", "NO_WAIT")

			-- Note: This captcha is different from the previous ones
			number_one=math.random(2,5)
			number_two=math.random(1,number_one-1)
			captcha = number_one + number_two

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
			end

			-- Just to be sure there won't be str/int problems
			if (captcha == 3) then
				captcha = "3"
			elseif (captcha == 4) then
				captcha = "4"
			elseif (captcha == 5) then
				captcha = "5"
			elseif (captcha == 6) then
				captcha = "6"
			elseif (captcha == 7) then
				captcha = "7"
			elseif (captcha == 8) then
				captcha = "8"
			elseif (captcha == 9) then
				captcha = "9"
			end
			response = user_input_string(string.format(_"CAPTCHA: Please write the number that answers the following: %s + %s = ?", number_one, number_two))


			if (captcha ~= response) then
				Npc:says(_"Access Denied. Electrical discharge in progress.")
				Npc:says(_"NOTE: If you are a human, try again, and make sure you enter digits and not a word.")
				freeze_tux_npc(2)
				Tux:hurt(30)
				Tux:heat(60)
				play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
				end_dialog()
			else
				Npc:says(_"Access granted. Opening gate ...")
				Npc:says(_"Gate status: OPEN")
				change_obstacle_state("Act2BotFactory", "opened")
				cli_says(Act2BotFactory_prompt, "NO_WAIT")
				hide("node0") show("node10")
			end
		end,
	},
	{
		id = "node10",
		--; TRANSLATORS: command,  use lowercase here
		text = _"close gate",
		echo_text = false,
		code = function()
			--; TRANSLATORS: command,  use lowercase here
			Tux:says(_"close gate", "NO_WAIT")
			Npc:says(_"Access granted. Closing gate ...")
			Npc:says(_"Gate status: CLOSED")
			change_obstacle_state("Act2BotFactory", "closed")
			cli_says(Act2BotFactory_prompt, "NO_WAIT")
			hide("node10") show("node0")
		end,
	},
	{
		id = "node20",
		--; TRANSLATORS: command, use lowercase here
		text = _"download hacking tools",
		echo_text = false,
		code = function()
			Tux:says(_"download hacking tools", "NO_WAIT")
			local hacking_level = get_program("Hacking")
			if (hacking_level > 8) then
				Npc:says(_"The max available software revision is 9.")
				Npc:says(_"Your hacking skill already has or exceeds this level.")
			else
				Npc:says(_"This is commercial software, payment required (3000 circuits).")
				Npc:says(_"You will also need %d training points.", get_program("Hacking") * 2)
				Npc:says(_"Proceed?")
				show("node21")
			end
			hide("node20")
		end,
	},
	{
		id = "node21",
		text = _"sudo apt-get install hacking-tools",
		code = function()
			-- this is output of apt-get on debian/ubuntu
			Npc:says(_"Reading package lists... Done", "NO_WAIT")
			Npc:says(_"Building dependency tree", "NO_WAIT")
			Npc:says(_"Reading state information... Done", "NO_WAIT")
			-- orig "The following NEW packages will be installed:"
			Npc:says(_"The following skill will be installed:")
			Npc:says(_"'Hacking' program revision %d.", get_program("Hacking") + 1)
			Npc:says("", "NO_WAIT")

			if (Tux:train_program(3000, get_program("Hacking") * 2, "Hacking")) then
				Npc:says(_"Feature set of the hacking program has been improved successfully.")
			else
				if (Tux:get_gold() < 3000) then
					next("node25")
				else
					next("node26")
				end
			end
			hide("node21") show("node20")
		end,
	},
	{
		id = "node25",
		code = function()
			Npc:says_random(_"Payment bounced. Insufficient credits.")
		end,
	},
	{
		id = "node26",
		code = function()
			Npc:says_random(_"Out of Memory. More Experience is needed to run this program.")
		end,
	},
	{
		id = "node99",
		--; TRANSLATORS: command,  use lowercase here
		text = _"logout",
		echo_text = false,
		code = function()
			--; TRANSLATORS: command,  use lowercase here
			Tux:says(_"logout", "NO_WAIT")
			Npc:says(_"Exiting...")
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
}
