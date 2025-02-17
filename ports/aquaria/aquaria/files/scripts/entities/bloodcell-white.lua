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

dofile("scripts/entities/bloodcell-common.lua")

v.fireDelay = 0
v.fireDelayTime = 1

v.sing = false

function init(me)
	v.commonInit(me, "bloodcell-white")
	
	esetv(me, EV_TYPEID, EVT_CELLWHITE)
end

local function fire(me)
	local e = getFirstEntity()
	local target = 0
	while e ~= 0 do
		if entity_getEntityType(e)==ET_ENEMY and not eisv(e, EV_TYPEID, EVT_CELLWHITE) and not eisv(e, EV_TYPEID, EVT_PET) then
			if entity_isEntityInRange(me, e, 450) then
				target = e
				break
			end
		end
		e = getNextEntity()
	end
	if target ~= 0 then
		local s = createShot("energyblast", me, target, entity_x(me), entity_y(me))
	end
	v.fireDelay = v.fireDelayTime + randRange(0,2)
end

function update(me, dt)
	v.commonUpdate(me, dt)
	
	if v.sing then
		entity_moveTowardsTarget(me, dt, 300)
	end
	
	v.fireDelay = v.fireDelay - dt
	if v.fireDelay < 0 then
		fire(me)
	end

	local rangeNode = entity_getNearestNode(me, "KILLENTITY")
	if node_isPositionIn(rangeNode, entity_x(me), entity_y(me)) then
		entity_setState(me, STATE_DEAD)
	end
end

function songNote(me, note)
	local r,g,b = getNoteColor(note)
	bone_setColor(v.glow, r*0.5+0.5, g*0.5+0.5, b*0.5+0.5)
	bone_alpha(v.glow, 0.4, 1)
	v.sing = true
end

function songNoteDone(me, note, t)
	bone_alpha(v.glow, 0, 4)
	v.sing = false
end
