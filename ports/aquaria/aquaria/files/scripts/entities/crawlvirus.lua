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
-- R A S P B E R R Y
-- ================================================================================================

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.fireDelay = 2
v.moveTimer = 0
v.shots = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	4,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	32,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	entity_initSkeletal(me, "crawlvirus")
	entity_setCullRadius(me, 64)
	--entity_setEatType(me, EAT_FILE, "Raspberry")
	entity_scale(me, 0.75, 0.75)
	entity_clampToSurface(me)
	entity_setDeathParticleEffect(me, "PurpleExplode")
	entity_setSegs(me, 2, 16, 0.6, 0.6, -0.028, 0, 6, 1)
	esetv(me, EV_WALLOUT, 12)
	esetvf(me, EV_CLAMPTRANSF, 0.2)
	entity_animate(me, "walk", -1)
end

function update(me, dt)
	if eisv(me, EV_CLAMPING, 0) then
		-- dt, pixelsPerSecond, climbHeight, outfromwall
		-- out: 24
		entity_moveAlongSurface(me, dt, 40, 6)
		entity_rotateToSurfaceNormal(me, 0.1)
		-- entity_rotateToSurfaceNormal(0.1)
		v.moveTimer = v.moveTimer + dt
		if v.moveTimer > 10 then
			entity_switchSurfaceDirection(me)
			v.moveTimer = 0
		end
		if not(entity_hasTarget(me)) then
			entity_findTarget(me, 1200)
		else
			if v.fireDelay > 0 then
				v.fireDelay = v.fireDelay - dt
				if v.fireDelay < 0 then
					entity_animate(me, "shoot", 0, 1)

					local nx, ny = entity_getNormal(me)
					nx, ny = vector_setLength(nx, ny, 64)
				
					local s = createShot("crawlvirus", me, entity_getTarget(me), entity_x(me)+nx, entity_y(me)+ny)
					
					v.shots = v.shots + 1
					if v.shots >= 3 then
						v.shots = 0
						v.fireDelay = 2
					else
						v.fireDelay = 0.5
					end
				end
			end
		end
	end
	
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0.5, 500)	
end

function dieNormal(me)
end

--[[
function diedFrom(attacker, damageType)
	if damageType ~= DT_AVATAR_BITE then
		spawnIngredient("RubberyMeat", entity_getPosition(me))
	end
end
]]--

function enterState(me)
	if entity_getState(me)==STATE_IDLE then	
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE or attacker == me then
		entity_changeHealth(me, -99)
	end
	return true
end

function exitState(me)
end

function hitSurface(me)
end
