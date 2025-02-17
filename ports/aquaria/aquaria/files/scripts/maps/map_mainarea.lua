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
--[[
	if isFlag(FLAG_VISION_ENERGYTEMPLE, 0) then
		debugLog("PLAYING LIGHT!!!")
		playMusic("light")
	end
	]]--
	--fadeIn(1)
	--watch(1)
	
	if isFlag(FLAG_ENDING, ENDING_MAINAREA) then
		overrideZoom(1)
		overrideZoom(0.6, 15)
		
		
		local dummy = createEntity("Empty")
		
		local na1 = getNode("endpana1")
		local nb1 = getNode("endpanb1")
		local na2 = getNode("endpana2")
		local nb2 = getNode("endpanb2")
		
		setCameraLerpDelay(0)
		cam_toEntity(dummy)
		entity_setPosition(dummy, node_x(na1), node_y(na2))
		watch(0.4)
		
		entity_setPosition(dummy, node_x(nb1), node_y(nb1), 15, 0, 0, 1)
	
		fade2(0, 1, 1, 1, 1)
		fadeIn(1)
		watch(1)
		
		voice("naija_endingpart1b")
		
		watch(7)
		
		fade2(1, 0.5, 1, 1, 1)
		watch(0.5)
		
		-- do stuff
		entity_warpToNode(dummy, na2)
		watch(1)
		
		
		entity_setPosition(dummy, node_x(nb2), node_y(nb2), 13, 0, 0, 1)
	
		
		overrideZoom(0.6)
		overrideZoom(1, 15)
		
		fade2(0, 1, 1, 1, 1)
		watch(2)
		
		voice("naija_endingpart1c")
		
		watchForVoice()
		
		fade2(1, 0.5, 1, 1, 1)
		watch(0.5)
		
		setFlag(FLAG_ENDING, ENDING_SECRETCAVE)
		loadMap("NaijaCave")
		
		--fade2(0, 0.5, 1, 1, 1)
	end
end

