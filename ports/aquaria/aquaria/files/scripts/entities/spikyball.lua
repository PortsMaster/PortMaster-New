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
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "SpikyBall")
	entity_setAllDamageTargets(me, false)
	
	--entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setHealth(me, 9)
	entity_setCollideRadius(me, 32)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setWeight(me, 400)
	entity_setMaxSpeed(me, 800)
	
	entity_setBounce(me, 1.0)
	
	entity_setDamageTarget(me, DT_AVATAR_VINE, true)
	entity_setDamageTarget(me, DT_AVATAR_BITE, true)
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, true)
	entity_setUpdateCull(me, 2000)
	
	loadSound("SpikyBounce")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) then
		entity_handleShotCollisions(me)
		dt = dt * 2
		entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.5, 500)
		entity_updateCurrents(me, dt)
		entity_updateMovement(me, dt)
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_CHARGE1) then
		local sx, sy = entity_getScale(me)
		entity_scale(me)
		entity_scale(me, sx, sy, 1.5, 0, 0)
		entity_setStateTime(me, 1.5)
	end
end

function exitState(me)
	if entity_isState(me, STATE_CHARGE1) then
		if not entity_isDead(me) then
			entity_setState(me, STATE_IDLE)
		end
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -dmg*50)
		return true
	end
	return true
end

function animationKey(me, key)
end

v.lastx = 0
v.lasty = 0
function hitSurface(me)	
	entity_scale(me, 1, 0.75)
	entity_scale(me, 1, 1, 0.5)
	entity_sound(me, "SpikyBounce")
	if entity_x(me) == v.lastx and entity_y(me) == v.lasty then
		entity_clearVel(me)
		--entity_applySurfaceNormalForce(me, 800)
		entity_adjustPositionBySurfaceNormal(me, 16)
	end
	v.lastx = entity_x(me)
	v.lasty = entity_y(me)
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

