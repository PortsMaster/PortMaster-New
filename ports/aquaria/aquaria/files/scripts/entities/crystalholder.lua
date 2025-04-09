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

-- CrystalHolder

v.charge = 0
v.delay = 1
v.glow = 0
v.crystal = 0
v.lx = 0
v.ly = 0
v.setWaterLevel = false


local STATE_DROPPED 	= 1000
local STATE_ROTATE	= 1001

function init(me)
	setupEntity(me)
	--entity_setProperty(me, EP_SOLID, true)
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	entity_setProperty(me, EP_MOVABLE, true)
	entity_setCollideRadius(me, 32)
	
	entity_setMaxSpeed(me, 450)
	--entity_setMaxSpeed(me, 600)
	
	entity_setEntityType(me, ET_NEUTRAL)
	
	entity_initSkeletal(me, "CrystalHolder")
	entity_animate(me, "idle")
	
	v.glow = entity_getBoneByName(me, "Glow")
	v.crystal = entity_getBoneByName(me, "Crystal")
	bone_alpha(v.glow, 0)
	
	entity_setCanLeaveWater(me, 1)
	
	
	--entity_setProperty(me, EP_BATTERY, true)
end

function postInit(me)

	--v.lx,v.ly = entity_getPosition(me)
end

function update(me, dt)
	if not v.setWaterLevel then
		v.lx,v.ly = entity_getPosition(me)
		entity_setPosition(me, entity_x(me), getWaterLevel())
		if not entity_isNearObstruction(me, 1) then
			v.ly = getWaterLevel(me)
		end
	end
	--if not entity_isState(me, STATE_CHARGED) then
	entity_handleShotCollisions(me)
	--end
	
	--[[
	if not entity_isState(me, STATE_INHOLDER) then
		entity_updateMovement(me, dt)
	end
	]]--
	entity_updateMovement(me, dt)
	entity_updateCurrents(me)
	
	if not entity_isBeingPulled(me) then
		entity_clearVel(me)
	end
	
	if entity_isState(me, STATE_IDLE) then
		local node = entity_getNearestNode(me, "LIGHT")
		if node ~= 0 and node_isEntityIn(node, me) then
			-- charging
			--debugLog(string.format("charge:%f", charge))
			v.charge = v.charge + dt
			if v.charge > 2 then
				entity_setState(me, STATE_CHARGED, 2)
			end
		else
			if v.charge > 0 then
				v.charge = v.charge - dt
				if v.charge < 0 then
					v.charge = 0
				end
			end
		end
	end
	if entity_isState(me, STATE_ROTATE) then
		if not entity_isAnimating(me) then
			entity_setState(me, STATE_DROPPED)
		end
	end

	local levelDiff = math.abs(entity_y(me)-getWaterLevel())
	if entity_isState(me, STATE_IDLE) then
		--debugLog(string.format("diff: %f", levelDiff))
		if levelDiff > 50 then
			--debugLog("setting false")
			entity_setProperty(me, EP_MOVABLE, false)
		else
			--debugLog("setting true")
			entity_setProperty(me, EP_MOVABLE, true)
		end
	end
	if levelDiff < 100 then
		entity_setPosition(me, entity_x(me), getWaterLevel())
	end
	if entity_isNearObstruction(me, 1) then
		entity_setPosition(me, v.lx, v.ly)
	end
	v.lx, v.ly = entity_getPosition(me)
end

function enterState(me)
	if entity_isState(me, STATE_CHARGED) then
		entity_setProperty(me, EP_MOVABLE, false)
		bone_alpha(v.glow, 1, 1)
	elseif entity_isState(me, STATE_ROTATE) then
		entity_animate(me, "rotate")
	elseif entity_isState(me, STATE_DROPPED) then
		entity_setProperty(me, EP_MOVABLE, false)
		bone_alpha(v.crystal, 0)
		bone_alpha(v.glow, 0)
		local x, y = bone_getWorldPosition(v.crystal)
		local ent = createEntity("LightCrystalCharged", "", x, y)
		entity_rotate(ent, 180)
	end
end

function exitState(me)
	if entity_isState(me, STATE_CHARGED) then
		entity_setState(me, STATE_ROTATE)
	end
end

function hitSurface(me)
	--entity_sound(me, "rock-hit")
end

function damage(me, attacker, bone, damageType, dmg)	
	return false
end

function activate(me)
end
