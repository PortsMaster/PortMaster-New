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
-- C R E A T O R ,   F O R M   4   (beta)
-- ================================================================================================

-- ================================================================================================
-- L O C A L   V A R I A B L E S
-- ================================================================================================

v.n = 0

v.bone_body = 0
v.bone_darkLi = 0

v.hits1 = 4
v.hits2 = 2

v.lureNode = 1
v.lastNodeNum = 0

v.hideCount = v.hits1

v.maxSpeed = 505

v.chaseRange = 690
v.attackRange = 489
v.waitToAttack = 0
v.hitNaija = 0

-- ================================================================================================
-- S T A T E S
-- ================================================================================================

local STATE_TRAP		= 1000
local STATE_PAIN		= 1001
local STATE_ATTACK		= 1002
local STATE_LUREWAIT	= 1003
local STATE_INTRO		= 1004
local STATE_CHASE		= 1005
local STATE_CREEP		= 1006

-- ================================================================================================
-- P H A S E S
-- ================================================================================================

v.phase = 0

local PHASE_LURE		= 0
local PHASE_HIDE		= 1
local PHASE_FINAL		= 2

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	
	entity_initSkeletal(me, "CreatorForm4")	
	v.bone_body = entity_getBoneByName(me, "Body")
	v.bone_darkLi = entity_getBoneByName(me, "DarkLi")
	v.bone_leftHand = entity_getBoneByName(me, "LeftHand")
	v.bone_rightHand = entity_getBoneByName(me, "RightHand")
	
	v.bone_leftLeg1 = entity_getBoneByName(me, "LeftLowerLeg1")
	v.bone_leftLeg2 = entity_getBoneByName(me, "LeftLowerLeg2")
	v.bone_rightLeg1 = entity_getBoneByName(me, "RightLowerLeg1")
	v.bone_rightLeg2 = entity_getBoneByName(me, "RightLowerLeg2")
	
	entity_generateCollisionMask(me)
	entity_setAllDamageTargets(me, true)
	
	entity_setBeautyFlip(me, false)
	esetv(me, EV_FLIPTOPATH, 0)
	
	entity_setCullRadius(me, 700)
	
	loadSound("CreatorForm4-Hit1")
	loadSound("CreatorForm4-Hit2")
	loadSound("CreatorForm4-Die")
	loadSound("creatorform4-bite")
	
	esetv(me, EV_MINIMAP, 1)
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	entity_setState(me, STATE_INTRO)
	
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	playSfx("CreatorForm4-Die")
	
	fadeOutMusic(6)
end

