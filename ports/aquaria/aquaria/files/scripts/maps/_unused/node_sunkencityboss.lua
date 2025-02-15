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

v.spawned = false
v.dad = 0
v.mom = 0
v.door = 0
v.didInit = false

function init(me)
	v.door = node_getNearestEntity(me, "EnergyDoor")
	v.dad = getEntity("SunkenDad")
	v.mom = getEntity("SunkenMom")	
	if isFlag(FLAG_SUNKENCITY_BOSS, 1) then
		entity_delete(v.dad)
		entity_delete(v.mom)
		return
	end
end

function doInit(me)
	--debugLog("Setting door to opened")
	entity_setState(v.door, STATE_OPENED)
end

function update(me, dt)
	if not v.didInit then
		doInit(me)
		v.didInit = true
	end
	if isFlag(FLAG_SUNKENCITY_BOSS, 1) then
		return
	end
	if entity_isState(v.dad, STATE_DEATHSCENE) then
		setFlag(FLAG_SUNKENCITY_BOSS, 1)
		entity_setState(v.door, STATE_OPEN)
	end	
	if not v.spawned then
		if node_isEntityIn(me, getNaija()) then
			entity_setState(v.dad, STATE_START)
			entity_setState(v.mom, STATE_START)
			entity_setState(v.door, STATE_CLOSE)
			v.spawned = true
		end
	end
end
