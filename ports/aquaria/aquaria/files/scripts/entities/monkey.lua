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


local STATE_CLIMBUP		= 1000
local STATE_WALLATTACK	= 1001
local STATE_CLIMBDOWN	= 1002
local STATE_WALL		= 1003
local STATE_FALLING		= 1004
local STATE_DROWN		= 1005
local STATE_DROWNED		= 1006

v.treeNode = 0
v.moveTimer = 0
v.minNode = 0
v.maxNode = 0
v.hitSoundDelay = 0

function init(me)
	v.walkSpd = 170+math.random(50)
	v.soundDelay = math.random(3)+2

	setupBasicEntity(me, 
	"",					-- texture
	6,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	64,								-- sprite width	
	64,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_initSkeletal(me, "Monkey")
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	
	entity_scale(me, 0.6, 0.6)
	
	v.minNode = entity_getNearestNode(me, "MONKEYMIN")
	v.maxNode = entity_getNearestNode(me, "MONKEYMAX")
	local node = entity_getNearestNode(me, "TREE")
	if node ~= 0 and node_isEntityIn(node, me) then
		debugLog("FOUND TREE!")
		v.treeNode = node
		entity_setState(me, STATE_WALL)
	else
		debugLog("no tree :|")
		entity_clampToSurface(me)
		entity_setState(me, STATE_IDLE)
	end
	
	entity_setCanLeaveWater(me, true)
	
	entity_setMaxSpeed(me, 1400)
	
	esetv(me, EV_WALLOUT, 20)
	
	loadSound("Monkey-Idle")
	loadSound("Monkey-Scream")
	loadSound("Monkey-Hit")
	entity_setDeathSound(me, "Monkey-Scream")
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
end

function update(me, dt)	
	
	if (not entity_isState(me, STATE_DROWN) and not entity_isState(me, STATE_DROWNED)) and entity_isUnderWater(me) and entity_y(me) > getWaterLevel() + 64 then	
		entity_setState(me, STATE_DROWN, 6)
	end
	if entity_isState(me, STATE_IDLE) then	
	--[[
		local node = entity_getNearestNode(me, "TREE")
		if node ~=0 and node_isEntityIn(node, me) then
			v.treeNode = node
			entity_setState(me, STATE_CLIMBUP)			
		end	
		]]--
		--[[
		v.moveTimer = v.moveTimer + dt
		if v.moveTimer > 2.2 then
			entity_flipHorizontal(me)
			entity_switchSurfaceDirection(me)
			v.moveTimer = 0
		end
		]]--	
		if v.minNode and v.maxNode then
			if entity_x(me) < node_x(v.minNode) and not entity_isfh(me) then
				entity_flipHorizontal(me)
				entity_switchSurfaceDirection(me, 0)
				--entity_adjustPositionBySurfaceNormal(me, 2)
				--entity_clampToSurface(me)
			elseif entity_x(me) > node_x(v.maxNode) and entity_isfh(me) then
				entity_flipHorizontal(me)
				entity_switchSurfaceDirection(me, 1)
				--entity_clampToSurface(me)				
			end			
			--[[
			if entity_isNearObstruction(me) then
				entity_adjustPositionBySurfaceNormal(me, 5)
			end
			]]--			
		end

		entity_moveAlongSurface(me, dt, v.walkSpd, 6, 20)
		entity_rotateToSurfaceNormal(me, 0.1)
		v.soundDelay = v.soundDelay - dt
		if v.soundDelay < 0 then
			v.soundDelay = math.random(3)+4
			entity_sound(me, "Monkey-Idle", math.random(200)+900)
		end
	end
	if entity_isState(me, STATE_FALLING) or entity_isState(me, STATE_DROWN) or entity_isState(me, STATE_DROWNED) then
		entity_updateMovement(me, dt)
	end
	
	if entity_isState(me, STATE_CLIMBUP) and not entity_isFollowingPath(me) then
		entity_setState(me, STATE_CLIMBDOWN)
	end
	entity_checkSplash(me)
	entity_handleShotCollisions(me)
	
	if v.hitSoundDelay > 0 then
		v.hitSoundDelay = v.hitSoundDelay - dt
		if v.hitSoundDelay < 0 then
			v.hitSoundDelay = 0
		end
	end
	
	if isObstructed(entity_x(me), entity_y(me)) then
		entity_adjustPositionBySurfaceNormal(me, 1)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_isState(me, STATE_DROWN) or entity_isState(me, STATE_DROWNED) then
		return true
	end
	if entity_isState(me, STATE_WALL) then
		entity_setState(me, STATE_FALLING)	
	end
	if damageType == DT_AVATAR_VINE then
		if entity_isState(me, STATE_WALL) then
			-- monkey knocked out of tree with vine
			flingMonkey(me)
			--entity_sound(me, "Monkey-Scream", math.random(200)+900)
			playSfx("Monkey-Scream")
			return false
		end
	end
	if v.hitSoundDelay == 0 then
		playSfx("Monkey-Hit")
		v.hitSoundDelay = 0.3 + math.random(2)*0.1
	end
	return true
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		--entity_animate(me, "idle", LOOP_INF)
		entity_animate(me, "crawl", LOOP_INF)
	elseif entity_isState(me, STATE_ATTACK) then
		entity_animate(me, "attack")
	elseif entity_isState(me, STATE_WALLATTACK) then
		entity_animate(me, "wallAttack")
	elseif entity_isState(me, STATE_WALL) then
		debugLog("STATEWALL!")
		entity_animate(me, "wall", LOOP_INF)
	elseif entity_isState(me, STATE_FALLING) then
		entity_setWeight(me, 1200)
	elseif entity_isState(me, STATE_DROWN) then
		entity_setDeathSound(me, "")
		entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
		--entity_setDamageTarget(me, DT_AVATAR_PET, false)
		entity_animate(me, "drown", LOOP_INF)
		entity_setWeight(me, 400)
		entity_setMaxSpeedLerp(me, 0.2, 0.1)
		
		entity_setDeathSound(me, "")
	elseif entity_isState(me, STATE_DROWNED) then
		entity_animate(me, "drowned", LOOP_INF)
		entity_rotate(me, 0, 0.1)
		entity_setWeight(me, -200)
		entity_setMaxSpeedLerp(me, 0.1, 1)
		entity_setCanLeaveWater(me, false)
		entity_setProperty(me, EP_MOVABLE, true)
		entity_setDeathSound(me, "")
	elseif entity_isState(me, STATE_CLIMBDOWN) then
		entity_animate(me, "wall", LOOP_INF)
		entity_followPath(me, v.treeNode, SPEED_VERYSLOW, 1)
	end
end

function exitState(me)
	if entity_isState(me, STATE_FALLING) then
		entity_setWeight(me, 0)
	elseif entity_isState(me, STATE_DROWN) then
		entity_setState(me, STATE_DROWNED)
	end
end

function hitSurface(me)
	if entity_isState(me, STATE_FALLING) then
		entity_clampToSurface(me)
		entity_setState(me, STATE_IDLE)
	end
end
