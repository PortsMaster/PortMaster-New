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

-- orb holder
v.energyOrb = 0
v.openedDoors = false
v.savedOrb = false

function init(me)
	setupEntity(me, "OrbHolder", -2)
	entity_setActivationType(me, AT_NONE)	
	entity_setAllDamageTargets(me, false)
end

function update(me, dt)
	if entity_getState(me)==STATE_IDLE then
		if v.energyOrb == 0 then
			local orb = entity_getNearestEntity(me, "EnergyOrb")
			if orb ~=0 then
				if entity_isEntityInRange(me, orb, 64) then					
					entity_setWeight(orb, 0)
					entity_clearVel(orb)					
					v.energyOrb = orb
					entity_setProperty(orb, EP_MOVABLE, false)
				end
			end
		else
			entity_clearVel(v.energyOrb)
			entity_setPosition(v.energyOrb, entity_x(me), entity_y(me))
			if not v.openedDoors and entity_isState(v.energyOrb, STATE_CHARGED) then
				v.openedDoors = true
				local node = entity_getNearestNode(me)
				node_activate(node)
			end
			if not v.savedOrb and entity_isState(v.energyOrb, STATE_IDLE) then
				local node = entity_getNearestNode(me)
				node_activate(node)
				v.savedOrb = true
			end
			if v.openedDoors and entity_isState(v.energyOrb, STATE_IDLE) then
				v.openedDoors = false
			end
		end
	end
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
	end
end

function exitState(me)
end

function hitSurface(me)
end
