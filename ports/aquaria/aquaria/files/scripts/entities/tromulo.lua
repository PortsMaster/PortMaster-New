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

-- Tromulo


-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

v.size = 0
v.size0 = 0.6
--[[

v.size1 = 0.65
v.size2 = 0.7
v.size3 = 0.75
v.size4 = 1.8
v.size5 = 1.85
v.size6 = 1.2
v.size7 = 1.3
v.size8 = 1.4
]]--

v.spd = 500
v.angle = 0
v.turnSpeed = 3.14
v.dir = 1
v.rotateTimer = 1
v.straightLineTimer = 0

function init(me)
	setupBasicEntity(
	me,
	"Tromulo",						-- texture
	4,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	0,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	128,							-- sprite width
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1							-- updateCull -1: disabled, default: 4000
	)
	entity_scale(me, v.size0, v.size0)
	-- 2.5
	entity_setSegs(me, 2, 8, 0.8, 0.8, -0.018, 0, 6, 1)
	entity_setCollideRadius(me, 16)
	entity_initPart(me, "Tentacles", "Tromulo-Tentacles", 0, 16, 0)
	entity_partSetSegs(me, "Tentacles", 2, 32, 0.3, 0.3, -0.03, 0, 6, 1)
	v.angle = math.random(314*2)/100.0
	entity_setDeathParticleEffect(me, "Explode")
	entity_setInternalOffset(me, 0, 8)
end

local function getRadius(me)
	return 32 + v.size*9
end

function dieNormal(me)
	if chance(5) then
		spawnIngredient("SmallTentacle", entity_x(me), entity_y(me))
	end
end

function update(me, dt)
	dt = dt * 0.75

		
	v.angle = v.angle + v.turnSpeed * dt * v.dir
	
	if not entity_hasTarget(me) then
		entity_findTarget(me, 1200)		
	end
	if entity_hasTarget(me) then
		if entity_isTargetInRange(me, 128) then
			entity_moveTowardsTarget(me, dt, -400)
		elseif not entity_isTargetInRange(me, 600) then
			entity_moveTowardsTarget(me, dt, 500)
		end		
	end
	if v.rotateTimer > 0 then
		entity_addVel(me, math.sin(v.angle)*v.spd, math.cos(v.angle)*v.spd)
	end
	if v.straightLineTimer > 0 then 
		entity_doFriction(me, dt, 1)
	end
	
	if v.straightLineTimer > 0 then
		v.straightLineTimer = v.straightLineTimer - dt
		if v.straightLineTimer < 0 then
			v.straightLineTimer = 0
			v.rotateTimer = 2
		end
	end
	
	if v.rotateTimer > 0 then
		v.rotateTimer = v.rotateTimer - dt
		if v.rotateTimer < 0 then
			v.rotateTimer = 0
			v.straightLineTimer = 2
		end
	end
	
	entity_doCollisionAvoidance(me, dt, 4, 1)
	entity_doEntityAvoidance(me, dt, 128, 0.5)
		
	entity_updateMovement(me, dt)
	
	entity_handleShotCollisions(me)
	
	entity_touchAvatarDamage(me, getRadius(me), 0.5, 1200)
end

function hitSurface(me)
	v.dir = -v.dir
end

function damage(me, attacker, bone, damageType, dmg)
	if not entity_isInvincible(me) and (damageType == DT_AVATAR_ENERGYBLAST or damageType == DT_AVATAR_SHOCK) then
		entity_heal(me, 999)
		
		v.size = v.size + dmg
		if v.size >= 8 then
			entity_setState(me, STATE_DEAD)
		end	
		--entity_setCollideRadius(me, getRadius(me))
		entity_setCollideRadius(me, entity_getCollideRadius(me)+(8+(v.size*0.5)))
		
		local sz = v.size0 + (v.size * 0.2)
		entity_scale(me, sz, sz, 0.5)
	end
	return true
end

function enterState(me)
	if entity_isState(me, STATE_DEAD) then
		--local shotSpd = 500
		local maxa = 3.14 * 2
		local a = 0
		while a < maxa do
			--entity_fireShot(me, 0, 0, math.sin(a)*shotSpd, math.cos(a)*shotSpd, 0, 500, "BlasterFire")
			local s = createShot("Tromulo", me)
			shot_setAimVector(s, math.sin(a), math.cos(a))
			a = a + (3.14*2)/16.0
		end
	end
end

function exitState(me)
end
