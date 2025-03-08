-- Copyright (C) 2007, 2010 - Bit-Blot
--
-- This file is part of Aquaria.
--
-- Aquaria is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

-- ================================================================================================
-- MENGRIL
-- ================================================================================================

running = false

function init(me)
	setupConversationEntity(me, "Mengil")
	entity_initSkeletal(me, "merman", "mengil")
	entity_animate(me, "idle", LOOP_INF)
	entity_scale(me, 0.6, 0.6)
	entity_setActivation(me, AT_CLICK, 80, 256)
	if isMapName("TransitPort") then
		entity_animate(me, "sitting", LOOP_INF)
	end

end

function update(me, dt)
	if getStory() < 15 and not running then
		running = true
		naija = getEntity("Naija")
		mengrilNode = getNode("GATE")
		if entity_x(naija) > node_x(mengrilNode) then
			-- the line must be drawn HERE!
			wnd(1)
			txt("Mengril: THOUH SHALT NOT PASS!")
			wnd(0)
			entity_swimToNode(naija, getNode("NAIJABACKOFF"))
			entity_watchForPath(naija)			
		end
		running = false
	end
end

function enterState(me)
end

function exitState(me)
end

function activate(me)
	if getStory() <15 then
		wnd(1)
		txt("Mengril: What? You expect me to have dialogue for the section of the game wherein you're not allowed to leave MainArea?")
		txt("Mengril: Puppy Cocks!")
		wnd(0)
	end
end

function hitSurface(me)
end
