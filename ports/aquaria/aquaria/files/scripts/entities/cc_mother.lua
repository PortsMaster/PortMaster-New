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

-- sings while animating

v.n = 0
v.singDelay = 60

v.singingStarted = false
v.head = 0

function init(me)
	setupEntity(me)
	--entity_setEntityLayer(me, 1)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "CC_Mother")
	entity_setAllDamageTargets(me, false)
		
	entity_setState(me, STATE_IDLE)
	
	entity_scale(me, 0.5, 0.5)
	
	loadSound("Anima")
	v.head = entity_getBoneByName(me, "Head")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if entity_getAlpha(me) == 1 then
		if v.singingStarted and entity_isState(me, STATE_SING) then
			if entity_isEntityInRange(me, v.n, 600) then
				v.singDelay = v.singDelay + dt
				if v.singDelay > 10 then
					v.singDelay = 0
					playSfx("Anima")
					--entity_setState(me, STATE_SING)
				end
			end
		end
		entity_setLookAtPoint(me, bone_getWorldPosition(v.head))
	end
	
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_SING) then
		entity_animate(me, "sing", -1)
		
		v.singingStarted = true
	end
end

function exitState(me)
	if entity_isState(me, STATE_SING) then
		--entity_setState(me, STATE_IDLE)
		v.singDelay = 0
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

function activate(me)
end

