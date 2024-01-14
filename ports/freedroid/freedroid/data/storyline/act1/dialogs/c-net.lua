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
		play_sound("effects/Menu_Item_Deselected_Sound_0.ogg")
		-- name = Tux:get_player_name() -- We need to generate the option text of option 0 to use this properly
		if (c_net_terminals_disabled) then
			Npc:says(" . ")
			end_dialog()
		else
			Npc:says(_"Welcome to the Community Network.", "NO_WAIT")
			cli_says(_"Login : ", "NO_WAIT")
			if (knows_c_net_users) then
				show("node1", "node2", "node3")
			end
			show("node0", "node99")
		end
		hide("node10", "node11", "node12", "node13", "node14", "node15", "node16", "node20", "node21", "node23", "node24", "node30", "node31", "node80", "node81", "node82", "node83", "node85", "node86")
	end,

	------------------------------
	-- c-net-nethack_sub
	--
	{
		topic = "c-net-nethack_sub",
		generator = include("c-net-nethack_sub"),
	},
	--
	------------------------------

	{
		id = "node0",
		--; TRANSLATORS: use lowercase for translation
		text = _"guest",
		echo_text = false,
		code = function()
			c_net_username = Tux:get_player_name()
			c_net_prompt = c_net_username .. "@c-net:~$"
				--; TRANSLATORS: use lowercase for translation
			Tux:says(_"guest", "NO_WAIT")
			if (not c_net_terminal_logged_in) then
				c_net_terminal_logged_in = true
				Npc:says(_"First time login detected.")
				Npc:says(_"Please enter your name", "NO_WAIT")
				cli_says(_"Name : ", "NO_WAIT")
				Tux:says(c_net_username)
				--; TRANSLATORS: %s = c_net_username
				Npc:says(_"Please set password for your personalized guest login, %s", c_net_username, "NO_WAIT")
				Npc:says(_"Use at least one lower case letter, one upper case letter, one number, and one symbol.", "NO_WAIT")
				cli_says(_"Password : ", "NO_WAIT")
				Tux:says(_"******")
			else
				cli_says(_"Name : ", "NO_WAIT")
				Tux:says(c_net_username, "NO_WAIT")
				cli_says(_"Password : ", "NO_WAIT")
				Tux:says(_"******", "NO_WAIT")
			end
			Npc:says(_"Last login from /dev/tty3 on unknown", "NO_WAIT")
			cli_says(c_net_prompt, "NO_WAIT")
			show("node10", "node20", "node30", "node80", "node99") hide("node0", "node1", "node2", "node3")
		end,
	},
	{
		id = "node1",
		text = "root",
		echo_text = false,
		code = function()
			Tux:says("root", "NO_WAIT")
			cli_says(_"Password : ", "NO_WAIT")
			Tux:says("******")
			--if (not knows_root_password) then
			next("node9")
			--else
			-- c_net_username = "root"
			-- c_net_prompt = c_net_username .. "@c-net:~$"
			-- Npc:says(_"Last login from /dev/tty3 on unknown" , "NO_WAIT")
			-- cli_says(c_net_prompt, "NO_WAIT")
			-- show("node10", "node20", "node30", "node80", "node99") hide("node0", "node1", "node2", "node3")
			--end
		end,
	},
	{
		id = "node2",
		text = "lily",
		echo_text = false,
		code = function()
			Tux:says("lily", "NO_WAIT")
			cli_says(_"Password : ", "NO_WAIT")
			if (not know_lily_password) then
				Tux:says("******")
				next("node9")
			else
				Tux:says("****")
				c_net_username = "lily"
				c_net_prompt = c_net_username .. "@c-net:~$"
				Npc:says(_"Last login from /dev/tty3 on unknown" , "NO_WAIT")
				cli_says(c_net_prompt, "NO_WAIT")
				show("node10", "node20", "node30", "node80", "node99") hide("node0", "node1", "node2", "node3")
			end
		end,
	},
	{
		id = "node3",
		text = "cpain",
		echo_text = false,
		code = function()
			Tux:says("cpain", "NO_WAIT")
			cli_says(_"Password: ", "NO_WAIT")
			--if (not knows_sorenson_password) then
			Tux:says("******")
			next("node9")
			--else
			-- Tux:says("************************************")
			-- c_net_username = "cpain"
			-- c_net_prompt = c_net_username .. "@c-net:~$"
			-- Npc:says(_"Last login from /dev/tty3 on unknown" , "NO_WAIT")
			-- cli_says(c_net_prompt, "NO_WAIT")
			-- show("node10", "node20", "node30", "node80", "node99") hide("node0", "node1", "node2", "node3")
			--end
		end,
	},
	{
		id = "node9",
		code = function()
			Npc:says(_"Login incorrect", "NO_WAIT")
			Npc:says(_"Connection to c-net terminated.")
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
	{
		-- ../ date finger users whoami
		id = "node10",
		text = "cd info_commands/",
		echo_text = false,
		code = function()
			c_net_prompt = c_net_username .. "@c-net:~/info_commands$"
			Npc:says(" ", "NO_WAIT")
			cli_says(c_net_prompt, "NO_WAIT")
			show("node11", "node12", "node13", "node14", "node15", "node16") hide("node10", "node20", "node30", "node80", "node99")
		end,
	},
	{
		id = "node11",
		text = "cd ../",
		echo_text = false,
		code = function()
			c_net_prompt = c_net_username .. "@c-net:~$"
			Npc:says(" ", "NO_WAIT")
			cli_says(c_net_prompt, "NO_WAIT")
			show("node10", "node20", "node30", "node80", "node99") hide("node11", "node12", "node13", "node14", "node15", "node16")
		end,
	},
	{
		id = "node12",
		text = "date",
		echo_text = false,
		code = function()
			Tux:says("date", "NO_WAIT")
			local day, hour, minute = game_date()
			--; TRANSLATORS: It shows the ingame date in format: Day day, hour:minute
			Npc:says(_"Day %d, %02d:%02d", day, hour, minute, "NO_WAIT")
			cli_says(c_net_prompt, "NO_WAIT")
		end,
	},
	{
		id = "node13",
		text = "finger",
		echo_text = false,
		code = function()
			Tux:says("finger", "NO_WAIT")
			knows_c_net_users = true
			--; TRANSLATORS: this reperesents the head of a table
			Npc:says(_"Login Tty Name", "NO_WAIT")
			Npc:says("bossman tty7 Spencer", "NO_WAIT")
			Npc:says("cpain tty5 Sorenson", "NO_WAIT")
			--; TRANSLATORS: %s=Tux:get_player_name()
			Npc:says("guest tty3 %s ", Tux:get_player_name(), "NO_WAIT")
			Npc:says("lily tty2 Lily Stone", "NO_WAIT")
			cli_says(c_net_prompt, "NO_WAIT")
		end,
	},
	{
		id = "node14",
		text = "users",
		echo_text = false,
		code = function()
			Tux:says("users", "NO_WAIT")
			Npc:says("bossman cpain guest lily", "NO_WAIT")
			knows_c_net_users = true
			cli_says(c_net_prompt, "NO_WAIT")
		end,
	},
	{
		id = "node15",
		text = "whoami",
		echo_text = false,
		code = function()
			Tux:says("whoami", "NO_WAIT")
			Npc:says(c_net_username, "NO_WAIT")
			cli_says(c_net_prompt, "NO_WAIT")
		end,
	},
	{
		id = "node16",
		text = "uname",
		echo_text = false,
		code = function()
			Tux:says("uname", "NO_WAIT")
			Npc:says("Nkernel", "NO_WAIT")
			cli_says(c_net_prompt, "NO_WAIT")
		end,
	},
	{
		-- ../ ls readdrive ./statistics.pl
		id = "node20",
		text = "cd file_commands/",
		echo_text = false,
		code = function()
			c_net_prompt = c_net_username .. "@c-net:~/file_commands$"
			Npc:says(" ", "NO_WAIT")
			cli_says(c_net_prompt, "NO_WAIT")
			show("node21", "node23", "node24", "node70") hide("node10", "node20", "node30", "node80", "node99")
		end,
	},
	{
		id = "node21",
		text = "cd ../",
		echo_text = false,
		code = function()
			c_net_prompt = c_net_username .. "@c-net:~$"
			Npc:says(" ", "NO_WAIT")
			cli_says(c_net_prompt, "NO_WAIT")
			show("node10", "node20", "node30", "node80", "node99") hide("node21", "node23", "node24", "node70")
		end,
	},
	{
		id = "node23",
		text = _"mountdisk.sh",
		echo_text = false,
		code = function()
			Tux:says(_"./mountdisk.sh", "NO_WAIT")
			if (Tux:has_item_backpack("Kevin's Data Cube")) then
				Npc:says(_"Mounting volume \"Kevins_Security_File\"...")
				Npc:says(_"Private memory and/or virtual address space exhausted.", "NO_WAIT")
				Npc:says(_"Not enough free memory to load data file.", "NO_WAIT")
			elseif (Tux:has_quest("Deliverance")) and
			       (not Tux:done_quest("Deliverance")) and
			       (Tux:has_item_backpack("Data cube")) then
				Npc:says(_"List for Spencer:")
				Npc:says("Alastra, Maria Grazia", "NO_WAIT")
				Npc:says("Arana, Pedro", "NO_WAIT")
				Npc:says("Badea, Catalin", "NO_WAIT")
				Npc:says("Bourdon, Pierre", "NO_WAIT")
				Npc:says("Castellan, Simon", "NO_WAIT")
				Npc:says("Cipicchio, Ted", "NO_WAIT")
				Npc:says("Danakian, Hike", "NO_WAIT")
				Npc:says("Degrande, Samuel", "NO_WAIT")
				Npc:says("Gill, Andrew A. ", "NO_WAIT")
				Npc:says("Griffiths, Ian", "NO_WAIT")
				Npc:says("Hagman, Nick", "NO_WAIT")
				Npc:says("Herron, Clint", "NO_WAIT")
				Npc:says("Huillet, Arthur", "NO_WAIT")
				Npc:says("Huszics, Stefan", "NO_WAIT")
				Npc:says("Infrared", "NO_WAIT")
				Npc:says("James", "NO_WAIT")
				Npc:says("Kangas, Stefan", "NO_WAIT")
				Npc:says("Kremer, David", "NO_WAIT")
				Npc:says("Kruger, Matthias", "NO_WAIT")
				Npc:says("Kucia, Jozef", "NO_WAIT")
				Npc:says("Matei, Pavaluca", "NO_WAIT")
				Npc:says("McCammon, Miles", "NO_WAIT")
				Npc:says("Mendelson, Michael", "NO_WAIT")
				Npc:says("Mourujarvi, Esa-Matti", "NO_WAIT")
				Npc:says("Mustonen, Ari", "NO_WAIT")
				Npc:says("Newton, Simon", "NO_WAIT")
				Npc:says("Offermann, Sebastian", "NO_WAIT")
				Npc:says("Parramore, Kurtis", "NO_WAIT")
				Npc:says("Pepin-Perreault, Nicolas")
				Npc:says("Picciani, Arvid", "NO_WAIT")
				Npc:says("Pitoiset, Samuel", "NO_WAIT")
				Npc:says("Pradet, Quentin", "NO_WAIT")
				Npc:says("Prix, Johannes", "NO_WAIT")
				Npc:says("Prix, Reinhard", "NO_WAIT")
				Npc:says("rudi_s", "NO_WAIT")
				Npc:says("Ryushu, Zombie", "NO_WAIT")
				Npc:says("Salmela, Bastian", "NO_WAIT")
				Npc:says("Starminn", "NO_WAIT")
				Npc:says("Solovets, Alexander", "NO_WAIT")
				Npc:says("Swietlicki, Karol", "NO_WAIT")
				Npc:says("Tetar, Philippe", "NO_WAIT")
				Npc:says("Thor", "NO_WAIT")
				Npc:says("Voots, Ryan", "NO_WAIT")
				Npc:says("Wood, JK", "NO_WAIT")
				Npc:says("Winterer, Armin", "NO_WAIT")
				if (not deliverance_datacube_c_net_list) then
					Tux:update_quest("Deliverance", _"I found a terminal in the town which could read the data cube Francis gave me. It looks like there was a list of names on it, but I have no clue what's the deal with these names.")
					deliverance_datacube_c_net_list = true
				end
			else
				Npc:says(_"no disk found", "NO_WAIT")
			end
			cli_says(c_net_prompt, "NO_WAIT")
		end,
	},
	{
		id = "node24",
		text = _"statistics.pl",
		echo_text = false,
		code = function()
			Tux:says("./statistics.pl", "NO_WAIT")
			Npc:says(_"Corrupted file.", "NO_WAIT")
			-- Npc:says(_"Bot #Dead# Tux #Hacked/Failed#Ratio", "NO_WAIT")
			-- Npc:says(print_stats(),"NO_WAIT")
			cli_says(c_net_prompt, "NO_WAIT")
		end,
	},
	{
		id = "node30",
		text = "cd documents/",
		echo_text = false,
		code = function()
			c_net_prompt = c_net_username .. "@c-net:~/documents$"
			Tux:says("cd documents/", "NO_WAIT")
			if (c_net_username =="root") then
				show("node66")
			end
			--if (c_net_username == "guest") then
			--elseif (c_net_username =="lily") then -- no special files yet
			--elseif (c_net_username =="cpain") then -- no special files yet
			--end
			cli_says(c_net_prompt, "NO_WAIT")
			show("node31") hide("node10", "node20", "node30", "node80", "node99")
		end,
	},
	{
		id = "node31",
		text = "cd ../",
		echo_text = false,
		code = function()
			c_net_prompt = c_net_username .. "@c-net:~$"
			Npc:says(" ", "NO_WAIT")
			cli_says(c_net_prompt, "NO_WAIT")
			show("node10", "node20", "node30", "node80", "node99") hide("node31")
		end,
	},
	{
		id = "node66",
		text = _"forkBOMB.sh -arm bomb",
		code = function()
			Npc:says(_"bomb armed", "NO_WAIT")
			cli_says(c_net_prompt, "NO_WAIT")
			show("node67", "node68")
		end,
	},
	{
		id = "node67",
		text = _"forkBOMB.sh -disarm bomb",
		code = function()
			Npc:says(_"bomb defused", "NO_WAIT")
			cli_says("root@c-net:~$", "NO_WAIT")
			hide("node67", "node68") show("node66")
		end,
	},
	{
		id = "node68",
		text = _"forkBOMB.sh -execute",
		code = function()
			c_net_terminals_disabled = true
			display_big_message(_"Terminals Disabled")
			Npc:says(_"Script run. After logout this terminal will be disabled.", "NO_WAIT")
			cli_says(_"root@c-net:~$", "NO_WAIT")
			-- Tux:add_xp(30) -- Eventually make this a quest goal.
		end,
	},
	{
		id = "node70",
		text = _"radio.sh",
		code = function()
			--; TRANSLATORS: "tracks" refers to music songs/music
			Npc:says(_"Valid tracks:", "NO_WAIT")
			Npc:says("Ambience, Bleostrada, HellFortressEntrance, ImperialArmy, NewTutorialStage, TechBattle, TheBeginning, underground, AmbientBattle, hellforce, HellFortressTwo, menu, Suspicion, temple, town")

			local try_again_radio = true

			while (try_again_radio) do
				local track = user_input_string(_"please enter track")
				if (track == "Ambience" ) or
				   (track == "AmbientBattle" ) or
				   (track == "Bleostrada" ) or
				   (track == "hellforce" ) or
				   (track == "HellFortressEntrance" ) or
				   (track == "HellFortressTwo" ) or
				   (track == "ImperialArmy" ) or
				   (track == "menu" ) or
				   (track == "NewTutorialStage" ) or
				   (track == "Suspicion" ) or
				   (track == "TechBattle" ) or
				   (track == "temple" ) or
				   (track == "TheBeginning" ) or
				   (track == "town" ) or
				   (track == "underground" ) or
				   (running_benchmark()) then
					switch_background_music(track .. ".ogg")
					town_track = track
					try_again_radio = false
					next("node20")
				elseif (track == "exit" ) then
					try_again_radio = false
					next("node20")
				else
					--; TRANSLATORS: "tracks" refers to music songs/music
					Npc:says(_"WARNING, '%s' not a valid track.", track)
					--; TRANSLATORS: "'exit'" must not be translated
					Npc:says(_"enter 'exit' to exit.")
					Npc:says(_"Please retry.")
					Npc:says(_"Valid tracks:", "NO_WAIT")
					Npc:says("Ambience, Bleostrada, HellFortressEntrance, ImperialArmy, NewTutorialStage, TechBattle, TheBeginning, underground, AmbientBattle, hellforce, HellFortressTwo, menu, Suspicion, temple, town")
				end
			end

		end,
	},
	{
		id = "node80",
		text = "cd games/",
		echo_text = false,
		code = function()
			Npc:says(" ", "NO_WAIT")
			c_net_prompt = c_net_username .. "@c-net:~/games$"
			cli_says(c_net_prompt, "NO_WAIT")
			show("node81", "node82", "node83", "node85", "node86") hide("node10", "node20", "node30", "node80", "node99")
		end,
	},
	{
		id = "node81",
		text = "cd ../",
		echo_text = false,
		code = function()
			c_net_prompt = c_net_username .. "@c-net:~$"
			Npc:says(" ", "NO_WAIT")
			cli_says(c_net_prompt, "NO_WAIT")
			show("node10", "node20", "node30", "node80", "node99") hide("node81", "node82", "node83", "node85", "node86")
		end,
	},
	{
		id = "node82",
		text = "nethack",
		echo_text = false,
		code = function()
			Tux:says("./nethack", "NO_WAIT")
			push_topic("c-net-nethack_sub")
			-- call c-net-nethack_sub subdialog
			next("c-net-nethack_sub.everytime")
		end,
	},
	{
		-- called after the end of c-net-nethack_sub subdialog
		id = "after-c-net-nethack_sub",
		code = function()
			pop_topic()
			cli_says(c_net_prompt, "NO_WAIT")
		end,
	},
	{
		id = "node83",
		text = _"global_thermonuclear_war",
		echo_text = false,
		code = function()
			Tux:says(_"./global_thermonuclear_war", "NO_WAIT")
			Npc:says_random(_"Sorry, only winning move is not to play. New game?",
							_"Mankind exterminated. You lost!",
							_"No victory possible. LOSER! Play again?",
							_"Everyone dies, new game?", "NO_WAIT")
			cli_says(c_net_prompt, "NO_WAIT")
		end,
	},
	{
		id = "node85",
		text = _"tetris",
		echo_text = false,
		code = function()
			Tux:says(_"./tetris", "NO_WAIT")
			Npc:says("Never gonna give you up,")
			Npc:says("Never gonna let you down,")
			Npc:says("Never gonna run around and desert you.")
			Npc:says("Never gonna make you cry,")
			Npc:says("Never gonna say goodbye,")
			Npc:says("Never gonna tell a lie and hurt you.")
			--left out gettext markers on purpose
			cli_says(c_net_prompt, "NO_WAIT")
			hide("node85")
		end,
	},
	{
		id = "node86",
		text = "progress_quest",
		echo_text = false,
		code = function()
			Tux:says("./progress_quest", "NO_WAIT")
			if (not playing_progress_quest) then
				playing_progress_quest = true
				Npc:says(_"Roll your Stats.")
				hide("node81", "node82", "node83", "node85", "node86")
				next("node87")
			else
				Npc:says(_"You are already playing Progress Quest:")
				Npc:says_random(_"You are selling an item!",
								_"You are killing a creature!",
								_"You are gaining a level!",
								_"You are casting a spell!")
				cli_says(c_net_prompt, "NO_WAIT")
			end
		end,
	},
	{
		id = "node87",
		code = function()
			local str = math.random(0,6) + math.random(0,6) + math.random(0,6)
			local con = math.random(0,6) + math.random(0,6) + math.random(0,6)
			local dex = math.random(0,6) + math.random(0,6) + math.random(0,6)
			local int = math.random(0,6) + math.random(0,6) + math.random(0,6)
			local wis = math.random(0,6) + math.random(0,6) + math.random(0,6)
			local cha = math.random(0,6) + math.random(0,6) + math.random(0,6)
			Npc:says(_"You rolled Stats of STR: [b]%d[/b], CON: [b]%d[/b], DEX: [b]%d[/b], INT: [b]%d[/b], WIS: [b]%d[/b], CHA: [b]%d[/b].", str, con, dex, int, wis, cha, "NO_WAIT")
			show("node88", "node89")
		end,
	},
	{
		id = "node88",
		text = _"Accept Character",
		echo_text = false,
		code = function()
			--; TRANSLATORS: "Progress Quest" should not be translated
			Npc:says(_"Welcome to Progress Quest!")
			cli_says(c_net_prompt, "NO_WAIT")
			show("node81", "node82", "node83", "node85", "node86") hide("node88", "node89")
		end,
	},
	{
		id = "node89",
		text = _"Reroll Character",
		echo_text = false,
		code = function()
			next("node87")
		end,
	},
	{
		id = "node99",
		text = "logout",
		echo_text = false,
		code = function()
			Tux:says("logout", "NO_WAIT")
			--; TRANSLATORS: "c-net" should probably not be translated
			Npc:says(_"Connection to c-net closed.")
			-- set_internet_login_time()
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
}
