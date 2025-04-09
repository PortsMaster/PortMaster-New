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

v.test = false

function init()
	setCutscene(1,1)

	local n = getNaija()
	
	fade2(0, 1, 1, 1, 1)
	--return
	
	setOverrideVoiceFader(0.5)
	
	local node = getNode("HIDENAIJA")
	entity_setPosition(getNaija(), node_x(node), node_y(node))

	
	local camDummy = createEntity("empty")
	local s1c1 = getNode("S1C1")
	local s1c2 = getNode("S1C2")
	local s1c3 = getNode("S1C3")
	
	local s2c1 = getNode("S2C1")
	local s2c2 = getNode("S2C2")
	local s2c3 = getNode("S2C3")
	
	local s3c1 = getNode("S3C1")
	
		
	-- 1

	overrideZoom(1)
	entity_warpToNode(camDummy, s1c1)
	cam_toEntity(camDummy)
	watch(0.5)

	overrideZoom(0.8)
	
	fade2(0, 0, 1, 1, 1)
	fadeIn(1)
	watch(1)

	playMusicOnce("Prometheus")
	
	
	entity_setPosition(camDummy, node_x(s1c2), node_y(s1c2), 16, 0, 0, 1)

	overrideZoom(0.5, 16)
	
	watch(10)
	
	voice("Naija_Vision_SunTemple1")
	
	while entity_isInterpolating(camDummy) do
		watch(FRAME_TIME)
	end
	
	entity_setPosition(camDummy, node_x(s1c3), node_y(s1c3), 5, 0, 0, 1)

	overrideZoom(0.6, 6)
	
	while entity_isInterpolating(camDummy) do
		watch(FRAME_TIME)
	end
	
	fade2(1, 1, 1, 1, 1)
	watch(1)
	
	
	--2 
	
	entity_setPosition(camDummy, node_x(s2c1), node_y(s2c1), 0.1)
	watch(1)
	
	overrideZoom(0.8)
	
	entity_setPosition(camDummy, node_x(s2c2), node_y(s2c2), 8, 0, 0, 1)
	
	fade2(0, 1, 1, 1, 1)
	watch(1)
	
	
	watch(3)
	voice("Naija_Vision_SunTemple2")
	
	while entity_isInterpolating(camDummy) do
		watch(FRAME_TIME)
	end
	
	
	entity_setPosition(camDummy, node_x(s2c3), node_y(s2c3), 8, 0, 0, 1)
	
	watch(2)
	
	entity_animate(node_getNearestEntity(s2c2, "Architect"), "create", -1)
	watch(2)
	
	spawnParticleEffect("TinyRedExplode", node_x(s2c3), node_y(s2c3))
	
	watch(0.4)
	
	createEntity("ClockworkFish", "", node_x(s2c3), node_y(s2c3))
	
	while entity_isInterpolating(camDummy) do
		watch(FRAME_TIME)
	end
	
	
	fade2(1, 1, 1, 1, 1)
	watch(1)
	
	-- 3
	overrideZoom(0.3)
	entity_setPosition(camDummy, node_x(s3c1), node_y(s3c1), 0.1)
	watch(0.5)
	
	
	
	fade2(0, 1, 1, 1, 1)
	overrideZoom(1.0, 11)
	watch(1.5)
	
	setSceneColor(1, 0.2, 0.2, 6)
	
	watch(3)
	
	voice("Naija_Vision_SunTemple3")
	
	watch(6.5)
		
	toggleBlackBars(1)
	showImage("Visions/SunTemple/00")
	--voice("Naija_Vision_EnergyBoss5")
	watchForVoice()
	watch(7)
	
	hideImage()
	
	fade(1, 1, 1, 1, 1)
	watch(1)
	
	

	setOverrideVoiceFader(-1)
	
	if v.test then
		fade2(0, 0.5, 1, 1, 1)
	
		cam_toEntity(n)
		setSceneColor(1, 1, 1, 5)
	else
		learnSong(SONG_SUNFORM)
		watch(1)
		entity_idle(n)
		changeForm(FORM_SUN)
		
		setCutscene(0)
		loadMap("SunWormTest", "RETURN")
	end
	
	setCutscene(0)
end


