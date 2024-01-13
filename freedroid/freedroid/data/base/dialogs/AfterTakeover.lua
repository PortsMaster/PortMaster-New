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
	FirstTime = function()
		Aftertakeover_drain_attempt = "ask"
		Aftertakeover_reprogramm_bots_after_takeover = false
	end,

	EveryTime = function()
		play_sound("effects/Menu_Item_Deselected_Sound_0.ogg")
		local day, hour, minute = game_date()
		AfterTakeover_year = os.date("%Y") + 45 -- current year + 45
		--; TRANSLATORS: It shows the ingame date in format: Day day, hour:minute
		AfterTakeover_date_1 = string.format(_"Day %d, %02d:%02d", day, hour, minute) -- TODO: It saves last login on ANY bot...
		-- AfterTakeover_date probably shouldn't exist, we cannot determine last login on an individual bot!
		AfterTakeover_repair_time = 0
		AfterTakeover_repair_circuits = 0
		AfterTakeover_repair_heat = 0
		terminal = string.format(_"%s@hacked_%s: ~ # ", Tux:get_player_name(), Npc:get_type())
		cli_says(_"Login : ", "NO_WAIT")
		Tux:says(Tux:get_player_name(), "NO_WAIT")
		cli_says(_"Password : ", "NO_WAIT")
		Tux:says("*******")
		-- Npc:says("First login, %s ", os.date())
		if (AfterTakeover_date == nil) then
			--; TRANSLATORS: %s = a date ,  %d = a year number
			Npc:says(_"First login from /dev/ttySO on %s %d", AfterTakeover_date_1, AfterTakeover_year, "NO_WAIT")
		else
			--; TRANSLATORS: %s = a date ,  %d = a year number
			Npc:says(_"Last login from /dev/ttyS0 on %s %d", AfterTakeover_date, AfterTakeover_year, "NO_WAIT")
		end
		AfterTakeover_date = AfterTakeover_date_1
		--; TRANSLATORS: %s = bot name
		Npc:says(_"Welcome to [b]%s[/b]!", Npc:get_translated_name(), "NO_WAIT")
		if (Npc:get_damage() >0) then
			Npc:says(_"Hardware Check : BOT DAMAGED", "NO_WAIT")
			--; TRANSLATORS: %s = bot type
			Npc:says(_"This %s unit could stand to be repaired.", Npc:get_type(), "NO_WAIT")
		end
		if (Aftertakeover_broadcast_mode) then
			if (Npc:get_damage() > 5) then
				Npc:says(_"BOTNET: UNIT TOO DAMAGED TO BROADCAST COMMANDS.", "NO_WAIT")
				Npc:says(_"Entering \"single node\" mode...")
				Aftertakeover_broadcast_mode = false
			else
				Npc:says(_"BOTNET: Most commands will be broadcast.", "NO_WAIT")
			end
		else
			Npc:says(_"SINGLE NODE: Commands will not be broadcast.", "NO_WAIT")
		end
		cli_says(terminal, "NO_WAIT")
		show("node1", "node11", "node12", "node13", "node47", "node99") -- top level options
		show("node3", "node20", "node30", "node40") -- repair_and_settings options
	end,

	{
		id = "node1",
		text = _"cd repair&settings/",
		echo_text = false,
		code = function()
			Tux:says(_"cd repair&settings/", "NO_WAIT")
			next("node2")
			push_topic("repair_and_settings")
		end,
	},
	{
		id = "node2",
		topic = "repair_and_settings",
		code = function()
			--; TRANSLATORS: first %s = Tux:get_player_name() ; second %s : Npc:get_type()
			terminal_sub = string.format(_"%s@hacked_%s/repair&settings: ~ # ", Tux:get_player_name(), Npc:get_type())
			cli_says(terminal_sub, "NO_WAIT")
		end,
	},
	{
		id = "node3",
		text = "cd ..",
		echo_text = false,
		topic = "repair_and_settings",
		code = function()
			Tux:says(_"cd ..", "NO_WAIT")
			cli_says(terminal, "NO_WAIT")
			pop_topic()
		end,
	},
	{
		id = "node11",
		text = _"./hold_position.sh",
		echo_text = false,
		code = function()
			Tux:says(_"./hold_position.sh", "NO_WAIT")
			Npc:says(_"Holding position.", "NO_WAIT")
			Npc:says(_"script V 1.0.2 (c) gnu.org, 2054", "NO_WAIT")
			Npc:says(_"Checking requirements...")
			Npc:says(_"Movement unit: Power-down... [Done].", "NO_WAIT")
			Npc:says(_"Status: All movement suppressed.", "NO_WAIT")
			if (Aftertakeover_broadcast_mode) then
				broadcast_bot_state("fixed")
			else
				Npc:set_state("fixed")
			end
			cli_says(terminal, "NO_WAIT")
			hide("node11") show("node12", "node13")
		end,
	},
	{
		id = "node12",
		text = _"./follow_me.sh",
		echo_text = false,
		code = function()
			Tux:says(_"./follow_me.sh", "NO_WAIT")
			Npc:says(_"Initiating tracking sequence.", "NO_WAIT")
			Npc:says(_"Movement unit: Enabled.", "NO_WAIT")
			--; TRANSLATORS: first %s = Tux:get_player_name() ; second %s : Npc:get_type()
			Npc:says(_"Acquiring lock on position of %s.", Tux:get_player_name(), "NO_WAIT")
			--; TRANSLATORS: %s =  Tux:get_player_name()
			Npc:says(_"Status: Following %s.", Tux:get_player_name(), "NO_WAIT")
			if (Aftertakeover_broadcast_mode) then
				broadcast_bot_state("follow_tux")
			else
				Npc:set_state("follow_tux")
			end
			cli_says(terminal, "NO_WAIT")
			hide("node12") show("node11", "node13")
		end,
	},
	{
		id = "node13",
		text = _"./move_freely.sh",
		echo_text = false,
		code = function()
			Tux:says(_"./move_freely.sh", "NO_WAIT")
			Npc:says(_"Enable movement.", "NO_WAIT")
			Npc:says(_"script V 1.0.5 (c) gnu.org, 2054", "NO_WAIT")
			Npc:says(_"Checking requirements...")
			Npc:says(_"Movement unit: Power-up... [Done].", "NO_WAIT")
			Npc:says(_"Resuming normal patrol operations... [Done]", "NO_WAIT")
			Npc:says(_"Status: Patrolling.", "NO_WAIT")
			if (Aftertakeover_broadcast_mode) then
				broadcast_bot_state("free")
			else
				Npc:set_state("free")
			end
			cli_says(terminal, "NO_WAIT")
			hide("node13") show("node11", "node12")
		end,
	},
	{
		id = "node20",
		text = _"./repair.plx",
		echo_text = false,
		topic = "repair_and_settings",
		code = function()
			local function calculate_bot_repair_penalty(constant, ability_value)
				ability_value = ability_value + Tux:get_program_revision("Repair equipment")
				return (1200 + Npc:get_max_health()) * math.exp(-0.02 * ability_value) * constant / 15000
				-- (1200 + Npc:get_max_health()) / 1500 is the bot_modifier, arranging the values between 0.8 (small bots) and 1 (big bots)
				-- math.exp(-0.02 * ability_value) is the ability_modifier, reducing the costs by ~2% per ability_level
				-- 1/10 is a constant to limit the repair_time to an upper bound of 30 seconds; it is adjusted to a 300 HP-bot (Sawmill, Cerebrum) to be the most expensive bot to be repaired
				-- the denominators 1500 and 10 are combined to 15000
			end

			Tux:says(_"./repair.plx", "NO_WAIT")
			damage = Npc:get_damage()
			if (damage > 0) then
				--; TRANSLATORS: %d = amount of valuable circuits
				Npc:says(_"Available amount of valuable circuits for repair: %d.", Tux:get_gold())
				-- Estimate the average repair costs: --
				AfterTakeover_repair_time = damage * calculate_bot_repair_penalty(1, Tux:get_program_revision("Check system integrity"))
				AfterTakeover_repair_circuits = math.max(1, damage * calculate_bot_repair_penalty(7, Tux:get_program_revision("Extract bot parts")))
				AfterTakeover_repair_heat = math.max(1, damage * calculate_bot_repair_penalty(3, Tux:get_program_revision("Hacking")))

				Aftertakeover_repair_time_estimation = math.ceil(AfterTakeover_repair_time * 1.2)
				Aftertakeover_repair_circuits_estimation = math.ceil(AfterTakeover_repair_time * 1.2)
				-- Get correct plural/singluar for "second(s)" and "circuit(s)"

				local repair_seconds = _"seconds"
				if (Aftertakeover_repair_time_estimation == 1) then
					repair_seconds = _"second"
				end

				local repair_circuits = _"circuits"
				if (Aftertakeover_repair_circuits_estimation == 1) then
					repair_circuits = _"circuit"
				end

				-- Display the maximum repair costs: --
				Npc:says(_"Repairs on %s will take less than %d %s, %d valuable %s, and %d heat.",
					Npc:get_translated_name(),
					Aftertakeover_repair_time_estimation,
					repair_seconds,
					Aftertakeover_repair_circuits_estimation,
					repair_circuits,
					math.ceil(AfterTakeover_repair_heat * 1.2))
				hide("node20")
				if (Tux:get_gold() < AfterTakeover_repair_circuits * 1.2) then
					Npc:says(_"You do not have enough valuable circuits to ensure repair of this %s unit.", Npc:get_type())
				elseif (Tux:get_cool() < AfterTakeover_repair_heat * 1.2) then
					Npc:says(_"You cannot dissipate enough heat to ensure repair of this %s unit.", Npc:get_type())
				else
					Npc:says(_"Do you want to start repair of this %s unit?", Npc:get_type())
					show("node21", "node22")
					push_topic("repair_YN")
				end
				-- Calculate the true repair costs: --
				AfterTakeover_repair_time = AfterTakeover_repair_time * (math.random() * 0.4 + 0.8)
				AfterTakeover_repair_circuits = math.ceil(AfterTakeover_repair_circuits * (math.random() * 0.4 + 0.8))
				AfterTakeover_repair_heat = math.ceil(AfterTakeover_repair_heat * (math.random() * 0.4 + 0.8))
			else
				Npc:says(_"%s is currently undamaged.", Npc:get_translated_name(), "NO_WAIT")
				hide("node20")
			end
			cli_says(terminal_sub, "NO_WAIT")
		end,
	},
	{
		id = "node21",
		--; TRANSLATORS: Y for yes
		text = _"Y",
		echo_text = false,
		topic = "repair_YN",
		code = function()
			--; TRANSLATORS: Y for yes
			Tux:says(_"Y", "NO_WAIT")
			Npc:says(_"Repair in progress.", "NO_WAIT")
			Npc:says(_"Logout to complete repair process.")
			AfterTakeover_repair = true
			pop_topic()
			hide("node20", "node21", "node22")
		end,
	},
	{
		id = "node22",
		--; TRANSLATORS: N for no
		text = _"N",
		echo_text = false,
		topic = "repair_YN",
		code = function()
			--; TRANSLATORS: N for no
			Tux:says(_"N", "NO_WAIT")
			Npc:says(_"Repair aborted.", "NO_WAIT")
			AfterTakeover_repair = false
			pop_topic()
			show("node20") hide("node21", "node22")
		end,
	},
	{
		id = "node30",
		text = _"./settings.plx",
		echo_text = false,
		topic = "repair_and_settings",
		code = function()
			next("node38")
			push_topic("settings.plx")
		end,
	},
	{
		id = "node31",
		text = _"confirmation of hcf.py",
		echo_text = false,
		topic = "settings.plx",
		code = function()
			Npc:says(_"Always ask for confirmation before execution of hcf.py? [Y/N]", "NO_WAIT")
			show("node32", "node33")
			push_topic("setting hcf.py confirmation Y/N")
		end,
	},
	{
		id = "node32",
		--; TRANSLATORS: Y for yes
		text = _"Y (always ask)",
		echo_text = false,
		topic = "setting hcf.py confirmation Y/N",
		code = function()
			Npc:says(_"Confirmation will now be asked before execution of hcf.py.")
			Aftertakeover_confirm_hcf = true
			next("node38")
			pop_topic()
		end,
	},
	{
		id = "node33",
		--; TRANSLATORS: N for no
		text = _"N (don't ask)",
		echo_text = false,
		topic = "setting hcf.py confirmation Y/N",
		code = function()
			Npc:says(_"hcf.py will be executed without asking for confirmation.")
			Aftertakeover_confirm_hcf = false
			next("node38")
			pop_topic()
		end,
	},
	{
		id = "node35",
		text = _"broadcast commands",
		echo_text = false,
		topic = "settings.plx",
		code = function()
			Npc:says(_"Broadcast commands to all units on level? [Y/N]", "NO_WAIT")
			show("node36", "node37")
			push_topic("enable broadcast Y/N")
		end,
	},
	{
		id = "node36",
		--; TRANSLATORS: Y for yes
		text = _"Y (enable broadcast)",
		echo_text = false,
		topic = "enable broadcast Y/N",
		code = function()
			Npc:says(_"Commands will be broadcast and executed by all bots on this level under your control.", "NO_WAIT")
			Npc:says(_"Entering \"botnet\" mode...")
			Aftertakeover_broadcast_mode = true
			next("node38")
			pop_topic()
		end,
	},
	{
		id = "node37",
		--; TRANSLATORS: N for no
		text = _"N (disable broadcast)",
		echo_text = false,
		topic = "enable broadcast Y/N",
		code = function()
			Npc:says(_"Commands will only be executed by this bot.", "NO_WAIT")
			Npc:says(_"Entering \"single node\" mode...")
			Aftertakeover_broadcast_mode = false
			next("node38")
			pop_topic()
		end,
	},
	{
		id = "node38",
		topic = "settings.plx",
		code = function()
			Tux:says(_"./settings.plx", "NO_WAIT")
			Npc:says(_"Welcome to the settings menu.", "NO_WAIT")
			Npc:says(_"Version: 1.82c", "NO_WAIT")
			--; TRANSLATORS: %s = sensor name
			Npc:says(_"Installed sensor: %s", Npc:get_sensor(), "NO_WAIT")
			Npc:says(_"No upgrades found.", "NO_WAIT")
			if (Npc:get_damage_ratio() > 0.5) then
				Npc:says(_"UNIT TOO DAMAGED TO BROADCAST COMMANDS.", "NO_WAIT")
			else
				show("node35")
			end
			Npc:says(_"Which setting should be changed?", "NO_WAIT")
			hide("node32", "node33", "node36", "node37") show("node31", "node70", "node80", "node74")
		end,
	},
	{
		id = "node40",
		text = _"./hostname",
		echo_text = false,
		topic = "repair_and_settings",
		code = function()
			Tux:says(_"./hostname", "NO_WAIT")
			Npc:says(_"Welcome to the hostname menu.", "NO_WAIT")
			Npc:says(_"Version: %s", get_game_version(),  "NO_WAIT")
			Npc:says(_"Current botname: [b]%s[/b]", Npc:get_translated_name(), "NO_WAIT")
			Npc:says(_"Select new name? [Y/N]", "NO_WAIT")
			cli_says("> ", "NO_WAIT")
			show("node41", "node42")
			push_topic("change hostname Y/N")
		end,
	},
	{
		id = "node41",
		text = _"Yes",
		echo_text = false,
		topic = "change hostname Y/N",
		code = function()
			--; TRANSLATORS: Y for yes
			Tux:says(_"Y", "NO_WAIT")
			cli_says(_"New Name: ", "NO_WAIT")

			new_name = user_input_string(string.format(_"Type a new name for this %s unit.", Npc:get_type()),
				string.format("%s %s %s",
					get_random(
						_"Bald",
						_"Brusque",
						_"Chic",
						_"Cuddly",
						_"Cute",
						_"Fickle",
						_"Fluffy",
						_"Fuzzy",
						_"Happy",
						_"Hyper",
						_"Laughing",
						_"Machavellian",
						_"Mad",
						_"Obscene",
						_"Ornery",
						_"Pompous",
						_"Shrewd"),
					get_random(
						_"Aardvark",
						_"Armadillo",
						_"Barracuda",
						_"Bat",
						_"Beetle",
						_"Bunny",
						_"Dodo",
						_"Duck",
						_"Fox",
						_"Frog",
						_"Gerbil",
						_"Gnu",
						_"Halibut",
						_"Hedgehog",
						_"Herring",
						_"Kitten",
						_"Koala",
						_"Lemur",
						_"Mackerel",
						_"Otter",
						_"Panda",
						_"Platypus",
						_"Puffin",
						_"Scarab",
						_"Shrew",
						_"Tapir",
						_"Trout",
						_"Tuna",
						_"Walrus"),
					Npc:get_type()))
			hide("node41", "node42") next("node43")
			pop_topic()
		end,
	},
	{
		id = "node42",
		text = _"No",
		echo_text = false,
		topic = "change hostname Y/N",
		code = function()
			--; TRANSLATORS: N for no
			Tux:says(_"N", "NO_WAIT")
			cli_says(terminal_sub, "NO_WAIT")
			hide("node41", "node42")
			pop_topic()
		end,
	},
	{
		id = "node43",
		topic = "repair_and_settings",
		code = function()
			Tux:says(new_name,"NO_WAIT")
			Npc:says(_"Confirm renaming from [b]%s[/b] to [b]%s[/b]? [Y/N]", Npc:get_translated_name(), new_name, "NO_WAIT")
			cli_says("> ", "NO_WAIT")
			show("node44", "node45")
			push_topic("confirm hostname Y/N")
		end,
	},
	{
		id = "node44",
		text = _"Yes",
		echo_text = false,
		topic = "confirm hostname Y/N",
		code = function()
			--; TRANSLATORS: Y for yes
			Tux:says(_"Y", "NO_WAIT")
			display_console_message(string.format(_"Renamed [b]%s[/b] to [b]%s[/b].", Npc:get_translated_name(), new_name))
			Npc:set_name(new_name)
			Npc:says(_"This %s unit is now designated: [b]%s[/b]", Npc:get_type(), Npc:get_translated_name(), "NO_WAIT")
			cli_says(terminal_sub, "NO_WAIT")
			hide("node44", "node45")
			pop_topic()
		end,
	},
	{
		id = "node45",
		text = _"No",
		echo_text = false,
		topic = "confirm hostname Y/N",
		code = function()
			--; TRANSLATORS: N for no
			Tux:says(_"N", "NO_WAIT")
			cli_says(terminal_sub, "NO_WAIT")
			hide("node44", "node45")
			pop_topic()
		end,
	},
	{
		id = "node47",
		text = _"./hcf.py",
		echo_text = false,
		code = function()
			Tux:says(_"./hcf.py", "NO_WAIT")
			if (Aftertakeover_confirm_hcf) then
				Npc:says(_"Are you really sure you want to destroy %s? Y/N", Npc:get_translated_name())
				show("node48", "node49")
				push_topic("confirm self-destruct Y/N")
			else
				next("node50")
			end
		end,
	},
	{
		id = "node48",
		text = _"Yes",
		echo_text = false,
		topic = "confirm self-destruct Y/N",
		code = function()
			Npc:says(_"Destruction confirmed.")
			hide("node48", "node49") next("node50")
			pop_topic()
		end,
	},
	{
		id = "node49",
		text = _"No",
		echo_text = false,
		topic = "confirm self-destruct Y/N",
		code = function()
			Npc:says(_"Destruction averted.")
			hide("node48", "node49")
			pop_topic()
		end,
	},
	{
		id = "node50",
		text = "PLEASE REPORT, BUG AFTERTAKEOVER NODE 50",
		echo_text = false,
		code = function()
			Aftertakeover_freezetime = (Npc:get_class() * 0.8)
			if (Aftertakeover_freezetime < 1) then
				Aftertakeover_freezetime = 1
			end

			local freezetime_seconds = _"seconds"
			if (Aftertakeover_freezetime == 1) then
				freezetime_seconds = _"second"
			end

			if (not (Aftertakeover_drain_attempt == "never")) then
				--; TRANSLATORS: Example: Draining this 123 unit will get you 5 HP but kill it and take 3 seconds.
				Npc:says(_"Draining this %s unit will get you %d HP but kill it and take %d %s.",
					Npc:get_type(),
					math.ceil(((Npc:get_max_health() - Npc:get_damage())/(difficulty_level()+1))),
					math.ceil(Aftertakeover_freezetime),
					freezetime_seconds)
			end

			if (Aftertakeover_drain_attempt == "ask") then
				Npc:says(_"Are you sure you want to drain this %s unit?", Npc:get_type())
				push_topic("drain_ask")
				show("node51", "node52")
			elseif (Aftertakeover_drain_attempt == "never") then
				next("node53")
				Aftertakeover_hcfnow = true
			elseif (Aftertakeover_drain_attempt == "auto") then
				next("node53")
			else
				Npc:says("ERROR OCCURRED; Aftertakeover node 50, state for Aftertakeover_drain_attempt not handled.")
			end
		end,
	},
	{
		id = "node51",
		text = _"Yes",
		echo_text = false,
		topic = "drain_ask",
		code = function()
			if (Aftertakeover_drain_attempt == "ask") then
				Tux:says(_"Yes")
			end
			hide("node51", "node52")
			next("node53")
			pop_topic()
		end,
	},
	{
		id = "node52",
		text = _"No",
		topic = "drain_ask",
		code = function()
			Npc:says(_"Bot not drained.")
			Npc:says(_"Running hcf.py...")
			Aftertakeover_hcfnow = true
			hide("node51", "node52")
			next("node53")
			pop_topic()
		end,
	},
	{
		id = "node53",
		code = function()
			if (Aftertakeover_hcfnow) then
				Npc:says(_"Executing: Halt and Catch Fire.", "NO_WAIT")
				if (math.random(1,10) > 2 ) then -- it shouldn't appear too often
					Npc:says(_"Warning! Cooling subsystems disabled.", "NO_WAIT")
					Npc:says(_"Warning! Spontaneous oxidization witH emis$ion of light aND heAt detecteddd in THE#main| procesIng unit.", "NO_WAIT")
					Npc:says(_"WArn|n*! SsTeM=#faiPure%%^#n 3 S 1()$++")
				else
					Npc:says(_"Warning: something seems wrong.")
					Npc:says(_"Error report:")
					Npc:says("Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", "NO_WAIT")
					Npc:says("Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.", "NO_WAIT")
					Npc:says("Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.", "NO_WAIT")
					Npc:says("Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")
					-- gettext strings left out on purpose
				end
				if (Dixon_mood) and
				   (Dixon_mood > 150) and
				   (Bruce_hurt) and
				   (Tux:has_quest("Opening access to MS Office")) and
				   (not tux_has_edge) then
					--; xgettext:no-c-format
					Npc:says(_"()%%#@(%% THE BLADE IS YOURS. )##%%*&%%*!")
					tux_has_edge = true
					Tux:add_item("Nobody's edge",1)
				end
				Npc:drop_dead()
			else
				if (takeover(Npc:get_class())) then -- bot intentionally drained, takeover won
					Npc:says(_"Bot drained.")
					freeze_tux_npc(Aftertakeover_freezetime)
					Npc:drain_health()
				else
					Npc:says(_"Failed to drain bot.")
					Npc:says(_"I am free!")
					npc_faction("crazy")
				end
				end_dialog()
			end
			AfterTakeover_repair = false
			Aftertakeover_hcfnow = false
		end,
	},
	{
		id = "node70",
		text = _"drain_bot_auto.setup",
		topic = "settings.plx",
		code = function()
			Npc:says(_"How do you want draining of bots to be handled?")

			if (Aftertakeover_drain_attempt == "auto") then
				Npc:says(_"Currently draining of bots is tried automatically.")
			elseif (Aftertakeover_drain_attempt == "never") then
				Npc:says(_"Currently draining of bots is never tried.")
			elseif (Aftertakeover_drain_attempt == "ask") then
				Npc:says(_"Currently it is asked if draining a bot is to be tried.")
			else
				Npc:says("BUG AFTERTAKEOVER node 70. not handled value for Aftertakeover_drain_attempt.")
			end

			show("node71", "node72", "node73")
			push_topic("drain_bot_attempt_state")
		end,
	},
	{
		id = "node71",
		text = _"Always try draining bots.",
		topic = "drain_bot_attempt_state",
		code = function()
			Aftertakeover_drain_attempt = "auto"
			hide("node71", "node72", "node73")
			pop_topic()
		end,
	},
	{
		id = "node72",
		text = _"Never try to drain a bot",
		topic = "drain_bot_attempt_state",
		code = function()
			Aftertakeover_drain_attempt = "never"
			hide("node71", "node72", "node73")
			pop_topic()
		end,
	},
	{
		id = "node73",
		text = _"Always ask if attempt to drain bot shall be ran.",
		topic = "drain_bot_attempt_state",
		code = function()
			Aftertakeover_drain_attempt = "ask"
			hide("node71", "node72", "node73")
			pop_topic()
		end,
	},
	{
		id = "node74",
		text = _"Reprogramm_bots_after_takeover.sh",
		topic = "settings.plx",
		code = function()
			if (Aftertakeover_reprogramm_bots_after_takeover) then
				Npc:says(_"Bots will be reprogrammed after takeover: [b]true[/b]")
			elseif not (Aftertakeover_reprogramm_bots_after_takeover) then
				Npc:says(_"Bots will be reprogrammed after takeover: [b]false[/b]")
			else -- ???
				Npc:says("ERROR REPROGRAMM BOTS AFTER TAKEOVER, NODE 74 UNHANDLED VALUE OF Aftertakeover_reprogramm_bots_after_takeover , PLEASE REPORT")
			end
			show("node75", "node76")
			push_topic("reprogramm_bots")
		end,
	},
	{
		id = "node75",
		text = _"Yes",
		topic = "reprogramm_bots",
		code = function()
			Npc:says(_"Bots will be reprogrammed after takeover: [b]true[/b]")
			reprogramm_bots_after_takeover(1) -- 1 = true in C
			Aftertakeover_reprogramm_bots_after_takeover = true
			hide("node75", "node76")
			pop_topic()
		end,
	},
	{
		id = "node76",
		text = _"No",
		topic = "reprogramm_bots",
		code = function()
			Npc:says(_"Bots will be reprogrammed after takeover: [b]false[/b]")
			reprogramm_bots_after_takeover(0) -- 0 = false in C
			Aftertakeover_reprogramm_bots_after_takeover = false
			hide("node75", "node76")
			pop_topic()
		end,
	},
	{
		id = "node80",
		text = _"leave settings.plx",
		echo_text = false,
		topic = "settings.plx",
		code = function()
			Npc:says(_"Settings saved", "NO_WAIT")
			Npc:says(_"Leaving settings.plx", "NO_WAIT")
			cli_says(terminal_sub, "NO_WAIT")
			hide("node31", "node35", "node80")
			pop_topic()
		end,
	},
	{
		id = "node99",
		text = "logout",
		echo_text = false,
		code = function()
			--; TRANSLATORS: 'logout' should be a command 
			Tux:says(_"logout","NO_WAIT")
			Npc:says(_"Closing remote connection...")
			if (AfterTakeover_repair) then
				Npc:heal()
				-- Apply repair costs: --
				freeze_tux_npc(AfterTakeover_repair_time)
				Tux:del_gold(AfterTakeover_repair_circuits)
				Tux:heat(AfterTakeover_repair_heat)
				AfterTakeover_repair = false
			end
			hide("node21")
			end_dialog()
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
		end,
	},
}
