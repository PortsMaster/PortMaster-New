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
v.note = 0
v.node = 0

function v.commonInit(me, myNote)
	v.note = myNote
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_setTexture(me, "particles/bigglow")

	entity_setState(me, STATE_IDLE)
	
	entity_scale(me, 1, 1)
	entity_scale(me, 1.5, 1.5, 1, -1, 1, 1)
	
	entity_setBlendType(me, BLEND_ADD)
	
	entity_setColor(me, getNoteColor(v.note))
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	v.node = getNode("WHALELAMPPUZZLEBRAIN")
end

function update(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_alpha(me, 0.01, 0.5)
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_ON) then
		entity_setStateTime(me, 12)
		entity_alpha(me, 0.5)
		entity_alpha(me, 1, 1, -1, 1, 1)
		
		if v.node ~= 0 then
			node_activate(v.node, me)
		end
	end
end

function exitState(me)
	if entity_isState(me, STATE_ON) then
		entity_setState(me, STATE_IDLE)
	end
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

function lightFlare(me)
	if entity_isEntityInRange(me, v.n, 256) then
		entity_soundFreq(me, getNoteName(v.note), 0.5, 4)
		debugLog("STATE ON")
		entity_setState(me, STATE_ON)
	end
end

function activate(me)
end

