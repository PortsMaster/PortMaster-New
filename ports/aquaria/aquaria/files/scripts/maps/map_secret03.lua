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

--function ASDFASFD end end end end

function init()	
	local n = getNaija()
	local node = getNode("INSIDE")
	entity_setPosition(n, node_x(node), node_y(node))
	overrideZoom(0.9)
	
	fade(0, 0)
	
	local start = getNode("SKY1")
	local camDummy = createEntity("Empty")
	cam_toEntity(camDummy)
	entity_setPosition(camDummy, node_x(start), node_y(start)-400)
	entity_setPosition(camDummy, node_x(start), node_y(start), 7, 0, 0, 1)
	--cam_toNode()
	watch(1)
	fade2(0, 1, 1, 1, 1)
	watch(1)
	watch(4)
	fade2(1, 1, 1, 1, 1)
	watch(1)
	
	cam_toNode(getNode("NAIJALICAM"))
	watch(1)
	
	fade2(0, 1, 1, 1, 1)
	--watch(0.5)

	local li = getEntity("YoungLi")
	local naija = getEntity("NaijaChild")
	
	local sx, sy = entity_getPosition(li)
	
	entity_setPosition(li, entity_x(li)-1024, entity_y(li), -100, 0, 0, 1)
	fadeIn(1)
	watch(1)
	
	watch(4)
	
	fade2(1, 1, 1, 1, 1)
	watch(1)

	entity_setPosition(li, sx, sy, 0.1)
	entity_setState(li, STATE_ON)
	
	cam_toEntity(naija)
	watch(1)
	
	--entity_swimToNode(naija, getNode("NAIJATO"))
	local node = getNode("NAIJATO")
	
	entity_animate(naija, "swim", -1)
	entity_setPosition(naija, node_x(node), node_y(node), 6, 0, 0, 1)
	entity_rotate(naija, 45, 1, 0, 0, 1)
	
	fade2(0, 1, 1, 1, 1)
	watch(1)
	
	entity_rotate(naija, 0, 6, 0, 0, 1)
	
	--entity_watchForPath(naija)
	while entity_isInterpolating(naija) do
		watch(FRAME_TIME)
	end
	
	entity_flipToEntity(naija, li)
	entity_animate(naija, "idle", -1)
	
	
	
	cam_toNode(getNode("NAIJATO"))
	
	watch(1)
	
	-- li surprise
	entity_setState(li, STATE_OFF)
	
	-- look up
	entity_animate(naija, "wave", 0, 2)
	watch(4)
	
	entity_animate(naija, "inspect", 0, 2)
	watch(2)
	
	playSfx("NaijaChildGiggle")
	entity_animate(naija, "giggle", 6, 2)
	watch(2)
	
	-- naija leaves
	entity_swimToNode(naija, getNode("NAIJAOUT"))
	watch(2)
	
	-- li thoughtful
	entity_setState(li, STATE_ATTACK)
	
	watch(4)
	
	fade2(1, 2)
	watch(2)
	loadMap("Veil02", "SECRET03")
	
	
	
	--cam_toEntity(n)
end

