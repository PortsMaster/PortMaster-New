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
v.small = 32
v.big = 90

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "PufferFish")	
	--entity_setAllDamageTargets(me, false)
	
	--entity_generateCollisionMask(me)	
	
	entity_setState(me, STATE_IDLE)
	entity_setBounceType(me, BOUNCE_REAL)
	
	entity_setDamageTarget(me, DT_AVATAR_BITE, false)
	
	entity_setCullRadius(me, 300)
	
	entity_setHealth(me, 12)
	
	entity_setDeathParticleEffect(me, "TinyRedExplode")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	local x, y = entity_getNormal(me)
	local sw = y
	y = -x
	x = sw
	entity_addVel(me, x*500, y*500)
end

local function rotflip(me)
	if entity_isfh(me) then
		entity_rotateToVel(me, 0, -90)
	else
		entity_rotateToVel(me, 0, 90)
	end
	entity_flipToVel(me)
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) then
		if entity_isEntityInRange(me, v.n, v.big*2) then
			entity_setState(me, STATE_OPEN)
		end
		entity_doCollisionAvoidance(me, dt, 8, 0.1)
		entity_doEntityAvoidance(me, dt, 32, 1)
		rotflip(me)
	end
	if entity_isState(me, STATE_OPENED) then
		if not entity_isEntityInRange(me, v.n, v.big+400) then
			entity_setState(me, STATE_CLOSE)
		end
		if not entity_isBeingPulled(me) then
			rotflip(me)
		end

		local e = getFirstEntity()
		while e ~= 0 do
			if e ~= me and entity_getEntityType(e) == ET_ENEMY then
				if entity_isEntityInRange(me, e, v.big + entity_getCollideRadius(e)) then
					entity_damage(e, me, dt*10, DT_CRUSH)
				end
			end
			e = getNextEntity()
		end
	end
	
	entity_updateMovement(me, dt)
	entity_handleShotCollisions(me)
	if not entity_isBeingPulled(me) then
		entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 500)
	end	
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setProperty(me, EP_MOVABLE, false)
		entity_animate(me, "idle", -1)
		entity_setCollideRadius(me, v.small)
		entity_setMaxSpeed(me, 100)
	elseif entity_isState(me, STATE_OPEN) then
		entity_setStateTime(me, entity_animate(me, "grow"))
	elseif entity_isState(me, STATE_CLOSE) then
		entity_setStateTime(me, entity_animate(me, "shrink"))
	elseif entity_isState(me, STATE_OPENED) then
		entity_clearVel(me)
		entity_setProperty(me, EP_MOVABLE, true)
		entity_setCollideRadius(me, v.big)
		entity_animate(me, "idleBig", -1)
	end
end

function exitState(me)
	if entity_isState(me, STATE_OPEN) then
		entity_setState(me, STATE_OPENED)
	elseif entity_isState(me, STATE_CLOSE) then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
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

