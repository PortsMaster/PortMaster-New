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

function init(me)	
end
	
function activate(me)
end

function run(me)
	if isFlag(FLAG_NAIJA_MEMORYCRYSTAL, 0) then
		setFlag(FLAG_NAIJA_MEMORYCRYSTAL, 1)
		
		local n = getNaija()		
		entity_idle(n)
		
		entity_flipToNode(n, getNode("SAVEPOINT"))
		
		local camNode = getNode("MEMORYCRYSTALCAM1")
		local camNode2 = getNode("MEMORYCRYSTALCAM2")
		local camNode3 = getNode("MEMORYCRYSTALCAM3")
		local camNode4 = getNode("SAVEPOINT")
		local camDummy = createEntity("Empty")
		entity_warpToNode(camDummy, camNode)
		
		setCameraLerpDelay(1.0)
		
		cam_toEntity(camDummy)
		
		overrideZoom(0.75, 1)
	
	
		entity_animate(getNaija(), "look45", LOOP_INF, LAYER_HEAD)
		entity_swimToNode(camDummy, camNode2, SPEED_SLOW)
		entity_watchForPath(camDummy)
		voice("naija_memorycrystal")
		entity_swimToNode(camDummy, camNode3, SPEED_SLOW)
		entity_watchForPath(camDummy)
		entity_swimToNode(camDummy, camNode4, SPEED_SLOW)
		entity_watchForPath(camDummy)
		
		overrideZoom(0.6, 9)
		watch(9)
		
		screenFadeCapture()		
		--overrideZoom(1, 4)
				
		
		overrideZoom(0)
		setCameraLerpDelay(0.0001)
		cam_toEntity(n)
		
		screenFadeGo(6)
		watch(6)
		
		entity_idle(n)
		
		setCameraLerpDelay(0)
		entity_delete(camDummy)
	end
end

function update(me, dt)
	if node_isEntityIn(me, getNaija()) then
		run(me)
	end
end
