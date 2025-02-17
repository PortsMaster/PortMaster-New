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

v.timer			= 0
v.growTime		= 0.1
v.size			= 32
v.life			= 10
v.moveTowards	= 400

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_setTexture(me, "ForestGod/Vine-Head")
	
	entity_setCollideRadius(me, v.size)
	entity_setState(me, STATE_IDLE)
	
	entity_setCanLeaveWater(me, true)
	
	entity_alpha(me, 0)
	entity_alpha(me, 1, 0.5)
	
	entity_setDeathSound(me, "")
	
	entity_scale(me, 1.2, 1.2)
	
	entity_setHealth(me, 4)
	
	entity_setMaxSpeed(me, 500)
	
	entity_setDamageTarget(me, DT_AVATAR_VINE, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	entity_setDamageTarget(me, DT_AVATAR_BITE, false)
	
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	esetv(me, EV_TYPEID, EVT_FORESTGODVINE)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function songNote(me, note)
end

function update(me, dt)
	if v.life < 0 then return end
	if v.timer ~= -1 then
		v.timer = v.timer + dt
		if v.timer > v.growTime then
			v.timer = 0
			local e = createEntity("ForestGodVine", "", entity_x(me), entity_y(me))
			entity_rotate(e, entity_getRotation(me))
		end
	end
	v.moveTowards = v.moveTowards + dt*100
	entity_moveTowardsTarget(me, dt, v.moveTowards)
	entity_updateMovement(me, dt)
	entity_handleShotCollisions(me)
	entity_rotateToVel(me)
	
	if entity_getAlpha(me) > 0.6 then
		entity_touchAvatarDamage(me, v.size, 1, 500)
	end
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_OFF) then
		v.life = 0
		entity_delete(me, 0.5)
		entity_alpha(me, 0, 0.5)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_setHealth(me, 0)
	end
	return true
end

function exitState(me)
end
