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

dofile("scripts/maps/finalcommon.lua")

function hasQuit()
	if not (getEnqueuedState() == "") then
		fade2(1, 0, 1, 1, 1)
		return true
	end
	return false
end

function init()
	--return
	fade2(0, 0, 1, 1, 1)
	overrideZoom(0.8)
	local n = getNaija()
	entity_setPosition(n, 0, 0)
	playMusicOnce("Intro")
	
	user_set_demo_intro(0)
	user_save()
	
	local camDummy = createEntity("Empty")
	local start1 = getNode("START1")
	local start2 = getNode("START2")
	local start3 = getNode("START3")
	
	local end1 = getNode("END1")
	local end2 = getNode("END2")
	local end3 = getNode("END3")
	
	-- 1
	entity_warpToNode(camDummy, start1)
	cam_toEntity(camDummy)
	entity_swimToNode(camDummy, end1, SPEED_SLOW)
	
	fade(0, 4)
	watch(4)
	if hasQuit() then return end
	watch(3)
	if hasQuit() then return end
	fade(1, 4)
	watch(4)
	if hasQuit() then return end
	
	-- 2
	entity_warpToNode(camDummy, start2)
	cam_toEntity(camDummy)
	entity_swimToNode(camDummy, end2, SPEED_SLOW)
	
	fade(0, 6)
	watch(6)
	if hasQuit() then return end
	fade(1, 6)
	watch(6)
	if hasQuit() then return end
	
	-- 3
	entity_warpToNode(camDummy, start3)
	cam_toEntity(camDummy)
	entity_swimToNode(camDummy, end3, SPEED_SLOW)
	
	fade(0, 4)
	watch(4)
	if hasQuit() then return end
	watch(4)
	if hasQuit() then return end
	
	
	overrideZoom(1, 6)
	watch(2)
	watch(2.5)
	
	
	--watch(5)
	
	
	fade2(1, 2, 1, 1, 1)
	watch(2)
	if hasQuit() then return end
	--jumpState("Title")
	loadMap("Title")
end


