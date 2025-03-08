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
-- JELLY
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.blupTimer = 0
v.dirTimer = 0
v.blupTime = 3.0


local STATE_SHOCK		= 1000

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================
v.sz = 1.0
v.dir = 0

local MOVE_STATE_UP = 0
local MOVE_STATE_DOWN = 1

v.moveState = 0
v.moveTimer = 0
v.velx = 0
v.waveDir = 1
v.waveTimer = 0
v.soundDelay = 0
v.shockDelay = 5

v.collisionSegs = 28

local function doIdleScale(me)	
	entity_scale(me, 1.0*v.sz, 0.75*v.sz, v.blupTime, -1, 1, 1)
end

function init(me)
	setupBasicEntity(
	me,
	"JellyShock",						-- texture
	12,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	32,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000,							-- updateCull -1: disabled, default: 4000
	1
	)
	
	entity_setEntityType(me, ET_ENEMY)
	
	entity_setDeathParticleEffect(me, "Explode")
	
	--entity_initSkeletal(me, "Jelly")
	
	--entity_scale(me, 0.6, 0.6)
	
	entity_initHair(me, 40, 5, 36, "JellyShockTentacles")
	
	entity_setState(me, STATE_IDLE)
	entity_setDropChance(me, 50)
	
	entity_scale(me, 0.75*v.sz, 1*v.sz)
	doIdleScale(me)
	
	entity_exertHairForce(me, 0, 400, 1)
	--entity_setWeight(me, 50)	
	--entity_initStrands(me, 5, 16, 8, 15, 0.8, 0.8, 1)			
end

function update(me, dt)
	dt = dt * 1.5
	if true then
		if avatar_isBursting() or entity_getRiding(getNaija())~=0 then
			local e = entity_getRiding(getNaija())
			if entity_touchAvatarDamage(me, 32, 0, 400) then
				if e~=0 then
					local x,y = entity_getVectorToEntity(me, e)
					x,y = vector_setLength(x, y, 500)
					entity_addVel(e, x, y)
				end
				local len = 500
				local x,y = entity_getVectorToEntity(getNaija(), me)
				x,y = vector_setLength(x, y, len)
				entity_push(me, x, y, 0.2, len, 0)
				entity_sound(me, "JellyBlup", 800)
			end		
		else
			if entity_touchAvatarDamage(me, 32, 0, 1000) then		
				entity_sound(me, "JellyBlup", 800)
			end
		end
	end
	entity_handleShotCollisions(me)
	
	--[[
	if entity_collideHairVsCircle(me, getNaija(), v.collisionSegs) then
		entity_touchAvatarDamage(me, 0, 0, 800)
	end
	]]--
	
	-- Quick HACK to handle getting bumped out of the water.  --achurch
	if not entity_isUnderWater(me) then
		v.moveState = MOVE_STATE_DOWN
		v.moveTimer = 5 + math.random(200)/100.0 + math.random(3)
		entity_setMaxSpeed(me, 500)
		entity_setMaxSpeedLerp(me, 1, 0)
		entity_addVel(me, 0, 500*dt)
		entity_updateMovement(me, dt)
		entity_setHairHeadPosition(me, entity_x(me), entity_y(me))
		entity_updateHair(me, dt)
		return
	elseif not entity_isState(me, STATE_PUSH) then
		entity_setMaxSpeed(me, 50)
	end
	
	v.moveTimer = v.moveTimer - dt
	if v.moveTimer < 0 then
		if v.moveState == MOVE_STATE_DOWN then		
			v.moveState = MOVE_STATE_UP
			entity_setMaxSpeedLerp(me, 1.5, 0.2)
			entity_scale(me, 0.75, 1, 1, 1, 1)
			v.moveTimer = 3 + math.random(200)/100.0
			entity_sound(me, "JellyBlup")
		elseif v.moveState == MOVE_STATE_UP then
			v.velx = math.random(400)+100
			if math.random(2) == 1 then
				v.velx = -v.velx
			end
			v.moveState = MOVE_STATE_DOWN
			doIdleScale(me)
			entity_setMaxSpeedLerp(me, 1, 1)
			v.moveTimer = 5 + math.random(200)/100.0 + math.random(3)
		end
	end
	
	v.waveTimer = v.waveTimer + dt
	if v.waveTimer > 2 then
		v.waveTimer = 0
		if v.waveDir == 1 then
			v.waveDir = -1
		else
			v.waveDir = 1
		end
	end
	
	
	--entity_exertHairForce(me, entity_v.velx(me), entity_vely(me), dt, -1)
	
	if v.moveState == MOVE_STATE_UP then
		entity_addVel(me, v.velx*dt, -600*dt)
		entity_rotateToVel(me, 1)
		--entity_exertHairForce(me, v.waveTimer*5*v.waveDir, 0, dt)	
		--entity_exertHairForce(me, 0, 10, dt)
		--entity_exertHairForce(me, v.waveTimer*50*v.waveDir, v.waveTimer*50, dt)	
	elseif v.moveState == MOVE_STATE_DOWN then
		entity_addVel(me, 0, 50*dt)
		entity_rotateTo(me, 0, 3)
		--entity_exertHairForce(me, v.waveTimer*50*v.waveDir, 400, dt)
		entity_exertHairForce(me, 0, 200, dt*0.6, -1)
		--entity_exertHairForce(me, v.waveTimer*25*v.waveDir, 0, dt)
		--entity_exertHairForce(me, v.waveTimer*50*v.waveDir, 0, dt)
	end
	

	
	
	entity_doEntityAvoidance(me, dt, 32, 1.0)
	entity_doCollisionAvoidance(me, 1.0, 8, 1.0)
	
	if not entity_isState(me, STATE_SHOCK) then
		entity_updateMovement(me, dt)
	end
	
	entity_setHairHeadPosition(me, entity_x(me), entity_y(me))
	entity_updateHair(me, dt)

	v.shockDelay = v.shockDelay - dt
	if v.shockDelay < 0 then
		v.shockDelay = 10 + math.random(5)
		entity_setState(me, STATE_SHOCK, 0.5)
	end
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setMaxSpeed(me, 50)
		--entity_animate(me, "idle", LOOP_INF)
	elseif entity_isState(me, STATE_SHOCK) then
		entity_sound(me, "EnergyOrbCharge")
		spawnParticleEffect("JellyShock", entity_x(me), entity_y(me))		
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function exitState(me)
	if entity_isState(me, STATE_SHOCK) then
		entity_touchAvatarDamage(me, 170, 1, 800)
		entity_setState(me, STATE_IDLE)
	end
end

function dieNormal(me)
	if chance(10) then
		spawnIngredient("SpicyMeat", entity_x(me), entity_y(me))
	end
end
