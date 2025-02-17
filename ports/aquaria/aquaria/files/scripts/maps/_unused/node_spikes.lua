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

function init(me)
	
end

function update(me, dt)
	if v.n == 0 then
		v.n = getNaija()
	end
	if node_isEntityIn(me, v.n) then
		entity_damage(v.n, 0, 0.5)
		
		local nx, ny = getWallNormal(node_x(me), node_y(me))
		if not(nx == 0 and ny == 0) then
			nx, ny = vector_setLength(nx, ny, 800)
			--entity_push(v.n, nx, ny, 0.25)
			entity_addVel(v.n, nx, ny)
		end
	end
end
