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
-- M A U L
-- ================================================================================================

-- entity specific
local STATE_FIRE			= 1000
local STATE_PULLBACK		= 1001
v.fireDelay = 0
v.spread = 5

v.dir = 0
v.n = 0
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"Loper",						-- texture
	12,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	20,								-- collideRadius 
	STATE_IDLE,						-- initState
	64,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1							-- updateCull -1: disabled, default: 4000
	)
		
	entity_setDropChance(me, 10)
	
	--entity_setSegs(me, 16, 2, 0.2, 0.2, 0, -0.03, 32, 0)
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	v.n = getNaija()
	entity_setTarget(me, v.n)
	entity_setEatType(me, EAT_FILE, "Loper")
end

function update(me, dt)	
	entity_handleShotCollisions(me)	
	entity_touchAvatarDamage(me, 20, 1, 1200)
	
	if v.dir == 0 then
		entity_addVel(me, -1000, 0)
	else
		entity_addVel(me, 1000, 0)
	end
	
	if entity_isEntityInRange(me, v.n, 512) then
		if (entity_isFlippedHorizontal(me) and entity_x(v.n) > entity_x(me)) or
		(not entity_isFlippedHorizontal(me) and entity_x(v.n) <= entity_x(me)) then
			entity_setMaxSpeedLerp(me, 0.5, 0.2)
			v.fireDelay = v.fireDelay + dt
			if v.fireDelay > 0.2 then
				v.fireDelay = 0
				if v.spread < 0 then
					v.spread = 6
				end
				v.spread = v.spread - 1
				if v.spread == 0 then
					v.spread = -1
					v.fireDelay = -1
				else
					local s = createShot("Loper", me, entity_getTarget(me))
					--[[
					s = entity_fireAtTarget(me, "Purple", 1, 500, 800, 3, 64)
					shot_setNice(s, "Shots/FatSpine", "", "SpineHit")
					]]--
				end
			end
		end
	else
		if v.fireDelay < 0 then
			v.fireDelay= v.fireDelay + dt
		end
		entity_setMaxSpeedLerp(me, 1.0, 0.2)
	end
	
	entity_updateMovement(me, dt)
end

function enterState(me)
end

function exitState(me)
end

function hitSurface(me)
	entity_flipHorizontal(me)
	if v.dir == 0 then
		v.dir = 1
	elseif v.dir == 1 then 
		v.dir = 0
	end
end

function activate(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -6)
	end
	return true
end

function dieNormal(me)
	if chance(35) then
		spawnIngredient("GlowingEgg", entity_getPosition(me))
	end
end
