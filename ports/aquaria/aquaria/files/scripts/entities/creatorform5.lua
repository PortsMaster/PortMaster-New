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

-- intro animation sequence:
local STATE_INTRO			= 1000
local STATE_INTRO2			= 1001
local STATE_INTRO3			= 1002
-- creator is getting ready to sing:
local STATE_SING			= 1003
-- creator is singing a song:
local STATE_PLAYSEG			= 1004
-- creator is in pain:
local STATE_PAIN			= 1005
-- naija sings a wrong note:
local STATE_WRONG			= 1006

local STATE_SPAWNSPHERES	= 1007

v.delay = 0

v.songNotes 				= nil

v.songSize 				= 0
v.curNote 				= 1
v.noteDelay 				= 0
v.songLevel 				= 3
v.waitTime				= 5
v.userNote				= 1
v.maxHits				= 5
v.hits 					= v.maxHits
-- counts # of successful songs between song levels
v.songsDone				= 0


v.setSongSize			= 3

v.bone_head				= 0

v.died					= 0

local function getHitPerc()
	return v.hits/v.maxHits
end

function init(me)
	v.songNotes = {}

	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "CreatorForm5")	
	entity_setAllDamageTargets(me, false)
	
	--entity_generateCollisionMask(me)
	
	entity_setState(me, STATE_INTRO)
	entity_alpha(me, 0)
	
	entity_scale(me, 0.5, 0.5)
	entity_setCullRadius(me, 1024)
	
	v.bone_head = entity_getBoneByName(me, "Head")
	
	esetv(me, EV_ENTITYDIED, 1)
	
	loadSound("quakeloop1")
	loadSound("quakeloop2")
	loadSound("quakeloop3")
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	
	loadSound("hellbeast-shot")
end

function entityDied(me)
end

function postInit(me)
	v.n = getNaija()
	local node = getNode("NAIJA5")
	entity_setPosition(v.n, node_x(node), node_y(node), 2, 0, 0, 1)
	entity_flipToEntity(v.n, me)
	entity_setTarget(me, v.n)
	
	local node = getNode("LIDOOR2")
	local door = node_getNearestEntity(node, "FinalDoor")
	entity_setState(door, STATE_CLOSED)
	
	musicVolume(1, 1)
	playMusic("worship4")
end


local function generateSong(size)
	debugLog("generating song")
	v.songSize = size
	for i=1,size do
		v.songNotes[i] = math.random(8)-1
    end
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) then
		v.delay = v.delay + dt
		if v.delay > 2 then
			v.delay = 0
			entity_setState(me, STATE_SING) 
		end
	elseif entity_isState(me, STATE_WAIT) then
		local shots = 0
		local e = getFirstEntity()
		while e ~= 0 do
			if eisv(e, EV_TYPEID, EVT_DARKLISHOT) then
				shots = shots + 1
			end
			e = getNextEntity()
		end
		if shots == 0 then
			entity_setState(me, STATE_IDLE)
		end
	elseif entity_isState(me, STATE_PLAYSEG) then
		v.noteDelay = v.noteDelay + dt
		if v.noteDelay > 0.5 - (v.songLevel*0.02) then
			debugLog(string.format("singing note: %d", v.songNotes[v.curNote]))
			v.noteDelay = 0
			
			local sfx = playSfx(getNoteName(v.songNotes[v.curNote], "low-"))
			fadeSfx(sfx, 2)
			
			playSfx("")
			
			local x, y = entity_getPosition(me)
			local dx, dy = getNoteVector(v.songNotes[v.curNote], 256)
			x = x + dx
			y = y + dy
			
			local t = 1
			
			local noteQuad = createQuad(string.format("Song/NoteSymbol%d", v.songNotes[v.curNote]), 6)
			quad_alpha(noteQuad, 0)
			quad_alpha(noteQuad, 1, 0.1)
			quad_scale(noteQuad, 3, 3)
			quad_scale(noteQuad, 6, 6, t, 0, 0, 1)
			quad_color(noteQuad, getNoteColor(v.songNotes[v.curNote]))
			local node = getNode(string.format("SN%d", v.songNotes[v.curNote]))
			quad_setPosition(noteQuad, node_x(node), node_y(node))
			quad_delete(noteQuad, t)
			
			if v.curNote >= v.songSize then
				entity_setState(me, STATE_SPAWNSPHERES, -1)
			else
				v.curNote = v.curNote + 1
			end
		end
	end
	overrideZoom(0.5)
end

function msg(me, msg)
	if entity_isState(me, STATE_WAIT) then
		if msg == "died" then
			v.died = v.died + 1
			if v.died == 3 then
				entity_setState(me, STATE_PAIN)
			end
		end
	end
end

