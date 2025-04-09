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
-- C R E A T O R ,   F O R M   3   (alpha)
-- ================================================================================================

-- ================================================================================================
-- D E B U G   J U N K
-- ================================================================================================

v.current_target = 0
v.last_node = 0
v.node_before_that = 0

-- ================================================================================================
-- S T A T E S
-- ================================================================================================

local STATE_INTRO = 1001
local STATE_PATTERN_01 = 1002
local STATE_SWIMMING = 1003
local STATE_AVOIDING_WALLS = 1004

-- ================================================================================================
-- L O C A L   V A R I A B L E S
-- ================================================================================================

v.angle = 0
v.rotateSpeed = 0.76

v.moveSpeed = 418 * 2

v.turnTimer = 0
v.turnT = 1
v.v.n = 0

v.killedSegs = 0

-- ================================================================================================
-- S E G M E N T   D A T A
-- ================================================================================================

v.bone_seg = {0, 0, 0, 0, 0, 0, 0, 0}		-- Bone
v.mouth_seg = {0, 0, 0, 0, 0, 0, 0, 0}

v.shotT = 2

v.health_seg = {3, 3, 3, 3, 3, 3, 3, 3}

v.faceFrame_seg = {0, 0, 0, 0, 0, 0, 0, 0}

v.flipT = 0.42
v.flipTimer_seg = {0, 0, 0, 0, 0, 0, 0, 0}

-- ================================================================================================
-- N O D E S
-- ================================================================================================

v.targetNode = 0

v.A1 = 0
v.A2 = 0
v.B1 = 0
v.B2 = 0
v.B3 = 0
v.B4 = 0
v.C1 = 0
v.C2 = 0
v.C3 = 0
v.C4 = 0
v.C5 = 0
v.D1 = 0
v.D2 = 0
v.D3 = 0
v.D4 = 0

-- ================================================================================================
-- M Y   F U N C T I O N S
-- ================================================================================================

local function changeAngle(me)
	v.angle = entity_getRotation(me)
	v.angle = v.angle + math.random(110) - 55
	
	entity_rotateTo(me, v.angle, v.turnT)
end

local function rotateToNode(me, node)
	local ndX, ndY = node_getPosition(node)
	local meX, meY = entity_getPosition(me)
	local vecX = (ndX - meX)
	local vecY = (ndY - meY)
	vecX, vecY = vector_cap(vecX, vecY, 512)
	entity_rotateToVec(me, vecX, vecY, v.rotateSpeed)
end

-- NODE LIST
local function loadNodes(me)
	v.targetNode = entity_getNearestNode(me, "C2")
	
	v.A1 = entity_getNearestNode(me, "A1")
	v.A2 = entity_getNearestNode(me, "A2")
	v.B1 = entity_getNearestNode(me, "B1")
	v.B2 = entity_getNearestNode(me, "B2")
	v.B3 = entity_getNearestNode(me, "B3")
	v.B4 = entity_getNearestNode(me, "B4")
	v.C1 = entity_getNearestNode(me, "C1")
	v.C2 = entity_getNearestNode(me, "C2")
	v.C3 = entity_getNearestNode(me, "C3")
	v.C4 = entity_getNearestNode(me, "C4")
	v.C5 = entity_getNearestNode(me, "C5")
	v.D1 = entity_getNearestNode(me, "D1")
	v.D2 = entity_getNearestNode(me, "D2")
	v.D3 = entity_getNearestNode(me, "D3")
	v.D4 = entity_getNearestNode(me, "D4")
