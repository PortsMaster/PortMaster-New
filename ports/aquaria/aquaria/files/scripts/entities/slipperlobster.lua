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
-- S L I P P E R  L O B S T E R
-- ================================================================================================

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.speed = 150
v.delay = 0.5
v.rotate = 0
v.moveaway = 0

local STATE_ROTATE = 1000
local STATE_WALK = 1001
local STATE_MOVEAWAY = 1002

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "SlipperLobster")	
	--entity_setAllDamageTargets(me, false)
	
	--entity_generateCollisionMask(me)
	entity_setCollideRadius(me, 128)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setHealth(me, 3)
	
	--entity_setDeathParticleEffect(me, "TinyRedExplode")
	entity_setUpdateCull(me, 4000)

	entity_scale(me, 0.9, 0.9)
	
	entity_setCanLeaveWater(me, true)
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	--entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	--entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)
end

function postInit(me)
	v.n = getNaija()
	--entity_setTarget(me, v.n)
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) then
		entity_setState(me, STATE_WALK)
	elseif entity_isState(me, STATE_ROTATE) then
		entity_rotate(me, entity_getRotation(me)-90*dt)
		v.rotate = v.rotate + dt
		if v.rotate >= 1 then
			debugLog(entity_getRotation(me))
			if entity_getRotation(me) > 45 and entity_getRotation(me) < 135 then
				entity_rotate(me, 90)
			elseif entity_getRotation(me) > 135 and entity_getRotation(me) < 225 then
				entity_rotate(me, 180)
			elseif entity_getRotation(me) < -45 and entity_getRotation(me) > -135 then
				entity_rotate(me, -90)
			else
				entity_rotate(me, 0)
				debugLog("FUCK")
			end

			v.rotate = 0

			entity_setState(me, STATE_WALK)
		end
	elseif entity_isState(me, STATE_WALK) then

		local coll = 0

		-- WALL COLLISION CHECK
		local vx, vy = entity_getNormal(me)
		vx, vy = vector_setLength(vx, vy, 2.5)

		if isObstructedBlock(entity_x(me) + vx*65, entity_y(me) + vy*65, 2) then
			entity_setState(me, STATE_ROTATE)
			coll = 1
		end

		if coll == 0 then
			vx, vy = vector_setLength(vx, vy, v.speed*dt)
			entity_setPosition(me, entity_x(me) + vx, entity_y(me) + vy)
		end

		local rangeNode = entity_getNearestNode(me, "KILLENTITY")
		if node_isPositionIn(rangeNode, entity_x(me), entity_y(me)) then
			debugLog("DIEEE")
			entity_setState(me, STATE_DEAD)
		end
	else
		entity_setState(me, STATE_IDLE)
	end

	--entity_updateMovement(me, dt)

	--entity_handleShotCollisions(me)
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 400) then
		--entity_moveTowardsTarget(me, 1, -500)
	end
	
	entity_handleShotCollisions(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_ROTATE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_WALK) then
		entity_animate(me, "idle", -1)		
	end
		
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	playNoEffect()
	return false
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

