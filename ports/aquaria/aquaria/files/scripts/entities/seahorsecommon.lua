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

--SeaHorse

-- specific
local STATE_JUMP			= 1000
local STATE_TRANSITION		= 1001
local STATE_RETURNTOWALL	= 1002
local STATE_SURFACE			= 1003

v.moveTimer = 0
v.moveDir = 0
v.avoidCollisionsTimer = 0
v.riding = false

v.noteDown = -1
v.dirx = 0
v.diry = 0
v.wasUnderWater = true

v.racePath = 0
v.curNode = 0

v.startx = 0
v.starty = 0

v.wasInCurrent = false

v.n = 0

v.naijaRideAnim = -1

local RIDEANIM_NORMAL 		= 0
local RIDEANIM_SLOW 			= 1
local RIDEANIM_OUTOFWATER		= 2

v.waiting = false

v.incut = false

v.seahorseCostume = false

function v.commonInit(me, tex, sz)
	if sz == 0 then
		sz = 50
	end
	setupBasicEntity(
	me,
	tex,							-- texture
	12,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	sz,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	256,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000,							-- updateCull -1: disabled, default: 4000
	0
	)
	
	loadSound("SeahorseWhinny")
	
	entity_setName(me, "Seahorse")

	entity_setMaxSpeed(me, 200)
	--entity_clampToSurface(me)
	entity_setState(me, STATE_IDLE)
	entity_setDropChance(me, 10)
	
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	
	entity_offset(me, 0, -40, 1, -1, 1, 1)
	entity_setSegs(me, 2, 30, 0.5, 0.3, -0.018, 0, 6, 1)
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setCanLeaveWater(me, true)
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	v.n = getNaija()
	v.startx = entity_x(me)
	v.starty = entity_y(me)
	entity_update(me, math.random(100)/100.0)
end

local function setRideSpeed(me)
	if not entity_isUnderWater(me) then
		entity_setMaxSpeedLerp(me, 8)
	elseif entity_isState(me, STATE_RACE) then
		entity_setMaxSpeedLerp(me, 3.4, 1)
	else
		if getCostume() == "seahorse" then
			v.seahorseCostume = true
			entity_setMaxSpeedLerp(me, 5.5, 1)
		else
			v.seahorseCostume = false
			entity_setMaxSpeedLerp(me, 3.5, 1)
		end
	end
end

local function updateRideAnim(me, num)
	if v.naijaRideAnim ~= num then
		if num == RIDEANIM_NORMAL then
			entity_animate(v.n, "rideSeaHorse", LOOP_INF, LAYER_OVERRIDE)
		elseif num == RIDEANIM_SLOW then
			entity_animate(v.n, "rideSeaHorse2", LOOP_INF, LAYER_OVERRIDE)
		elseif num == RIDEANIM_OUTOFWATER then
			entity_animate(v.n, "rideSeaHorse3", LOOP_INF, LAYER_OVERRIDE)
		end
		v.naijaRideAnim = num
	end
end

local function getRidePosition(me)
	local x, y = entity_getPosition(me)
	local ox, oy = entity_getOffset(me)
	x = x + ox
	y = y + oy
	local offx = 32
	if entity_isFlippedHorizontal(me) then
		-- facing right
		offx = -offx
	end
	x = x+offx
	y = y-10
	return x, y
end

local function startRide(me)
	v.incut = true
	debugLog("start ride")
	setRideSpeed(me)

	entity_setInvincible(me, true)
	entity_setInvincible(v.n, true)
	entity_clearVel(me)
	entity_clearVel(v.n)
	
	
	v.waiting = true
	
	entity_idle(v.n)
	entity_animate(v.n, "pushForward")
	entity_flipToEntity(v.n, me)
	watch(0.2)
	entity_clearVel(v.n)
	local x, y = getRidePosition(me)
	entity_setPosition(v.n, x, y, 1, 0, 0, 0)
	watch(1)

	v.riding = true
	--entity_animate(v.n, "rideSeaHorse", LOOP_INF, LAYER_OVERRIDE)
	v.naijaRideAnim = -1
	updateRideAnim(me, RIDEANIM_NORMAL)
	
	-- zoomsurface
	--setCanWarp(false)
	entity_setRiding(getNaija(), me)
	
	
	local x, y = getRidePosition(me)
	entity_setRidingData(me, x, y, entity_getRotation(me), entity_isfh(me))
	
	entity_setInvincible(me, false)
	entity_setInvincible(v.n, false)
	
	v.waiting = false
	
	entity_sound(me, "SeahorseWhinny")
	
	setCameraLerpDelay(0.05)
	
	cam_toEntity(me)
	
	v.incut = false