end

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	v.shotTimer_seg = {math.random(8)*0.5, math.random(8)*0.5, math.random(8)*0.5, math.random(8)*0.5, math.random(8)*0.5, math.random(8)*0.5, math.random(8)*0.5, math.random(8)*0.5}
	--v.shotTimer_seg = {3, 3, 3, 3, 3, 3, 3, 3}

	setupBasicEntity(
	me,
	"Creator/Form3/Head",			-- texture
	64,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	256,							-- sprite width
	256,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	6000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setDeathParticleEffect(me, "Explode")
	entity_setDropChance(me, 21)
	
	entity_initSkeletal(me, "CreatorForm3")
	entity_generateCollisionMask(me)
	v.head = entity_getBoneByName(me, "Head")
	v.jaw = entity_getBoneByName(me, "Jaw")
	v.tail = entity_getBoneByName(me, "Tail")
	
	-- BODY SEGS
	v.bone_seg[1] = entity_getBoneByName(me, "BodySeg1")
	v.mouth_seg[1] = entity_getBoneByName(me, "MouthSeg1")
	bone_alpha(v.mouth_seg[1], 0)
	v.bone_seg[2] = entity_getBoneByName(me, "BodySeg2")
	v.mouth_seg[2] = entity_getBoneByName(me, "MouthSeg2")
	bone_alpha(v.mouth_seg[2], 0)
	v.bone_seg[3] = entity_getBoneByName(me, "BodySeg3")
	v.mouth_seg[3] = entity_getBoneByName(me, "MouthSeg3")
	bone_alpha(v.mouth_seg[3], 0)
	v.bone_seg[4] = entity_getBoneByName(me, "BodySeg4")
	v.mouth_seg[4] = entity_getBoneByName(me, "MouthSeg4")
	bone_alpha(v.mouth_seg[4], 0)
	v.bone_seg[5] = entity_getBoneByName(me, "BodySeg5")
	v.mouth_seg[5] = entity_getBoneByName(me, "MouthSeg5")
	bone_alpha(v.mouth_seg[5], 0)
	v.bone_seg[6] = entity_getBoneByName(me, "BodySeg6")
	v.mouth_seg[6] = entity_getBoneByName(me, "MouthSeg6")
	bone_alpha(v.mouth_seg[6], 0)
	v.bone_seg[7] = entity_getBoneByName(me, "BodySeg7")
	v.mouth_seg[7] = entity_getBoneByName(me, "MouthSeg7")
	bone_alpha(v.mouth_seg[7], 0)
	v.bone_seg[8] = entity_getBoneByName(me, "BodySeg8")
	v.mouth_seg[8] = entity_getBoneByName(me, "MouthSeg8")
	bone_alpha(v.mouth_seg[8], 0)
	
	entity_setCull(me, false)
	
	entity_setMaxSpeed(me, v.moveSpeed)
	
	-- Don't collide with the level.  Hm.
	--esetv(me, EV_COLLIDELEVEL, 0)
	
	-- SEGMENT TAIL
	bone_setSegmentChainHead(v.head, true)
	bone_setSegmentProps(v.head, 154, 154, true)
	for i=10,2,-1 do
		local b = entity_getBoneByIdx(me, i)
		bone_addSegment(v.head, b)
		bone_rotateOffset(b, -90)
	end
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, getNaija())
	
	entity_setState(me, STATE_INTRO)
	
	entity_scale(me, 0, 0)
	
	-- NODE LIST
	loadNodes(me)
	
	v.current_target = v.targetNode
	v.last_node = v.targetNode
	v.node_before_that = v.targetNode
	

end

