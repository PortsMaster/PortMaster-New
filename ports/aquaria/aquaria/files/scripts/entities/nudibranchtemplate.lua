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
v.noteDown = -1
v.note1 = -1
v.note2 = -1
v.note3 = -1

function v.commonInit(me, gfxNum, n1, n2, n3)
	setupEntity(me)
	entity_setTexture(me, string.format("NudiBranch/NudiBranch%d", gfxNum))
	entity_setEntityType(me, ET_ENEMY)
	entity_setAllDamageTargets(me, false)
	entity_setCollideRadius(me, 48)
	
	v.note1 = n1
	v.note2 = n2
	v.note3 = n3
	
	entity_setState(me, STATE_IDLE)
	
	entity_setMaxSpeed(me, 700)
	
	entity_offset(me, 0, 10, 1, -1, 1, 1)
	entity_update(me, math.random(100)/100.0)
	entity_setUpdateCull(me, 2000)
	
	entity_setDamageTarget(me, DT_AVATAR_VINE, true)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)

	if v.noteDown ~= -1 and entity_isEntityInRange(me, v.n, 800) then
		local rotspd = 0.8
		if v.noteDown == v.note2 then
			entity_moveTowardsTarget(me, dt, 1000)
			if entity_doEntityAvoidance(me, dt, 128, 1.0) then
				entity_setMaxSpeedLerp(me, 0.2)
			else
				entity_setMaxSpeedLerp(me, 2.0, 0.2)
			end
			entity_rotateToVel(me, rotspd)
		elseif v.noteDown == v.note1 or v.noteDown == v.note3 then			
			entity_moveTowardsTarget(me, dt, 500)
			if entity_doEntityAvoidance(me, dt, 128, 1.0) then
				entity_setMaxSpeedLerp(me, 0.2)
			else
				entity_setMaxSpeedLerp(me, 1, 0.2)
			end
			entity_rotateToVel(me, rotspd)
		end			
		
	else
		v.noteDown = -1
		entity_rotate(me, 0, 0.5, 0, 0, 1)
	end
	
	entity_doFriction(me, dt, 300)
	entity_updateMovement(me, dt)
	
	entity_handleShotCollisions(me)
	
	if isForm(FORM_NATURE) then
		entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.5, 500, 0)
	else
		entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1.0, 500, 0)
	end
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
	v.noteDown = note
end

function songNoteDone(me, note)
	v.noteDown = -1
end

function song(me, song)
end

function activate(me)
end

