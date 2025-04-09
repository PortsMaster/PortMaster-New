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

v.naija = 0
v.door = 0
v.done = false

function init(me)
	v.naija = getNaija()
	node_setCursorActivation(me, false)
	v.door = node_getNearestEntity(me, "EnergyDoor")
	if v.door ~= 0 then
		entity_setState(v.door, STATE_OPENED)
	end
end

function activate(me)
end

function update(me, dt)
	if not v.done and getStory() <= 8 then
		if node_isEntityIn(me, v.naija) then
			v.done = true
			
			local boss = node_getNearestEntity(me, "EnergyBoss")
			setStory(8)
			entity_setState(v.door, STATE_CLOSE)
			entity_flipToEntity(getNaija(), boss)
			wnd(1)
			txt("Naija: ...")
			wnd(0)
			
			entity_setState(boss, STATE_AWAKEN)
			
			playMusic("BigBoss")
		end
	end
end