end

local function stopRide(me)
	debugLog("stop ride")
	if v.riding then
		entity_sound(me, "SeahorseWhinny")
	
		--if entity_isUnderWater(me) then
			overrideZoom(0)
			v.riding = false
			entity_stopAllAnimations(v.n)
			entity_idle(v.n)
			--setCanWarp(true)
			entity_setRiding(v.n, 0)
			entity_addVel(v.n, entity_velx(me), entity_vely(me))
			if not entity_isUnderWater(v.n) then
				entity_animate(v.n, "burst")
			else
				entity_setMaxSpeedLerp(me, 1, 1)
			end
		--end
		
		setCameraLerpDelay(0)
		
		cam_toEntity(getNaija())
	end
end

function activate(me)
	if v.incut then return end
	--debugLog("activate")
	if avatar_isOnWall() then return end
	if v.riding then
		stopRide(me)
	else
		startRide(me)
	end
end

function update(me, dt)
	if isForm(FORM_NORMAL) then
		entity_setActivation(me, AT_CLICK, 64, 512)
	else
		entity_setActivation(me, AT_NONE)
		if v.riding then
			stopRide(me)
		end
	end


	--if not entity_isNearObstruction(me, 3) then
	local inCurrent = false
	if v.riding then
		inCurrent = entity_updateCurrents(me, dt)
		if (inCurrent and not v.wasInCurrent) then
			-- start boost anim
		elseif (not inCurrent and v.wasInCurrent) then
			-- end boost anim
		end
	end
	
	if not v.seahorseCostume then
		if inCurrent then
			entity_setMaxSpeed(me, 150)
		else
			entity_setMaxSpeed(me, 200)
		end
	else
		entity_setMaxSpeed(me, 200)
	end
	
	v.wasInCurrent = inCurrent
	
	if v.riding then
		if entity_getRiding(getNaija())==0 then
			stopRide(me)
		else
			overrideZoom(0.55, 0.5)
		end
		esetv(me, EV_LOOKAT, 0)
	else
		esetv(me, EV_LOOKAT, 1)
	end
	
	if v.riding == true or entity_isState(me, STATE_RACE) then
		local e = getFirstEntity()
		while e~=0 do
			if e~=me and entity_isName(e, "Seahorse") then
				if entity_isEntityInRange(me, e, 64) then
					local dx, dy = entity_getVectorToEntity(me, e)
					dx, dy = vector_setLength(dx, dy, 1000)
					entity_addVel(e, dx, dy)
				end
			end
			e = getNextEntity()
		end
	end
	
	if entity_checkSplash(me) then
		if not entity_isUnderWater(me) then
			--//entity_setMaxSpeed(me, outOfWaterSpeed)
			--entity_setMaxSpeedLerp(me, 2, 0.1)
			setRideSpeed(me)
			--end
			--entity_addVel(me, 0, -2000)
			local vx = entity_velx(me)
			local vy = entity_vely(me)
			vx, vy = vx*4, vy*4
			vx, vy = vector_cap(vx, vy, 1100)
			entity_clearVel(me)
			entity_addVel(me, vx, vy)
			
			entity_setWeight(me, 800)
			--entity_sound(me, "splash-outof")
		else
			setRideSpeed(me)
			--entity_setMaxSpeedLerp(me, 1, 0.8)
			if not v.riding then
				entity_setMaxSpeedLerp(me, 1, 1)
			else			
				setRideSpeed(me)
			end
			entity_setWeight(me, 0)
			--entity_sound(me, "splash-into")
		end
	end
	--[[
	if entity_isUnderWater(me) ~= v.wasUnderWater then
		v.wasUnderWater = entity_isUnderWater(me)
		
		spawnParticleEffect("Splash", entity_x(me), entity_y(me))
		if not entity_isUnderWater(me) then
			--//entity_setMaxSpeed(me, outOfWaterSpeed)
			--entity_setMaxSpeedLerp(me, 2, 0.1)
			entity_addVel(me, 0, -1000)
			entity_setWeight(me, 800)			
			entity_sound(me, "splash-outof")
		else
			--entity_setMaxSpeedLerp(me, 1, 0.8)
			entity_setWeight(me, 0)
			entity_sound(me, "splash-into")
		end
	end	
	]]--
	if entity_isState(me, STATE_IDLE) then
		if not v.riding then
			v.avoidCollisionsTimer = v.avoidCollisionsTimer + dt
			if v.avoidCollisionsTimer > 5 then
				v.avoidCollisionsTimer = 0
			end
			v.moveTimer = v.moveTimer + dt
			if v.moveTimer < 1.5 then
				-- move
				local amount = 2000*dt
				if v.moveDir == 0 then
					entity_addVel(me, -amount, 0)
					if entity_isFlippedHorizontal(me) then
						entity_flipHorizontal(me)
					end
				elseif v.moveDir == 1 then
					entity_addVel(me, 0, amount)
				elseif v.moveDir == 2 then
					entity_addVel(me, amount, 0)
					if not entity_isFlippedHorizontal(me) then
						entity_flipHorizontal(me)
					end			
				elseif v.moveDir == 3 then
					entity_addVel(me, 0, amount)
				end		
			elseif v.moveTimer > 3 then
				-- stop 
				--entity_clearVel(me)
				v.moveTimer = 0
				v.moveDir = v.moveDir +1 
				if v.moveDir >= 4 then
					v.moveDir = 0
				end
			elseif v.moveTimer > 2.5 then
				local factor = 5*dt
				entity_addVel(me, -entity_velx(me)*factor, -entity_vely(me)*factor)
			end
			if v.avoidCollisionsTimer < 4 then
				entity_doCollisionAvoidance(me, dt, 4, 1.0)
			end
		else
			if v.noteDown ~= -1 and entity_isUnderWater(me) then
				local amt
				if getCostume() == "seahorse" then
					amt = 8000*dt
				else
					amt = 2000*dt
				end
				entity_addVel(me, v.dirx*amt, v.diry*amt)
			end
			if entity_getHealth(getNaija()) < 1 then
				stopRide(me)
			end
			--entity_doCollisionAvoidance(me, dt, 8, 0.1)
			if v.dirx < 0 and entity_velx(me) < -100 then
				if entity_isFlippedHorizontal(me) then
					entity_flipHorizontal(me)
				end
			elseif v.dirx > 0 and entity_velx(me) > 100 then
				if not entity_isFlippedHorizontal(me) then
					entity_flipHorizontal(me)
				end
			end
			
			--entity_flipToVel(me)
		end
		
		entity_setTarget(me, getNaija())
		if v.riding then
			if entity_isUnderWater(me) then
				entity_doCollisionAvoidance(me, dt, 4, 0.6)
				--entity_doCollisionAvoidance(me, dt, 3, 0.5)
				--entity_doEntityAvoidance(me, dt, 32, 1.0)
			else
				entity_doCollisionAvoidance(me, dt, 4, 1)
			end
		else
			entity_doEntityAvoidance(me, dt, 128, 0.1)
		end
		entity_doCollisionAvoidance(me, dt, 2, 1.0)
		entity_updateMovement(me, dt)
		--entity_rotateToVel(me, 0.1)
	elseif entity_isState(me, STATE_RACE) then
		local x, y = node_getPathPosition(v.racePath, v.curNode)
		if x == 0 and y == 0 then
			--entity_setState(me, STATE_RESTART)
			v.curNode = 0
		else
			if entity_isPositionInRange(me, x, y, 64) then
				v.curNode = v.curNode + 1
			end
			local x1, y1 = entity_getPosition(me)
			local vx = x - x1
			local vy = y - y1
			vector_setLength(vx, vy, 500*dt)
			entity_addVel(me, vx, vy)
			entity_flipToVel(me)
			entity_doEntityAvoidance(me, dt, 32, 1.0)
			entity_doCollisionAvoidance(me, dt, 8, 0.2)
			entity_updateMovement(me, dt)			
		end
	end
	
	if v.waiting then
		entity_clearVel(me)
	end
	
	if v.riding then
		entity_updateLocalWarpAreas(me, true)
		entity_clearVel(v.n)
		local x, y = getRidePosition(me)
		entity_setRidingData(me, x, y, entity_getRotation(me), entity_isfh(me))
		--entity_setRidingRotation(me, entity_getRotation(me))
		--entity_rotate(v.n, entity_getRotation(me))
		--[[
		if entity_isFlippedHorizontal(me) and not entity_isFlippedHorizontal(v.n) then
			entity_flipHorizontal(v.n)
		elseif not entity_isFlippedHorizontal(me) and entity_isFlippedHorizontal(v.n) then
			entity_flipHorizontal(v.n)
		end
		]]--
		--avatar_updatePosition()
		
		if not entity_isUnderWater(me) then
			updateRideAnim(me, RIDEANIM_OUTOFWATER)
		elseif entity_isVelIn(me, 200) then
			updateRideAnim(me, RIDEANIM_SLOW)
		else
			updateRideAnim(me, RIDEANIM_NORMAL)
		end
		
		if v.noteDown == -1 then
			if entity_isUnderWater(me) then
				entity_doFriction(me, dt, 450)
			end
		end		
		
		--updateRideAnim(me, RIDEANIM_NORMAL)
		--[[
		entity_clearVel(v.n)
		entity_addVel(v.n, entity_velx(me), entity_vely(me))
		]]--
		
	end
	entity_handleShotCollisions(me)
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		if not v.riding then
			entity_setMaxSpeedLerp(me, 1, 1)
		end
		v.avoidCollisionsTimer = 0
	elseif entity_isState(me, STATE_DEAD) then
		stopRide(me)
	elseif entity_isState(me, STATE_RACE) then
		v.curNode = 0
		setRideSpeed(me)
		v.racePath = entity_getNearestNode(me, "RACE")
	elseif entity_isState(me, STATE_RESTART) then
		entity_clearVel(me)
		entity_setPosition(me, v.startx, v.starty)
		entity_setStateTime(me, 0.1)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function songNote(me, note)
	if v.riding then
		--debugLog("noteUp!")
		v.noteDown = note
		local amt = 0.6
		if note == 0 then
			v.dirx, v.diry =  0, 1
		elseif note == 1 then
			v.dirx, v.diry =  1, 1
		elseif note == 2 then
			v.dirx, v.diry =  1, 0
		elseif note == 3 then
			v.dirx, v.diry =  1,-1
		elseif note == 4 then
			v.dirx, v.diry =  0,-1
		elseif note == 5 then
			v.dirx, v.diry = -1,-1
		elseif note == 6 then
			v.dirx, v.diry = -1, 0
		elseif note == 7 then
			v.dirx, v.diry = -1, 1
		else
			debugLog("Sour note! (impossible)")
			v.dirx, v.diry =  0, 0
			return
		end
		v.dirx, v.diry = vector_setLength(v.dirx, v.diry, amt)
	end
end

function songNoteDone(me, note)
	--debugLog("songNoteDone function")
	if note == v.noteDown then
		--debugLog("noteDone!")
		v.dirx = 0
		v.diry = 0
		v.noteDown = -1
	end
end

function exitState(me)
	if entity_isState(me, STATE_SURFACE) then
		entity_rotate(me, 0, 1)
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_RESTART) then
		entity_setState(me, STATE_WAIT)	
	end
end

function shiftWorlds(me, old, new)
	if v.riding then
		if new == WT_SPIRIT then
			entity_setRiding(v.n, 0)
			cam_toEntity(v.n)
		elseif new == WT_NORMAL then
			if entity_isEntityInRange(me, v.n, 64) then
				entity_setRiding(v.n, me)
				cam_toEntity(me)
			else
				overrideZoom(0)
				v.riding = false
				entity_stopAllAnimations(v.n)
				entity_idle(v.n)
				entity_setRiding(v.n, 0)
				entity_setMaxSpeedLerp(me, 1, 1)
			end
		end
	end
end
