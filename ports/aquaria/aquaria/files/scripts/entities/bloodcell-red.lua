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

function init(me)
	v.commonInit(me, "bloodcell-red")
	
	esetv(me, EV_TYPEID, EVT_CELLRED)

	
	--entity_setEntityLayer(me, 0)
end

function update(me, dt)
	v.commonUpdate(me, dt)
	
	if entity_isEntityInRange(me, v.n, 40) then 
		if not avatar_isBursting() then
			entity_setPosition(me, entity_x(v.n), entity_y(v.n), 0.1)
		elseif avatar_isRolling() then
			entity_moveTowardsTarget(me, dt, -800)
		end
	end

	local rangeNode = entity_getNearestNode(me, "KILLENTITY")
	if node_isPositionIn(rangeNode, entity_x(me), entity_y(me)) then
		entity_setState(me, STATE_DEAD)
	end
end
