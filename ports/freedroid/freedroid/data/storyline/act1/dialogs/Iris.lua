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
PERSONALITY = { "Independent", "Free Spirit", "Reclusive" },
MARKERS = { ITEMID1 = "Desk Lamp", NPCID1 = "Erin" },
PURPOSE = "$$NAME$$ is a treasure hunter living in the town. $$NAME$$ complains about the amount of light in her quarters
	 and will trade with Tux for a $$ITEMID1$$.",
BACKSTORY = "$$NAME$$ may be Francis' daughter, and a spy of the Rebel Faction, but this information remains to be checked. She may also have some backstory with $$NPCID1$$ but this also remains to be checked."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Iris_max_lessons = 5 -- the max number of lessons Iris is willing to teach
		Iris_lessons_taught = 0 -- the number of lessons Iris has already taught, initialized with 0
		Iris_next_lesson_cost = 0 -- the training point cost of the upcoming lesson
		show("node0")
	end,

	EveryTime = function()
		if (Iris_wants_lamp) then
			if (Tux:has_item_backpack("Desk Lamp")) then
				if (Iris_deal) then
					Npc:says(_"Hey, remember our deal?")
					Npc:says(_"I'll trade you a book, for that lamp and 100 credits.")
					show("node7")
				else
					hide("node6") show("node5")
				end
			else
				Npc:says_random(_"Sure is dark around here.",
					_"I wish there was some decent lighting.")
			end
		end

		if (Iris_false_happy) and
		   (not guard_follow_tux) then
			Iris_false_happy = false
			show("node4")
		end

		if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) and
		   (Tux:has_met("Iris")) and
		   (not Iris_post_firmware_upgrade) then
			show("Iris_post_firmware_upgrade")
		end

		show("node99")
	end,

	{
		id = "node0",
		text = _"Hello.",
		code = function()
			Npc:says_random(_"Hello.",
				_"Hi there!")
			if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Npc:says(_"I've heard about you.")
				Npc:says(_"A lot.")
				Npc:says(_"You're the talk of the town, actually.")
				Iris_post_firmware_upgrade = true
				show("node50", "node51", "node52")
			else
				show("node1")
			end
			hide("node0")
		end,
	},
	{
		id = "node1",
		text = _"Who are you?",
		code = function()
			Npc:says(_"I'm Iris.")
			Npc:set_name("Iris")
			Tux:says(_"Hello, Iris.")
			hide("node1") show("node2")
		end,
	},
	{
		id = "node2",
		text = _"What are you doing here?",
		code = function()
			Npc:says(_"I'm here just for vacations.")
			Tux:says(_"And what do you usually do?")
			Npc:says(_"Usually I hunt bots and their 'treasures'.") --she may be a spy of the rebel faction that is not yet implemented
			Npc:set_name("Iris - treasure hunter")
			hide("node2") show("node3", "node30")
		end,
	},
	{
		id = "node3",
		text = _"Where do you come from?",
		code = function()
			Npc:says(_"Nowhere and everywhere.")
			Npc:says(_"As I already said, I walk around, kill bots and loot their corpses.")
			hide("node3") show("node4")
		end,
	},
	{
		id = "node4",
		text = _"Do you like it here?",
		code = function()
			if (guard_follow_tux) then
				Iris_false_happy = true
				Npc:says(_"Yes, sure.")
				Npc:says(_"The Red Guard is very polite and keeps us safe from bots.")
				Npc:says(_"And the overall design of the town is quite clever.")
				Npc:says(_"Nevertheless, this room is quite dark.")
				Npc:says(_"It could use some light.")
			else
				Npc:says(_"Not really.")
				Npc:says(_"The town is quite ugly and dark.")
				Npc:says(_"And there are very strange people here.")
				Tux:says(_"I know exactly what you are talking about...")
				Npc:says(_"I think this room could use some decoration.")
				Npc:says(_"It looks so cold and dark...")
			end
			if (not Iris_traded_lamp) then
				Iris_wants_lamp = true
				if (Tux:has_item_backpack("Desk Lamp")) then
					show("node5")
				else
					Npc:says(_"Perhaps what I need is a lamp.")
				end
			end
			hide("node4")
		end,
	},
	{
		id = "node5",
		text = _"Look, I have this Lamp.",
		code = function()
			Npc:says(_"Wow, nice.")
			hide("node5") show("node6")
		end,
	},
	{
		id = "node6",
		text = _"You can have it.",
		code = function()
			Npc:says(_"Oh great, thanks!")
			Npc:says(_"Hmm, what can I give you as a thank-you...?")
			Npc:says(_"Oh, I have a nice book here.")
			Npc:says(_"But it's worth more than the old dusty lamp.")
			Npc:says(_"I'll give it to you for the lamp and 100 circuits.")
			if (Tux:get_gold() > 99) then
				show("node7")
			else
				Tux:says(_"I don't have that much right now.")
				Tux:says(_"Let me get back to you about that.")
				end_dialog()
			end
			hide("node6")
			Iris_deal = true
		end,
	},
	{
		id = "node7",
		text = _"Sure, sounds like a fair trade.",
		code = function()
			if (not Tux:has_item_backpack("Desk Lamp")) then
				Npc:says(_"Uhm, sorry, but where is the Desk Lamp?")
				Tux:says(_"Erm, ah, good question, where could it be?")
				Npc:says(_"Well, eff off until you have the lamp!")
			elseif (Tux:del_gold(100)) then
				Tux:says(_"Take these 100 valuable circuits.")
				Npc:says(_"Ok, here it is. Take this book.")
				Npc:says(_"It's quite old and some pages are missing, but the main message is still clear.")
				Tux:says(_"Oh, thanks!")
				Tux:del_item_backpack("Desk Lamp", 1)
				Tux:add_item("Source Book of Invisibility")
				Iris_wants_lamp = false
				Iris_traded_lamp = true
			else
				Npc:says(_"Don't try to trick me, fat bird.")
				Npc:says(_"I know you can't afford it.")
				Npc:says(_"Eff off until you have the right sum!")
			end
			hide("node7")
		end,
	},
	{
		id = "node30",
		text = _"Can you teach me anything about treasure-hunting?",
		code = function()
			if (Iris_lessons_taught == Iris_max_lessons) then
				Npc:says(_"Teach you right now?", "NO_WAIT")
				Npc:says(_"In your dreams, Penguin!")
			else
				Iris_next_lesson_cost = 200 * (Iris_lessons_taught + 1)
				Npc:says(_"It requires a certain stylization of form and technique, so you have to be in the proper mindset.", "NO_WAIT")
				Npc:says(_"Likewise I'll require a small gratuity for my time.", "NO_WAIT")
				--; TRANSLATORS: %d = number of circuits needed
				Npc:says(_"You will need 3 training points and %d circuits.", Iris_next_lesson_cost)
				Npc:says(_"Any interest?")
				show("node31")
			end
			hide("node30")
			end,
	},
	{
		id = "node31",
		text = _"Yes, teach me how to find bots 'treasures' more often.",
		code = function()
			if (Tux:train_program(Iris_next_lesson_cost, 3, "Treasure Hunting")) then
				Iris_lessons_taught = Iris_lessons_taught + 1
				Npc:says(_"Good. I'll give you an algorithm better than the one you're using right now.")
				Npc:says(_"Try using the 0x6974656D6D6F6E6579 algorithm.") -- ItemMoney (in hex and lowercase)
				--; TRANSLATORS: %d = "random" one-digit number.
				Npc:says(_"But this time, replaces every 6 with %d61.", Iris_lessons_taught)
				Tux:says(_"Yes, I understand. It's so simple! How I never thought on this before.")
			else
				if (Tux:get_gold() < Iris_next_lesson_cost) then
					next("node40")
				else
					next("node41")
				end
			end
			hide("node31") show("node30")
		end,
	},
	{
		id = "node40",
		code = function()
			Tux:says_random(_"Hold on, I don't seem to have that much money right now.",
				_"This is embarrassing. I will come back when I have the amount of valuable circuits you desire.")
			Npc:says_random(_"I'm not going to teach you anything for free!",
				_"Please don't bother me if you can't even pay me.",
				_"Come back when you have enough circuits, penguin.")
		end,
	},
	{
		id = "node41",
		code = function()
			Tux:says(_"Sorry, I don't think I can process another algorithm right now.")
			Npc:says_random(
				_"Everyone has the right to be stupid, but sometimes you abuse the privilege.",
				_"Come back when you are going to be serious.",
				_"You can only learn to hunt after the hunt.")
		end,
	},

	{
		id = "Iris_post_firmware_upgrade",
		text = _"Hello.",
		code = function()
			Npc:says(_"Hello again.")
			Npc:says(_"I've been hearing about you all day. You're the talk of the town.")
			Iris_post_firmware_upgrade = true
			hide("Iris_post_firmware_upgrade") show("node50", "node51", "node52")
		end,
	},
	{
		id = "node50",
		text = _"Yep, that's me. I saved everyone's hide. Including yours.",
		code = function()
			Npc:says(_"You did save a lot of lives, I'll give you that.")
			Npc:says(_"But I wouldn't get so excited if I were you. I don't think we're in the clear yet.")
			hide("node50", "node51", "node52") show("node53")
		end,
	},
	{
		id = "node51",
		text = _"Oh, and what have you heard?",
		code = function()
			Npc:says(_"Pretty cool stuff, actually. I heard you practically saved the town.")
			Npc:says(_"You penetrated the Hell Fortress in a bold operation against all odds, and managed to sabotage every bot from here to the next MegaSys service cell over, without so much as touching any standard interface.")
			Npc:says(_"That's what they say, anyway.")
			Tux:says(_"Hehe, well, the stories people tell...")
			Tux:says(_"The important thing is that everyone's safe now.")
			Npc:says(_"Yeah. I just wish I could be as certain of that...")
			hide("node50", "node51", "node52") show("node53")
		end,
	},
	{
		id = "node52",
		text = _"I know what they say, but I'm really not the superhero they make me out to be.",
		code = function()
			Npc:says(_"Hey, you gotta give yourself some credit.")
			Npc:says(_"Infiltration and sabotage are some of the most complicated types of operations out there. And also the most fun.")
			Npc:says(_"And you did pretty well, by the looks of it. Especially for someone with no fingers.")
			Tux:says(_"Thank you... I guess.")
			Npc:says(_"Yeah. Although there's still a lot to be done.")
			hide("node50", "node51", "node52") show("node53")
		end,
	},
	{
		id = "node53",
		text = _"What do you mean?",
		code = function()
			Npc:says(_"I... I'm not sure.")
			Npc:says(_"It could be just background noise. Maybe it's not even that. But there's still something a little weird about it.")
			Npc:says(_"More than a little, when I think about it.")
			Tux:says(_"What are you talking about?")
			Npc:says(_"... I hope trusting you with this isn't a mistake.")
			--; TRANSLATORS: comm = communication
			Npc:says(_"My comm devices have been intercepting strange signals in this area, ever since I got here. It's usually scrambled beyond recognition, and I wasn't even sure it was a signal at all until recently.")
			Npc:says(_"It was just before you arrived, actually.")
			Tux:says(_"Are you saying I'm emitting some kind of signal?")
			Npc:says(_"No - if that were the case my equipment would've been going crazy right now. But it's definitely related to you.")
			Tux:says(_"But how do you know?")
			Npc:says(_"Because just before you arrived, everything did go crazy. At first I thought we were being nuked and the EMP was causing it.")
			Npc:says(_"But then I realized: someone is broadcasting, and they really wanted outreach.")
			Npc:says(_"It wasn't scrambled this time, and I listened. The whole thing lasted about an hour. It was mostly binary; I couldn't figure most of it out, but there were some names encoded in hex in there. Places. People.")
			Npc:says(_"One of them was you.")
			push_topic("Mysterious signal")
			hide("node53") show("node54")
		end,
	},
	{
		id = "node54",
		text = _"My name? What does this mean?",
		topic = "Mysterious signal",
		code = function()
			Npc:says(_"It means someone knew about you before the Red Guard did, and it means whoever it was broadcast it far and wide.")
			Npc:says(_"That's all I can make of it.")
			hide("node54")
			show("node55", "node56")
		end,
	},
	{	id = "node55",
		text = _"I understand.",
		topic = "Mysterious signal",
		code = function()
			Npc:says(_"If I were you, I would be very careful. I'm sure there were a lot of hands stirring in this mess, but I think some of them weren't chopped off by a bot.")
			hide("node55", "node56")
			pop_topic()
		end,
	},
	{	id = "node56",
		text = _"I don't understand.",
		topic = "Mysterious signal",
		code = function()
			Npc:says(_"I don't either, and I don't have anything more to say on the matter.")
			--; TRANSLATORS: previous sentence was "I don't have anything more to say on the matter"
			Npc:says(_"Just that I hope that your optimism will be justified.")
			hide("node55", "node56")
			pop_topic()
		end,
	},
	{
		id = "node99",
		text = _"See you later.",
		code = function()
			if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
				Npc:says_random(_"Take care.",
						_"Be careful out there.",
						_"Keep an eye out for anything weird.",
						_"Remember the saying, 'Speak softly and carry a big stick.' I think you'll need that stick soon.")
			elseif (Iris_wants_lamp) then
				Npc:says(_"Bye.")
			else
				Npc:says(_"In your dreams, Penguin!")
			end
			end_dialog()
		end,
	},
}
