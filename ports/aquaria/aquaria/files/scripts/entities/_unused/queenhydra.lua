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
-- Q U E E N  H Y D R A
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================
 
 chaseDelay = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init()
	setupBasicEntity(
	"wurm-head",					-- texture
	15,								-- health
	1,								-- manaballamount
	2,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	256,							-- sprite width
	256,							-- sprite height
	0,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	5000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_flipVertical()			-- fix the head orientation
	
	if getFlag("Q1")==1 then
		entity_delete()
	else
		entity_initSegments(
		8,								-- num segments
		2,								-- minDist
		26,								-- maxDist
		"wurm-body",					-- body tex
		"wurm-tail",					-- tail tex
		256,							-- width
		256,							-- height
		0.05,							-- taper
		0								-- reverse segment direction
		)
	end
	

end

function update(dt)	
	if entity_hasTarget() then
		if entity_isTargetInRange(64) then
			entity_hurtTarget(1);
			entity_pushTarget(400);
		end
	end
	if chaseDelay > 0 then
		chaseDelay = chaseDelay - dt
		if chaseDelay < 0 then
			chaseDelay = 0
		end
	end
	if entity_getState()==STATE_IDLE then
		if not entity_hasTarget() then
			entity_findTarget(800)
		else
			if chaseDelay==0 then
				if entity_isTargetInRange(1000) then
					if entity_getHealth() < 4 then
						entity_setMaxSpeed(600)
						entity_moveTowardsTarget(dt, 1500)
					else
						entity_setMaxSpeed(400)
						entity_moveTowardsTarget(dt, 1000)
					end					
				else
					entity_setMaxSpeed(100)
				end
			end
		end
	end
	entity_doEntityAvoidance(dt, 200, 0.1)
	if entity_getHealth() < 4 then
		entity_doSpellAvoidance(dt, 64, 0.5);
	end
	entity_doCollisionAvoidance(dt, 5, 1)
	entity_updateMovement(dt)
	entity_rotateToVel(0.1)
end

function enterState()
	if entity_getState()==STATE_IDLE then
	elseif entity_getState()==STATE_DEAD then
		conversation("Q1-BossDead")
		setFlag("TransitActive", 1)
		setFlag("Q1", 1)
	end
end

function exitState()
end

function hitSurface()
end
