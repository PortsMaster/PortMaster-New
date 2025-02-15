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
v.started = false
v.priests = nil
v.numPriests = 0
v.door = 0

function init(me)
	v.priests = {}

	v.n = getNaija()

	local e = getFirstEntity()
	local i = 1
	while e ~=0 do
		if entity_isName(e, "Priest") then
			v.priests[i] = e
			i = i + 1
		end
		e = getNextEntity()
	end
	v.numPriests = i
	
	v.door = node_getNearestEntity(me, "energydoor")
	
	if not isFlag(FLAG_MITHALAS_PRIESTS, 0) then
		entity_setState(v.door, STATE_OPENED)
	end
end
	
function activate(me)	
end

function update(me, dt)
	if isFlag(FLAG_MITHALAS_PRIESTS,0) then
		if not v.started then
			if node_isEntityIn(me, v.n) then
				v.started = true
				entity_idle(v.n)
				playMusic("MiniBoss")
				for i=1,v.numPriests do
					cam_toEntity(v.priests[i])
					entity_setState(v.priests[i], STATE_APPEAR)
					watch(1)
				end
				overrideZoom(0.6, 1)
				cam_toEntity(v.n)
				for i=1,v.numPriests do
					entity_setState(v.priests[i], STATE_IDLE)
				end				
			end
		else
			local c = 0
			local e = getFirstEntity()
			while e ~= 0 do
				if entity_getEntityType(e) == ET_ENEMY and entity_isName(e, "Priest") then					
					c = c + 1
				end
				e = getNextEntity()
			end
			if c == 0 then
				setFlag(FLAG_MITHALAS_PRIESTS, 1)
				setFlag(FLAG_MINIBOSS_PRIESTS, 1)
				updateMusic()
				overrideZoom(0)
				entity_idle(v.n)
				changeForm(FORM_NORMAL)
				watch(1)
				entity_setInvincible(v.n, true)
				watch(1)				
				entity_animate(v.n, "agony", LOOP_INF)
				learnSong(SONG_SPIRITFORM)
				watch(1)
				changeForm(FORM_SPIRIT)
				voice("naija_song_spiritform")
				setControlHint(getStringBank(44), 0, 0, 0, 10, "", SONG_SPIRITFORM)
				entity_setInvincible(v.n, false)
				entity_setState(v.door, STATE_OPEN)
			end
		end
	end
end