v.incut = false

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		v.died = 0
		entity_animate(me, "idle", -1)
		
		local e = getFirstEntity()
		while e ~=0 do
			if eisv(e, EV_TYPEID, EVT_DARKLISHOT) then
				
			end
			e = getNextEntity()
		end
		
	elseif entity_isState(me, STATE_INTRO) then
		entity_idle(v.n)
		disableInput()
		cam_toEntity(me)
		
		entity_alpha(me, 0)
		entity_alpha(me, 1, 2)
		entity_setStateTime(me, 2)
	elseif entity_isState(me, STATE_INTRO2) then
		entity_setStateTime(me, entity_animate(me, "jumpOut"))
	elseif entity_isState(me, STATE_INTRO3) then
		entity_setStateTime(me, entity_animate(me, "land"))
	elseif entity_isState(me, STATE_SING) then
		-- animate?
		entity_setStateTime(me, 0.1)
	elseif entity_isState(me, STATE_PLAYSEG) then
		v.curNote = 1
		generateSong(v.setSongSize)
	elseif entity_isState(me, STATE_WAIT) then
		v.userNote = 1
	elseif entity_isState(me, STATE_PAIN) then
		--bone_damageFlash(me, entity_getBoneByIdx(me, 0))
		
		for i=0,50 do
			bone_damageFlash(entity_getBoneByIdx(me, i))
		end
		
		entity_setStateTime(me, entity_animate(me, "pain"))
	elseif entity_isState(me, STATE_WRONG) then
		entity_setStateTime(me, entity_animate(me, "wrong"))
	elseif entity_isState(me, STATE_ATTACK) then
		entity_setStateTime(me, entity_animate(me, "attack"))
		for i=1,3 do
			local sn = math.random(8)-1
			local node = getNode(string.format("SN%d", sn))
			createEntity("Mutilus", "", node_x(node), node_y(node))
		end
	elseif entity_isState(me, STATE_TRANSITION) then
		if not v.incut then
			entity_setStateTime(me, 99)
			v.incut = true
			entity_idle(v.n)
			cam_toEntity(me)
			overrideZoom(0.9)
			watch(entity_animate(me, "die"))
			watch(3)
			overrideZoom(0.8)
			shakeCamera(2, 4)
			local loop = playSfx("quakeloop1")
			watch(4)
			overrideZoom(0.7)
			shakeCamera(20, 4)
			fadeSfx(loop, 0.5)
			local loop = playSfx("quakeloop2")
			watch(4)
			overrideZoom(0.6)
			fade2(1, 4, 1, 1, 1)
			shakeCamera(100, 4)
			fadeSfx(loop, 0.5)
			local loop = playSfx("quakeloop3")
			watch(4)
			entity_setStateTime(me, 0.1)
			v.incut = false
			fadeSfx(loop, 4)
		end
	elseif entity_isState(me, STATE_DELAY) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_SPAWNSPHERES) then
		entity_setStateTime(me, entity_animate(me, "attack"))
	end
end

v.ic = false

function exitState(me)
	if entity_isState(me, STATE_INTRO) then
		entity_setState(me, STATE_INTRO2)
	elseif entity_isState(me, STATE_SPAWNSPHERES) then
		if not v.ic then
			v.ic = true
			
			for n=1,v.songSize do
				local x, y = entity_getPosition(me)
				local dx, dy = getNoteVector(v.songNotes[n], 440)
				x = x + dx
				y = y + dy
				
				local e = createEntity("dark-li-shot", "", x, y)
				entity_msg(e, "note", v.songNotes[n])
				entity_msg(e, "sd", n*(1.0-((1.0-getHitPerc())*0.1)))
				
				entity_setMaxSpeedLerp(e, 1.0+((1.0-getHitPerc())*0.5))
				
				--[[
				local t = 3- (3-songLevel)*0.5
				if t <= 0 then
					t = 0.5
				end
				]]--
				--wait(1)
			end	
			
			entity_setState(me, STATE_WAIT)
			
			v.ic = false
		end
	elseif entity_isState(me, STATE_INTRO2) then
		entity_setState(me, STATE_INTRO3)
	elseif entity_isState(me, STATE_INTRO3) then
		entity_idle(v.n)
		enableInput()
		cam_toEntity(v.n)
		
		entity_setState(me, STATE_IDLE)
		--[[
	elseif entity_isState(me, STATE_WAIT) then
		entity_setState(me, STATE_ATTACK)
		]]--
	elseif entity_isState(me, STATE_TRANSITION) then
		-- transition to finalboss02
		loadMap("FinalBoss02", "ENTER")
	elseif entity_isState(me, STATE_SING) then
		entity_setState(me, STATE_PLAYSEG)
	elseif entity_isState(me, STATE_PAIN) then
		v.songLevel = v.songLevel + 1
		v.hits = v.hits - 1
		debugLog("test")
		if v.hits <= 0 then
			entity_setState(me, STATE_TRANSITION)
		else
			entity_setState(me, STATE_IDLE)
		end
	elseif entity_isState(me, STATE_WRONG) then
		entity_setState(me, STATE_ATTACK)
	elseif entity_isState(me, STATE_ATTACK) then
		local bx, by = bone_getWorldPosition(v.bone_head)
		for i=1,3,1 do
			createEntity("Mutilus", "", bx, by)
		end
		entity_setState(me, STATE_DELAY, 8)
	elseif entity_isState(me, STATE_DELAY) then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
	-- song spheres handle the work now
--[[
	if entity_isState(me, STATE_WAIT) then
		if note == v.songNotes[v.userNote] then
			v.userNote = v.userNote + 1
			if v.userNote > v.songSize then
				v.songsDone = v.songsDone + 1
				if v.songsDone >= 3 then
					v.songLevel = v.songLevel + 1
					v.songsDone = 0
				end
				entity_setState(me, STATE_PAIN)
			end
		else
			entity_setState(me, STATE_WRONG)
		end
	end
]]--
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

