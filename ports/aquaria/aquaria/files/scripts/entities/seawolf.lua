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

v.grab = 0
v.head = 0

v.attached = 0

local STATE_LUNGE		= 1000
local STATE_BACK		= 1001
local STATE_WAIT2		= 1002

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "seawolf")
	
	entity_setEntityLayer(me, 1)
	
	entity_setAllDamageTargets(me, false)
	
	v.grab = entity_getBoneByName(me, "grab")
	v.head = entity_getBoneByName(me, "head")
	
	--entity_generateCollisionMask(me)	
	
	entity_setState(me, STATE_IDLE)
	
	entity_setCullRadius(me, 2000)
	entity_setUpdateCull(me, 2300)
	
	bone_alpha(v.grab, 0)
	
	entity_offset(me, 0, -5)
	entity_offset(me, 0, 5, 1, -1, 1, 1)
	
	loadSound("seawolf")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	local node = entity_getNearestNode(me, "flip")
	if node ~= 0 then
		if node_isEntityIn(node, me) then
			entity_fh(me)
		end
	end
end

function update(me, dt)
	--entity_updateMovement(me, dt)
	local bx, by = bone_getWorldPosition(v.grab)
	
	if entity_isState(me, STATE_IDLE) then
		--debugLog(string.format("%f, %f", bx, by))
		if entity_isPositionInRange(v.n, bx, by, 160) then
			debugLog("SETTING STATE LUNGE")
			entity_setState(me, STATE_LUNGE)
		end
	end
	
	local bx2, by2 = bone_getWorldPosition(v.head)
	if v.attached ~= 0 then
		entity_setPosition(v.attached, bx2, by2)
	end
	
	--[[
	entity_handleShotCollisionsSkeletal(me)
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	]]--
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_LUNGE) then
		playSfx("seawolf")
		entity_setStateTime(me, entity_animate(me, "lunge"))
	elseif entity_isState(me, STATE_WAIT) then
		if v.attached ~= 0 then
			entity_setStateTime(me, 3)
		else
			entity_setStateTime(me, 0.1)
		end
	elseif entity_isState(me, STATE_BACK) then
		debugLog("back")
		entity_setStateTime(me, entity_animate(me, "back"))
	end
end

function exitState(me)
	if entity_isState(me, STATE_LUNGE) then
		local bx, by = bone_getWorldPosition(v.grab)
		if entity_isPositionInRange(v.n, bx, by, 160) then
			v.attached = v.n
		end
		if v.attached ~= 0 then
			entity_damage(v.attached, me, 1)
		end
		entity_setState(me, STATE_WAIT)
	elseif entity_isState(me, STATE_WAIT) then
		entity_setState(me, STATE_BACK)
	elseif entity_isState(me, STATE_WAIT2) then
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_BACK) then
		if v.attached ~= 0 then
			if v.attached == v.n then
				--centerText("Lost Ingredients!")
				local vx, vy = entity_getNormal(me)
				local p = vy
				vy = -vx
				vx = p
				if entity_isfh(me) then
					vx = -vx
				end
				vx, vy = vector_setLength(vx, vy, 2000)
				entity_idle(v.n)
				entity_push(v.n, vx, vy, 1, 3000, 0.5)
			end
				
		end
		v.attached = 0
		entity_setState(me, STATE_WAIT2, 3)
	end
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

