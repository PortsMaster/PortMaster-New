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
PERSONALITY = { "Militaristic", "Abrasive", "Domineering", "Condescending" },
PURPOSE = "$$NAME$$ enables Tux's access to the training arena."
WIKI]]--

-- TODO: Tux shouldn't kill Butch at low level.
-- TODO: Butch reacts to Tux Arena rank.
-- TODO: Butch give or not a reward.
-- TODO: Butch reacts when Tux enter the red guard.
-- TODO: Butch talks about Mike.
-- TODO: Create a secret rank "master" with insane difficulty.

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Npc:says(_"Hey! Never seen you, newbie.")
		Npc:says(_"Wanna enter the arena?")
		Npc:set_rush_tux(false)
		show("butch", "arena_what", "newbie")
	end,

	EveryTime = function()
		if (Tux:has_met("Butch")) then
			Tux:says(_"Hello!")

			show("arena_topic") hide("arena_what")

			if (Tux:has_met("Mike")) then
				show("arena_talk2")
			end

			if (Tux:done_quest("Novice Arena")) then
				show("newbie_alt") hide("newbie")
				if (Tux:has_quest("Time to say goodnight")) then
					if (not Tux:done_quest("Time to say goodnight")) then
						Npc:says(_"Yeah, what do you want newbie?")
						Npc:says(_"The master arena is by no means an easy task. Maybe you should practice some more before you go there.")
						Npc:says(_"It's the trapdoor north of the regular arena. Good luck, newbie: You'll need it.")
					else
						Npc:says(_"Yeah, what do you want?")
						if (not Butch_enable_second_set) then
							Butch_enable_second_set = true
							show("master_complete")
						end
						hide("newbie_alt")
					end
				else
					Npc:says(_"Yeah, what do you want newbie?")
					show("butch_master")
				end
			else
				show("newbie")
			end
			hide("newbie2")
		end

		show("end")
	end,
	{
		id = "butch",
		text = _"Who are you?",
        code = function()
			Npc:says(_"Butch... The arena master.")
			Npc:set_name("Butch - Arena Master")
			hide("butch")
		end,
	},
	{
		id = "arena_what",
		text = _"Arena? What arena?",
		code = function()
			Npc:says(_"This underground arena. With holographic bots to train combat techniques against.")
			Npc:says(_"Wanna fight?")
			hide("arena_what") show("arena_fight", "arena_peace", "arena_no")
			push_topic("Arena")
		end,
	},
	{
		id = "arena_topic",
		text = _"It's about the arena.",
		code = function()
			if (not Tux:has_quest("Novice Arena")) then
				Npc:says(_"Wanna fight?")
				show("arena_fight", "arena_peace", "arena_no")
				push_topic("Arena")
			else
				Npc:says(_"All you need to do is walk in there and talk to Mike.")
			end
			hide("arena_topic") 
		end,
	},
	{
		id = "arena_fight",
		text = _"Yeah. I want to fight.",
		topic = "Arena",
		code = function()
			Npc:says(_"Good. I opened up the door. Just continue to the corridor.")
			Npc:says(_"You'll need talk to Mike, the arena manager, there.")
			Npc:says(_"And be careful, your brain will be fooled by what happens in the holographic world. Any damage you take there, will result in actual physical damage.")
			Npc:says(_"So even if the enemies are only holograms, they can still hurt you... and even kill you.")
			Tux:add_quest("Novice Arena", _"Fighting in the arena is not something I would usually do, but I feel like doing it for a change. Why not?")
			Npc:says(_"Oh, and this room is made out of some special material. People reported their teleporter gadgets didn't work in here. Take care!")
			Tux:update_quest("Novice Arena", _"Butch says that teleporter gadgets may not work in the arena.")
			change_obstacle_state("Arena-ManagerDoor", "opened")
			hide("arena_fight", "arena_peace", "arena_no")
			show("arena_info1", "arena_talk1")
			pop_topic()
		end,
	},
	{
		id = "arena_peace",
		text = _"No way! Violence is wrong! Make love not war!",
		topic = "Arena",
		code = function()
			Npc:says(_". . .")
			hide("arena_fight", "arena_peace", "arena_no") show("arena_peace2")
		end,
	},
	{
		id = "arena_peace2",
		text = _"Roses, not destruction!",
		topic = "Arena",
		code = function()
			Npc:says(_". . .")
			hide("arena_peace2") show("arena_peace3")
		end,
	},
	{
		id = "arena_peace3",
		text = _"End the violence! All blood is red!",
		topic = "Arena",
		code = function()
			Npc:says(_"Hey, the bots bleed black. With oil.")
			Tux:says(_"But... But...")
			Npc:says(_"No 'but' about it, newbie.")
			Npc:says(_"The bots bleed black.")
			Tux:says(_"You... Have ruined my pacifistic slogan... I am angry... So angry that I want to smash things!")
			Npc:says(_"Great. Get in the door, newbie, and go talk to Mike.")
			Tux:add_quest("Novice Arena", _"Fighting in the arena is not something I would usually do, but I feel like doing it for a change. Why not?")
			change_obstacle_state("Arena-ManagerDoor", "opened")
			hide("arena_fight", "arena_peace", "arena_no", "arena_peace3") 
			show("arena_info1", "arena_talk1")
			pop_topic()
			end_dialog()
		end,
	},
	{
		id = "arena_no",
		text = _"I don't have time, I need to save the world.",
		topic = "Arena",
		code = function()
			Npc:says(_"Yeah! Continue to dream, newbie.")
			hide("arena_fight", "arena_peace", "arena_no")
			pop_topic()
		end,
	},
	{
		id = "arena_info1",
		text = _"Why the heck are you organizing fights? Enough people have died already!",
		code = function()
			Npc:says(_"I have a very good reason not to tell you.")
			Npc:says(_"Not like someone as inexperienced as you could understand it anyway.")
			hide("arena_info1")
		end,
	},
	{
		id = "arena_talk1",
		text = _"I thought I was going to fight you, coward.",
		code = function()
			Npc:says(_"I NEVER said that, newbie.")
			if (done_quest("Novice Arena")) then
				Npc:says(_"You wanted a fight, and you got one.")
				Npc:says(_"I offered a fight, and you wanted that.")
			else
				Npc:says(_"You wanted a fight, and you will get one.")
				Npc:says(_"I offered a fight, then do it.")
			end
			Npc:says(_"There is nothing more to say, newbie.")
			hide("arena_talk1")
		end,
	},
	{
		id = "arena_talk2",
		text = _"I want a bigger challenge.",
		code = function()
			if (not Tux:done_quest("Novice Arena")) then
				Npc:says(_"I'm sorry, but town regulations forbid access to the more advanced ranks unless you've completed the noob-, errr, novice first.")
				Npc:says(_"This regulation is in place for your own safety, so that no newbie accidentally signs up as Champion.")
				--; TRANSLATORS: 'more difficult' is related to arena rank
				Npc:says(_"You might try taking the novice challenge first. Then Mike will grant you access to a more difficult.")
			else
				Npc:says(_"Newbie, just go talk to Mike.")
				Npc:says(_"He has better challenges.")
			end
			hide("arena_talk2")
		end,
	},
	{
		id = "newbie",
		text = _"I'm not a 'newbie'.",
		code = function()
			Npc:says(_"Of course you are. Everyone start as newbie.")
			Npc:says(_"You are just a little more newbie than others.")
			hide("newbie") show("newbie2")
		end,
	},
	{
		id = "newbie_alt",
		text = _"What is wrong with you? Why do you keep calling me a newbie?",
		code = function()
			Npc:says(_"Because you ARE a newbie, newbie!")
			--; TRANSLATORS: 'less' refers to 'newbie'
			Npc:says(_"You are just a little less.")
			hide("newbie_alt") show("newbie2")
		end,
	},
	{
		id = "newbie2",
		text = _"Say 'newbie' again and I will rip your spine out.",
		code = function()
			Npc:says(_"Fine, newbie. You are greener than green and a total newbie.")
			Npc:says(_"You can start ripping out my spine now.")
			Npc:says(_"Ha!")
			hide("newbie2", "newbie4") show("newbie3", "newbie_end")
			push_topic("Newbie")
		end,
	},
	{
		id = "newbie3",
		text = _"I really mean it. I will kill you for that insult.",
		topic = "Newbie",
		code = function()
			Npc:says(_"Go for it.")
			hide("newbie3") show("newbie4")
		end,
	},
	{
		id = "newbie4",
		text = _"BANZAI! DIE DIE DIE!",
		topic = "Newbie",
		code = function()
			Npc:says(_"Wha --")
			Npc:drop_dead()
			set_faction_state("redguard", "hostile")
			display_big_message(_"Better reload your last save and try again.") -- reverse order
			display_big_message(_"Ooops, the Red Guard hates you now.")
			hide("newbie4", "newbie_end")
			end_dialog()
		end,
	},
	{
		id = "newbie_end",
		text = _"...",
		topic = "Newbie",
		code = function()
			Npc:says(_"So, it was just for show. Anything else, newbie?")
			hide("newbie4", "newbie_end") pop_topic()
		end,
	},

    {
        id = "butch_master",
        text = _"If Mike manages the arena, how comes you're the arena master?",
        code = function()
            if (arena_ranking == "champion") then
                Npc:says(_"Newbie, we have a second arena, the Master Arena.")
				if (Tux:has_item_equipped("The Super Exterminator!!!") or
						Tux:has_item_equipped("Exterminator")) then
						Npc:says(_"It is no place to test your cool Exterminator.", "NO_WAIT")
		        end
                Npc:says(_"You will die if you go there.")
                Npc:says(_"I pity you, silly bird. Don't go there.")
                Npc:says(_"But if you really want to, the door is now open. It's inside the city, north of this one.")
                Tux:add_quest("Time to say goodnight", _"I told the arena master to let me into the master arena. He agreed. Now all that remains to do is to climb down the ladder to the north arena and wait for death herself to come on her black wings and claim my soul. You know, now that I think about it... Maybe I should stay out of there?")
                Npc:says(_"Remember, if your teleporter don't work on the convencional arena, it won't work in the master arena either...")
                Tux:update_quest("Time to say goodnight", _"Again, Butch warned me about possibly broken teleporter gadgets.")
                change_obstacle_state("MasterArenaAccessTrapdoor", "opened")
            else
                Npc:says(_"Oh, that? I've completed a special challenge.")
                Npc:says(_"But you're still too green to try that. You know, town regulations. You must complete the Elite arena first.")
                Npc:says(_"Once you're done, come talk to me about this again.")
            end
            hide("butch_master")
        end,
    },
    {
        id = "master_complete",
        text = _"The master arena is clear.",
        code = function()
            Npc:says(_"What!? Impossible! No one has ever survived the second arena! Well, except me, of course.")
            Npc:says(_"One has to be out of his mind to even attempt the second arena. Not even Bender tried it!")
            Npc:says(_"You are not a newbie... You are COMPLETELY INSANE!")
            Npc:says(_"Poor fool... You will surely die young.")
            Tux:add_xp(8000)
            Tux:update_quest("Time to say goodnight", _"I survived the master arena. A miracle. Whew.")
            hide("master_complete")
        end,
    },
	{
		id = "end",
		text = _"I'll be going then.",
		code = function()
			Npc:says_random(_"Sure, go hide away in fear.",
							_"See you around, newbie.",
							_"Remember: pain is temporary but glory is forever.",
							_"Go kill some bots.")
			end_dialog()
		end,
	},
}
