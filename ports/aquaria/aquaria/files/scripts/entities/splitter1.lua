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
-- JELLY
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================


-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

local MOVE_STATE_UP = 0
local MOVE_STATE_DOWN = 1

v.moveState = 0
v.moveTimer = 0
v.velx = 0
v.waveDir = 1
v.waveTimer = 0
v.soundDelay = 0

function init(me)
	setupBasicEntity(
	me,
	"",							-- texture
	3,								-- health
	2,								-- manaballamount
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
	
	--entity_setDeathParticleEffect(me, "PurpleExplode")
	
	entity_initSkeletal(me, "Splitter1")
	
	entity_scale(me, 1.1, 1.1)
	entity_setDropChance(me, 40, 1)
		
	--entity_setWeight(me, 300)
	entity_setState(me, STATE_IDLE)
	entity_setTarget(me, getNaija())
	--entity_setDropChance(me, 100)
end

function update(me, dt)
	dt = dt * 3

	if entity_touchAvatarDamage(me, 32, 1, 1000) then		
		entity_sound(me, "JellyBlup", 800)
	end
	
	entity_handleShotCollisions(me)
	
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
			--doIdleScale(me)
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
		--entity_addVel(me, v.velx*dt, -600*dt)
		--entity_rotateToVel(me, 1)
		entity_rotateTo(me, 0, 1)
		if not entity_isNearObstruction(getNaija(), 3) then
			entity_moveTowardsTarget(me, dt, 500)		
		end
	elseif v.moveState == MOVE_STATE_DOWN then
		entity_addVel(me, 0, 300*dt)
		--entity_moveTowardsTarget(me, dt, 50)
		entity_rotateTo(me, 0, 3)
		entity_exertHairForce(me, 0, 200, dt*0.6, -1)
	end
	
	entity_doEntityAvoidance(me, dt, 32, 1.0)
	entity_doCollisionAvoidance(me, 1.0, 8, 1.0)
	entity_updateMovement(me, dt)
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
		entity_setMaxSpeed(me, 50)
	elseif entity_isState(me, STATE_DEAD) then
		createEntity("Splitter2", "", entity_x(me)-16, entity_y(me))
		createEntity("Splitter2", "", entity_x(me)+16, entity_y(me))
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function exitState(me)
end
