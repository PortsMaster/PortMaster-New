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
-- NEWT BLASTER
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

local STATE_HIDE 		= 1000
local STATE_MOVING	= 1001

v.tailEnd = 0
v.hits = 0

v.fireDelayTime = 0.5
v.fireDelay = v.fireDelayTime
v.orient = ORIENT_UP

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================


function init(me)
	setupBasicEntity(
	me,
	"",						-- texture
	12,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	40,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000,							-- updateCull -1: disabled, default: 4000
	-1
	)
	
	entity_setDeathParticleEffect(me, "NewtExplode")
	entity_initSkeletal(me, "NewtBlaster")
	entity_setState(me, STATE_IDLE)
	
	entity_setDropChance(me, 100, 2)
	entity_setDeathScene(me, true)
	
	v.tailEnd = entity_getBoneByName(me, "TailEnd")
	
	loadSound("newtblaster-die")
	entity_setDeathSound(me, "newtblaster-die")
end

function songNote(me, note)
--[[
	if getForm()~=FORM_NORMAL then
		return
	end
	transTime = 0.5
	if note == 0 then
		entity_setColor(me, 1, 0, 0, transTime)
	elseif note == 1 then
		entity_setColor(me, 1, 1, 0, transTime)		
	elseif note == 2 then
		entity_setColor(me, 0, 1, 0, transTime)
	elseif note == 3 then
		entity_setColor(me, 0, 1, 1, transTime)
	elseif note == 4 then
		entity_setColor(me, 0, 0, 1, transTime)
	elseif note == 5 then
		entity_setColor(me, 1, 1, 1, transTime)
	elseif note == 6 then
		entity_setColor(me, 0, 0, 0, transTime)	
	elseif note == 7 then
		entity_setColor(me, 1, 0, 1, transTime)	
	elseif note == 8 then
		entity_setColor(me, 0.5, 0.5, 0.5, transTime)
	end
	]]--
end

function update(me, dt)
	entity_handleShotCollisions(me)
	
	if not entity_hasTarget(me) then
		entity_findTarget(me, 1024)
	else
		if entity_isState(me, STATE_IDLE) then
			entity_touchAvatarDamage(me, 48, 1, 1000)
			-- fire if in range
			v.fireDelay = v.fireDelay - dt
			if v.fireDelay < 0 then
				--local vx, vy = bone_getNormal(v.tailEnd)
				local x, y = bone_getPosition(v.tailEnd)
				--bone_getOrientation()
				--entity_playSfx(me, "BasicShot")
				--entity_fireAtTarget(me, "NewtFire", 1, 150, 10, 3, 32, 0, 0, 0, 0, x, y)
				local s = createShot("NewtFire", me, entity_getTarget(me), x, y)
				local tx, ty = entity_getPosition(entity_getTarget(me))
				shot_setAimVector(s, tx-x, ty-y)
				
				v.fireDelay = v.fireDelayTime
			end
		end
	end
	local speed = 400
	if entity_isState(me, STATE_HIDE) then
		local check = 256
		local block = 6
		if v.orient == ORIENT_LEFT then
			if not isObstructedBlock(entity_x(me)-check, entity_y(me), block) then
				entity_setPosition(me, entity_x(me)-speed*dt, entity_y(me))
			else
				v.orient = v.orient + 1
			end
		elseif v.orient == ORIENT_RIGHT then
			if not isObstructedBlock(entity_x(me)+check, entity_y(me), block) then
				entity_setPosition(me, entity_x(me)+speed*dt, entity_y(me))
			else
				v.orient = v.orient + 1
			end
		elseif v.orient == ORIENT_DOWN then
			if not isObstructedBlock(entity_x(me), entity_y(me)+check, block) then
				entity_setPosition(me, entity_x(me), entity_y(me)+speed*dt)
			else
				v.orient = v.orient + 1
			end
		elseif v.orient == ORIENT_UP then
			if not isObstructedBlock(entity_x(me), entity_y(me)-check, block) then
				entity_setPosition(me, entity_x(me), entity_y(me)-speed*dt)
			else
				v.orient = v.orient + 1
			end			
		else
			v.orient = 0
		end
	end
	--[[
	if entity_isState(me, STATE_IDLE) then
		if chance(10) then
			entity_setState(me, STATE_MOVING, 4)
		end
	end
	]]--
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setEntityType(me, ET_ENEMY)
		entity_animate(me, "idle", LOOP_INF)
		
		entity_setColor(me, 1, 1, 1, 0.5)
		entity_alpha(me, 1, 0.5)
	elseif entity_isState(me, STATE_HIDE) then
		
		v.orient = math.random(4)
		entity_setEntityType(me, ET_NEUTRAL)
		entity_alpha(me, 0.1, 1)
		entity_setColor(me, 0.5, 0.5, 1, 0.5)
		entity_animate(me, "crawl", LOOP_INF)
	elseif entity_isState(me, STATE_MOVING) then
		entity_animate(me, "crawl", LOOP_INF)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		local ox = entity_x(me)
		local oy = entity_y(me)
		entity_setStateTime(me, 99)
		--entity_idle(v.n)
		--cam_toEntity(me)
		entity_animate(me, "fall", -1)
		--entity_setPosition(me, entity_x(me), entity_y(me)+1000, 2)
		wait(1)
		--cam_toEntity(getNaija())
		entity_setStateTime(me, 0.1)
		--spawnIngredient("SpicyMeat", ox, oy)
		spawnIngredient("SpicyMeat", ox, oy)
	end
end

function exitState(me)
	if entity_isState(me, STATE_HIDE) or entity_isState(me, STATE_MOVING) then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_getAlpha(me) == 1 then
		v.hits = v.hits + dmg
		if v.hits > 5 then
			v.hits = 0
			if entity_isState(me, STATE_IDLE) then		
				entity_setState(me, STATE_HIDE, 3.5 + math.random(200)/200.0)
			end
		end
		return true
	end
	return false
end
