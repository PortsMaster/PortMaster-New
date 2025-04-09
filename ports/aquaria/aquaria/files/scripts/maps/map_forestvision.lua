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
	setCutscene(1,1)
	toggleDamageSprite(false)
	fade2(0, 1, 1, 1, 1)
	--return
	
	setOverrideVoiceFader(0.6)
	
	entity_setPosition(getNaija(), 0, 0)

	
	local camDummy = createEntity("Empty")
	local cam1 = getNode("CAM1")
	local cam2 = getNode("CAM2")
	local cam3 = getNode("CAM3")
	
	local campan1 = getNode("CAMPAN1")
	local campan2 = getNode("CAMPAN2")
	local campan3 = getNode("CAMPAN3")
	
	local camdestroy1 = getNode("CAMDESTROY1")
	local camdestroy2 = getNode("CAMDESTROY2")
	
		
	-- 1

	overrideZoom(1)
	entity_warpToNode(camDummy, cam1)
	cam_toEntity(camDummy)
	
	watch(0.5)

	fade2(0, 0, 1, 1, 1)
	fadeIn(1)
	watch(1)
	
	local n = getNaija()
	entity_setPosition(n, 0, 0)
	playMusicOnce("DruniadDance")
	
	
	entity_setPosition(camDummy, node_x(cam2), node_y(cam2), 10, 0, 0, 1)

	overrideZoom(0.8, 10.1)
	
	watch(4)
	
	while entity_isInterpolating(camDummy) do
		watch(FRAME_TIME)
	end
	
	entity_setPosition(camDummy, node_x(cam3), node_y(cam3), 5, 0, 0, 1)

	overrideZoom(0.5, 11)
	
	while entity_isInterpolating(camDummy) do
		watch(FRAME_TIME)
	end
	
	fade2(1, 1, 1, 1, 1)
	watch(1)
	
	--2 
	overrideZoom(1)
	entity_warpToNode(camDummy, campan1)
	cam_toEntity(camDummy)
	
	watch(0.5)
	
	entity_setPosition(camDummy, node_x(campan2), node_y(campan2), 16, 0, 0, 1)
	
	overrideZoom(0.5, 21)

	fade2(0, 1, 1, 1, 1)
	watch(1)
	
	watch(7)
	
	voice("Naija_Vision_Forest")
	watch(8)
	
	
	entity_setPosition(camDummy, node_x(campan3), node_y(campan3), 11, 0, 0, 1)
	
	watch(10)
		
	fade2(1, 1)
	watch(1)
	
	
	--3
	overrideZoom(1)
	entity_warpToNode(camDummy, camdestroy1)
	cam_toEntity(camDummy)
	
	watch(0.5)
	
	entity_setPosition(camDummy, node_x(camdestroy2), node_y(camdestroy2), 10, 0, 0, 0)
	
	overrideZoom(0.5, 8)
	
	fade2(0, 1)
	watch(1)

	shakeCamera(20, 10)
	
	for i = 1,(8/FRAME_TIME) do
		local x, y = getScreenCenter()
		local node = getNode("DESTROY")
		local ent = getFirstEntity()
		while ent ~= 0 do
			if not entity_isState(ent, STATE_DONE) and node_isEntityIn(node, ent) and entity_x(ent) < x+200 then
				entity_setState(ent, STATE_DONE)
			end
			ent = getNextEntity()
		end
		watch(FRAME_TIME)
	end

	fade2(1, 4)
	watch(4)
	
	
	
	fade2(0, 0.1)
	
	toggleBlackBars(1)
	
	showImage("Visions/Forest/00")
	--[[
	voice("")
	watchForVoice()
	]]--
	watch(10)
	hideImage()
	overrideZoom(1, 7)
	watch(4)
	changeForm(FORM_NATURE)
	watch(3)

	setOverrideVoiceFader(-1)
	
	setCutscene(0)
	
	voice("Naija_Song_NatureForm")
	loadMap("Tree02", "NAIJADONE")

	--[[
	fade2(0, 0.5, 1, 1, 1)
	
	cam_toEntity(n)
	]]--

end


