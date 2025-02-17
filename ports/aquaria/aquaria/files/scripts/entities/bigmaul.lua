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
-- BIG MAUL
-- ================================================================================================

v.shotDelay = 2
v.shotDelay2 = 0
v.shots = 3
v.createtimer = 0.5

v.cr = 80

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	30,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	v.cr,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)

	entity_setDeathParticleEffect(me, "NewtExplode")
	entity_initSkeletal(me, "BigMaul")
	entity_scale(me, 1.5, 1.5)
	entity_animate(me, "idle", -1)

end

function update(me, dt)


	if not entity_hasTarget(me) then
		entity_findTarget(me, 1000)
	else
		v.shotDelay = v.shotDelay - dt
		if v.shotDelay < 0 then
			v.shotDelay2 = v.shotDelay2 - dt
			if v.shotDelay2 < 0 then
				-- FIXME: obsolete function
				--entity_fireAtTarget(me, 1, 1000, 1500, 5, 64)
				v.shots = v.shots - 1
				v.shotDelay2 = 0.2
				if v.shots <= 0 then
					v.shotDelay = 1
					v.shotDelay2 = 0
					v.shots = 3
				end
			end
		end
		entity_moveTowardsTarget(me, dt, 500)
		entity_flipToEntity(me, entity_getTarget(me))
	end

	v.createtimer = v.createtimer - dt
	if v.createtimer < 1 then
		local n = 10
		while n > 0 do
			createEntity("Maul", "", entity_x(me), entity_y(me))
			n = n - 1
		end
		v.createtimer = 30
	end

	entity_doEntityAvoidance(me, dt, 256, 0.2)
	entity_updateMovement(me, dt)
	
	entity_doCollisionAvoidance(me, dt, 8, 0.5)
	
	
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, v.cr, 1, 1000)
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_setMaxSpeed(me, 200)
	end
end

function exitState(me)
end

function activate(me)
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -2)
	end
	return true
end

function dieNormal(me)
	local p = randRange(1, 100)
	if p <= 10 then -- 10%
		spawnIngredient("ToughCake", entity_x(me), entity_y(me))
	elseif p > 10 and p <= 30 then -- 20%
		spawnIngredient("TastyCake", entity_x(me), entity_y(me))
	elseif p > 30 and p <= 40 then -- 10%
		spawnIngredient("RubberyMeat", entity_x(me), entity_y(me))
	elseif p > 40 and p <= 45 then -- 5%
		spawnIngredient("ArcanePoultice", entity_x(me), entity_y(me))
	end
end