function update(me, dt)
	overrideZoom(0.60)
	entity_updateMovement(me, dt)
	
	if entity_isState(me, STATE_IDLE) then
		entity_setState(me, STATE_MOVE)
	end
	
	if entity_isState(me, STATE_MOVE) then
		entity_setAnimLayerTimeMult(me, 0, 1.89)
	end
	if entity_isState(me, STATE_MOVE) and not entity_isFollowingPath(me) then
		entity_setStateTime(me, 0.1)
	end
	
	if entity_isState(me, STATE_LUREWAIT) then
		entity_rotateToEntity(me, v.n, 0.1)
		if entity_isEntityInRange(me, v.n, 543) then
			entity_setState(me, STATE_MOVE)
		end
	end
	
	-- WAITING FOR NAIJA AT A NODE
	if entity_isState(me, STATE_TRAP) then
		-- FACE NAIJA
		if entity_isEntityInRange(me, v.n, 1234) then
			entity_rotateToEntity(me, v.n, 0.23)
		end
		
		-- ATTAAAACK
		if entity_isEntityInRange(me, v.n, 543) and v.waitToAttack == 1 then
			entity_setState(me, STATE_ATTACK)
		end
		if entity_isEntityInRange(me, v.n, v.attackRange) then
			entity_setState(me, STATE_ATTACK)
		-- CHASE
		elseif entity_isEntityInRange(me, v.n, v.chaseRange) and v.waitToAttack == 0 then
			entity_setState(me, STATE_CHASE)
		end
	end
	
	if entity_isState(me, STATE_ATTACK) then
		entity_rotateToEntity(me, v.n, 1)
	end
	
	if entity_isState(me, STATE_CHASE) then
		if entity_isEntityInRange(me, v.n, 210) then
			entity_setState(me, STATE_TRAP)
		end
	
		--overrideZoom(0.67)
		entity_setAnimLayerTimeMult(me, 0, 0.72)
		entity_moveTowards(me, entity_x(v.n), entity_y(v.n), dt, 432)
		entity_rotateToEntity(me, v.n, 0.21)
		
	elseif entity_isState(me, STATE_CREEP) then
		entity_setAnimLayerTimeMult(me, 0, 0.64)
		entity_moveTowards(me, entity_x(v.n), entity_y(v.n), dt, 323)
		entity_rotateToEntity(me, v.n, 0.34)
		
	else
		if entity_getVelLen(me) <= 234 then
			entity_clearVel(me)
			entity_setMaxSpeed(me, 0)
		end
	end
	
	-- AVOID WALLS
	entity_doCollisionAvoidance(me, dt, 8, 0.32)
		
	local vecX, vecY = entity_getPosition(me)
	local wallX, wallY = getWallNormal(entity_x(me), entity_y(me), 12)
	if wallX ~= 0 or wallY ~= 0 then
		vecX = vecX + wallX*256
		vecY = vecY + wallY*256
		entity_moveTowards(me, vecX, vecY, dt, 248)
	end
	
	entity_doFriction(me, dt, 234)
	
	-- COLLISIONS
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		-- BITE NAIJA
		if entity_isState(me, STATE_ATTACK) then 
			entity_touchAvatarDamage(me, 0, 1, 800)
			v.hitNaija = 1
			
		--BUMP NAIJA
		else
			entity_touchAvatarDamage(me, 0, 0.1, 321)
		end
	end
	
	if not entity_isState(me, STATE_INTRO) then
		local r = entity_getDistanceToEntity(me, v.n)
		if r < 800 then
			musicVolume(1, 0.1)
		else
			r = 1 - ((r-800) / 1024)
			if r < 0.3 then
				r = 0.3
			end
			if r > 1 then
				r = 1
			end
			musicVolume(r)
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", LOOP_INF)
		entity_setAnimLayerTimeMult(me, 0, 1)
		
	elseif entity_isState(me, STATE_MOVE) then
		
		shakeCamera(3.4, 2.3)
		
		entity_animate(me, "crawl", LOOP_INF)
		local node = 0
		local nodeName = ""
		
		-- MOVING BETWEEN NODES w/ PATHFINDING
		if v.phase == PHASE_LURE then
			nodeName = string.format("L%d", v.lureNode)
		elseif v.phase == PHASE_HIDE then
			local rnd = math.random(9)
			while rnd == v.lastNodeNum do	-- While loops are scary
				rnd = math.random(9)
			end
			nodeName = string.format("W%d", rnd)
			v.lastNodeNum = rnd
		elseif v.phase == PHASE_FINAL then
			nodeName = "WFINAL"
			local door
			
			node = getNode("LIDOOR")
			door = node_getNearestEntity(node, "FinalDoor")
			entity_setState(door, STATE_OPENED, -1, 1)
			
			node = getNode("LIDOOR2")
			door = node_getNearestEntity(node, "FinalDoor")
			entity_setState(door, STATE_OPENED, -1, 1)
			
			playSfx("TentacleDoor")
			playSfx("CreatorForm4-hit1")
		end
		node = entity_getNearestNode(me, nodeName)
		entity_swimToNode(me, node, SPEED_FAST2)
		
	elseif entity_isState(me, STATE_TRAP) then
		entity_setMaxSpeed(me, v.maxSpeed/8)
		entity_animate(me, "idle", LOOP_INF)
		
	elseif entity_isState(me, STATE_ATTACK) then
		entity_setStateTime(me, entity_animate(me, "attack"))
		v.waitToAttack = 0
		v.hitNaija = 0
	
	elseif entity_isState(me, STATE_CHASE) then
		entity_setMaxSpeed(me, v.maxSpeed)
		local stateTime = 1.56
		shakeCamera(2.3, stateTime)
		entity_animate(me, "crawl", LOOP_INF)
		entity_setStateTime(me, stateTime)
	
	elseif entity_isState(me, STATE_CREEP) then
		entity_setMaxSpeed(me, v.maxSpeed/2)
		local stateTime = 1.2
		shakeCamera(2.1, stateTime)
		entity_animate(me, "crawl", LOOP_INF)
		entity_setStateTime(me, stateTime)
		
	elseif entity_isState(me, STATE_PAIN) then
		if chance(50) then
			playSfx("CreatorForm4-Hit1")
		else
			playSfx("CreatorForm4-Hit2")
		end
		entity_setStateTime(me, entity_animate(me, "pain"))
		
	elseif entity_isState(me, STATE_TRANSITION) then
		playSfx("CreatorForm4-Die")
		local lastNode = getNode("WFINAL")
		entity_stopInterpolating()
		
		entity_setPosition(me, node_x(lastNode), node_y(lastNode))
		entity_setPosition(me, node_x(lastNode), node_y(lastNode), 1)
		
		entity_animate(me, "idle", LOOP_INF)
		entity_rotate(me, 0, 1,0,0,1)
		entity_setStateTime(me, 1)
		
		entity_idle(v.n)
		disableInput()
		cam_toEntity(me)
	
	elseif entity_isState(me, STATE_INTRO) then
		entity_scale(me, 0, 0)
		entity_scale(me, 1, 1, 3)
		entity_animate(me, "idle")
		entity_setStateTime(me, 3)
		
		playMusic("worship3")
	end
