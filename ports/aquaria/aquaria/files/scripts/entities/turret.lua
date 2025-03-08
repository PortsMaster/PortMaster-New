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
-- T U R R E T
-- ================================================================================================

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.fireDelay = 0
v.moveTimer = 0

local STATE_MOVING = 1000
local STATE_FIRING = 1001
v.rounds = 0
v.orb = 0

v.fireRate = 0.75

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

local LAYER_ORB = 1

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	6,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	32,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	entity_initSkeletal(me, "Turret")
	entity_setDropChance(me, 75)
	entity_clampToSurface(me)
	entity_moveAlongSurface(me, 0, 1, 6, 40)
	entity_rotateToSurfaceNormal(me, 0.1)
	
	v.orb = entity_getBoneByName(me, "Orb")
	
	entity_setDeathParticleEffect(me, "Explode")
	--[[
	
	bone_setColor(v.orb, 0, 0, 1)
	]]--

	entity_setState(me, STATE_IDLE)
	esetv(me, EV_WALLOUT, 40)
end

function update(me, dt)
	-- dt, pixelsPerSecond, climbHeight, outfromwall

	entity_findTarget(me, 5000)
	
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, 48, 1, 1000)
	-- entity_rotateToSurfaceNormal(0.1)
	if entity_isState(me, STATE_MOVING) then
		entity_moveAlongSurface(me, dt, 100, 6, 40)
		entity_rotateToSurfaceNormal(me, 0.1)
		v.moveTimer = v.moveTimer + dt
		if v.moveTimer > 3 then
			entity_setState(me, STATE_IDLE)
		end
	else
		entity_moveAlongSurface(me, 0, 1, 6, 40)
		entity_rotateToSurfaceNormal(me, 0.1)
	end
	if entity_isState(me, STATE_IDLE) then
		if entity_hasTarget(me) then
			if v.rounds < 3 then
				entity_setState(me, STATE_FIRING)
				v.rounds = v.rounds + 1
			else
				v.rounds = 0
				entity_setState(me, STATE_MOVING)
			end
		end
	end
	if entity_isState(me, STATE_FIRING) then
		if entity_hasTarget(me) then
			v.fireDelay = v.fireDelay - dt
			if v.fireDelay < 0 then
				-- dmg, mxspd, homing, numsegs, out
				
				local vx, vy = bone_getNormal(v.orb)
				--bone_getOrientation()
				--entity_playSfx(me, "BasicShot")
				--entity_fireAtTarget(me, "Turret", 1, 100, 0, 3, 32, 0, -48, vx, vy)
				local s = createShot("Turret", me, entity_getTarget(me), bone_getWorldPosition(v.orb))
				shot_setAimVector(s, vx, vy)
				shot_setOut(s, 32)
				v.fireDelay = v.fireRate
			end
		end
		if not entity_isAnimating(me) then
			entity_setState(me, STATE_IDLE)
		end
	end
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_animate(me, "idle", LOOP_INF)
	elseif entity_getState(me) == STATE_MOVING then
		v.moveTimer = 0
		entity_switchSurfaceDirection(me)
		entity_animate(me, "walk", LOOP_INF)
	elseif entity_getState(me) == STATE_FIRING then
		entity_animate(me, "fire")
	end
end

function animationKey(me, key)
	if entity_isState(me, STATE_MOVING) then
		if key == 2 or key == 3 then
			entity_playSfx(me, "RockStep")
		end
	end
end

function exitState(me)
end

function hitSurface(me)
end

function dieNormal(me)
	if chance(50) then
		spawnIngredient("FishMeat", entity_x(me), entity_y(me))
	end
end
