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
PERSONALITY = { "Pushy", "Isolated" },
MARKERS = {
	ITEMID1 = "Map Maker",
	ITEMID2 = "Teleporter homing beacon",
	NPCID1 = "Town-TeleporterGuard"
},
PURPOSE = "$$NAME$$ is a technology trader. He also sells a $$ITEMID1$$ pill that enables Tux's mapping abilities during the
	 game. $$NAME$$ is also the only other way Tux can obtain a $$ITEMID2$$ after using the one received from $$NPCID1$$.",
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0", "node99")
	end,

	EveryTime = function()
		if (Skippy_angry) then
			-- We probably at some point want to be able to make Skippy happy again, maybe by Tux finishing a quest or something that helps Skippy or a friend of his or similar.
			Npc:says(_"What? You again? I don't want you here, get out.")
			Tux:says(_"See you later.")
			Npc:says(_"Don't come back. I hate you.")
			end_dialog()
		end
	end,

	{
		id = "node0",
		text = _"Hi! I'm new here.",
		code = function()
			Npc:says(_"Great! A newcomer! Welcome! Welcome! I'm Skippy, and I'm your new best friend!")
			Npc:says(_"I already saw you coming. Due to my mapping device! It's great stuff!")
			Npc:says(_"And as a special favour, I'll sell you a mapping device for half price!")
			Npc:says(_"What a GREAT offer! You're so lucky!")
			Npc:set_name("Skippy - Map-Maker Maker")
			hide("node0") show("node1", "node2", "node3", "node10", "node20")
		end,
	},
	{
		id = "node1",
		text = _"Ok, if I want to buy me one of those mapping pills. How much are they?",
		code = function()
			Npc:says_random(_"They only cost 50 circuits. Special price only for you!",
							_"You're so lucky! I just decided to cut the price in half! One of those devices only costs 50 circuits now!")
			hide("node1") show("node11", "node12")
		end,
	},
	{
		id = "node2",
		text = _"How do I activate a mapping device?",
		code = function()
			Npc:says(_"Oh, that's so simple. No need to activate anything at all.")
			Npc:says(_"Just swallow the pill and the nanotechnological bots will enter your body.")
			Npc:says(_"They'll merge with your eyes and transmit data to your brain using the optical nerves. Nice, eh?")
			Npc:says(_"Everything within 50 meters of you will be displayed on your retinas.")
			hide("node2") show("node4")
		end,
	},
	{
		id = "node3",
		text = _"You said you make these things yourself? How do you do that?",
		code = function()
			Npc:says(_"Oh, I've always been a geek. And I got blueprints from before the Great Assault.")
			Npc:says(_"You can't order anything from a catalogue any more.")
			Npc:says(_"The only source of these gizmos is here. It's me!")
			hide("node3")
		end,
	},
	{
		id = "node4",
		text = _"Nanotechnology? Isn't that dangerous?",
		code = function()
			Npc:says(_"No way, man, I guarantee it. Don't believe anything you might have heard.")
			Npc:says(_"This is a perfectly safe and tried technology. No risk at all! Really!")
			Npc:says(_"There is no risk of your head being eaten by a nanotechnological nightmare, or anything funny like that.")
			Npc:says(_"I've used one myself for many years now: no side effects! It works just as great as on the first day!")
			Npc:says(_"Trust me! I'm your best friend and I wouldn't lie to you! Never!")
			hide("node4") show("node5")
		end,
	},
	{
		id = "node5",
		text = _"I don't trust you.",
		code = function()
			Npc:says(_"WHAT? But I'm your best friend! You must trust me!")
			hide("node5") show("node6")
		end,
	},
	{
		id = "node6",
		text = _"I still do not trust you. You are selling junk to people.",
		code = function()
			Npc:says(_"WHAT? Fine, you can forget about my great deals now! I don't want to trade with you anymore!")
			Npc:says(_"I'm no longer your best friend. Go away, you dirty hoser!")
			Skippy_angry = true
			hide("node1", "node3", "node6", "node10", "node11", "node12", "node20", "node21", "node99")
			end_dialog()
		end,
	},
	{
		id = "node10",
		text = _"Do you sell anything else?",
		code = function()
			Npc:says(_"Sure! I also build some electronics devices, depending on what parts I can get my hands on.", "NO_WAIT")
			-- We can potentially add more electronics things he can do in the future, or perhaps "add magic" to an item of Tux for a price
			Npc:says(_"Resources are a bit scarce nowadays though.")
			trade_with("Skippy")
		end,
	},
	{
		id = "node11",
		text = _"Ok, I'll take one. (costs 50 circuits)",
		code = function()
			if (Tux:del_gold(50)) then
				Npc:says(_"Here is your pill.", "NO_WAIT")
				Npc:says(_"Just swallow it, and it should work.")
				Npc:says(_"I give a 30 day warranty and adjustments, in case it doesn't work as expected.")
				Tux:add_item("Map Maker",1)
				display_big_message(_"Swallow pill and press tab to see automap.")
			else
				Npc:says(_"Hey, I'm not a bank!", "NO_WAIT")
				Npc:says(_"Come back when you can afford it.")
				show("node1")
			end
			hide("node11", "node12")
		end,
	},
	{
		id = "node12",
		text = _"Nah, don't think so. ",
		code = function()
			Npc:says(_"Your loss.", "NO_WAIT")
			Npc:says(_"Hope you won't get lost and killed out there.", "NO_WAIT")
			Npc:says(_"But don't count on it.")
			hide("node11", "node12") show("node1")
		end,
	},
	{
		id = "node20",
		text = _"Why are you so friendly?",
		code = function()
			Npc:says(_"Because you are my best friend!")
			Npc:says(_"I always take good care of my special buddies!")
			hide("node20") show("node21")
		end,
	},
	{
		id = "node21",
		text = _"You are friendly only to sell me your stuff, aren't you?",
		code = function()
			Npc:says(_"No, never! I would never be so shallow!")
			Npc:says(_"I am friendly because I like you.")
			hide("node21")
		end,
	},
	{
		id = "node99",
		text = _"See you later.",
		code = function()
			Npc:says(_"Yes, we'll meet again, my friend, and I'll have other great deals for you.")
			end_dialog()
		end,
	},
}
