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
-- R U K H
-- ================================================================================================

-- ================================================================================================
-- S T A T E S
-- ================================================================================================

local STATE_NESTING = 1001
local STATE_STARTLED = 1002
local STATE_HOVERING = 1003
local STATE_FLYING = 1004

-- ================================================================================================
-- L O C A L   V A R I A B L E S 
-- ================================================================================================

v.startX = 0
v.startY = 0
v.startRot = 0

v.hitCount = 12

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"Rukh/Head",					-- texture
	21,								-- health
	2,								-- manaballamount
	1,								-- exp
	1,								-- money
	64,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	2200							-- updateCull -1: disabled, default: 4000
	)
	
	loadSound("RukhYell")
	loadSound("RukhFlap")
	
	entity_setDeathParticleEffect(me, "Explode")
	entity_setDropChance(me, 100)
	
	entity_initSkeletal(me, "Rukh")
	v.backLeg = entity_getBoneByName(me, "BackLeg")
	v.backWing = entity_getBoneByName(me, "BackWing")
	v.bone_body = entity_getBoneByName(me, "Body")
	v.bone_neck = entity_getBoneByName(me, "Neck")
	
	local cl = 0.56
	bone_setColor(v.backLeg, cl, cl, cl)
	bone_setColor(v.backWing, cl, cl, cl)
	
	entity_setCullRadius(me, 456)
	
	entity_setCanLeaveWater(me, true)
	esetv(me, EV_COLLIDELEVEL, 1)
	
	v.startX, v.startY = entity_getPosition(me)
	v.startRot = entity_getRotation(me)
end

function postInit(me)
	entity_setState(me, STATE_NESTING)
	
	-- FLIP HORIZONTALLY IF THERE'S A FLIP NODE
	local node = entity_getNearestNode(me, "FLIP")
	if node ~=0 then
		if node_isEntityIn(node, me) then 
			entity_fh(me)
		end
	end
end

function update(me, dt)

	-- WAKE UP WHEN THE TIME IS RIGHT
	if entity_getState(me) == STATE_NESTING then	
		entity_findTarget(me, 654)
		
		if entity_hasTarget(me) then
			entity_setState(me, STATE_STARTLED)
			spawnParticleEffect("RukhFeathers", entity_x(me), entity_y(me))
		end
	elseif entity_getState(me) == STATE_HOVERING then
		entity_addVel(me, -3 + math.random(5), 0)
		
		-- RETURN TO NESTING IF NAIJA LEAVES
		entity_findTarget(me, 1234 )
		if not entity_hasTarget(me) then
			entity_setState(me, STATE_NESTING)
		end
	end
	
	
	if entity_getState(me) ~= STATE_FLYING then
		-- FACE NAIJA
		if entity_isfh(me) == true and entity_x(me) > entity_x(getNaija()) then
			entity_fh(me)
		elseif entity_isfh(me) ~= true and entity_x(me) < entity_x(getNaija()) then
			entity_fh(me)
		end
		
		-- FLY AWAY WHEN SHOT ENOUGH
		if v.hitCount <= 0 then
			entity_setState(me, STATE_FLYING)
			spawnIngredient("RukhEgg", entity_x(me), entity_y(me))
			spawnParticleEffect("RukhFeathers", entity_x(me), entity_y(me))
		end
		
	-- DISAPPEAR INTO THE SUNSET
	elseif entity_getState(me) == STATE_FLYING  then
		entity_findTarget(me, 2345)
		if not entity_hasTarget(me) then
			entity_delete(me)
		end
	end
	
	-- UPDATE EVERYTHING
	if entity_getState(me) ~= STATE_NESTING then
		entity_doFriction(me, dt, 69)
		entity_updateMovement(me, dt)
	end
	entity_touchAvatarDamage(me, 32, 0.1, 420)
	entity_handleShotCollisions(me)
end

function animationKey(me, key)
	if entity_getState(me) == STATE_STARTLED then
		if key == 13 or key == 15 or key == 17 then
			entity_addVel(me, 0, -123)
			entity_sound(me, "RukhFlap")
			shakeCamera(2, 1)
			spawnParticleEffect("RukhFeathers", entity_x(me), entity_y(me))
			
		elseif key == 10 then
			entity_rotateTo(me, 0, 1)
			
		elseif key == 1 then
			entity_sound(me, "RukhYell")
		end
		
	elseif entity_getState(me) == STATE_HOVERING then
		if key == 1 then
			entity_addVel(me, 0, -69 - math.random(4))
			entity_sound(me, "RukhFlap")
			shakeCamera(1.2, 1)
		end
		entity_addVel(me, 0, 20)
		
	elseif entity_getState(me) == STATE_FLYING then
		if key == 1 then
			entity_addVel(me, 0, -69 - math.random(12))
			entity_sound(me, "RukhFlap")
			shakeCamera(2.3, 1)
			spawnParticleEffect("RukhFeathers", entity_x(me), entity_y(me))
		end
	end
end

function enterState(me)
	if entity_getState(me) == STATE_NESTING then
		entity_setHealth(me, 21)
		v.hitCount = 12
		entity_animate(me, "nesting", LOOP_INF)
		entity_clearVel(me)
		entity_setPosition(me, v.startX, v.startY, 2, 0, 0, 1)
		entity_rotateTo(me, v.startRot, 2)
		
	elseif entity_getState(me) == STATE_STARTLED then
		entity_setStateTime(me, entity_animate(me, "startled"))
	
	elseif entity_getState(me) == STATE_HOVERING then
		spawnParticleEffect("RukhFeathers", entity_x(me), entity_y(me))
		entity_animate(me, "hovering", LOOP_INF)
		
	elseif entity_getState(me) == STATE_FLYING then
		esetv(me, EV_COLLIDELEVEL, 0)
		entity_animate(me, "flying", LOOP_INF)
		entity_rotateTo(me, 0, 2)
		
		-- FLY AWAY FROM NAIJA
		--[[
		if entity_isfh(me) == true and entity_x(me) > entity_x(getNaija()) then
			entity_addVel(me, 1234, 0)
		elseif entity_isfh(me) ~= true and entity_x(me) < entity_x(getNaija()) then
			entity_addVel(me, -1234, 0)
		end
		entity_fh(me)
		]]--
	end
end

function exitState(me)
	if entity_getState(me) == STATE_STARTLED then
		entity_sound(me, "RukhFlap")
		entity_setState(me, STATE_HOVERING)
	end
end

function damage(me, attacker, bone, damageType, dmg, x, y)
	if entity_getState(me) == STATE_NESTING then
		entity_setState(me, STATE_STARTLED) 
	else
		v.hitCount = v.hitCount - 1
		bone_damageFlash(v.bone_body)
		bone_damageFlash(v.bone_neck)
	end
	
	spawnParticleEffect("RukhFeathers", x, y)
	return false
end

function hitSurface(me)
end
