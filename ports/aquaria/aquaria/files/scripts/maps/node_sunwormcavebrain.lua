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

v.h1 = 0
v.h2 = 0
v.past = 0

v.timer = 0

v.levelAt = 1
v.pastDefault = false

v.n = 0

function init(me)
	v.h1 = getNode("WATERLEVEL_HIGH")
	v.h2 = getNode("WATERLEVEL_LOW")
	v.past = getNode("RAISE_WATERLEVEL")
	v.bossRoom = getNode("NAIJA_ENTER")
	v.n = getNaija()
	
	loadSound("waterlevelchange")
end
	
function activate(me)
end

function update(me, dt)
	if not isFlag(FLAG_BOSS_SUNWORM, 0) then
		setWaterLevel(node_y(getNode("ENDWATERLEVEL")))
		return
	end
	if entity_x(v.n) > node_x(v.past) then
		if not v.pastDefault then
			setWaterLevel(node_y(v.h1), 2)
			v.pastDefault = true
		end
	else
		v.pastDefault = false
		v.timer = v.timer + dt
		if v.timer > 7 then
			playSfx("waterlevelchange")
			if v.levelAt == 1 then
				v.levelAt = 2
			else
				v.levelAt = 1
			end
			if v.levelAt == 1 then
				setWaterLevel(node_y(v.h1), 2)
			elseif v.levelAt == 2 then
				setWaterLevel(node_y(v.h2), 2)
			end
			v.timer = 0
		end
	end
end
