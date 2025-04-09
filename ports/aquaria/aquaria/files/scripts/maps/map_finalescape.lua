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

v.doit = true
v.doexit = true

function init()

	if v.doit then
	
		local n = getNaija()
		
		shakeCamera(2, 100)
		
		local fadeNode = getNode("FADE")
		
		setCameraLerpDelay(0.0001)
		
		entity_heal(n, 999)
		
		overrideZoom(0.7)
		
		toggleDamageSprite(false)
		
		setInvincible(n, true)
		
		esetv(n, EV_LOOKAT, false)
		
		
		entity_warpToNode(n, getNode("naija1"))
		entity_animate(n, "sleep", -1)
		entity_fh(n)

		
		local li = getLi()
		
		if li == 0 then
			li = createEntity("Li", "")
		end
		
		entity_setState(li, STATE_CARRIED, -1, 1)
		
		entity_warpToNode(li, getNode("li1"))
		entity_animate(li, "sleep", -1)
		
		watch(0.2)
		
		
		setCameraLerpDelay(3)
		
		fade2(0, 1, 1, 1, 1)
		fadeIn(1)
		watch(1)
		
		entity_animate(n, "slowWakeUp")
		while entity_isAnimating(n) do
			watch(FRAME_TIME)
		end
		entity_idle(n)
		cam_toEntity(li)
		watch(2)
		
		fade2(1, 1, 1, 1, 1)
		watch(1)
		
		
		-- help out li
		setCameraLerpDelay(0.0001)
		watch(0.1)
		entity_warpToNode(n, getNode("helpli"))
		
		fade2(0, 0.5, 1, 1, 1)
		
		entity_animate(n, "helpli")
		watch(3)
		
		fade2(1, 1, 1, 1, 1)
		watch(1)
		
		
		-- hug part
		
		setCameraLerpDelay(0.0001)
		
		shakeCamera(5, 100)
		local node = getNode("START")
		entity_setPosition(n, node_x(node), node_y(node))
		cam_toEntity(n)
		
		entity_setPosition(li, entity_x(n)+24, entity_y(n))
		
		entity_animate(li, "idle", -1)
		entity_rotate(li, 0)
		
		local node2 = getNode("END")
		
		entity_setState(li, STATE_CARRIED, -1, 1)
		
		
		--[[
		entity_setPosition(n, node_x(node)-400, node_y(node))
		entity_setPosition(n, node_x(node), node_y(node), -500, 0, 0, 1)
		]]--
		
		entity_flipToEntity(n, li)
		entity_flipToEntity(li, n)
		--entity_fh(li)
		
		entity_animate(li, "hugnaija")
		
		entity_animate(n, "hugli", -1, 4)
		
		watch(0.2)
			
		fade2(0, 1, 1, 1, 1)
		fadeIn(1)

		
		watch(1)
		
		watch(0.5)
		
		entity_animate(n, "look45", -1, 7)
		watch(0.5)
		
		entity_setPosition(n, node_x(node2), node_y(node2), -1100, 0, 0, 1)
		entity_setPosition(li, node_x(node2)+24, node_y(node2), -1100, 0, 0, 1)
		watch(0.5)
		
		entity_animate(li, "look45", -1, 2)
		
		watch(0.5)
		
		while not node_isEntityIn(fadeNode, n) do
			watch(FRAME_TIME)
		end
		
		fade2(1, 1, 1, 1, 1)
		watch(1)
		
		watch(5)
		
		setInvincible(n, false)
		
		setCameraLerpDelay(0)
		--playMusic("theend")
		if v.doexit then
			watch(2)
			
			fade3(1, 5)
			watch(5)
			
			fade2(1, 0.1)
			fade3(0, 0.1)
			watch(1)
			
			setOverrideMusic("theend")
			playMusic("theend")
			
			setFlag(FLAG_ENDING, ENDING_NAIJACAVE)
			loadMap("songcave")
		else
			shakeCamera(0,0)
			fade2(0, 0)
		end
		--jumpState("Credits")
		--fade2(0, 1)
	end
end


