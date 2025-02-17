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
-- S E A   T U R T L E   C O M M O N
-- ================================================================================================

-- ================================================================================================
-- S T A T E S
-- ================================================================================================

local STATE_GLIDING = 1001
local STATE_TO_THRUST = 1002
local STATE_THRUSTING = 1003
local STATE_TO_GLIDE = 1004

-- ================================================================================================
-- L O C A L   V A R I A B L E S 
-- ================================================================================================

v.sz = 1
v.maxSpeed = 890

v.angle = 90

v.turtle_type = 0

v.song = nil

v.songNoteTimer = 0
v.songNoteDelay = 1.2
v.songNote = 1
v.singDelay = 0
v.singing = false

v.curRecNote = 1
v.recDelay = 0

v.follower = false
v.following = false

v.saveFlag = 0
v.saveNode = 0

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function v.commonInit(me, turType)
	v.song = { 0, 0, 0 }
	v.swimTime = 0.34 + (math.random(42)*0.01)

	setupBasicEntity(
	me,
	"SeaTurtle/Head",				-- texture
	8,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	64,								-- collideRadius (only used if hit entities is on)
	STATE_GLIDING,					-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	1800							-- updateCull -1: disabled, default: 4000
	)
	
	v.turtle_type = turType
	
	entity_setDeathParticleEffect(me, "Explode")
	entity_setDropChance(me, 21)
	
	if v.turtle_type == 2 then
		entity_initSkeletal(me, "babyturtle")
		
	elseif v.turtle_type == 4 then
		entity_initSkeletal(me, "babyturtle", "babyturtle-special1")
		v.follower = true
		v.song[1] = 0
		v.song[2] = 3
		v.song[3] = 4
		
		v.saveFlag = FLAG_MAMATURTLE_RESCUE1
		
	elseif v.turtle_type == 5 then
		entity_initSkeletal(me, "babyturtle", "babyturtle-special2")
		v.follower = true
		v.song[1] = 2
		v.song[2] = 3
		v.song[3] = 4
		
		v.saveFlag = FLAG_MAMATURTLE_RESCUE2
		
	elseif v.turtle_type == 6 then
		entity_initSkeletal(me, "babyturtle", "babyturtle-special3")
		v.follower = true
		v.song[1] = 7
		v.song[2] = 6
		v.song[3] = 2
		
		v.saveFlag = FLAG_MAMATURTLE_RESCUE3
		
	else
		entity_initSkeletal(me, "SeaTurtle")
	end
	
	if v.saveFlag ~= 0 then
		v.saveNode = getNode("TURTLESAVED")
	end
	
	v.shell = entity_getBoneByName(me, "Shell")
	
	-- MAKE BACK PARTS DARKER
	--[[backFrontFlipper = entity_getBoneByName(me, "FrontFlipperBack")
	backBackFlipper = entity_getBoneByName(me, "BackFlipperBack")
	bone_setColor(backFrontFlipper, 0.69, 0.69, 0.69)
	bone_setColor(backBackFlipper, 0.69, 0.69, 0.69)]]--
	
	entity_setCullRadius(me, 800)
	
	-- BIG
	if v.turtle_type <= 0 then
		v.sz = 1.56 + (math.random(234)*0.001)
		v.turtle_type = 0
		entity_generateCollisionMask(me)
		entity_setCullRadius(me, 1024)
	
	-- SMALL
	elseif v.turtle_type == 1 then
		v.sz = 0.76 + (math.random(234)*0.001)
	
	-- BABY
	elseif v.turtle_type == 2 then
		
		v.sz = 0.43 + (math.random(210)*0.001)
	
	-- BACKGROUND	(CRAP)
	elseif v.turtle_type == 3 then
		--v.turtle_type = 3
		v.sz = 0.23 + (math.random(210)*0.001)
		entity_color(me, 0.1, 0.1, 0.1)
		entity_alpha(me, 0.98)
		entity_setEntityLayer(me, -2)
	elseif v.turtle_type == 4 or v.turtle_type == 5 or v.turtle_type == 6 then
		-- special baby 1
		v.sz = 0.43 + ((math.random(50)+140)*0.001)
	end
	
	entity_scale(me, v.sz, v.sz)
	
	entity_setEntityType(me, ET_NEUTRAL)
	
	entity_setState(me, STATE_GLIDING)
	entity_rotateTo(me, 360, 0.1)
	entity_setMaxSpeed(me, v.maxSpeed)
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	
	entity_setEatType(me, EAT_NONE)
end

function animationKey(me, key)
end

function postInit(me)
	-- FLIP HORIZONTALLY IF THERE'S A FLIP NODE
	local node = entity_getNearestNode(me, "FLIP")
	if node ~=0 then
		if node_isEntityIn(node, me) then 
			entity_fh(me)
		end
	end
end

local function sing(me)
	v.singing = true
	v.songNote = 1
end

