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
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_setTexture(me, "falsebg/bg")	
	
	entity_scale(me, 1.6, 1.6)
	
	entity_setState(me, STATE_IDLE)
	
	loadSound("mia-appear")
	
	esetv(me, EV_LOOKAT, 0)
end

function update(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_CLOSE) then
		entity_alpha(me, 0, 4)
		entity_setSegs(me, 2, 8, 0.8, 0.8, -0.018, 0, 6, 1)
		
		entity_scale(me, 3, 3, 4)
		
		playSfx("mia-appear")
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

