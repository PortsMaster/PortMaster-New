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

v.n1 = 0
v.n2 = 0
v.n3 = 0

function init(me)
	v.n = getNaija()
	
	node_setCursorActivation(me, true)
	
	v.n1 = getNode("N1")
	
	-- monsters
	v.n2 = getNode("N2")
	v.n3 = getNode("N3")
end

function update(me, dt)
end

function activate(me)
	entity_idle(v.n)
	
	shakeCamera(0,0.001)
	
	fade(1,0)
	
	setCameraLerpDelay(0.0001)
	cam_toNode(v.n1)
	
	overrideZoom(0.7)
	
	overrideZoom(1, 12)
	
	fade(0, 4)
	watch(4)
	
	watch(4)
	
	fade(1, 4)
	watch(4)
	
	cam_toNode(v.n2)
	
	watch(2)
	
	shakeCamera(2, 200)
	
	fade(0, 0.1) watch(0.1)
	fade(1, 0.1) watch(0.1)
	fade(0, 0.1) watch(0.1)
	fade(1, 0.1) watch(0.1)
	watch(0.5)
	fade(0, 0.1) watch(0.1)
	watch(1)
	fade(1, 0.2) watch(0.2)
	
	
	cam_toNode(v.n3)
	
	
	fade(0, 0.1) watch(0.1)
	fade(1, 0.1) watch(0.1)
	fade(0, 0.1) watch(0.1)
	fade(1, 0.1) watch(0.1)
	watch(0.5)
	fade(0, 0.1) watch(0.1)
	watch(1)
	fade(1, 0.2) watch(0.2)
	
	
	setCameraLerpDelay(0)
	
	fade(0,1)
	cam_toEntity(v.n)
	shakeCamera(0,0.001)
	overrideZoom(0)
end

