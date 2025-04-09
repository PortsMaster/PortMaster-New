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

-- H A T C H E T F I S H



local STATE_CIRCLE			= 1000
local STATE_WANDER			= 1001		--Assumes bevy has no target
local STATE_SEEKTARGET		= 1002		--Everything is just dandy, following stuff
local STATE_SEEKBEVY		= 1003		--No bevy in range, find a bevy!

v.targetDelay = 0.5				-- Time between checking targets
v.wanderDelay = 2				-- Amount of time to wander in a given direction

v.segsOn = true

-- ================================================================================================
-- M Y   F U N C T I O N S
-- ================================================================================================

local function setSpookSegsOn(me)
	bone_setSegs(v.body, 8, 2, 0.12, 0.42, 0, -0.03, 8, 0)
	bone_setSegs(v.glow01, 8, 2, 0.12, 0.42, 0, -0.03, 8, 0)
	bone_setSegs(v.glow02, 8, 2, 0.12, 0.42, 0, -0.03, 8, 0)
end

local function setSpookSegsOff(me)
	bone_setSegs(v.body, 8, 2, 0.23, 0.69, 0, -0.03, 8, 0)
	bone_setSegs(v.glow01, 8, 2, 0.23, 0.69, 0, -0.03, 8, 0)
	bone_setSegs(v.glow02, 8, 2, 0.23, 0.69, 0, -0.03, 8, 0)
	--bone_setSegs(v.body)
	--bone_setSegs(v.glow01)
	--bone_setSegs(v.glow02)
end

-- ================================================================================================
-- F U N C T I O N S
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
	STATE_WANDER,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1,								-- updateCull -1: disabled, default: 4000
	1
	)

	entity_initSkeletal(me, "hatchetfish")
	v.body = entity_getBoneByName(me, "body")
	v.glow01 = entity_getBoneByName(me, "glow01")
	v.glow02 = entity_getBoneByName(me, "glow02")

	entity_animate(me, "idle", LOOP_INF)
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	entity_setMaxSpeed(me, 400)
	entity_setDropChance(me, 10, 1)
	
	local scale_random = math.random(40) * 0.01
	entity_scale(me, 0.6 + scale_random, 0.6 + scale_random)
	esetv(me, EV_ENTITYDIED, 1)
end

function postInit(me)
	--bone_scale(v.glow02, 1.31, 2.5, 3.4, -1, 1, 1)
	bone_alpha(v.glow01, 0.12, 1.23, -1, 1, 1)
	bone_alpha(v.body, 0.23, 4.2, -1, 1, 1)

	setSpookSegsOn(me)
	v.segsOn = true
end

function entityDied(me, ent)
	if entity_getTarget(me) == ent then
		entity_setTarget(me, 0)
	end
end

-- the entity's main update function
function update(me, dt)	
	--Timer for checking state and target
	if v.targetDelay > 0 then v.targetDelay = v.targetDelay - dt if v.targetDelay < 0 then v.targetDelay = 0 end end
	
	--Update State/Target
	if v.targetDelay == 0 then
		local target = entity_getNearestEntity(me, "hatchetfish")
		if target == 0 then	--No Bevys at all!
			if not entity_isState(me, STATE_WANDER) then entity_setState(me, STATE_WANDER) end
		else
			if not entity_isEntityInRange(me, target,800) then 						--No bevy nearby... FIND A BEVY
				if not entity_isState(me, STATE_SEEKBEVY) then entity_setState(me, STATE_SEEKBEVY) end
			else																	--In range of another bevy
				if not entity_isState(me, STATE_SEEKTARGET) then entity_animate(me, "idle", LOOP_INF) end --We want to find a new target every targetUpdate, but don't want to start animation again
				entity_setState(me, STATE_SEEKTARGET)
			end
		end
		v.targetDelay = 0.5
	end
	
	--Perform actions based on state
	if entity_isState(me, STATE_WANDER) then
		if v.wanderDelay > 0 then v.wanderDelay = v.wanderDelay - dt if v.wanderDelay < 0 then v.wanderDelay = 0 end end
		if v.wanderDelay == 0 then
			entity_addVel(me, math.random(50) - 100, math.random(50) - 100)
			v.wanderDelay = 1.5
		end
	elseif entity_hasTarget(me) then
		if entity_isState(me, STATE_SEEKBEVY) then
			entity_moveTowardsTarget(me, dt, 400)
		elseif entity_isState(me, STATE_SEEKTARGET) and entity_isTargetInRange(me, 2000) then
			entity_moveTowardsTarget(me, dt, 300)
		end			--If it has a target, but it's out of range, do nothing, it'll update target soon
	end				--If it has no target, do nothing...
	
	--Maintenance
	entity_flipToVel(me)
	entity_doCollisionAvoidance(me, dt, 4, 0.1)
	entity_updateCurrents(me, dt)
	entity_updateMovement(me, dt)
	entity_handleShotCollisions(me)
	
end

function enterState(me)
	if entity_isState(me, STATE_WANDER) then
		entity_animate(me, "FRENZY", LOOP_INF)
	elseif entity_isState(me, STATE_SEEKTARGET) then
		entity_color(me, 1, 1, 1, 1)
		entity_setTarget(me, entity_getNearestEntity(me, "!Bevy", 2000))
	elseif entity_isState(me, STATE_SEEKBEVY) then
		entity_color(me, 1, 0.5, 0.5, 1)
		entity_animate(me, "FRENZY", LOOP_INF)
		entity_setTarget(me, entity_getNearestEntity(me, "Bevy", 2500))
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function hitSurface(me)
end

function shiftWorlds(me, old, new)
end
