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

function v.commonInit(me, skel)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, skel)
	
	entity_setEntityLayer(me, 1)
	
	entity_setCollideRadius(me, 16)
	entity_setHealth(me, 12)
	
	entity_addVel(me, 1, 0)
	
	entity_setState(me, STATE_IDLE)
	
	local off = randRange(1, 100) * 0.002
	entity_scale(me, 1-off, 0.8-off)
	entity_scale(me, 0.8-off, 1-off, 0.5, -1, 1, 1)
	entity_rotate(me, 360, 30, -1)
	
	entity_setCullRadius(me, 128)
	
	v.glow = entity_getBoneByName(me, "glow")
	bone_setBlendType(v.glow, BLEND_ADD)
	bone_scale(v.glow, 10, 10)
	bone_alpha(v.glow, 0)
	
	entity_setUpdateCull(me, 2000)
	
	entity_setDeathSound(me, "")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	entity_update(me, randRange(1, 4)*0.1)
end

function v.commonUpdate(me, dt)
	
	entity_updateCurrents(me, dt)
	entity_updateMovement(me, dt)
	
	entity_doEntityAvoidance(me, dt, 40, 0.1)
	entity_doCollisionAvoidance(me, dt, 8, 0.5)
	
	--entity_handleShotCollisions(me)
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
