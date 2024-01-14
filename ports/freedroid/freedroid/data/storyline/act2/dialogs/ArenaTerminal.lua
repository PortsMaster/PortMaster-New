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

local Npc = FDrpg.get_npc()

return {
	EveryTime = function()
		if (not arena_current_level) then
			end_dialog()
		elseif (arena_won) then
			Npc:says(_"[b]Arena Terminated[/b]")
			end_dialog()
		elseif (not arena_remaining_bots) then
			Npc:says(_"[b]Click on the button to stop the arena[/b]")
		else
			Npc:says(_"[b]Wave ongoing...[/b]")
			end_dialog()
		end

		show("click", "not_click")
	end,
	{
		id = "click",
		text = _"(Click)",
		echo_text = false,
		code = function()
			change_obstacle_state("Arena-RingEntrance", "opened")
			arena_next_wave = nil
			arena_withdraw = true
			end_dialog()
		end,
	},
	{
		id = "not_click",
		text = _"(Don't click)",
		echo_text = false,
		code = function()
			end_dialog()
		end,
	},
}
