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

function init(me)
	setupEntity(me, "EnergyOrb")
	entity_setEntityType(me, ET_NEUTRAL)
	entity_setProperty(me, EP_MOVABLE, true)
	entity_setWeight(me, 300)
	entity_setCollideRadius(me, 32)	
	entity_setMaxSpeed(me, 450)
	entity_setColor(me, 1, 0, 0)
	entity_setName(me, "SacrificeVictim")
	if entity_isFlag(me, 1) then
		entity_delete(me)
	end	
end

function update(me, dt)
	entity_updateMovement(me, dt)
	--entity_updateCurrents(me)
end

function enterState(me)
end

function exitState(me)
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)	
	return false
end

function activate(me)
end
