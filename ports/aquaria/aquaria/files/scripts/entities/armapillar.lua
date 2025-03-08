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
-- A R M A P I L L A R    (beta)
-- ================================================================================================

-- ================================================================================================
-- S T A T E S 
-- ================================================================================================

local STATE_HIDE		= 1001
local STATE_STAND		= 1002
local STATE_CRAWL		= 1003
--local STATE_OPEN		= 1004
local STATE_CHARGE		= 1005
--local STATE_CLOSE		= 1006
local STATE_SIT			= 1007

-- ================================================================================================
-- L O C A L   V A R I A B L E S 
-- ================================================================================================

v.chargeTime = 0
v.chT = 2.4
--v.chT = 0.2

v.shotCount = 0

v.moveTimer = 0
v.mT = 0.5 -- 3.2

v.moves = 1

v.fireBit = 0

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"Armapillar/Body",				-- texture
	24,								-- health
	1,								-- manaballamount
	0,								-- exp
	0,								-- money
	32,								-- collideRadius (for hitting entities + spells)
	STATE_HIDE,						-- initState
	256,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setDeathParticleEffect(me, "Explode")
	entity_setDropChance(me, 36)
	
	entity_initSkeletal(me, "Armapillar")
	v.eye = entity_getBoneByName(me, "Eye")
	v.body = entity_getBoneByName(me, "Body")
	
	entity_setEntityType(me, ET_ENEMY)
	--entity_generateCollisionMask(me)
	entity_setCollideRadius(me, 54)
	
	esetv(me, EV_WALLOUT, 1)
	esetvf(me, EV_CLAMPTRANSF, 0.2)
	entity_clampToSurface(me)
	
	entity_scale(me, 0.76, 0.76)
	bone_scale(v.body, 0.2, 0.2)
	
	entity_setState(me, STATE_HIDE)
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
end

function postInit(me)
	-- RANDOMLY FLIP HORIZONTALLY
	if chance(50) then 
		entity_fh(me)
		entity_switchSurfaceDirection(me)
	end
end

function update(me, dt)

	entity_findTarget(me, 678)		-- Active range
	
	if entity_getState(me) == STATE_HIDE then
		entity_clearTargetPoints(me)
	
		if entity_hasTarget(me) then
			entity_setState(me, STATE_STAND)
		end
	else
		entity_clearTargetPoints(me)
		local eyeX, eyeY = bone_getWorldPosition(v.eye)
		entity_addTargetPoint(me, eyeX, eyeY)
	end
	
	if entity_getState(me) == STATE_CRAWL then
		entity_findTarget(me, 1337)
		
		if entity_hasTarget(me) then
			if eisv(me, EV_CLAMPING, 0) then
			
				entity_moveAlongSurface(me, dt, 34)
				
				if v.moveTimer > 0 then v.moveTimer = v.moveTimer - dt
				else
					--if chance(24) then
					v.moves = v.moves - 1
					if v.moves <= 0 then
						entity_setState(me, STATE_OPEN)
						v.moves = 1
						entity_switchSurfaceDirection(me)
					else
					--else
						entity_switchSurfaceDirection(me)
					end
					--end
					
					v.moveTimer = v.mT + (math.random(432) * 0.01)
				end
			end
		else
			entity_setState(me, STATE_SIT)
		end
	elseif entity_getState(me) == STATE_CHARGE then
		if v.chargeTime > 0 then v.chargeTime = v.chargeTime - dt end

		local pupx, pupy = bone_getWorldPosition(v.eye)
		local nx, ny = entity_getNormal(me)
		nx, ny = vector_setLength(nx, ny, 34)
		
		v.fireBit = v.fireBit - dt
		if v.fireBit < 0 then
			v.fireBit = 0.2
			
			spawnParticleEffect("ArmaShot", pupx, pupy)
			local s = createShot("ArmaShot", me, getNaija(), entity_x(me) + nx, entity_y(me) + ny)
			shot_setAimVector(s, nx, ny)
			v.shotCount = v.shotCount + 1
			
			if v.shotCount > 16 then
				v.chargeTime = 0
				v.shotCount = 0
				entity_setState(me, STATE_CLOSE)
			end
		end
		
		--[[
		if v.chargeTime <= (v.chT * 0.60) and v.shotCount == 0 then
			spawnParticleEffect("ArmaShot", pupx, pupy)
			local s = createShot("ArmaShot", me, 0, entity_x(me) + nx, entity_y(me) + ny)
			v.shotCount = v.shotCount + 1
			
		elseif v.chargeTime <= (v.chT * 0.50) and v.shotCount == 1 then
			spawnParticleEffect("ArmaShot", pupx, pupy)
			local s = createShot("ArmaShot", me, 0, entity_x(me) + nx, entity_y(me) + ny)
			v.shotCount = v.shotCount + 1
			
		elseif v.chargeTime <= (v.chT * 0.40) and v.shotCount == 2 then
			spawnParticleEffect("ArmaShot", pupx, pupy)
			local s = createShot("ArmaShot", me, 0, entity_x(me) + nx, entity_y(me) + ny)
			v.shotCount = v.shotCount + 1
		
		elseif v.chargeTime <= (v.chT * 0.30) and v.shotCount == 3 then
			spawnParticleEffect("ArmaShot", pupx, pupy)
			local s = createShot("ArmaShot", me, 0, entity_x(me) + nx, entity_y(me) + ny)
			v.shotCount = v.shotCount + 1
			
		elseif v.chargeTime <= 0 and v.shotCount == 4 then
			v.chargeTime = 0
			v.shotCount = 0
			entity_setState(me, STATE_CLOSE)
		end
		]]--
	end
	
	-- UPDATE STUFFS
	entity_rotateToSurfaceNormal(me, 0.34)
	--entity_handleShotCollisionsSkeletal(me)
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, 54, 0.5, 64)	
end

