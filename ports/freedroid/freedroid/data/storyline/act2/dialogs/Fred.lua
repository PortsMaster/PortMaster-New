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
PERSONALITY = { "Pushy", "Obsessed" },
MARKERS = { NPCID1 = "Yadda" },
PURPOSE = "$$NAME$$ is an Act 2 NPC. He is isolated with a C-64 glitch south of R&R Resorts. He crafts add-ons and also introduces the Barrett M82.",
BACKSTORY = "Follower of $$NPCID1$$ which was included on the sole purpose of crafting addons."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		show("node0")
	end,

	EveryTime = function()
		show("node99")
		if (Tux:has_item_equipped("Barrett M82 Sniper Rifle") and
			not Fred_Barrett) then
			show("barrett_help")
        --[[ This could be useful if people complain about not finishing Reapers I quest.
        elseif (not Fred_Barret) then
			Npc:says_random(_"Sniper Rifles are cool.",
							_"Defeating robots is easy with Sniper Rifles.",
							_"Bah-bah-bah rifler.", -- From Doctor Who “bah-bah-bah-biker”
							_"What's better than grenades? Sniper rifles.",
							_"Where could I increase my Sniper Rifles collection?")
        ]]--
		end

	end,

	{
		id = "node0",
		text = _"Uhm... Hello?",
		code = function()
			Npc:says(_"Hello, I'm Fred. I make addons and grenades. I can craft some for you.")
			Tux:says(_"I would like to give a look at it later, thanks.")
			hide("node0") show("addoncraft", "addonequip", "buy", "barrett")

		end,
	},
	{
		id = "addoncraft",
		text = _"Could you craft some add-ons for me?",
		code = function()
			Npc:says(_"Of course I can craft add-ons for my best customer.")
			Tux:says(_"If not the only.")
			craft_addons()
		end,
	},
	{
		id = "addonequip",
		text = _"Can you assemble add-ons on my equip?",
		code = function()
			Npc:says(_"Of course I can assemble add-ons for my best customer.")
			Tux:says(_"If not the only.")
			upgrade_items()
		end,
	},
	{
		id = "buy",
		text = _"I want a grenade.",
		code = function()
			Npc:says_random(_"Sure, please take a look.",
							_"They're not impressive, but get the work done!",
							_"You won't regret them.",
							_"VMX for humans, EMP for droids. Remember this rule.",
							_"Nice shopping!")
			trade_with("Fred")
		end,
	},
	{
		id = "barrett",
		text = _"Do you know where to find a weapon for the .50 BMG Ammo?",
		code = function()
			Npc:says(_"A weapon for the .50 Browning Machine Gun Ammo. Only the Barrett M82 Sniper Rifle use that junk. I mean, they don't even stack, you need a slot on inventory for each ammo.")
			Tux:says(_"So, if I was interested in such gun. Do you know where I could get one?")
			Npc:says(_"I have one, but I won't give it to you. You see, the Barrett is powerful enough to stop a truck, literally, and the likelihood of even a battle droid surviving more than 2 hits by this weapon is quite slim.")
			Npc:says(_"So unless you're military or something, I won't be giving, trading, nor selling it for you.")
			Tux:says(_"I have many circuits, you know.")
			Npc:says(_"And I have a Barrett M82. I bet a few direct hits from this gun, and you'll leave life to become history.")
			Tux:says(_"...You've got a point there.")
			hide("barrett")
		end,
	},
	{
		id = "barrett_help",
		text = _"Look at this! I have a Barrett.",
		code = function()
			Npc:says(_"Ah, so you've got a Barrett too. Nice.")
			Npc:says(_"That is a sniper rifle. It should kill bots in one shoot from afar.")
			Npc:says(_"If you ever find a droid with subsonic sensor, this is the weapon you should use.")
			Tux:says(_"Why?")
			Npc:says(_"Subsonic droids won't attack until you attack them. They are powerful, fast, and have lots of armor.")
			Npc:says(_"Plasma would be too slow, and laser too weak, so you really should use sniper rifles there.")
			Tux:says(_"...I do not think I'll ever meet such droid, but thanks for the warning.")
			Tux:add_item(".50 BMG (12.7x99mm) Ammunition", 5)
			Npc:says(_"Here is some spare ammo. Use it wisely.")
			Tux:end_quest("The Reapers Of MegaSys I", _"Glitch was defeated, and I obtained one of the most powerful weapon in sheer damage terms. Man, either I am THAT good, or I cheat.")
			Fred_Barrett = true
			hide("barrett_help")
		end,
	},
	{
		id = "node99",
		text = _"I'll leave this strange man to his... evil doings.",
		code = function()
			Npc:says_random(_"...",
							_"You joke now, but a bot soon will teach you to be more serious.",
							_"Evildoer? You don't even know me.",
							_"...But it's you who is killing bots left and right...",
							_"Having survived the Great Assault doesn't make me an evildoer.")
			end_dialog()
		end,
	},
}
