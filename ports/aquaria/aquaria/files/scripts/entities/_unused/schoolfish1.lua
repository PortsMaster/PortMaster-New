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
-- SCHOOL FISH 1 - Ze Grande Experimente!
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.lungeDelay = 0				-- prevents the nautilus from lunging over and over

 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

-- initializes the entity
function init(me)
	setupBasicEntity(
	me,
	"Fish-0001",						-- texture
	4,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	64,								-- sprite width
	64,								-- sprite height
	1,						-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1							-- updateCull -1: disabled, default: 4000
	)

	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	
	entity_setDropChance(me, 50)
		
	entity_addVel(me, math.random(500)-250, math.random(500)-250)
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
end

-- the entity's main update function
function update(me, dt)
	entity_handleShotCollisions(me)
	
	--entity_moveTowardsGroupHeading(me, dt, 500)
	entity_moveTowardsGroupCenter(me, dt, 400)
	entity_moveTowardsGroupHeading(me, dt, 50)
	entity_doEntityAvoidance(me, dt, 64, 0.5)
	entity_doCollisionAvoidance(me, dt, 10, 0.5)
	
	entity_avgVel(me, 4)
	entity_setVelLen(me, 200)
	
	if (chance(1)) then
		v = math.random(4)
		if v == 0 then
			entity_applyGroupVel(me, -200, 200)
		elseif v == 1 then
			entity_applyGroupVel(me, 200, 200)
		elseif v == 2 then
			entity_applyGroupVel(me, 200, -200)
		elseif v == 3 then
			entity_applyGroupVel(me, -200, -200)
		end
	end

	
	--[[
	entity_doCollisionAvoidance(me, dt, 8, 1.0)
	
	entity_doSpellAvoidance(me, dt, 200, 0.8)
	]]--
		
	--entity_avgVel(me, 4)
	
	entity_updateMovement(me, dt)
	
	--[[
	if entity_velx(me) > 0 and not entity_isFlippedHorizontal(me) then
		entity_flipHorizontal(me)
	elseif entity_velx(me) < 0 and entity_isFlippedHorizontal(me) then
		entity_flipHorizontal(me)
	end
	]]--
	
	--entity_rotateToVel(me, 0.5, 90)
end

function enterState(me)

	if entity_getState(me)==STATE_IDLE then
		entity_setMaxSpeed(me, 200)
	end
end

function exitState(me)
end

function hitSurface(me)
end
