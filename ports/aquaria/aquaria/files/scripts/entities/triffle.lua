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

v.glow = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "Triffle")	
	entity_setAllDamageTargets(me, true)
	
	--entity_generateCollisionMask(me)	
	
	entity_setEntityLayer(me, 1)
	entity_setCollideRadius(me, 32)	
	
	v.glow = createQuad("Naija/LightFormGlow", 13)
	
	local boneGlow = entity_getBoneByName(me, "Glow")
	bone_alpha(boneGlow, 0.5)
	bone_alpha(boneGlow, 1, 0.5, -1, 1, 1)
	bone_setSegs(entity_getBoneByName(me, "Body"), 2, 16, 0.6, 0.6, -0.058, 0, 6, 1)
	
	entity_setState(me, STATE_IDLE)
	
	local diff = math.random(2500)/10000.0
	local sz = 1-diff
	entity_scale(me, sz, sz)
	
	quad_scale(v.glow, 3*sz, 3*sz)
	
	entity_setDeathParticleEffect(me, "TinyBlueExplode")
	
	entity_setDropChance(me, 10, 1)
	entity_setHealth(me, 4)
	entity_setUpdateCull(me, 2000)
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	entity_update(me, math.random(1000)/1000.0)
end

function update(me, dt)
	entity_handleShotCollisions(me)
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0, 100) and avatar_isBursting() then
		local x, y = entity_getVectorToEntity(v.n, me)
		x, y = vector_setLength(x,y,500)
		entity_addVel(me, x, y)
		entity_doCollisionAvoidance(me, dt, 8, 0.5)
	end
	entity_doEntityAvoidance(me, dt, 40, 1)
	entity_doCollisionAvoidance(me, dt, 2, 1)	
	entity_doFriction(me, dt, 200)
	entity_updateMovement(me, dt)
	quad_setPosition(v.glow, entity_getPosition(me))
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_DEAD) then
		quad_delete(v.glow, 1)
		local l = createQuad("Naija/LightFormGlow", 13)
		quad_setPosition(l, entity_getPosition(me))
		quad_color(l, 0.7, 0.5, 1)
		quad_scale(l)
		quad_scale(l, 8, 8, 0.5, 0, 0, 1)
		quad_delete(l, 8)
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

