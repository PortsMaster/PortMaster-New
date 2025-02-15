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
-- Z A P   J E L L Y   (beta)
-- ================================================================================================

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.blupTimer = 0
v.dirTimer = 0
v.blupTime = 3.0

v.sz = 1.0
v.dir = 0

local MOVE_STATE_UP = 0
local MOVE_STATE_DOWN = 1

v.moveState = 0
v.moveTimer = 0
v.velx = 0
v.soundDelay = 0

-- JellyZap-specific
v.ent_friendJelly = 0
v.zapRange = 842
v.stopTimer = 0

v.zapFreezeTime = 0.87
v.preZapTime = 0.34

-- ================================================================================================
-- S T A T E S
-- ================================================================================================

local STATE_ZAP		= 1001
local STATE_PRE_ZAP	= 1002

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================
local function doIdleScale(me)	
	entity_scale(me, 1.0*v.sz, 0.75*v.sz, v.blupTime, -1, 1, 1)
end

function init(me)
	v.zapTimer = 3.21 + (math.random(321) * 0.01)

	setupBasicEntity(
	me,
	"JellyZap/Head",				-- texture
	32,								-- health
	0,								-- manaballamount
	2,								-- exp
	10,								-- money
	32,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000,							-- updateCull -1: disabled, default: 4000
	1
	)
	
	entity_setEntityType(me, ET_ENEMY)
	
	entity_setDeathParticleEffect(me, "Explode")
	
	entity_initSkeletal(me, "JellyZap")
	v.bone_glow = entity_getBoneByName(me, "Glow")
	v.bone_head = entity_getBoneByName(me, "Head")
	v.bone_bulb = entity_getBoneByName(me, "Bulb")
	
	bone_alpha(v.bone_head, 0.73, 5.4, -1, 1, 1)
	bone_alpha(v.bone_glow, 0, 3.2, -1, 1, 1)
	bone_scale(v.bone_bulb, 1.2, 1.2, 2.1, -1, 1, 1)
	
	entity_initHair(me, 40, 5, 36, "JellyZap/FrontArms")
	
	entity_setState(me, STATE_IDLE)

	entity_scale(me, 0.75*v.sz, 1*v.sz)
	doIdleScale(me)
	
	entity_exertHairForce(me, 0, 400, 1)
	
	entity_setDamageTarget(me, DT_ENEMY_SHOCK, false)	
	entity_setDamageTarget(me, DT_ENEMY_ENERGYBLAST, false)
	
	esetv(me, EV_ENTITYDIED, 1)
end

function entityDied(me, ent)
	if v.ent_friendJelly == ent then
		v.ent_friendJelly = 0
		entity_setState(me, STATE_IDLE)
	end
end

function msg(me, msg)
	if msg == "PREPARE THYSELF" then
		v.stopTimer = v.preZapTime + 1
		v.zapTimer = v.zapTimer + 1
		entity_clearVel(me)
		spawnParticleEffect("JellyZapPreZap", entity_x(me), entity_y(me))
		
	elseif msg == "FREEZE" then
		v.stopTimer = v.zapFreezeTime
		v.zapTimer = 14
		entity_setState(me, STATE_IDLE)
		entity_clearVel(me)
	end
end

