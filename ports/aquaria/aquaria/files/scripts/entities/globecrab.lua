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
-- G L O B E  C R A B
-- ================================================================================================

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.speed = 150
v.delay = 0.5
v.moveaway = 0

local STATE_ROTATE = 1000
local STATE_WALK = 1001
local STATE_MOVEAWAY = 1002

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupEntity(me)
	entity_setEntityLayer(me, -3)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "GlobeCrab")	
	--entity_setAllDamageTargets(me, false)
	
	--entity_generateCollisionMask(me)
	entity_setCollideRadius(me, 32)
	
	entity_setState(me, STATE_IDLE)

	esetv(me, EV_TYPEID, EVT_GLOBEJELLY)
	
	entity_setHealth(me, 3)
	entity_setDropChance(me, 20, 1)
	
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	entity_setUpdateCull(me, 4000)

	local scale_random = math.random(40) * 0.01
	entity_scale(me, 0.6 + scale_random, 0.6 + scale_random)
end

function postInit(me)
	v.n = getNaija()
	--entity_setTarget(me, v.n)
end

function update(me, dt)

	if entity_isState(me, STATE_IDLE) then
		if v.delay > 0 then
			v.delay = v.delay - dt
			--debugLog(string.format("globecrab delay: %d", v.delay))
		elseif math.random(100) == 1 then
			entity_setState(me, STATE_ROTATE)
			v.delay = 0.5
		end
	elseif entity_isState(me, STATE_ROTATE) then
		entity_rotate(me, entity_getRotation(me)+90*dt)
		if v.delay > 0 then
			v.delay = v.delay - dt
		elseif math.random(100) == 1 then
			if v.moveaway == 1 then
				entity_setState(me, STATE_MOVEAWAY)
				v.delay = 0.5
			else
				entity_setState(me, STATE_WALK)
				v.delay = 1
			end
		end
	elseif entity_isState(me, STATE_MOVEAWAY) then
		v.vx, v.vy = vector_setLength(v.vx, v.vy, v.speed*dt)
		entity_setPosition(me, entity_x(me) + v.vx, entity_y(me) + v.vy)

		if v.delay > 0 then
			v.delay = v.delay - dt
		else
			entity_setState(me, STATE_IDLE)
			v.moveaway = 0
			v.delay = 0.5
		end
	elseif entity_isState(me, STATE_WALK) then

		local coll = 0

		-- CRAB COLLISION CHECK
		local e = getFirstEntity()
		while e ~= 0 do
			if e ~= me and eisv(e, EV_TYPEID, EVT_GLOBEJELLY) and entity_isEntityInRange(me, e, 64) then
				entity_setState(me, STATE_IDLE)
				v.delay = 0.5
				coll = 1
				v.moveaway = 1 -- so they don't get stuck
			end
			e = getNextEntity()
		end

		-- WALL COLLISION CHECK
		v.vx, v.vy = entity_getNormal(me)
		v.vx, v.vy = vector_setLength(v.vx, v.vy, v.speed*dt)

		if isObstructedBlock(entity_x(me) + v.vx, entity_y(me) + v.vy, 2) then
			entity_setState(me, STATE_IDLE)
			v.delay = 0.5
			coll = 1
		end

		if coll == 0 then
			v.vx, v.vy = vector_setLength(v.vx, v.vy, v.speed*dt)
			entity_setPosition(me, entity_x(me) + v.vx, entity_y(me) + v.vy)

			if v.delay > 0 then
				v.delay = v.delay - dt
			elseif math.random(100) == 1 then
				entity_setState(me, STATE_IDLE)
				v.delay = 0.5
			end
		end
	else
		entity_setState(me, STATE_IDLE)
	end

	entity_updateMovement(me, dt)

	entity_handleShotCollisions(me)
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 400) then
		entity_moveTowardsTarget(me, 1, -500)
	end

end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_ROTATE) then
		entity_animate(me, "walk", -1)
	elseif entity_isState(me, STATE_WALK) then
		entity_animate(me, "walk", -1)		
	end
		
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function animationKey(me, key)
end

function hitSurface(me)
	--debugLog("HIT")
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

function dieNormal(me)
	if chance(20) then
		spawnIngredient("CrabMeat", entity_x(me), entity_y(me))
	end
end

