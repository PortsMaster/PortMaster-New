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
--[[
	if isFlag(FLAG_SONGCAVECRYSTAL, 1) then
		node_setCursorActivation(me, false)
	else
		node_setCursorActivation(me, true)
	end
	]]--
end
	
local function runScene(me)
	setCutscene(1, 1)
	setFlag(FLAG_SONGCAVECRYSTAL, 1)
	
	local ghost = node_getNearestEntity(me, "ErulianGhost")

	local oldx, oldy = entity_getPosition(ghost)
	
	setCameraLerpDelay(1.0)
	
	cam_toNode(getNode("CRYSTALCAM1"))
	
	esetv(getNaija(), EV_LOOKAT, 0)
	
	entity_idle(getNaija())
	entity_swimToNode(getNaija(), getNode("NAIJACRYSTAL"))
	entity_watchForPath(getNaija())	
	entity_idle(getNaija())
	entity_flipToEntity(getNaija(), ghost)
		
	overrideZoom(0.9, 10)
	
	watch(2)
	
	voice("Naija_SongCrystal1")	
	watchForVoice()
	fadeOutMusic(3)
	
	
	
	local n = getNode("NAIJATOUCHCRYSTAL")
	
	entity_animate(getNaija(), "pushForward")
	watch(0.4)
	entity_setPosition(getNaija(), node_x(n), node_y(n), 1, 0, 0, 1)
	watch(1.0)
	entity_idle(getNaija())
	watch(0.5)
	entity_animate(getNaija(), "touchCrystal")
	while entity_isAnimating(getNaija()) do
		watch(FRAME_TIME)
	end
	entity_heal(getNaija(), 999)
	watch(0.2)
	local crystalNode = me
	spawnParticleEffect("SongCrystalActivate", node_x(crystalNode), node_y(crystalNode))
	playMusic("Mystery")
	
	setSceneColor(0.5, 0.5, 1, 10)
	
	watch(3)
	entity_alpha(ghost, 0.5, 3)

	setNaijaHeadTexture("")
	
	cam_toEntity(ghost)
	entity_setPosition(ghost, entity_x(ghost), entity_y(ghost)-256, 4, 0, 0, 1)
	entity_alpha(ghost, 1, 4)
	watch(1)
	voice("Naija_SongCrystal2")
	watch(2)
	entity_idle(getNaija())
	entity_animate(getNaija(), "look45", LOOP_INF, LAYER_HEAD)
	watch(1)
	cam_toNode(getNode("CRYSTALCAM2"))
	
	local n = getNode("NAIJACRYSTAL")
	entity_animate(getNaija(), "pushBack")
	watch(0.2)	
	entity_setPosition(getNaija(), node_x(n), node_y(n), 1.0, 0, 0, 1)
	
	entity_animate(getNaija(), "look45", LOOP_INF, LAYER_HEAD)
	watch(0.5)
	
	
	
	spawnParticleEffect("Erulian", entity_x(ghost), entity_y(ghost))
	watch(0.5)
	entity_idle(getNaija())
	entity_animate(getNaija(), "look45", LOOP_INF, LAYER_HEAD)

	
	watchForVoice()
	
	watch(0.5)
	
	voice("Naija_SongCrystal3")
	watch(2.5)
	vision("Erulian", 4, true)
	watchForVoice()
	
	spawnParticleEffect("SongCrystalActivate", node_x(crystalNode), node_y(crystalNode))

	overrideZoom(1.5, 2)
	
	entity_alpha(ghost, 0, 5)
	fadeOutMusic(6)

	setNaijaHeadTexture("Pain")
	esetv(ghost, EV_LOOKAT, 0)
	cam_toEntity(getNaija())
	
	entity_animate(getNaija(), "look-45", LOOP_INF, LAYER_HEAD)
	voice("Naija_SongCrystal3b")
	
	watchForVoice()
	watch(1.5)
	
	voice("Naija_SongCrystal4")

	watch(1.4)
	
	overrideZoom(1, 1)
	cam_toNode(getNode("CRYSTALCAM2"))	
	
			
	setNaijaHeadTexture("")
	entity_idle(getNaija())
	
	watchForVoice()
	
	entity_idle(getNaija())	
	
	cam_toEntity(getNaija())

	setSceneColor(1, 1, 1, 4)	
	
	watch(2)
	
	setCameraLerpDelay(0)
	
	wait(1)
	
	
	node_setCursorActivation(me, false)
	
	overrideZoom(0)
	learnSong(SONG_PULL)
	
	setCutscene(0)
	
	setControlHint(getStringBank(36), 0, 0, 0, 10, "", SONG_BIND)
	
	playMusic("Cave")
	
	
	voice("naija_song_bind")	
	entity_setPosition(ghost, oldx, oldy)
	
	esetv(getNaija(), EV_LOOKAT, 1)
	
	setBeacon(BEACON_ENERGYTEMPLE, true, -100, -50, 1, 0.25, 0.25)
	beaconEffect(BEACON_ENERGYTEMPLE)
end

function activate(me)
	runScene(me)
end

function update(me, dt)
	if isFlag(FLAG_SONGCAVECRYSTAL, 0) and node_isEntityIn(me, getNaija()) then
		runScene(me)
	end
end
