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

v.rotSpd = 0.0
v.n = 0
v.gear = 0
v.gearBack = 0
v.actDelay = 0
v.t = 15
v.soundTimer =0

v.useSetRotSpd = 0

function v.commonInit(me, usrs)
	v.useSetRotSpd = usrs
	entity_setEntityType(me, ET_NEUTRAL)
	--entity_setTexture(me, "")
	entity_initSkeletal(me, "Gear")
	--entity_setWidth(me, 64)
	--entity_setHeight(me, 64)
	entity_setUpdateCull(me, -1)
	v.n = getNaija()
	
	entity_setCollideRadius(me, 160)
	
	v.gear = entity_getBoneByName(me, "Gear")
	v.gearBack = entity_getBoneByName(me, "GearBack")
	
	entity_scale(me, 1.5, 1.5)
	
	loadSound("GearTurn")
	loadSound("GearWaterLevel")
	
	esetv(me, EV_BEASTBURST, 0)
	esetv(me, EV_LOOKAT, 0)
end

function postInit(me)
	v.mult = 1
	local node = entity_getNearestNode(me, "FLIP")
	if node ~= 0 and node_isEntityIn(node, me) then
		v.useSetRotSpd = -v.useSetRotSpd
	end
end

function enterState(me)
end

function exitState(me)
end

function activate(me)
end

function songNote(me, note)
end

function damage(me)
	return false
end

local function doFunction(me)
	if v.actDelay == 0 then
		v.actDelay = v.t
		local node = entity_getNearestNode(me)
		if node ~= 0 and node_isEntityIn(node, me) then
			node_activate(node)
		end
		playSfx("GearWaterLevel")
	end
end

function update(me, dt)
	local spinning = false
	if v.actDelay > 0 then
		v.actDelay = v.actDelay - dt
		if v.actDelay < 0 then
			v.actDelay = 0
		end
	end
	
	
	if v.useSetRotSpd == 0 then
		if entity_isEntityInRange(me, v.n, 600) then
			if entity_isUnderWater(v.n) and avatar_isRolling() then
				v.rotSpd = v.rotSpd + 90*dt*avatar_getRollDirection()
				if v.rotSpd > 360 then
					v.rotSpd = 360
				elseif v.rotSpd < -360 then
					v.rotSpd = -360
				end
				v.spinning = true
				
			end
		end
	else
		v.spinning = true
		v.rotSpd = v.useSetRotSpd
	end
	--debugLog(string.format("rotspd:%d", v.rotSpd))
	if v.rotSpd ~= 0 then
		
		entity_rotate(me, entity_getRotation(me)+v.rotSpd*dt)
		--bone_rotate(gear, bone_getRotation(gear)+v.rotSpd*dt)
		bone_rotate(v.gearBack, bone_getRotation(v.gearBack)-v.rotSpd*2*dt)
		
		if bone_getRotation(v.gear) > 360 then
			bone_rotate(v.gear, bone_getRotation(v.gear)-360)
			--entity_sound(me, "GearTurn")
		elseif bone_getRotation(v.gear) < -360 then
			bone_rotate(v.gear, bone_getRotation(v.gear)+360)
			--entity_sound(me, "GearTurn")			
		end
		v.soundTimer = v.soundTimer + v.rotSpd*dt
		--debugLog(string.format("soundTimer: %f", v.soundTimer))
		local intv = 90
		if v.soundTimer > intv then
			v.soundTimer = 0
			entity_sound(me, "GearTurn")
		end
		if v.soundTimer < -intv then
			v.soundTimer = 0
			entity_sound(me, "GearTurn")
		end

		if not spinning then
			local dir = 1
			if v.rotSpd > 0 then
				dir = -1
			end
			v.rotSpd = v.rotSpd + (30.0*dt*dir)
			if dir == 1 and v.rotSpd > 0 then
				v.rotSpd = 0
			elseif dir == -1 and v.rotSpd < 0 then
				v.rotSpd = 0
			end
		end
	end

	local minSpd = 300
	if v.rotSpd > minSpd or v.rotSpd < -minSpd then
		doFunction(me)
	end
	
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0) then
		if avatar_isLockable() and entity_setBoneLock(v.n, me) then
		else
			local x, y = entity_getVectorToEntity(me, v.n, 8000)
			entity_addVel(v.n, x, y)
		end
	end
	entity_handleShotCollisions(me)
end
