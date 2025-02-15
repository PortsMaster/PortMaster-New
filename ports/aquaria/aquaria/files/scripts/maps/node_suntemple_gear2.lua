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

v.running = false
v.t = 12

function init(me)
	--node_setCursorActivation(me, true)
	loadSound("kathunk")
end
	
function activate(me)
	if v.running then return end
	
	playSfx("kathunk")
	v.running = true
	local lvl = node_y(me)
	if (getWaterLevel() ~= lvl) then
		setFlag(FLAG_SUNTEMPLE_WATERLEVEL, 1)
		setWaterLevel(lvl, v.t)
	else
		local node = getNode("SUNTEMPLE_GEAR3")
		setWaterLevel(node_y(node), v.t)
		setFlag(FLAG_SUNTEMPLE_WATERLEVEL, 2)
	end
	v.running = false
end

function update(me, dt)
end
