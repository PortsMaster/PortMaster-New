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
v.ent = 0
v.done = false

function init(me)

	v.n = getNaija()
end

function activate(me)
end

function update(me, dt)
	if v.ent == 0 then
		local node = getNode("OPENFINALDOOR")
		if node ~= 0 then
			v.ent = node_getNearestEntity(node, "FinalDoor")
		end
	end
	
	if not v.done then
		if node_isEntityIn(me, v.n) and not (entity_isState(v.ent, STATE_CLOSED) or entity_isState(v.ent, STATE_CLOSE)) then
			entity_setState(v.ent, STATE_CLOSE, -1, 1)
			v.done = true
		end
	end
end
