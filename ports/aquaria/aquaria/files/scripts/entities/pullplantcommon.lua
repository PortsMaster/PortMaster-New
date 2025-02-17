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

local STATE_PULL		= 1001

v.entToSpawn = ""
v.ingToSpawn = ""
v.amount = 0

v.pullTimer			= 0
v.pullMax				= 0.2

v.leaf1 				= 0
v.leaf2				= 0

function v.commonInit(me, ent, ing, amt)
	setupEntity(me)
	if amt == 0 then
		v.amount = 1
	else
		v.amount = amt
	end
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "PullPlant")
	
	entity_setProperty(me, EP_MOVABLE, true)	
	
	entity_setState(me, STATE_IDLE)
	
	v.entToSpawn = ent
	v.ingToSpawn = ing
	entity_setEntityLayer(me, -2)
	
	v.leaf1 = entity_getBoneByIdx(me, 0)
	v.leaf2 = entity_getBoneByIdx(me, 1)
	
	local sz1 = 1 + math.random(1000)/4000.0
	local sz2 = 1 + math.random(1000)/4000.0
	bone_scale(v.leaf1, sz1, sz1)
	bone_scale(v.leaf2, sz2, sz2)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) and entity_isBeingPulled(me) then
		v.pullTimer = v.pullTimer + dt
		if v.pullTimer > v.pullMax then
			entity_setState(me, STATE_PULL)
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_PULL) then
		entity_setStateTime(me, entity_animate(me, "pull")-0.2)

	end
end

function exitState(me)
	if entity_isState(me, STATE_PULL) then

		

		entity_alpha(me, 0, 0.2)
		entity_delete(me, 0.2)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function animationKey(me, key)
	if entity_isState(me, STATE_PULL) then
		if key == 2 then
			if v.ingToSpawn ~= "" then
				spawnIngredient(v.ingToSpawn, entity_x(me), entity_y(me))
				playSfx("secret")
			end
		elseif key == 3 then
			if v.entToSpawn ~= "" then
				createEntity(v.entToSpawn, "", entity_x(me), entity_y(me))
				playSfx("secret")
			end
		end
	end
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

