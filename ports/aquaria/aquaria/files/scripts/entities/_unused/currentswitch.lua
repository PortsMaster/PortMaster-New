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

-- current switches
dofile("scripts/entities/entityInclude.lua")

v.CURRENTSWITCH_OFF	= 1
v.CURRENTSWITCH_ON	= 2

v.bone_orb = 0

function v.commonInit(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_setWidth(me, 64)
	entity_setHeight(me, 64)
	entity_setUpdateCull(me, -1)
	entity_setActivation(me, AT_CLICK, 64, 256)
	entity_initSkeletal(me, "FleshSwitch")
	entity_animate(me, "idle", LOOP_INF)
	v.bone_orb = entity_getBoneByName(me, "Orb")
end

function postInit(me)
	debugLog("postInit")
	if entity_isFlag(me, v.CURRENTSWITCH_ON) then
		entity_setState(me, STATE_ON)
	elseif entity_isFlag(me, v.CURRENTSWITCH_OFF) then
		entity_setState(me, STATE_OFF)
	end	
end

local function setGroupState(me, state)
	if entity_getGroupID(me) ~= 0 then
		local iter = 0
		local ent = getEntityInGroup(entity_getGroupID(me), iter)
		while (ent ~= 0) do
			--debugLog("Looping thru group")
			if not (ent == me) then
				if not entity_isState(ent, state) then
					entity_setState(ent, state)
				end
			end
			iter = iter + 1
			ent = getEntityInGroup(entity_getGroupID(me), iter)
		end
	end
end

function enterState(me, state)
	if entity_isState(me, STATE_ON) then
	
		debugLog("setting on")
		entity_animate(me, "open")
		--entity_setNodeGroupActive(me, 0, true)
		local node = getNearestNodeByType(entity_x(me), entity_y(me), PATH_CURRENT)
		if node ~= 0 then
			debugLog("found node, setting")
			node_setActive(node, true)
		else
			debugLog("did not find node")
		end
		entity_setFlag(me, v.CURRENTSWITCH_ON)
		-- turn other switches off
		setGroupState(me, STATE_OFF)
		--bone_setColor(v.bone_orb, 0, 1, 0, 0.5)
		--entity_setColor(me, 0, 1, 0, 0)
	elseif entity_isState(me, STATE_OFF) then
		debugLog("setting off")
		entity_animate(me, "close")
		--entity_setNodeGroupActive(me, 0, false)
		local node = getNearestNodeByType(entity_x(me), entity_y(me), PATH_CURRENT)
		if node ~= 0 then
			node_setActive(node, false)
		end		
		entity_setFlag(me, v.CURRENTSWITCH_OFF)
		-- turn other switches on
		setGroupState(me, STATE_ON)
		--bone_setColor(v.bone_orb, 1, 0, 0, 0.5)
		--entity_setColor(me, 1, 0, 0, 0)
	end
end

function activate(me)
	if entity_isFlag(me, v.CURRENTSWITCH_OFF) then
		debugLog("setting stateon")
		entity_setState(me, STATE_ON)
	end
end

function songNote(me, note)

end

function update(me)
end