end

function exitState(me)
	if entity_isState(me, STATE_MOVE) then
		debugLog("move state ended")
		if v.phase == PHASE_LURE then
			v.lureNode = v.lureNode + 1
			if v.lureNode > 7 then
				v.phase = PHASE_HIDE
				entity_setState(me, STATE_MOVE)
			else
				entity_setState(me, STATE_LUREWAIT)
			end
		elseif v.phase == PHASE_HIDE then
			if v.hideCount <= 0 then
				entity_setState(me, STATE_TRAP)
				v.waitToAttack = 1
				v.hideCount = 0
			else
				v.hideCount = v.hideCount - 1
				entity_setState(me, STATE_MOVE)
			end
		elseif v.phase == PHASE_FINAL then
			entity_setState(me, STATE_TRAP)
			v.waitToAttack = 1
		end
		
	elseif entity_isState(me, STATE_PAIN) then
		if v.phase == PHASE_HIDE then
			v.hideCount = 4
			entity_setState(me, STATE_MOVE)
		else
			entity_setState(me, STATE_TRAP)
		end
		
	elseif entity_isState(me, STATE_IDLE) then
		entity_setState(me, STATE_MOVE)
		
	elseif entity_isState(me, STATE_ATTACK) then
		-- POST ATTACK, MOVE OR HANG BACK?
		if v.hitNaija == 0 and entity_isEntityInRange(me, v.n, v.attackRange) then
			entity_setState(me, STATE_CREEP)
			
		elseif v.hitNaija == 0 then
			entity_setState(me, STATE_CHASE)
			
		else
			entity_setState(me, STATE_TRAP)
		end
		
	elseif entity_isState(me, STATE_CHASE) then
		if entity_isEntityInRange(me, v.n, v.chaseRange) then 
			entity_setState(me, STATE_ATTACK)
		else
			entity_setState(me, STATE_TRAP)
		end
	
	elseif entity_isState(me, STATE_CREEP) then
		entity_setState(me, STATE_ATTACK)
		
	elseif entity_isState(me, STATE_TRANSITION) then
		entity_idle(v.n)
		enableInput()
		cam_toEntity(v.n)
		
		local bx, by = bone_getWorldPosition(v.bone_darkLi)
		createEntity("CreatorForm5", "", bx, by)
		
		entity_alpha(me, 0.6, 3)
		entity_setState(me, STATE_WAIT, 6)
		
	elseif entity_isState(me, STATE_WAIT) then
		entity_delete(me, 1)
	elseif entity_isState(me, STATE_INTRO) then
		entity_setState(me, STATE_MOVE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if v.phase == PHASE_LURE then return false end
	if entity_isState(me, STATE_PAIN) then return false end
	
	if bone == v.bone_body then
		bone_damageFlash(bone)
		if v.hits1 > 0 then
			v.hits1 = v.hits1 - 1	--dmg?
			if v.hits1 <= 0 then
				v.phase = PHASE_FINAL
				entity_setState(me, STATE_MOVE)
			else
				entity_setState(me, STATE_PAIN)
			end
		elseif v.hits2 > 0 then
			v.hits2 = v.hits2 - 1 --dmg?
			if v.hits2 <= 0 then
				entity_setState(me, STATE_TRANSITION)
			else
				entity_setState(me, STATE_PAIN)
			end
		end
	end
	
	return false
end

function animationKey(me, key)
	if entity_isState(me, STATE_MOVE) or entity_isState(me, STATE_CHASE) or entity_isState(me, STATE_CREEP) then
		if key == 1 then
			local hX, hY = bone_getWorldPosition(v.bone_rightHand)
			spawnParticleEffect("CreatorForm4HandDust", hX, hY)
			hX, hY = bone_getWorldPosition(v.bone_leftHand)
			spawnParticleEffect("CreatorForm4FootDust", hX, hY)
			
			hX, hY = bone_getWorldPosition(v.bone_leftLeg1)
			spawnParticleEffect("CreatorForm4FootDust", hX, hY)
			hX, hY = bone_getWorldPosition(v.bone_leftLeg2)
			spawnParticleEffect("CreatorForm4FootDust", hX, hY)
			
			entity_sound(me, "RockHit")
			
		elseif key == 3 then
			local hX, hY = bone_getWorldPosition(v.bone_leftHand)
			spawnParticleEffect("CreatorForm4HandDust", hX, hY)
			hX, hY = bone_getWorldPosition(v.bone_rightHand)
			spawnParticleEffect("CreatorForm4FootDust", hX, hY)
			
			hX, hY = bone_getWorldPosition(v.bone_rightLeg1)
			spawnParticleEffect("CreatorForm4FootDust", hX, hY)
			hX, hY = bone_getWorldPosition(v.bone_rightLeg2)
			spawnParticleEffect("CreatorForm4FootDust", hX, hY)
			
			entity_sound(me, "RockHit")
		end
	
	elseif entity_isState(me, STATE_ATTACK) then
		if key == 3 then
			local hX, hY = bone_getWorldPosition(v.bone_leftHand)
			spawnParticleEffect("CreatorForm4FootDust", hX, hY)
			hX, hY = bone_getWorldPosition(v.bone_rightHand)
			spawnParticleEffect("CreatorForm4FootDust", hX, hY)
			
			hX, hY = bone_getWorldPosition(v.bone_leftLeg1)
			spawnParticleEffect("CreatorForm4FootDust", hX, hY)
			hX, hY = bone_getWorldPosition(v.bone_leftLeg2)
			spawnParticleEffect("CreatorForm4FootDust", hX, hY)
			hX, hY = bone_getWorldPosition(v.bone_rightLeg1)
			spawnParticleEffect("CreatorForm4FootDust", hX, hY)
			hX, hY = bone_getWorldPosition(v.bone_rightLeg2)
			spawnParticleEffect("CreatorForm4FootDust", hX, hY)
			
			entity_sound(me, "creatorform4-bite")
		end
	end
end

function hitSurface(me)
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end
