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

-- ===============================================================================================
-- SPORE CHILD
-- ================================================================================================

v.growth = 0
v.growTime = 5
v.growEmitter = 0
v.seekEnemy = 0
v.seekEnemyDelay = 1.5

v.minSpeed = 450
v.maxSpeed = 700

v.backAway = 0
v.backAwayTime = 0.75

v.myType = 1

v.flowerTimer = 0

local STATE_MOVETOFLOWER 	= 1000
local STATE_OPENFLOWER	= 1001

v.state2 = 0

function init(me)
	setupBasicEntity(
	me,
	"SporeChildSeed",				-- texture
	16,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	16,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	64,								-- sprite width	
	64,								-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1,								-- updateCull -1: disabled, default: 4000
	1
	)
	
	entity_initEmitter(me, v.growEmitter, "SporeSeedGrow")
	
	entity_setCollideRadius(me, 16)
	entity_setEntityType(me, ET_PET)
	
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)
	entity_setDamageTarget(me, DT_AVATAR_VOMIT, false)
	entity_setDamageTarget(me, DT_AVATAR_SPORECHILD, false)
	
	entity_setState(me, STATE_SEED)
	
	v.seekEnemy = v.seekEnemyDelay
end

function songNote(me, note)	
	if note == 0 or note == 1 then
		-- green
		v.myType = 1
	elseif note == 2 or note == 3 then
		-- blue
		v.myType = 2
	elseif note == 4 or note == 5 then
		-- red
		v.myType = 0
	elseif note == 6 or note == 7 then
		-- yellow
		v.myType = 3
	end
end

local function hatch(me)
	if v.myType == 0 then
		entity_setState(me, STATE_SK_RED)
	elseif v.myType == 1 then
		entity_setState(me, STATE_SK_GREEN)
	elseif v.myType == 2 then
		entity_setState(me, STATE_SK_BLUE)
	elseif v.myType == 3 then
		entity_setState(me, STATE_SK_YELLOW)
	end

end

local function isHatched(me)
	return (entity_isState(me, STATE_SK_RED) or entity_isState(me, STATE_SK_BLUE)
	or entity_isState(me, STATE_SK_GREEN) or entity_isState(me, STATE_SK_YELLOW))
end

