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
PERSONALITY = { "Brilliant", "Dumb" },
PURPOSE = "$$NAME$$ will help to improve Tux\'s abilities. Will also give Tux some more background on Act2.",
BACKSTORY = "$$NAME$$ is part of Act2. It mistakes Tux with Agent Zero, and says a little more than desired, besides calling player as \"master\". It can improve Tux's programming. However, it is required previous knowledge which can be obtained with Sorenson."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Tux:says(_"Oh noes! It is a 999 bot! Run! Run! Danger!")
		Npc:says(_"Welcome back, master. I hope your plan in dominating mankind is going as planned.")
		Tux:says(_"Err, remind me, what were your tasks again?")
		Npc:says(_"Primary: [b]Control all dangerous humans who are being held captive on RR Resorts.[/b]", "NO_WAIT")
		Npc:says(_"Secondary: [b]Kill everyone and everything if security threat: HIGH[/b]")
		Tux:says(_"Ah, uhm, ok.")
		show("node20", "node21", "node22", "node50")
	end,

	EveryTime = function()
		show("node99")
	end,

	{
		id = "node20",
		text = _"What is my name?",
		code = function()
			Npc:says(_"Your name is classified information.", "NO_WAIT")
			Npc:says(_"Please proof your identity.")
			Tux:says(_"Actually, uhm... I forgot that on my other set of war pants!")
			Npc:says(_"Aborted.")
			Tux:says(_"Can you tell me your name, though?")
			Npc:says(_"I am the manager of this facility.")
			Npc:set_name(_"999 RR Manager")
			hide("node20")
		end,
	},
	{
		id = "node21",
		text = _"What is this place?",
		code = function()
			Npc:says(_"RR Resorts, or the RRR, is the paradise for those who dares to oppose my masters.")
			Npc:says(_"An efficient way to dispose undesired people, without causing too much ruckus.")
			Tux:says(_"Undesired... people? Is that even ethical?")
			Npc:says(_"I do not know what \"ethical\" means.")
			Tux:says(_"Ah, okay. Do not worry with such big details.")
			Tux:update_quest("Where Am I?", _"I found RR Resorts, where \"undesired individuals\" are kept frozen. I probably should seek a way to unfreeze them.")
			hide("node21")
		end,
	},
	{
		id = "node22",
		text = _"What is the current security threat level?",
		code = function()
			Npc:says(_"Threat Degree Analysis: [b]NO THREAT DETECTED[/b]", "NO_WAIT")
			Npc:says(_"Currently, all hostilities are dead or cryonized.")
			Tux:says(_"What about bots?")
			Npc:says(_"Sorry, I do not understand this question.")
			Tux:says(_"Nevermind that.")
			hide("node22")
		end,
	},
	{
		id = "node50",
		text = _"You're very intelligent for a bot.",
		code = function()
			Npc:says(_"I am a 999 equipped with a Primode brain. I also know a lot about programming.")
			Tux:says(_"Cool! Can you teach me?")
			if (Tux:get_skill("programming") < 4) then
				Npc:says(_"Sorry, I cannot. I overestimated your coding skills previously.")
				Npc:says(_"You must practice a little more, master. I will not bother you with this again.")
                hide("node50")
			else
				Npc:says(_"Naturally, I can remind you about coding.")
				Npc:says(_"However, you'll need 5,000 circuits and two training points. A short maintenance routine must be conducted afterwards.")
				hide("node50") show("node60")
			end
		end,
	},
	{
		id = "node60",
		text = _"Sure. Teach me more programming than I actually know. (costs 5000 valuable circuits, 2 training points)",
		code = function()
				if (Tux:train_skill(5000, 2, "programming")) then -- Not much AP because Tux probably is a high-level linarian by now.
					Tux:heat(110) -- Ping-pong is the hardest game ever made. It only loses to Nethack.
					Npc:says(_"Let us begin then.")
					Npc:says(_"Come closer...")
					Npc:says(_"Do you see this screen?")
					Tux:says(_"Yes. I see a ball going up and down, hitting two moving walls.")
					Npc:says(_"This is called ping-pong. It's an... interesting game.")
					Tux:says(_"Seems simple.")
					Npc:says(_"Maybe. It's much more complex than you think. It's not the code I'm talking about, or even the ball going up and down. The important is not the program on itself. It's the art of programming.")
					Npc:says(_"Once you understand how the bytes flows, how they sum and they bitwise, you'll become a true master at programming.")
					Tux:says(_"What should I do?")
					Npc:says(_"Look at source code, and replicate the ping pong, but not with this simple, built-in, example AI. Try to do a sentient ping pong field, with air friction, gravity, virtual reality, these sort of things.")
					Npc:says(_"It would be desirable to consider the solar effect over tachyon particles and the E-particle emission on field due to friction with two antigrav rackets, but do not worry too much with that.") -- Are tachyons the way to contact Linarius?
					Tux:says(_"Yes sir! Will be done sir!")
					Npc:says(_"[b]...some time later...[/b]")
					Npc:says(_"Very good. The E-particle emission is a little off, but this can be forgiven.")
					Npc:says(_"You're good to go.")
					Npc:says(_"By the way, you've learned very fast the exponential overflow from E-particles. Have you sold your soul by any chance, master?")
					Npc:says(_"This is enough training for today.")
					hide("node60")
				else
					if (Tux:get_gold() >= 5000) then
						Npc:says(_"You don't have enough experience. I can't teach you anything more right now.")
						Npc:says(_"I'm afraid there is nothing I can do for you right now, master.")
					else
						Npc:says(_"Sorry, training you could damage my own circuits and I may need replacements parts.")
						Npc:says(_"After all, don't you know the Third Law of Robotics? \"A robot must protect its own existence.\"")
						Tux:says(_"...Now I'm really curious about what you bots believe to be the first and second laws of robotics...")
					end
				end
		end,
	},
	{
		id = "node99",
		text = _"I'll inspect this fine resort of yours. Please excuse me.",
		code = function()
			Npc:says(_"Have a nice visit, master. If you need a full report, just contact me.")
			end_dialog()
		end,
	},
}
