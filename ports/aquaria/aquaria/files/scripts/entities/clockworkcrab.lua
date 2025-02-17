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
-- K I N G   C R A B
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.fireDelay = 3
v.moveTimer = 0

local STATE_FIRING = 1001
local STATE_CLAW = 1002

v.leftArm = 0
v.claw = 0

v.cannon = 0
v.n = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(me, 
	"",								-- texture
	12,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	32,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	256,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	2500							-- updateCull -1: disabled, default: 4000
	)
	
	entity_initSkeletal(me, "ClockworkCrab")
	
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	entity_clampToSurface(me)
	
	v.cannon = entity_getBoneByName(me, "Cannon")
	v.leftArm = entity_getBoneByName(me, "LeftArm")
	v.claw = entity_getBoneByName(me, "Claw")
	
	entity_setState(me, STATE_IDLE)	
	v.n = getNaija()
	entity_setCullRadius(me, 1024)
	
	entity_setDamageTarget(me, DT_AVATAR_BITE, false)
end

function postInit(me)
	v.n = getNaija()
end

function animationKey(me, key)
	if entity_isState(me, STATE_FIRING) and key == 1 then
		local x, y = bone_getWorldPosition(v.cannon)
		local nx, ny = getWallNormal(entity_getPosition(me))
		if entity_hasTarget(me) then
			createShot("ClockworkCrab", me, entity_getTarget(me), x, y)			
		end
	end
end

function update(me, dt)
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 1000) then
	end
	
	entity_handleShotCollisions(me)
	
	if entity_isState(me, STATE_IDLE) then
		entity_moveAlongSurface(me, dt, 200, 6, 10)
		entity_rotateToSurfaceNormal(me, 0.1)
		v.moveTimer = v.moveTimer + dt
		if v.moveTimer > 30 then
			entity_switchSurfaceDirection(me)
			v.moveTimer = 0
		end
	elseif entity_isState(me, STATE_CLAW) then
		local x1,y1 = bone_getWorldPosition(v.leftArm)
		local x2,y2 = bone_getWorldPosition(v.claw)
		if entity_collideCircleVsLine(v.n, x1, y1, x2, y2, 8) then
			entity_damage(v.n, me, 1)
		end
	end
	

	if not(entity_hasTarget(me)) then
		entity_findTarget(me, 1200)
	else
		if entity_isState(me, STATE_IDLE) then
			if v.fireDelay > 0 then
				v.fireDelay = v.fireDelay - dt
				if v.fireDelay < 0 then
					-- dmg, mxspd, homing, numsegs, out
					--entity_fireAtTarget(me, "BlasterFire", 1, 400, 200, 3, 64)
					--local s = createShot("ClockworkCrab", me, entity_getTarget(me), bone_getPosition(cannon))					
					v.fireDelay = 4
					if chance(50) then
						entity_setState(me, STATE_FIRING)
					else
						entity_setState(me, STATE_CLAW)
					end
				end
			end
		end
	end
	
	if isObstructed(entity_x(me), entity_y(me)) then
		entity_adjustPositionBySurfaceNormal(me, 1)
	end
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_FIRING) then
		entity_setStateTime(me, entity_animate(me, "firing", 10))
	elseif entity_isState(me, STATE_CLAW) then
		entity_setStateTime(me, entity_animate(me, "claw"))
	elseif entity_isState(me, STATE_DEAD) then
		entity_sound(me, "MetalExplode", math.random(100)+750)
		spawnParticleEffect("ClockworkCrabDie", entity_getPosition(me))
	end
end

function exitState(me)
	if entity_isState(me, STATE_FIRING) or entity_isState(me, STATE_CLAW) then
		entity_setState(me, STATE_IDLE)
	end
end

function hitSurface()
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end
