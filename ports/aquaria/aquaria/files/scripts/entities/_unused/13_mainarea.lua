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

--- THINK THIS FILE ISN'T USED ANYMORE!!!!
--- NOT UUUUUSED!

v.n = 0
v.curNode = 1
v.lastNode = 0
v.bone_head = 0

local STATE_HEADTOCAVE 	= 1000
local STATE_TRANS			= 1001

function init(me)
	setupEntity(me)
	entity_setEntityLayer(me, 1)
	--entity_setBeautyFlip(me, false)
	loadSound("13Touch")
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)	
	
	v.lastNode = getNode(string.format("13_%d", v.curNode))
	entity_setPosition(me, node_getPosition(v.lastNode))
	-- check flags
	if isFlag(FLAG_VISION_ENERGYTEMPLE, 0) then
		entity_initSkeletal(me, "13")
		entity_scale(me, 0.6, 0.6)
		entity_animate(me, "idle", -1)
		v.bone_head = entity_getBoneByName(me, "Head")
	else
		entity_alpha(me)
		entity_setPosition(me)
	end
end

v.done1st = false
v.over = false
v.is = false
local function doScene(me)
	v.done1st = true
	if v.is then return end
	setCameraLerpDelay(1)
	v.is = true
	entity_idle(v.n)
	entity_setInvincible(v.n, true)
	entity_flipToEntity(v.n, me)
	
	local ompo = getEntity("Ompo")
	entity_msg(ompo, "fmia")
	
	watch(1)	
	cam_toEntity(me)
	voice("Naija_See13")
	watch(6)
	--fade(1, 1)
	
	--watch(1)
	
	--watch(0.1)
	screenFadeCapture()
	
	
	setCameraLerpDelay(0)
	cam_toEntity(v.n)
	cam_setPosition(entity_x(v.n), entity_y(v.n))
	
	watch(0.1)
	--watch(0.5)
	--fade(0,1)
	screenFadeTransition(2)
	watch(0.5)
	--watch(1)
	entity_setInvincible(v.n, false)
	v.is = false
end

function update(me, dt)	
	if entity_isState(me, STATE_HEADTOCAVE) then
		--debugLog("Head to Cave")
		return
	end
	if v.bone_head ~= 0 then
		entity_setLookAtPoint(me, bone_getWorldPosition(v.bone_head))
	end
	if isFlag(FLAG_VISION_ENERGYTEMPLE, 0) and v.n ~= 0 then
		if not v.done1st and v.curNode == 1 and node_isEntityIn(v.lastNode, v.n) then
			doScene(me)
		end
		if not entity_isInterpolating(me) and entity_isEntityInRange(me, v.n, 256) and not v.is then
			v.curNode = v.curNode + 1
			--debugLog(string.format("CURNODE: %f", v.curNode))
			if v.curNode > 4 then
				-- do scene
				setFlag(FLAG_VISION_ENERGYTEMPLE, 1)
				stopVoice()
				
				musicVolume(0, 2)
				
				--entity_clearVel(v.n)
				entity_idle(v.n)
				entity_setInvincible(v.n, true)
				-- watch for seahorse!
				watch(1)
				
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
				local ox, oy = entity_getPosition(v.n)
				
				learnSong(SONG_ENERGYFORM)
				changeForm(FORM_ENERGY)
				
				setCanChangeForm(false)
				
				local sn = getNode("FIRSTVISIONSTART")
				entity_setPosition(v.n, node_x(sn), node_y(sn))
				entity_fh(v.n)
				fade2(0, 2, 1, 1, 1)
				
				emote(EMOTE_NAIJAUGH)
				
				setInvincibleOnNested(false)
				avatar_setCanDie(false)
				entity_heal(v.n, 100)
				
				local cn = getNode("FIRSTVISIONEXIT")
				
				
				local c = 0
				while not node_isEntityIn(cn, v.n) do 
					wait(FRAME_TIME)
					if entity_getHealth(v.n) <= 1 then
						--entity_heal(v.n, 1)
						c = c + 1
					end
					if c > 2 then
						break
					end
				end
				
				entity_heal(v.n, 100)
				
				setCanChangeForm(true)
				changeForm(FORM_NORMAL)
				unlearnSong(SONG_ENERGYFORM)
				
				setInvincibleOnNested(true)
				
				fade2(1, 0.5, 1, 1, 1)
				entity_setPosition(v.n, ox, oy)
				entity_rotate(v.n, 0)
				entity_flipToEntity(v.n, me)
				entity_idle(v.n)
				fade2(0, 0.5, 1, 1, 1)
				
				entity_heal(v.n, 100)
				
				avatar_setCanDie(true)
				
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
				voiceInterupt("Naija_Vision_MainArea")
				--entity_setPosition(me)
				entity_setInvincible(v.n, false)
				watch(1)
				setNaijaHeadTexture("")
				entity_setState(me, STATE_TRANS, 2)
			else
				v.lastNode = getNode(string.format("13_%d", v.curNode))
				entity_setPosition(me, node_x(v.lastNode), node_y(v.lastNode), -400, 0, 0, 0)
			end
		end
		if not v.over then
			if math.abs(entity_x(me)-entity_x(v.n)) > 100 then
				entity_flipToEntity(me, v.n)
			end
		end
	end
end


function enterState(me)
	if entity_isState(me, STATE_HEADTOCAVE) then
		entity_animate(me, "trail")
		--esetv(me, EV_LOOKAT, 0)
		--debugLog("Setting HeadToCave")
		entity_setPosition(me, entity_getPosition(me))
		entity_clearVel(me)
		entity_swimToNode(me, entity_getNearestNode(me, "13_SONGCAVE"), SPEED_SLOW)
		entity_setCullRadius(me, 1024)
	end
end

function exitState(me)
	if entity_isState(me, STATE_TRANS) then
		entity_setState(me, STATE_HEADTOCAVE)
	end
end
