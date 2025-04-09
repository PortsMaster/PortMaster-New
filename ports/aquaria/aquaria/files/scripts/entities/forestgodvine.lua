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
v.growTime		= 0.2
v.size			= 32
v.life			= 4

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	
	entity_setTexture(me, "ForestGod/Vine")
	
	entity_setCollideRadius(me, v.size)
	entity_setState(me, STATE_IDLE)
	
	entity_setCanLeaveWater(me, true)
	
	entity_alpha(me, 0)
	entity_alpha(me, 1, 0.2)
	
	entity_setEntityLayer(me, -1)
	
	entity_setDeathSound(me, "")
	

	--[[
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	entity_setDamageTarget(me, DT_AVATAR_BITE, false)
	]]--
	entity_setAllDamageTargets(me, false)
	
	entity_scale(me, 1.2, 1.2)
	esetv(me, EV_LOOKAT, 0)
	
	esetv(me, EV_TYPEID, EVT_FORESTGODVINE)
end

function postInit(me)
	v.n = getNaija()
end

function songNote(me, note)
end

function update(me, dt)
	if v.life < 0 then return end
	
	if entity_getAlpha(me) > 0.6 then
		if entity_touchAvatarDamage(me, v.size, 1, 1000) then
			entity_clearVel(v.n)
			entity_touchAvatarDamage(me, v.size, 1, 1000)
		end
	end
	
	v.life = v.life - dt
	if v.life < 0 then
		entity_delete(me, 0.5)
		entity_alpha(me, 0, 0.5)
	end
	
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, true)
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, true)
	
	entity_handleShotCollisions(me)
	
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
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
		--entity_setHealth(me, 0)
		--return true
		return false
	end
	return false
end

function exitState(me)
end
