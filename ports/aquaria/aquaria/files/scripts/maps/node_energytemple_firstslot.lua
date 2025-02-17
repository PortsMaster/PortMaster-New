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

function init(me)
	node_setCursorActivation(me, false)

	local door = node_getNearestEntity(me, "EnergyDoor")
	if door ~= 0 then
		debugLog("found door")
		if isFlag(FLAG_ENERGYGODENCOUNTER, 0) then
			entity_setState(door, STATE_OPENED)
		else
			if getFlag(FLAG_ENERGYSLOT_FIRST) > 0 then
				local orbHolder = node_getNearestEntity(me)
				local id = getFlag(FLAG_ENERGYSLOT_FIRST)
				local energyOrb = getEntityByID(id)
				if energyOrb ~=0 and orbHolder ~=0 then
					entity_setPosition(energyOrb, entity_x(orbHolder), entity_y(orbHolder))
					entity_setState(energyOrb, STATE_CHARGED)
				end
				local door = node_getNearestEntity(me, "EnergyDoor")
				if door ~= 0 then
					entity_setState(door, STATE_OPENED)
				end
			end
		end
	else
		debugLog("Could not find door")
	end
	--[[
	if getFlag(FLAG_ENERGYSLOT_MAINAREA) > 0 then
		local orbHolder = node_getNearestEntity(me)
		local id = getFlag(FLAG_ENERGYSLOT_MAINAREA)
		local energyOrb = getEntityByID(id)
		if energyOrb ~=0 and orbHolder ~=0 then
			entity_setPosition(energyOrb, entity_x(orbHolder), entity_y(orbHolder))
			entity_setState(energyOrb, STATE_CHARGED)
		end
		local door = node_getNearestEntity(me, "EnergyDoor")
		if door ~= 0 then
			entity_setState(door, STATE_OPENED)
		end
	end
	]]--
end

function activate(me)
	if getFlag(FLAG_ENERGYSLOT_FIRST)==0 then
		local energyOrb = node_getNearestEntity(me, "EnergyOrb")
		if energyOrb ~= 0 and entity_isState(energyOrb, STATE_CHARGED) then
			setFlag(FLAG_ENERGYSLOT_FIRST, entity_getID(energyOrb))
			local door = node_getNearestEntity(me, "EnergyDoor")
			if door ~= 0 then
				entity_setState(door, STATE_OPEN)
			end
		end
	end
end

function update(me, dt)
end
