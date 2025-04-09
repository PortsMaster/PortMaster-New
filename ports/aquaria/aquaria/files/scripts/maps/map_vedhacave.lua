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
	setElementLayerVisible(7, false)
	--fadeIn(1)
	--watch(1)
	
	
	
	if isFlag(FLAG_ENDING, ENDING_NAIJACAVE) then
		
		overrideZoom(1)
		local n = getNaija()
		local l = getLi()
		entity_setPosition(l, 0, 0)
		local li = createEntity("lipuppet", "", 0,0)
		entity_msg(li, "end")
		
		local lunode = getNode("baby")
		local luc = createEntity("lucien-baby", "", node_x(lunode), node_y(lunode))
		
		local last = getCostume()
		setCostume("end")
		
		local nd1 = getNode("end_naija")
		local nd2 = getNode("end_li")
		
		entity_setPosition(n, node_x(nd1), node_y(nd1))
		entity_animate(n, "sitback", LOOP_INF)
		entity_setPosition(li, node_x(nd2), node_y(nd2))
		
		
		watch(0.5)
		
		fadeIn(1)
		fade2(0, 1, 0, 0, 0)
		watch(1)
		
		watch(1.5)
		
		voice("naija_endingpart1a")
		
		watch(1.5)
		
		entity_animate(n, "getUpFromSitBack")
		
		watch(3)
		
		
		-- setup 2: husband
		fade2(1, 1, 1, 1, 1)
		watch(1)
		
		local node = getNode("end_naija2")
		entity_setPosition(n, node_x(node), node_y(node))
		entity_flipToEntity(n, li)
		
		entity_idle(n)
		
		watch(0.5)
		
		fade2(0, 1, 1, 1, 1)
		watch(1)
		
		-- fadein
		watch(0.5)
		setNaijaHeadTexture("smile")
		watch(0.2)
		entity_msg(li, "smile")
		watch(1)
		
		
		-- setup 3: hanging out with baby
		fade2(1, 1, 1, 1, 1)
		watch(1)
		
		entity_msg(li, "normal")
		entity_idle(n)
		node = getNode("end_naija3")
		entity_setPosition(n, node_x(node), node_y(node))
		node = getNode("end_li3")
		entity_setPosition(li, node_x(node), node_y(node))
		entity_flipToEntity(li, n)
		entity_flipToEntity(n, li)
		
		entity_animate(li, "sit", -1)
		entity_animate(n, "sitback", -1)
		
		setNaijaHeadTexture("")
		
		cam_toNode(getNode("end_cam3"))
		
		watch(0.5)
		
		overrideZoom(1.2, 10)
		
		fade2(0, 1, 1, 1, 1)
		watch(1)
		
		watch(0.5)
		entity_msg(li, "surprise")
		watch(1.5)
		entity_msg(li, "normal")
		watch(0.5)
		setNaijaHeadTexture("smile")
		watch(0.5)
		
		entity_msg(li, "smile")
		watch(0.5)
		
		
		-- setup 4: looking out doorway
		fade2(1, 1, 1, 1, 1)
		watch(1)
		
		setNaijaHeadTexture("")
		entity_idle(n)
		node = getNode("end_naija4")
		entity_setPosition(n, node_x(node), node_y(node))
		entity_fh(n)
		cam_toEntity(n)
		watch(0.5)
		
		fade2(0, 1, 1, 1, 1)
		watch(1)
		
		setCameraLerpDelay(8)
		overrideZoom(0.7, 20)
		cam_toNode(getNode("end_cam4"))
		
		watchForVoice()
		
		fade2(1, 0.5, 1, 1, 1)
		watch(0.5)
	
		
		--[[
		entity_setPosition(n, node_x(node), node_y(node), 6, 0, 0, 1)
		entity_animate(n, "swim", -1)
		entity_rotate(n, 0, 8, 0, 0, 1)
		while entity_isInterpolating(n) do
			watch(FRAME_TIME)
		end
		entity_animate("idle", 
		watch(2)
		]]--
		
		setFlag(FLAG_ENDING, ENDING_MAINAREA)
		loadMap("MainArea")
		
		--jumpState("Credits")
		--loadMap("NaijaCave")
		
		--[[
		fade2(0, 0.5, 1, 1, 1)
		watch(0.5)
		
		setCameraLerpDelay(0)
		
		cam_toEntity(n)
		
		entity_idle(n)
		]]--
	end
end