function enterState(me)
	if entity_getState(me) == STATE_HIDE then
		entity_animate(me, "hide", LOOP_INF)
		bone_scale(v.body, 0.2, 0.2, 0.48)
		bone_setSegs(v.body)
		entity_setAllDamageTargets(me, false)
		
	elseif entity_getState(me) == STATE_STAND then
		entity_setStateTime(me, entity_animate(me, "stand"))
		bone_scale(v.body, 1, 1, 0.48)
		entity_setAllDamageTargets(me, true)
		entity_setDamageTarget(me, DT_ENEMY_ENERGYBLAST, false)
		
	elseif entity_getState(me) == STATE_CRAWL then
		entity_animate(me, "crawl", LOOP_INF)
		bone_setSegs(v.body, 4, 4, 0.6, 0.6, -0.022, 0, 4.8, 1)
		v.moveTimer = v.mT + (math.random(432) * 0.01)
		entity_setDamageTarget(me, DT_AVATAR_PET, false)
		
	elseif entity_getState(me) == STATE_OPEN then
		entity_setStateTime(me, entity_animate(me, "open"))
		bone_setSegs(v.body)
		
	elseif entity_getState(me) == STATE_CHARGE then
		entity_animate(me, "charge", LOOP_INF)
		v.chargeTime = v.chT 
		v.shotCount = 0
		entity_setDamageTarget(me, DT_AVATAR_PET, true)
	
	elseif entity_getState(me) == STATE_CLOSE then
		entity_setStateTime(me, entity_animate(me, "close"))
		entity_setDamageTarget(me, DT_AVATAR_PET, false)
		
	elseif entity_getState(me) == STATE_SIT then
		entity_setStateTime(me, entity_animate(me, "sit"))
		bone_scale(v.body, 0.2, 0.2, 0.48)
		bone_setSegs(v.body)
		
	end
end

function exitState(me)
	if entity_getState(me) == STATE_STAND then
		entity_setState(me, STATE_OPEN)
		
	elseif entity_getState(me) == STATE_OPEN then
		entity_setState(me, STATE_CHARGE)
	
	elseif entity_getState(me) == STATE_CLOSE then
		entity_setState(me, STATE_CRAWL)
		
	elseif entity_getState(me) == STATE_SIT then
		entity_setState(me, STATE_HIDE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_isState(me, STATE_CHARGE) then
		local nx, ny = entity_getNormal(me)
		local cx, cy = getLastCollidePosition()
		local dx = cx-entity_x(me)
		local dy = cy-entity_y(me)
		local dot = vector_dot(nx, ny, dx, dy)

		if dot > 0.9 then
			bone_damageFlash(v.body)
			bone_damageFlash(v.eye)
			return true
		else
			playNoEffect()
			return false
		end
	else
		playNoEffect()
		return false
	end
end

function hitSurface(me)
end
