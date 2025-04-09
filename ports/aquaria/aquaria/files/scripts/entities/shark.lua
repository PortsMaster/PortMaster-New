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

v.attackDelay = 0
v.dir = 1
v.jaw = 0

v.go = false

function init(me)
	setupBasicEntity(
	me,
	"",							-- texture
	30,							-- health
	2,							-- manaballamount
	2,							-- exp
	10,							-- money
	64,							-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,							-- particle "explosion" type, 0 = none
	0,							-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_initSkeletal(me, "Shark")	
	entity_generateCollisionMask(me)
	

	entity_setDeathParticleEffect(me, "Explode")
	
	entity_setState(me, STATE_IDLE)
	entity_setCullRadius(me, 1024)
	
	v.n = getNaija()
	v.jaw = entity_getBoneByName(me, "Jaw")
end

function update(me, dt)
	if entity_isState(me, STATE_ATTACK) and not entity_isAnimating(me) then
		entity_setState(me, STATE_IDLE)
	end
	
	if entity_isState(me, STATE_IDLE) then
		local inRange = false
		local x, y = bone_getWorldPosition(v.jaw)
		if entity_isPositionInRange(v.n, x, y, 550) then
			inRange = true
		end
		if v.dir < 0 then
			if entity_x(v.n) > entity_x(me) then
				inRange = false
			end
		else
			if entity_x(v.n) < entity_x(me) then
				inRange = false
			end
		end
		if inRange then
			v.attackDelay = v.attackDelay + dt
			if v.attackDelay > 1 then
				entity_setState(me, STATE_ATTACK)
				v.attackDelay = 0
			end
		end
	end
	
	entity_addVel(me, 500*v.dir, 0)
	
	if entity_isEntityInRange(me, v.n, 900) then
		entity_moveTowards(me, entity_x(v.n), entity_y(v.n), 1, 250)
	end
	
	if v.go then
		entity_moveTowardsTarget(me, 1, 1000)
	end
	
	entity_updateCurrents(me, dt)
	entity_updateMovement(me, dt)
	
	if not entity_isVelIn(me, 60) then
		entity_flipToVel(me)
	end
	
	if isObstructed(entity_x(me) + 300*v.dir, entity_y(me)) then
		v.dir = -v.dir
	end
	
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		if avatar_isTouchHit() then
			if entity_isState(me, STATE_ATTACK) then
				entity_damage(v.n, me, 2)
			else
				entity_damage(v.n, me, 1)
			end
		end
	end
end

function hitSurface(me)
	v.dir = -v.dir
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", LOOP_INF)
	elseif entity_isState(me, STATE_ATTACK) then
		entity_animate(me, "attack")
	end
end

function animationKey(me, key)
	if entity_isState(me, STATE_ATTACK) then
		if key == 2 then
			entity_setMaxSpeedLerp(me, 2)
			entity_moveTowardsTarget(me, 1, 1000)
			v.go = true
		elseif key == 3 then
			playSfx("bite", 0.2)
		elseif key == 5 then
			entity_setMaxSpeedLerp(me, 1, 0.5)
			v.go = false
		end
		--entity_moveTowardsTarget(me, 1, 50000)
	end
end

function exitState(me)
end

function dieNormal(me)
	if chance(100) then
		spawnIngredient("SharkFin", entity_x(me), entity_y(me))
	end
end

function damage(me)
	if entity_x(v.n) > entity_x(me) then
		v.dir = 1
	else
		v.dir = -1
	end
	entity_moveTowardsTarget(me, 1, 1000)
	return true
end
