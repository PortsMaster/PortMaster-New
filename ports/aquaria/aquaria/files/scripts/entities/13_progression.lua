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
v.curNode = 1
v.lastNode = 0
v.bone_head = 0

v.leaveNode = 0

v.range = 0

function init(me)
	setupEntity(me)
	entity_setEntityLayer(me, 1)
	
	loadSound("13Touch")
	loadSound("mia-appear")
	loadSound("mia-scream")
	loadSound("mia-sillygirl")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
	
	entity_setPosition(me, node_getPosition(v.lastNode))
	
	entity_initSkeletal(me, "13")
	entity_scale(me, 0.6, 0.6)
	entity_animate(me, "idle", -1)
	v.bone_head = entity_getBoneByName(me, "Head")
	

	
	v.range = entity_getNearestNode(me, "13range")
end

v.doFirstVision = false
v.done1st = false
v.over = false
v.is = false	

function update(me, dt)
	entity_setLookAtPoint(me, bone_getWorldPosition(v.bone_head))
	
	if v.doFirstVision and not v.over then
		if node_isEntityIn(v.range, v.n) and not v.is then
			v.is = true
			
			setCutscene(1,0)
			-- do scene
			setFlag(FLAG_VISION_ENERGYTEMPLE, 1)
			stopVoice()
			
			musicVolume(0, 2)
			
			--entity_clearVel(v.n)
			entity_idle(v.n)
			entity_setInvincible(v.n, true)
			-- watch for seahorse!
			watch(1)
			
			overrideZoom(0.9, 4)
			
			entity_flipToEntity(me, v.n)
			entity_flipToEntity(v.n, me)
			
			entity_swimToNode(v.n, getNode("NAIJA_13"), SPEED_NORMAL)
			entity_watchForPath(v.n)
			
			entity_flipToEntity(me, v.n)
			entity_flipToEntity(v.n, me)
			watch(2)
			entity_animate(me, "touchNaija")
			watch(1)
			

			local ompo = getEntity("Ompo")
			entity_msg(ompo, "fade")
			
			playSfx("13Touch")
			while entity_isAnimating(me) do
				watch(FRAME_TIME)
			end
			setNaijaHeadTexture("Blink")
			watch(1)
			
			vision("EnergyTemple", 4)
			
			stopMusic()
			fade2(1, 0.1, 1, 1, 1)
			
			learnSong(SONG_ENERGYFORM)
			changeForm(FORM_ENERGY)
			
			setCanChangeForm(false)
			
			local sn = getNode("FIRSTVISIONSTART")
			entity_setPosition(v.n, node_x(sn), node_y(sn))
			entity_fh(v.n)
			fade2(0, 2, 1, 1, 1)
			
			overrideZoom(0)
			
			emote(EMOTE_NAIJAUGH)
			
			setInvincibleOnNested(false)
			avatar_setCanDie(false)
			
			local cn = getNode("FIRSTVISIONEXIT")
			
			local c = 0
			while not node_isEntityIn(cn, v.n) do 
				wait(FRAME_TIME)
				if entity_getHealth(v.n) <= 1 then
					entity_heal(v.n, 1)
					c = c + 1
				end
				if c > 3 then
					break
				end
			end
			entity_heal(v.n, 100)
			fade2(1, 0.5, 1, 1, 1)
			watch(0.5)
			entity_heal(v.n, 100)
			
			setCanChangeForm(true)
			changeForm(FORM_NORMAL)
			unlearnSong(SONG_ENERGYFORM)
			
			setInvincibleOnNested(true)
			
			local n13 = getNode("NAIJA_13")
			
			entity_setPosition(v.n, node_x(n13), node_y(n13))
			entity_rotate(v.n, 0)
			entity_flipToEntity(v.n, me)
			entity_idle(v.n)
			entity_offset(v.n, 0, 0)
			watch(1)
			
			entity_heal(v.n, 100)
			avatar_setCanDie(true)
			
			fade2(0, 0.5, 1, 1, 1)
			
			vision("EnergyTemple", 4)
			
			fade2(1, 0.5, 1, 1, 1)
			watch(0.5)
			fade2(0, 5, 1, 1, 1)
			watch(5)
			
			entity_alpha(me, 0.01, 3)
			v.over = true
			entity_setPosition(me, entity_x(me)+50, entity_y(me)-50, 5, 0, 0, 1)
			setMusicToPlay("OpenWaters")
			playMusic("OpenWaters")					
			watch(2)

			entity_setInvincible(v.n, false)
			entity_rotate(me, -90, 2, 0, 0, 1)
			playSfx("mia-sillygirl")
			watch(1)
			setNaijaHeadTexture("")
			
			
			entity_animate(me, "trail")
			local nx, ny = node_getPosition(getNode("13LEAVE"))
			entity_setPosition(me, nx, ny, 8, 0, 0, 1)
			entity_setCullRadius(me, 4000)
			watch(0.5)
			
			watch(2)
			emote(EMOTE_NAIJASADSIGH)
			watch(2)
			
			voice("naija_vision_mainarea")
			
			setBeacon(BEACON_SONGCAVE, true, 128.578, 159.092, 0.5, 1, 1)
			beaconEffect(BEACON_SONGCAVE)
			
			setCutscene(0,0)
			v.is = false
			--entity_setState(me, STATE_TRANS, 2)
		end
	end
end


function enterState(me)
end

function exitState(me)
end

function msg(me, msg)
	if msg == "firstvision" then
		v.doFirstVision = true
	end
end
