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

v.delay = 1
v.moveDelay = 0
v.rangeNode = 0
v.lastWeb = 0

v.fireDelayTime = 0.5
v.fireDelay = v.fireDelayTime
v.orient = ORIENT_UP

v.myWeb = 0
v.curPoint = -1
v.webPoint = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================


function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	16,								-- health
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
	
	--entity_setDeathParticleEffect(me, "NewtExplode")
	entity_initSkeletal(me, "SpiderCrab")
	entity_setState(me, STATE_IDLE)
	
	entity_setCollideRadius(me, 64)
	
	entity_scale(me, 1.4, 1.4)
	--entity_setDropChance(me, 75)
	
	v.orient = math.random(4)	
	v.webPoint = entity_getBoneByName(me, "WebPoint")
	bone_alpha(v.webPoint, 0)
	
	entity_setDamageTarget(me, DT_ENEMY_WEB, false)
	entity_setCullRadius(me, 1024)
	
	entity_generateCollisionMask(me)
	
	entity_setDeathScene(me, true)
	
	entity_setEatType(me, EAT_NONE)
end

function postInit(me)
	v.rangeNode = entity_getNearestNode(me, "BOUND")
	v.myWeb = createWeb()
	v.curPoint = web_addPoint(v.myWeb)
end

function songNote(me, note)
end

v.block = 6
local function isBlocked(x, y)	
	if v.rangeNode ~= 0 then
		return (isObstructedBlock(x, y, v.block)) or (not node_isPositionIn(v.rangeNode, x, y))
	end
	return (isObstructedBlock(x, y, v.block))
end

function update(me, dt)
	--[[
	if v.lastWeb ~= 0 then
		web_delete(v.lastWeb, 4)
		v.lastWeb = 0
	end
	]]--
	local speed = 600
	if entity_isState(me, STATE_IDLE) then
		local wx, wy = bone_getWorldPosition(v.webPoint)
		if v.myWeb ~= 0 and v.curPoint ~= -1 then
			web_setPoint(v.myWeb, v.curPoint, wx, wy)
		end
		if v.delay > 0 then
			entity_rotate(me, entity_getRotation(me)+180*dt)
			v.delay = v.delay - dt
			if v.delay < 0 then
				v.delay = 0
				v.moveDelay = 3 + math.random(4)
				entity_animate(me, "move", -1)
				v.orient = math.random(4)
			end
		else
			v.moveDelay = v.moveDelay - dt
			if v.moveDelay < 0 then
				v.moveDelay = 0
				v.delay = math.random(50)/100.0 + 0.5
				entity_animate(me, "idle", -1)
				if v.myWeb~=0 then
					if v.curPoint > 8 then
						web_delete(v.myWeb, 2)
						v.myWeb = createWeb()
					end
					v.curPoint = web_addPoint(v.myWeb, wx, wy)
				else
					v.myWeb = createWeb()
				end
			else
				local vx, vy = entity_getNormal(me)
				vx, vy = vector_setLength(vx, vy, 128)
				if not isBlocked(entity_x(me)+vx, entity_y(me)+vy) then
					vx, vy = vector_setLength(vx, vy, speed*dt)
					entity_setPosition(me, entity_x(me) + vx, entity_y(me) + vy)
				else
					v.moveDelay = 0
				end
			end
			--[[
			local check = 128
			if v.orient == ORIENT_LEFT then			
				if not isBlocked(entity_x(me)-check, entity_y(me)) then
					entity_setPosition(me, entity_x(me)-speed*dt, entity_y(me))
				else
					v.orient = v.orient + 1
				end
			elseif v.orient == ORIENT_RIGHT then
				if not isBlocked(entity_x(me)+check, entity_y(me)) then
					entity_setPosition(me, entity_x(me)+speed*dt, entity_y(me))
				else
					v.orient = v.orient + 1
				end
			elseif v.orient == ORIENT_DOWN then
				if not isBlocked(entity_x(me), entity_y(me)+check) then
					entity_setPosition(me, entity_x(me), entity_y(me)+speed*dt)
				else
					v.orient = v.orient + 1
				end
			elseif v.orient == ORIENT_UP then
				if not isBlocked(entity_x(me), entity_y(me)-check) then
					entity_setPosition(me, entity_x(me), entity_y(me)-speed*dt)
				else
					v.orient = v.orient + 1
				end			
			else
				v.orient = 0
			end
			]]--
		end
	end
	
	entity_clearTargetPoints(me)
	if not entity_isState(me, STATE_DEATHSCENE) then
		entity_addTargetPoint(me, bone_getWorldPosition(v.webPoint))
	end
	entity_handleShotCollisionsSkeletal(me)
	
	entity_touchAvatarDamage(me, 64, 1, 500)	
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setEntityType(me, ET_ENEMY)
		entity_animate(me, "idle", LOOP_INF)
		
		entity_setColor(me, 1, 1, 1, 0.5)
		entity_alpha(me, 1, 0.5)
	elseif entity_isState(me, STATE_DEAD) then
		shakeCamera(5, 1.5)
		playSfx("RockHit-Big")	
		web_delete(v.myWeb, 3)
		v.myWeb = 0
	elseif entity_isState(me, STATE_DEATHSCENE) then
		cam_toEntity(me)
		local ox = entity_x(me)
		local oy = entity_y(me)

		--entity_rotate(me, 180, 1, 0, 0, 1)
		entity_setPosition(me, entity_x(me), entity_y(me)+1600, 1.5, 0, 0, 1)
		entity_setStateTime(me, 1.5)
		wait(1)
		if chance(100) then
			spawnIngredient("SpiderEgg", ox, oy)
		end
		cam_toEntity(getNaija())
	end
end

function exitState(me)
	if entity_isState(me, STATE_HIDE) or entity_isState(me, STATE_MOVING) then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_ENERGYBLAST or damageType == DT_AVATAR_SHOCK or damageType == DT_AVATAR_BITE then	
		local nx, ny = entity_getNormal(me)
		local cx, cy = getLastCollidePosition()
		local dx = cx-entity_x(me)
		local dy = cy-entity_y(me)
		local dot = vector_dot(nx, ny, dx, dy)

		if dot < 0.9 then
			--[[		
			if damageType == DT_AVATAR_BITE then
				if v.myWeb ~= 0 then
					v.lastWeb = v.myWeb
					v.myWeb = 0
				end
			end
			]]--
			return true
		end
	end
	
	return false
end

function dieNormal(me)
end
