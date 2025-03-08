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
v.noteDown = -1
v.note1 = -1
v.note2 = -1
v.note3 = -1

v.ingToSpawn = ""
v.entToSpawn = ""

v.amount = 0

function init(me)
	setupEntity(me)
	entity_initSkeletal(me, "ancient-bulb")
	
	entity_setEntityType(me, ET_NEUTRAL)
	--entity_setCollideRadius(me, 0)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setMaxSpeed(me, 1200)
	
	entity_offset(me, 0, 10, 1, -1, 1, 1)
	entity_setUpdateCull(me, 2000)
	
	entity_animate(me, "idle")
	
	v.note2 = getRandNote()
	
	entity_setColor(me, getNoteColor(v.note2))
	
	entity_setEntityLayer(me, 1)
	
	local n1 = getNearestNodeByType(entity_x(me), entity_y(me), PATH_SETING)
	if n1 ~= 0 and node_isEntityIn(n1, me) then
		v.ingToSpawn = node_getContent(n1)
		v.amount = node_getAmount(n1)	if v.amount == 0 then v.amount = 1 end
	else
		local n2 = getNearestNodeByType(entity_x(me), entity_y(me), PATH_SETENT)
		if n2 ~= 0 and node_isEntityIn(n2, me) then
			v.entToSpawn = node_getContent(n2)
			v.amount = node_getAmount(n2)	if v.amount == 0 then v.amount = 1 end
		end
	end
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)

	if v.noteDown ~= -1 and entity_isEntityInRange(me, v.n, 800) then
		local rotspd = 0.8
		if v.noteDown == v.note2 then
			entity_moveTowardsTarget(me, dt, 1000)
			entity_setMaxSpeedLerp(me, 2.0, 0)
			
			entity_rotateToVel(me, rotspd)
		elseif v.noteDown == v.note1 or v.noteDown == v.note3 then
			entity_moveTowardsTarget(me, dt, 500)
			if entity_doEntityAvoidance(me, dt, 128, 1.0) then
				entity_setMaxSpeedLerp(me, 0.2)
			else
				entity_setMaxSpeedLerp(me, 1, 0.2)
			end
			entity_rotateToVel(me, rotspd)
		end			
		
	else
		v.noteDown = -1
		entity_rotate(me, 0, 0.5, 0, 0, 1)
		entity_setMaxSpeedLerp(me, 0.2, 2)
	end
	
	entity_doFriction(me, dt, 200)
	entity_updateMovement(me, dt)
	
	entity_handleShotCollisions(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
	elseif entity_isState(me, STATE_OPEN) then
	end
end

function exitState(me)
	if entity_isState(me, STATE_OPEN) then
		if entity_isFlag(me, 0) then
			entity_setStateTime(me, 1)
			
			entity_setFlag(me, 1)
			
			local bx, by = bone_getWorldPosition(v.bulb)
			
			if v.ingToSpawn ~= "" or v.entToSpawn ~= "" then
				playSfx("secret")
			end
			if v.ingToSpawn ~= "" then
				for i=1,v.amount do
					spawnIngredient(v.ingToSpawn, bx, by, 1, (i==1))
				end
			elseif v.entToSpawn ~= "" then
				for i=1,v.amount do
					createEntity(v.entToSpawn, "", bx, by)
				end
			end
		end
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
	v.noteDown = note
end

function songNoteDone(me, note)
	v.noteDown = -1
end

function song(me, song)
end

function activate(me)
end

