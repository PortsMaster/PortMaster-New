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
	
local function visions(me)
	if isFlag(FLAG_VISION_ENERGYTEMPLE, 1) and isFlag(FLAG_ENERGYBOSSDEAD, 0) then
		vision("EnergyTemple", 3)
		playSfx("VisionWakeup")
		return true
	end
	return false
end

function activate(me)
	local n = getNaija()
	
	avatar_fallOffWall()
	--watch(0.2)
	entity_idle(n)
	
	if getForm() ~= FORM_NORMAL then
		watch(0.5)
		changeForm(FORM_NORMAL)
		watch(0.5)
	end
	
	
	
	local li = 0
	if hasLi() then
		li = getLi()
		--entity_setState(li, STATE_IDLE, -1, 1)
		entity_setState(li, STATE_PUPPET, -1, 1)
		entity_flipToEntity(li, n)
	end
	
	if li ~= 0 then
		fade2(1, 0.5, 1, 1, 1)
		watch(0.5)
		
		entity_setState(li, STATE_PUPPET)
		
		entity_setPosition(li, entity_x(n), entity_y(n))
		
		fade2(0, 0.5, 1, 1, 1)
	end

	
	entity_rotate(n, 0, 0.1)
	esetv(n, EV_LOOKAT, 0)
	entity_swimToNode(n, me)
	entity_watchForPath(n)
	
	entity_setPosition(n, node_x(me), node_y(me), 0.1)
	
	entity_idle(n)
	
	if li ~= 0 then
		entity_clearVel(li)
		entity_setPosition(li, node_x(me), node_y(me)-10, 1)
	end

	setSceneColor(0.5, 0.5, 1, 3)
	entity_animate(n, "sleep", LOOP_INF)
	overrideZoom(1.25, 2)
	watch(1)
	
	if li ~= 0 then
		entity_offset(li, 0, 0)
		entity_setInternalOffset(li, 0, 0)
		entity_clearVel(li)
		entity_setPosition(li, node_x(me), node_y(me),0.1)
		entity_animate(li, "sleep", -1)
	end
	
	emote(EMOTE_NAIJASADSIGH)
	fadeOutMusic(1)
	fadeOut(1)
	watch(1)
	
	entity_heal(getNaija(), 999)
	cureAllStatus()
	
	watch(2)
	
	if not visions(me) then	
		watch(2)
	
		fadeIn(1)
		watch(1)
	
		while (not isLeftMouse()) and (not isRightMouse()) do
			watch(FRAME_TIME)
		end		
	end
	setSceneColor(1, 1, 1, 3)
	entity_idle(n)
	entity_addVel(n, 0, -200)
	overrideZoom(1, 1)
	--musicVolume(1, 1)
	
	
	updateMusic()
	
	esetv(n, EV_NOINPUTNOVEL, 0)
	if li ~= 0 then
		entity_setState(li, STATE_IDLE)
	end
	watch(1)
	esetv(n, EV_NOINPUTNOVEL, 1)
	overrideZoom(0)	
	esetv(n, EV_LOOKAT, 1)
end

function update(me, dt)
end
