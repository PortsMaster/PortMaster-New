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
v.targetBone = 0
v.ventBone = 0


local STATE_OPT		= 1001

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "ThermalVent")	
	entity_setEntityLayer(me, -2)
	entity_setAllDamageTargets(me, false)
	
	entity_generateCollisionMask(me)
		
	v.targetBone = entity_getBoneByName(me, "Target")
	v.ventBone = entity_getBoneByName(me, "Vent")
	
	bone_alpha(v.targetBone)
	bone_alpha(v.ventBone)
	entity_setState(me, STATE_IDLE)
	entity_setUpdateCull(me, 1100)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	--[[
	entity_handleShotCollisionsSkeletal(me)	
	]]--
	local e = getFirstEntity()
	while e ~= 0 do
		if e ~= me and eisv(e, EV_CRAWLING, 0) and entity_getName(e) ~= "thermalvent" then
			local x, y = bone_getWorldPosition(v.targetBone)
			local x2, y2 = bone_getWorldPosition(v.ventBone)
			if entity_collideCircleVsLine(e, x, y, x2, y2, 64) then
				entity_addVel(e, 0, -2000*dt)
			end
			
			if entity_collideCircleVsLine(e, x, y, x2, y2, 16) then
				y = entity_vely(e)
				entity_clearVel(e)
				if entity_x(v.n) < entity_x(me) then
					entity_addVel(e, -100, y)
				else
					entity_addVel(e, 100, y)
				end
			end
		end
		e = getNextEntity()
	end

	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		entity_touchAvatarDamage(me, 0, 0, 400, 0)
	end
	--[[
	if entity_isEntityInRange(me, v.n, 1000) then
		entity_setState(me, STATE_IDLE)
		entity_animate(me, "idle", -1)
	else
		entity_animate(me, "opt", -1)
	end	
	]]--
	entity_updateMovement(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_OPT) then
		entity_animate(me, "opt", -1)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
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

function activate(me)
end