function update(me, dt)
	-- FIND NEARBY JELLY, ZAP AT HIM
	v.zapTimer = v.zapTimer - dt
	if v.zapTimer <= 0 then
		if v.ent_friendJelly == 0 or not entity_isEntityInRange(me, v.ent_friendJelly, v.zapRange) then
			v.ent_friendJelly = entity_getNearestEntity(me, "JellyZap", v.zapRange) 
			v.zapTimer = 0
			
		elseif not entity_isEntityInRange(me, v.ent_friendJelly, v.zapRange/2) then
			v.zapTimer = 3.21 + (math.random(321) * 0.01) + v.zapFreezeTime
			if v.ent_friendJelly ~= 0 then
				v.stopTimer = v.preZapTime + 1
				entity_setState(me, STATE_PRE_ZAP, v.preZapTime)
				entity_msg(v.ent_friendJelly, "PREPARE THYSELF", me)
			end
		end
	end
	-- -- --

	dt = dt * 1.5
	if true then
		if avatar_isBursting() or entity_getRiding(getNaija())~=0 then
			local e = entity_getRiding(getNaija())
			if entity_touchAvatarDamage(me, 32, 0, 400) then
				if e~=0 then
					local x,y = entity_getVectorToEntity(me, e)
					x,y = vector_setLength(x, y, 500)
					entity_addVel(e, x, y)
				end
				local len = 500
				local x,y = entity_getVectorToEntity(getNaija(), me)
				x,y = vector_setLength(x, y, len)
				entity_push(me, x, y, 0.2, len, 0)
				entity_sound(me, "JellyBlup", 800)
			end		
		else
			if entity_touchAvatarDamage(me, 32, 0, 1000) then		
				entity_sound(me, "JellyBlup", 800)
			end
		end
	end
	entity_handleShotCollisions(me)
	
	-- Quick HACK to handle getting bumped out of the water.  --achurch
	if not entity_isUnderWater(me) then
		v.moveState = MOVE_STATE_DOWN
		v.moveTimer = 5 + math.random(200)/100.0 + math.random(3)
		entity_setMaxSpeed(me, 500)
		entity_setMaxSpeedLerp(me, 1, 0)
		entity_addVel(me, 0, 500*dt)
		entity_updateMovement(me, dt)
		entity_setHairHeadPosition(me, entity_x(me), entity_y(me))
		entity_updateHair(me, dt)
		return
	elseif not entity_isState(me, STATE_PUSH) then
		entity_setMaxSpeed(me, 50)
	end
	
	v.moveTimer = v.moveTimer - dt
	if v.moveTimer < 0 then
		if v.moveState == MOVE_STATE_DOWN then		
			v.moveState = MOVE_STATE_UP
			entity_setMaxSpeedLerp(me, 1.5, 0.2)
			entity_scale(me, 0.75, 1, 1, 1, 1)
			v.moveTimer = 3 + math.random(200)/100.0
			entity_sound(me, "JellyBlup")
		elseif v.moveState == MOVE_STATE_UP then
			v.velx = math.random(400)+100
			if math.random(2) == 1 then
				v.velx = -v.velx
			end
			v.moveState = MOVE_STATE_DOWN
			doIdleScale(me)
			entity_setMaxSpeedLerp(me, 1, 1)
			v.moveTimer = 5 + math.random(200)/100.0 + math.random(3)
		end
	end
	
	if v.moveState == MOVE_STATE_UP then
		entity_addVel(me, v.velx*dt, -600*dt)
		entity_rotateToVel(me, 1)
		
	elseif v.moveState == MOVE_STATE_DOWN then
		entity_addVel(me, 0, 50*dt)
		entity_rotateTo(me, 0, 3)
		entity_exertHairForce(me, 0, 200, dt*0.6, -1)
	end
	
	entity_doEntityAvoidance(me, dt, 321, 3.21)
	entity_doCollisionAvoidance(me, dt, 10, 1.23)
	
	-- FREEZE JELLY WHEN ZAPPING (OR RECEIVING ZAP)
	if v.stopTimer > 0 then 
		v.stopTimer = v.stopTimer - dt
		entity_exertHairForce(me, 0, 123, dt, -1)
		entity_rotateTo(me, 0, 0.23)
		
	elseif v.stopTimer <= 0 then
		v.stopTimer = 0
		entity_updateMovement(me, dt)
	end
	
	entity_setHairHeadPosition(me, entity_x(me), entity_y(me))
	entity_updateHair(me, dt)
end

function hitSurface(me)
end

function enterState(me)
	if entity_getState(me) == STATE_IDLE then
		entity_setMaxSpeed(me, 50)
		entity_animate(me, "idle", LOOP_INF)
		v.ent_friendJelly = entity_getNearestEntity(me, "JellyZap", v.zapRange)	
		
	elseif entity_getState(me) == STATE_ZAP then
		v.stopTimer = v.zapFreezeTime
		entity_clearVel(me)
		
		if v.ent_friendJelly ~= 0 then
			entity_sound(me, "EnergyOrbCharge")
			--entity_sound(me, "FizzleBarrier")
			
			local meX, meY = entity_getPosition(me)
			local fX, fY = entity_getPosition(v.ent_friendJelly)
			local vecX = (fX - meX)
			local vecY = (fY - meY)
			
			-- ZAP ATTACK
			local zapAmount = 24
			for i=0,zapAmount do
				local s = createShot("JellyZapAttack", me, 0, entity_x(me) + ((vecX/zapAmount)*i), entity_y(me) + ((vecY/zapAmount)*i))
				spawnParticleEffect("JellyZapFx", entity_x(me) + ((vecX/zapAmount)*i), entity_y(me) + ((vecY/zapAmount)*i))
			end
			
			spawnParticleEffect("JellyZapPreZap", entity_x(me), entity_y(me))
			spawnParticleEffect("JellyZapPreZap", entity_x(me) + vecX, entity_y(me) + vecY)
		end
		
	elseif entity_getState(me) == STATE_PRE_ZAP then
		entity_clearVel(me)
		spawnParticleEffect("JellyZapPreZap", entity_x(me), entity_y(me))
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_DUALFORMNAIJA then
		entity_changeHealth(me, -500)
	end
	return true
end

function exitState(me)
	if entity_getState(me) == STATE_ZAP then
		entity_touchAvatarDamage(me, 170, 1, 800)
		
	elseif entity_getState(me) == STATE_PRE_ZAP then
		entity_setState(me, STATE_ZAP, v.zapFreezeTime) 
		entity_msg(v.ent_friendJelly, "FREEZE", me)
	end
end

function songNoteDone(me, note)
	-- INSTA-KILL LOL
	-- v.ent_friendJelly = getNaija()
	-- entity_setState(me, STATE_PRE_ZAP, v.preZapTime)
end
