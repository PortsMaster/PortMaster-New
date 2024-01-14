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
PERSONALITY = { "Robotic" },
BACKSTORY = "$$NAME$$ is a bot used by MegaSys for testing purposes. Because $$NAME$$ is running a very rudimentary
	 operating system, Tux cannot takeover and control $$NAME$$."
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
		text = _"This is a MegaSys test bot, running a very basic version of their OS. I can do nothing with this bot, because it doesn't know how to do anything.",
		code = function()
			hide("node0")
		end,
	},
	{
		id = "node99",
		--; TRANSLATORS: command, user lowercase here
		text = _"logout",
		code = function()
			end_dialog()
		end,
	},
}
