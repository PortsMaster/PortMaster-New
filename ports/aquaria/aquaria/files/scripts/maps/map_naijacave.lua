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
	if isStory(0) then
		entity_warpToNode(getNaija(), getNode("NAIJASTART"))
	end

	local doTrailerIntro = false
	-- turn into watchFadeIn?


	local n = getNaija()
	
	if isFlag(FLAG_ENDING, ENDING_SECRETCAVE) then
		
		local li = getLi()
		if li ~= 0 then
			entity_setPosition(li, 0, 0)
			entity_alpha(li, 0)
		end
		local camNode = getNode("CAM1")
		local camNode2 = getNode("CAM2")
		local camNode3 = getNode("CAM3")
		local camNode4 = getNode("NAIJASTART")
		local camDummy = createEntity("Empty")
		entity_warpToNode(camDummy, camNode)
		
		setCameraLerpDelay(0)
		cam_toEntity(camDummy)
		
		entity_animate(n, "sitBack", LOOP_INF)

		overrideZoom(0.6)
		entity_setPosition(camDummy, node_x(camNode), node_y(camNode))
		watch(0.5)
		
		setCameraLerpDelay(1)
		
		watch(0.5)
		
		fadeIn(3)
		fade2(0, 1, 1, 1, 1)
		
		voice("naija_endingpart1d")
		
		watch(0.5)
		
		entity_setPosition(camDummy, node_x(camNode3), node_y(camNode3))
		
		entity_setPosition(camDummy, node_x(camNode4), node_y(camNode4), -200, 0, 0, 1)
		while entity_isInterpolating(camDummy) do
			watch(FRAME_TIME)
		end	
		
		local bits = 6.0/FRAME_TIME
		for i=1,bits do
		
			overrideZoom(1, 6)
			watch(FRAME_TIME)
			
			setCameraLerpDelay(1.0 - (i/bits))
		end
		
		watchForVoice()
		
		voice("naija_endingpart1e")
					
		cam_toEntity(n)
		
		watchForVoice()
		
		watch(1)
		
		fadeOutMusic(10)
		fade2(1, 8, 0, 0, 0)
		watch(8)
		
		
		watch(2)
		
		watch(1)
		
		stopMusic()
		
		setFlag(FLAG_ENDING, ENDING_DONE)
		
		jumpState("Credits")
	elseif isStory(0) then
		setCutscene(1, 1)
		
		learnSong(SONG_SHIELD)

		setStory(1)
		
		local camNode = getNode("CAM1")
		local camNode2 = getNode("CAM2")
		local camNode3 = getNode("CAM3")
		local camNode4 = getNode("NAIJASTART")
		local camDummy = createEntity("Empty")
		entity_warpToNode(camDummy, camNode)
		
		setCameraLerpDelay(0)
		cam_toEntity(camDummy)
		
		if doTrailerIntro then
			entity_animate(n, "trailerIntroAnim1", LOOP_INF)
		else
			entity_animate(n, "sitBack", LOOP_INF)
		end
		
		--watch(1)
		--debugLog("end of streaming voice")
		--watch(0.5)
		
		overrideZoom(0.6)
		entity_setPosition(camDummy, node_x(camNode), node_y(camNode))
		watch(0.5)
		
		setCameraLerpDelay(1)
		
		watch(0.5)
		
		fadeIn(3)
		
		voice("Naija_VerseCave")
		
		watch(0.5)
		
		
		entity_setPosition(camDummy, node_x(camNode2), node_y(camNode2), -200, 0, 0, 1)
		while entity_isInterpolating(camDummy) do
			watch(FRAME_TIME)
		end
		--[[
		entity_swimToNode(camDummy, camNode2, SPEED_SLOW)
		entity_watchForPath(camDummy)
		]]--
		
		entity_setPosition(camDummy, node_x(camNode3), node_y(camNode3), -200, 0, 0, 1)
		while entity_isInterpolating(camDummy) do
			watch(FRAME_TIME)
		end
		
		entity_setPosition(camDummy, node_x(camNode4), node_y(camNode4), -200, 0, 0, 1)
		while entity_isInterpolating(camDummy) do
			watch(FRAME_TIME)
		end	
		
		local bits = 6.0/FRAME_TIME
		for i=1,bits do
		
			overrideZoom(1, 6)
			watch(FRAME_TIME)
			
			setCameraLerpDelay(1.0 - (i/bits))
		end
		

					
		cam_toEntity(getNaija())
		
		watch(2)
		
		--entity_animate(n, "getUpFromSitBack")
		
		
		if doTrailerIntro then
			entity_animate(n, "trailerIntroAnim2")
			while entity_isAnimating(n) do
				watch(FRAME_TIME)
			end
			watch(2)
		else
			entity_animate(n, "getUpFromSitBack")
		end
		
		watch(2.5)
		--entity_setPosition(n, entity_x(n)+20, entity_y(n)+150, 1.4, 1)
		entity_moveToNode(n, getNode("OFFROCK"), SPEED_VERYSLOW)
		entity_watchForPath(n)
		
		
		overrideZoom(0)
		
		if isPlat(PLAT_MAC) then
			setControlHint(getStringBank(81), 1, 0)
		else
			setControlHint(getStringBank(61), 1, 0)
		end
		
		pickupGem("Naija-Token", 1)
		
		setCutscene(0)
		
		--[[
		pickupGem("PieceGreen", 1)
		pickupGem("PieceRed", 1)
		pickupGem("PieceTeal", 1)
		pickupGem("PyramidYellow", 1)
		pickupGem("PyramidPurple", 1)
		]]--
	else
		fadeIn(1)
		watch(1)
	end
end

