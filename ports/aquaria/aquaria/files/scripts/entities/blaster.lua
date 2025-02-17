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
-- B L A S T E R
-- ================================================================================================

-- entity specific
local STATE_FIRE			= 1000
local STATE_PULLBACK		= 1001
v.fireDelay = 0
v.motherChance = 10
v.soundDelay = 0
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	4,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000							-- updateCull -1: disabled, default: 4000
	)
		
	entity_initSkeletal(me, "Blaster")
	entity_animate(me, "idle", -1)
		
	entity_setDeathParticleEffect(me, "Explode")
	
	entity_scale(me, 0.8, 0.8)
	
	v.soundDelay = math.random(3)+1
	
	entity_setEatType(me, EAT_FILE, "Blaster")
	
	loadSound("BlasterLaugh")
end

function update(me, dt)
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, 32, 0, 1000)
	if true then
		if entity_hasTarget(me) then
			if entity_isTargetInRange(me, 200) then
				entity_moveTowardsTarget(me, dt, -200)
			end
			if entity_isTargetInRange(me, 64) then
	--			entity_hurtTarget(1);
				entity_moveTowardsTarget(me, dt, -1000)
			end
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
			else
				if entity_isTargetInRange(me, 1600) then				
					entity_moveTowardsTarget(me, dt, 400)		-- move in if we're too far away
					if entity_isTargetInRange(me, 350) and v.fireDelay==0 then
						entity_setState(me, STATE_FIRE, 0.5)
					end
				end
							
			end
			v.soundDelay = v.soundDelay - dt 
			if v.soundDelay < 0 then
				-- Sound doesn't exist, so commenting out.  --achurch
				--entity_playSfx(me, "BlasterIdle")
				v.soundDelay = math.random(3)+1
			end
		end
		if entity_getState(me)==STATE_FIRE then
			entity_moveTowardsTarget(me, dt, -600)
		end
		if entity_getState(me)==STATE_PULLBACK then
			if not entity_hasTarget(me) then
				entity_setState(me, STATE_IDLE)
			else
				if entity_isTargetInRange(me, 800) then
					entity_moveTowardsTarget(me, dt, -5000)
				else
					entity_setState(me, STATE_IDLE)
				end
			end
		end
	end
	entity_doEntityAvoidance(me, dt, 256, 0.2)
--	entity_doSpellAvoidance(dt, 200, 1.5);
	entity_doCollisionAvoidance(me, dt, 6, 0.5)
	entity_rotateToVel(me, 0.1)
	entity_updateCurrents(me, dt)
	entity_updateMovement(me, dt)
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		v.fireDelay = 2
		entity_setMaxSpeed(me, 500)
	elseif entity_getState(me)==STATE_FIRE then
		entity_setMaxSpeed(me, 600)
		local s = createShot("BlasterFire", me, entity_getTarget(me))
		shot_setOut(s, 32)
	elseif entity_getState(me)==STATE_PULLBACK then
		if chance(50) then
			entity_playSfx(me, "BlasterLaugh")
		end
		entity_setMaxSpeed(me, 650)
	end
end

function exitState(me)
	if entity_getState(me)==STATE_FIRE then
		entity_setState(me, STATE_PULLBACK, 1)
	elseif entity_getState(me)==STATE_PULLBACK then
		entity_setState(me, STATE_IDLE)
	end
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -99)
	end
	return true
end
