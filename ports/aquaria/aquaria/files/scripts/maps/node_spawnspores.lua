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

v.n = 0
v.sz = 64
v.delay = 0
		
function init(me)
	v.n = getNaija()
end

local function spawnSpore(x, y)
	-- SLOW have to load a script each time
	createSpore(x, y)
	--[[
	local ent = createEntity("Spore", "", x, y)
	local e = entity_getNearestEntity(ent, "Spore")
	if e ~= 0 then
		if entity_isEntityInRange(ent, e, v.sz/2) then
			entity_delete(ent)
		end
	end
	]]--
end

function update(me, dt)
	v.delay = v.delay - dt
	if v.delay < 0 then
		if node_isEntityIn(me, v.n) then
			-- spawn around on a grid
			local x, y = entity_getPosition(v.n)

			x = math.floor(x / v.sz)
			y = math.floor(y / v.sz)
			x = x * v.sz + v.sz/2
			y = y * v.sz + v.sz/2
			
			local out = 4
			spawnSpore(x, y-v.sz*out)
			spawnSpore(x+v.sz*out, y-v.sz*out)
			spawnSpore(x-v.sz*out, y-v.sz*out)
			
			spawnSpore(x, y+v.sz*out)
			spawnSpore(x+v.sz*out, y+v.sz*out)
			spawnSpore(x-v.sz*out, y+v.sz*out)
			
			spawnSpore(x+v.sz*out, y)
			spawnSpore(x-v.sz*out, y)
		end
		v.delay = 0.5
	end
end
