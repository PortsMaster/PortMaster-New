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

v.pullTimer		= 1.5
v.dieTimer		= 0

v.glow = 0

v.hits = 16

local STATE_BLIND	= 1000
local STATE_PULLABLE= 1001

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "eyespiral")
	
	entity_setState(me, STATE_IDLE)
	
	v.glow = entity_getBoneByName(me, "glow")
	
	bone_scale(v.glow, 4, 4, 1)
	bone_scale(v.glow, 8, 8, 1, -1, 1)
	bone_alpha(v.glow, 0)
	
	bone_rotate(v.glow, 360, 1, -1)
	
	entity_setCollideRadius(me, 90)
	
	entity_scale(me, 1.5, 1.5)
	
	bone_setBlendType(v.glow, BLEND_ADD)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	v.creatorform6 = entity_getNearestEntity(me, "creatorform6")
end

function update(me, dt)
	entity_updateMovement(me, dt)
	
	
	
	
	if v.dieTimer > 0 then
		entity_addVel(me, -1000*dt, 0)
		v.dieTimer = v.dieTimer - dt
		if v.dieTimer <= 0 then
			v.dieTimer = 0
			entity_msg(v.creatorform6, "eyedied")
			entity_delete(me)
			return
		end
	end
	
	if entity_isState(me, STATE_PULLABLE) then
		if entity_isBeingPulled(me) then
			v.pullTimer = v.pullTimer - dt
			if v.pullTimer <= 0 then
				entity_msg(v.creatorform6, "eyepopped")
				entity_setProperty(me, EP_MOVABLE, false)
				
				entity_addVel(me, -1000, 0)
				
				entity_alpha(me, 0, 2)
				
				v.dieTimer = 2
				
				v.pullTimer = 0
			end
		end
	end
	
	entity_updateMovement(me, dt)
	
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 800)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		bone_alpha(v.glow, 0, 1)
		entity_setColor(me, 1, 1, 1, 0.5)
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_BLIND) then
		--[[
		entity_setColor(me, 1, 1, 1)
		entity_setColor(me, 1, 0.5, 0.5, 0.2, -1, 1)
		]]--
		bone_alpha(v.glow, 0.5, 1)
		
	elseif entity_isState(me, STATE_PULLABLE) then
		entity_color(me, 0.2, 0.2, 0.2, 3)
		entity_offset(me, -5, 0)
		entity_offset(me, 5, 0, 0.04, -1, 1)
		entity_setProperty(me, EP_MOVABLE, true)
	end
end

function exitState(me)
	if entity_isState(me, STATE_BLIND) then
		bone_alpha(v.glow, 0, 1)
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	debugLog("hit eyespiral")
	if entity_isState(me, STATE_BLIND) then
		bone_damageFlash(entity_getBoneByIdx(me, 0))
		v.hits = v.hits - dmg
		if v.hits <= 0 then
			entity_setState(me, STATE_PULLABLE)
		end
		return false
	else
		playNoEffect()
	end
	
	entity_changeHealth(me, 100)
	
	return false
end

function lightFlare(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setState(me, STATE_BLIND, 6)
	end
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


