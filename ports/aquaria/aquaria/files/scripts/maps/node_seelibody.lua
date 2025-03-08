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

v.done = false

function init(me)
end

function update(me, dt)
	if not hasSong(SONG_DUALFORM) and not v.done and not hasLi() and node_isEntityIn(me, getNaija()) then
		v.done = true
		
		local li = getEntity("li")
		if li ~= 0 then
			entity_idle(getNaija())
			entity_flipToEntity(getNaija(), li)
			watch(0.5)
			overrideZoom(0.3)
			setCameraLerpDelay(0.0001)
			overrideZoom(1.2, 16)
			screenFadeGo(0.5)
			playSfx("ping")
			cam_toEntity(li)
			watch(4)
			cam_toEntity(getNaija())
			screenFadeGo(3)
			watch(0.5)
			setCameraLerpDelay(0)
			overrideZoom(0)
		end
	end
end
