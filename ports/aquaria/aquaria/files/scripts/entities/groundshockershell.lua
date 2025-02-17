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

v.myWeight = 432
v.onSurface = 0

function init(me)
	setupBasicEntity(
	me,
	"GroundShocker/Shell",			-- texture
	3,								-- health
	0,								-- manaballamount
	0,								-- exp
	0,								-- money
	21,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000							-- updateCull -1: disabled, default: 4000
	)

	entity_setBounce(me, 0.2)	
	entity_setCanLeaveWater(me, true)
	
	entity_setAllDamageTargets(me, false)
	
	entity_setMaxSpeed(me, 640)
end

function update(me, dt)
	entity_handleShotCollisions(me)
	entity_updateMovement(me, dt)
	
	if entity_checkSplash(me) then
	end
	if not entity_isUnderWater(me) then
		if not entity_isBeingPulled(me) then
			entity_setWeight(me, v.myWeight*2)
			entity_setMaxSpeedLerp(me, 5, 0.1)
		end
	else
		entity_setMaxSpeedLerp(me, 1, 0.1)
		entity_setWeight(me, v.myWeight)
	end
	
	if entity_getVelLen(me) > 76 then 
		entity_rotateToVel(me, 0.34)
	end
	
	-- DESTROY IF ON SURFACE TOO LONG
	if v.onSurface > 3 then
		entity_alpha(me, 0, 0.12)
		entity_scale(me, 0, 0, 0.12)
		entity_delete(me, 0.12)
		spawnParticleEffect("GroundShockerShellDestroy", entity_x(me), entity_y(me))
	end
	
	entity_touchAvatarDamage(me, 32, 0.13, 321)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function hitSurface(me)
	v.onSurface = v.onSurface + 1
end
