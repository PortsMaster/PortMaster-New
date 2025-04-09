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
PERSONALITY = { "Intelligent" },
MARKERS = { DROIDID1 = "614" },
BACKSTORY = "$$NAME$$ is the Red Guard\'s Computer Cluster maintainer and occasional $$DROIDID1$$ programmer."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
		if (Kevin:is_dead()) then
			show("node50")
		end
	end,

	EveryTime = function()
		if (Tux:has_item_backpack("Kevin's Data Cube")) then
			show("node6")
		end
		show("node99")
	end,

	{
		id = "node0",
		text = _"Hi! I'm new here. ",
		code = function()
			Npc:says(_"Welcome, welcome! I'm Richard. I'm the computer guy around here.")
			Npc:says(_"I mostly work with this huge computer cluster here, although I also program the 614 bots in my spare time.")
			Npc:set_name("Richard - Programmer")
			hide("node0") show("node1", "node60")
		end,
	},
	{
		id = "node1",
		text = _"A computer cluster? What's that?",
		code = function()
			Npc:says(_"A cluster is a group of computers, connected in a way that helps them collaborate in solving problems.")
			Npc:says(_"As they say, 'two heads are better than one'. And we have a lot of heads here.")
			Npc:says(_"That is why I call this cluster 'Hydra'. A lot of heads indeed.")
			hide("node1")
		end,
	},
	{
		id = "node6",
		text = _"I have a data cube with some information. Can you tell me something more about it?",
		code = function()
			Npc:says(_"Interesting. Let me see this thing. Hmm... Yes, there is quite a lot of data in there. Maybe we could use Hydra to evaluate the data.")
			Npc:says(_"Hey, what do we have here? The data is already prepared for processing by a cluster just like ours. Wow! That's excellent!")
			Npc:says(_"I'll feed it into Hydra right away. Expect the results in a short while. Hydra has never let me down.")
			Tux:del_item_backpack("Kevin's Data Cube", 1)
			Tux:end_quest("A kingdom for a cluster!", _"Yes, that was simple. I wish everything else went as smoothly as this one did...")
			hide("node6") show("node9", "node10")
		end,
	},
	{
		id = "node9",
		text = _"Hey, did you get something out of that data cube?",
		code = function()
			Npc:says(_"Of course! I told you, Hydra has never failed me! I designed it myself, and I know computers very well. I never make mistakes.")
			Npc:says(_"Seems like the disruptor shield which thwarts all our attacks on Hell Fortress can be controlled from somewhere outside, or something like that.")
			Npc:says(_"I was busy servicing one of Hydra's nodes, but I sent the full report to Spencer. He will tell you more.")
			hide("node9")
		end,
	},
	{
		id = "node10",
		text = _"So... What's the story on those data cubes, anyway?",
		code = function()
			Npc:says(_"Well, they were originally developed for use with the Open-Pandora computing platform.")
			Tux:says(_"The what?")
			Npc:says(_"It was a handheld gaming computer, built on open-source software.")
			Npc:says(_"The device had limited storage capabilities, so an enterprising hacker designed the data cubes.")
			Npc:says(_"Those were the beginning days of open-source hardware. It's one of the few open-source innovations still around.")
		end,
	},
	{
		id = "node41",
		code = function()
			Tux:says(_"Sorry, my memory data bank is filled to the brim right now. Can't learn more until I get some more experience.")
			Npc:says_random(_"You Linarians are funny creatures. Come back later when you feel ready if you please.",
							_"I cannot teach you when you have no training points. Come back when you are more prepared.",
							_"You are not ready. Go kill some bots and come back.",
							_"Come back when you are mentally ready to learn.",
							_"Come back after some more practice in the field.",
							_"Waving those circuits in front of me when you are too unfocused to train won't help. I can take your money, but you won't learn anything.",
							_"Yeah, I don't think you have enough experience for this. Come back here after you see some more action.",
							_"Then come back when you have a real will to learn.",
							_"You don't have enough experience. Come here after you see some more action.")
		end,
	},
	{
		id = "node50",
		text = _"What can you teach me about hacking?",
		code = function()
			Npc:says(_"I can teach you everything, for a price of course.", "NO_WAIT")
			Npc:says(_"Three hundred per lesson, up front.", "NO_WAIT")
			hacking_level = get_program("Hacking")
			if (hacking_level > 8) then
				Npc:says(_"Sorry, there is no human alive that could give you further training.")
				hide("node51")
			else
				--; TRANSLATORS: %d = a number
				Npc:says(_"You will need %d training points.", hacking_level * 2)
				Npc:says(_"Still interested?")
				show("node51")
			end
		end,
	},
	{
		id = "node51",
		text = _"Yes, please teach me.",
		code = function()
			if (Tux:train_program(300, get_program("Hacking") * 2, "Hacking")) then
				Npc:says(_"Good. The most important thing about hacking is to understand the nature of the machine you want to hack.")
				Npc:says(_"Once you have figured out what the creators of the system were thinking when setting it up, you'll also know how to best hack it.")
				Npc:says(_"Now I see the feature set of your hacking program has already improved a lot.")
				hide("node51") show("node50")
			else
				if (Tux:get_gold() < 300 ) then
					next("node52")
				else
					next("node41")
				end
			end
		end,
	},
	{
		id = "node52",
		code = function()
			Tux:says_random(_"Hold on, I don't seem to have enough money right now.",
							_"This is embarrassing. I will come back when I have the amount of valuable circuits you desire.")
			Npc:says_random(_"Ok, come back when you can afford to pay me if you are interested.",
							_"Please don't bother me if you can't pay me.",
							_"You don't have enough money! I cannot afford to just give away training for free.",
							_"Come back when you have enough circuits.",
							_"So come back when you have some valuables.")
		end,
	},
	{
		id = "node60",
		text = _"What bot types do you know?",
		code = function()
			Npc:says(_"Well, I program the 614, so I know quite some things about the droids on this class.")
			Npc:says(_"Interested?")
			hide("node60") show("node61")
		end,
	},
	{
		id = "node61",
		text = _"Which bots are on 600s class?",
		code = function()
			Npc:says(_"The 600s class keeps the sentinel droids.", "NO_WAIT")
			Npc:says(_"They were projected mainly to protect a certain area from intruders, killing trespassers.")
			Npc:says(_"There is the [b]614[/b], made by Nicholson Company. They have some sort of [b]Exterminator[/b] inside. It's slow but a reliable droid.")
			Npc:says(_"There is also the [b]615[/b] droid. Nicholson Company didn't finish the project, which made they get affected by the Great Assault as well. They are much more dangerous than the 614, and much faster.")
			Npc:says(_"There is also the [b]629[/b] droid. It's slow, but its guns are powerful enough to such trivia doesn't matter.")
			Npc:says(_"There is also the [b]603[/b]. A lawnmower. It doesn't cause much damage, but his attack rate is incredibly fast and doesn't need recharging. Thankfully, it's a melee droid.")
			Npc:says(_"I only program the 614 droids, so my information about the others may be wrong.")
			hide("node61")
		end,
	},
	{
		id = "node99",
		text = _"See you later.",
		code = function()
			Npc:says(_"Take care, Linarian.")
			end_dialog()
		end,
	},
}
