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

v.dir = 0
v.dirTimer = 0
v.attackDelay = 2
v.fireDelay = 0
v.n = 0
v.dodgePhase = 0
v.bone_body = 0

v.rideTimer = 0
v.maxRideTime = 20

v.throwOffTimer = 0
v.maxThrowOffTime = 15

local STATE_THROWOFF 			= 1000

v.roarDelay = 0

v.aggro = 0

v.firstSeen = true

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	64,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius
	STATE_IDLE,						-- initState
	0,								-- sprite width
	0,								-- sprite height
	0,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	3000
	)
	
	entity_initSkeletal(me, "GreenSeaDragon")	
	entity_generateCollisionMask(me)
	
	entity_animate(me, "idle", LOOP_INF)	
	
	entity_setMaxSpeed(me, 800)
	
	v.fireLoc = entity_getBoneByName(me, "FireLoc")
	bone_alpha(v.fireLoc)
	
	entity_setDeathParticleEffect(me, "GreenSeaDragonExplode")
	
	bone_setSegs(entity_getBoneByName(me, "Weeds1"), 2, 16, 0.5, 0.3, -0.018, 0, 12, 1)
	bone_setSegs(entity_getBoneByName(me, "Weeds2"), 2, 16, 0.5, 0.3, -0.018, 0, 12, 1)
	
	v.bone_body = entity_getBoneByName(me, "Body")
	
	entity_setCullRadius(me, 1024)
	
	loadSound("greenseadragon-die")
	loadSound("greenseadragon-roar")
	loadSound("greenseadragon-fire")
	
	entity_setDeathSound(me, "greenseadragon-die")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function dieNormal(me)

	if chance(5) then
		spawnIngredient("SpicyRoll", entity_getPosition(me))
	else
		if chance(10) then
			spawnIngredient("SpecialBulb", entity_getPosition(me))
		else
			if chance(10) then
				spawnIngredient("Poultice", entity_getPosition(me))
			else
				for i=1,3,1 do
					spawnIngredient("PlantLeaf", entity_getPosition(me))
				end
			end
		end
	end
end

function update(me, dt)
	--entity_handleShotCollisions(me)
	
	--entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0, 1000)
	
	if not isForm(FORM_FISH) then
		v.aggro = 1
	elseif isForm(FORM_FISH) and not entity_isEntityInRange(me, v.n, 1024) then
		v.aggro = 0
	end
	
	if v.firstSeen and entity_isTargetInRange(me, 800) then
		v.roarDelay = v.roarDelay - dt
		if v.roarDelay < 0 then
			playSfx("greenseadragon-roar")
			shakeCamera(6, 3)
			v.roarDelay = 5 + math.random(3)
			avatar_fallOffWall()
		end
		--v.firstSeen = false
	end

	--[[
	if dir == 0 then
		entity_addVel(me, -100*dt, 0)
	else
		entity_addVel(me, 100*dt, 0)
	end
	
	v.dirTimer = v.dirTimer - dt
	if v.dirTimer < 0 then
		v.dirTimer = 1
		if dir == 0 then
			dir = 1
		else
			dir = 0
		end
	end
	]]--
	v.dodgePhase = v.dodgePhase + dt
	if v.dodgePhase > 6 then
		v.dodgePhase = 0
	end
	if entity_isTargetInRange(me, 256)
	and v.aggro == 1 then
		entity_moveTowardsTarget(me, dt, -1000)
	elseif entity_isTargetInRange(me, 1024)
	and v.aggro == 1 then
		entity_moveTowardsTarget(me, dt, 500)
	end
	if v.dodgePhase > 3 then
		--entity_doSpellAvoidance(me, dt, 128, 0.5)
	end
	entity_doCollisionAvoidance(me, dt, 4, 1.0)
	
	if (math.abs(entity_x(v.n) - entity_x(me)) > 140) then
		entity_flipToEntity(me, v.n)
	end

	if entity_isState(me, STATE_IDLE)
	and v.aggro == 1 then
		v.attackDelay = v.attackDelay - dt
		if v.attackDelay < 0 then
			entity_setState(me, STATE_ATTACK)			
		end
	elseif entity_isState(me, STATE_ATTACK) then
		v.fireDelay = v.fireDelay - dt
		if v.fireDelay < 0 then
			v.fireDelay = 0.2
			local vx, vy = bone_getNormal(v.fireLoc)
			local x, y = bone_getWorldPosition(v.fireLoc)
			local s = createShot("GreenSeaDragon", me, entity_getTarget(me), x, y)
			shot_setAimVector(s, vx, vy)			
			--local s = entity_fireAtTarget(me, "", 1, 100, 0, 3, 32, 0, 0, vx, vy, x, y)
			--shot_setNice(s, "Shots/HotEnergy", "HeatTrailSmall", "HeatHit")
		end
	elseif entity_isState(me, STATE_THROWOFF) then
		local range = 5 + v.throwOffTimer * 10
		if range > 30 then
			range = 30
		end
		entity_offset(me, math.random(range/2)-range, math.random(range/2)-range)
		v.throwOffTimer = v.throwOffTimer + dt * math.random(3)
		if v.throwOffTimer > v.maxThrowOffTime then
			avatar_fallOffWall()
			
			entity_moveTowards(v.n, entity_x(me), entity_y(me), 1, -2000)
			entity_moveTowards(me, entity_x(v.n), entity_y(v.n), 1, -1200)
		end
	end
	entity_updateMovement(me, dt)
	
	local ent = entity_getBoneLockEntity(v.n)
	if ent == me then
		v.rideTimer = v.rideTimer + dt
		if v.rideTimer > v.maxRideTime and not entity_isState(me, STATE_THROWOFF) then
			entity_setState(me, STATE_THROWOFF)
		end
	else
		if entity_isState(me, STATE_THROWOFF) then
			entity_setState(me, STATE_IDLE)
		end
		v.rideTimer = 0
	end
	
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if avatar_isBursting() and bone == v.bone_body and entity_setBoneLock(v.n, me, bone) then
	else
		entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0, 1000)
	end
	
	entity_handleShotCollisionsSkeletal(me)
end

function hitSurface(me)
end

function enterState(me, state)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_ATTACK) then
		entity_setStateTime(me, entity_animate(me, "attack"))
		v.attackDelay = 0.5 + math.random(150)/100.0
		v.fireDelay = 0.3
	elseif entity_isState(me, STATE_THROWOFF) then
		v.throwOffTimer = v.throwOffTimer - 5
		if v.throwOffTimer < 0 then
			v.throwOffTimer = 0
		end
	elseif entity_isState(me, STATE_DEAD) then
		shakeCamera(10, 3)
	end
end

function exitState(me, state)
	if entity_isState(me, STATE_ATTACK) then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me)
	v.rideTimer = v.rideTimer + 1.5
	v.aggro = 1
	return true
end
