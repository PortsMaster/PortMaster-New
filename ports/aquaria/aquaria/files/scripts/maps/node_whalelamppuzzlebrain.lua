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
v.door = 0

v.numNotes = 4
v.curNote = 1

function init(me)
	v.n = getNaija()
	
	v.l1 = getEntity("SongLamp3")
	v.l2 = getEntity("SongLamp2")
	v.l3 = getEntity("SongLamp7")
	v.l4 = getEntity("SongLamp1")
	
	v.door = node_getNearestEntity(me, "EnergyDoor")
	
	if isFlag(FLAG_WHALELAMPPUZZLE, 1) then
		entity_setState(v.door, STATE_OPENED)
	end
end
	
	--[[
			if entity_isState(l1, STATE_ON) and entity_isState(l2, STATE_ON) and entity_isState(l3, STATE_ON)
			and entity_isState(l4, STATE_ON) then
			end
	]]--
function activate(me, ent)
	if v.curNote == 1 and ent == v.l1 then
		v.curNote = v.curNote + 1
	elseif v.curNote == 2 and ent == v.l2 then
		v.curNote = v.curNote + 1
	elseif v.curNote == 3 and ent == v.l3 then
		v.curNote = v.curNote + 1
	elseif v.curNote == 4 and ent == v.l4 then
		v.curNote = v.curNote + 1
	else
		v.curNote = 1
	end
	
	if v.curNote > 4 then
		playSfx("Collectible")
		debugLog("DONE")
		setFlag(FLAG_WHALELAMPPUZZLE, 1)
		entity_setState(v.door, STATE_OPEN)
		
		v.curNote = 1
	end
end

function update(me, dt)

end

local function entityNumber(me, ent, num)
	if isFlag(FLAG_WHALELAMPPUZZLE, 1) then return end
end
