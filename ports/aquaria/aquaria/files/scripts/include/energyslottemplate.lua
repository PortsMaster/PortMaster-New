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

local chargeIDOffset = 5000

function init(me)
	node_setCursorActivation(me, false)
	if getFlag(v.flag) > 0 then
		local charged = true
		local id = getFlag(v.flag)
		if id > chargeIDOffset then
			charged = false
			id = id - chargeIDOffset
		end
		--[[
		if getFlag(chargeFlag) == 0 then
			charged = false
		end
		]]--
		
		v.orbHolder = getEntityByID(v.holderID)		
		v.energyOrb = getEntityByID(id)
		if v.energyOrb ~= 0 and v.orbHolder ~= 0 then
			--debugLog(string.format("%s : setting orb to %d, %d", node_getName(me), entity_x(v.orbHolder), entity_y(v.orbHolder)))
			entity_setPosition(v.energyOrb, entity_x(v.orbHolder), entity_y(v.orbHolder))
			if charged then
				entity_setState(v.energyOrb, STATE_CHARGED)
			end
		end
		if charged then
			v.door = getEntityByID(v.doorID)
			if v.door ~= 0 then
				entity_setState(v.door, STATE_OPENED)
			end
		end
	end
end

function activate(me)
	if getFlag(v.flag) == 0 or getFlag(v.flag) >= chargeIDOffset then
		v.energyOrb = node_getNearestEntity(me, "EnergyOrb")
		if v.energyOrb ~= 0 then
			if entity_isState(v.energyOrb, STATE_CHARGED) then
				debugLog("Saving orb in slot, charged")
				setFlag(v.flag, entity_getID(v.energyOrb))
				v.door = getEntityByID(v.doorID)
				if v.door ~= 0 then
					entity_setState(v.door, STATE_OPEN)
				else
					debugLog("COULD NOT FIND DOOR")
				end
			else
				debugLog("Saving orb in slot, not charged")
				setFlag(v.flag, entity_getID(v.energyOrb)+chargeIDOffset)				
			end
		else
			debugLog("Could not find orb")
		end
	end
end

function update(me, dt)
end
