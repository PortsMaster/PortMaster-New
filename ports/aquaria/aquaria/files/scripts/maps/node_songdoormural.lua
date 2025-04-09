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

v.giggled = false

function init(me)
	node_setCursorActivation(me, true)
end

function activate(me)

	screenFadeCapture()
	setCameraLerpDelay(0.0001)
	cam_toEntity(getEntity("SongDoor1"))
	screenFadeGo(3)
	watch(3)
	if not v.giggled then
		emote(EMOTE_NAIJAGIGGLE)
		v.giggled = true
	end
	watch(2)
	
	screenFadeCapture()
	cam_toEntity(getNaija())
	screenFadeGo(2)
	
	watch(1)
	
	setCameraLerpDelay(0)
end

