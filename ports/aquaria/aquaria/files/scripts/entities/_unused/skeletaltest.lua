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

-- skeletal test


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================


v.swimTime = 0.75
v.swimTimer = v.swimTime - v.swimTime/4
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init()
	setupBasicEntity(
	"",								-- texture
	6,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	28,								-- collideRadius
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)

	--entity_scale(0.5, 0.5)
	entity_initSkeletal("mer", "drask")
	entity_animate("swim", -1)
end

function update(dt)
	if not entity_hasTarget() then
		entity_findTarget(1000)
	else
		if entity_hasTarget() then
			if entity_isTargetInRange(64) then
				entity_hurtTarget(1);
--				entity_moveTowardsTarget(dt, -1000)
			end
		end
		
		--[[
		v.swimTimer = v.swimTimer + dt
		if v.swimTimer > v.swimTime then			
			entity_moveTowardsTarget(1, 400)
			entity_doCollisionAvoidance(1, 6, 0.5);
			entity_doEntityAvoidance(1, 256, 0.2);
			entity_rotateToVel(0.2)
			v.swimTimer = v.swimTimer - v.swimTime
		else
			entity_moveTowardsTarget(dt, 100)
			entity_doEntityAvoidance(dt, 64, 0.1);
			entity_doCollisionAvoidance(dt, 6, 0.5);
		end	
		]]--
		entity_moveTowardsTarget(dt, 1000)
		entity_rotateToVel(0.1)
		entity_doCollisionAvoidance(dt, 6, 0.5)
	end
	
	--entity_doFriction(dt, 700)	
	entity_updateMovement(dt)
end

function enterState()
	if entity_getState()==STATE_IDLE then
		entity_setMaxSpeed(200)
	end
end

function exitState()
end

function hitSurface()
end
