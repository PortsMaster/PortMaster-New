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
-- N A U T I L U S
-- ================================================================================================

-- entity specific
local STATE_ATTACKPREP		= 1000
local STATE_ATTACK			= 1001


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.lungeDelay = 0					-- prevents the nautilus from lunging over and over

 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

-- initializes the entity
function init(me)
	setupBasicEntity(
	me,
	"RedNautilus",					-- texture
	6,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	40,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1,								-- updateCull -1: disabled, default: 4000
	1
	)

	entity_setDeathParticleEffect(me, "TinyRedExplode")
	
	entity_setDropChance(me, 10, 1)
	
	entity_rotate(me, 360, 1, LOOP_INF)		-- make the nautilus spin 360 degrees endlessly over 1 second
	v.lungeDelay = 1.0				-- prevent the nautilus from attacking right away
	entity_scale(me, 1.2, 1.2)
end

-- the entity's main update function
function update(me, dt)
	dt = dt * 1.2
	
	-- in any state: if we have a target and we're close enough, hurt the target and move back

	
	-- in idle state only
	if entity_getState(me)==STATE_IDLE then
		-- count down the v.lungeDelay timer to 0
		if v.lungeDelay > 0 then v.lungeDelay = v.lungeDelay - dt if v.lungeDelay < 0 then v.lungeDelay = 0 end end
		
		-- if we don't have a target, find one
		if not entity_hasTarget(me) then
			entity_findTarget(me, 1000)
		else
			if entity_isTargetInRange(me, 1600) then
				if entity_isTargetInRange(me, 200) then
					entity_moveTowardsTarget(me, dt, -500);		-- if we're too close, move away
				else					
					entity_moveTowardsTarget(me, dt, 1000)		-- move in if we're too far away
				end
			end
			
			-- 40% of the time when we're in range and not delaying, launch an attack
			if entity_isTargetInRange(me, 300) then
				if math.random(100) < 40 and v.lungeDelay == 0 then
					entity_setState(me, STATE_ATTACKPREP, 0.5)
				end
			end
			
			-- avoid other things nearby
			entity_doEntityAvoidance(me, dt, 128, 0.5);
--			entity_doSpellAvoidance(dt, 200, 1.5);
			entity_doCollisionAvoidance(me, dt, 4, 0.1);
		end
	end
	entity_updateCurrents(me, dt)
	entity_updateMovement(me, dt)
	
	entity_handleShotCollisions(me)
	if entity_hasTarget(me) then
		if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1) then
			entity_moveTowardsTarget(me, dt, -10000)
		end
	end	
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_setMaxSpeed(me, 400)
	elseif entity_getState(me)==STATE_ATTACKPREP then
		entity_sound(me, "Nautilus", 1200+math.random(100))
		entity_setMaxSpeed(me, 0)
		entity_doGlint(me, "Glint", BLEND_ADD)
	elseif entity_getState(me)==STATE_ATTACK then
		entity_enableMotionBlur(me)
		v.lungeDelay = 1.5
		entity_setMaxSpeed(me, 950)
		entity_moveTowardsTarget(me, 950, 1)
	end
end

function exitState(me)
	if entity_getState(me)==STATE_ATTACKPREP then
		entity_setState(me, STATE_ATTACK, 1)
	elseif entity_getState(me)==STATE_ATTACK then
		entity_disableMotionBlur(me)
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_getHealth(me)-dmg <= 0 then
		entity_sound(me, "Nautilus", 1500 + math.random(100))
	else
		entity_sound(me, "Nautilus", 900 + math.random(100))
	end
	return true
end

function hitSurface(me)
end

function shiftWorlds(me, old, new)
end
