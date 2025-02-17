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
-- C H O M P E R
-- ================================================================================================

-- ================================================================================================
-- L O C A L   V A R I A B L E S 
-- ================================================================================================

v.startX = 0
v.startY = 0
v.startRot = 0

v.dir = 0

v.biteDelay = 0
v.bD = 1.67	-- Time before bite
v.doneDelay = 0		
v.dD = 1.32	-- Time after bite

v.maxSpeed = 890

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"Chomper/Body",					-- texture
	14,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	64,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	256,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	1800							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setDeathParticleEffect(me, "Explode")
	entity_setDropChance(me, 11)
	
	entity_initSkeletal(me, "Chomper")
	v.glow = entity_getBoneByName(me, "EyeGlow")
	v.body = entity_getBoneByName(me, "Body")
	
	entity_setEntityType(me, ET_ENEMY)
	entity_generateCollisionMask(me)
	
	entity_setCullRadius(me, 420) -- Skeletal sprites ain't got auto cull yet (says Alec)
	
	bone_alpha(v.glow, 0.21)
	bone_scale(v.glow, 0.12, 0.12)
	
	entity_setMaxSpeed(me, v.maxSpeed)
	
	entity_initEmitter(me, 0, "ChomperLunge")
end

function postInit(me)
	entity_setState(me, STATE_IDLE)
	v.startX, v.startY = entity_getPosition(me)
	v.startRot = entity_getRotation(me)
	
	-- FLIP HORIZONTALLY IF THERE'S A FLIP NODE
	local node = entity_getNearestNode(me, "FLIP")
	if node ~=0 then
		if node_isEntityIn(node, me) then 
			entity_fh(me)
			v.dir = 1
		end
	end
end

function update(me, dt)
	-- SET TARGET TO BODY
	entity_clearTargetPoints(me)
	local x,y = bone_getWorldPosition(v.body)
	entity_addTargetPoint(me, x, y)
	
	entity_findTarget(me, 808)
	
	if not entity_hasTarget(me) then
		bone_alpha(v.glow, 0.21, 0.89)
		bone_scale(v.glow, 0.12, 0.12, 0.89)
		
		v.biteDelay = v.bD
	else
		bone_alpha(v.glow, 0.89, 0.26)
		bone_scale(v.glow, 1, 1, 0.26)
		
		if entity_getState(me) == STATE_OPEN then
			bone_alpha(v.glow, 0.93, 0.64)
			bone_scale(v.glow, 1.8, 1.8, 0.56)
			-- Aim a bit before bite
			entity_rotateToEntity(me, getNaija(), 2.8, 90 +(v.dir*-180))
		end
		
		-- TIME BETWEEN BITES
		if v.biteDelay > 0 then v.biteDelay = v.biteDelay - dt
		else v.biteDelay = 0 end
		
		if v.biteDelay == 0 then
			if entity_isState(me, STATE_IDLE) then entity_setState(me, STATE_OPEN) end
			v.biteDelay = v.bD
		end
	end
	
	-- WAIT A MOMENT BEFORE RETURNING TO START POSITION
	if entity_getState(me) == STATE_DONE then
		if v.doneDelay > 0 then v.doneDelay = v.doneDelay - dt
		else v.doneDelay = 0 end
		
		if v.doneDelay == 0 then entity_setState(me, STATE_CLOSE) end
	end

	-- DON'T UPDATE MOVEMENT IF CHOMPER'S SLIDING BACK TO HOME POSITION
	if entity_getState(me) == STATE_CLOSE then
		local closeX, closeY = entity_getPosition(me)
		
		if closeX == v.startX and closeY == v.startY then
			entity_setState(me, STATE_IDLE)
		end
	else
		-- UPDATE MOVEMENT
		entity_doFriction(me, dt, 654)
		entity_updateMovement(me, dt)
	end
	
	-- UPDATE COLLISIONS
	if entity_getState(me) == STATE_ATTACK then entity_touchAvatarDamage(me, 124, 3.2, 1337)
	else entity_touchAvatarDamage(me, 98, 1.2, 789)  end	-- Could make skeletal as well...
	entity_handleShotCollisionsSkeletal(me)
end

function enterState(me)
	if entity_getState(me) == STATE_IDLE then
		entity_animate(me, "idle", LOOP_INF)
		v.biteDelay = v.bD
		entity_clearVel(me)
		entity_setMaxSpeed(me, 0)
		
	elseif entity_getState(me) == STATE_OPEN then
		entity_setStateTime(me, entity_animate(me, "open"))
		entity_setNaijaReaction(me, "shock")
		
	elseif entity_getState(me) == STATE_ATTACK then
		entity_setStateTime(me, entity_animate(me, "attack"))
		entity_setMaxSpeed(me, v.maxSpeed)
		entity_setMaxSpeedLerp(me, 7.9)				-- Increased biteyness
		entity_setMaxSpeedLerp(me, 0.76, 0.38)
	
	elseif entity_getState(me) == STATE_DONE then
		entity_animate(me, "idle", LOOP_INF)
		entity_rotateTo(me, v.startRot, 3.21)
		
	elseif entity_getState(me) == STATE_CLOSE then
		-- Go back home, Chomper!
		entity_setPosition(me, v.startX, v.startY, 2, 0, 0, 1)
	end
end

function animationKey(me, key)
	if entity_getState(me) == STATE_ATTACK and key == 0 then
		entity_sound(me, "Bite", 543 + math.random(123))
		
		-- THRUST IN PROPER DIRECTION
		if v.dir == 0 then
			local thrustX, thrustY = entity_getAimVector(me, 270, (v.maxSpeed*10), 0)
			entity_addVel(me, thrustX, thrustY)
		else
			local thrustX, thrustY = entity_getAimVector(me, 270, (v.maxSpeed*10), 1)
			entity_addVel(me, thrustX, thrustY)
		end
		
		spawnParticleEffect("ChomperLunge", entity_x(me), entity_y(me))
		entity_startEmitter(me, 0)
		shakeCamera(3.2, 0.54)
	end
end

function exitState(me)
	if entity_getState(me) == STATE_OPEN then
		entity_setState(me, STATE_ATTACK)
	
	elseif entity_getState(me) == STATE_ATTACK then
		entity_setState(me, STATE_DONE)
		v.doneDelay = v.dD
		entity_stopEmitter(me, 0)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if bone == v.body then
		return true
	end
	
	return false
end

function dieNormal(me)
	if chance(75) then
		spawnIngredient("SpicyMeat", entity_x(me), entity_y(me))
	end
end

