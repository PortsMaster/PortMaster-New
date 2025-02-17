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

function init(me)
	node_setCursorActivation(me, true)
end
	
function activate(me)
	local n = getNaija()
	local node_bg = node_getNearestNode(me, "BG")
	local node_bgExit = node_getNearestNode(me, "BGEXIT")
	local sx, sy = entity_getScale(n)
	entity_switchLayer(n, -3)
	entity_scale(n, sx*0.5, sy*0.5, 1.5)
	entity_swimToNode(n, node_bg)
	entity_watchForPath(n)
	overrideZoom(0.5, 2)
	watch(0.5)
	while (not isLeftMouse()) and (not isRightMouse()) do
		watch(FRAME_TIME)
	end
	entity_scale(n, sx, sy, 1)
	overrideZoom(1, 1)
	entity_swimToNode(n, node_bgExit)
	entity_watchForPath(n)
	entity_switchLayer(n, 0)
	--entity_idle(n)
	overrideZoom(0)
end

function update(me, dt)
end
