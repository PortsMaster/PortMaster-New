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

-- ================================================================================================
-- EEL
-- ================================================================================================

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

v.dir = 0
v.switchDirDelay = 0
v.wiggleTime = 0
v.wiggleDir = 1
v.interestTimer = 0
v.colorRevertTimer = 0

v.collisionSegs = 25
v.avoidLerp = 0
v.avoidDir = 1
v.interest = false
local STATE_AROUND = 1001
v.dir = 0
v.idleDelay = 3

v.n = 0

v.bone_body = 0

-- initializes the entity
function init(me)
-- oldhealth : 40
	setupBasicEntity(
	me,
	"",						-- texture
	50,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1,							-- updateCull -1: disabled, default: 4000
	0
	)
	
	entity_setDropChance(me, 50)
	
	entity_initHair(me, 64, 8, 64, "ekkrit/tail")
	--[[
	entity_initSegments(
	25,								-- num segments
	2,								-- minDist
	12,								-- maxDist
	"wurm-body",						-- body tex
	"wurm-tail",						-- tail tex
	128,								-- width
	128,								-- height
	0.01,							-- taper
	0								-- reverse segment direction
	)
	]]--
	
	if chance(50) then
		v.dir = 0
	else
		v.dir = 1
	end
	
	if chance(50) then
		v.interest = true
	end
	v.switchDirDelay = math.random(800)/100.0
	v.naija = getNaija()
	
	entity_addVel(me, math.random(1000)-500, math.random(1000)-500)
	entity_setDeathParticleEffect(me, "Explode")
	
	entity_initSkeletal(me, "Ekkrit")
	entity_generateCollisionMask(me)
	entity_animate(me, "idle", LOOP_INF)
	entity_setDeathScene(me, true)
	entity_setCullRadius(me, 1024)
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	
	v.bone_body = entity_getBoneByName(me, "Body")
	
	loadSound("EkkritCall")
	loadSound("EkkritHit")
	loadSound("EkkritIdle")
end

function postInit(me)
	v.n = getNaija()
end

v.lastRot = 0
v.timer = 0
-- the entity's main update function
function update(me, dt)
	v.idleDelay = v.idleDelay - dt
	if v.idleDelay < 0 then
		entity_sound(me, "EkkritIdle", (math.random(300)+800)/1000.0)
		v.idleDelay = math.random(3) + 3
	end
	if entity_isState(me, STATE_AROUND) then
		dt = dt * 1.5
	end
	if v.colorRevertTimer > 0 then
		v.colorRevertTimer = v.colorRevertTimer - dt
		if v.colorRevertTimer < 0 then
			entity_setColor(me, 1, 1, 1, 3)
		end
	end
	

	--entity_handleShotCollisionsHair(me, v.collisionSegs)
	-- in idle state only
	if entity_getState(me)==STATE_IDLE then		
		entity_doCollisionAvoidance(me, dt, 16, 0.05)
		entity_doCollisionAvoidance(me, dt, 4, 0.5)
	end

	if not entity_hasTarget(me) then
		entity_findTarget(me, 500)
	else
		-- has target
		if entity_isState(me, STATE_IDLE) then
			--debugLog(string.format("timer: %f", timer))
			local t = 6
			if entity_getRotation(me) > v.lastRot then
				v.timer = v.timer + dt 
				if v.timer > t then
					v.dir = 1
					entity_setState(me, STATE_AROUND)
					v.timer = 0	
				end
			elseif entity_getRotation(me) < v.lastRot then
				v.timer = v.timer - dt
				if v.timer < -t then
					v.dir = 0
					entity_setState(me, STATE_AROUND)
					v.timer = 0
				end
			end
			v.lastRot = entity_getRotation(me)
			if entity_isNearObstruction(entity_getTarget(me), 4) then
				entity_moveTowardsTarget(me, dt, -100)
			else
				entity_moveTowardsTarget(me, dt, 500)
			end
		elseif entity_isState(me, STATE_AROUND) then
			entity_moveAroundTarget(me, dt, 5000, v.dir)
			entity_doCollisionAvoidance(me, dt, 16, 0.5)
			entity_doCollisionAvoidance(me, dt, 4, 1.0)
		end
	end
	--entity_flipToVel(me)
	entity_rotateToVel(me, 0.3)
	entity_updateMovement(me, dt)	
	entity_setHairHeadPosition(me, entity_x(me), entity_y(me))
	entity_updateHair(me, dt)
	entity_handleShotCollisionsSkeletal(me)
	
	--[[
	if entity_collideHairVsCircle(me, v.naija, v.collisionSegs) then
		entity_touchAvatarDamage(me, 0, 0, 500)
	end
	]]--

	local bone = entity_collideSkeletalVsCircle(me, v.naija)
	if bone ~= 0 then
		if avatar_isBursting() and bone == v.bone_body and entity_setBoneLock(v.n, me, bone) then
		else
			local bx, by = bone_getWorldPosition(bone)
			local x, y = entity_getPosition(v.n)
			x = x - bx
			y = y - by
			x,y = vector_setLength(x, y, 800)
			entity_addVel(v.n, x, y)
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setNaijaReaction(me, "")
		entity_setMaxSpeedLerp(me, 1, 0.5)
		entity_setMaxSpeed(me, 200)
	elseif entity_isState(me, STATE_AROUND) then
		entity_setNaijaReaction(me, "smile")
		entity_sound(me, "EkkritCall", (math.random(100)+950)/1000.0)
		entity_setMaxSpeedLerp(me, 2.5)		
		entity_setStateTime(me, 5)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		entity_setNaijaReaction(me, "shock")
		entity_setStateTime(me, -1)
		entity_offset(me, 0, 10, 0.5, -1, 1)
		shakeCamera(10, 3)
		cam_toEntity(me)
		watch(2)
		cam_toEntity(getNaija())
		entity_setStateTime(me, 0.1)
	end
end

function exitState(me)
	if entity_isState(me, STATE_AROUND) then
		entity_setState(me, STATE_IDLE)
	end
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	entity_sound(me, "EkkritHit", (math.random(100)+950)/1000.0)
	entity_setMaxSpeedLerp(me, 5)
	entity_setMaxSpeedLerp(me, 1, 3)
	entity_addVel(me, entity_velx(me)*2, entity_vely(me)*2)
	entity_doSpellAvoidance(me, 1, 32, 1)
	v.timer = 0
	return true
end

function songNote(me, note)
end
