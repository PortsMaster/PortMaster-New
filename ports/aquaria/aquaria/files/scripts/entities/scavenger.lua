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
v.chargeTimer = 0

local STATE_CHARGEPREP 	= 1001
local STATE_CHARGE 		= 1002

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Scavenger")	
	--entity_setAllDamageTargets(me, false)
	entity_setHealth(me, 28)
	entity_setCullRadius(me, 1024)	
	
	entity_setCollideRadius(me, 80)
	--entity_generateCollisionMask(me)
	
	entity_setState(me, STATE_IDLE)
	entity_setMaxSpeed(me, 500)
	entity_setDeathScene(me, true)
	
	entity_setDeathParticleEffect(me, "PinkExplode")
	
	loadSound("Scavenger-Die")
	loadSound("scavenger-attack")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if entity_isState(me, STATE_CHARGE) then
		entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 1000, 1.0)
	else
		entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.5)
	end
	entity_handleShotCollisions(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if entity_isState(me, STATE_IDLE) then
		if entity_isEntityInRange(me, v.n, 2048) then
			entity_moveTowardsTarget(me, dt, 500)
			entity_doCollisionAvoidance(me, dt, 4, 1)
			entity_doEntityAvoidance(me, dt, 256, 0.5)
			entity_doSpellAvoidance(me, dt, 512, 5)
			if math.abs(entity_x(me)-entity_x(v.n)) > 100 then
				entity_flipToEntity(me, v.n)
			end
			v.chargeTimer = v.chargeTimer + dt
			if v.chargeTimer > 4 then
				v.chargeTimer = 0
				entity_setState(me, STATE_CHARGEPREP)
			end
			entity_rotate(me, 0, 0.5)
		end
	elseif entity_isState(me, STATE_CHARGE) then
		entity_moveTowardsTarget(me, dt, 500)
		if not entity_isFlippedHorizontal(me) then		
			entity_rotateToVel(me, 0.1, 90)
		else
			entity_rotateToVel(me, 0.1, -90)
		end
	end
	
	
	entity_updateMovement(me, dt)	
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
		entity_setMaxSpeedLerp(me, 1.0, 0.2)
	elseif entity_isState(me, STATE_CHARGEPREP) then
		entity_setStateTime(me, entity_animate(me, "chargePrep"))
		entity_clearVel(me)
		entity_addVel(me, 0, -200)
	elseif entity_isState(me, STATE_CHARGE) then
		entity_sound(me, "scavenger-attack")
		entity_animate(me, "charge")
		entity_setMaxSpeedLerp(me, 4.0)
		entity_setStateTime(me, 2.5)
		entity_moveTowardsTarget(me, 1, 4000)
		entity_flipToEntity(me, v.n)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		entity_rotate(me, 0, 0.5)
		entity_color(me, 0.5, 0.5, 0.5, 3)
		entity_sound(me, "Scavenger-Die")
		local t = entity_animate(me, "death")
		entity_setStateTime(me, t)
		local x, y = entity_getPosition(me)
		while (isObstructed(x,y+16) == false) do
			y = y + 20
		end
		entity_setPosition(me, x, y, t*0.5)
	elseif entity_isState(me, STATE_GROW) then
		entity_setStateTime(me, entity_animate(me, "grow"))
	end
end

function exitState(me)
	if entity_isState(me, STATE_CHARGEPREP) then
		entity_setState(me, STATE_CHARGE)
	elseif entity_isState(me, STATE_CHARGE) then
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_GROW) then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		dmg = dmg * 1.5
	end
	return true
end

function animationKey(me, key)
end

function hitSurface(me)
	if entity_isState(me, STATE_CHARGE) then
		entity_setState(me, STATE_IDLE)
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

