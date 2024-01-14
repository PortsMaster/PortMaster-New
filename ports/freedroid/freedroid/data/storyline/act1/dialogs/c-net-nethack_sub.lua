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
	{
		id = "c-net-nethack_sub.everytime",
		code = function()
			if ((n_hp == nil) or (n_hp < 1)) then
				next("c-net-nethack_sub.node0")
			else
				next("c-net-nethack_sub.node80")
			end
		end,
	},
	{
		-- start a new nethack game
		id = "c-net-nethack_sub.node0",
		text = _"nethack",
		echo_text = false,
		code = function()
			hide("c-net-nethack_sub.node0")
			-- Start at level 1, amulet at level 7, win with amulet at level 1
			n_yendor = "no"
			n_level = 0 --level you are on
			n_yendorlevel = 7+math.random(6) --level where you get the Amulet of Yendor!
			if (won_nethack) then n_yendorlevel = n_yendorlevel*2 end
			n_hp = 0 --your hitpoints
			n_ac = 0 --your attack/armor
			n_tricks = 0 --your tricks
			n_emhp = 0 --enemy hitpoints
			n_emac = 0 --enemy attack/armor
			n_emname = ""--enemy name
			n_emtype = 0 --enemy type 0-nothing, 1-easy, 2-medium, 3-hard
			n_emiq = 100 --females need more health than this to use 'feminine wiles'

			n_role = "" --your job
			n_race = "" --your race
			n_sex = "" --your sex
			n_alignment = "" --your alignment
			n_god = "" --your goddess
			n_emgod = "" --your enemy god

			Npc:says(_"Shall I pick a character's race, role, gender and alignment for you? [b][y/n][/b]", "NO_WAIT")
			cli_says("> ", "NO_WAIT")
			n_randomchoice = "no"
			selection = 0
			show("c-net-nethack_sub.node1", "c-net-nethack_sub.node2")
			show("c-net-nethack_sub.node99") --Exit game option
		end,
	},
	{
		id = "c-net-nethack_sub.node1",
		text = _"yes",
		code = function()
			n_randomchoice = "yes" --Pick nethack race, role, gender, alignment randomly
			hide("c-net-nethack_sub.node1", "c-net-nethack_sub.node2")
			next("c-net-nethack_sub.node8")
		end,
	},
	{
		id = "c-net-nethack_sub.node2",
		text = _"no",
		code = function()
			hide("c-net-nethack_sub.node1", "c-net-nethack_sub.node2")
			n_randomchoice = "no"
			Npc:says(_"Choose your job.", "NO_WAIT")
			cli_says("> ", "NO_WAIT")
			show("c-net-nethack_sub.node3", "c-net-nethack_sub.node4", "c-net-nethack_sub.node5", "c-net-nethack_sub.node6", "c-net-nethack_sub.node7")
		end,
	},
	{
		id = "c-net-nethack_sub.node3",
		text = _"Archaeologist",
		code = function()
			selection = 1
			next("c-net-nethack_sub.node8")
		end,
	},
	{
		id = "c-net-nethack_sub.node4",
		text = _"Rogue",
		code = function()
			selection = 2
			next("c-net-nethack_sub.node8")
		end,
	},
	{
		id = "c-net-nethack_sub.node5",
		text = _"Ranger",
		code = function()
			selection = 3
			next("c-net-nethack_sub.node8")
		end,
	},
	{
		id = "c-net-nethack_sub.node6",
		text = _"Tourist",
		code = function()
			selection = 4
			next("c-net-nethack_sub.node8")
		end,
	},
	{
		id = "c-net-nethack_sub.node7",
		text = _"Wizard",
		code = function()
			selection = 5
			next("c-net-nethack_sub.node8")
		end,
	},
	{
		--hidden
		id = "c-net-nethack_sub.node8",
		text = "JOB ASSIGNMENT - BUG NODE 8 c-net sub nethack",
		echo_text = false,
		code = function()
			hide("c-net-nethack_sub.node3", "c-net-nethack_sub.node4", "c-net-nethack_sub.node5", "c-net-nethack_sub.node6", "c-net-nethack_sub.node7")
			if (selection == 0) then
				selection = math.random(6)
			end
			--actual assignment --
			if (selection == 1) then
				n_role = _"Archaeologist"
				n_hp = 0
				n_tricks = 2
			elseif (selection == 2) then
				n_role = _"Rogue"
				n_hp = 10
				n_tricks = 2
			elseif (selection == 3) then
				n_role = _"Ranger"
				n_hp = 20
				n_tricks = 0
			elseif (selection == 4) then
				n_role = _"Tourist"
				n_hp = -10
				n_tricks = 0
			elseif (selection == 5) then
				n_role = _"Wizard"
				n_hp = -20
				n_tricks = 5
			elseif (selection == 6) then -- Secret random-only job
				n_role = _"Geologist"
				n_hp = 15
				n_tricks = 1
			end

			selection = 0

			if (n_randomchoice == "no") then
				Npc:says(_"Choose your race.", "NO_WAIT")
				cli_says("> ", "NO_WAIT")
				show("c-net-nethack_sub.node9", "c-net-nethack_sub.node10", "c-net-nethack_sub.node11", "c-net-nethack_sub.node12")
			else
				next("c-net-nethack_sub.node13")
			end
		end,
	},
	{
		id = "c-net-nethack_sub.node9",
		text = _"human",
		code = function()
			selection = 1
			next("c-net-nethack_sub.node13")
		end,
	},
	{
		id = "c-net-nethack_sub.node10",
		text = _"elf",
		code = function()
			selection = 2
			next("c-net-nethack_sub.node13")
		end,
	},
	{
		id = "c-net-nethack_sub.node11",
		text = _"gnome",
		code = function()
			selection = 3
			next("c-net-nethack_sub.node13")
		end,
	},
	{
		id = "c-net-nethack_sub.node12",
		text = _"orc",
		code = function()
			selection = 4
			next("c-net-nethack_sub.node13")
		end,
	},
	{
		--hidden
		id = "c-net-nethack_sub.node13",
		code = function()
			hide("c-net-nethack_sub.node9", "c-net-nethack_sub.node10", "c-net-nethack_sub.node11", "c-net-nethack_sub.node12")
			if (selection == 0) then
				selection = math.random(5)
			end

			--actual assignment --
			if (selection == 1) then
				n_race = _"human"
				n_hp = n_hp + 100
				n_ac = 2
				n_tricks = n_tricks + 1
			elseif (selection == 2) then
				n_race = _"elf"
				n_hp = n_hp + 90
				n_ac = 1
				n_tricks = n_tricks + 4
			elseif (selection == 3) then
				n_race = _"gnome"
				n_hp = n_hp + 110
				a_ac = 2
				n_tricks = n_tricks + 2
			elseif (selection == 4) then
				n_race = _"orc"
				n_hp = n_hp + 120
				n_ac = 4
				n_tricks = n_tricks - 1
			elseif (selection == 5) then -- Secret random-only race
				n_race = _"troglodyte"
				n_hp = n_hp + 100
				n_ac = 6
			end

			selection = 0
			if (n_randomchoice == "no") then
				Npc:says(_"Choose your gender.", "NO_WAIT")
				cli_says("> ", "NO_WAIT")
				show("c-net-nethack_sub.node14", "c-net-nethack_sub.node15")
			else
				next("c-net-nethack_sub.node16")
			end
		end,
	},
	{
		id = "c-net-nethack_sub.node14",
		text = _"male",
		code = function()
			selection = 1
			next("c-net-nethack_sub.node16")
		end,
	},
	{
		id = "c-net-nethack_sub.node15",
		text = _"female",
		code = function()
			selection = 2
			next("c-net-nethack_sub.node16")
		end,
	},
	{
		--hidden
		id = "c-net-nethack_sub.node16",
		code = function()
			hide("c-net-nethack_sub.node14", "c-net-nethack_sub.node15")
			if (selection == 0) then
				selection = math.random(2)
			end

			if (selection == 1) then
				n_sex = _"male"
				n_hp = n_hp + 10
			else
				n_sex = _"female"
			end
			next("c-net-nethack_sub.node20")
		end,
	},
	{
		--hidden
		id = "c-net-nethack_sub.node20",
		code = function()
			-- Goddess/Gods don't give you a choice
			local random_var = math.random(3)
			if (random_var == 1) then n_alignment = _"a good"
			elseif (random_var == 2) then n_alignment = _"a chaotic"
			elseif (random_var == 3) then n_alignment = _"an evil"
			end

			random_var = math.random(3)
			if (random_var == 1) then
				n_god = "Inara"
				n_tricks = n_tricks - 1
			elseif (random_var == 2) then
				n_god = "Freyja"
				n_hp = n_hp + 10
			elseif (random_var == 3) then
				n_god = "Shakti"
				n_ac = n_ac + 1
			end

			random_var = math.random(3)
			if (random_var == 1) then
				n_emgod = "Loki"
				n_tricks = n_tricks - 1
			elseif (random_var == 2) then
				n_emgod = "Sutekh"
				n_hp = n_hp - 10
			elseif (random_var == 3) then
				n_emgod = "Imkhullu"
				n_ac = n_ac - 1
			end

			if (n_ac<1) then n_ac = 0 end
			if (n_tricks<1) then n_tricks = 1 end

			--; TRANSLATORS: you are $alignment, $sex, $race, $role
			Npc:says(_"Hello, welcome to Nethack! You are %s %s %s %s.", n_alignment, n_sex, n_race, n_role, "NO_WAIT")
			--; TRANSLATORS: boths %s represent a name of a god
			Npc:says(_"Your goddess, [b]%s[/b] desires the Amulet of Yendor, which the evil god [b]%s[/b] has hidden at the bottom of this dungeon.", n_god, n_emgod, "NO_WAIT")
			Npc:says(_"Return with the [b]Amulet of Yendor[/b], and you shall be rewarded!", "NO_WAIT")
			Npc:says(_"You are all alone on the surface. There is a stairway down.", "NO_WAIT")
			show("c-net-nethack_sub.node63")
			cli_says("> ", "NO_WAIT")
		end,
	},
	{
		-- Description + Random Encounter
		id = "c-net-nethack_sub.node30",
		code = function()
			if (n_level < 0) then n_level = 0 end
			hide("c-net-nethack_sub.node62", "c-net-nethack_sub.node63", "c-net-nethack_sub.node30")
			if (n_level == n_yendorlevel) then -- At Yendor level
				if (n_yendor == "no") then -- get yendor
					Npc:says(_"The door closes behind you.", "NO_WAIT")
					Npc:says(_"You find the [b]Amulet of Yendor[/b], and take it and suddenly feel a compulsion to go down, into the depths.", "NO_WAIT")
					Npc:says(_"%s awaits you at the surface", n_god, "NO_WAIT")
					n_yendor = "yes"
					Npc:says(_"There is only an exit into the depths.", "NO_WAIT")
					next("c-net-nethack_sub.node63")
				else
					Npc:says_random(_"You find nothing new here.",
									_"You find a Fake Amulet of Yendor.",
									_"You find emptiness.",
									_"You find an empty room.", "NO_WAIT")
					next("c-net-nethack_sub.node61")
				end
			elseif (n_level == 0) then -- At surface
				if (n_yendor == "no") then
					if(n_hp<70) then
						n_hp = 70
						Npc:says_random(_"You drink from the spring at the entrance to the cave.",
										_"You make a quick trip to the hospital.", "NO_WAIT")
					end
					--; TRANSLATORS:  %s = a god
					Npc:says_random(string.format(_"%s looks at you with impatience and points you back to the entrance of the dungeon.", n_god),
									--; TRANSLATORS:  %s = a god
									string.format(_"You find your goddess, %s, at lunch. She points back the way you came.", n_god),
									--; TRANSLATORS:  %s = a god
									string.format(_"You come up and nearly catch %s bathing. You quickly head back the way you came.", n_god), "NO_WAIT")
					hide("c-net-nethack_sub.node62")
					next("c-net-nethack_sub.node63")
				else -- have Amulet of Yendor -- WIN!
					--; TRANSLATORS:  %s = a god
					Npc:says(_"You present the [b]Amulet of Yendor[/b] to [b]%s[/b] and you are rewarded with everlasting life.", n_god, "NO_WAIT")
					Npc:says(_"You win!", "NO_WAIT")
					--; TRANSLATORS: you ascended a $alignment, $sex, $race, $role in nethack
					display_console_message(_"You ascended a %s %s %s %s in Nethack!", n_alignment, n_sex, n_race, n_role)
					if (not won_nethack) then
						won_nethack = true
						Tux:improve_program("Hacking")
						display_big_message(_"By ascending in Nethack, you have improved your Hacking ability!")
					end
					next("c-net-nethack_sub.node70")
				end
			else
				--; TRANSLATORS: %s = n_level
				Npc:says(_"You are on level [b]%s[/b]:", n_level, "NO_WAIT")
				--Describe the level
				Npc:says_random(_"You find yourself in a series of passages all alike.",
								_"You find yourself in an underground office building.",
								_"You find yourself in a labyrinth, with 1980's music playing mysteriously.",
								_"You find yourself inside a Cretaceous limestone cave.",
								_"You find yourself in an abandoned coal mine.",
								_"You find yourself in a flooded room.",
								_"You find yourself in a room filled with huge, transparent, hexagonal dipyramidal crystals.",
								_"You find yourself in a passage filled with bones from the ancient past.",
								_"You find yourself in a room filled with fresh bones.",
								_"You find yourself in a room filled with rotting corpses.",
								_"You find yourself in a goblin village.",
								_"You find yourself in an abandoned gold mine.",
								_"You find yourself. You are in a yoga room.",
								_"You lose yourself in a misty passageway.",
								_"You find yourself in a room filled with blinking lights.",
								_"You find yourself in a lava tube.",
								_"You find yourself lost in darkness.", "NO_WAIT")

				--Random happenings:
				local random_var = math.random(5)+n_level
				-- Correct for superpowering:
				if (n_hp > 100) then
					level_correction = math.floor((n_hp - 100)/10 + (n_ac - 7))
					if (level_correction - random_var > 0) then
						random_var = random_var + math.random(level_correction - random_var)
					end
				end
				if (random_var > 18) then
					n_emtype = 6 -- even more difficult enemy
					--get_random(...) returns a random argument
					n_emname = get_random(_"angry woodchuck", _"platypus", _"duck", _"puffin", _"superintelligent slime mold", _"internet oracle")
					n_emac = 10 + math.random(3)
					n_emhp = 200 + math.random(20)
					n_emiq = 200 + math.random(20)
				elseif (random_var > 14) then
					n_emtype = 5 -- extreamly difficult enemy
					n_emname = get_random(_"dragon", _"dwarf", _"basilisk", _"penguin", _"grue")
					n_emac = 7 + math.random(3)
					n_emhp = 150 + math.random(20)
					n_emiq = 120 + math.random(20)
				elseif (random_var > 11) then
					n_emtype = 4 -- very difficult enemy
					n_emname = get_random(_"balrog", _"daemon", _"demagogue", _"ex-girlfriend", _"jabberwock", _"ringwrath")
					n_emac = 5 + math.random(3)
					n_emhp = 130 + math.random(20)
					n_emiq = 70 + math.random(20)
				elseif (random_var > 9) then
					n_emtype = 4 -- difficult enemy
					n_emname = get_random(_"clippy", _"ghoul", _"ninja", _"sober pirate", _"cockatrice", _"chickatrice", _"mind flayer", _"marilith", _"vrock", _"nalfeshnee")
					n_emac = 3 + math.random(3)
					n_emhp = 120 + math.random(20)
					n_emiq = 70 + math.random(20)
				elseif (random_var > 7) then
					n_emtype = 3 -- intermediate enemy
					n_emname = get_random(_"politician", _"gremlin", _"incubus", _"succubus", _"awkward turtle", _"minotaur", _"goblin", _"shade", _"drunk pirate")
					n_emac = 1 + math.random(3)
					n_emhp = 90 + math.random(20)
					n_emiq = 50 + math.random(20)
				elseif (random_var > 5) then -- no enemy (free parking)!
					n_emname = get_random(_"darkness", _"nothing", _"air", _"steam", _"shadow", _"chair", _"pet rock", _"bag of bones", _"inanimate carbon rod", _"mirage", _"hyperintelligent shade of blue")
					n_emtype = 0 -- not an enemy
				elseif (random_var > 3) then
					n_emtype = 2 -- easy enemy
					n_emname = get_random(_"woodchuck", _"MS employee", _"rooster", _"gnome", _"lawyer", _"wraith")
					n_emac = math.random(3)
					n_emhp = 51 + math.random(20)
					n_emiq = 51 + math.random(20)
				else
					n_emtype = 1 -- very easy enemy
					n_emname = get_random(_"bureaucrat", _"snail", _"banana slug")
					n_emac = math.random(2)
					n_emhp = 1 + math.random(20)
					n_emiq = 1 + math.random(20)
				end
				--; TRANSLATORS: %s = enemy name
				Npc:says_random(string.format(_"A wild [b]%s[/b] appears!", n_emname),
								--; TRANSLATORS: %s = enemy name
								string.format(_"You notice a [b]%s[/b] in front of you.", n_emname),
								--; TRANSLATORS: %s = enemy name
								string.format(_"You turn around and see a [b]%s[/b] right behind you!", n_emname),
								--; TRANSLATORS: %s = enemy name
								string.format(_"A [b]%s[/b] jumps out in front of you!", n_emname),
								--; TRANSLATORS: %s = enemy name
								string.format(_"You sneak up upon a [b]%s[/b].", n_emname), "NO_WAIT")
				Npc:says(_"Your stats are: [b]%s[/b] attack/armor, [b]%s[/b] tricks, and [b]%s[/b] health.", n_ac, n_tricks, n_hp, "NO_WAIT")
				show("c-net-nethack_sub.node50", "c-net-nethack_sub.node51", "c-net-nethack_sub.node53", "c-net-nethack_sub.node54")
				if ( (n_tricks>0) or (n_sex == _"female") ) then show("c-net-nethack_sub.node52") end
				cli_says("> ", "NO_WAIT")
			end
		end,
	},
	{
		id = "c-net-nethack_sub.node50",
		text = _"Attack",
		code = function()
			if (n_emtype == 0) then --inanimate object
				Npc:says_random(string.format(_"You attack the inanimate %s.", n_emname),
								_"You go to attack, but then think better.",
								string.format(_"You charge the %s and strike a mighty blow...", n_emname),
								_"You are puzzled as to what you plan to attack.",
								string.format(_"You throw a fireball at the %s. It is super effective!", n_emname),
								string.format(_"You attack the %s.", n_emname), "NO_WAIT")
				next("c-net-nethack_sub.node61")
			else
				local damage = math.random((n_ac+1)*10)
				if (damage > n_emac) then --check if you hit
									--; TRANSLATORS %s1 = enemy name, %s2 = digit
					Npc:says_random(string.format(_"Your fireball hits the %s causing %s damage.", n_emname, damage),
									--; TRANSLATORS %s1 = enemy name, %s2 = digit
									string.format(_"A bolt from your crossbow hits the %s causing %s damage.", n_emname, damage),
									--; TRANSLATORS %s2 = digit
									string.format(_"Your credit card causes a massive papercut of %s damage.", damage),
									--; TRANSLATORS %s1 = enemy name, %s2 = digit
									string.format(_"You freeze the middle of the %s causing %s damage.", n_emname, damage),
									--; TRANSLATORS %s1 = enemy name, %s2 = digit
									string.format(_"Your fist of wrath smites the %s causing internal bleeding and %s damage.", n_emname, damage),
									--; TRANSLATORS %s1 = enemy name, %s2 = digit
									string.format(_"You throw your bola at the %s, causing it to trip and take %s damage.", n_emname, damage), "NO_WAIT")
					n_emhp = n_emhp - damage + n_emac
				else -- no hit
									--; TRANSLATORS: %s = enemy name
					Npc:says_random(string.format(_"Your arrow misses the %s.", n_emname),
									--; TRANSLATORS: %s = enemy name
									string.format(_"Blow after blow is rained down upon the %s but they all miss.", n_emname),
									--; TRANSLATORS: %s = enemy name
									string.format(_"Your sword glances off the magical aura of the %s.", n_emname),
									--; TRANSLATORS: %s = enemy name
									string.format(_"Your really awesome attack took too long to power up, and the %s moved.", n_emname), "NO_WAIT")
				end
				next("c-net-nethack_sub.node60")
			end
		end,
	},
	{
		id = "c-net-nethack_sub.node51",
		text = _"Run",
		code = function()
			hide("c-net-nethack_sub.node50", "c-net-nethack_sub.node51", "c-net-nethack_sub.node52", "c-net-nethack_sub.node53", "c-net-nethack_sub.node54")
			local random_var = math.random(3)
			if (random_var > 2) then
				Npc:says_random(_"You escape!",
								_"You run away!",
								_"You chicken out!", "NO_WAIT")
				next("c-net-nethack_sub.node62")
				n_level=n_level-1
			elseif (random_var > 1) then
				Npc:says_random(_"You escape!",
								_"You run away!",
								_"You chicken out!", "NO_WAIT")
				next("c-net-nethack_sub.node63")
			else
								--; TRANSLATORS: %s = enemy name
				Npc:says_random(string.format(_"The %s throws a bola at you, tripping you and stopping your escape", n_emname),
								_"You stand there like a deer in the headlights.",
								--; TRANSLATORS: %s = enemy name
								string.format(_"You try to go, but the %s grabs you.", n_emname),
								--; TRANSLATORS: %s = enemy god name
								string.format(_"%s strikes you with fear, and you cannot move.", n_emgod),
								--; TRANSLATORS: %s = enemy name
								string.format(_"The %s tackles you and pins you to the floor.", n_emname),
								_"You go to run, but you trip over your shoelace.", "NO_WAIT")
				next("c-net-nethack_sub.node60")
			end
		end,
	},
	{
		id = "c-net-nethack_sub.node52",
		text = _"Trick",
		code = function()
			if (n_tricks>0) then
				n_tricks = n_tricks - 1
				if (math.random(3)>1) then
									--; TRANSLATORS: %s = enemy name
					Npc:says_random(string.format(_"You toss a rock. The sound distracts the %s", n_emname),
									_"You toss a smoke-bomb and escape.",
									--; TRANSLATORS: %s = enemy name
									string.format(_"You stumble over a rock, creating a chain of reactions, ending in the tunnel collapsing on the %s.", n_emname),
									_"You stab yourself with a fake dagger and pretend to be dead.",
									--; TRANSLATORS: %s = enemy name
									string.format(_"You walk like a duck, quack like a duck and swim like a duck. The %s figures you must be a duck.", n_emname),
									_"You pretend to be a mime.",
									_"You pull a rabbit from your top hat.", "NO_WAIT")
					next("c-net-nethack_sub.node61")
				else
									--; TRANSLATORS:  %s = enemy name
					Npc:says_random(string.format(_"The %s is not impressed by your tricks.", n_emname),
									--; TRANSLATORS:  %s = enemy name
									string.format("%s has seen this one before, and is not impressed.", n_emname),
									--; TRANSLATORS:  %s = enemy name
									string.format(_"You try to act like a duck, but %s has an elephant and a lighter, and you don't want to be the punchline.", n_emname),
									--; TRANSLATORS:  %s = enemy name
									string.format(_"%s sees your trick, and shows you an even better one.", n_emname), "NO_WAIT")
					next("c-net-nethack_sub.node60")
				end
			elseif (n_sex == _"female") then
				Npc:says(_"Not having any tricks left, you resort to you trying your feminine wiles.", "NO_WAIT")
				if (n_hp > n_emiq) then
					if (math.random(6)>1) then
										--; TRANSLATORS:  %s = enemy name
						Npc:says_random(string.format(_"You succeed getting past the %s.", n_emname),
										--; TRANSLATORS:  %s = enemy name
										string.format(_"You distract the %s long enough to escape.", n_emname),
										--; TRANSLATORS:  %s = enemy name
										string.format(_"Your plight is noticed by a hero, who valiantly rescues you from the dastardly %s.", n_emname), "NO_WAIT")
						next("c-net-nethack_sub.node61")
					else
										--; TRANSLATORS:  %s = enemy name
						Npc:says_random(string.format(_"The %s casts change gender on you.", n_emname),
										--; TRANSLATORS:  %s = enemy name
										string.format(_"The %s curses you.", n_emname),
										--; TRANSLATORS:  %s = enemy name
										string.format(_"The %s casts a polymorph spell.", n_emname),
										_"The Random Number God strikes you, changing your gender.", "NO_WAIT")
						n_sex = _"male"
						--; TRANSLATORS n_alignment, n_sex, m_race, n_role, 
						Npc:says(_"You are now %s %s %s %s.", n_alignment, n_sex, n_race, n_role , "NO_WAIT")
						next("c-net-nethack_sub.node60")
					end
				else
									--; TRANSLATORS: %s = enemy name
					Npc:says_random(string.format(_"The %s notes your physique, but has too high of an IQ to be impressed.", n_emname),
									--; TRANSLATORS: %s = enemy name
									string.format(_"%s might be more malleable if you were in better health.", n_emname), "NO_WAIT")
					next("c-net-nethack_sub.node60")
				end
			else
				next("c-net-nethack_sub.node60")
			end
		end,
	},
	{
		id = "c-net-nethack_sub.node53",
		text = _"Pray",
		code = function()
			local random_var = math.random(6)
			if ( random_var == 6) then --16% chance:
				Npc:says(_"Your goddess %s comes to your aid and gives you strength.", n_god, "NO_WAIT")
				n_ac = n_ac + 2
				n_hp = n_hp + 51
				Npc:says(_"Your stats are: [b]%s[/b] attack/armor, [b]%s[/b] tricks, and [b]%s[/b] health.", n_ac, n_tricks, n_hp, "NO_WAIT")
			elseif ( random_var == 5 ) then --16% chance:
				Npc:says(_"Your goddess %s comes to your aid and teaches you a new trick.", n_god, "NO_WAIT")
				n_ac = n_ac + 2
				n_tricks = n_tricks + 1
				Npc:says(_"Your stats are: [b]%s[/b] attack/armor, [b]%s[/b] tricks, and [b]%s[/b] health.", n_ac, n_tricks, n_hp, "NO_WAIT")
			elseif (random_var > 2) then -- 54% chance:
				Npc:says_random(string.format(_"Your enemy %s bestows some burdens upon you.", n_emgod),
								string.format(_"%s overhears your prayers and curses you.", n_emgod),
								_"While you were praying a leprechaun stole your sword.",
								_"While you were praying a hermit crab moved into your helmet. It's his now.", "NO_WAIT")
				n_ac = n_ac - 2
				n_tricks = n_tricks - 1
				if (n_ac < 1) then n_ac =0 end
				if (n_tricks < 1) then n_tricks =0 end
				Npc:says(_"Your stats are: [b]%s[/b] attack/armor, [b]%s[/b] tricks, and [b]%s[/b] health.", n_ac, n_tricks, n_hp, "NO_WAIT")
			else -- 54% chance:
				Npc:says_random(_"Nothing happens.",
								string.format(_"%s can't take your prayers right now, please leave a message...", n_god),
								_"Twice nothing happens.",
								string.format(_"%s left her cellphone at home today.", n_god),
								_"Something, somewhere else happened.",
								_"The Random Number God is not swayed by your petty prayers.", "NO_WAIT")
			end
			next("c-net-nethack_sub.node60")
		end,
	},
	{
		id = "c-net-nethack_sub.node54",
		text = _"Xyzzy",
		code = function()
			if (math.random(10)>1) then --90% chance:
				Npc:says_random(_"Nothing happens.",
								_"Surprisingly, nothing happens.",
								_"You are shocked, SHOCKED, to find nothing happens.",
								_"Time was frozen then unfrozen but for you, nothing happens.",
								_"Unexpectedly, nothing happens.",
								_"You wait for a moment, then, suddenly, nothing happens.",
								_"Twice nothing happens.", "NO_WAIT")
				if (n_emtype == 0) then
					Npc:says_random(_"You take a short nap.",
									_"You meditate.",
									_"You check your e-mail.",
									_"You sip a cup of late-afternoon tea in quiet retrospection.",
									_"You take a power nap.",
									_"You take a long nap.",
									_"You take a cat nap.", "NO_WAIT")
					n_temphp = n_hp + math.random(51)
					if (n_temphp < 256) then
						n_hp = n_temphp
					else
						if (n_hp < 256) then n_hp = 256 end
					end
					Npc:says(_"You feel refreshed.", "NO_WAIT")
					--; TRANSLATORS: n_ac n_tricks n_hp
					Npc:says(_"Your stats are: [b]%s[/b] attack/armor, [b]%s[/b] tricks, and [b]%s[/b] health.", n_ac, n_tricks, n_hp, "NO_WAIT")
					next("c-net-nethack_sub.node61")
				else
					next("c-net-nethack_sub.node60")
				end
			else --10% chance:
				Npc:says_random(_"Suddenly you find yourself teleported to the next level.",
								_"Everything goes black.",
								_"Everything goes white.",
								_"Suddenly, there is nothing.",
								_"Surprisingly, something happens.",
								_"Everything goes cold and dark.",
								_"You feel a sharp pain in your neck, and everything goes blue.", "NO_WAIT")
				if (math.random(2) > 1) then
					n_level = n_level + 3
				else
					n_level = n_level - 3
				end
				next("c-net-nethack_sub.node30")
			end
		end,
	},
	{
		id = "c-net-nethack_sub.node60",
		code = function()
			hide("c-net-nethack_sub.node50", "c-net-nethack_sub.node51", "c-net-nethack_sub.node52", "c-net-nethack_sub.node53", "c-net-nethack_sub.node54")
			if (n_emtype == 0) then
				next("c-net-nethack_sub.node61")
			else
				if (n_emhp < 1) then
									--; TRANSLATORS %s = enemy name
					Npc:says_random(string.format(_"The %s passed out.", n_emname),
									--; TRANSLATORS %s = enemy name
									string.format(_"The %s suddenly is gone.",  n_emname),
									--; TRANSLATORS %s = enemy name
									string.format(_"The %s ran away.",  n_emname),
									--; TRANSLATORS %s = enemy name
									string.format(_"You push the %s off a convenient cliff.", n_emname), "NO_WAIT")
					-- Rewards:
					local random_var = math.random(1,4)
					if (random_var == 4) then --Improve AC
						Npc:says_random(_"You find prayer beads invoking the goodwill of the Random Number God.",
										_"You find a lightning rod.",
										_"You find a sword of greater death.",
										_"You find a vorpal dagger.",
										_"You find a breast plate of awesome.",
										_"You find a spell of doom.",
										_"You find a helmet of fire.",
										_"You find a left boot of anti-fungus.",
										_"You find a right boot of speed.",
										_"You find a shank.",
										_"You find a kevlar vest.",
										_"You find a Hawaiian t-shirt.",
										_"You find a credit card.",
										_"You find a sharpened pencil.",
										_"You find a broken glass bottle.",
										_"You find a 'weapon'.", "NO_WAIT")
						n_ac = n_ac + (math.random(n_emtype + 1) +1)
					elseif (random_var == 3) then --Improve HP
						Npc:says_random(_"You find a bandage and put it on.",
										_"A nurse patches some of your wounds.",
										--; TRANSLATORS: %s = god name
										string.format(_"You drink a bottle of greater healing. %s sends some salve to sooth your wounds.", n_god),
										_"You find an aloe vera plant.",
										_"You apply some sunscreen from your backpack.",
										_"You decide that you are healthier than you thought.", "NO_WAIT")
						n_hp = n_hp +(n_emtype * 10 * math.random(3))
						Npc:says_random(_"Your health improves.",
										_"You feel more vigorous.",
										_"Your arm spontaneously regenerates.",
										_"Your leg grows back.",
										_"Your acne clears up.",
										_"You stop hemorrhaging blood.", "NO_WAIT")
					elseif (random_var == 2) then --Get a trick!
						Npc:says_random(_"You find a top hat with a rabbit.",
										_"You find a deck of cards.",
										_"You find a coin with two heads.",
										_"You find a stick with two snakes wrapped around it.",
										_"You find a magic wand.",
										_"You find a skipping stone.",
										_"You find a trick dagger.", "NO_WAIT")
						n_tricks=n_tricks+1

					elseif(random_var == 1) then --Status change
						random_var = math.random(1,5)
						if (random_var == 1) then --become good
							Npc:says(_"You reform your wicked ways, and join the side of good.", "NO_WAIT")
											--; TRANSLATORS: %s = enemy god name
							Npc:says_random(string.format(_"%s is unhappy about this.", n_emgod),
											--; TRANSLATORS: %s = god name
											string.format(_"%s likes this.", n_god), "NO_WAIT")
							n_alignment = _"a good"
						elseif (random_var == 2) then --become evil
							Npc:says(_"The urge to sin fills you, you now are evil!", "NO_WAIT")
											--; TRANSLATORS %s = enemy god name
							Npc:says_random(string.format(_"%s is happy about this.", n_emgod),
											--; TRANSLATORS: %s = god name
											string.format(_"%s is unhappy about this.", n_god), "NO_WAIT")
							n_alignment=_"an evil"
						elseif (random_var == 3) then --become neutral
							Npc:says(_"You decide that good and evil are two sides of the same coin, so you take the coin.", "NO_WAIT")
							n_alignment = _"a neutral"
							--; TRANSLATORS: %s 1 = god name  %s 2 = enemy god name
							Npc:says(_"Both %s and %s don't know how to feel about this.", n_god, n_emgod, "NO_WAIT")
						else --change gender
							Npc:says_random(_"You put on a tarnished belt, and you feel something strange happen.",
											_"You have been cursed.",
											_"You have been blessed.",
											_"You drink from a sparkling well, and something weird happens.",
											_"You try on the shiny necklace you find.", "NO_WAIT")

							if (n_sex == _"female") then n_sex=_"male" else n_sex=_"female" end
						end
					--; TRANSLATORS: you ascended a $alignment, $sex, $race, $role in nethack
						Npc:says(_"You are now %s %s %s %s.", n_alignment, n_sex, n_race, n_role, "NO_WAIT")
					end
					n_emtype = 0 --no more monsters
				else
					damage = math.random((n_emac+1)*10)
					if (damage > n_ac) then
										--; TRANSLATORS: enemy name, damage (digit)
						Npc:says_random(string.format(_"The devious %s stabs you, causing %s damage.", n_emname, damage-n_ac),
										--; TRANSLATORS: enemy name, damage (digit)
										string.format(_"You suffer %s damage as the %s tosses you up into the air like a ragdoll.", damage-n_ac, n_emname),
										--; TRANSLATORS: enemy name, damage (digit)
										string.format(_"The %s breathes fire at you, burning your map and causing %s damage.", n_emname, damage-n_ac),
										--; TRANSLATORS: enemy name, damage (digit)
										string.format(_"The %s throws an exploding banana at you, but you duck, so it only causes %s damage.", n_emname, damage-n_ac),
										--; TRANSLATORS: enemy name, damage (digit)
										string.format(_"The %s hits you with its best shot, causing %s damage.", n_emname, damage-n_ac),
										--; TRANSLATORS: enemy name, damage (digit)
										string.format(_"The %s hits you against the wall, causing %s of hurt.", n_emname, damage-n_ac),
										--; TRANSLATORS: enemy name, damage (digit)
										string.format(_"The %s snipes you with an arrow causing %s damage.", n_emname, damage-n_ac),
										--; TRANSLATORS: enemy name, damage (digit)
										string.format(_"The %s bites you causing %s damage.", n_emname, damage-n_ac), "NO_WAIT")
						n_hp = n_hp - damage + n_ac
					else
						Npc:says_random(string.format(_"You dodge a blow from the %s.", n_emname),
										string.format(_"%s tries to hit you, but misses.", n_emname),
										string.format(_"%s blow hits your cap of cool, causing no damage.", n_emname),
										string.format(_"%s pokes you really hard. You are annoyed.", n_emname),
										string.format(_"%s takes a swing at you, but can't reach you from there.", n_emname), "NO_WAIT")
					end
				end

				-- Did you survive?
				if (n_hp < 1) then --No :-(
					Npc:says_random(_"You died.",
									_"A Valkyrie carries you off to Valhalla.",
									_"Hermes, with Death and Sleep, asks if you've seen his Caduceus anywhere, and then brings you to the river Leith.",
									_"Your soul finds itself travelling along the path of the moon, far away from your broken body.",
									_"You are fully one with everything. Your battered body no longer concerns you.",
									_"You failed to enlist the Random Number God to your side. You died.", "NO_WAIT")
					Npc:says(_"Game over.", "NO_WAIT")
					next("c-net-nethack_sub.node70")
				else --Yes :-)
					--; TRANSLATORS: all numbers
					Npc:says(_"Your stats are: [b]%s[/b] attack/armor, [b]%s[/b] tricks, and [b]%s[/b] health.", n_ac, n_tricks, n_hp, "NO_WAIT")
					if (n_emhp < 1) then
						next("c-net-nethack_sub.node61")
					else
						show("c-net-nethack_sub.node50", "c-net-nethack_sub.node53", "c-net-nethack_sub.node54")

						if (math.random(3)>2) then
							show("c-net-nethack_sub.node51")
						end --you can't always run
						
						if ((n_tricks>0) or (n_sex == _"female")) then
							show("c-net-nethack_sub.node52")
						end

						cli_says("> ", "NO_WAIT")
					end
				end
			end
		end,
	},
	{
		id = "c-net-nethack_sub.node61",
		code = function()
			hide("c-net-nethack_sub.node50", "c-net-nethack_sub.node51", "c-net-nethack_sub.node52", "c-net-nethack_sub.node53", "c-net-nethack_sub.node54")
			if ((n_yendor == "yes") and (math.random(3)>2)) then --have the Amulet of Yendor
				--; TRANSLATORS: digit
				Npc:says(_"You come to the end of level %s and the [b]Amulet of Yendor[/b] compels you down, deeper into the depths.", n_level, "NO_WAIT")
				next("c-net-nethack_sub.node63")
			else --still need the Amulet of Yendor
				--; TRANSLATORS: digit
				Npc:says(_"You come to the end of level %s and see a way up and a way down. Which do you choose?", n_level, "NO_WAIT")
				if (math.random(3)>1) then show("c-net-nethack_sub.node53") end
				show("c-net-nethack_sub.node62", "c-net-nethack_sub.node63")
				cli_says("> ", "NO_WAIT")
			end
		end,
	},
	{
		id = "c-net-nethack_sub.node62",
		text = _"Go Up",
		code = function()
			Npc:says_random(_"You climb up the ladder with care.",
							_"You shimmy up the crevasse.",
							_"You ascend the Gothic staircase.",
							_"You untie the balloon.",
							_"You wave your arms vigorously and slowly levitate up.",
							_"You grab a nice rope someone left, and climb up it.",
							_"Using magic, you cut foot and handholds into the rock, and use them.",
							_"Reaching a state of total ONE-ness with the world, you break your earthly bonds, and rise upwards.",
							_"You climb the cliff-face.",
							_"You jump up, and pull yourself up to the next level.", "NO_WAIT")
			n_level=n_level-1
			next("c-net-nethack_sub.node30")
		end,
	},
	{
		id = "c-net-nethack_sub.node63",
		text = _"Go Down",
		code = function()
			Npc:says_random(_"You rappel down the pit to the level below.",
							_"You lower yourself using footholds cut long ago into the living earth.",
							_"You take the staircase down to the lower level.",
							_"By playing with the levers before you, you teleport into the depths below.",
							_"You take out a shovel and start digging. Eventually you hit rock bottom.",
							_"You carefully climb down the ladder.",
							_"You jump into the darkness and land in the depths.", "NO_WAIT")
			n_level=n_level+1
			next("c-net-nethack_sub.node30")
		end,
	},
	{
		id = "c-net-nethack_sub.node70",
		code = function()
			n_hp = 0
			hide("c-net-nethack_sub.node20", "c-net-nethack_sub.node62", "c-net-nethack_sub.node63", "c-net-nethack_sub.node30", "c-net-nethack_sub.node50", "c-net-nethack_sub.node51", "c-net-nethack_sub.node52", "c-net-nethack_sub.node53", "c-net-nethack_sub.node54", "c-net-nethack_sub.node60", "c-net-nethack_sub.node99")
			next("after-c-net-nethack_sub")
		end,
	},
	{
		id = "c-net-nethack_sub.node80",
		code = function()
			--; TRNSLATORS: n_alignment, n_role, n_race, n_sex, n_god, n_level
			Npc:says(_"Save game detected: %s %s %s %s in service to [b]%s[/b] on level [b]%d[/b].", n_alignment, n_role, n_race, n_sex, n_god, n_level, "NO_WAIT")
			if (n_yendor == "yes") then
				Npc:says(_"Save game has the [b]Amulet of Yendor[/b]!", "NO_WAIT")
			end
			cli_says("> ", "NO_WAIT")
			show("c-net-nethack_sub.node81", "c-net-nethack_sub.node82", "c-net-nethack_sub.node83", "c-net-nethack_sub.node99")
		end,
	},
	{
		id = "c-net-nethack_sub.node81",
		text = _"Show stats",
		code = function()
			--; TRANSLATORS: n_ac, n_tricks, n_hp
			Npc:says(_"[b]%d[/b] attack/armor, [b]%d[/b] tricks, and [b]%d[/b] health", n_ac, n_tricks, n_hp, "NO_WAIT")
			cli_says("> ", "NO_WAIT")
			hide("c-net-nethack_sub.node81")
		end,
	},
	{
		id = "c-net-nethack_sub.node82",
		text = _"Load Character",
		code = function()
			--; TRANSLATORS: both god names
			Npc:says_random(string.format(_"[b]%s[/b], the enemy of your goddess [b]%s[/b], plans your demise with glee.", n_emgod, n_god),
							--; TRANSLATORS: god name
							string.format(_"The vile god [b]%s[/b] cackles that you will again flee from the dungeon in terror!", n_emgod),
							--; TRANSLATORS: both god names
							string.format(_"[b]%s[/b] blesses your return to the dungeon.", n_god), "NO_WAIT")
			hide("c-net-nethack_sub.node81", "c-net-nethack_sub.node82", "c-net-nethack_sub.node83")
			if (n_level < 1) then
				next("c-net-nethack_sub.node30")
			elseif (n_emhp < 1) then
				next("c-net-nethack_sub.node61")
			else
				next("c-net-nethack_sub.node84")
			end
		end,
	},
	{
		id = "c-net-nethack_sub.node83",
		text = _"New Game",
		code = function()
			hide("c-net-nethack_sub.node81", "c-net-nethack_sub.node82", "c-net-nethack_sub.node83")
			next("c-net-nethack_sub.node0")
		end,
	},
	{
		id = "c-net-nethack_sub.node84",
		code = function()
			--; TRANSLATORS: n_ac, n_tricks, n_hp
			Npc:says(_"Your stats are: [b]%d[/b] attack/armor, [b]%d[/b] tricks, and [b]%d[/b] health.", n_ac, n_tricks, n_hp, "NO_WAIT")
			--; TRANSLATORS: n_emname
			Npc:says(_"A [b]%s[/b] is before you. What do you do?", n_emname, "NO_WAIT")
			show("c-net-nethack_sub.node50", "c-net-nethack_sub.node51", "c-net-nethack_sub.node53", "c-net-nethack_sub.node54")
			if ((n_tricks>0) or (n_sex == _"female")) then show("c-net-nethack_sub.node52") end
			cli_says("> ", "NO_WAIT")
		end,
	},
	{
		id = "c-net-nethack_sub.node99",
		text = _"End Game",
		code = function()
			hide("c-net-nethack_sub.node20", "c-net-nethack_sub.node62", "c-net-nethack_sub.node63", "c-net-nethack_sub.node30", "c-net-nethack_sub.node50", "c-net-nethack_sub.node51", "c-net-nethack_sub.node52", "c-net-nethack_sub.node53", "c-net-nethack_sub.node54", "c-net-nethack_sub.node60", "c-net-nethack_sub.node99")
			next("after-c-net-nethack_sub")
		end,
	},
}
