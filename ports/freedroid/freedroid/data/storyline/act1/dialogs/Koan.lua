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
PERSONALITY = { "Contemplative", "Peaceful", "Hopeful" },
MARKERS = { NPCID1 = "Duncan", QUESTID1 = "Doing Duncan a favor", NPCID2 = "Tania" },
PURPOSE = "$$NAME$$ is the focus of the $$QUESTID1$$ quest",
BACKSTORY = "$$NAME$$ has turned a hidden bunker into an \'Oasis of Peace\' hidden from the ravaged world above.",
RELATIONSHIP = {
	{
		actor = "$$NPCID1$$",
		text = "$$NAME$$ is the opposite of $$NPCID1$$. $$NPCID1$$ destroys life while $$NAME$$ creates life."
	},
	{
		actor = "$$NPCID2$$",
		text = "$$NAME$$ has an unknown relationship with $$NPCID2$$. She will be very angry if $$NAME$$ is killed."
	},
}
WIKI]]--


local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	EveryTime = function()
		if (Tania_position == "bunker") then --Tania is following you
			tania_is_here = true
			Tania:heal()
		else
			tania_is_here = false
		end

		if (not Koan_met) then
			Koan_met = true
			Npc:says(_"So you have come. I knew Duncan would not let me live for too long.")
			Npc:says(_"Once I am gone this oasis of peace in the world will dry up and die. A shame.")
			Npc:says(_"I hoped to turn the whole desert into a sanctuary. And now my dream will never come true.")
			Npc:says(_"Do what you must.")
			if Tux:has_quest("Doing Duncan a favor") then
				show("node2")
			else
				if (not Tux:has_met("Duncan")) then
					show("node4")
				else
					show("node5")
				end
			end
			show("node3")
		elseif (Koan_spared_via_dialog) then
			Npc:says_random(_"It's a pleasure to meet you again.",
							_"I am happy to see you've returned.")
			if (tania_is_here) then
				Npc:says(_"I see you have brought a friend along with you.")
			end
		elseif Tux:has_quest("Doing Duncan a favor") then
			Npc:says(_"I see the troubles of the world in your eyes.")
			show("node10", "node11")
			hide("node20", "node21", "node99")
			--elseif (met_koan_before_duncan) then
			-- Npc:says_random(_"Come sit down my friend.",
			-- _"Please take some time and relax here in the cool.")
			-- if (tania_is_here) then
			-- Npc:says(_"I see you've brought a friend along with you.")
			-- end
		end
	end,

	{
		id = "node2",
		text = _"With pleasure.",
		code = function()
			Npc:drop_dead()
			Tux:update_quest("Doing Duncan a favor", _"I took revenge for Duncan by killing Koan.")
			respawn_level(38) --this is the desert above the bunker
			if (tania_is_here) then
				Koan_murdered = true
				start_chat("Tania")
			end
		end,
	},
	{
		id = "node3",
		text = _"No. I have not come here to kill you.",
		code = function()
			Npc:says(_"Thank you.")
			Npc:says(_"Feel free to stay here. There is no danger.")
			Npc:says(_"The water is safe to drink and the fruit from the tree is quite delicious. I have a few extra provisions here with me. Please take some.")
			Tux:add_item("Strength Pill", 1)
			Tux:add_item("Doc-in-a-can", 2)
			Tux:add_item("Source Book of Repair equipment", 1)
			Tux:add_item("Strength Capsule", 1)
			if Tux:has_quest("Doing Duncan a favor") then
				next("node12")
			end
			hide("node2", "node3") show("node5", "node20", "node99")
		end,
	},
	{
		--has not met Duncan yet
		id = "node4",
		text = _"Who are you? Who is Duncan?",
		code = function()
			Npc:set_name("Koan")
			Npc:says(_"I am Koan.")
			Npc:says(_"Duncan is one obsessed with destroying things, while I create.")
			Npc:says(_"Therefore, he desires my destruction.")
			hide("node3", "node4", "node5") show("node20", "node99")
		end,
	},
	{
		id = "node5",
		text = _"Who are you?",
		code = function()
			Npc:set_name("Koan")
			Npc:says(_"I am Koan.")
			Npc:says(_"Beyond that I am a creator.")
			Npc:says(_"I give life to things, even if they eventually will be destroyed.")
			hide("node3", "node5") show("node20", "node99")
		end,
	},
	{
		id = "node10",
		text = _"You shall die.",
		code = function()
			Npc:drop_dead()
			Tux:update_quest("Doing Duncan a favor", _"I took revenge for Duncan by killing Koan.")
			respawn_level(38) --this is the desert above the bunker
			if (tania_is_here) then
				Koan_murdered = true
				start_chat("Tania")
			end
		end,
	},
	{
		id = "node11",
		text = _"Duncan sent me to kill you, but I came to make certain you were safe.",
		code = function()
			Npc:says(_"Thanks for checking up on me.")
			hide("node10", "node11") show("node99") next("node12")
		end,
	},
	{
		id = "node12",
		code = function()
			Koan_spared_via_dialog = true
			Tux:update_quest("Doing Duncan a favor", _"I met and talked to Koan, but didn't kill him.")
			show("node13")
		end,
	},
	{
		id = "node13",
		text = _"Why does Duncan want you dead?",
		code = function()
			Npc:says(_"Very simple. He likes destruction, and I am creation.")
			Npc:says(_"There is nothing more to it.")
			hide("node13")
		end,
	},
	{
		id = "node20",
		text = _"What is this place? Why is there grass and water under the desert?",
		code = function()
			Npc:says(_"Ah, yes. That is my fault, I am afraid.")
			Npc:says(_"Wherever I go, life follows me.")
			Npc:says(_"I thought I could hide from Duncan in this old bunker.")
			Npc:says(_"When I woke up the next day, things were as you see them now.")
			hide("node20") show("node21")
		end,
	},
	{
		id = "node21",
		text = _"This was a bunker?",
		code = function()
			Npc:says(_"Yes. The place has changed a bit, as you can see.")
			Npc:says(_"I like the way it is right now. The water cools everything down and the plants give the air a very fresh smell.")
			Npc:says(_"As soon as I leave, everything will die. I have seen that happen before.")
			Npc:says(_"Because this place is just like a small bit of paradise, I decided to stay here.")
			Npc:says(_"I do not want this wonderful bunker to become devoid of life again.")
			hide("node21")
		end,
	},
	{
		id = "node99",
		text = _"I will go now.",
		code = function()
			Npc:says_random(_"This place will always wait for you.",
							_"This is a sanctuary from the desert above.")
			Tux:heal()
			hide("node2", "node3", "node4", "node5")
			end_dialog()
		end,
	},
}
