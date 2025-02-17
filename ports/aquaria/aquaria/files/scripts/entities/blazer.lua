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

-- blazer

v.dir = 0
v.dropTimer = 0

function init(me)
	setupBasicEntity(
	me,
	"Blazer",						-- texture
	6,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	3000							-- updateCull -1: disabled, default: 4000
	)
		
	entity_setDeathParticleEffect(me, "Explode")
	entity_setEatType(me, EAT_FILE, "Blazer")
end

function update(me, dt)
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, 32, 0.5, 1000)
	
	v.dropTimer = v.dropTimer + dt
	local t = 0.2
	if v.dropTimer > t then
		--shot = entity_fireShot(me, 0, 0, 0, 0, 0, 0, "")
		--shot_setLifeTime(shot, 1.5)
		
		local sx,sy = entity_getPosition(me)
		local nx,ny = entity_getNormal(me)
		local l = 32
		sx = sx - nx*l
		sy = sy - ny*l
		createShot("DropShot", me, 0, sx, sy)
		
		v.dropTimer = v.dropTimer - t
	end
	local amt = 2500*dt
	if v.dir == 0 then
		entity_addVel(me, -amt, amt)
	elseif v.dir == 1 then
		entity_addVel(me, -amt, -amt)
	elseif v.dir == 2 then
		entity_addVel(me, amt, amt)
	elseif v.dir == 3 then
		entity_addVel(me, amt, -amt)
	end
	--entity_doEntityAvoidance(me, dt, 256, 0.2)
--	entity_doSpellAvoidance(dt, 200, 1.5);
	--entity_doCollisionAvoidance(me, dt, 6, 0.5)
	entity_rotateToVel(me, 0.1)
	entity_updateMovement(me, dt)
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_setMaxSpeed(me, 500)
	end
end

function exitState(me)
end

function hitSurface(me)
	v.dir = v.dir + 1
	if v.dir > 3 then
		v.dir = 0
	end
end

function activate(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -1)
	end
	return true
end

function dieNormal(me)
	if chance(75) then
		spawnIngredient("SpicyMeat", entity_x(me), entity_y(me))
	end
end
