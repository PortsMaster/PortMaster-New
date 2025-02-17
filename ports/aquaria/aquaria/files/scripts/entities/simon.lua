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

-- Simon Says: "Eight Eyed Monster!"
-- BOROMAL
-- idle : waiting for user to click
-- playSeg : playing segment of song
-- wait : wait for user input
-- game over : user was too slow
-- victory

local STATE_PLAYSEG		= 1000
local STATE_WAIT		= 1001
local STATE_GAMEOVER	= 1002
local STATE_VICTORY		= 1003

v.songLen = 8
v.waitTime = 4.5
v.curNote = 1
v.onNote = 1
v.noteDelay = 0
v.userNote = 1

v.song = nil
v.eye = nil
v.center = 0
v.centerEye = 0
v.body = 0

v.idolWeight = 200

local function generateSong()
	for i=1, 10 do
		v.song[i] = math.random(8)-1
    end
end

function init(me)
	v.song = {}
	v.eye = {}

	setupEntity(me)
	entity_initSkeletal(me, "Simon")
	entity_setEntityType(me, ET_NEUTRAL)	
	
	entity_setActivation(me, AT_CLICK, 64, 512)
	for	i=1, 8 do
		v.eye[i] = entity_getBoneByIdx(me, i)
		--entity_getBoneByName(string.format("Eye%d",i))
		bone_setColor(v.eye[i], getNoteColor(i-1))
		bone_alpha(v.eye[i], 0)
	end
	v.center = entity_getBoneByName(me, "Center")	
	v.centerEye = entity_getBoneByName(me, "CenterEye")
	v.body = entity_getBoneByName(me, "Body")
	v.skirtLeft = entity_getBoneByName(me, "SkirtLeft")
	v.skirtRight = entity_getBoneByName(me, "SkirtRight")
	
	entity_animate(me, "idle")
	
	entity_setState(me, STATE_IDLE)
	
	entity_offset(me, 0, 20, 2, -1, 1, 1)
	
	entity_setCullRadius(me, 1024)
	
	bone_setSegs(v.body, 2, 32, 0.3, 0.3, -0.018, 0, 6, 1)
	bone_setSegs(v.skirtLeft, 2, 32, -0.3, 0.3, -0.018, 0, 6, 1)
	bone_setSegs(v.skirtRight, 2, 32, -0.3, 0.3, -0.018, 0, 6, 1)
	entity_setUpdateCull(me, 2500)
end

function postInit(me)
	if entity_isFlag(me, 1) then
		-- FormUpgradeEnergy2
		local ent = createEntity("upgrade-wok", "", entity_getPosition(me))
		entity_setWeight(ent, v.idolWeight)
	end
end

function update(me, dt)
	if entity_isState(me, STATE_PLAYSEG) then
		v.noteDelay = v.noteDelay + dt
		if v.noteDelay > 0.5 - (v.onNote*0.02) then
			v.noteDelay = 0
			playSfx(string.format("MenuNote%d", v.song[v.curNote]))
			local theEye = v.eye[v.song[v.curNote]+1]
			--bone_alpha(theEye, 0)
			bone_scale(theEye, 1, 0)
			bone_scale(theEye, 1, 1, 0.25, 1, -1)
			bone_alpha(theEye, 1)
			--bone_alpha(, 1, 0.25, 1, -1)
			if v.curNote >= v.onNote then
				entity_setState(me, STATE_WAIT, v.waitTime)
			end
			v.curNote = v.curNote + 1
		end
	end
	local nx,ny = entity_getPosition(getNaija())
	local sx,sy = entity_getPosition(me)
	local x = (nx-sx)*0.75
	local y = (ny-sy)*0.75
	x,y = vector_cap(x, y, 20)
	bone_setPosition(v.centerEye, x, y, 1.0)
end

function activate(me)
	--debugLog("ACTIVATE!")
	entity_setActivationType(me, AT_NONE)
	v.curNote = 1
	v.userNote = 1
	entity_setState(me, STATE_PLAYSEG)
	musicVolume(0.5, 0.5)
end

function enterState(me)
	local colorT = 0.2
	if entity_isState(me, STATE_IDLE) then
		--debugLog("IDLE!")
		entity_setActivationType(me, AT_CLICK)
		generateSong()
		v.onNote = 1
		v.curNote = 1
		v.userNote =1 
		bone_setColor(v.center, 0.5, 0.5, 1, colorT)
	elseif entity_isState(me, STATE_VICTORY) then
		--debugLog("VICTORY!")
		musicVolume(1, 1)
		if entity_isFlag(me, 0) then
			playSfx("secret")
			local ent = createEntity("upgrade-wok", "", entity_getPosition(me))
			entity_alpha(ent, 0)
			entity_alpha(ent, 1, 0.2)
			entity_setWeight(ent, v.idolWeight)
			entity_setFlag(me, 1)
		else
			playSfx("secret")
			local r = randRange(1, 70)
			if r < 10 then
				spawnIngredient("PlantLeaf", entity_getPosition(me))
			elseif r < 20 then
				spawnIngredient("FishOil", entity_getPosition(me))
			elseif r < 30 then
				spawnIngredient("SmallEgg", entity_getPosition(me))
			elseif r < 40 then
				spawnIngredient("SmallEye", entity_getPosition(me))
			elseif r < 50 then
				spawnIngredient("SeaCake", entity_getPosition(me))
			elseif r < 60 then
				spawnIngredient("HandRoll", entity_getPosition(me))
			else
				spawnIngredient("SmallBone", entity_getPosition(me))
			end
		end
		entity_setStateTime(me, 3)
	elseif entity_isState(me, STATE_GAMEOVER) then
		musicVolume(1, 1)
		shakeCamera(10, 1)
		for	i=1, 8 do
			bone_alpha(v.eye[i], 0)
		end	
		--debugLog("GAMEOVER!")
		playSfx("BeastForm")
		entity_setStateTime(me, 2)
		bone_setColor(v.center, 1, 0.5, 0.5, colorT)
	elseif entity_isState(me, STATE_WAIT) then
		--[[
		for	i=1, 8 do
			bone_alpha(v.eye[i], 0)
		end
		]]--	
		--debugLog("WAIT!")
		v.userNote = 1
		bone_setColor(v.center, 0.5, 1, 0.5, colorT)
	elseif entity_isState(me, STATE_PLAYSEG) then
		v.curNote = 1
		--debugLog("PLAYSEG!")
		bone_setColor(v.center, 0.5, 0.5, 1, colorT)
	end
end

function exitState(me)
	if entity_isState(me, STATE_WAIT) then
		entity_setState(me, STATE_GAMEOVER)
	elseif entity_isState(me, STATE_GAMEOVER) or entity_isState(me, STATE_VICTORY) then
		entity_setState(me, STATE_IDLE)
	end
end

function songNote(me, note)
	--debugLog("songNote!")
	if entity_isState(me, STATE_WAIT) then
		if note == v.song[v.userNote] then
			v.userNote = v.userNote + 1
			if v.userNote > v.onNote then
				if v.userNote > v.songLen then
					entity_setState(me, STATE_VICTORY)
				else
					v.onNote = v.onNote + 1
					entity_setState(me, STATE_PLAYSEG)
				end
			end
		else
			entity_setState(me, STATE_GAMEOVER)
		end
	end
end

function hitSurface(me)
	--entity_sound(me, "rock-hit")
end

function damage(me, attacker, bone, damageType, dmg)	
	return false
end
