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
-- EEL
-- ================================================================================================

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

v.dir = 0
v.switchDirDelay = 0
v.wiggleTime = 0
v.wiggleDir = 1
v.interestTimer = 0
v.colorRevertTimer = 0

v.collisionSegs = 32
v.avoidLerp = 0
v.avoidDir = 1
v.glow = 0
v.glowBone = 0

function init(me)
-- oldhealth : 40
	setupBasicEntity(
	me,
	"",						-- texture
	6,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	2500							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setDropChance(me, 50)
	
	entity_initHair(me, 64, 8, 32, "DeepEel/Tail")
	
	entity_initSkeletal(me, "DeepEel")

	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	entity_addVel(me, math.random(1000)-500, math.random(1000)-500)
	entity_setDeathParticleEffect(me, "TinyBlueExplode")
	
	entity_setState(me, STATE_IDLE)
	
	entity_setDeathScene(me, true)
	
	v.glow = createQuad("Naija/LightFormGlow", 13)
	quad_scale(v.glow, 1.5, 1.5)
	--quad_scale(v.glow, 1.8, 1.8, 1, -1, 1, 1)
	v.glowBone = entity_getBoneByName(me, "Glow")
end

function dieNormal(me)
	if chance(5) then
		spawnIngredient("GlowingEgg", entity_x(me), entity_y(me))
	end
end

function update(me, dt)
	
	if entity_getState(me)==STATE_IDLE then
		if entity_isEntityInRange(me, v.n, 800) then
			entity_moveTowardsTarget(me, dt, 500)
			entity_setMaxSpeedLerp(me, 0.8, 0.5)
		else
			entity_setMaxSpeedLerp(me, 1, 0.8)
		end
		
		entity_doEntityAvoidance(me, dt, 32, 0.1)
		entity_doCollisionAvoidance(me, dt, 10, 0.1)
		entity_doCollisionAvoidance(me, dt, 4, 0.8)
	end
	entity_updateMovement(me, dt)	
	entity_setHairHeadPosition(me, entity_x(me), entity_y(me))
	entity_updateHair(me, dt)
	entity_handleShotCollisionsHair(me, v.collisionSegs)
	--entity_handleShotCollisions(me)
	if entity_collideHairVsCircle(me, v.n, v.collisionSegs) then
		entity_touchAvatarDamage(me, 0, 0.5, 500)
	end
	entity_rotateToVel(me)
	entity_flipToVel(me)
	
	quad_setPosition(v.glow, bone_getWorldPosition(v.glowBone))
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setMaxSpeed(me, 600)
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		entity_clearVel(me)
		entity_setStateTime(me, 1.5)
		for i=32,1,-6 do
			local x, y = entity_getHairPosition(me, i)
			spawnParticleEffect("TinyBlueExplode", x, y, 0.2*((32-i)/6.0))
		end
	elseif entity_isState(me, STATE_DEAD) then
		quad_delete(v.glow)
	end
end

function exitState(me)
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	entity_setMaxSpeedLerp(me, 3)
	entity_setMaxSpeedLerp(me, 1,2)

	return true
end

function songNote(me, note)
end
