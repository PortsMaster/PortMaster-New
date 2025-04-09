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
PERSONALITY = { "Weird", "Mysterious", "Riddles", "Omniscient?", "Crypt" },
PURPOSE = "$$NAME$$ is just an useless character which may spawn between Acts and player will wonder why he does that and what he's talking about.",
BACKSTORY = "$$NAME$$ is an anomaly. No one knows where he comes from, why he is here, or even if he should be in FreedroidRPG to begin with. He was not added by FreedroidRPG staff, and seems pretty happy in playing mind games with Tux. But, who is this man, who all he does all day is staring the sky? He might be holding a big secret, but you'll never know. All you can do for now is fry your brain, trying to understand why he just stares the sky, without doing anything, as if everything is going as it should be going... including you."
WIKI]]--

local Npc = FDrpg.get_npc()
local Tux = FDrpg.get_tux()

return {
	FirstTime = function()
		Saves_times=0
	end,

	EveryTime = function()
		Saves_times=Saves_times + 1

		-- I like to salute people correctly, so get the correct game time
		local day, hour, minute = game_date()
		if (hour >= 18 or hour < 6) then
			Npc:says(_"Good evening!")
		elseif (hour < 12 and hour >= 6) then
			Npc:says(_"Good morning!")
		elseif (hour < 18 and hour >= 12) then
			Npc:says(_"Good afternoon!")
		end

		if (not has_met("MrSaves")) then
			Tux:says(_"...Hello.")
			Npc:says(_"I am Mr. Saves, the Watcher of Stories!")
			Npc:set_name(_"Mr. Saves, Watcher of Stories")
			Npc:says(_"The weather is grim again, don't you think? Ah, I love mental games. All the better when no one can understand them.")
			--Tux:says(_"...No one asked.")
			Tux:says(_"Uhm... great, I think?")
			show("weird", "alive", "lazy", "node99")
		elseif (Saves_times == 8) then
			Npc:says(_"You don't have anything better to do, do you?")
			Npc:says(_"I repeated the same thing seven times and you still come to bother me.")
			Npc:says(_"Seven is a number of luck, though. Here, take this program update and don't show up again.")
			Tux:improve_program("Animal Magnetism")
			Npc:says(_"[b]Animal Magnetism skill updated![/b]")
			Npc:says(_"If you do, I'll repeat myself until I manage to bore you out.")
			Tux:says(_"Uhm... Thanks?")
			Npc:says(_"Now get going. You have more important things to do.")
			end_dialog()
		else
			Npc:says(_"The sky is in a pretty blue azure today...") -- He could give different colors to sky based on player progress.
		end
	end,
	-- The first time you talk to Mr. Saves, you are presented the opportunity to do questions (most IRC-quotes based)
	{
		id = "alive",
		text = _"Why are you alive? Why are the bots not attacking you?",
		code = function()
			Npc:says(_"I don't exist under normal circumstances.") -- IRC quote
			Tux:says(_"Makes sense, you cannot attack something which doesn't exist.")
			Tux:says(_"...No wait. It doesn't. If you don't exist, I can't talk to you either!")
			Npc:says(_"Well, with strange aeons, even Mr. Saves may die.") -- IRC quote from quote “with strange aeons, even death may die”
			Tux:says(_"...You know what? You're weird. I bet the bots are just afraid of getting close to you.")
			hide('alive')
		end,
	},
	{
		id = "weird",
		text = _"You're weird.",
		code = function()
			Npc:says(_"That's my purpose in life.") -- IRC quote
			Tux:says(_"That only makes you weirder!")
			Npc:says(_"If you think too much about it, you'll end up overheating.")
			Npc:says(_"I advice you to drop this subject.")
			hide('weird')
		end,
	},
	{
		id = "lazy",
		text = _"What are you doing?",
		code = function()
			Npc:says(_"Volunteer work.")
			Tux:says(_"I don't see you working.")
			Npc:says(_"Well, that's because we volunteer for things exactly so that we can be lazy on them.") -- IRC quote
			Tux:says("...")
			hide('lazy')
		end,
	},
	{
		id = "node99",
		text = _"Er, uhm... Good bye?",
		code = function()
			play_sound("effects/Menu_Item_Selected_Sound_1.ogg")
			end_dialog()
		end,
	},
}
