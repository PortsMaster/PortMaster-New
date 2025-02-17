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

-- DARK JELLY

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
v.waveDir = 1
v.waveTimer = 0
v.soundDelay = 0
v.glows = nil

local function doIdleScale(me)
	entity_scale(me, 0.9*v.sz, 1.1*v.sz)
	entity_scale(me, 1.1*v.sz, 0.9*v.sz, v.blupTime, -1, 1, 1)
end

function init(me)
	v.glows = {}

	setupBasicEntity(
	me,
	"",						-- texture
	6,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	0,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000,							-- updateCull -1: disabled, default: 4000
	1
	)
	
	entity_initSkeletal(me, "DarkJelly")
	
	entity_setEntityType(me, ET_NEUTRAL)
	entity_setAllDamageTargets(me, false)
	
	entity_setEntityLayer(me, -4)
		
	--entity_initHair(me, 64, 16, 128, "DarkJelly/Tentacles")
	
	
	doIdleScale(me)
	
	entity_exertHairForce(me, 0, 400, 1)
		
	entity_setState(me, STATE_IDLE)
	--entity_setCullRadius(me, -3)
	entity_setCull(me, false)
	
	bone_setSegs(entity_getBoneByName(me, "Tentacles"), 4, 32, 0.6, 0.6, -0.028, 0, 0.75, 0)
	
	--[[
	for i=1,4 do
		v.glows[i] = entity_getBoneByName(me, string.format("Glow%d", i))
		bone_alpha(v.glows[i], 0.5)
		bone_alpha(v.glows[i], 1, 1, -1, 1, 1)
		bone_update(v.glows[i], i*0.25)
	end
	]]--
	
end

function postInit(me)
	entity_update(me, math.random(100)/100.0)
end

function update(me, dt)
	--dt = dt * 1.5
	local sx,sy = entity_getScale(me)
		
	v.moveTimer = v.moveTimer - dt
	if v.moveTimer < 0 then
		if v.moveState == MOVE_STATE_DOWN then		
			v.moveState = MOVE_STATE_UP
			entity_setMaxSpeedLerp(me, 1.5, 0.2)
			--entity_scale(me, 0.75, 1, 1, 1, 1)
			v.moveTimer = 3 + math.random(200)/100.0
			--entity_sound(me, "JellyBlup")
		elseif v.moveState == MOVE_STATE_UP then
			v.velx = math.random(400)+100
			if math.random(2) == 1 then
				v.velx = -v.velx
			end
			v.moveState = MOVE_STATE_DOWN
			entity_setMaxSpeedLerp(me, 1, 1)
			v.moveTimer = 5 + math.random(200)/100.0 + math.random(3)
		end
	end
	
	v.waveTimer = v.waveTimer + dt
	if v.waveTimer > 2 then
		v.waveTimer = 0
		if v.waveDir == 1 then
			v.waveDir = -1
		else
			v.waveDir = 1
		end
	end

	if v.moveState == MOVE_STATE_UP then
		entity_addVel(me, v.velx*dt, -600*dt)
		entity_rotateToVel(me, 8)
	elseif v.moveState == MOVE_STATE_DOWN then
		entity_addVel(me, 0, 50*dt)
		entity_rotateTo(me, 0, 8)
		entity_exertHairForce(me, 0, 200, dt*0.6, -1)
	end

	--[[
	entity_doEntityAvoidance(me, dt, 32, 1.0)
	entity_doCollisionAvoidance(me, 1.0, 8, 1.0)
	entity_updateCurrents(me, dt)
	]]--
	entity_updateMovement(me, dt)
	
	--[[
	local bx, by = bone_getWorldPosition(entity_getBoneByIdx(me, 0))
	entity_setHairHeadPosition(me, bx, by)
	entity_updateHair(me, dt*5)
	]]--
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setMaxSpeed(me, 40)
		entity_animate(me, "idle", LOOP_INF)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function exitState(me)
end