function update(me, dt)
		
	-- SWIM ANGLE
	
	if not v.follower then
		if entity_getState(me) == STATE_GLIDING then
			v.swimTime = v.swimTime - dt
			if v.swimTime < 0 then
				v.swimTime = 1.23 + (math.random(234)*0.01)
				
				-- Point based on Flip
				if not entity_isfh(me) then
					v.angle = 58 + math.random(64)
					entity_rotateTo(me, v.angle + 270, 2)
				else
					v.angle = 238 + math.random(64)
					entity_rotateTo(me, v.angle + 90, 2)
				end		
				
				entity_setState(me, STATE_TO_THRUST)
			end
		end
		
		-- SUBTLE GLIDE
		if entity_getState(me) == STATE_TO_THRUST then
			if not entity_isfh(me) then
				entity_moveTowardsAngle(me, entity_getRotation(me) - 270, 1, 2.48)
			else
				entity_moveTowardsAngle(me, entity_getRotation(me) - 90, 1, 2.48)
			end
		end
	end
	
	if v.following then
		if isFlag(v.saveFlag, 0) then
			entity_setTarget(me, getNaija())
			entity_setMaxSpeed(me, 500)
			if not entity_isEntityInRange(me, getNaija(), 128) then
				entity_moveTowardsTarget(me, dt, 700)
			end
			entity_rotateTo(me, 0, 0.1)
			
			if node_isEntityIn(v.saveNode, me) then
				local mamaTurtle = getEntity("mamaturtle")
				setFlag(v.saveFlag, 1)
				entity_setState(mamaTurtle, STATE_OPEN, -1, 1)
			end
		end
	end
	
	-- FLIP L/R
	local flipThresh = 50	
	if entity_velx(me) < -flipThresh and not entity_isfh(me) then
		entity_fh(me)
		v.angle = v.angle + 180
	elseif entity_velx(me) > flipThresh and entity_isfh(me) then
		entity_fh(me)
		v.angle = v.angle - 180
	end
	
	-- AVOIDANCE
	if v.following then
		entity_setCollideRadius(me, 16)
		entity_doEntityAvoidance(me, dt, 43, 0.12)
		entity_doCollisionAvoidance(me, dt, 4, 0.5)
	else
		entity_doEntityAvoidance(me, dt, 43, 0.12)
		entity_doCollisionAvoidance(me, dt, 5, 0.36)
	end
	
	-- MOVEMENT
	entity_doFriction(me, dt, 48)
	entity_updateMovement(me, dt)
	
	-- COLLISIONS
	if v.turtle_type >= 3 then
	elseif v.turtle_type == 0 then
		-- NAIJA ATTACHING TO SHELL
		
		local rideBone = entity_collideSkeletalVsCircle(me, getNaija())
		if rideBone == v.shell and avatar_isBursting() and entity_setBoneLock(getNaija(), me, rideBone) then
		
		elseif rideBone ~=0 then
			local nX, nY = entity_getPosition(getNaija())
			local bX, bY = bone_getWorldPosition(rideBone)
			nX = nX - bX
			nY = nY - bY
			nX, nY = vector_setLength(nX, nY, 600)
			entity_addVel(getNaija(), nX, nY)
		end
		
		entity_handleShotCollisionsSkeletal(me)
		
	elseif v.turtle_type == 1 then
		entity_touchAvatarDamage(me, 67 * v.sz, 0, 420)
		entity_handleShotCollisions(me)
	end
	
	
	if v.follower then
		if not v.following and entity_isEntityInRange(me, getNaija(), 512) then
			musicVolume(0.5, 0.2)
		else
			musicVolume(1.0, 0.2)
		end
		if v.recDelay > 0 then
			v.recDelay = v.recDelay - dt
			if v.recDelay < 0 then
				v.recDelay = 0
				v.curRecNote = 1
			end
		end
		if not v.following then
			if entity_isEntityInRange(me, getNaija(), 800) then
				if v.singing then
					v.songNoteTimer = v.songNoteTimer + dt
					if v.songNoteTimer > v.songNoteDelay then
						--playSfx(getNoteName(v.song[v.songNote]), 
						entity_sound(me, getNoteName(v.song[v.songNote], "low-"), 1, 2)
						v.songNote = v.songNote + 1
						if v.songNote > 3 then
							v.singing = false
						end
						v.songNoteTimer = 0
						v.singDelay = 3
					end
				else
					v.singDelay = v.singDelay - dt
					if v.singDelay < 0 then
						v.singDelay = 0
						sing(me)
					end
				end
			end
		end
	end
end

function enterState(me)
	if entity_getState(me) == STATE_GLIDING then
		entity_animate(me, "glide", LOOP_INF)
		
	elseif entity_getState(me) == STATE_TO_THRUST then
		entity_setStateTime(me, entity_animate(me, "tothrust"), -1)
		
	elseif entity_getState(me) == STATE_THRUSTING then
		entity_setStateTime(me, entity_animate(me, "thrust"), -1)
		
	elseif entity_getState(me) == STATE_TO_GLIDE then
		entity_setStateTime(me, entity_animate(me, "toglide"), -1)
		
	end
end

function exitState(me)
	if entity_getState(me) == STATE_GLIDING then
	
	elseif entity_getState(me) == STATE_TO_THRUST then
		entity_setState(me, STATE_THRUSTING)
		
	elseif entity_getState(me) == STATE_THRUSTING then
		-- THRUST
		entity_moveTowardsAngle(me, v.angle, 1, 124 + math.random(124))
		entity_setState(me, STATE_TO_GLIDE)
		local shellX, shellY = bone_getWorldPosition(v.shell)
		spawnParticleEffect("SeaTurtleBubbles", shellX, shellY)
		
	elseif entity_getState(me) == STATE_TO_GLIDE then
		entity_setState(me, STATE_GLIDING)
		
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		playNoEffect()
		return false
	end
	return true
end

local function startFollowing(me)
	v.following = true
end

function songNoteDone(me, note, t)
	if v.follower and not v.following then
		if t >= 0.2 and note == v.song[v.curRecNote] then
			v.recDelay = 2
			v.curRecNote = v.curRecNote + 1
			if v.curRecNote > 3 then
				startFollowing(me)
			end
		else
			v.recDelay = 0.1
			v.curRecNote = 1
		end
	end
end

function hitSurface(me)
end

