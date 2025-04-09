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

v.moveTimer = 0
v.rotateOffset = 0
v.mouthOpen = 0
v.fireDelay = 2

local STATE_FIREPREP = 1003
local STATE_FIRE = 1004

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================


--[[
function land(me)
	entity_clampToSurface(me)	
	entity_rotateToSurfaceNormal(me, 0.1)
end
]]--

function init(me)
	v.jumpDelay = 0+math.random(3)

	setupBasicEntity(
	me,
	"",								-- texture
	8,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	50,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	3000,							-- updateCull -1: disabled, default: 4000
	1
	)
	entity_initSkeletal(me, "Toad")
	
	entity_setDeathParticleEffect(me, "TinyBlueExplode")


	--land(me)
	entity_clampToSurface(me)
	entity_setState(me, STATE_IDLE)
	
	v.mouthOpen = entity_getBoneByName(me, "Head-MouthOpen")
	bone_alpha(v.mouthOpen, 0)
	
	entity_setInternalOffset(me, 0, -20)
	
	entity_setEatType(me, EAT_FILE, "BouncyBall")
	
	entity_setDropChance(me, 0, 1)
	esetv(me, EV_WALLOUT, 16)
	--entity_setBounce(0)
end

function update(me, dt)
	if entity_getState(me)==STATE_IDLE then	
		--entity_moveAlongSurface(me, dt, 0.5, 6, 16)
		--entity_switchSurfaceDirection(me)
		entity_rotateToSurfaceNormal(me, 0.1)
		if not(entity_hasTarget(me)) then
			entity_findTarget(me, 1200)
		else
			v.fireDelay = v.fireDelay - dt
			if v.fireDelay < 0 then
				v.fireDelay = math.random(2)+0.75
				entity_setState(me, STATE_FIREPREP)
			end
			if entity_isTargetInRange(me, 600) then
				v.jumpDelay = v.jumpDelay - dt
				if entity_getHealth(me) < 3 then
					v.jumpDelay = v.jumpDelay - dt*2
				end
				if v.jumpDelay < 0 then
					v.jumpDelay = 3+math.random(2)
					entity_setState(me, STATE_JUMPPREP)
				end
			end
		end		
	elseif entity_getState(me)==STATE_JUMPPREP then
		if not entity_isAnimating(me) then
			entity_setState(me, STATE_JUMP)
		end
	elseif entity_getState(me)==STATE_JUMP then
		entity_updateCurrents(me, dt)
		entity_updateMovement(me, dt*1.5)		
	elseif not(entity_getState(me)==STATE_TRANSITION) then
		--entity_updateMovement(me, dt)
	end
	entity_handleShotCollisions(me)
	if entity_hasTarget(me) then
		entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 500)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_isState(me, STATE_IDLE) and chance(20) then
		entity_setState(me, STATE_JUMPPREP)
	end
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -999) -- -4
	end
	return true
end

--[[
function hitSurface(me)
	if entity_getState(me)==STATE_JUMP then
		entity_clampToSurface(me, 0.1) -- (0.1)
		entity_moveAlongSurface(me, 0, 1, 6, 24)
		entity_setState(me, STATE_IDLE)
	end
end
]]--

v.bounces = 0
function hitSurface(me)
	local cx, cy = getLastCollidePosition()
	spawnParticleEffect("HitSurface", cx, cy)
	if entity_getState(me)==STATE_JUMP then		
		--local nx, ny = getWallNormal(cx, cy)
		--if ny < 0 then
		if entity_checkSurface(me, 6, STATE_IDLE, -1) then
		end
		--[[
		if entity_isNearObstruction(me, 4, OBSCHECK_DOWN) then
			land(me)
			entity_setState(me, STATE_IDLE)
		else
			v.bounces = v.bounces + 1
			if v.bounces > 8 then
				land(me)
				entity_setState(me, STATE_IDLE)
			end
		end
		]]--
	end
end

v.weight = 600
function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_setWeight(me, 0)
		entity_animate(me, "idle", LOOP_INF)
		entity_setMaxSpeed(me, v.weight)
		entity_clearVel(me)
		--entity_adjustPositionBySurfaceNormal(me, 16)
	elseif entity_isState(me, STATE_TRANSITION) then
		entity_rotateToSurfaceNormal(me, 0.1)
		entity_setWeight(me, 0)
		entity_clearVel(me)
	elseif entity_getState(me)==STATE_JUMPPREP then
		entity_animate(me, "jumpPrep")
	elseif entity_getState(me)==STATE_JUMP then
		v.bounces = 0
		entity_setWeight(me, v.weight)
		entity_animate(me, "jump")
		v.rotateOffset = 0
		--entity_applySurfaceNormalForce(me, 800)
		local force = 1200
		if entity_x(getNaija()) < entity_x(me) then
			entity_addVel(me, -force, -force*0.75)
		else
			entity_addVel(me, force, -force*0.75)
		end
		entity_adjustPositionBySurfaceNormal(me, 64)
		entity_rotate(me, 0, 1)
	elseif entity_isState(me, STATE_FIREPREP) then
		entity_animate(me, "idle", LOOP_INF)
		bone_alpha(v.mouthOpen, 1, 0.1)
		entity_setStateTime(me, 0.5)
	elseif entity_isState(me, STATE_FIRE) then
		local spd = 700
		--local homing = 100
		--local s = entity_fireAtTarget(me, "", 1, spd, 0, 0, 32)
		local s = createShot("BouncyBall", me, entity_getTarget(me))
		local vx = 0
		local vy = 0
		if chance(50) then
			vx, vy = entity_getAimVector(me, -20, 1)
		else
			vx, vy = entity_getAimVector(me, 20, 1)
		end
		shot_setAimVector(s, vx, vy)
		shot_setOut(s, 96)
		--[[
		shot_setNice(s, "Shots/BouncyBall", "BouncyBallTrail", "BouncyBallHit")
		shot_setBounceType(s, BOUNCE_REAL)
		shot_setVel(s, vx, vy)
		]]--

		entity_setStateTime(me, 0.5)
		bone_alpha(v.mouthOpen, 0, 0.1)
	end
end

function exitState(me)
	if entity_getState(me)==STATE_TRANSITION then
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_FIREPREP) then
		entity_setState(me, STATE_FIRE)		
	elseif entity_isState(me, STATE_FIRE) then
		bone_alpha(v.mouthOpen, 0, 0.2)
		entity_setState(me, STATE_IDLE)
	end
end
