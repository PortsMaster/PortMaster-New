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
PERSONALITY = { "Militaristic", "Not Very Intelligent" },
MARKERS = {
	NPCID1 = "Ewald",
	NPCID2 = "Sorenson",
	ITEMID1="Teleporter homing beacon"
},
PURPOSE = "$$NAME$$ guards the town\'s teleporter and attempts to explain how teleporters work, albeit in a not so
	 intelligent fashion. $$NAME$$ also informs Tux of how to use the teleporter and gives a $$ITEMID1$$ to Tux.",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "$$NAME$$ suggests that if Tux wants to \'play dice\' that he visit $$NPCID1$$."
	},
	{
		actor = "$$NPCID2$$",
		text = "$$NAME$$ explains how $$NPCID2$$ saved the town by locking down the teleporter."
	}
}
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
	end,

	EveryTime = function()
		show("node99")
	end,

	{
		id = "node0",
		text = _"Hi! I'm new here.",
		code = function()
			Npc:says(_"A newcomer, eh?")
			Npc:says(_"Well, what do you have to say for yourself?")
			hide("node0") show("node1", "node10")
		end,
	},
	{
		id = "node1",
		text = _"I'm a Linarian.",
		code = function()
			Npc:says(_"And how is that working out for you?")
			hide("node1") show("node2", "node3")
		end,
	},
	{
		id = "node2",
		text = _"Fairly well.",
		code = function()
			Npc:says(_"That's nice.")
			hide("node2", "node3")
		end,
	},
	{
		id = "node3",
		text = _"Not well at all.",
		code = function()
			Npc:says(_"I'm sorry.")
			Npc:says(_"Glad that I'm me then.")
			hide("node2", "node3")
		end,
	},
	{
		id = "node10",
		text = _"I was actually wondering what you are doing?",
		code = function()
			Npc:says(_"Oh, I'm guarding the teleporter point here.")
			hide("node10") show("node11")
		end,
	},
	{
		id = "node11",
		text = _"How does teleportation work?",
		code = function()
			Npc:says(_"Something about knitting or crochet.")
			Tux:says(_"Strings?")
			Npc:says(_"Yeah, something about tying them in knots.")
			Npc:says(_"It is supposed to be a pleasant way to relax.")
			Npc:says(_"Although some things can't be teleported because something about Einstein playing dice with Schrodinger's cat.")
			hide("node11") show("node12", "node13", "node15")
		end,
	},
	{
		id = "node12",
		text = _"Einstein playing dice with a cat?",
		code = function()
			Npc:says(_"The cat would eat the dice.")
			Tux:says(_"So, no dice?")
			Npc:says(_"Yeah. If you want to play dice you should talk to the bartender, Ewald.")
			Ewald:set_name("Ewald - Barkeeper")
			hide("node12")
		end,
	},
	{
		id = "node13",
		text = _"How can I teleport?",
		code = function()
			Npc:says(_"Well, first the computer needs to scan you.")
			Npc:says(_"But it did that as soon as you entered the town.")
			Npc:says(_"Then all you need is one of these Teleporter homing beacons. I'll give you one.")
			Tux:add_item("Teleporter homing beacon")
			Npc:says(_"They send a coded signal to our computer here, which does all of the quantum doohickeys to move you around.")
			Npc:says(_"Of course, if you had another way to send a coded signal, that would work as well.")
			hide("node13") show("node14")
		end,
	},
	{
		id = "node14",
		text = _"So, not everyone can be teleported?",
		code = function()
			Npc:says(_"Yeah. The crazy computer lady locked down our teleporter pretty tight as soon as the Great Assault started to happen.")
			Npc:says(_"Probably saved all our lives.")
			Npc:says(_"Imagine how long we'd last if the bots just teleported right here.")
			Npc:says(_"But all the same, I'm stationed here to make certain everything is working right.")
			Npc:says(_"That lady is crazy after all.")
			hide("node14")
		end,
	},
	{
		id = "node15",
		text = _"Not everything can be teleported?",
		code = function()
			Npc:says(_"Yeah, some objects have issues.")
			Npc:says(_"Highly explosive issues.")
			Npc:says(_"So, the teleporter is designed not to teleport you if there is a problematic item in your possession.")
			Npc:says(_"It should tell you why it isn't working though.")
			hide("node15")
		end,
	},
	{
		id = "node99",
		text = _"I'll be going, then.",
		code = function()
			Npc:says(_"Goodbye.")
			show("node1")
			end_dialog()
		end,
	},
}
