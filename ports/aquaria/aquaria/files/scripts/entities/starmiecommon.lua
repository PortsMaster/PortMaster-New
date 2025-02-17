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
-- S T A R M I E   C O M M O N   S C R I P T
-- ================================================================================================

-- ================================================================================================
-- L O C A L   V A R I A B L E S 
-- ================================================================================================

v.shotDelay = 0
v.sD = 6	-- Time between shots

v.animSpeed = 1
v.openDelay = 0

v.maxSpeed = 700
v.shotForce = 432	-- For pushing Starmie around

v.pYo = 2			-- Pupil y offset
v.pupilFreeze = 0
v.blinkTime = 0
 
-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function v.commonInit(me, skin)
	v.rotDir = math.random(2)-1	-- Random direction for spinning 'round Naija

	setupBasicEntity(
	me,
	"Starmie/Body",					-- texture
	15,								-- health
	1,								-- manaballamount
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
	
	loadSound("StarmieAwake")
	
	entity_setEatType(me, EAT_FILE, "Starmie")
	
	entity_setDeathParticleEffect(me, "StarmieDeath")
	entity_setDropChance(me, 6)
	
	if skin == 1 then 
		entity_initSkeletal(me, "Starmie")
	elseif skin == 2 then
		entity_initSkeletal(me, "Starmie", "Starmie2")
	end
	
	v.pupil = entity_getBoneByName(me, "Pupil")
	v.lid = entity_getBoneByName(me, "Lid")
	v.eye = entity_getBoneByName(me, "Eye")
	
	entity_setState(me, STATE_IDLE)
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
end

function dieNormal(me)
	if chance(5) then
		spawnIngredient("SmallEye", entity_x(me), entity_y(me))
	end
end

function update(me, dt)

	-- WAKE UP STARMIE WHEN THE TIME IS RIGHT
	if entity_getState(me)==STATE_IDLE
	and not isForm(FORM_FISH) then	
		entity_findTarget(me, 321)
		
		if not entity_hasTarget(me) then
			bone_setPosition(v.pupil, 0, v.pYo)
		else
			entity_setState(me, STATE_OPEN)
		end
	elseif entity_getState(me)==STATE_OPEN then
		if v.openDelay > 0 then v.openDelay = v.openDelay - dt
		elseif v.openDelay <= 0 then
			entity_setState(me, STATE_HOSTILE)
		end
	end
	
	-- STARMIE ON THE ATTACK
	if entity_getState(me)==STATE_HOSTILE then
		entity_findTarget(me, 2000)
		
		-- TIME BETWEEN SHOTS
		if v.shotDelay > 0 then v.shotDelay = v.shotDelay - dt
		else v.shotDelay = 0 end
		-- PUPIL FREEZE COUNTDOWN
		if v.pupilFreeze > 0 then v.pupilFreeze = v.pupilFreeze - dt
		else v.pupilFreeze = 0 end
		
		-- DO BLINKING
		if v.blinkTime > 0 and v.pupilFreeze == 0 then v.blinkTime = v.blinkTime - dt
		elseif v.blinkTime <= 0 and v.blinkTime > -0.18 then
			bone_alpha(v.lid, 1)
			v.blinkTime = v.blinkTime - dt
		else
			bone_alpha(v.lid, 0, 0.024)
			v.blinkTime = 5 + (math.random(600) * 0.01)
		end

		if not entity_hasTarget(me) then
			-- RETURN TO "HIDING"
			entity_clearVel(me)
			entity_setState(me, STATE_IDLE)
			bone_setPosition(v.pupil, 0, v.pYo)
			entity_rotate(me, randAngle360())
		else
			local nX, nY = entity_getPosition(getNaija())	-- Naija's position
			if v.pupilFreeze == 0 and v.blinkTime > 0 then
				-- EYE TRACKING
				local sX, sY = entity_getPosition(me)	-- Starmie's position
				local x = (nX - sX)
				local y = (nY - (sY+v.pYo))
				x, y = vector_cap(x, y, 7.5)
				bone_setPosition(v.pupil, x, y, 0.24)
				
				-- ATTACK
				if v.shotDelay == 0 and entity_hasTarget(me) then entity_setState(me, STATE_ATTACK) end
			else
				if v.shotDelay == 0 then v.shotDelay = v.shotDelay + 0.34 end	-- Helps keep Starmie stunned when being hit
			end

			-- MOVEMENT
			entity_moveAround(me, nX, nY, dt, 255, v.rotDir)
			entity_moveTowardsTarget(me, dt, 186)
			if not entity_isTargetInRange(me, 1248) then entity_moveTowardsTarget(me, dt, v.shotForce) end -- Move in if far away
		end
	end
	
	if entity_getState(me)==STATE_ATTACK then
		-- BOUNCE STARMIE AFTER SHOOTING
		entity_moveTowardsTarget(me, 1, -(v.shotForce * 0.9))
		entity_setState(me, STATE_HOSTILE)
	end

	-- SPEED UP/SLOW DOWN ROTATION BASED ON ACTUAL SPEED
	v.animSpeed = ((entity_getVelLen(me) / v.maxSpeed) * 2) + 0.2
	entity_setAnimLayerTimeMult(me, 0, v.animSpeed)
	
	entity_doEntityAvoidance(me, dt, 123, 0.32)
	entity_doCollisionAvoidance(me, dt, 8, 0.6)
	
	-- UPDATE ERRVRYTHING
	
	if not entity_isState(me, STATE_IDLE) then
		entity_updateCurrents(me, dt)
		entity_doFriction(me, dt, 200)
		entity_updateMovement(me, dt)
		
		entity_touchAvatarDamage(me, 32, 0.25, 640)
	end
	
	entity_handleShotCollisions(me)
end

function enterState(me)
	local appearSpeed = 0.30
	local lookSpeed = 0.2

	-- HIDE STARMIE IN THE BACKGROUND...
	if entity_getState(me)==STATE_IDLE then
		bone_setPosition(v.pupil, 0, v.pYo)
		bone_alpha(v.lid, 1)
		entity_scale(me, 0.7, 0.7)
		entity_color(me, 0.6, 0.6, 0.6)
	
		entity_animate(me, "idle", LOOP_INF)
		v.animSpeed = 0
		
		v.shotDelay = 1 + (math.random(50) * 0.1)
		entity_setMaxSpeed(me, v.maxSpeed/8)
		
		v.blinkTime = 5 + (math.random(600) * 0.01)
	
	-- BRING STARMIE TO LIFE!
	elseif entity_getState(me)==STATE_OPEN then
		entity_sound(me, "StarmieAwake")
	
		-- SPIN IN THE PROPER DIRECTION, BASED ON HOW STARMIE IS ROTATING AROUND NAIJA
		if v.rotDir == 0 then entity_animate(me, "spinLeft", LOOP_INF)
		elseif v.rotDir == 1 then entity_animate(me, "spinRight", LOOP_INF) end
		
		v.animSpeed = 1
		
		bone_setPosition(v.pupil, 0, v.pYo)
		bone_alpha(v.lid, 0, appearSpeed) --fade away the eyelid
		entity_scale(me, 1.2, 1.2, appearSpeed) --scale to normal size
		entity_color(me, 1, 1, 1, appearSpeed)	--set to normal colour
		bone_scale(v.pupil, 1.27, 1.27)
		bone_scale(v.pupil, 1, 1, appearSpeed) -- Pupil adjusting to light -> may have to tweak timing to get it lookin' nice
		
		entity_rotate(me, 0, lookSpeed)
		v.openDelay = appearSpeed + lookSpeed
		
		entity_setMaxSpeed(me, v.maxSpeed/4)
		entity_moveTowards(me, entity_x(getNaija()), entity_y(getNaija()), 1, -1234)
		
		
		entity_setDamageTarget(me, DT_AVATAR_PET, true)
		entity_setDamageTarget(me, DT_AVATAR_LIZAP, true)
		
	elseif entity_getState(me)==STATE_HOSTILE then
		v.openDelay = 0
		v.pupilFreeze = 0
		entity_setMaxSpeed(me, v.maxSpeed)
	
	-- SHOT WEB, LOL
	elseif entity_getState(me)==STATE_ATTACK then
		local pupx, pupy = bone_getWorldPosition(v.pupil)
		spawnParticleEffect("StarShot", pupx, pupy)
		local s = createShot("StarFire", me, entity_getTarget(me))
		shot_setOut(s, 12)	
		
		bone_setColor(v.pupil, 2, 2, 0)
		bone_setColor(v.pupil, 1, 1, 1, 0.15)
		bone_alpha(v.pupil, 0.45)
		bone_alpha(v.pupil, 1, 0.5)
		bone_scale(v.pupil, 1.27, 1.27)
		bone_scale(v.pupil, 1, 1, 0.32)
		
		bone_setColor(v.eye, 1, 1, 0)
		bone_setColor(v.eye, 1, 1, 1, 0.04)
		
		v.shotDelay = v.sD
	end
end

-- TAKE DAMAGE -> STUN STARMIE WHEN HIT
function damage(me, attacker, bone, damageType, dmg, x, y)
	bone_setPosition(v.pupil, 0, v.pYo, 0.021)
	bone_scale(v.pupil, 0.76, 0.76)
	bone_scale(v.pupil, 1, 1, 0.1)
	v.pupilFreeze = 0.32
	
	entity_moveTowards(me, x, y, 1, -v.shotForce)

	if entity_getState(me)==STATE_IDLE then	
		entity_setState(me, STATE_OPEN)
		v.pupilFreeze = 0
	end
	
	return true
end

function exitState(me)
	if entity_isState(me, STATE_OPEN) then
	end
end

function songNoteDone(me, note)
end

function hitSurface(me)
end
