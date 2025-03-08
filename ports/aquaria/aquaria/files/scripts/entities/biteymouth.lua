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
-- B I T E Y   M O U T H
-- ================================================================================================

-- ================================================================================================
-- S T A T E S 
-- ================================================================================================

local STATE_BITE = 1001

-- ================================================================================================
-- L O C A L   V A R I A B L E S
-- ================================================================================================
 
v.biteDelay = 0
 
-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"BiteyMouth/Teeth",				-- texture
	69,								-- health
	0,								-- manaballamount
	69,								-- exp
	69,								-- money
	64,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000							-- updateCull -1: disabled, default: 4000
	)
	
	loadSound("BiteyMouthBite")
	
	entity_setAllDamageTargets(me, false)
	
	entity_initSkeletal(me, "BiteyMouth")
	
	entity_scale(me, 0.9, 0.9)
	entity_color(me, 0.54, 0.54, 0.54)
	
	entity_setState(me, STATE_IDLE)
end

function update(me, dt)

	-- BITE WHEN NAIJA IS NEAR
	if entity_getState(me) == STATE_IDLE then
		if v.biteDelay > 0 then v.biteDelay = v.biteDelay - dt
		elseif v.biteDelay <= 0 then
			v.biteDelay = 0
			
			entity_findTarget(me, 321)
			
			if entity_hasTarget(me) then
				entity_setState(me, STATE_OPEN)
			end
		end
	end
end

function enterState(me)
	-- HIDE IN THE BG...
	if entity_getState(me) == STATE_IDLE then
		entity_animate(me, "idle", LOOP_INF)
		entity_scale(me, 0.9, 0.9, 0.54, 0, 0, 1)
		entity_color(me, 0.54, 0.54, 0.54, 0.54, 0, 0, 1)
	
	-- ...OPEN UP...
	elseif entity_getState(me) == STATE_OPEN then
		local appearSpeed = entity_animate(me, "open")
		entity_setStateTime(me, appearSpeed)
		entity_scale(me, 1.4, 1.4, appearSpeed) --scale to normal size
		entity_color(me, 1, 1, 1, appearSpeed)	--set to normal colour
	
	-- ...BITE!
	elseif entity_getState(me) == STATE_BITE then
		entity_setStateTime(me, entity_animate(me, "bite")) 
	end
end

function damage(me, attacker, bone, damageType, dmg, x, y)
	return false
end

function exitState(me)
	if entity_getState(me) == STATE_OPEN then
		entity_setState(me, STATE_BITE)
		
	elseif entity_getState(me) == STATE_BITE then
		entity_setState(me, STATE_IDLE)
		v.biteDelay = 2.1 + (math.random(210) * 0.01)
		entity_offset(me, 0, 0)
	end
end

function animationKey(me, key)
	if entity_getState(me) == STATE_BITE and key == 1 then
		entity_sound(me, "BiteyMouthBite")
		--entity_sound(me, "Bite", 543 + math.random(123))
		shakeCamera(3.2, 0.54)
		entity_touchAvatarDamage(me, 98, 2.1, 360)
	end
	
	-- BITE SHAKE
	--[[if entity_getState(me) == STATE_BITE and key >= 1 then
		range = 120
		entity_offset(me, (math.random(range)-range/2) * 0.1, (math.random(range)-range/2) * 0.1)
	end]]--
end
