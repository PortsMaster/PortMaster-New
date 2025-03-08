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
v.dir = 0

local STATE_FLYING = 1000
local STATE_FALLING = 1001
v.inity = 0
v.drownTimer = 0
v.drownTime = 6

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Parrot")	
	--entity_setAllDamageTargets(me, true)
	--entity_setEntityLayer(me, 0)

	entity_setCollideRadius(me, 32)
	
	entity_setHealth(me, 5)
	
	entity_setState(me, STATE_FLYING)
	
	entity_setCanLeaveWater(me, true)
	entity_setMaxSpeed(me, 800)
	entity_scale(me, 0.8, 0.8)
	entity_setDeathParticleEffect(me, "ParrotHit")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	v.inity = entity_y(me)
end

function update(me, dt)
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.5, 1000, 0)
	
	if entity_isState(me, STATE_FLYING) then
		if v.dir == 0 then
			entity_addVel(me, -800*dt, 0)
		else
			entity_addVel(me, 800*dt, 0)
		end
		entity_flipToVel(me)
	end
	if not entity_isState(me, STATE_IDLE) then	
		entity_updateMovement(me, dt)
		--entity_setPosition(me, entity_x(me), v.inity, 0)
	end
	if entity_isUnderWater(me) then
		if not entity_isState(me, STATE_FALLING) then
			entity_setState(me, STATE_FALLING)
		end
		v.drownTimer = v.drownTimer + dt
		if v.drownTimer > v.drownTime then
			entity_damage(me, me, 999)
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_FLYING) then
		entity_animate(me, "fly", -1)		
		entity_setWeight(me, 0)
	elseif entity_isState(me, STATE_FALLING) then
		entity_setWeight(me, 300)
		entity_addVel(me, -entity_velx(me)/2, 400)
		entity_setMaxSpeedLerp(me, 2, 0.1)
		entity_rotate(me, 160, 2, 0, 0, 1)
		entity_animate(me, "idle", -1)
		--spawnParticleEffect("ParrotHit", entity_x(me), entity_y(me))
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if attacker == me then return true end
	--debugLog(string.format("parrot health: %d", entity_getHealth(me)))
	spawnParticleEffect("ParrotHit", entity_x(me), entity_y(me))
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -50)
		return true
	elseif damageType == DT_AVATAR_ENERGYBLAST or damageType == DT_AVATAR_SHOCK or damageType == DT_CRUSH then
		entity_setState(me, STATE_FALLING)
		spawnParticleEffect("ParrotHit", entity_x(me), entity_y(me))
		return true
	end
	return false
end

function animationKey(me, key)
end

function hitSurface(me)
	if v.dir == 0 then
		v.dir = 1
	else
		v.dir = 0
	end
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

