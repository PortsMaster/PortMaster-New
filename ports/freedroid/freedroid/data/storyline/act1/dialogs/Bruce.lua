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
PERSONALITY = { "Exhausted", "Haunted", "Trapped" },
BACKSTORY = "$$NAME$$ is a mine worker and former member of the Red Guard. He is haunted by the loss of comrades at Hell Fortress."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
		Bruce_helmet_sell = -1
		-- -1: deal not initiated
		-- 0, 20, 100: sell prices
		-- -1000: deal failed (the "lost" case is handled separately)
	end,

	EveryTime = function()
		if (HF_FirmwareUpdateServer_uploaded_faulty_firmware_update) then
			Npc:says(_"I was finally allowed to rest. Please don't bother me.")
			end_dialog()
		end
		if (tux_has_joined_guard) then
			Npc:says(_"I am tired.")
			Npc:says(_"Go away.")
			end_dialog()
		elseif (Bruce_wants_helmet) then
			next("node30")
			push_topic("Bruce wants Dixon's helmet")
		else
			if (not Bruce_hurt) and
			(Tux:has_item_equipped("Dixon's Helmet")) then
				if (Bruce_Dixons_helmet_lost) then
					Npc:says(_"So, you've 'lost' the helmet, heh?")
					Npc:says(_"Then, what's that on your head?")
					Npc:says(_"Leave me alone!")
					Bruce_hurt = true
					hide("node0", "node1", "node2", "node3", "node4", "node5", "node6", "node7", "node10", "node11", "node12")
				elseif (Bruce_helmet_sell == -1) then
					next("node20")
					push_topic("Bruce wants Dixon's helmet")
				end
			end
		end
		hide("node29") show("node99")
	end,

	{
		id = "node0",
		text = _"Are you all right? You don't look too good.",
		code = function()
			if (guard_follow_tux) then
				Npc:says(_"I don't have time to talk: I'm far too busy working! I'm normally at the mines this time of day but I forgot something and that's...")
				Npc:says(_"That's why I'm here. Now I must get back to the mines.")
				end_dialog()
			else
				Npc:says(_"Good day. I am Bruce.")
				Npc:says(_"I am unwell.")
				Npc:set_name("Bruce - Mine Worker")
				hide("node0") show("node1")
			end
		end,
	},
	{
		id = "node1",
		text = _"How is it going?",
		code = function()
			Npc:says(_"I am very tired, but otherwise well.")
			hide("node1") show("node2")
		end,
	},
	{
		id = "node2",
		text = _"You don't talk much, eh?",
		code = function()
			Npc:says(_"No, I am just too tired right now. I have been working in the mine for two weeks now.")
			Npc:says(_"I feel totally wiped, so maybe it would be better if you came some other day.")
			hide("node2") show("node3")
		end,
	},
	{
		id = "node3",
		text = _"Why do you work so hard in the mine?",
		code = function()
			Npc:says(_"Because I must! The Red Guard makes everyone work up to their limits!")
			Npc:says(_"If you do not work for a full work period, you will be in trouble.")
			Npc:says(_"But I have no choice. I do not want to be a soldier again.")
			hide("node3") show("node4")
		end,
	},
	{
		id = "node4",
		text = _"You were a soldier before?",
		code = function()
			Npc:says(_"Yes. I would rather not talk about it.")
			hide("node4") show("node5", "node6")
		end,
	},
	{
		id = "node5",
		text = _"I have some bad memories too. I know how hard it can be to talk about them. Keep your stories for yourself.",
		code = function()
			Npc:says(_"Yes. And now I would like to go to sleep. Good night Linarian.")
			hide("node5", "node6", "node7")
			end_dialog()
		end,
	},
	{
		id = "node6",
		text = _"I said, I want to know about your life as a soldier.",
		code = function()
			Npc:says(_"And I said that I do not want to talk about it. It hurts too much. Please, stop asking about it and leave me alone.")
			hide("node6") show("node7")
		end,
	},
	{
		id = "node7",
		text = _"You don't understand. I wasn't asking. Now, tell me about your life as a soldier, or I will tell the guards you are slacking off.",
		code = function()
			Npc:says(_"No! Please... I will do anything, just don't call the Red Guard! They do not like people who left the service. They do not like me.")
			Npc:says(_"I will tell you everything.")
			Bruce_hurt = true
			hide("node5", "node7") show("node10")
		end,
	},
	{
		id = "node10",
		text = _"Good. Start talking. Now.",
		code = function()
			Npc:says(_"Those are pretty painful and distant memories.")
			Npc:says(_"After the Great Assault, I joined the Red Guard. They needed help and were looking for volunteers.")
			Npc:says(_"I served there for a short while, and they even let me use an exterminator. But then after a failed mission, I resigned and never wore a uniform again.")
			hide("node10") show("node11", "node12")
		end,
	},
	{
		id = "node11",
		text = _"You mentioned an exterminator. What is it?",
		code = function()
			Npc:says(_"It is the best weapon that the Red Guard has against the bots.")
			Npc:says(_"A direct hit from one of those guns is enough to turn most bots into scrap metal.")
			Npc:says(_"Many of the great victories of the Red Guard are thanks to the exterminator.")
			Npc:says(_"Of course, because of its small clip and terribly long reloading time, equally many deaths can be attributed to it.")
			hide("node11")
		end,
	},
	{
		id = "node12",
		text = _"A failed mission?",
		code = function()
			Npc:says(_"There were six of us. Me, Wilbert, Anderson and three others. I do not remember the names anymore. We were team number nine.")
			Npc:says(_"It was a routine scout mission. We saw an interesting building which was not there before, and decided to take a look.")
			Npc:says(_"It was a terrible fortress, many stories high. It had guns everywhere. When we got close the shooting started.")
			Npc:says(_"They were waiting for us. Came in endless swarms. More and more and more. We stood our ground and kept firing, but it was no use. More of them came.")
			Npc:says(_"Our ammunition ran out. They got close. It was the end of team number nine. The Hell Fortress took their lives. I ran. I survived.")
			Npc:says(_"After that I decided that I am not fit to be one of the Red Guard. I resigned and started to work in the mine shortly after.")
			Npc:says(_"I do not want to face the rage of the Hell Fortress ever again. Never again.")
			hide("node12")
		end,
	},
	{
		id = "node20",
		topic = "Bruce wants Dixon's helmet",
		code = function()
			Npc:says(_"What do you have there?")
			Tux:says(_"What do you mean?")
			Npc:says(_"That helmet. I could make good use of it, it looks quite solid.")
			Npc:says(_"Can I buy it from you?")
			Bruce_wants_helmet = true
			hide("node20") show("node40", "node45", "node49")
		end,
	},
	{
		id = "node29",
		text = _"Let's talk about the helmet.",
		code = function()
			hide("node29") next("node30")
			push_topic("Bruce wants Dixon's helmet")
		end,
	},
	{
		id = "node30",
		topic = "Bruce wants Dixon's helmet",
		code = function()
			Npc:says(_"So, what about the helmet now?")
			if (Bruce_helmet_deal) then
				Npc:says(_"I offered you 20 circuits for it.")
			end
			if (Bruce_helmet_sell == 20) then
				Npc:says(_"You agreed.")
				Tux:says(_"Indeed.")
			elseif (Bruce_helmet_sell == 100) then
				Npc:says(_"You suggested 100 circuits as a price.")
				Npc:says(_"That is acceptable to me.")
				Tux:says(_"Excellent.")
			elseif (Bruce_helmet_sell == 0) then
				Npc:says(_"You said you would give me the helmet for free.")
				Tux:says(_"Yes, that's true.")
			end
			if (Tux:has_item_equipped("Dixon's Helmet")) then
				Npc:says(_"Please unequip it, so we can proceed.")
				Npc:says(_"I want to see your face as we talk.")
				end_dialog()
			elseif (Tux:has_item("Dixon's Helmet")) then
				if (Bruce_helmet_sell == 0) then
					Tux:says(_"Here you go.")
					Npc:says(_"Oh, thank you!")
					Npc:says(_"Here, take this Lamp, as a token of my esteem.")
					Tux:says(_"Oh, thank you very much!")
					Npc:says(_"You're welcome.")
					Tux:add_item("Desk Lamp")
				elseif (Bruce_helmet_sell == 20) then
					Npc:says(_"Fine.")
					Npc:says(_"Here are your 20 circuits.")
					Tux:says(_"Here's your new helmet.")
					Npc:says(_"Thank you.")
					Tux:says(_"You're welcome.")
					Tux:add_gold(20)
				elseif (Bruce_helmet_sell == 100) then
					Npc:says(_"Hmm...")
					Npc:says(_"OK.")
					Npc:says(_"Here, take the hundred bucks.")
					Npc:says(_"Now give me that helmet!")
					Tux:says(_"Here, take it.")
					Tux:add_gold(100)
				end
				if (Bruce_helmet_sell > -1) then
					Tux:del_item("Dixon's Helmet")
					Bruce_wants_helmet = false
					pop_topic() -- "Bruce wants Dixon's helmet"
				end
			else
				Npc:says(_"Where is it?")
				Npc:says(_"Did you lose it?")
				Npc:says(_"Come back to me when you have it.")
				show("node47", "node48")
				push_topic("Lost Dixon's Helmet Y/N")
			end
		end,
	},
	{
		id = "node40",
		text = _"Yes, sure.",
		topic = "Bruce wants Dixon's helmet",
		code = function()
			Npc:says(_"Good.")
			Npc:says(_"Let's say, 20 circuits?")
			Bruce_helmet_deal = true
			if (Tux:has_item_equipped("Dixon's Helmet")) then
				Npc:says(_"Please take off the helmet, so we can proceed trading.")
				end_dialog()
			end
			hide("node40") show("node41", "node42", "node43", "node44")
		end,
	},
	{
		id = "node41",
		text = _"You can have it for free.",
		echo_text = false,
		topic = "Bruce wants Dixon's helmet",
		code = function()
			Tux:says(_"I changed my mind.")
			Tux:says(_"You can have it. For free.")
			Npc:says(_"Oh... Oh my! Thanks!")
			Npc:says(_"Wait, let me go get something first.")
			Tux:says(_"Sure.")
			Bruce_helmet_sell = 0
			hide("node41", "node42", "node43", "node44", "node45")
			Npc:set_destination("Bruce-move-target-label")
			end_dialog()
		end,
	},
	{
		id = "node42",
		text = _"20 circuits? OK.",
		topic = "Bruce wants Dixon's helmet",
		code = function()
			Npc:says(_"Okay.")
			Npc:says(_"Let me quickly go get the money.") --excuse for need to restart the dialog
			Npc:says(_"Talk to me again in a moment.")
			Bruce_helmet_sell = 20
			hide("node41", "node42", "node43", "node44", "node45")
			Npc:set_destination("Bruce-move-target-label")
			end_dialog()
		end,
	},
	{
		id = "node43",
		text = _"20 circuits? I'll sell it for... a hundred.",
		topic = "Bruce wants Dixon's helmet",
		code = function()
			Npc:says(_"Well... okay.")
			Npc:says(_"Let me get the money.") --excuse for need to restart the dialog
			Npc:says(_"Come back to me after that.")
			Bruce_helmet_sell = 100
			hide("node41", "node42", "node43", "node44", "node45")
			Npc:set_destination("Bruce-move-target-label")
			end_dialog()
		end,
	},
	{
		id = "node44",
		text = _"20 circuits? Do you think I'm stupid? I'll sell it for 1000!",
		topic = "Bruce wants Dixon's helmet",
		code = function()
			Npc:says(_"That's way too expensive.")
			Tux:says(_"Fine, I'll keep it then.")
			Npc:says(_"You're the greediest penguin I've ever met.")
			Npc:says(_"Forget about the deal!")
			Bruce_helmet_sell = -1000
			Bruce_wants_helmet = false
			hide("node41", "node42", "node43", "node44", "node45")
			pop_topic() -- "Bruce wants Dixon's helmet"
		end,
	},
	{
		id = "node45",
		text = _"I'm sorry, but I'd like to keep it.",
		topic = "Bruce wants Dixon's helmet",
		code = function()
			Npc:says(_"Bummer!")
			Bruce_helmet_sell = -1000
			Bruce_wants_helmet = false
			hide("node40", "node41", "node42", "node43", "node44", "node45")
			pop_topic() -- "Bruce wants Dixon's helmet"
		end,
	},
	{
		id = "node47",
		text = _"No, it's alright. I have it.",
		topic = "Lost Dixon's Helmet Y/N",
		code = function()
			Npc:says(_"OK, so please fetch it and bring it to me.")
			hide("node47", "node48")
			end_dialog()
		end,
	},
	{
		id = "node48",
		text = _"I lost it.",
		topic = "Lost Dixon's Helmet Y/N",
		code = function()
			Npc:says(_"That's too sad!")
			Npc:says(_"So, please leave. I want to take a rest.")
			Bruce_Dixons_helmet_lost = true
			Bruce_wants_helmet = false
			hide("node40", "node41", "node42", "node43", "node44", "node45", "node47", "node48", "node49")
			end_dialog()
		end,
	},
	{
		id = "node49",
		text = _"I'll think about that, but right now let's talk about something else.",
		topic = "Bruce wants Dixon's helmet",
		code = function()
			Npc:says(_"OK, but please don't forget the helmet deal!")
			show("node29")
			pop_topic() -- "Bruce wants Dixon's helmet"
		end,
	},
	{
		id = "node99",
		text = _"I'll be going then.",
		code = function()
			if (Bruce_hurt) then
				Npc:says(_". . .")
			elseif (Bruce_wants_helmet) then
				Npc:says(_"Hang tight, I'll be right back for that helmet!")
			else
				Npc:says(_"Good. I need sleep.")
			end
			end_dialog()
		end,
	},
}
