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

function init()

	--return
	
	
	setCameraLerpDelay(0.00001)
	
	local black = getNode("black")
	local floatingcity = getNode("floating-city")
	local mia = getNode("mia")
	local nprime = getNode("nprime")
	local energyboss = getNode("energyboss")
	local forestgoddess = getNode("forestgoddess")
	local mithala = getNode("mithala")
	local ericmom = getNode("ericmom")
	local mutantnaija = getNode("mutantnaija")
	local ghostmom = getNode("ghostmom")
	
	
	cam_toNode(black)
	
	setSceneColor(1,1,1)
	
	watch(4)
	
	
	fadeIn(0.1)
	
	fade2(0, 1, 1, 1, 1)
	watch(1)
	
	voice("eric")
	
	watch(12) -- 12
	
	fade2(1, 0.5) watch(0.5)
	cam_toNode(floatingcity)
	fade2(0, 0.5) watch(0.5)
	
	watch(9) -- 9
	
	-- 22
	setSceneColor(0.1, 0.3, 1)
	
	fade2(1, 0.5, 1, 0.5, 0.5)
	watch(0.5)
	
	cam_toNode(black)
	
	-- 22.5
	fade2(0, 4.5, 1, 0.5, 0.5)
	watch(4.5)
	
	-- 26
	watch(4.5)
	
	fade2(1, 0.5, 1, 1, 1)
	watch(0.5)
	
	-- 32
	
	
	fade2(0, 16, 1, 1, 1)
	
	watch(16)
	
	-- 48
	watch(5)
	
	-- 53
	
	cam_toNode(nprime)
	watch(3)
	
	cam_toNode(energyboss)
	watch(3)
	
	cam_toNode(mithala)
	watch(3)
	
	-- 1:02
	
	fade2(1, 4)
	watch(8)
	
	-- 1:10
	
	fade2(1,0)
	
	cam_toNode(ghostmom)
	
	fade2(0,10)
	watch(10)
	
	-- 1:20
	
	watch(10)
	
	-- 1:30
	
	fade2(1, 10)
	watch(10)
	
	-- 1:40
	
	watch(4)
	
	fade2(0,0)
	
	cam_toNode(mutantnaija)
	watch(1)
	
	cam_toNode(ericmom)
	watch(1)
	
	cam_toNode(forestgoddess)
	watch(1)
	
	watch(2)
	
	-- 1:49
	fade2(1, 1)
	watch(1)
	
	-- 1:50
	
	cam_toNode(mia)
	
	fade2(0, 5)
	watch(5)
	
	-- 1: 55
	
	watch(4)
	
	-- 1:59
	fade2(1, 3)
	watch(3)
	
	-- 2:02
	
	cam_toNode(black)
	
	watch(38)
	
	-- 2:40
	
	

	
	
	
	setCameraLerpDelay(0)
	
	loadMap("finalescape")
end

