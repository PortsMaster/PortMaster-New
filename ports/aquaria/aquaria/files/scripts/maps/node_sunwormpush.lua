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
v.s = 0

function init(me)
	v.n = getNaija()
	v.s = getEntity("sunworm")
end

function update(me, dt)
	if getFlag(FLAG_BOSS_SUNWORM) <= 0 then
		if v.s == 0 then
			v.s = getEntity("sunworm")
		else
			if node_isEntityIn(me, v.s) and entity_isUnderWater(v.s) then
				local dx = entity_x(v.s) - node_x(me)
				local dy = entity_y(v.s) - node_y(me)
				dx, dy = vector_setLength(dx, dy, 3000*dt)
				entity_addVel(v.s, dx, dy)
			end
		end
	end
end
