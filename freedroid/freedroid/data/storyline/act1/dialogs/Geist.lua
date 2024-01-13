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
PERSONALITY = { "Militaristic", "Focused", "Vengeful" },
MARKERS = { NPCID1 = "Engel" },
BACKSTORY = "$$NAME$$ and $$NPCID1$$ have become bot hunters after the loss their mother to a bot attack. He does not speak English.
	 His family name is Fleischer (in English - \"butcher\").",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "$$NPCID1$$ and $$NAME$$ are brothers."
	},
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
		text = _"Hello. Any idea where I can get some help here?",
		code = function()
			--; TRANSLATORS: Vanish!
			Npc:says(_"Verschwinde!")
			hide("node0") show("node1", "node2")
		end,
	},
	{
		id = "node1",
		text = _"Erm... What do you mean?",
		code = function()
			--; TRANSLATORS: I am the ghost that always negates (?).
			Npc:says(_"Ich bin der Geist, der stets verneint.")
			--; TRANSLATORS: For a reason; because everything that is created,
			Npc:says(_"Und das mit Recht; denn alles, was entsteht,")
			--; TRANSLATORS: is worth, to be ruined.
			Npc:says(_"ist wert, dass es zugrunde geht.")
			hide("node1") show("node3")
		end,
	},
	{
		id = "node2",
		text = _"I really do not understand you.",
		code = function()
			--; TRANSLATORS: The one who does not know them, the Elements,
			Npc:says(_"Wer sie nicht kennte, die Elemente,")
			--; TRANSLATORS: their power and their feature/characteristic,
			Npc:says(_"ihre Kraft und Eigenschaft,")
			--; TRANSLATORS: would not be a master of the ghosts/spirits.
			Npc:says(_"waere kein Meister ueber die Geister.")
			hide("node2") show("node3")
		end,
	},
	{
		id = "node3",
		text = _"I wish I knew what you are talking about.",
		code = function()
			--; TRANSLATORS: Vanish!
			Npc:says(_"Verschwinde!")
			hide("node3")
			end_dialog()
		end,
	},
	{
		id = "node99",
		text = _"I need to go now.",
		code = function()
			Npc:says(_". . .")
			end_dialog()
		end,
	},
}
