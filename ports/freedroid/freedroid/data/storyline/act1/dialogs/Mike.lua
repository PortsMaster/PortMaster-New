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
--[[WIKI
PERSONALITY = { "Robotic" },
PURPOSE = "$$NAME$$ controls arena functions in the game.",
BACKSTORY = "$$NAME$$ is the Arena Manager for the Red Guard.",
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

local tr_rankings = {
	novice	 = _"Novice",
	elite	 = _"Elite",
	champion = _"Champion",
}

local function start_arena(level) 
	arena_current_level = level
	arena_next_wave = 1

	-- Prepare the arena
	change_obstacle_state("Arena-ChangingRoomDoor", "opened")
	change_obstacle_state("Arena-RingEntrance", "opened")

	next("arena_start")
end

return {
	FirstTime = function()
        show("botnode1")
	end,

	EveryTime = function()
		if (not has_met("Mike")) then
			Tux:says(_"Euh...hello?")
			Npc:says(_"Salutation: Welcome to the arena.")
			Npc:says(_"Presentation: The robot is M.I.K.E.", "NO_WAIT")
			Npc:says(_"Modern Interactive Kombat Executive.")
			Npc:says(_"Tasks: Multiple assignments have been programmed.")
			Npc:says(_"Suggestion: The arena enrollment program is open.")
			show("arena_enroll")
		else
			if (arena_current_level ~= nil) then
				if (arena_won) then
					Npc:says(_"You have won the arena.")
					if (not done_quest("Novice Arena")) then
						--change_obstacle_state("NoviceArenaExitDoor", "opened")
						display_console_message(_"Novice arena cleared!")
						display_big_message(_"Novice arena cleared!")
						Tux:end_quest("Novice Arena", _"I won the fight in the novice arena.")
					end
					if (arena_ranking == "novice") then
						arena_ranking = "elite"
					elseif (arena_ranking == "elite" and arena_current_level == "elite") then
						arena_ranking = "champion"
					end
					show("arena_ready")
				elseif (arena_withdraw) then
					Npc:says(_"Information: You have withdrawn the arena.")
					Npc:says(_"Note: You can restart it another time.")
					--; TRANSLATORS: This sentence use the english adage 'Better safe than sorry'. Use the equivalent adage of the language you translate.
					Npc:says(_"Advice: It is better to be safe than sorry.")
					show("arena_ready")
				else
					Npc:says(_"Information: The arena is already started.")
					show("arena_info_rules", "arena_info_where") hide("arena_ready")
				end
			else
				Npc:says_random(_"Hello.", _"Hi.")

				local salutations = {
					_"Salutations: Welcome to the arena.",
					_"Salutations: M.I.K.E. says hello."
				}
				if (arena_ranking ~= nil) then 
					table.insert(salutations, _"Salutations: Greeting, Fighter.") 
				end

				Npc:says_random(table.unpack(salutations))
			end
		end

		show("tasks", "end")
		hide("sandwich", "sandwich_sudo")
	end,
	{
		id = "arena_enroll",
		text = _"I want to fight.",
		code = function()
			arena_enroll = true,
			Npc:says(_"Excellent: New challengers are greatly appreciated.")
			Npc:says(_"Registration: Patience, it will take a little moment.")
			Npc:says(_"[b]...Analysis of the bio-signature.[/b]")
			Npc:says(_"[b]...Processing the ranking value.[/b]")
			Npc:says(_"[b]...Saving personal characteristics.[/b]")
			-- TODO: Tux can choose a nickname. This can let's other NPC react to it.
			Npc:says(_"[b]...Fighter registered.[/b]")
			--; TRANSLATORS: %s = Tux:get_player_name()
			Npc:says(_"Compliment: %s is the new challenger.", Tux:get_player_name())
			-- TODO: Detect the level of Tux to set a higher ranking.
			arena_ranking = "novice"
			--; TRANSLATORS: %s is the ranking of Tux in the arena.
			Npc:says(_"Information: Your ranking has been established to be '%s'.", tr_rankings[arena_ranking])
			Npc:says(_"Planning: Arena matches are freely scheduled.")
			Npc:says(_"Advice: Begin fighting when you are ready.")
			show("arena_ready") hide("arena_enroll")
		end,
	},
	{
		id = "arena_ready",
		text = _"I'm ready to fight.",
		code = function()
			arena_current_level = nil
			arena_won = false
			arena_withdraw = false

			--; TRANSLATORS: %s is the ranking of Tux in the arena.
			Npc:says(_"Information: Your ranking has been established to be '%s'.", tr_rankings[arena_ranking])

			if (not arena_info_rank) then
				Npc:says(_"Explanation: The arena is divided into three rank levels.")
				Npc:says(_"First: Novice - new to the arena and bot-fighting.")
				Npc:says(_"Second: Elite - you are a good fighter who already knows the routine.")
				Npc:says(_"Third: Champion - nothing can stop you, you seek the harder challenges.")
				Npc:says(_"Every time you win, you are raised to the next rank.")
				Npc:says(_"Advice: Last rank has the most difficult challenge.")
				arena_info_rank = true
			end

			if (arena_ranking == "champion") then
				Npc:says(_"Choice: You can fight at the 'Novice', 'Elite' and 'Champion' rank.")
				show("arena_novice", "arena_elite", "arena_champion")
			elseif (arena_ranking == "elite") then
				Npc:says(_"Choice: You can fight at the 'Novice' and 'Elite' rank.")
				show("arena_novice", "arena_elite")
			else
				Npc:says(_"Beginning: You can only fight at the 'Novice' rank.")
				show("arena_novice")
			end
			push_topic("arena")
			show("arena_none")
		end,
	},
	{
		id = "arena_novice",
		topic = "arena",
		text = _"Let's go at 'Novice' rank.",
		code = function()
			Npc:says(_"Accepted: You have chosen the 'Novice' rank.")
			start_arena("novice")
		end,
	},
	{
		id = "arena_elite",
		topic = "arena",
		text = _"Let's go at 'Elite' rank.",
		code = function()
			Npc:says(_"Accepted: You have chosen 'Elite' rank.")
			start_arena("elite")
		end,
	},
	{
		id = "arena_champion",
		topic = "arena",
		text = _"Let's go at 'Champion' rank.",
		code = function()
			Npc:says(_"Accepted: You have chosen 'Champion' rank.")
			start_arena("champion")
		end,
	},
	{
		id = "arena_none",
		topic = "arena",
		text = _"None for now.",
		code = function()
			Npc:says(_"Accepted: You will fight later.")
			--; TRANSLATORS: This sentence misrepresent the english adage 'Fortune favors the brave'. Use the equivalent adage of the language you translate.
			Npc:says(_"Advice: Fortune favors the cautious.")
			hide("arena_novice", "arena_elite", "arena_champion")
			pop_topic("arena")
		end,
	},
	{
		id = "arena_start",
		topic = "arena",
		code = function()
			arena_starting = true

			if (not arena_info_rules) then
				next("arena_info_rules")
				arena_info_rules = true
			else
				next("arena_start2")
			end

		end,
	},
	{
		id = "arena_start2",
		topic = "arena",
		code = function()
			-- TODO: Provide information about the current wave

			-- TODO: Clean the arena of bot from previous fight.

			Npc:says(_"Preparation: Patience, it will take a little moment.")
			Npc:says(_"[b]...Accessing the matrix.[/b]")
			Npc:says(_"[b]...Initializing the environment.[/b]")
			Npc:says(_"[b]...Reprogramming the Arena.[/b]")
			Npc:says(_"Excellent: The Arena is ready.")

			if (not arena_info_where) then
				next("arena_info_where")
				arena_info_where = true
			else
				-- TODO: Provide 'Protip' to Tux.
				next("arena_start3")
			end
		end
	},
	{
		id = "arena_start3",
		topic = "arena",
		code = function()
			arena_starting = false
			
			pop_topic("arena")
			hide("arena_ready", "arena_novice", "arena_elite", "arena_champion")
			end_dialog()
		end,
	},
	{
		id = "arena_info_rules",
		text = _"Can you explain again?",
		echo_text = false,
		code = function()
			if (not arena_starting) then
				Tux:says(_"Can you explain again?", "NO_WAIT")
			end

			Npc:says(_"Instruction: You will fight multiple waves of bots.")
			Npc:says(_"Second: The wave will end when all bots are dead.")
			Npc:says(_"Third: Wave will be only started when you stay on the multicolor floor lamp.")
			Npc:says(_"Fourth: You can only withdraw between waves with the terminal at the entry.")
			Npc:says(_"Warning: Few waves have B.O.S.S.", "NO_WAIT")
			Npc:says(_"Bot Of Special Shock.")
			Npc:says(_"Important: B.O.S.S. are more powerful. You will be signaled to take care.")

			if (arena_starting) then
				next("arena_start2")
			end
		end,
	},
	{
		id = "arena_info_where",
		text = _"Where I need to go?",
		echo_text = false,
		code = function()
			if (not arena_starting) then
				Tux:says(_"Where I need to go?", "NO_WAIT")
			end

			Npc:says(_"Information: The arena is on your west in the corridor.")
			Npc:says(_"Direction: Continue straight ahead after the locker room.")
			Npc:says(_"Advice: If you see a large area surrounded by barrier, you are here.")

			if (arena_starting) then
				next("arena_start3")
			end
		end,
	},
	{
		id = "tasks",
		text = _"What are your tasks?",
		code = function()
			Npc:says(_"First: Control of incoming droid.")
			Npc:says(_"Second: Prepare the arena installation.")
			Npc:says(_"Third: Save and analyse combat data.")
			Npc:says(_"Important: Make sandwiches.")
			hide("tasks") show("sandwich")
		end,
	},
	{
		id = "sandwich",
		text = _"Make me a sandwich.",
		code = function()
			if (tux_has_joined_guard) then
				-- TODO: Make ingredient avalaible. :)
				Npc:says(_"Problem: Ingredients are not available.")
			else
				Npc:says(_"Refusal: Only authorized personal can give orders.")
				show("sandwich_sudo")
			end
			hide("sandwich")
		end,
	},
	{
		id = "sandwich_sudo",
		text = _"sudo make me a sandwich",
		code = function()
			Npc:says(_"Annoyance: The droid is not a terminal.")
			hide("sandwich_sudo")
		end,
	},
	{
		id = "botnode1",
		text = _"You're not like the droids above.",
		code = function()
			Npc:says(_"I am a 571 model droid, designed for crew management.")
			if (tux_has_joined_guard or arena_ranking == "champion") then
				Npc:says(_"Do you wish any information about the 500s class?")
				hide("botnode1") show("botnode2", "botnode3")
			else
				Npc:says(_"Advice: If you meet a droid from the 500s class, run away, they'll kill you.")
				Npc:says(_"Warning: This is all you need to know.")
				Npc:says(_"Important: Access to this info will be disclosed when you become Elite, or a Red Guard Member.")
            end
		end,
	},
	{
		id = "botnode2",
		text = _"Which bots are on 500s class?",
		code = function()
			Npc:says(_"The 500s class is mostly composed by melee ranged, crew drones.", "NO_WAIT")
			Npc:says(_"They were designed to do all sort of tasks on a ship, except for the Harvester.")
			Npc:says(_"The [b]516[/b] was there for simple flight checks only. It's no longer supplied.")
			Npc:says(_"The [b]571[/b] is the replacement of the 516, and can be defined as a simple, jack-of-all-trades standard drone. According to data logs, they were in nearly every ship built before the Great Assault.")
			Npc:says(_"There is also the [b]598[/b], a highly sophisticated droid able to control the Robo-Freighter by itself.")
			Npc:says(_"The [b]543 Harvester[/b] is the exception. It was designed for logging, but right now, instead of harvesting trees, it may be harvesting people. If this is the case, it's advised to run away as fast as you can.")
			hide("botnode2")
		end,
	},
	{
		id = "botnode3",
		text = _"Shouldn't you be hostile?",
		code = function()
            --; TRANSLATORS: “Mike's” does not reefer to this bot in specific, but all Arena Management bots.
			Npc:says(_"Mike's currently does not uses MegaSys default firmware.", "NO_WAIT")
			Npc:says(_"I am running under [b]botnet-for-workgroups-3.11d[/b] Kernel.")
            Npc:says(_"So do not worry, I won't suddenly start attacking you.")
            --Tux:says(_"Yes, after all, you could just send arena bots after me, couldn't you?")
			hide("botnode3")
		end,
	},
	{
		id = "end",
		text = _"...",
		echo_text = false,
		code = function()
			-- TODO. Make Mike ask Tux to be more polite, and quit with a "good bye".
			-- A idea from jesusalva is to allows the traditional linarian salute.
			end_dialog()
		end,
	},
}
