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
-- M O N E Y E
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================


v.orient = ORIENT_LEFT
v.orientTimer = 0

v.swimTime = 0.75
v.swimTimer = v.swimTime - v.swimTime/4
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(me, 
	"",						-- texture
	4,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	28,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000							-- updateCull -1: disabled, default: 4000
	)
		
	-- entity_initPart(partName, partTexture, partPosition, partFlipH, partFlipV,
	-- partOffsetInterpolateTo, partOffsetInterpolateTime
	entity_initSkeletal(me, "Splitter2")	
	entity_animate(me, "idle", -1)
	
	entity_scale(me, 0.8, 0.8)
	
	v.flipper = entity_getBoneByName(me, "Flipper1")
	
	bone_setSegs(v.flipper, 16, 2, 0.2, 0.4, 0, -0.05, 8, 0)
	
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	
	--entity_setMaxSpeed(me, 1000)
end

function update(me, dt)
	dt = dt * 1.5
	local amt = 400
	
	entity_touchAvatarDamage(me, 16, 1, 1200)
	
	entity_handleShotCollisions(me)
	if not entity_hasTarget(me) then
		entity_findTarget(me, 500)
		v.swimTimer = v.swimTimer + dt
		if v.swimTimer > v.swimTime then	
			v.swimTimer = v.swimTimer - v.swimTime
			if v.orient == ORIENT_LEFT then
				entity_addVel(me, -amt, 0)
				v.orient = ORIENT_UP
			elseif v.orient == ORIENT_UP then
				entity_addVel(me, 0, -amt)
				v.orient = ORIENT_RIGHT
			elseif v.orient == ORIENT_RIGHT then
				entity_addVel(me, amt, 0)
				v.orient = ORIENT_DOWN
			elseif v.orient == ORIENT_DOWN then
				entity_addVel(me, 0, amt)
				v.orient = ORIENT_LEFT
			end			
			--entity_rotateToVel(me, 0.2)
			v.orientTimer = v.orientTimer + dt
			entity_doEntityAvoidance(me, 1, 256, 0.2)
		end
		entity_doCollisionAvoidance(me, dt, 6, 0.5)
	else
		
		v.swimTimer = v.swimTimer + dt
		if v.swimTimer > v.swimTime then			
			entity_moveTowardsTarget(me, 1, amt)
			if not entity_isNearObstruction(getNaija(), 8) then
				entity_doCollisionAvoidance(me, 1, 6, 0.5)
			end
			entity_doEntityAvoidance(me, 1, 256, 0.2)
			--entity_rotateToVel(me, 0.2)
			v.swimTimer = v.swimTimer - v.swimTime
		else
			entity_moveTowardsTarget(me, dt, 100)
			entity_doEntityAvoidance(me, dt, 64, 0.1)
			--if not entity_isNearObstruction(getNaija(), 8) then
			entity_doCollisionAvoidance(me, dt, 6, 0.5)
			--end
		end
		entity_findTarget(me, 800)
	end
	entity_doFriction(me, dt, 500)	
	entity_updateMovement(me, dt)
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_setMaxSpeed(me, 400)
	end
end

function exitState(me)
end

function hitSurface(me)
	v.orient = v.orient + 1
end
