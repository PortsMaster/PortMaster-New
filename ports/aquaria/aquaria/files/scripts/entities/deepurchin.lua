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
v.boneGlow = 0
v.dir = 1
v.dirTimer = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "DeepUrchin")
	
	entity_setHealth(me, 12)
	
	entity_setAllDamageTargets(me, false)
	
	entity_setCollideRadius(me, 80)
	
	entity_setState(me, STATE_IDLE)
	
	v.boneGlow = entity_getBoneByName(me, "Glow")
	v.glow = createQuad("Naija/LightFormGlow", 13)
	quad_scale(v.glow, 8, 8)
	quad_alpha(v.glow, 0)
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, true)
	entity_setUpdateCull(me, 3000)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	entity_handleShotCollisions(me)
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 800) then		
	end
	
	v.dirTimer = v.dirTimer + dt
	if v.dirTimer > 3 then
		v.dirTimer = 0
		v.dir = -v.dir
	end
	
	entity_addVel(me, 1000*dt*v.dir, 0)
	
	entity_updateMovement(me, dt)
	quad_setPosition(v.glow, entity_getPosition(me))
	
	
	
	if entity_isEntityInRange(me, v.n, 256) then
		quad_alpha(v.glow, 1, 0.8)
		bone_alpha(v.boneGlow, 1, 0.8)
	else
		quad_alpha(v.glow, 0, 0.3)
		bone_alpha(v.boneGlow, 0, 0.3)
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_DEAD) then
		quad_delete(v.glow)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg, x, y)
	if damageType == DT_AVATAR_SHOCK then
		x,y = entity_getPosition(v.n)
	end
	if damageType == DT_AVATAR_ENERGYBLAST or damageType == DT_AVATAR_SHOCK then
		if y > entity_y(me) + 50 and x > entity_x(me)-32 and x < entity_x(me)+32 then
			return true
		end
	end
	return false
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

