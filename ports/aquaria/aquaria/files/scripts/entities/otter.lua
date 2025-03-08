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

v.n = 0
v.ing = 0
v.ingToSpawn = 0
v.amount = 0
v.cycle = 0
v.cycleMax = 5
v.phase = 0

v.hits = 2
v.hitDelay = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "otter")	
	
	entity_setHealth(me, 6)
	
	entity_setCollideRadius(me, 32)
	
	entity_setState(me, STATE_IDLE)
	
	v.ing = entity_getBoneByName(me, "ing")
	
	entity_scale(me, 0.7, 0.7)
	
	entity_addVel(me, randVector(400))
	
	entity_setUpdateCull(me, 3000)
	entity_setCullRadius(me, 300)

	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	
	entity_setInternalOffset(me, 0, -10)
	entity_setInternalOffset(me, 0, 10, 0.5, -1, 1)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	bone_alpha(v.ing, 0)
	
	local n1 = getNearestNodeByType(entity_x(me), entity_y(me), PATH_SETING)
	if n1 ~= 0 and node_isEntityIn(n1, me) then
		v.ingToSpawn = node_getContent(n1)
		v.amount = node_getAmount(n1)	if v.amount == 0 then v.amount = 1 end
		bone_alpha(v.ing, 1)
		bone_setTexture(v.ing, string.format("ingredients/%s", getIngredientGfx(v.ingToSpawn)))
		--bone_scale(v.ing, 0.9, 0.9)
	end
end

function update(me, dt)
	if v.hitDelay > 0 then
		v.hitDelay = v.hitDelay - dt
		if v.hitDelay < 0 then
			v.hitDelay = 0
		end
	end
	
	v.cycle = v.cycle + dt
	if v.cycle > v.cycleMax then
		v.cycle = 0
		v.phase = v.phase + 1
		if v.phase > 1 then
			v.phase = 0
		end
		
		if v.phase == 0 then
			entity_setMaxSpeedLerp(me, 0.5, 3)
			entity_addVel(me, randVector(400))
			spawnParticleEffect("bubble-release", entity_x(me), entity_y(me))
		elseif v.phase == 1 then
			entity_setMaxSpeedLerp(me, 1.5, 3)
		end
	end
	
	entity_doCollisionAvoidance(me, dt, 4, 1)
	
	entity_doCollisionAvoidance(me, dt, 6, 0.1)

	entity_updateMovement(me, dt)
	entity_handleShotCollisions(me)
	
	entity_rotateToVel(me, 0.1)
	
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0, 1000) then
		if avatar_isBursting() then
			if v.hitDelay <= 0 then
				v.hits = v.hits - 1
				entity_offset(me, 0, 0)
				entity_offset(me, 10, 0, 0.05, 4, 1)
				playSfx("hit-soft")
				entity_moveTowardsTarget(me, -1, 1000)
				if v.hits <= 0 and v.ingToSpawn ~= 0 then
					playSfx("secret")
					bone_alpha(v.ing, 0)
					for i=1,v.amount do
						i = spawnIngredient(v.ingToSpawn, entity_x(me), entity_y(me), 1, (i==1))
					end
					v.ingToSpawn = 0
				end
				v.hitDelay = 0.5
			end
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

