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

v.n = 0
v.mia = 0
v.done = false
v.head = 0
v.mx = 0
v.my = 0

function init(me)
	v.n = getNaija()
	v.mia = createEntity("13_Progression", "", node_x(me), node_y(me))
	entity_alpha(v.mia, 0)
	
	v.mx, v.my = node_getPosition(getNode("13spawn"))
end

function update(me, dt)
	if not v.done then
		if isFlag(FLAG_VISION_ENERGYTEMPLE, 0) and node_isEntityIn(me, v.n) then
			v.done = true
			
			setCutscene(1, 1)
			entity_idle(v.n)
			fadeOutMusic(4)
			overrideZoom(0.8, 3)
			
			stopVoice()
			--watchForVoice()
			
			watch(1)
			setSceneColor(0.2, 0.2, 1, 3)
			watch(2)
			
			shakeCamera(10, 2)
			playSfx("naijagasp")
			entity_setPosition(v.mia, v.mx, v.my)
			entity_flipToEntity(v.n, v.mia)
			entity_flipToEntity(v.mia, v.n)
			
			watch(0.5)
			
			cam_toEntity(v.mia)
			watch(0.5)
			spawnParticleEffect("miawarp", v.mx, v.my)
			playSfx("mia-appear")
			entity_alpha(v.mia, 1, 1)
			watch(1)
			
			local x, y = node_getPosition(getNode("13fight"))
			entity_setPosition(v.mia, x, y, 4, 0, 0, 1)
			
			shakeCamera(10, 4)
			
			watch(0.2)
			
			playSfx("mia-scream")
			
			watch(1.4)
			emote(EMOTE_NAIJAUGH)
			entity_flipToEntity(v.mia, v.n)
			entity_flipToEntity(v.n, v.mia)
			watch(1.5)
			entity_flipToEntity(v.mia, v.n)
			entity_flipToEntity(v.n, v.mia)
			
			--updateMusic()
			
			watch(2)
			voice("naija_see13")
			overrideZoom(0.5, 15)
			setSceneColor(1, 1, 1, 10)
			watch(2)
			
			screenFadeCapture()
			
			cam_toEntity(v.n)
			
			screenFadeGo(3)
			watch(2)
			
			entity_msg(v.mia, "firstvision")
			setCutscene(0)
						
			overrideZoom(0, 1)
		end
	end
end
