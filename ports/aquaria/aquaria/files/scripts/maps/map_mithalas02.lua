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

v.leave = true

function init()
	if isFlag(FLAG_ENDING, ENDING_NAIJACAVE) then		
		local e1 = getNode("end1")
		local e2 = getNode("end2")
		local e3 = getNode("end3")
		local e4 = getNode("end4")
		local e5 = getNode("end5")
		
		local sn = getNode("spirit")
		
		overrideZoom(0.8)
		
		fade2(1, 0)
		
		local spirit = createEntity("drask", "", node_x(sn), node_y(sn))
		entity_animate(spirit, "sit", -1)
		
		local cam = createEntity("empty", "", node_x(e1), node_y(e1))
		cam_toEntity(cam)
		
		watch(0.5)
		
		entity_setPosition(cam, node_x(e2), node_y(e2), 8, 0, 0, 1)
		
		fade2(0, 3)
		fadeIn(0)
		watch(5)
		
		fade2(1, 3)
		watch(3)
		
		
		overrideZoom(0.65, 20)
		
		entity_warpToNode(cam, e3)
		watch(0.5)
		
		entity_setPosition(cam, node_x(e4), node_y(e4), 5, 0, 0, 1)
				
		fade2(0, 3)
		watch(5)
		
		entity_setPosition(cam, node_x(e5), node_y(e5), 5, 0, 0, 1)
		watch(5)
		
		fade2(1, 3)
		watch(3)
		
		
		overrideZoom(0)
		
		if v.leave then
			loadMap("forest04")
		else
			watch(1)
			fade2(0, 0)
			cam_toEntity(getNaija())
		end
		
		
		--fade2(0,4)
		
		--loadMap("energytemple")
	end
end
