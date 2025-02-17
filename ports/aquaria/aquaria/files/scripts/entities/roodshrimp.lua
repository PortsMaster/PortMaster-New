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
-- Rood Shrimp
-- ================================================================================================

-- specific
local STATE_JUMP			= 1000
local STATE_TRANSITION		= 1001
local STATE_RETURNTOWALL	= 1002

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.vx = 0
v.vy = 0
v.jumpDelay = 1
v.moveTimer = 0
v.rotateOffset = 0
v.flyTimer = 0
v.moveTowardsTimer = 0
v.y_range = 200
v.fudge = 40
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

v.cr = 12

function init(me)
	setupBasicEntity(
	me,
	"RoodShrimp",					-- texture
	6,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	v.cr,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	64,							-- sprite width	
	64,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	--entity_initSkeletal(me, "RoodShrimp")

	entity_setMaxSpeed(me, 500)
	entity_clampToSurface(me)
	entity_setState(me, STATE_IDLE)
	--entity_setDropChance(me, 75)
	
	entity_setDeathParticleEffect(me, "TinyBlueExplode")
	--entity_setBounce(0)
	
	entity_setTarget(me, getNaija())
end

function update(me, dt)
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, v.cr, 0, 1000)

	
	if entity_getState(me)==STATE_IDLE then
		entity_rotateToSurfaceNormal(me, 0.1, 0, -90)
		entity_moveAlongSurface(me, dt, 0, 6, 24)
		if v.jumpDelay > 0 then
			v.jumpDelay = v.jumpDelay - dt
			if v.jumpDelay < 0 then
				v.jumpDelay = 0
			end
		end
		if entity_isTargetInRange(me, 500) then

			
		--[[
			entity_moveAlongSurface(me, dt, 100, 6, 24)
			entity_rotateToSurfaceNormal(me, 0.1)
			v.moveTimer = v.moveTimer + dt
			if v.moveTimer > 30 then
				entity_switchSurfaceDirection(me)
				v.moveTimer = 0
			end
			]]--
			if v.jumpDelay == 0 then
				v.jumpDelay = 1
				entity_setState(me, STATE_JUMP)
			end
		end
	elseif entity_getState(me)==STATE_JUMP then
		if v.flyTimer > 0 then
			v.flyTimer = v.flyTimer - dt
			if v.flyTimer < 0 then
				v.flyTimer = 0
				entity_setState(me, STATE_RETURNTOWALL)
			end
		end

		entity_doEntityAvoidance(me, dt, 128, 0.5)
		entity_moveTowardsTarget(me, dt, 200)
		entity_rotateToVel(me, 0.1)
		entity_updateMovement(me, dt)
	elseif entity_getState(me)==STATE_RETURNTOWALL then
		--debugLog("moving back....")
		if v.vx > v.vy then
			entity_addVel(me, (0-v.vx)*dt*0.9, v.vy*dt*0.1)
		else
			entity_addVel(me, (v.vx)*dt*0.1, (0-v.vy)*dt*0.9)
		end
		
		entity_doEntityAvoidance(me, dt, 128, 0.5)
		entity_updateMovement(me, dt)
		entity_rotateToVel(me, 0.1)
	elseif not(entity_getState(me)==STATE_TRANSITION) then
		entity_updateMovement(me, dt)
	end
end

function hitSurface(me)
	if entity_isState(me, STATE_RETURNTOWALL) then
		entity_clampToSurface(me, 0.1)
		entity_setState(me, STATE_TRANSITION, 0.1)
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then		
		--entity_animate(me, "idle", LOOP_INF)
	elseif entity_isState(me, STATE_JUMP) then
		local t = entity_getTarget(me)
		if t ~= 0 then
			entity_moveTowardsTarget(me, 1, 2000)
			local amp = 1.5
			--entity_addVel(me, entity_velx(entity_getTarget(me))*amp, entity_vely(entity_getTarget(me))*amp)
		end
		v.moveTowardsTimer = 0
		v.rotateOffset = 0
		v.flyTimer = 2
		entity_applySurfaceNormalForce(me, 800)
		--entity_adjustPositionBySurfaceNormal(me, 64)
		entity_adjustPositionBySurfaceNormal(me, v.fudge)
		
		v.vx = entity_velx(me)
		v.vy = entity_vely(me)

		--entity_animate(me, "swim", LOOP_INF)
	elseif entity_isState(me, STATE_RETURNTOWALL) then
		--entity_fireAtTarget(me, "BlasterFire", 1, 400, 200, 3)
		local s = createShot("RoodShrimp", me, entity_getTarget(me))
		shot_setOut(s, 32)
		--entity_fireShot(me, getNaija())
		debugLog("returning to wall")
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function exitState(me)
	if entity_isState(me, STATE_TRANSITION) then
		entity_setState(me, STATE_IDLE)
	end
end
