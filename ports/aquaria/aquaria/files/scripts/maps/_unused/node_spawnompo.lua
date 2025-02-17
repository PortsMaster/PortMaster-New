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

v.ompo = 0
v.n = 0
v.doSetFlag = false

local function spawnOnNaija(me)
	v.ompo = createEntity("Ompo", "", entity_x(v.n)+10, entity_y(v.n)-16)
end

local function spawnOnNode(me)
	debugLog("spawning on nodeee")
	v.ompo = createEntity("Ompo", "", node_x(me), node_y(me))
end

function init(me)
	v.n = getNaija()
	
	if isMapName("TRAININGCAVE") then
		if isFlag(FLAG_OMPO, 0) then
			v.doSetFlag = true
			spawnOnNode(me)
		elseif isFlag(FLAG_OMPO, 1) or isFlag(FLAG_OMPO, 3) then
			spawnOnNaija(me)
		end
	elseif isMapName("MAINAREA") then
		if isFlag(FLAG_OMPO, 1) or isFlag(FLAG_OMPO, 3) then
			spawnOnNaija(me)
		end
	elseif isMapName("SONGCAVE") or isMapName("NAIJACAVE") then
		if isFlag(FLAG_OMPO, 1) or isFlag(FLAG_OMPO, 3) then
			spawnOnNaija(me)
		end
	elseif isMapName("SONGCAVE02") then
		if isFlag(FLAG_OMPO, 2) then
			spawnOnNode(me)
		elseif isFlag(FLAG_OMPO, 3) then
			spawnOnNaija(me)
		end
	elseif isMapName("VEDHACAVE") then
		if isFlag(FLAG_OMPO, 1) or isFlag(FLAG_OMPO, 3) then
			spawnOnNaija(me)
		end
	elseif isMapName("ENERGYTEMPLE01") then
		if isFlag(FLAG_OMPO, 3) then
			spawnOnNaija(me)
		end
	end
end

function update(me, dt)
	if v.doSetFlag and node_isEntityIn(me, v.n) then
		if isFlag(FLAG_OMPO, 0) then
			setFlag(FLAG_OMPO, 1)
		end
	end
end
