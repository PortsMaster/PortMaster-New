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
-- G R A B B Y   A R M   (beta)
-- ================================================================================================

-- ================================================================================================
-- L O C A L   V A R I A B L E S
-- ================================================================================================
 
v.grabDelay = 0

v.n = 0
v.li = 0
v.grabbedEnt = 0

v.numGrabHits = 6
v.grabHits = v.numGrabHits

v.bone_front = 0
v.bone_back = 0





v.sz = 1.1

-- ================================================================================================
-- S T A T E S
-- ================================================================================================

local STATE_TRAP	= 1001
local STATE_IN	= 1002
local STATE_OUT	= 1003

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"GrabbyArm/Front",				-- texture
	12,								-- health
	0,								-- manaballamount
	69,								-- exp
	69,								-- money
	54,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setCullRadius(me, 1024)
	
	entity_initSkeletal(me, "GrabbyArm")
	v.bone_front = entity_getBoneByName(me, "Front")
	v.bone_back = entity_getBoneByName(me, "Back")
	
	bone_setSegs(v.bone_front, 2, 8, 0.3, 0.3, -0.020, 0, 6, 1)
	bone_setSegs(v.bone_back, 2, 8, 0.34, 0.34, -0.023, 0, 7, 1)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setAllDamageTargets(me, false)
	
	entity_setEntityLayer(me, -2)
	
	entity_scale(me, v.sz, v.sz)
	
	entity_setState(me, STATE_IN, -1, 1)
end

function postInit(me)
	entity_animate(me, "idle", LOOP_INF)

	v.n = getNaija()
	v.li = getLi()
	
	local node = entity_getNearestNode(me, "FLIP")
	if node ~= 0 and node_isEntityIn(node, me) then
		entity_fh(me)
	end
	
	
	
	entity_setInternalOffset(me, 0, 300)
end

function update(me, dt)

	-- GRAB NAIJA AND LI WHEN NEAR
	if entity_getState(me) == STATE_IDLE then
		if v.grabDelay > 0 then v.grabDelay = v.grabDelay - dt
		elseif v.grabDelay <= 0 then
			v.grabDelay = 0
			local grabRange = 74
			if entity_isEntityInRange(me, v.n, grabRange) then
				v.grabbedEnt = v.n
				entity_setState(me, STATE_TRAP)
				
			elseif v.li ~= 0 and entity_isEntityInRange(me, v.li, grabRange) then
				v.grabbedEnt = v.li
				entity_setState(me, STATE_TRAP)
				
			end
		end
	elseif entity_isState(me, STATE_IN) then
		if v.grabDelay > 0 then v.grabDelay = v.grabDelay - dt
		elseif v.grabDelay <= 0 then
			local grabRange = 128
			if entity_isEntityInRange(me, v.n, grabRange) then
				entity_setState(me, STATE_OUT)
			end
		end
	elseif entity_getState(me) == STATE_TRAP then
		if v.grabbedEnt ~= 0 then
			-- HOLD GRABBED ENTITY
			entity_setPosition(v.grabbedEnt, entity_x(me), entity_y(me), 0.06)
			
			-- RELEASE GRABBED ENTITY WHEN HURT ENOUGH
			if v.grabHits <= 0 then
				v.grabHits = 0
				v.grabbedEnt = 0
				entity_setState(me, STATE_IN)
			end
			
			-- FREE UP WHEN GRABBED ENTITY IS DEAD
			if entity_isDead(v.grabbedEnt) then
				v.grabbedEnt = 0
				entity_setState(me, STATE_IN)
			end
		end
		
		-- Move down, pulling held entity towards a hazzard??
	end
	
	-- COLLISIONS
	entity_handleShotCollisions(me)
end

function enterState(me)
	if entity_getState(me) == STATE_IDLE then
		v.grabHits = 0
		entity_animate(me, "idle", LOOP_INF)
		entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
		
	elseif entity_getState(me) == STATE_TRAP then
		v.grabHits = v.numGrabHits
		entity_setDamageTarget(me, DT_AVATAR_LIZAP, true)
		toggleLiCombat(true)
	elseif entity_isState(me, STATE_IN) then
		entity_setInternalOffset(me, 0, 300, 1, 0, 0)
		bone_setRenderPass(v.bone_front, 0)
		entity_setAllDamageTargets(me, false)
	elseif entity_isState(me, STATE_OUT) then
		entity_setAllDamageTargets(me, true)
		local t = 0.3
		entity_setInternalOffset(me, 0, 0, t, 0, 0)
		entity_setStateTime(me, t)
		bone_setRenderPass(v.bone_front, 3)
	end
end

function exitState(me)
	if entity_getState(me) == STATE_IDLE then

	elseif entity_getState(me) == STATE_TRAP then
		v.grabHits = 0
		entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
		v.grabDelay = 3.5
		entity_touchAvatarDamage(me, 64, 0, 321)	-- Bump Naija out when released
	elseif entity_isState(me, STATE_OUT) then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg, x, y)
	-- HURT TO RELEASE HELD ENTITY
	if entity_isState(me, STATE_TRAP) then 
		v.grabHits = v.grabHits - dmg
		bone_damageFlash(v.bone_front)
	end
	
	return false
end

function animationKey(me, key)
end
