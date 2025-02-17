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
v.done = false
function init(me)
	v.n = getNaija()
end
	
function activate(me)
end

function update(me, dt)
	if isFlag(FLAG_MINIBOSS_KINGJELLY, 0) and not v.done then
		if node_isEntityIn(me, v.n) then
			v.done = true
			local kingJelly = node_getNearestEntity(me, "KingJelly")
			if kingJelly ~=0 then
				debugLog("has king jelly")
				playMusic("inevitable")
				cam_toEntity(kingJelly)
				watch(2)
				entity_setState(kingJelly, STATE_DESCEND)
				watch(3)
				cam_toEntity(v.n)
			else
				debugLog("Could not find king jelly")
			end
		end
	end
end
