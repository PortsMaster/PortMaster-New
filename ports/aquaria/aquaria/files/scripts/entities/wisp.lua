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
v.mld = 0.2
v.ld = v.mld
v.note = -1
v.excited = 0
v.glow = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_setTexture(me, "Wisp")
	entity_setAllDamageTargets(me, true)
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	
	entity_setCollideRadius(me, 20)
	
	entity_setState(me, STATE_IDLE)
	entity_addRandomVel(me, 500)
	
	v.glow = createQuad("Naija/LightFormGlow", 13)
	quad_scale(v.glow, 2, 2)	
	
	entity_setHealth(me, 6)
	
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	
	entity_setUpdateCull(me, 3000)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function dieNormal(me)
	if chance(5) then
		spawnIngredient("GlowingEgg", entity_x(me), entity_y(me))
	end
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	v.ld = v.ld - dt
	if v.ld < 0 then
		v.ld = v.mld
		local l = createQuad("Naija/LightFormGlow", 13)
		local r = 1
		local g = 1
		local b = 1
		if v.note ~= -1 then
			r, g, b = getNoteColor(v.note)
			r = r*0.5 + 0.5
			g = g*0.5 + 0.5
			b = b*0.5 + 0.5
		end
		quad_setPosition(l, entity_getPosition(me))
		quad_scale(l, 1.5, 1.5)
		quad_alpha(l, 0)
		quad_alpha(l, 1, 0.5)
		quad_color(l, r, g, b)		
		quad_delete(l, 4)
		quad_color(v.glow, r, g, b, 0.5)
	end
	--entity_doCollisionAvoidance(me, dt, 8, 0.2)
	entity_doCollisionAvoidance(me, dt, 4, 0.8)
	entity_updateMovement(me, dt)
	entity_handleShotCollisions(me)
	--entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 500)	
	if v.excited > 0 then
		v.excited = v.excited - dt
		if v.excited < 0 then
			entity_addRandomVel(me, 500)
		end
		if entity_isTargetInRange(me, 256) then
			entity_moveAroundTarget(me, dt, 1000)
		else
			entity_moveTowardsTarget(me, dt, 400)
		end
	end
	if not entity_isRotating(me) then
		entity_rotateToVel(me, 0.2)
	end
		
	quad_setPosition(v.glow, entity_getPosition(me))
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
	elseif entity_isState(me, STATE_DEAD) then
		quad_delete(v.glow, 1)
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

function songNote(me, n)
	v.note = n
	v.excited = 10
	--entity_rotate(me, entity_getRotation(me)+360, 0.5, 0, 0, 1)
	quad_scale(v.glow, 2, 2)
	quad_scale(v.glow, 4, 4, 0.5, 1, 1, 1)
	entity_setMaxSpeedLerp(me, 1.25)
	entity_setMaxSpeedLerp(me, 1, 3)
end

function songNoteDone(me, note)
	v.excited = 3
end

function song(me, song)
end

function activate(me)
end

