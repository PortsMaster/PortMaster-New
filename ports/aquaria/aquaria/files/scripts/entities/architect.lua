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

v.n = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "Lumerean")	

	entity_scale(me, 0.5, 0.5)
	entity_setState(me, STATE_IDLE)
	
	entity_animate(me, "idle", -1)
	
	entity_offset(me, 0, 32, 1, -1, 1, 1)
	
	entity_setCullRadius(me, 1024)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	local w = entity_getNearestNode(me, "WORSHIP")
	if w ~= 0 and node_isEntityIn(w, me) then
		entity_animate(me, "worship", -1)
	end
	
	local f = entity_getNearestNode(me, "FLIP")
	if f ~= 0 and node_isEntityIn(f, me) then
		entity_fh(me)
	end
	
	local p = entity_getNearestNode(me, "PAIN")
	if p ~= 0 and node_isEntityIn(p, me) then
		entity_animate(me, "pain", -1)
	end
end

function update(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		
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