function update(me, dt)

	dt = dt * 2

	-- DEBUG:  WHERE IS WORMY GOING??
	if v.current_target ~= v.targetNode then
		v.node_before_that = v.last_node
		v.last_node = v.current_target
		v.current_target = v.targetNode
		
		debugLog(string.format("- - - "))
		debugLog(string.format("Current Target: %s", node_getName(v.current_target)))
		debugLog(string.format("Last Node: %s", node_getName(v.last_node)))
		debugLog(string.format("Node Before That: %s", node_getName(v.node_before_that)))
	end
	
	-- S E G M E N T   L O O P
	for i=1,8 do
		local segX, segY = bone_getWorldPosition(v.bone_seg[i])
		local mouthX, mouthY = bone_getWorldPosition(v.mouth_seg[i])
		
		if v.health_seg[i] > 0 then
			-- SHOOTING
			v.shotTimer_seg[i] = v.shotTimer_seg[i] - dt
			if v.shotTimer_seg[i] <= 0 then
				v.shotTimer_seg[i] = v.shotT + (math.random(200) * 0.01)
				
				local nX, nY = bone_getNormal(v.bone_seg[i])
				nX, nY = vector_setLength(nX, nY, 123)

				spawnParticleEffect("CreatorForm3Shot1", mouthX, mouthY)
				local s = createShot("CreatorForm3Shot1", me, 0, mouthX, mouthY)
				shot_setAimVector(s, -nX, -nY)
			end
			
		else -- If no health
			local numFlipFrames = 3
			-- FLIP FACES
			if v.faceFrame_seg[i] < numFlipFrames then
			
				v.flipTimer_seg[i] = v.flipTimer_seg[i] - dt
				if v.flipTimer_seg[i] <= 0 then
					v.flipTimer_seg[i] = v.flipT
					
					v.faceFrame_seg[i] = v.faceFrame_seg[i] + 1
					
					bone_setTexture(v.bone_seg[i], string.format("Creator/Form3/BodySegFlip%d", v.faceFrame_seg[i]))
				end
			else
				v.flipTimer_seg[i] = 0
				v.faceFrame_seg[i] = numFlipFrames
			end
		end
		-- RANDOM BUBBLES
		if chance(2) then
			spawnParticleEffect("CreatorForm3LiteBubbles", segX, segY)
		end
	end
	
	

	if entity_getState(me) == STATE_INTRO then
		entity_addVel(me, 0, -32)
		
	elseif entity_getState(me) == STATE_PATTERN_01 then
		overrideZoom(0.42)
		
	-------------------------------------------------------------------------------------------------
	-- N O D E   C O D E
	-------------------------------------------------------------------------------------------------
	--[[
		-- v.A1
		if v.A1 == v.targetNode and v.A1 ~=0 and node_isEntityIn(v.A1, me) then
			if entity_velx(me) < 0 then
				if chance(25) then v.targetNode = entity_getNearestNode(me, "C1")
				elseif chance(25) then v.targetNode = entity_getNearestNode(me, "D1")
				elseif chance(25) then v.targetNode = entity_getNearestNode(me, "C2")
				else v.targetNode = entity_getNearestNode(me, "B1") end
			else
				if chance(25) then v.targetNode = entity_getNearestNode(me, "C4")
				elseif chance(25) then v.targetNode = entity_getNearestNode(me, "B4")
				elseif chance(25) then v.targetNode = entity_getNearestNode(me, "D4")
				else v.targetNode = entity_getNearestNode(me, "D3") end	-- v.C5
			end
		-- v.A2
		elseif  v.A2 == v.targetNode and  v.A2 ~=0 and node_isEntityIn(v.A2, me) then 
			if entity_velx(me) < 0 then
				if chance(33.3) then v.targetNode = entity_getNearestNode(me, "B1")
				elseif chance(33.3) then v.targetNode = entity_getNearestNode(me, "C1")
				else v.targetNode = entity_getNearestNode(me, "C2") end
			else
				if chance(33.3) then v.targetNode = entity_getNearestNode(me, "D4")
				elseif chance(33.3) then v.targetNode = entity_getNearestNode(me, "B4")
				else v.targetNode = entity_getNearestNode(me, "C5") end
			end
		-- v.B1
		elseif  v.B1 == v.targetNode and  v.B1 ~=0 and node_isEntityIn(v.B1, me) then 
			if entity_vely(me) > 0 then
				if chance(33.3) then v.targetNode = entity_getNearestNode(me, "D3")
				elseif chance(33.3) then v.targetNode = entity_getNearestNode(me, "D1")	-- BUMP?
				else v.targetNode = entity_getNearestNode(me, "C1") end
			else
				if chance(33.3) then v.targetNode = entity_getNearestNode(me, "B3")
				elseif chance(33.3) then v.targetNode = entity_getNearestNode(me, "A2")
				else v.targetNode = entity_getNearestNode(me, "C3") end
			end
		-- v.B2
		elseif  v.B2 == v.targetNode and  v.B2 ~=0 and node_isEntityIn(v.B2, me) then 
			if entity_velx(me) < 0 then
				if chance(50) then v.targetNode = entity_getNearestNode(me, "C1")
				else v.targetNode = entity_getNearestNode(me, "D2") end
			else
				if chance(33.3) then v.targetNode = entity_getNearestNode(me, "D4")
				elseif chance(33.3) then v.targetNode = entity_getNearestNode(me, "C5")
				else v.targetNode = entity_getNearestNode(me, "B4") end
			end
		-- v.B3
		elseif  v.B3 == v.targetNode and  v.B3 ~=0 and node_isEntityIn(v.B3, me) then 
			if entity_velx(me) > 0 then
				if chance(50) then v.targetNode = entity_getNearestNode(me, "C5")
				else v.targetNode = entity_getNearestNode(me, "D4") end
			else
				if chance(50) then v.targetNode = entity_getNearestNode(me, "C2")
				else v.targetNode = entity_getNearestNode(me, "B1") end
			end
		-- v.B4
		elseif  v.B4 == v.targetNode and  v.B4 ~=0 and node_isEntityIn(v.B4, me) then 
			if entity_vely(me) > 0 then
				if chance(50) then v.targetNode = entity_getNearestNode(me, "D4")
				else v.targetNode = entity_getNearestNode(me, "D3") end
			else
				if entity_velx(me) < 0 then
					v.targetNode = entity_getNearestNode(me, "B1")
				else
					v.targetNode = entity_getNearestNode(me, "B2")
				end
			end
		-- v.C1
		elseif  v.C1 == v.targetNode and  v.C1 ~=0 and node_isEntityIn(v.C1, me) then 
			if entity_vely(me) >= 0 then
				if chance(50) then v.targetNode = entity_getNearestNode(me, "D3")
				else v.targetNode = entity_getNearestNode(me, "C5") end	--v.D4?
			else
				if chance(20) then v.targetNode = entity_getNearestNode(me, "B3")
				elseif chance(20) then v.targetNode = entity_getNearestNode(me, "C4")
				elseif chance(20) then v.targetNode = entity_getNearestNode(me, "B1")
				elseif chance(20) then v.targetNode = entity_getNearestNode(me, "A2")
				else v.targetNode = entity_getNearestNode(me, "A1") end
			end
		-- v.C2
		elseif  v.C2 == v.targetNode and  v.C2 ~=0 and node_isEntityIn(v.C2, me) then 
			if entity_vely(me) > 0 then
				if entity_velx(me) > 0 then
					v.targetNode = entity_getNearestNode(me, "B4")
				else
					if chance(50) then v.targetNode = entity_getNearestNode(me, "C1")
					else v.targetNode = entity_getNearestNode(me, "B1") end	-- trouble?
				end
			else
				if chance(33.3) then v.targetNode = entity_getNearestNode(me, "B3")
				elseif chance(33.3) then  v.targetNode = entity_getNearestNode(me, "A2")
				else v.targetNode = entity_getNearestNode(me, "B4") end
			end
		-- v.C3
		elseif  v.C3 == v.targetNode and  v.C3 ~=0 and node_isEntityIn(v.C3, me) then 
			if entity_velx(me) > 0 then
				if entity_vely(me) < 0 then
					if chance(33.3) then v.targetNode = entity_getNearestNode(me, "B4")
					elseif chance(33.3) then  v.targetNode = entity_getNearestNode(me, "C5")
					else v.targetNode = entity_getNearestNode(me, "A2") end	--trouble?
				else
					if chance(50) then v.targetNode = entity_getNearestNode(me, "C1")
					else v.targetNode = entity_getNearestNode(me, "C5") end
				end
			else
				if entity_vely(me) < 0 then
					if chance(50) then v.targetNode = entity_getNearestNode(me, "B1")
					else v.targetNode = entity_getNearestNode(me, "B4") end
				else
					if chance(50) then v.targetNode = entity_getNearestNode(me, "D2")
					else v.targetNode = entity_getNearestNode(me, "C1") end	--trouble?
				end
			end
		-- v.C4
		elseif v.C4 == v.targetNode and v.C4 ~=0 and node_isEntityIn(v.C4, me) then 
			if entity_vely(me) > 0 then
				v.targetNode = entity_getNearestNode(me, "D4")	--v.D2?
			else
				v.targetNode = entity_getNearestNode(me, "A1")
			end
		-- v.C5
		elseif v.C5 == v.targetNode and v.C5 ~=0 and node_isEntityIn(v.C5, me) then 
			if entity_vely(me) < 0 then
				if chance(33.3) then v.targetNode = entity_getNearestNode(me, "A1") 
				elseif chance(33.3) then v.targetNode = entity_getNearestNode(me, "A2") 
				else v.targetNode = entity_getNearestNode(me, "B4") end
			else
				if entity_velx(me) > 0 then		-- I F F Y
					v.targetNode = entity_getNearestNode(me, "D4")
					--if chance(50) then v.targetNode = entity_getNearestNode(me, "D4")
					--else v.targetNode = entity_getNearestNode(me, "D2") end	-- Aaarrrggghhh
				else
					if chance(50) then v.targetNode = entity_getNearestNode(me, "D1")
					else v.targetNode = entity_getNearestNode(me, "D2") end
				end
			end
		-- v.D1
		elseif v.D1 == v.targetNode and v.D1 ~=0 and node_isEntityIn(v.D1, me) then 
			if entity_vely(me) < 0 then
					v.targetNode = entity_getNearestNode(me, "B2")
			else
				if entity_velx(me) > 0 then
					v.targetNode = entity_getNearestNode(me, "C3")		-- BIG trouble!
				else
					v.targetNode = entity_getNearestNode(me, "B1")
				end
			end
		-- v.D2
		elseif v.D2 == v.targetNode and v.D2 ~=0 and node_isEntityIn(v.D2, me) then 
			if entity_velx(me) < 0 then
				v.targetNode = entity_getNearestNode(me, "C1")
			else
				if chance(33.3) then v.targetNode = entity_getNearestNode(me, "C5")
				elseif chance(33.3) then v.targetNode = entity_getNearestNode(me, "C4")
				else v.targetNode = entity_getNearestNode(me, "B4") end
			end
		-- v.D3
		elseif v.D3 == v.targetNode and v.D3 ~=0 and node_isEntityIn(v.D3, me) then 
			if entity_velx(me) > 0 then
				v.targetNode = entity_getNearestNode(me, "C5")
			else
				v.targetNode = entity_getNearestNode(me, "C1")
			end
		-- v.D4
		elseif v.D4 == v.targetNode and v.D4 ~=0 and node_isEntityIn(v.D4, me) then 
			if entity_vely(me) > 0 then
				if entity_velx(me) < 0 then
					if chance(33.3) then v.targetNode = entity_getNearestNode(me, "D2")
					elseif chance(33.3) then v.targetNode = entity_getNearestNode(me, "B1")
					else v.targetNode = entity_getNearestNode(me, "D1") end
				else
					v.targetNode = entity_getNearestNode(me, "B3")
				end
			else
				if chance(50) then v.targetNode = entity_getNearestNode(me, "B4")
				else v.targetNode = entity_getNearestNode(me, "A2") end
			end
		end
		]]--
		
		local entNode = entity_getNearestNode(v.n, "WORM")
		v.targetNode = entNode
		
		-- TURN TO NEXT NODE
		rotateToNode(me, v.targetNode)
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	-------------------------------------------------------------------------------------------------
	
		entity_moveTowardsAngle(me, entity_getRotation(me), dt, v.moveSpeed)
		
		entity_doCollisionAvoidance(me, dt, 10, 0.1)
		
	elseif entity_getState(me) == STATE_SWIMMING then
		
		-- TURN TIMER
		if v.turnTimer > 0 then v.turnTimer = v.turnTimer - dt
		else
			v.turnTimer = v.turnT
				
			changeAngle(me)
		end
		
		entity_moveTowardsAngle(me, entity_getRotation(me), dt, v.moveSpeed)
		
		-- AVOID WALLS
		local cX, cY = entity_getPosition(me)
		local wallX, wallY = getWallNormal(entity_x(me), entity_y(me), 24)
		--debugLog(string.format("wall(%d, %d", wallX, wallY))
		if wallX ~= 0 or wallY ~= 0 then 
			entity_setState(me, STATE_AVOIDING_WALLS)
			
			v.turnTimer = v.turnT
			entity_setMaxSpeed(me, v.moveSpeed/2)
			
			cX = cX + wallX*256
			cY = cY + wallY*256
			--createShot("DropShot", me, 0, cX, cY)
			--entity_clearVel(me)
			--entity_moveTowards(me, cX, cY, 1, 1234)
			
			local meX, meY = entity_getPosition(me)
			local vX = (cX - meX)
			local vY = (cY - meY)
			vX, vY = vector_cap(vX, vY, 32)
			entity_rotateToVec(me, vX, vY, v.rotateSpeed)
		end
		
		-- AVOID TAIL
		local tX, tY = bone_getWorldPosition(v.tail)
		local hX, hY = bone_getWorldPosition(v.head)
		local vX = hX - tX
		local vY = hY - tY
		if vector_isLength2DIn(vX, vY, 123) then
			entity_moveTowards(me, tX, tY, dt, -1234)
		end
	
	elseif entity_getState(me) == STATE_AVOIDING_WALLS then
		entity_moveTowardsAngle(me, entity_getRotation(me), dt, v.moveSpeed)
	end

	-- UPDATE EVERYTHING
	entity_doEntityAvoidance(me, dt, 32, 2)
	entity_doFriction(me, dt, 64)
	entity_updateMovement(me, dt)
	
	-- COLLISIONS
	local hitBone = entity_collideSkeletalVsCircle(me, getNaija())
	
	-- Do shot collisions
	entity_handleShotCollisionsSkeletal(me)
	
	-- Hurt Naija if Head, Jaw, or Tail is hit
	if hitBone == v.jaw or hitBone == v.tail then
		entity_damage(getNaija(), me, 0.1, DT_ENEMY_BITE)
	end
	
	-- Attach Naija to Back
	if hitBone ~= 0 and hitBone ~= v.jaw and hitBone ~= v.tail and avatar_isBursting() and entity_setBoneLock(getNaija(), me, hitBone) then
	
	-- Bump Naija away
	elseif hitBone ~= 0 then
		local nX, nY = entity_getPosition(getNaija())
		local bX, bY = bone_getWorldPosition(hitBone)
		nX = nX - bX
		nY = nY - bY
		nX, nY = vector_setLength(nX, nY, 600)
		entity_addVel(getNaija(), nX, nY)
	end
	
	entity_clearTargetPoints(me)
	
	for i=1,8 do
		local x,y = bone_getWorldPosition(v.bone_seg[i])
		entity_addTargetPoint(me, x, y)
	end
