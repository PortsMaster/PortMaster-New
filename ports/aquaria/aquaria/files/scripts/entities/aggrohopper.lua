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
-- AGGRO HOPPER
-- ================================================================================================

-- specific
local STATE_JUMP			= 1000
local STATE_TRANSITION		= 1001
local STATE_JUMPPREP		= 1002

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.jumpDelay = 0
v.moveTimer = 0
v.rotateOffset = 0
v.angry = false
v.enraged = false

v.out = 32

v.n = 0

v.bdelay = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

local function land(me, dt)
	entity_clampToSurface(me)
	entity_moveAlongSurface(me, dt, 1, 6, v.out)
	entity_rotateToSurfaceNormal(me, 0.1)
end

function init(me)

	setupBasicEntity(
	me,
	"",								-- texture
	12,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	40,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	entity_initSkeletal(me, "AggroHopper")
	
	esetv(me, EV_WALLOUT, v.out)
	
	entity_setDeathParticleEffect(me, "Explode")
	
	entity_scale(me, 0.5, 0.5)
	land(me, 0)
	entity_setWeight(me, 1000)
	entity_setState(me, STATE_IDLE)
	--entity_setBounce(0)
	
	loadSound("aggrohopper-jump")
end

function postInit(me)
	v.n = getNaija()
end

function update(me, dt)
	dt = dt * 0.9
	if v.enraged then
		dt = dt * 1.25
	end
	entity_handleShotCollisions(me)
	if entity_hasTarget(me) then
		if entity_isTargetInRange(me, 64) then
			entity_hurtTarget(me, 1)
			entity_pushTarget(me, 500)
		end
	end
	if entity_getState(me)==STATE_IDLE then
	--[[
		entity_moveAlongSurface(me, dt, 100, 6, 24)
		entity_rotateToSurfaceNormal(me, 0.1)
		v.moveTimer = v.moveTimer + dt
		if v.moveTimer > 30 then
			entity_switchSurfaceDirection(me)
			v.moveTimer = 0
		end
		]]--
		--entity_moveAlongSurface(me, dt, 0.5, 6, v.out)
		--entity_switchSurfaceDirection(me)
		entity_rotateToSurfaceNormal(me, 0.1)
		if not(entity_hasTarget(me)) then
			entity_findTarget(me, 1200)
		else
			if not v.angry then
				if entity_isTargetInRange(me, 400) then
					v.jumpDelay = v.jumpDelay - dt
					if v.jumpDelay < 0 then
						v.angry = true
						v.jumpDelay = 1.5
						entity_setState(me, STATE_JUMPPREP)
					end
				end
			else
				if entity_isTargetInRange(me, 1800) then
					v.jumpDelay = v.jumpDelay - dt
					if v.jumpDelay < 0 then
						v.angry = true
						v.jumpDelay = 1.5
						entity_setState(me, STATE_JUMPPREP)
					end
				end
			end
		end
	elseif entity_getState(me)==STATE_JUMPPREP then
		if not entity_isAnimating(me) then
			entity_setState(me, STATE_JUMP)
		end
	elseif entity_getState(me)==STATE_JUMP then
		v.bdelay = v.bdelay + dt
		if v.bdelay > 0.1 then
			v.bdelay = 0
			spawnParticleEffect("bubble-release-short", entity_x(me), entity_y(me))
		end
		
	--[[
		v.rotateOffset = v.rotateOffset + dt * 400
		if v.rotateOffset > 180 then
			rotateOffset = 180
		end
		entity_rotateToVel(me, 0.1, v.rotateOffset)
		
		]]--
		entity_updateMovement(me, dt*1.5)
--		entity_applySurfaceNormalForce(1000)
		
	elseif not(entity_getState(me)==STATE_TRANSITION) then
		entity_updateMovement(me, dt)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_getHealth(me) < 6 and not v.enraged then
		debugLog("ENRAGED!!!!!!!!!")
		v.enraged = true
		entity_setColor(me, 1, 0.5, 0.5, 1)
	end
	if entity_isState(me, STATE_IDLE) then
		entity_setState(me, STATE_JUMPPREP)
	end
	return true
end

v.bounces = 0
function hitSurface(me)
	local cx, cy = getLastCollidePosition()
	spawnParticleEffect("HitSurface", cx, cy)
	if entity_getState(me)==STATE_JUMP then
		--local nx, ny = getWallNormal(cx, cy)
		--if ny < -0.8 and entity_isNearObstruction(me, 3, OBSCHECK_4DIR) then
		if entity_checkSurface(me, 6, STATE_IDLE, -1) then
			entity_sound(me, "rockhit")
		end
		--[[
		if entity_isNearObstruction(me, 4, OBSCHECK_DOWN) then
			land(me, 0)
			entity_setState(me, STATE_TRANSITION)
		else
			v.bounces = v.bounces + 1
			if v.bounces > 100 then
				land(me, 0)
				entity_setState(me, STATE_TRANSITION)
			end
		end
		]]--
	end
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_animate(me, "idle", LOOP_INF)
		entity_setMaxSpeed(me, 1000)
		if v.enraged then
			entity_setMaxSpeed(me, 1200)
		end
	elseif entity_getState(me)==STATE_JUMPPREP then
		entity_animate(me, "jump")
	elseif entity_isState(me, STATE_TRANSITION) then
		
		entity_setStateTime(me, 0.1)
	elseif entity_getState(me)==STATE_JUMP then
		entity_sound(me, "aggrohopper-jump")
		entity_rotate(me, 0, 0.5)
		entity_animate(me, "jumping")
		v.rotateOffset = 0
		--entity_applySurfaceNormalForce(me, 800)
		local force = 2000
		--[[
		if entity_x(getNaija()) < entity_x(me) then
			entity_addVel(me, -force, -force*0.75)
		else
			entity_addVel(me, force, -force*0.75)
		end
		]]--
		local x,y = entity_getNormal(me)
		x,y = vector_setLength(x, y, force)
		local dx = entity_x(v.n) - entity_x(me)
		local dy = entity_y(v.n) - entity_y(me)
		dx,dy = vector_setLength(dx, dy, force)
		x = dx*0.5 + x*0.5
		y = dy*0.5 + y*0.5
		entity_addVel(me, x, y)
		entity_adjustPositionBySurfaceNormal(me, 64)
	end
end

function exitState(me)
	if entity_getState(me)==STATE_TRANSITION then
		entity_setState(me, STATE_IDLE)
	end
end
