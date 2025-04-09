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
-- SPIKEBALL
-- ================================================================================================

-- entity specific
local STATE_FIRE			= 1000
local STATE_PULLBACK		= 1001
v.fireDelay = 0

v.dir = 0
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"SpikeBall",					-- texture
	10,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	70,								-- collideRadius 
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
		

	--entity_scale(me, 0.9, 0.9)
end

function update(me, dt)
	entity_heal(me, 1)
--[[
	if entity_hasTarget(me) then
		if entity_isTargetInRange(me, 96) then
			entity_moveTowardsTarget(me, dt, -1000)
		end
	end
	]]--
	
	entity_touchAvatarDamage(me, 64, 1, 0.1)
	
	local amount = 1000
	if v.dir == 0 then
		entity_addVel(me, -amount, 0)
	elseif v.dir == 1 then
		entity_addVel(me, 0, amount)
	elseif v.dir == 2 then
		entity_addVel(me, amount, 0)
	elseif v.dir == 3 then
		entity_addVel(me, 0, -amount)
	end
	entity_updateMovement(me, dt)
	
	
	--[[
	if entity_getTarget(me) ~= 0 then
		entity_flipToEntity(me, entity_getTarget(me))
	end
	if v.fireDelay > 0 then
		v.fireDelay = v.fireDelay - dt
		if v.fireDelay < 0 then
			v.fireDelay = 0
		end
	end
	
	if entity_getState(me)==STATE_IDLE then
		if not entity_hasTarget(me) then
			entity_findTarget(me, 1000)
			entity_clearVel(me)
		else
			if entity_isTargetInRange(me, 4000) then				
				entity_moveTowardsTarget(me, dt, 500)		-- move in if we're too far away
				if entity_isTargetInRange(me, 350) and v.fireDelay==0 then
					entity_setState(me, STATE_FIRE, 0.5)
				end
			else
				entity_clearVel(me)
			end
						
		end
	end
	if entity_getState(me)==STATE_FIRE then
		entity_moveTowardsTarget(me, dt, -600)
	end
	]]--
	--[[
	if entity_getState(me)==STATE_PULLBACK then
		if not entity_hasTarget(me) then
			entity_setState(me, STATE_IDLE)
		else
			if entity_isTargetInRange(me, 400) then
				entity_moveTowardsTarget(me, dt, -5000)
			else
				entity_setState(me, STATE_IDLE)
			end
		end
	end
	]]--
	--[[

	entity_doEntityAvoidance(me, dt, 128, 0.2);
--	entity_doSpellAvoidance(dt, 200, 1.5);
	entity_doCollisionAvoidance(me, dt, 6, 0.5);
	--entity_rotateToVel(me, 0.1)
	
	]]--
end

function enterState(me)
end

function exitState(me)
end

function hitSurface(me)
	--entity_flipHorizontal(me)
	v.dir = v.dir + 1
	if v.dir > 3 then
		v.dir = 0
	end
end

function activate(me)
end
