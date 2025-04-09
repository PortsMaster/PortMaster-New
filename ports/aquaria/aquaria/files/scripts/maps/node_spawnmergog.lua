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

v.mergog = 0

local function spawnEgg(me)
	local node = getNode("COLLECTIBLEPIRANHAEGGLOCATION")
	createEntity("CollectiblePiranhaEgg", "", node_x(node), node_y(node))
end

function init(me)
	if isFlag(FLAG_MINIBOSS_MERGOG, 0) then
		v.mergog = createEntity("Mergog", "", node_x(me), node_y(me))
	else
		spawnEgg(me)
	end
end

function update(me, dt)
	if v.mergog ~= 0 then
		if entity_isState(v.mergog, STATE_DEAD) then
			setFlag(FLAG_MINIBOSS_MERGOG, 1)
			spawnEgg(me)
			v.mergog = 0
		end
	end
end
