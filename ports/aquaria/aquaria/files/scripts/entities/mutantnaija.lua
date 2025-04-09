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

v.head = 0

local STATE_SWIM		= 1000
local STATE_BURST		= 1001

v.burstDelay		= 0

v.singDelay			= 4

v.fireDelay			= 3
v.fired				= 0
v.fireShotDelay		= 0

local function idle(me)
	entity_setState(me, STATE_IDLE, math.random(1)+0.5)
end

local function doBurstDelay()
	v.burstDelay = math.random(4) + 2
end

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Naija", "Mutant")	
	--entity_setAllDamageTargets(me, false)
	
	entity_scale(me, 0.7, 0.7)
	
	entity_setCollideRadius(me, 20)
	entity_setHealth(me, 20)
	
	
	bone_alpha(entity_getBoneByName(me, "Fish2"),0)
	bone_alpha(entity_getBoneByName(me, "DualFormGlow"),0)
	
	v.head = entity_getBoneByName(me, "Head")
	
	entity_setDeathScene(me, true)
	
	idle(me)
	
	entity_setUpdateCull(me, 1300)
	
	loadSound("mutantnaija-note")
	loadSound("mutantnaija-note-hit")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	entity_updateMovement(me, dt)
	
	entity_handleShotCollisions(me)
	
	entity_setLookAtPoint(me, bone_getWorldPosition(v.head))
	
	if entity_isState(me, STATE_IDLE) then
		entity_rotate(me, 0, 0.1)
	elseif entity_isState(me, STATE_SWIM) then
		entity_moveTowardsTarget(me, dt, 500)
		v.burstDelay = v.burstDelay - dt
		if v.burstDelay < 0 then
			doBurstDelay()
			entity_setMaxSpeedLerp(me, 2)
			entity_setMaxSpeedLerp(me, 1, 4)
			entity_moveTowardsTarget(me, 1, 1000)
			entity_animate(me, "burst", 0, 1)
		end
		entity_rotateToVel(me, 0.1)
	end
	entity_doEntityAvoidance(me, dt, 32, 0.5)
	entity_doCollisionAvoidance(me, dt, 4, 0.5)
	
	--[[
	v.singDelay = v.singDelay - dt
	if v.singDelay < 0 then
		v.singDelay = math.random(3) + 3
		entity_sound(me, getNoteName(math.random(8)), 1, 3)
		local x = entity_x(v.n) - entity_x(me)
		local y = entity_y(v.n) - entity_y(me)
		x, y = vector_setLength(x, y, 1000)
		entity_addVel(v.n, x, y)
	end
	]]--
	
	if entity_isState(me, STATE_SWIM) then
		if v.fired == -1 then
			v.fireDelay = v.fireDelay - dt
			if v.fireDelay < 0 then
				v.fired = 3
				v.fireDelay = math.random(2) + 3
				v.fireShotDelay = 0
			end
		end
	end
	
	if v.fired > -1 then
		v.fireShotDelay = v.fireShotDelay - dt
		if v.fireShotDelay < 0 then
			local s = createShot("MutantNaija", me, v.n, bone_getWorldPosition(v.head))
			v.fired = v.fired - 1
			if v.fired == 0 then
				v.fired = -1 
			end
			v.fireShotDelay = 0.2
		end
	end
	
	local thresh = 10
	if entity_velx(me) > thresh and not entity_isfh(me) then
		entity_fh(me)
	end
	if entity_velx(me) < -thresh and entity_isfh(me) then
		entity_fh(me)
	end
	
	entity_touchAvatarDamage(me, 8, 1, 500)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_SWIM) then
		entity_animate(me, "swim", -1)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		entity_setColor(me, 0.3, 0.3, 0.3, 1)
		entity_setPosition(me, entity_x(me), entity_y(me)+400, -300)
		entity_setStateTime(me, entity_animate(me, "diePainfully", 2))
		entity_rotate(me, 0, 0.1)
	end
end

function exitState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_rotate(me, 0, 0.1)
		entity_setState(me, STATE_SWIM, math.random(6)+4)
	elseif entity_isState(me, STATE_SWIM) then
		idle(me)
		doBurstDelay()
	elseif entity_isState(me, STATE_DEATHSCENE) then
		spawnParticleEffect("TinyBlueExplode", entity_getPosition(me))
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

