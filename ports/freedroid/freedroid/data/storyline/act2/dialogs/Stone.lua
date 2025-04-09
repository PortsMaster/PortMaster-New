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
PERSONALITY = { "Friendly", "Happy", "Obsessive" },
MARKERS = {
	PLACEID1 = "Hell Fortress",
	ITEMID1 = "Two Barrel shotgun",
	ITEMID2 = "Shotgun shells"
},
PURPOSE = "$$NAME$$ is the first seller of equipment available in the second act. He is the main supplier for the Second Act.",
BACKSTORY = "$$NAME$$ used to live in (FreedroidRPG) town, but he found a small-time corruption at the strange building $$PLACEID1$$,
	 and because that suffered an accident while he was investigating it. The caring MegaSys said they would offer medical care, at
    a very low cost, on their specialized RR Resorts. He is the grandfather from Ms. Stone, and knows Tux as an ancient hero. They
    have some backstory together."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		--; TRANSLATORS: %s = Tux:get_player_name()
		Npc:says(_"%s, long time no see! Haha, I guess I was cryonized too! Is this the future?", Tux:get_player_name(), "NO_WAIT")
		Npc:says(_"Ah, this place looks horrible! A pity, I still have so many wares to sell!")
		Tux:says(_"Who... are you?")
		Npc:says(_"Wait, can't you remember me? I am your old friend, Mr. Stone!")
		Npc:set_name("Mr. Stone - Shop owner")
		Tux:says(_"So... you know me? From before being cryonized?")
		Npc:says(_"Well, I was only a kid then, but you were a hero!", "NO_WAIT")
		Npc:says(_"You saved my cat when it climbed a tree! I'll be forever grateful!")
		Tux:says(_"This is... weird. Do you remember why I was cryonized, at least?")
		Npc:says(_"Well, I guess it was some sort of protest against MegaSys or something?", "NO_WAIT")
		Npc:says(_"Old people should not stay under cryostasis for long, they say! Haha! I guess they were right!")
		Npc:says(_"Eh, I do not really like the bots here. Not many clients, either.", "NO_WAIT")
		Npc:says(_"I think there was a bunker north of here, I'll go there and set up my shop! Come visit me once I'm done!")
		show("node31") -- We should check if Tux has item "Two Barrel shotgun" but this is TBD.
		end_dialog()
	end,

	EveryTime = function()
		--; TRANSLATORS: %s = Tux:get_player_name()
		Npc:says(_"So, %s, how may I serve you today?", Tux:get_player_name())

		show("node0", "node1", "node99")
	end,

	{
		id = "node0",
		text = _"So, how is it going?",
		code = function()
			Npc:says(_"Pretty bad, no one visits here but you.", "NO_WAIT")
			Npc:says(_"But as long that my wares are useful for you, I'm happy enough!")
			hide("node0")
		end,
	},
	{
		id = "node1",
		text = _"I would like to trade with you.",
		code = function()
			Npc:says_random(_"Sure, please take a look.",
							_"Maybe you'll like something.",
							_"In time of apocalypse, only I can supply you.",
							_"My wares are your only hope of survival out there.",
							_"Everything you'll ever need, only in Mr. Stone shop.",
							_"So, are you enjoying those lands so far?",
							_"Remember to buy the right ammo for your gun!",
							_"You got the gun, I've got the ammo.",
							_"Please buy my wares. You won't regret.",
							_"Nice shopping!",
							_"Good! Here is the selection of items I have for sale.")
			trade_with("Stone")
		end,
	},
	{
		id = "node31",
		text = _"I met your niece, Ms. Stone...",
		code = function()
			Npc:says(_"Haha! I used to tell her stories about you.", "NO_WAIT")
			Npc:says(_"I hope she is doing fine!")
			Tux:says(_"I hope you did not tell her anything weird...")
			Npc:says(_"I would never! Your strange sidekick would have my head, haha!")
			Tux:says(_"Sidekick?")
			-- TRANSLATORS: Dorac: Mr. Stone cannot remember how to spell “Dvorak”
			Npc:says(_"Yes, I think he was called... Dorac or something? Ahh, I can't remember anymore...")
			Tux:says(_"I guess his name was Dvorak. I think he'll have more useful info than you...")
			Npc:says(_"More info he may have, but can he supply you in the apocalypse?", "NO_WAIT")
			Npc:says(_"You'll only find cheap, quality wares here, with Mr. Stone! Buy today!")
			hide("node31")
		end,
	},
	{
		id = "node99",
		text = _"See you later.",
		code = function()
			Npc:says_random(_"Have a nice day!",
				_"Take care that you don't void any warranties.",
				_"Please come back if you have any questions regarding my goods.",
				_"I hope to see you again, soon!")
			end_dialog()
		end,
	},
}
