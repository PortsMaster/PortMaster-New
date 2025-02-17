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
v.soundDelay = 0
v.dir = 0
v.dirTimer = 0

v.bubDelay = 0

function init(me)
	v.attackDelay = 1 + math.random(3)

	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Tabar")	
	--entity_setAllDamageTargets(me, false)
	
	entity_setCollideRadius(me, 32)
	
	entity_setState(me, STATE_IDLE)
	entity_scale(me, 0.7, 0.7)
	
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	entity_setDropChance(me, 25, 1)
	
	entity_setMaxSpeed(me, 300)
	
	entity_setHealth(me, 6)
	
	loadSound("froogflap")
	loadSound("tabar-die")
	loadSound("tabar-attack")
	entity_setDeathSound(me, "tabar-die")
end

function postInit(me)
	v.n = getNaija()
	--entity_setTarget(me, v.n)
end

function update(me, dt)	
	dt = dt * 1.1
	if entity_isState(me, STATE_IDLE) then
		if entity_hasTarget(me) then
			v.dirTimer = v.dirTimer + dt
			if v.dirTimer > 1 then
				if v.dir == 0 then v.dir = 1 else v.dir = 0 end
				v.dirTimer = 0
			end
			entity_doCollisionAvoidance(me, dt, 8, 0.2)
			entity_addVel(me, 0, -800*dt)
			if v.dir == 0 then
				entity_addVel(me, -400*dt)
			else
				entity_addVel(me, 400*dt)
			end
			v.attackDelay = v.attackDelay - dt
			if v.attackDelay < 0 then
				v.attackDelay = 0
				local x, y = entity_getPosition(me)
				local x2 = x
				local y2 = y + 1000
				if entity_collideCircleVsLine(me, x, y, x2, y2, 64) then
					entity_setState(me, STATE_CHARGE1)
				end
			end
			entity_findTarget(me, 1000)
		else
			entity_findTarget(me, 900)
		end
	elseif entity_isState(me, STATE_ATTACK) then
		v.bubDelay = v.bubDelay + dt
		if v.bubDelay > 0.1 then
			v.bubDelay = 0
			spawnParticleEffect("bubble-release-short", entity_x(me), entity_y(me))
		end
		
		v.soundDelay = v.soundDelay + dt
		if v.soundDelay >= 0.4 then
			
			entity_playSfx(me, "FroogFlap")
			v.soundDelay = 0
		end
	
		entity_moveTowardsTarget(me, dt, 200)
	elseif entity_isState(me, STATE_CHARGE1) then
		entity_doFriction(me, dt, 800)
	end	
	entity_updateMovement(me, dt)
	
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 800)	
end

function dieEaten(me)
	
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
		entity_setMaxSpeedLerp(me, 1, 2)
	elseif entity_isState(me, STATE_DEAD) then	
		spawnParticleEffect("TabarDie", entity_getPosition(me))
	elseif entity_isState(me, STATE_CHARGE1) then
		entity_sound(me, "tabar-attack")
		entity_doGlint(me, "Glint", BLEND_ADD)
		entity_setStateTime(me, 0.5)
	elseif entity_isState(me, STATE_ATTACK) then
		entity_animate(me, "dive")
		entity_setMaxSpeedLerp(me, 3.8)
		entity_moveTowardsTarget(me, 1, 5000)
		entity_setMaxSpeedLerp(me, 3.8,0.5)
		entity_addVel(me, 0, 5000)
	end
end

function exitState(me)
	if entity_isState(me, STATE_ATTACK) then
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_CHARGE1) then
		entity_setState(me, STATE_ATTACK, 2)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -1)
	end
	return true
end

function animationKey(me, key)
end

function hitSurface(me)
	if entity_isState(me, STATE_ATTACK) then
		entity_setState(me, STATE_IDLE)
		v.attackDelay = 2+math.random(3)
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

