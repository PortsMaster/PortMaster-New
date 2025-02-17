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

function init()
	if isFlag(FLAG_SUNTEMPLE_WATERLEVEL, 0) then
		setWaterLevel(node_y(getNode("SUNTEMPLE_GEAR1")))
	elseif isFlag(FLAG_SUNTEMPLE_WATERLEVEL, 1) then
		setWaterLevel(node_y(getNode("SUNTEMPLE_GEAR2")))
	else
		setWaterLevel(node_y(getNode("SUNTEMPLE_GEAR3")))
	end
	debugLog(string.format("SunTemple: FLAG_SUNTEMPLE_WATERLEVEL was %d", getFlag(FLAG_SUNTEMPLE_WATERLEVEL)))
	if isFlag(FLAG_SUNTEMPLE_LIGHTCRYSTAL, 1) then
		local node = entity_getNearestNode(getNaija(), "LIGHTCRYSTAL_SPAWN")
		if node ~= 0 then
			createEntity("LightCrystalCharged", "", node_x(node), node_y(node))
		end
		local crystalHolder = getEntity("CrystalHolder")
		if crystalHolder ~=0 then
			entity_delete(crystalHolder)
		end
	end
end