function update(me, dt)
	registerSporeChildData(me)
	entity_handleShotCollisions(me)
	if isHatched(me) then
		entity_updateCurrents(me, dt)
	end
	entity_updateMovement(me, dt)
	
	if v.state2 == STATE_MOVETOFLOWER then
		if not entity_isFollowingPath(me) or entity_isEntityInRange(me, v.flower, 128) then
			v.state2 = STATE_OPENFLOWER
			entity_animate(me, "openFlower", LOOP_INF)
			entity_clearVel(me)
			entity_setTarget(me, v.flower)
			entity_stopFollowingPath(me)
			v.flowerTimer = 0
		end
	end
	if v.state2 == STATE_OPENFLOWER then
		if entity_isState(v.flower, STATE_OPENED) then
			v.state2 = 0
			v.flower = 0
			entity_animate(me, "idle", LOOP_INF)
			entity_setState(me, entity_getState(me))
		else 
			v.flowerTimer = v.flowerTimer + dt
			if v.flowerTimer < 1 then
				entity_moveTowardsTarget(me, dt, 100)
			else
				entity_moveTowardsTarget(me, dt, -100)
			end
			if v.flowerTimer > 2 then
				v.flowerTimer = 0
			end
		end
	end

	if entity_isState(me, STATE_SEED) then
		local node = entity_getNearestNode(me, "GSPOT")
		if node ~= 0 then
			if node_isEntityIn(node, me) then
				if v.growing then
					v.growth = v.growth + dt
					if v.growth > v.growTime then
						hatch(me)
					end
				else
					v.growing = true
					entity_startEmitter(me, v.growEmitter)
				end
			else
				if v.growing then
					entity_stopEmitter(me, v.growEmitter)
				end
				v.growing = false
			end
		end
	--elseif entity_isState(me, STATE_HATCHEDYOUNG) then	
	elseif isHatched(me) and v.state2==0 then
		if not entity_hasTarget(me) then
			local ent = entity_getNearestEntity(getNaija(), "SporeChildFlower")
			if ent ~= 0 then
				if entity_isEntityInRange(getNaija(), ent, 256) and entity_isState(ent, STATE_IDLE) then
					v.flower = ent
					v.state2 = STATE_MOVETOFLOWER
					entity_swimToPosition(me, entity_getPosition(v.flower))
				end
			end
			entity_findTarget(me, 800, ET_AVATAR)
		end	
		if entity_hasTarget(me) then
			local ent = entity_getNearestEntity(getNaija(), "SporeChildFlower")
			if ent ~= 0 and entity_isEntityInRange(getNaija(), ent, 64) and entity_isState(ent, STATE_IDLE) then
				entity_setTarget(me, 0)
			else
				if entity_getHealth(entity_getTarget(me)) < 1 then
					entity_setTarget(me, 0)
				else
					local target = entity_getTarget(me)
					if entity_getEntityType(target)==ET_ENEMY then
						v.seekEnemy = 0
						entity_rotateToVel(me, 0)
						entity_setMaxSpeedLerp(me, 1.0, 0.1)
						if v.backAway > 0 then						
							v.backAway = v.backAway - dt
							entity_moveTowardsTarget(me, dt, -2000)
							if v.backAway < 0 then
								v.backAway = 0
								entity_setMaxSpeedLerp(me, 1.0, 0.2)
							end
						else
							entity_moveTowardsTarget(me, dt, 2000)
						end
						entity_doCollisionAvoidance(me, dt, 2, 0.5)					
						if entity_isEntityInRange(me, target, 32 + entity_getCollideRadius(target)) then
							entity_damage(target, me, 1, DT_AVATAR_SPORECHILD)
							v.backAway = v.backAwayTime
							entity_moveTowardsTarget(me, 1, -2000)
							--entity_setMaxSpeedLerp(me, 0.01, 0.01)
							--entity_setTarget(me, 0)
						elseif not entity_isTargetInRange(me, 1500) then
							entity_setTarget(me, 0)
						end
						entity_doEntityAvoidance(me, dt, 4, 1)
					else
						if entity_isTargetInRange(me, 220) then
							entity_rotate(me, 0, 1.0)
						else
							entity_rotateToVel(me, 0.5)
						end
						-- if moving to naija					
						if entity_isEntityInRange(me, target, 200) then
							if entity_isEntityInRange(me, target, 96) then
								entity_moveTowardsTarget(me, dt, -100) 
							else
								entity_moveTowardsTarget(me, dt, 1000)
							end
							entity_setMaxSpeedLerp(me, 0.2, 1.0)
						else
							entity_moveTowardsTarget(me, dt, 1500)
							entity_setMaxSpeedLerp(me, 1.4, 0.1)
						end
						entity_doCollisionAvoidance(me, dt, 3, 0.5)
						entity_doEntityAvoidance(me, dt, 32, 0.1)
					end
				end
			end
		end
		v.seekEnemy = v.seekEnemy - dt
		if v.seekEnemy < 0 then
			if entity_isEntityInRange(me, getNaija(), 1000) then
					if not entity_isEntityInRange(me, getNaija(), 500) then
						entity_setMaxSpeedLerp(me, 2.0, 0.2)
					else
						entity_setMaxSpeedLerp(me, 1.0, 0.2)
					end
				--if entity_isState(me, STATE_SK_GREEN) then
					entity_findTarget(me, 2000, ET_ENEMY)
					local ent = entity_getTarget(me)
					if ent ~=0 then
						if not entity_isDamageTarget(ent, DT_AVATAR_SPORECHILD) then
							entity_setTarget(me, 0)
							entity_setMaxSpeed(me, v.minSpeed)						
						else
							entity_setMaxSpeed(me, v.maxSpeed)
							entity_setMaxSpeedLerp(me, 1.2, 0.1)
						end
					end
				--end
			else
				entity_setTarget(me, getNaija())
				entity_setMaxSpeed(me, v.minSpeed)
			end
			v.seekEnemy = v.seekEnemyDelay
		end
	end
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_SEED) then
		v.growth = 0
		entity_setProperty(me, EP_MOVABLE, true)
		entity_setWeight(me, 200)
	elseif isHatched(me) then
		entity_setMaxSpeed(me, v.minSpeed)
		--entity_setColor(me, 1, 0, 0, 0.5)
		entity_setProperty(me, EP_MOVABLE, false)
		entity_setWeight(me, 0)
		if entity_isState(me, STATE_SK_RED) then
			entity_initSkeletal(me, "SK-Red")
		elseif entity_isState(me, STATE_SK_GREEN) then
			entity_initSkeletal(me, "SK-Green")
		elseif entity_isState(me, STATE_SK_BLUE) then			
			entity_initSkeletal(me, "SK-Blue")
		elseif entity_isState(me, STATE_SK_YELLOW) then
			entity_initSkeletal(me, "SK-Yellow")
		end
		entity_scale(me, 0.7, 0.7)
		
		entity_animate(me, "idle", LOOP_INF)
	elseif entity_isState(me, STATE_IDLE) then		
		entity_setProperty(me, EP_MOVABLE, false)
		entity_setWeight(me, 0)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_ENERGYBLAST then
		return false
	end	
	return true
end

function exitState(me)
	if entity_isState(me, STATE_SEED) then
		entity_stopEmitter(me, v.growEmitter)
	end
end
