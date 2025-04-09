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
v.seen = false

local notes = { 4, 2, 3, 2, 1 }
local numNotes = 5
v.curNote = 1

v.warpLoc = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "DeepWhale")
	
	entity_scale(me, 1.5, 1.5)
	
	
	entity_setCullRadius(me, 3500)
	if isFlag(FLAG_DEEPWHALE, 0) then
		entity_setState(me, STATE_IDLE)
	else
		entity_setState(me, STATE_OPENED)
	end
	v.warpLoc = entity_getBoneByName(me, "WarpLoc")
	
	loadSound("DeepWhale-Open")
	
	entity_setInternalOffset(me, 0, -50)
	entity_setInternalOffset(me, 0, 50, 4, -1, 1, 1)
end

function postInit(me)
	v.n = getNaija()
	entity_setTarget(me, v.n)
end

function update(me, dt)
	if entity_isState(me, STATE_OPENED) then
		--debugLog("opened")
		local bx, by = bone_getWorldPosition(v.warpLoc)
		if entity_isPositionInRange(v.n, bx, by, 200) then
			loadMap("WHALE", "ENTER")
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_OPEN) then
		playSfx("DeepWhale-Open")
		v.seen = true
		entity_idle(v.n)
		entity_animate(me, "open")
		shakeCamera(10, 4)
		entity_flipToEntity(v.n, me)
		watch(1)
		emote(EMOTE_NAIJAUGH)
		watch(2)
		emote(EMOTE_NAIJAWOW)
		watch(2)
		emote(EMOTE_NAIJAGIGGLE)
		entity_setStateTime(me, 1)
	elseif entity_isState(me, STATE_OPENED) then
		entity_animate(me, "opened", -1)
		if isFlag(FLAG_DEEPWHALE, 0) then
			setFlag(FLAG_DEEPWHALE, 1)
		end
	end
end

function exitState(me)
	if entity_isState(me, STATE_OPEN) then
		entity_setState(me, STATE_OPENED)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function animationKey(me, key)
end

function hitSurface(me)
end

function lightFlare(me)
	if not v.seen then
		if entity_isEntityInRange(me, v.n, 600) then
			entity_idle(v.n)
			v.seen = true
			entity_flipToEntity(v.n, me)
			watch(0.2)
			emote(EMOTE_NAIJAUGH)
			watch(1.4)
			emote(EMOTE_NAIJALAUGH)
		end
	end
end

function songNote(me, note)

end

function songNoteDone(me, note)
	if entity_isState(me, STATE_IDLE) then
		debugLog(string.format("curNote: %d", v.curNote))
		if notes[v.curNote] == note then
			v.curNote = v.curNote + 1
		elseif notes[1] == note then
			v.curNote = 2
		else
			v.curNote = 1
		end
		if v.curNote > numNotes then
			entity_setState(me, STATE_OPEN)
		end
	end
end

function song(me, song)
end

function activate(me)
end

