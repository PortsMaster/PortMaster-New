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
local STATE_WALK			= 1003

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.jumpDelay = 0
v.moveTimer = 0
v.rotateOffset = 0
v.angry = false
v.enraged = false
v.moving = 0.2
v.n = 0

v.puffTimer = 0

v.fireDelay = 0

v.lx = 0
v.ly = 0

v.bubbleRelease = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

--[[
function land(me)
	entity_clampToSurface(me)
	entity_moveAlongSurface(me, dt, 1, 6, 24)
	entity_rotateToSurfaceNormal(me, 0.1)
end
]]--

function init(me)

	setupBasicEntity(
	me,
	"",								-- texture
	24,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	40,								-- collideRadius
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	entity_initSkeletal(me, "mermoth")
	
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	
	--land(me)
	entity_setWeight(me, 1000)
	entity_setState(me, STATE_IDLE)
	
	entity_setBounceType(me, BOUNCE_REAL)
	entity_setBounce(me, 0.9)
	--entity_setClampOnSwitchDir(me, false)
	esetv(me, EV_SWITCHCLAMP, 0)
	esetv(me, EV_WALLOUT, 64)--18)
	
	entity_clampToSurface(me)
	
	entity_setCullRadius(me, 512)
	--entity_setBounce(0)
	entity_setDeathSound(me, "mermog-die")

	loadSound("mermog-die")
	loadSound("mermog-jump")
end

function postInit(me)
	v.n = getNaija()
end

function update(me, dt)
	v.lx, v.ly = entity_getPosition(me)
	
	dt = dt * 1.2
	
	
	v.puffTimer = v.puffTimer - dt

	if v.puffTimer < 0 then
		spawnParticleEffect("poisonbubbles", entity_x(me) + math.random(100) - math.random(100), entity_y(me) - 40 + math.random(100) - math.random(100))
		v.puffTimer = 1
	end
	
	if v.enraged then
		dt = dt * 1.25
	end	
	--[[
	if entity_hasTarget(me) then
		if entity_isTargetInRange(me, 64) then
			entity_hurtTarget(me, 1)
			entity_pushTarget(me, 500)
		end
	end
	]]--
	if entity_isState(me, STATE_IDLE) or entity_isState(me, STATE_TRANSITION) then
		entity_moveAlongSurface(me, dt, 0.5, 6)
		--entity_switchSurfaceDirection(me)
	end
	if entity_getState(me)==STATE_IDLE then
		if not(entity_hasTarget(me)) then
			entity_findTarget(me, 1200)
		else
			if entity_isTargetInRange(me, 800) then
				v.jumpDelay = v.jumpDelay - dt
				if v.jumpDelay < 0 then
					v.angry = true
					v.jumpDelay = 0.2
					entity_setState(me, STATE_JUMPPREP)
				end
			end
		end		
	elseif entity_isState(me, STATE_WALK) then
		if entity_isfh(me) then
			entity_switchSurfaceDirection(me, 0)
		else
			entity_switchSurfaceDirection(me, 1)
		end
		entity_moveAlongSurface(me, dt, 1000*v.moving, 6)
		entity_rotateToSurfaceNormal(me, 0.1)
	elseif entity_getState(me)==STATE_JUMPPREP then
		if not entity_isAnimating(me) then
			entity_setState(me, STATE_JUMP)
		end
	elseif entity_getState(me)==STATE_JUMP then
		--entity_flipToVel(me)
		entity_updateCurrents(me, dt)
		entity_updateMovement(me, dt)
		
		v.bubbleRelease = v.bubbleRelease - dt
		if v.bubbleRelease < 0 then
			v.bubbleRelease = 0.4
			spawnParticleEffect("bubble-release-short", entity_x(me), entity_y(me))
		end
		
		--[[
		v.fireDelay = v.fireDelay - dt
		if v.fireDelay < 0 then
			v.fireDelay = 0.4
			s = createShot("mermog-shot", me, v.n, entity_x(me), entity_y(me))
			shot_setAimVector(s, math.sin(angle), math.cos(angle))
			if entity_isfh(me) then
				angle = angle + 0.1
			else
				angle = angle - 0.1
			end
		end
		]]--
	elseif not(entity_getState(me)==STATE_TRANSITION or entity_isState(me, STATE_WALK)) then
		entity_updateMovement(me, dt)
	end
	

	--[[
	if isObstructed(entity_x(me), entity_y(me)) then
		entity_setPosition(me, v.lx, v.ly)
		entity_clampToSurface(me)
	end
	]]--
	
	entity_handleShotCollisions(me)
	if entity_touchAvatarDamage(me, 64, 1, 500) then
		setPoison(1, 12)
	end
	
	if isObstructed(entity_x(me), entity_y(me)) then
		entity_adjustPositionBySurfaceNormal(me, 1)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_isState(me, STATE_IDLE) then
		entity_setState(me, STATE_JUMPPREP)
	end
	return true