end

function enterState(me)
	if entity_getState(me) == STATE_INTRO then
		local stateTime = 1
		
		entity_setMaxSpeed(me, v.moveSpeed/4)
		
		entity_animate(me, "idle", LOOP_INF)
		
		entity_setStateTime(me, stateTime)
		entity_scale(me, 1, 1, stateTime)
		
	elseif entity_getState(me) == STATE_PATTERN_01 then
		entity_setMaxSpeed(me, v.moveSpeed/2)
		
	elseif entity_getState(me) == STATE_SWIMMING then
		entity_setMaxSpeed(me, v.moveSpeed/2)
		v.turnTimer = v.turnT
			
	elseif entity_getState(me) == STATE_AVOIDING_WALLS then
		entity_setStateTime(me, 3)
		
	elseif entity_isState(me, STATE_TRANSITION) then
		entity_setAllDamageTargets(me, false)
		
		entity_idle(v.n)
		disableInput()
		entity_setInvincible(v.n, true)
		cam_toEntity(me)
		
		local node = entity_getNearestNode(me, "CENTER")
		entity_setPosition(me, node_x(node), node_y(node), 3, 0, 0, 1)	
		entity_setStateTime(me, 2)
	end
end

function exitState(me)
	if entity_getState(me) == STATE_INTRO then
		entity_setState(me, STATE_PATTERN_01)
		
	elseif entity_getState(me) == STATE_SWIMMING then
	
	elseif entity_getState(me) == STATE_AVOIDING_WALLS then
		entity_setState(me, STATE_SWIMMING)
		v.angle = entity_getRotation(me)
		entity_rotateTo(me, v.angle, 0.1)
		
	elseif entity_isState(me, STATE_TRANSITION) then
		local bx, by = bone_getWorldPosition(v.tail)
		local ent = createEntity("CreatorForm4", "", bx, by)
		entity_setState(me, STATE_WAIT, 2)
		cam_toEntity(ent)
	elseif entity_isState(me, STATE_WAIT) then
		entity_delete(me)
		enableInput()
		entity_setInvincible(v.n, false)
		cam_toEntity(v.n)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	for i=1,8 do
		if bone == v.bone_seg[i] and v.faceFrame_seg[i] == 0 and v.health_seg[i] > 0 then
			local bnx, bny = bone_getNormal(v.bone_seg[i])
			local bx, by = bone_getWorldPosition(v.bone_seg[i])
			local sx, sy = getLastCollidePosition()
			local nx = bx - sx
			local ny = by - sy
			nx, ny = vector_setLength(nx, ny, 1)
			--local dot = vector_dot(bnx, bny, nx, ny)
			local dot = 0
			debugLog(string.format("boneNormal(%d, %d) vs shotNormal(%d, %d) dot: %d", bnx, bny, nx, ny, dot))
			if dot > 0 then
				v.health_seg[i] = v.health_seg[i] - 1
				bone_damageFlash(bone)
			end
		end
		
		if v.health_seg[i] <= 0 and v.faceFrame_seg[i] == 0 then
			v.faceFrame_seg[i] = 1
			v.flipTimer_seg[i] = v.flipT
			v.health_seg[i] = 0
			v.killedSegs = v.killedSegs + 1
			if v.killedSegs >= 8 then
				entity_setState(me, STATE_TRANSITION)
			end
		end
	end

	return false
end

function hitSurface(me)
	
end
