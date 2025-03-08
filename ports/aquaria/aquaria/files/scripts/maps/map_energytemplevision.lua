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

local function hasQuit()
	if not (getEnqueuedState() == "") then
		fade2(1, 0, 1, 1, 1)
		return true
	end
	return false
end

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
	
	local camKrotiteBattle1 = getNode("CAMKROTITEBATTLE1")
	
	local camMarch = getNode("CAMMARCH")
	
	local camBattle1 = getNode("CAMBATTLE1")
	local camBattle2 = getNode("CAMBATTLE2")
	
	
		
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
	playMusicOnce("MarchOfTheKrotites")
	
	
	entity_setPosition(camDummy, node_x(cam2), node_y(cam2), 10, 0, 0, 1)

	overrideZoom(0.8, 10.1)
	
	watch(4)
	
	voice("Naija_Vision_EnergyBoss2")
	
	while entity_isInterpolating(camDummy) do
		watch(FRAME_TIME)
	end
	
	entity_setPosition(camDummy, node_x(cam3), node_y(cam3), 5, 0, 0, 1)

	overrideZoom(0.5, 6)
	
	while entity_isInterpolating(camDummy) do
		watch(FRAME_TIME)
	end
	
	fade2(1, 1)
	watch(1)
	
	
	-- two krotites fighting
	
	voice("Naija_Vision_EnergyBoss3")
	
	cam_toEntity(camDummy)
	
	overrideZoom(1)
	
	entity_setPosition(camDummy, node_x(camKrotiteBattle1), node_y(camKrotiteBattle1))
	watch(0.5)
	
	local ent = node_getNearestEntity(camKrotiteBattle1, "KrotiteVsKrotite")
	entity_setState(ent, STATE_ON)
	fade2(0, 0.4)
	watch(0.4)
	
	watch(3)
	
	overrideZoom(0.5, 4)
	
	watch(3.5)
	
	fade2(1, 0.5)
	watch(0.5)
	
	-- marching
	
	
	cam_toEntity(node_getNearestEntity(camMarch))
	watch(0.5)
	
	local e = getFirstEntity()
	while e ~= 0 do
		if entity_isName(e, "krotiteontheway") then
			entity_setState(e, STATE_ON)
		end
		e = getNextEntity()
	end
	
	fade2(0, 0.4)
	watch(0.4)
	
	voice("Naija_Vision_EnergyBoss4")
	
	watch(4)
	
	fade2(1, 0.5)
	watch(0.5)
	
	local e = getFirstEntity()
	while e ~= 0 do
		if entity_isName(e, "KrotiteOnTheWay") then
			entity_delete(e)
		end
		e = getNextEntity()
	end
	
	-- close up battle scene
	
	cam_toEntity(camDummy)
	
	entity_setPosition(camDummy, node_x(camBattle1), node_y(camBattle1))
	watch(0.5)
	
	local ent = node_getNearestEntity(camBattle1, "KrotiteErulianBattle01")
	entity_setState(ent, STATE_ON)
	fade2(0, 0.4)
	watch(0.4)
	
	watch(3)
	
	entity_setPosition(camDummy, node_x(camBattle2), node_y(camBattle2), 2, 0, 0, 1)
	
	watch(4)
	
	--[[
	setGameSpeed(0.5, 0.2)
	watch(1)
	setGameSpeed(1, 0.2)
	watch(3)
	]]--
	
	--[[
	fade2(1, 0.5)
	watch(0.5)
	]]--
	
	toggleBlackBars(true)
	
	showImage("Visions/EnergyBoss/00")
	voice("Naija_Vision_EnergyBoss5")
	watchForVoice()
	watch(4)
	hideImage()
	overrideZoom(1, 7)
	watch(5)

	setOverrideVoiceFader(-1)
	
	setCutscene(0)
	
	loadMap("EnergyTemple05", "RETURN")
	--[[
	fade2(0, 0.5, 1, 1, 1)
	
	cam_toEntity(n)
	]]--
end