end

v.bounces = 0
function hitSurface(me)
	if entity_getState(me)==STATE_JUMP then
		local t = egetvf(me, EV_CLAMPTRANSF)
		if entity_checkSurface(me, 6, STATE_TRANSITION, t) then
			entity_rotateToSurfaceNormal(me, 0)
			entity_scale(me, 1, 0.5)
			entity_scale(me, 1, 1, t)
			--[[
			entity_setInternalOffset(me, 0, 64)
			entity_setInternalOffset(me, 0, 0, t)
			]]--
		else
			local nx, ny = getWallNormal(entity_getPosition(me))
			nx, ny = vector_setLength(nx, ny, 400)
			entity_addVel(me, nx, ny)
		end
		--[[
		if entity_isNearObstruction(me, 4, OBSCHECK_4DIR) then
			entity_clampToSurface(me)
			entity_setState(me, STATE_TRANSITION, 0.001)
		end
		]]--
	end
	--[[
	if entity_getState(me)==STATE_JUMP then
		local nx, ny = getWallNormal(cx, cy)
		if ny < 0 then
			land(me)
			entity_setState(me, STATE_TRANSITION)
		else
			v.bounces = v.bounces + 1
			if v.bounces > 8 then
				land(me)
				entity_setState(me, STATE_TRANSITION)
			end
		end
	end
	]]--
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_animate(me, "idle", LOOP_INF)
		entity_setMaxSpeed(me, 1200)
	elseif entity_getState(me)==STATE_JUMPPREP then

		local nx, ny = entity_getNormal(me)
		for i=20,400,20 do
			
			local nx1, ny1 = vector_setLength(nx, ny, i)
			local tx = entity_x(me) + nx1
			local ty = entity_y(me) + ny1
			--debugLog(string.format("t(%d, %d)", tx, ty))
			if isObstructed(tx, ty) then
				--debugLog("idle!")
				entity_setState(me, STATE_WALK, 2, 1)
				return
			end
		end
		
		entity_animate(me, "jumpPrep")
		entity_flipToEntity(me, entity_getTarget(me))
	elseif entity_isState(me, STATE_TRANSITION) then
		entity_setStateTime(me, entity_animate(me, "land"))
	elseif entity_isState(me, STATE_WALK) then
		entity_animate(me, "walk", -1)
	elseif entity_getState(me)==STATE_JUMP then
		v.bounces = 0
		entity_flipToEntity(me, entity_getTarget(me))
		entity_animate(me, "jump")
		
		v.rotateOffset = 0
		entity_applySurfaceNormalForce(me, 1000)
		if entity_isfh(me) then
			entity_addVel(me, 400, 0)
		else
			entity_addVel(me, -400, 0)
		end
		entity_adjustPositionBySurfaceNormal(me, 10)
		
		entity_sound(me, "mermog-jump")
	end
end

function animationKey(me, key)
end

function exitState(me)
	if entity_getState(me)==STATE_TRANSITION then
		entity_setState(me, STATE_IDLE)
		if chance(50) then
			entity_setState(me, STATE_WALK, 2)
		end
	elseif entity_getState(me)==STATE_WALK then
		entity_setState(me, STATE_IDLE)
	end
end

function dieNormal(me)
	if chance(25) then
		local x, y = entity_getNormal(me)
		x, y = vector_setLength(x, y, 64)
		spawnIngredient("PlantLeaf", entity_x(me)+x, entity_y(me)+y)
	end
end
