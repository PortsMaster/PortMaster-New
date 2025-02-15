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

-- WISKER

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.fireDelay = 2
v.moveTimer = 0
v.charge = 0

local STATE_CHARGE = 1000
local STATE_DELAY = 1001
v.inited = false

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	6,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	64,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	256,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	3000							-- updateCull -1: disabled, default: 4000
	)
	entity_scale(me, 0.75, 0.75)
	entity_setDropChance(me, 25)
	entity_clampToSurface(me)
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
	entity_initSkeletal(me, "Wisker")
	entity_setState(me, STATE_IDLE)
	esetv(me, EV_WALLOUT, 10)
	entity_setEatType(me, EAT_FILE, "Wisker")
end

function update(me, dt)


	if entity_isState(me, STATE_IDLE) then
		entity_moveAlongSurface(me, dt, 140, 6, 30)
		entity_rotateToSurfaceNormal(me, 0.1)

		-- entity_rotateToSurfaceNormal(0.1)
		v.moveTimer = v.moveTimer + dt
		if v.moveTimer > 4 then
			entity_switchSurfaceDirection(me)
			v.moveTimer = 0
		end	
		if not(entity_hasTarget(me)) then
			entity_findTarget(me, 1200)
		else
			if v.fireDelay > 0 then
				v.fireDelay = v.fireDelay - dt
				if v.fireDelay < 0 then
					v.fireDelay = 3
					entity_setState(me, STATE_CHARGE)
				end
			end
		end
	end
	if entity_isState(me, STATE_DELAY) then
		entity_moveAlongSurface(me, dt, 60, 6, 10)
		entity_rotateToSurfaceNormal(me, 0.1)
	end
	entity_handleShotCollisions(me)
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 500) then
		setPoison(1, 12)
	end
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_animate(me, "waddle", -1)
	elseif entity_isState(me, STATE_CHARGE) then
		entity_setStateTime(me, entity_animate(me, "charge"))
	elseif entity_isState(me, STATE_DELAY) then
		entity_animate(me, "idle", -1)
		entity_setStateTime(me, 1)
	end
end

local function fireShot(me, a)
	local s = createShot("WiskerShot", me, entity_getTarget(me))
	shot_setAimVector(s, entity_getAimVector(me, a, 1))
	shot_setOut(s, 32)
	
end

function exitState(me)
	if entity_isState(me, STATE_CHARGE) then
		--entity_doGlint(me, "Particles/PurpleFlare")
		
		entity_sound(me, "SpineFire")
		fireShot(me, -45)
		fireShot(me, 0)
		fireShot(me, 45)
		
		entity_setState(me, STATE_DELAY)
	elseif entity_isState(me, STATE_DELAY) then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me)
	return true
end

function hitSurface(me)
end
